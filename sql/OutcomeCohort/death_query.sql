
CREATE TABLE public.i57oi4pkCodesets (
  codeset_id int NOT NULL,
  concept_id NUMBER(19) NOT NULL
)
;




CREATE TABLE public.i57oi4pkqualified_events

AS
WITH primary_events (event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id)  AS (SELECT P.ordinal as event_id, P.person_id, P.start_date, P.end_date, op_start_date, op_end_date, cast(P.visit_occurrence_id as NUMBER(19)) as visit_occurrence_id
FROM (SELECT E.person_id, E.start_date, E.end_date,
         row_number() OVER (PARTITION BY E.person_id ORDER BY E.sort_date ASC) ordinal,
         OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date, cast(E.visit_occurrence_id as NUMBER(19)) as visit_occurrence_id
  FROM (SELECT C.person_id, C.person_id as event_id, C.death_date as start_date, (C.death_date + NUMTODSINTERVAL(1, 'day')) as end_date,
  CAST(NULL as NUMBER(19)) as visit_occurrence_id, C.death_date as sort_date
FROM (SELECT d.*
  FROM cdm.DEATH d
 
 ) C


-- End Death Criteria
   
   
   ) E
	JOIN cdm.observation_period OP on E.person_id = OP.person_id and E.start_date >=  OP.observation_period_start_date and E.start_date <= op.observation_period_end_date
    WHERE (OP.OBSERVATION_PERIOD_START_DATE + NUMTODSINTERVAL(0, 'day')) <= E.START_DATE AND (E.START_DATE + NUMTODSINTERVAL(0, 'day')) <= OP.OBSERVATION_PERIOD_END_DATE
 ) P
  WHERE P.ordinal = 1
-- End Primary Events
 
 )
 SELECT
event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id

FROM
(SELECT pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal, cast(pe.visit_occurrence_id as NUMBER(19)) as visit_occurrence_id
  FROM primary_events pe
 
 ) QE
 
 ;

--- Inclusion Rule Inserts

create table public.i57oi4pkinclusion_events (inclusion_rule_id NUMBER(19),
	person_id NUMBER(19),
	event_id NUMBER(19)
);

CREATE TABLE public.i57oi4pkincluded_events

AS
WITH cteIncludedEvents(event_id, person_id, start_date, end_date, op_start_date, op_end_date, ordinal)  AS (SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, row_number() over (partition by person_id order by start_date ASC) as ordinal
  FROM (SELECT Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date, SUM(coalesce(POWER(cast(2 as NUMBER(19)), I.inclusion_rule_id), 0)) as inclusion_rule_mask
    FROM public.i57oi4pkqualified_events Q
    LEFT JOIN public.i57oi4pkinclusion_events I on I.person_id = Q.person_id and I.event_id = Q.event_id
    GROUP BY Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date
   ) MG -- matching groups
 
 )
 SELECT
event_id, person_id, start_date, end_date, op_start_date, op_end_date

FROM
cteIncludedEvents Results
  WHERE Results.ordinal = 1
 ;



-- generate cohort periods into #final_cohort
CREATE TABLE public.i57oi4pkcohort_rows

AS
WITH cohort_ends (event_id, person_id, end_date)  AS (SELECT event_id, person_id, op_end_date as end_date FROM public.i57oi4pkincluded_events
 ),
first_ends (person_id, start_date, end_date) as
(SELECT F.person_id, F.start_date, F.end_date
	FROM (SELECT I.event_id, I.person_id, I.start_date, E.end_date, row_number() over (partition by I.person_id, I.event_id order by E.end_date) as ordinal 
	  FROM public.i57oi4pkincluded_events I
	  join cohort_ends E on I.event_id = E.event_id and I.person_id = E.person_id and E.end_date >= I.start_date
	 ) F
	  WHERE F.ordinal = 1
 )
 SELECT
person_id, start_date, end_date

FROM
first_ends ;

CREATE TABLE public.i57oi4pkfinal_cohort

AS
WITH cteEndDates (person_id, end_date)  AS (SELECT person_id
		, (event_date + NUMTODSINTERVAL(-1 * 0, 'day'))  as end_date
	FROM (SELECT person_id
			, event_date
			, event_type
			, MAX(start_ordinal) OVER (PARTITION BY person_id ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal 
			, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY event_date, event_type) AS overall_ord
		FROM (SELECT person_id
				, start_date AS event_date
				, -1 AS event_type
				, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date) AS start_ordinal
			FROM public.i57oi4pkcohort_rows
     
			  UNION ALL
   
   
			SELECT
				person_id
				, (end_date + NUMTODSINTERVAL(0, 'day'))  end_date
				, 1 AS event_type
				, NULL
			FROM public.i57oi4pkcohort_rows
		 ) RAWDATA
	 ) e
	  WHERE (2 * e.start_ordinal) - e.overall_ord = 0
 ),
cteEnds (person_id, start_date, end_date) AS
(SELECT c.person_id
		, c.start_date
		, MIN(e.end_date) AS end_date
	FROM public.i57oi4pkcohort_rows c
	JOIN cteEndDates e ON c.person_id = e.person_id AND e.end_date >= c.start_date
	GROUP BY c.person_id, c.start_date
 )
 SELECT
person_id, min(start_date) as start_date, end_date

FROM
cteEnds
group by person_id, end_date
 ;

DELETE FROM public.cohort where cohort_definition_id = 9000;
INSERT INTO public.cohort (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
SELECT 9000 as cohort_definition_id, person_id, start_date, end_date 
FROM public.i57oi4pkfinal_cohort CO
 ;





TRUNCATE TABLE public.i57oi4pkcohort_rows;
DROP TABLE public.i57oi4pkcohort_rows;

TRUNCATE TABLE public.i57oi4pkfinal_cohort;
DROP TABLE public.i57oi4pkfinal_cohort;

TRUNCATE TABLE public.i57oi4pkinclusion_events;
DROP TABLE public.i57oi4pkinclusion_events;

TRUNCATE TABLE public.i57oi4pkqualified_events;
DROP TABLE public.i57oi4pkqualified_events;

TRUNCATE TABLE public.i57oi4pkincluded_events;
DROP TABLE public.i57oi4pkincluded_events;

TRUNCATE TABLE public.i57oi4pkCodesets;
DROP TABLE public.i57oi4pkCodesets;