# =============================================================================
# fig_pipeline_funnel.R
#
# Purpose:  Create jury pipeline funnel diagram showing mean county-year counts
#           at each stage of the pipeline, with attrition annotations.
#
# Input:    data_final/michigan_panel_B.dta
# Output:   $OL/files/fig/main/fig_pipeline_funnel.pdf
#           $OL/files/fig/main/fig_pipeline_funnel_slides.pdf  (wider, for Beamer)
#
# Usage:    Rscript scripts/fig_pipeline_funnel.R
# =============================================================================

library(haven)
library(ggplot2)
library(dplyr)
library(scales)

# --- Paths ---
rb <- "C:/Users/jensenn/Dropbox/Research Papers/Jury Trials/master/jury_trial_documentation/Documentation/Michigan_replication_cleaned/results_rebuild"
ol <- "C:/Users/jensenn/Dropbox/Apps/Overleaf/Voir Dire 2-20-26"

data_path <- file.path(rb, "data_final", "michigan_panel_B.dta")
fig_dir   <- file.path(ol, "files", "fig", "main")

# --- Read data ---
df <- read_dta(data_path)

# --- Compute means ---
pipeline_means <- df %>%
  summarize(
    Summoned                = mean(summoned, na.rm = TRUE),
    `Told to Report`        = mean(told_to_report, na.rm = TRUE),
    `Actually Reported`     = mean(actually_reported, na.rm = TRUE),
    `Sent to Courtroom`     = mean(sent_to_courtroom, na.rm = TRUE),
    `Questioned in\nVoir Dire` = mean(questioned_in_voir_dire, na.rm = TRUE)
  )

# Reshape to long format
stages <- data.frame(
  stage = c("Summoned", "Told to\nReport", "Actually\nReported",
            "Sent to\nCourtroom", "Questioned in\nVoir Dire"),
  mean_count = as.numeric(pipeline_means[1, ]),
  order = 1:5
)

# Compute retention rates (% of previous stage)
stages$retention <- NA
for (i in 2:nrow(stages)) {
  stages$retention[i] <- stages$mean_count[i] / stages$mean_count[i - 1]
}

# Format labels
stages$count_label <- formatC(round(stages$mean_count), format = "d", big.mark = ",")
stages$retention_label <- ifelse(
  is.na(stages$retention), "",
  paste0(round(stages$retention * 100, 0), "%")
)

# --- Create funnel diagram (paper version) ---
p <- ggplot(stages, aes(x = reorder(stage, -order), y = mean_count)) +
  geom_col(fill = "steelblue", width = 0.7, alpha = 0.85) +
  geom_text(aes(label = count_label), hjust = -0.15, size = 3.2, fontface = "bold") +
  geom_text(
    data = stages %>% filter(!is.na(retention)),
    aes(label = retention_label, y = mean_count * 0.5),
    hjust = 0.5, size = 2.8, color = "white", fontface = "italic"
  ) +
  coord_flip() +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.2)),
    labels = comma
  ) +
  labs(
    x = NULL,
    y = "Mean County-Year Count"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 9, face = "bold"),
    axis.text.x = element_text(size = 8),
    plot.margin = margin(10, 20, 10, 10)
  )

ggsave(
  file.path(fig_dir, "fig_pipeline_funnel.pdf"),
  plot = p, width = 6.5, height = 3.5, device = cairo_pdf
)

# --- Create slides version (wider aspect ratio for Beamer) ---
# Build from scratch to avoid duplicate geom layers from inheriting p
p_slides <- ggplot(stages, aes(x = reorder(stage, -order), y = mean_count)) +
  geom_col(fill = "steelblue", width = 0.7, alpha = 0.85) +
  geom_text(aes(label = count_label), hjust = -0.15, size = 4, fontface = "bold") +
  geom_text(
    data = stages %>% filter(!is.na(retention)),
    aes(label = retention_label, y = mean_count * 0.5),
    hjust = 0.5, size = 3.5, color = "white", fontface = "italic"
  ) +
  coord_flip() +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2)), labels = comma) +
  labs(x = NULL, y = "Mean County-Year Count") +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(size = 11, face = "bold"),
    axis.text.x = element_text(size = 10),
    plot.margin = margin(10, 25, 10, 10)
  )

ggsave(
  file.path(fig_dir, "fig_pipeline_funnel_slides.pdf"),
  plot = p_slides, width = 9, height = 4, device = cairo_pdf
)

cat("Pipeline funnel figures saved to:\n")
cat("  Paper:  ", file.path(fig_dir, "fig_pipeline_funnel.pdf"), "\n")
cat("  Slides: ", file.path(fig_dir, "fig_pipeline_funnel_slides.pdf"), "\n")
cat("\nPipeline stage means:\n")
print(stages[, c("stage", "mean_count", "retention_label")])
