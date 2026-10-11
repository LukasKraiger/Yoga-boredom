# Data preparation script for the longitudinal boredom study
#
# This script reads the raw CSV exports from the mobile data collection app,
# removes administrative/test accounts, filters participants to those with at
# least two repeated assessments, and creates a compact dataset that can be
# used by Mplus for longitudinal mediation models.

# Load required R packages.
# The functions used here are part of the analysis workflow for reading raw CSV
# files and preparing a Mplus-compatible dataset.
misty::libraries(misty, MplusAutomation, officer, flextable, dplyr, lubridate, tidyr)
setsource()

# Read the baseline questionnaire and the repeated post-session assessments.
# These are the source files from which the prepared analysis dataset is derived.
start_df <- read.data("Data/raw/Start questionnaire.csv")
esm_df <- read.data("Data/raw/Please complete after each session.csv")

# Remove administrative and test participants from the raw data.
# These accounts are not part of the study sample and should not appear in the
# final analysis dataset.
start_df <- start_df[start_df$userId != "Fnek-5SRz-zkHU", ]
esm_df <- esm_df[esm_df$userId != "Fnek-5SRz-zkHU", ]

start_df <- start_df[start_df$userId != "RRhM-KfF9-rV7S", ]
esm_df <- esm_df[esm_df$userId != "RRhM-KfF9-rV7S", ]

# Keep only participants with at least two repeated ESM responses.
# This ensures that each participant contributes enough observations to estimate
# within-person change over time.
esm_df_filtered <- esm_df |>
  group_by(userId) |>
  filter(n() >= 2) |>
  ungroup()

# Restrict the baseline dataset to the participants retained for the longitudinal
# analyses.
start_df_filtered <- start_df[start_df$userId %in% esm_df_filtered$userId, ]

# Compute the time interval between consecutive measurement occasions.
# The first measurement occasion is set to 0 days to anchor the longitudinal
# structure for Mplus.
esm_df_neu_2_intervals <- esm_df_filtered |>
  arrange(userId, responseTime_formatted) |>
  group_by(userId) |>
  mutate(
    intervaldays = ifelse(
      is.na(lag(responseTime_formatted)),
      0,
      as.numeric(difftime(responseTime_formatted, lag(responseTime_formatted), units = "days"))
    )
  ) |>
  ungroup()

# Create mean scale scores from the repeated item batteries.
# These scale scores are used to represent the latent constructs in the Mplus
# models: boredom (BO), valence (VA), overchallenge (OC), underchallenge (UC),
# and mood (MO).
esm_df_neu_2_scale_intervals <- esm_df_neu_2_intervals %>%
  rowwise() %>%
  mutate(
    BO = mean(c_across(starts_with("SB01.")), na.rm = TRUE),
    VA = mean(c_across(starts_with("VL01.")), na.rm = TRUE),
    OC = mean(c_across(starts_with("CO01.")), na.rm = TRUE),
    UC = mean(c_across(starts_with("CO02.")), na.rm = TRUE),
    MO = mean(c_across(starts_with("MO01.")), na.rm = TRUE)
  ) %>%
  ungroup()

# Keep the columns needed for the Mplus DSEM input.
# This step reduces the dataset to the participant ID, scale scores, and the
# time-interval variable used by the longitudinal models.
esm_df_neu_2_scale_intervals <- esm_df_neu_2_scale_intervals[, c(
  "userId", "SB01.1", "SB01.2", "SB01.3", "SB01.4", "SB01.5",
  "VL01.1", "VL01.2", "VL01.3", "VL01.4", "VL01.5",
  "MO01.1", "MO01.2", "MO01.3", "MO01.4",
  "CO01.1", "CO01.2", "CO01.3", "CO01.4", "CO01.5",
  "CO02.1", "CO02.2", "CO02.3", "CO02.4", "CO02.5", "intervaldays",
  "BO", "VA", "OC", "UC", "MO"
)]

# Order the final dataset by participant and time.
# This produces a clean longitudinal structure that is easier to inspect and
# interpret in Mplus.
esm_df_neu_2_scale_intervals_ordered <- esm_df_neu_2_scale_intervals[order(
  esm_df_neu_2_scale_intervals$userId,
  esm_df_neu_2_scale_intervals$intervaldays
), ]

# Final dataset for Mplus: keep only the variables required by the mediation
# models and round the scale scores for stable numeric export.
df_MPlus_scale_intervals_ordered <- esm_df_neu_2_scale_intervals_ordered[, c(
  "userId",
  "BO", "VA", "OC",
  "UC",
  "MO", "intervaldays"
)]

df_MPlus_scale_intervals_ordered[, -1] <- round(df_MPlus_scale_intervals_ordered[, -1], 2)

# Export the prepared dataset in a format compatible with Mplus.
# The output file is stored in the `Data/` directory and is the canonical input
# for the repeated-measures mediation models.
prepareMplusData(
  df_MPlus_scale_intervals_ordered,
  filename = "Data/MPLUS_scale_ordered_intervals2.dat",
  inpfile = TRUE
)
