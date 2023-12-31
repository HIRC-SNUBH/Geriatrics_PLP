
ALTER TABLE PUBLIC.cohort NOLOGGING;
DELETE FROM PUBLIC.cohort WHERE COHORT_DEFINITION_ID = 9003;
-- COHORT_DEFINITION_ID = 131
INSERT /*+ APPEND */ INTO PUBLIC.cohort
WITH DRUG_CODE AS ( 
     SELECT 'HALO' AS DRUG, '90813'   AS SOURCE_CODE, 4166788  AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'HALO' AS DRUG, 'HLP05'   AS SOURCE_CODE, 19081391 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'HALO' AS DRUG, 'HLP15'   AS SOURCE_CODE, 19088113 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'HALO' AS DRUG, 'HLP3'    AS SOURCE_CODE, 42936549 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'HALO' AS DRUG, 'HLP5'    AS SOURCE_CODE, 19081397 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'HALO' AS DRUG, 'HLP50I'  AS SOURCE_CODE, 40165564 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'HALO' AS DRUG, 'HLP5I'   AS SOURCE_CODE, 19081398 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'OLAN' AS DRUG, 'OZP1'    AS SOURCE_CODE, 19081763 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'OLAN' AS DRUG, 'OZP1D'   AS SOURCE_CODE, 785821   AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'OLAN' AS DRUG, 'OZP2'    AS SOURCE_CODE, 19081764 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'OLAN' AS DRUG, 'OZP5'    AS SOURCE_CODE, 19082514 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'OLAN' AS DRUG, 'OZP5D'   AS SOURCE_CODE, 19079154 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'OLAN' AS DRUG, 'OZP7'    AS SOURCE_CODE, 19081765 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'OLAN' AS DRUG, 'OZPI'    AS SOURCE_CODE, 785874   AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'QUET' AS DRUG, 'QTP100'  AS SOURCE_CODE, 766819   AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'QUET' AS DRUG, 'QTP12'   AS SOURCE_CODE, 42970165 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'QUET' AS DRUG, 'QTP200'  AS SOURCE_CODE, 766842   AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'QUET' AS DRUG, 'QTP25'   AS SOURCE_CODE, 766820   AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'QUET' AS DRUG, 'QTP25K'  AS SOURCE_CODE, 766820   AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'QUET' AS DRUG, 'QTPS200' AS SOURCE_CODE, 19134838 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'QUET' AS DRUG, 'QTPS300' AS SOURCE_CODE, 19134840 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'QUET' AS DRUG, 'QTPS400' AS SOURCE_CODE, 19134842 AS CONCEPT_ID FROM DUAL UNION ALL
     SELECT 'QUET' AS DRUG, 'QTPS50'  AS SOURCE_CODE, 19133729 AS CONCEPT_ID FROM DUAL
     
  ), PROCESS_DATA AS (
     SELECT S1.PERSON_ID
          , S1.PROCEDURE_DATE 
          , S2.VISIT_END_DATE 
          , MAX(CASE WHEN C1.DRUG = 'HALO' AND S3.DRUG_EXPOSURE_START_DATE < S1.PROCEDURE_DATE THEN 'Y' ELSE 'N' END) AS OP_BF_HALO_YN 
          , MAX(CASE WHEN C1.DRUG = 'OLAN' AND S3.DRUG_EXPOSURE_START_DATE < S1.PROCEDURE_DATE THEN 'Y' ELSE 'N' END) AS OP_BF_OLAN_YN 
          , MAX(CASE WHEN C1.DRUG = 'QUET' AND S3.DRUG_EXPOSURE_START_DATE < S1.PROCEDURE_DATE THEN 'Y' ELSE 'N' END) AS OP_BF_QUET_YN 
          , MIN(CASE WHEN C1.DRUG = 'HALO' AND S3.DRUG_EXPOSURE_START_DATE BETWEEN S1.PROCEDURE_DATE AND S2.VISIT_END_DATE THEN S3.DRUG_EXPOSURE_START_DATE END) AS DRUG_DATE_HALO 
          , MIN(CASE WHEN C1.DRUG = 'OLAN' AND S3.DRUG_EXPOSURE_START_DATE BETWEEN S1.PROCEDURE_DATE AND S2.VISIT_END_DATE THEN S3.DRUG_EXPOSURE_START_DATE END) AS DRUG_DATE_OLAN 
          , MIN(CASE WHEN C1.DRUG = 'QUET' AND S3.DRUG_EXPOSURE_START_DATE BETWEEN S1.PROCEDURE_DATE AND S2.VISIT_END_DATE THEN S3.DRUG_EXPOSURE_START_DATE END) AS DRUG_DATE_QUET 
       FROM cdm.PROCEDURE_OCCURRENCE S1
          , cdm.VISIT_OCCURRENCE S2
          , cdm.DRUG_EXPOSURE S3
          , DRUG_CODE C1
      WHERE S1.VISIT_OCCURRENCE_ID = S2.VISIT_OCCURRENCE_ID
        AND S1.PERSON_ID = S2.PERSON_ID
        AND S2.PERSON_ID = S3.PERSON_ID
--        AND S1.PROCEDURE_TYPE_CONCEPT_ID = 38000275
        AND S1.PROCEDURE_CONCEPT_ID IN (2000269,2000289,2000307,2001047,2002174,2002522,2003391,2003402,2003403,2003404,2003405,2003407,2003427,2006417,2006419,2006421,4000158,4001100,4001359,4012004,4012305,4012321,4012325,4012461,4012930,4012932,4012936,4013506,4016163,4017329,4017464,4018300,4019422,4019635,4020329,4020330,4020466,4020467,4021544,4022013,4022791,4022910,4026223,4026915,4029416,4029418,4030099,4030148,4030150,4030412,4030824,4030825,4031970,4031972,4032564,4033396,4034657,4035734,4040299,4040924,4041194,4041249,4042907,4046247,4047947,4048556,4049330,4049552,4049678,4049680,4049813,4049816,4050128,4050137,4050138,4050262,4050407,4050408,4051016,4051017,4051018,4051176,4052255,4052391,4052393,4054559,4058266,4062763,4064257,4064257,4065449,4066035,4066442,4066543,4066636,4066807,4066882,4067285,4067461,4067463,4067888,4067908,4068146,4068214,4068634,4069074,4069129,4069166,4069351,4070365,4070372,4070478,4070869,4071096,4071118,4071443,4071443,4071534,4071537,4073199,4073526,4074077,4074846,4076862,4078308,4078310,4080015,4080760,4087575,4088727,4093167,4096461,4097958,4098273,4098731,4099462,4099970,4100324,4100351,4100937,4100937,4101538,4102383,4103646,4105589,4106088,4107567,4107571,4108316,4113224,4114630,4115341,4116629,4116952,4117192,4118196,4118958,4119255,4120657,4120958,4120959,4120960,4120961,4121236,4122303,4122322,4122422,4122777,4122781,4122908,4123402,4123419,4123585,4123739,4124040,4124045,4124310,4124311,4125467,4125467,4125784,4128563,4128864,4128868,4129353,4131021,4131910,4134541,4134717,4135177,4137462,4138691,4139402,4139403,4139548,4139992,4140007,4140686,4141148,4141243,4141254,4141372,4141456,4142182,4142233,4142327,4142436,4144212,4144565,4144584,4144721,4144796,4144800,4144849,4144927,4146780,4147839,4147849,4147913,4148235,4148762,4148793,4148898,4148948,4148975,4149106,4151121,4151530,4151662,4152086,4152745,4157779,4161023,4162987,4163971,4163975,4164150,4164300,4164907,4165576,4165739,4166196,4166294,4166760,4166855,4166993,4167080,4167809,4167978,4168628,4168926,4171187,4171194,4171687,4172166,4172358,4173452,4173612,4174035,4175489,4177376,4179797,4180074,4180164,4181781,4182577,4183842,4184913,4185734,4185848,4186613,4187533,4187786,4191258,4192247,4193037,4193288,4193791,4194124,4194238,4194253,4194372,4194967,4195307,4195648,4195720,4195854,4195874,4196081,4196199,4196678,4196919,4196923,4197068,4197412,4197729,4198190,4198981,4199270,4199951,4199952,4200391,4200418,4201613,4203442,4204677,4209860,4210595,4211860,4211977,4213045,4215782,4216250,4217180,4218295,4219780,4222123,4222325,4222733,4223241,4224173,4224467,4225375,4225427,4225585,4226958,4227016,4227605,4228202,4229920,4230220,4230233,4230250,4231441,4231545,4231680,4231681,4232190,4233085,4233214,4233237,4233412,4233414,4233416,4233417,4234134,4234382,4234811,4234972,4235130,4235749,4236711,4236969,4237353,4237585,4238120,4238497,4238646,4239077,4239473,4240701,4240962,4242997,4243973,4244285,4244809,4245629,4246722,4247012,4249113,4249893,4250458,4250795,4251314,4251929,4253069,4253523,4259121,4259286,4261365,4262797,4262950,4263259,4263386,4263740,4264064,4264119,4264216,4264332,4266622,4266668,4267134,4267296,4268321,4270198,4270222,4270654,4271057,4271058,4271183,4271596,4271929,4271995,4272003,4273524,4275570,4275911,4279534,4279766,4279903,4280083,4280974,4281511,4281814,4281839,4283095,4283832,4286502,4286804,4287259,4287325,4291953,4293893,4295431,4296594,4296620,4296871,4297287,4297515,4299955,4300713,4301125,4302886,4304943,4310408,4312613,4313138,4314146,4314572,4314683,4315014,4316068,4322169,4322178,4322181,4322471,4322818,4323447,4323560,4325283,4327067,4327488,4328484,4329559,4330851,4331609,4336756,4337253,4337833,4339542,4340250,35624144,37111483,37111484,40482705,40486668,40487973,40487974,42538237,44807806,44809616) /* surgical procedure */
        AND S3.DRUG_CONCEPT_ID = C1.CONCEPT_ID
      GROUP BY S1.PERSON_ID, S1.PROCEDURE_DATE, S2.VISIT_END_DATE
)

SELECT 9003          AS COHORT_DEFINITION_ID
     , T1.PERSON_ID AS SUBJECT_ID
     , CASE T2.RN WHEN 1 THEN T1.DRUG_DATE_HALO
                  WHEN 2 THEN T1.DRUG_DATE_OLAN
                  WHEN 3 THEN T1.DRUG_DATE_QUET
       END AS COHORT_START_DATE 
     , T1.VISIT_END_DATE AS COHORT_END_DATE 
  FROM PROCESS_DATA T1
     , (SELECT LEVEL AS RN
          FROM DUAL
       CONNECT BY LEVEL <= 3
       ) T2
 WHERE T1.OP_BF_HALO_YN = 'N'
   AND T1.OP_BF_OLAN_YN = 'N'
   AND T1.OP_BF_QUET_YN = 'N'
   AND CASE T2.RN WHEN 1 THEN T1.DRUG_DATE_HALO
                  WHEN 2 THEN T1.DRUG_DATE_OLAN
                  WHEN 3 THEN T1.DRUG_DATE_QUET
       END IS NOT NULL
;
COMMIT;
ALTER TABLE PUBLIC.cohort LOGGING;