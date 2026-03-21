# =============================================================================
# heterogeneity_plots.R
# Population-Heterogeneity Visualizations for Michigan Jury Trial Paper
# =============================================================================
#
# PURPOSE:
#   Produces three figures documenting how the relationship between electoral
#   pressure and jury utilization varies across Michigan's highly skewed county
#   population distribution. These plots support the population-heterogeneity
#   analysis reported in the paper (Table A8 and related discussion).
#
# OUTPUT FILES (saved to output/figures/):
#   1. heterogeneity_pop_distribution.png
#      — Density of county populations (log scale) with median marker.
#        Motivates why population heterogeneity matters: the median county
#        (~37,650) is an order of magnitude smaller than the mean (~119,835).
#
#   2. heterogeneity_utilization_scatter.png
#      — 2x2 panel: actually_reported, pct_told_to_report, pct_capital_felony,
#        pct_other_felony plotted against county population (log scale),
#        colored by election-pressure status. LOESS smoothers show nonlinear
#        population gradients. Vertical dashed line at median population.
#
#   3. heterogeneity_election_differential.png
#      — County-level election-year differential (election minus non-election
#        mean) for key outcomes, plotted against county population. Directly
#        visualizes where the treatment effect is concentrated.
#
# DATA:
#   michigan_panel_B.dta (Panel B: all courts, 83 counties, 579 obs)
#   COVID years 2020-2021 already excluded from the dataset.
#
# USAGE:
#   Set working directory to results_rebuild/ and run:
#     Rscript scripts/heterogeneity_plots.R
#
# REQUIRES:
#   haven, ggplot2, dplyr, tidyr, patchwork, scales
# =============================================================================

# --- Libraries ---------------------------------------------------------------
library(haven)
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)
library(scales)

# --- Configuration -----------------------------------------------------------
# Paths (relative to results_rebuild/)
data_path    <- "data_final/michigan_panel_B.dta"
output_dir   <- "output/figures"
overleaf_fig <- "C:/Users/jensenn/Dropbox/Apps/Overleaf/Voir Dire 2-20-26/files/fig/main"

# Ensure output directory exists
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Plot settings
dpi    <- 300
theme_set(theme_minimal(base_size = 12) +
            theme(
              plot.title       = element_text(face = "bold", size = 13),
              plot.subtitle    = element_text(size = 10, color = "grey30"),
              strip.text       = element_text(face = "bold", size = 11),
              panel.grid.minor = element_blank(),
              legend.position  = "bottom"
            ))

# Colorblind-safe palette: two-color for election vs non-election
color_election    <- "#D55E00"   # vermillion (election pressure)
color_nonelection <- "#0072B2"   # blue (no pressure)
color_palette     <- c("0" = color_nonelection, "1" = color_election)
label_palette     <- c("0" = "Non-Election Year", "1" = "Election-Pressure Year")

# --- Load Data ---------------------------------------------------------------
d <- read_dta(data_path)

# Label the treatment variable for plotting
d <- d %>%
  mutate(
    pressure_label = factor(
      treat_pros_pressure,
      levels = c(0, 1),
      labels = c("Non-Election Year", "Election-Pressure Year")
    )
  )

# Median population (pooled across all county-years)
median_pop <- median(d$county_pop, na.rm = TRUE)
cat("Median county population:", comma(median_pop), "\n")
cat("Mean county population: ", comma(round(mean(d$county_pop, na.rm = TRUE))), "\n")
cat("Population range:       ", comma(min(d$county_pop, na.rm = TRUE)), "to",
    comma(max(d$county_pop, na.rm = TRUE)), "\n\n")


# =============================================================================
# PLOT 1: County Population Distribution
# =============================================================================
# Show the extreme right-skew. Pooled across years since population changes
# are small within the 2016-2024 window.

