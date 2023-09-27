
# Load PLP Library
library(PatientLevelPrediction)


# Set working directory
setwd("./")
outputFolder <- "Output"

# Set connection parameters
source("./connection_details.R")

# Connect the database
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = password)


# Set Cohort names
cohortTable <- "cohort"
outcomeTable <- "outcome_cohort"


# Set custom covariate settings
## DRUG_ERA per os
drug_era_po_covSet <- createCohortAttrCovariateSettings(attrDatabaseSchema = cohortDatabaseSchema, 
							cohortAttrTable = "drug_era_po_attr",
                                                        attrDefinitionTable = "drug_era_po_def")

## Operation Concept ID
op_concept_id_covSet <- createCohortAttrCovariateSettings(attrDatabaseSchema = cohortDatabaseSchema,
							  cohortAttrTable = "OPERATION_CONCEPT_ID_ATTR",
							  attrDefinitionTable = "OPERATION_CONCEPT_ID_DEF")

## Operation GROUP
op_group_covSet <- createCohortAttrCovariateSettings(attrDatabaseSchema = cohortDatabaseSchema,
						     cohortAttrTable = "OPERATION_GROUP_ATTR",
						     attrDefinitionTable = "OPERATION_GROUP_DEF")
covariateSettingList <- list(covSet1, covSet2, covSet3)

# ML models
gbm <- setGradientBoostingMachine()
lr <- setLassoLogisticRegression()
ada <- setAdaBoost()
rf <- setRandomForest()
dt <- setDecisionTree()
modelList <- list(lr, gbm, ada, rf, dt)

# Setting PLP Covariates
covSet <- createCovariateSettings(useDemographicsGender = TRUE,
                                   useDemographicsAge = TRUE,
                                   useConditionGroupEraLongTerm = TRUE,
                                   useConditionOccurrenceLongTerm = TRUE,
                                   useDistinctConditionCountLongTerm = TRUE,
                                   useProcedureOccurrenceLongTerm = TRUE,
                                   useMeasurementValueLongTerm = TRUE,
                                   useObservationLongTerm = TRUE,
                                   useVisitConceptCountLongTerm = TRUE,
                                   useChads2Vasc = TRUE,
				   excludedCovariateConceptIds = c(2000000018, 37018726),
                                   endDays = -1)
covSet1 <- list(covSet, drug_era_po_covSet)
covSet2 <- list(covSet, drug_era_po_covSet, op_concept_id_covSet)
covSet3 <- list(covSet, drug_era_po_covSet, op_group_covSet)

################# Delirium ################# 
cohortIds <- c(4274)

cohortNames <- c(
                 "General surgery operation(Index date = operation)"
                 )
outcomeIds <- c(9003)
outcomeNames <- c("Delirium")

# Generate the study population
studyPopl <- createStudyPopulationSettings(binary = TRUE,
                                           includeAllOutcomes = TRUE,
                                           removeSubjectsWithPriorOutcome = FALSE,
                                           requireTimeAtRisk = TRUE,
                                           riskWindowStart = 0, 
                                           startAnchor = 'cohort start',
                                           riskWindowEnd = 0,
                                           endAnchor = 'cohort end',
					   minTimeAtRisk = 0
					)
populationSettingList <- list(studyPopl)

# Run PLP Analyses
modelAnalysisList <- createPlpModelSettings(modelList = modelList,
                                            covariateSettingList = covariateSettingList,
                                            populationSettingList = populationSettingList)
allresults <- runPlpAnalyses(connectionDetails = connectionDetails,
                             cdmDatabaseSchema = cdmDatabaseSchema,
                             cdmDatabaseName = cdmDatabaseName,
                             oracleTempSchema = oracleTempSchema,
                             cohortDatabaseSchema = cohortDatabaseSchema,
                             cohortTable = cohortTable,
                             outcomeDatabaseSchema = outcomeDatabaseSchema,
                             outcomeTable = outcomeTable,
                             outputFolder = outputFolder,
                             modelAnalysisList = modelAnalysisList,
                             cohortIds = cohortIds,
                             cohortNames = cohortNames,
                             outcomeIds = outcomeIds,
                             outcomeNames = outcomeNames,
                             maxSampleSize = NULL, 
                             minCovariateFraction = 0,
                             normalizeData = TRUE,
                             testSplit = "subject",
                             testFraction = 0.25,
                             splitSeed = 202103,
                             nfold = 5,
                             verbosity = "DEBUG")

