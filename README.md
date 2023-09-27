# Geriatrics Patient Level Prediction


## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)

## Requirements

Before getting started with the Patient Level Prediction, make sure you have the following prerequisites installed:

- R 4.0.2: Download and install R from the [official website](https://cran.r-project.org/src/base/R-4/).
- Python 3.8.2: Download and install Python from the [official website](https://www.python.org/downloads/).

- pip: pip is the package installer for Python. It is usually included with Python, but you can upgrade it using `pip install --upgrade pip`.

Additionally, you'll need the following Python libraries, which can be installed using pip:

- NumPy: `pip install numpy`
- Pandas: `pip install pandas`
- Scikit-Learn: `pip install scikit-learn`

## Installation

You can install the OHDSI Patient Level Prediction package by cloning this repository:

```bash
git clone https://github.com/HIRC-SNUBH/Geriatrics_PLP.git
```

Once you have cloned the repository, navigate to the project directory and run `‘requirements.R’` script. :

```bash

cd Geriatrics_PLP
Rscript ./requirements.R

```

## Usage

To use the Geriatrics Patient Level Prediction model in your own project, follow these steps:
1. Run the script to create cohort tables:

```bash

psql -h HOST -U USERNAME-d DATABASE -f ./sql/TargetCohort/Target_Cohort.sql
psql -h HOST -U USERNAME-d DATABASE -f ./sql/OutcomeCohort/los.sql
psql -h HOST -U USERNAME-d DATABASE -f ./sql/OutcomeCohort/delirium.sql 
psql -h HOST -U USERNAME-d DATABASE -f ./sql/OutcomeCohort/death_query.sql 
psql -h HOST -U USERNAME-d DATABASE -f ./sql/OutcomeCohort/death_or_er_30.sql
psql -h HOST -U USERNAME-d DATABASE -f ./sql/OutcomeCohort/death_or_er_90.sql

```

2. Run the script to create custom covariate tables:

```bash

psql -h HOST -U USERNAME-d DATABASE -f ./sql/CustomCovariate/custom_covarite_op.sql 
psql -h HOST -U USERNAME-d DATABASE -f ./sql/CustomCovariate/custom_covarite_po.sql

```

3. Replace `’connection_detail.R’` with the variables to the CDM database:

4. Run `’RunPLP.R’`script to train the model and perform internal validation:

```bash

Rscript RunPLP.R

```

5. Run `'RunExternalValidation.R'` to perform external validation:

```bash

Rscript RunExternalValidation.R

```