p1 <- ggplot(d, aes(x = county_pop)) +
  geom_density(fill = "steelblue", alpha = 0.4, color = "steelblue4") +
  geom_vline(xintercept = median_pop, linetype = "dashed", color = "grey20",
             linewidth = 0.7) +
  annotate("text",
           x = median_pop * 1.15, y = Inf, vjust = 2, hjust = 0,
           label = paste0("Median = ", comma(median_pop)),
           size = 3.5, color = "grey20") +
  annotate("text",
           x = mean(d$county_pop, na.rm = TRUE) * 1.15, y = Inf,
           vjust = 3.5, hjust = 0,
           label = paste0("Mean = ", comma(round(mean(d$county_pop, na.rm = TRUE)))),
           size = 3.5, color = "grey50", fontface = "italic") +
  scale_x_log10(
    labels = comma,
    breaks = c(2000, 5000, 10000, 25000, 50000, 100000, 250000, 500000, 1000000, 2000000)
  ) +
  labs(
    title    = "Distribution of County Population (Michigan, 2016\u20132024)",
    subtitle = "Log scale. 83 counties pooled across 7 non-COVID years (579 county-years).",
    x        = "County Population (log scale)",
    y        = "Density",
    caption  = "Data: Michigan SCAO jury utilization reports. COVID years 2020\u20132021 excluded."
  )

ggsave(file.path(output_dir, "heterogeneity_pop_distribution.png"),
       plot = p1, width = 8, height = 5, dpi = dpi)
cat("Saved: heterogeneity_pop_distribution.png\n")


# =============================================================================
# PLOT 2: Juror Utilization by Population — Election vs Non-Election Years
# =============================================================================
# 2x2 panel with LOESS smoothers, colored by treatment status.

# Reshape to long format for the four outcomes
outcomes_scatter <- d %>%
  select(county_pop, pressure_label, treat_pros_pressure,
         actually_reported, pct_told_to_report,
         pct_capital_felony, pct_other_felony) %>%
  pivot_longer(
    cols      = c(actually_reported, pct_told_to_report,
                  pct_capital_felony, pct_other_felony),
    names_to  = "outcome",
    values_to = "value"
  ) %>%
  mutate(
    outcome = factor(outcome,
                     levels = c("actually_reported", "pct_told_to_report",
                                "pct_capital_felony", "pct_other_felony"),
                     labels = c("(A) Jurors Actually Reported",
                                "(B) % Told to Report",
                                "(C) Capital Felony Share (%)",
                                "(D) Other Felony Share (%)"))
  )

p2 <- ggplot(outcomes_scatter,
             aes(x = county_pop, y = value, color = pressure_label)) +
  geom_point(alpha = 0.3, size = 1.2) +
  geom_smooth(method = "loess", se = TRUE, alpha = 0.15, linewidth = 1,
              span = 0.75) +
  geom_vline(xintercept = median_pop, linetype = "dashed", color = "grey40",
             linewidth = 0.5) +
  facet_wrap(~ outcome, scales = "free_y", ncol = 2) +
  scale_x_log10(labels = comma,
                breaks = c(5000, 25000, 100000, 500000, 2000000)) +
  scale_color_manual(values = c("Non-Election Year"          = color_nonelection,
                                "Election-Pressure Year"     = color_election),
                     name = "") +
  labs(
    title    = "Jury Utilization by County Population and Electoral Pressure",
    subtitle = "LOESS smoothers with 95% CI. Dashed line = median county population.",
    x        = "County Population (log scale)",
    y        = NULL,
    caption  = "Panel B (all courts). 83 counties, 2016\u20132024 excl. COVID."
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(output_dir, "heterogeneity_utilization_scatter.png"),
       plot = p2, width = 10, height = 8, dpi = dpi)
cat("Saved: heterogeneity_utilization_scatter.png\n")


# =============================================================================
# PLOT 3: Election-Year Differential by Population
# =============================================================================
# For each county, compute:
#   mean(outcome | election year) - mean(outcome | non-election year)
# Then plot this differential against county population.
# This directly visualizes WHERE the treatment effect is largest.

# Compute county-level means by treatment status
# Convert treatment to character to ensure clean pivot_wider column names
county_means <- d %>%
  mutate(trt = paste0("t", as.integer(treat_pros_pressure))) %>%
  group_by(county_id, county, trt) %>%
  summarise(
    county_pop          = mean(county_pop, na.rm = TRUE),
    actually_reported   = mean(actually_reported, na.rm = TRUE),
    pct_told_to_report  = mean(pct_told_to_report, na.rm = TRUE),
    total_jury_verdicts = mean(total_jury_verdicts, na.rm = TRUE),
    utilization_rate    = mean(utilization_rate, na.rm = TRUE),
    n_years             = n(),
    .groups = "drop"
  )