################# Long Term ################# 
cohortIds <- c(4274)
cohortNames <- c("General surgery operation(Index date = operation)"
                 )
outcomeIds <- c(9002)
outcomeNames <- c("Prolonged Postoperative LOS")

# Generate the study population
studyPopl <- createStudyPopulationSettings(binary = TRUE,
                                           includeAllOutcomes = TRUE,
                                           removeSubjectsWithPriorOutcome = FALSE,
                                           requireTimeAtRisk = FALSE,
                                           riskWindowStart = 0, 
                                           startAnchor = 'cohort start',
                                           riskWindowEnd = 0,
                                           endAnchor = 'cohort end',
					   minTimeAtRisk = 0
					)
populationSettingList <- list(studyPopl)


# Run PLP Analyses
modelAnalysisList <- createPlpModelSettings(modelList = modelList,
                                            covariateSettingList = covariateSettingList,
                                            populationSettingList = populationSettingList)

allresults <- runPlpAnalyses(connectionDetails = connectionDetails,
                             cdmDatabaseSchema = cdmDatabaseSchema,
                             cdmDatabaseName = cdmDatabaseName,
                             oracleTempSchema = oracleTempSchema,
                             cohortDatabaseSchema = cohortDatabaseSchema,
                             cohortTable = cohortTable,
                             outcomeDatabaseSchema = outcomeDatabaseSchema,
                             outcomeTable = outcomeTable,
                             outputFolder = outputFolder,
                             modelAnalysisList = modelAnalysisList,
                             cohortIds = cohortIds,
                             cohortNames = cohortNames,
                             outcomeIds = outcomeIds,
                             outcomeNames = outcomeNames,
                             maxSampleSize = NULL, 
                             minCovariateFraction = 0,
                             normalizeData = TRUE,
                             testSplit = "subject",
                             testFraction = 0.25,
                             splitSeed = 202103,
                             nfold = 5,
                             verbosity = "DEBUG")


