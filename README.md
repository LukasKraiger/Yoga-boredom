# Yoga Boredom Study: Analysis Code

This repository contains the reproducible analysis workflow for the longitudinal yoga and boredom study. It includes data-preparation scripts, Mplus model specifications, and scripts for indirect-effect calculations used in the mediation analyses.

## Project overview

The analyses are based on repeated-measures questionnaire data collected after yoga sessions. The workflow prepares a long-format dataset, computes scale scores, and fits multilevel mediation models in Mplus.

## Repository contents

- `data_prep.R` — pre-processes the raw questionnaire exports and creates the Mplus-ready analysis dataset
- `indirect_effect.R` — reads Mplus estimates and calculates indirect effects
- `mediation_RDSEM_H1_intervall.inp` — longitudinal mediation model 1
- `mediation_RDSEM_H2_intervall.inp` — longitudinal mediation model 2
- `mediation_RDSEM_H3_intervall.inp` — longitudinal mediation model 3
- `mediation_RDSEM_H4_intervall.inp` — longitudinal mediation model 4
- `mediation_RDSEM_H5_OC_intervall.inp` — mediation model for overchallenge
- `mediation_RDSEM_H5_UC_intervall.inp` — mediation model for underchallenge
- `mediation_RDSEM_H5_VA_intervall.inp` — mediation model for valence
- `levels_of_boredom_new.inp` — additional boredom-level model specification

## Requirements

To reproduce the analyses, you need:

- R (version 4.x or later recommended)
- Mplus
- The following R packages:
  - `misty`
  - `MplusAutomation`
  - `officer`
  - `flextable`
  - `dplyr`
  - `lubridate`
  - `tidyr`

## Reproducible workflow

1. Place the raw data files in the adjacent `Data/raw/` directory.
2. Run the data preparation script:

   ```bash
   Rscript data_prep.R
   ```

3. Confirm that the prepared file is created in the `Data/` directory:

   ```text
   Data/MPLUS_scale_ordered_intervals2.dat
   ```

4. Run the relevant Mplus models in the `Code/` directory.
5. Estimate indirect effects from the Mplus output:

   ```bash
   Rscript indirect_effect.R
   ```

## Notes on the analysis scripts

- The R scripts are written with English comments to improve reuse and transparency.
- The processing workflow is fully script-based and can be rerun from the raw source data.
- File paths are relative to the project folder; if you move the repository, update the paths as needed.

## Data protection and reuse

The scripts use the pseudonymous `userId` variable to link repeated measurements within the same participant while avoiding direct personal identifiers in the analytical data. Please handle the raw data according to the study’s ethics and data-protection requirements.

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

## Citation and reproducibility

This repository is intended for scientific reuse and transparent replication. If you adapt or extend the code, please cite the underlying study and clearly document any modifications.