# Pivot to wide: one row per county with election and non-election means
county_wide <- county_means %>%
  pivot_wider(
    id_cols     = c(county_id, county),
    names_from  = trt,
    values_from = c(county_pop, actually_reported, pct_told_to_report,
                    total_jury_verdicts, utilization_rate, n_years),
    names_sep   = "_"
  )

# Use non-election population as the county's reference population
# (more observations, more stable estimate)
county_wide <- county_wide %>%
  mutate(county_pop = coalesce(county_pop_t0, county_pop_t1))

# Compute differentials (election minus non-election)
county_diff <- county_wide %>%
  mutate(
    diff_reported   = actually_reported_t1   - actually_reported_t0,
    diff_pct_told   = pct_told_to_report_t1  - pct_told_to_report_t0,
    diff_verdicts   = total_jury_verdicts_t1  - total_jury_verdicts_t0,
    diff_util_rate  = utilization_rate_t1     - utilization_rate_t0
  ) %>%
  # Keep only counties that have BOTH election and non-election observations
  filter(!is.na(diff_reported), !is.na(diff_pct_told))

cat("\nCounties with both election and non-election obs:",
    nrow(county_diff), "of 83\n")

# Reshape for faceted plot
diff_long <- county_diff %>%
  select(county_id, county, county_pop,
         diff_reported, diff_pct_told, diff_verdicts, diff_util_rate) %>%
  pivot_longer(
    cols      = starts_with("diff_"),
    names_to  = "outcome",
    values_to = "differential"
  ) %>%
  mutate(
    outcome = factor(outcome,
                     levels = c("diff_reported", "diff_pct_told",
                                "diff_verdicts", "diff_util_rate"),
                     labels = c("(A) Jurors Actually Reported",
                                "(B) % Told to Report (pp)",
                                "(C) Total Jury Verdicts",
                                "(D) Utilization Rate (pp)"))
  )

p3 <- ggplot(diff_long,
             aes(x = county_pop, y = differential)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey60",
             linewidth = 0.4) +
  geom_point(alpha = 0.5, size = 1.8, color = "grey30") +
  geom_smooth(method = "loess", se = TRUE, color = color_election,
              fill = color_election, alpha = 0.15, linewidth = 1,
              span = 0.75) +
  geom_vline(xintercept = median_pop, linetype = "dashed", color = "grey40",
             linewidth = 0.5) +
  facet_wrap(~ outcome, scales = "free_y", ncol = 2) +
  scale_x_log10(labels = comma,
                breaks = c(5000, 25000, 100000, 500000, 2000000)) +
  labs(
    title    = "Election-Year Differential in Jury Outcomes by County Population",
    subtitle = paste0(
      "Each point = one county. Differential = election-year mean \u2212 ",
      "non-election-year mean.\nLOESS smoother in vermillion. ",
      "Dashed line = median population (", comma(median_pop), ")."
    ),
    x        = "County Population (log scale)",
    y        = "Election-Year Differential",
    caption  = "Panel B (all courts). Only counties with both election and non-election observations."
  )

ggsave(file.path(output_dir, "heterogeneity_election_differential.png"),
       plot = p3, width = 10, height = 8, dpi = dpi)
cat("Saved: heterogeneity_election_differential.png\n")


# =============================================================================
# Deliver to Overleaf
# =============================================================================
# Only the election-differential plot is used in the paper (renamed on copy)
file.copy(
  file.path(output_dir, "heterogeneity_election_differential.png"),
  file.path(overleaf_fig, "fig_heterogeneity_differential.png"),
  overwrite = TRUE
)
cat("Delivered to Overleaf:", file.path(overleaf_fig, "fig_heterogeneity_differential.png"), "\n")


# =============================================================================
# Summary
# =============================================================================
cat("\n--- Complete ---\n")
cat("All plots saved to:", normalizePath(output_dir), "\n")
cat("Files:\n")
cat("  1. heterogeneity_pop_distribution.png     (8x5 in, 300 DPI)\n")
cat("  2. heterogeneity_utilization_scatter.png   (10x8 in, 300 DPI)\n")
cat("  3. heterogeneity_election_differential.png (10x8 in, 300 DPI)\n")
cat("  -> fig_heterogeneity_differential.png delivered to Overleaf\n")