################# Death or ER (Time at Risk 30 d) ################# 
cohortIds <- c(4274)
cohortNames <- c("General surgery operation(Index date = operation)"
outcomeIds <- c(9001)
outcomeNames <- c("Death or ER (minTimeAtRisk=29")

# Generate the study population
studyPopl <- createStudyPopulationSettings(binary = TRUE,
											includeAllOutcomes = TRUE,
											removeSubjectsWithPriorOutcome = FALSE,
											requireTimeAtRisk = TRUE,
											minTimeAtRisk = 29,
											riskWindowStart = 0, 
											riskWindowEnd = 30)
populationSettingList <- list(studyPopl)


modelAnalysisList <- createPlpModelSettings(modelList = modelList,
											covariateSettingList = covariateSettingList,
											populationSettingList = populationSettingList)


# Run PLP Analyses
allresults <- runPlpAnalyses(connectionDetails = connectionDetails,
							cdmDatabaseSchema = cdmDatabaseSchema,
							cdmDatabaseName = cdmDatabaseName,
							oracleTempSchema = oracleTempSchema,
							cohortDatabaseSchema = cohortDatabaseSchema,
							cohortTable = cohortTable,
							outcomeDatabaseSchema = outcomeDatabaseSchema,
							outcomeTable = outcomeTable,
							outputFolder = outputFolder,
							modelAnalysisList = modelAnalysisList,
							cohortIds = cohortIds,
							cohortNames = cohortNames,
							outcomeIds = outcomeIds,
							outcomeNames = outcomeNames,
							maxSampleSize = NULL, 
							minCovariateFraction = 0,
							normalizeData = TRUE,
							testSplit = "subject",
							testFraction = 0.25,
							splitSeed = 202103,
							nfold = 5,
							verbosity = "DEBUG")


################# Death or ER (Time at Risk 90 d) ################# 
cohortIds <- c(4274)
cohortNames <- c("General surgery operation(Index date = operation)"
outcomeIds <- c(9001)
outcomeNames <- c("Death or ER (minTimeAtRisk=89")

# Generate the study population
studyPopl <- createStudyPopulationSettings(binary = TRUE,
											includeAllOutcomes = TRUE,
											removeSubjectsWithPriorOutcome = FALSE,
											requireTimeAtRisk = TRUE,
											minTimeAtRisk = 89,
											riskWindowStart = 0, 
											riskWindowEnd = 90)
populationSettingList <- list(studyPopl)


modelAnalysisList <- createPlpModelSettings(modelList = modelList,
											covariateSettingList = covariateSettingList,
											populationSettingList = populationSettingList)
											

# Run PLP Analyses
allresults <- runPlpAnalyses(connectionDetails = connectionDetails,
							cdmDatabaseSchema = cdmDatabaseSchema,
							cdmDatabaseName = cdmDatabaseName,
							oracleTempSchema = oracleTempSchema,
							cohortDatabaseSchema = cohortDatabaseSchema,
							cohortTable = cohortTable,
							outcomeDatabaseSchema = outcomeDatabaseSchema,
							outcomeTable = outcomeTable,
							outputFolder = outputFolder,
							modelAnalysisList = modelAnalysisList,
							cohortIds = cohortIds,
							cohortNames = cohortNames,
							outcomeIds = outcomeIds,
							outcomeNames = outcomeNames,
							maxSampleSize = NULL, 
							minCovariateFraction = 0,
							normalizeData = TRUE,
							testSplit = "subject",
							testFraction = 0.25,
							splitSeed = 202103,
							nfold = 5,
							verbosity = "DEBUG")



################# Death (Time at Risk 30 d) ################# 

cohortIds <- c(4274)
cohortNames <- c("General surgery operation(Index date = operation)"
				)
outcomeIds <- c(9000)
outcomeNames <- c("Death (minTimeAtRisk=29")

# Generate the study population
studyPopl <- createStudyPopulationSettings(binary = TRUE,
											includeAllOutcomes = TRUE,
											removeSubjectsWithPriorOutcome = FALSE,
											requireTimeAtRisk = TRUE,
											minTimeAtRisk = 29,
											riskWindowStart = 0, 
											riskWindowEnd = 30)
populationSettingList <- list(studyPopl)


modelAnalysisList <- createPlpModelSettings(modelList = modelList,
											covariateSettingList = covariateSettingList,
											populationSettingList = populationSettingList)
											

# Run PLP Analyses
allresults <- runPlpAnalyses(connectionDetails = connectionDetails,
							cdmDatabaseSchema = cdmDatabaseSchema,
							cdmDatabaseName = cdmDatabaseName,
							oracleTempSchema = oracleTempSchema,
							cohortDatabaseSchema = cohortDatabaseSchema,
							cohortTable = cohortTable,
							outcomeDatabaseSchema = outcomeDatabaseSchema,
							outcomeTable = outcomeTable,
							outputFolder = outputFolder,
							modelAnalysisList = modelAnalysisList,
							cohortIds = cohortIds,
							cohortNames = cohortNames,
							outcomeIds = outcomeIds,
							outcomeNames = outcomeNames,
							maxSampleSize = NULL, 
							minCovariateFraction = 0,
							normalizeData = TRUE,
							testSplit = "subject",
							testFraction = 0.25,
							splitSeed = 202103,
							nfold = 5,
							verbosity = "DEBUG")



################# Death (Time at Risk 90 d) ################# 
cohortIds <- c(4274)
cohortNames <- c("General surgery operation(Index date = operation)"
				)
outcomeIds <- c(9000)
outcomeNames <- c("Death (minTimeAtRisk=89")

studyPopl <- createStudyPopulationSettings(binary = TRUE,
											includeAllOutcomes = TRUE,
											removeSubjectsWithPriorOutcome = FALSE,
											requireTimeAtRisk = TRUE,
											minTimeAtRisk = 89,
											riskWindowStart = 0, 
											riskWindowEnd = 90)
populationSettingList <- list(studyPopl)


modelAnalysisList <- createPlpModelSettings(modelList = modelList,
											covariateSettingList = covariateSettingList,
											populationSettingList = populationSettingList)
					

# Run PLP Analyses
allresults <- runPlpAnalyses(connectionDetails = connectionDetails,
							cdmDatabaseSchema = cdmDatabaseSchema,
							cdmDatabaseName = cdmDatabaseName,
							oracleTempSchema = oracleTempSchema,
							cohortDatabaseSchema = cohortDatabaseSchema,
							cohortTable = cohortTable,
							outcomeDatabaseSchema = outcomeDatabaseSchema,
							outcomeTable = outcomeTable,
							outputFolder = outputFolder,
							modelAnalysisList = modelAnalysisList,
							cohortIds = cohortIds,
							cohortNames = cohortNames,
							outcomeIds = outcomeIds,
							outcomeNames = outcomeNames,
							maxSampleSize = NULL, 
							minCovariateFraction = 0,
							normalizeData = TRUE,
							testSplit = "subject",
							testFraction = 0.25,
							splitSeed = 202103,
							nfold = 5,
							verbosity = "DEBUG")

