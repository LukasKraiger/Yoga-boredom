# Data

The data files are hosted on the project's Zenodo record rather than in this
GitHub repository. To regenerate the prepared analysis dataset, download these
two raw questionnaire files and place them in `Data/raw/` in the repository
root:

- `Start questionnaire.csv`
- `Please complete after each session.csv`

Create the `Data/raw/` folder if it does not already exist. Then, from the
repository root, run:

```bash
Rscript data_prep.R
```

This creates `Data/MPLUS_scale_ordered_intervals2.dat`, the prepared dataset
used by the Mplus models and figure script. The generated dataset is not
tracked in Git.

To skip data preparation, download `MPLUS_scale_ordered_intervals2.dat` from
Zenodo directly into `Data/`.
