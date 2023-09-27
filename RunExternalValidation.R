setwd("./")
library(SqlRender)
library(PatientLevelPrediction)
library(DatabaseConnector)

dbms <- "postgresql"
user <- "user"
password <- "password"
server <- "127.0.0.1/postgres"
port <- "5432"

cdmDatabaseSchema <- "cdm"
cdmDatabaseName <- "cdm"
cohortDatabaseSchema <- "public"
cohortTable <- "cohort"
exposureDatabaseSchema <- "public"
outcomeDatabaseSchema <- "public"
outcomeTable <- "cohort"
vocaSchema <- "cdm"   

validation_output_dir = 'validation_output'

test_result_path_list = c('Output')
### Cohort mapping
#### Key : Original Cohort Id, value : external validation cohort Id
cohort_map_dict = list()

####Target Cohort
# Index_date = admission
targetCohortId_admission_gs = 2186
targetCohortId_admission_os = 2188
cohort_map_dict[["2186"]] <- as.character(targetCohortId_admission_gs) # GS op
cohort_map_dict[["2188"]] <- as.character(targetCohortId_admission_os) # OS op
# Index_date = operation
targetCohortId_sugery_gs = 2176
targetCohortId_sugery_os = 2178
cohort_map_dict[["2176"]] <- as.character(targetCohortId_sugery_gs) # GS op
cohort_map_dict[["2178"]] <- as.character(targetCohortId_sugery_os) # OS op

#### Outcome Cohort
outcomeCohortId_death = 122
outcomeCohortId_longterm = 2164
outcomeCohortId_death_or_er = 1382
outcomeCohortId_any_er_visit = 117
outcomeCohortId_delirium = 131
outcomeCohortId_discharge = 112
outcomeCohortId_icu_admission = 116
cohort_map_dict[["122"]] <- as.character(outcomeCohortId_death) # Expired in the hospital
cohort_map_dict[["2164"]] <- as.character(outcomeCohortId_longterm) # Long term admission
cohort_map_dict[["1382"]] <- as.character(outcomeCohortId_death_or_er) # death or ER
cohort_map_dict[["117"]] <- as.character(outcomeCohortId_any_er_visit) # any ER visit
cohort_map_dict[["131"]] <- as.character(outcomeCohortId_delirium) # Delirium
cohort_map_dict[["112"]] <- as.character(outcomeCohortId_discharge) # Discharge - Exclude home
cohort_map_dict[["116"]] <- as.character(outcomeCohortId_icu_admission) # ICU admission



connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = password,
                                                                port = port)
connection <- connect(connectionDetails)


############ validation section())
for(result_path in test_result_path_list){
  settings <- read.csv(file.path(result_path, 'settings.csv'))
  #Analysis Path
  for(i in 1:nrow(settings)){
    row <- settings[i,]
    {
      analysis_path <- paste0('Analysis_', row$analysisId)
      analysis_path <- file.path(result_path, analysis_path)
      plpdata_path <- file.path(result_path,strsplit(row$plpDataFolder,'/')[[1]][-1])
      
	  input_plpData <- loadPlpData(file = plpdata_path)
      input_plpResult <- loadPlpResult(dirPath = file.path(analysis_path,'plpResult'))
      input_cohortName <- row$cohortName
      input_outcomeName <- row$outcomeName
      input_cohortId <-as.numeric(cohort_map_dict[[as.character(row$cohortId)]])
      input_outcomeId <-as.numeric(cohort_map_dict[[as.character(row$outcomeId)]])
      if(input_plpResult$model$modelSettings$model == 'knn'){input_plpResult$model$model <- file.path(getwd(), input_plpResult$model$model)}
      
      output_valid_rds_dir <- file.path(validation_output_dir,paste0(result_path,'_Analysis_', row$analysisId))
      input_plpResult$inputSetting$dataExtrractionSettings$covariateSettings[[2]]$attrDatabaseSchema <- 'public'
      input_plpResult$inputSetting$dataExtrractionSettings$covariateSettings[[2]]$attrDefinitionTable <- 'DRUG_ERA_PO_DEF'
      input_plpResult$inputSetting$dataExtrractionSettings$covariateSettings[[2]]$cohortAttrTable <- 'DRUG_ERA_PO_ATTR'
      input_plpResult$model$metaData$call$covariateSettings[[2]]$attrDatabaseSchema <- 'public'
      input_plpResult$model$metaData$call$covariateSettings[[2]]$attrDefinitionTable <- 'DRUG_ERA_PO_DEF'
      input_plpResult$model$metaData$call$covariateSettings[[2]]$cohortAttrTable <- 'DRUG_ERA_PO_ATTR'
      dir.create(output_valid_rds_dir, showWarnings =  FALSE)
      dir.create(paste0(output_valid_rds_dir,'/cdm'), showWarnings =  FALSE)
      dir.create(paste0(output_valid_rds_dir,'/cdm/',paste0('Analysis_', row$analysisId)), showWarnings =  FALSE)
      input_validationResult = externalValidatePlp(
        plpResult = input_plpResult,
        connectionDetails = connectionDetails,
        validationSchemaTarget = cohortDatabaseSchema,
        validationSchemaOutcome = cohortDatabaseSchema,
        validationSchemaCdm = cdmDatabaseSchema,
        databaseNames = c(cdmDatabaseName),
        validationTableTarget = cohortTable,
        validationTableOutcome = outcomeTable,
        validationIdTarget = input_cohortId,
        validationIdOutcome = input_outcomeId,
        #oracleTempSchema = oracleTempSchema,
        outputFolder = output_valid_rds_dir,
        keepPrediction = TRUE)
      
    }
  }
}
