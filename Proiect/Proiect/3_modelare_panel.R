
# ==============================================================================
# PROIECT ECONOMETRIE: APLICAȚIA 2 - MODELE CU DATE DE TIP PANEL
# ==============================================================================
# Etapa 3: Analiză completă Panel Data
# - Pooled OLS, Fixed Effects, Random Effects
# - Hausman Test
# - Teste specifice panel: CD, autocorelare, heteroscedasticitate, efecte timp
# ==============================================================================

if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  readxl, tidyverse, writexl, broom,    # Data handling
  plm, lmtest, sandwich, car,           # Panel models & tests
  Formula                               # Formula handling
)

setwd("C:/Users/Jastin/Desktop/Econometrie/Proiect-Econometrie/Proiect/Proiect")

# Sink Output
sink("Output/Rapoarte/rezultate_panel_complet.txt", split = TRUE)

cat("=================================================================\n")
cat("     APLICAȚIA 2: MODELE CU DATE DE TIP PANEL - ANALIZĂ COMPLETĂ \n")
cat("=================================================================\n\n")

# ==============================================================================
# 1. ÎNCĂRCARE ȘI PREGĂTIRE DATE PANEL
# ==============================================================================

cat("--- 1. ÎNCĂRCARE DATE PANEL ---\n\n")

data_path <- "Cleaned Data/"

# Citire date
df_theft <- read_excel(paste0(data_path, "theft_cleaned.xlsx"))
df_gdp <- read_excel(paste0(data_path, "gdp_cleaned.xlsx"))
df_unemp <- read_excel(paste0(data_path, "unemployment_cleaned.xlsx"))
df_immig <- read_excel(paste0(data_path, "immigration_cleaned.xlsx"))
df_pop <- read_excel(paste0(data_path, "population_density_cleaned.xlsx"))

# Funcție helper pentru pivot - folosim Tara (structura reală a datelor)
process_wide_data <- function(df, val_name) {
  names(df)[1] <- "Tara"
  df %>%
    pivot_longer(-Tara, names_to = "An", values_to = val_name) %>%
    mutate(An = as.numeric(An))
}

# Transformare și merge
df_list <- list(
  process_wide_data(df_theft, "Furturi"),
  process_wide_data(df_gdp, "PIB"),
  process_wide_data(df_unemp, "Someri"),
  process_wide_data(df_immig, "Imigratie"),
  process_wide_data(df_pop, "Densitate")
)

df_panel <- df_list %>% reduce(left_join, by = c("Tara", "An"))

# Clasificare Est_Vest
eastern_countries <- c("Bulgaria", "Croatia", "Czechia", "Estonia", "Hungary", "Latvia", 
                       "Lithuania", "Poland", "Romania", "Slovakia", "Slovenia", "Albania",
                       "North Macedonia", "Serbia", "Montenegro", "Bosnia and Herzegovina")

df_panel_final <- df_panel %>%
  mutate(
    ln_Furturi = log(Furturi),
    ln_PIB = log(PIB),
    ln_Someri = log(Someri),
    ln_Imigratie = log(Imigratie + 1),
    ln_Densitate = log(Densitate),
    Est_Vest = ifelse(Tara %in% eastern_countries, 1, 0),
    An_Factor = as.factor(An)
  ) %>%
  filter(!is.na(ln_Furturi) & !is.na(ln_PIB) & !is.na(ln_Someri))

cat("Structura Panel:\n")
cat("- Număr țări (n):", length(unique(df_panel_final$Tara)), "\n")
cat("- Număr ani (T):", length(unique(df_panel_final$An)), "\n")
cat("- Total observații (N):", nrow(df_panel_final), "\n")
cat("- Tip panel: Balanced\n\n")

# Declarare pdata.frame
pdata <- pdata.frame(df_panel_final, index = c("Tara", "An"))

cat("pdata.frame creat cu succes.\n")
cat("Dimensiuni pdata:", pdim(pdata)$nT$n, "țări ×", pdim(pdata)$nT$T, "ani =", 
    pdim(pdata)$nT$N, "obs.\n\n")

# ==============================================================================
# 2. ESTIMARE MODELE PANEL
# ==============================================================================

cat("=================================================================\n")
cat("               2. ESTIMARE MODELE PANEL                          \n")
cat("=================================================================\n\n")

formula_panel <- ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate

# --- Model A: Pooled OLS ---
cat("--- 2.1 Model Pooled OLS ---\n")
cat("Ignoră structura panel, tratează toate observațiile ca independente.\n\n")
model_pool <- plm(formula_panel, data = pdata, model = "pooling")
summary_pool <- summary(model_pool)
print(summary_pool)
cat("\n")

# --- Model B: Fixed Effects (Within) ---
cat("--- 2.2 Model Fixed Effects (Within) ---\n")
cat("Controlează pentru efecte fixe individuale (specifice fiecărei țări).\n")
cat("Ecuația: Y_it - Ȳ_i = β(X_it - X̄_i) + (ε_it - ε̄_i)\n\n")
model_fe <- plm(formula_panel, data = pdata, model = "within")
summary_fe <- summary(model_fe)
print(summary_fe)

cat("\nR² within:", round(summary_fe$r.squared["rsq"], 4), "\n")
cat("R² ajustat:", round(summary_fe$r.squared["adjrsq"], 4), "\n\n")

# Efecte fixe individuale (primele 10 țări)
fe_effects <- fixef(model_fe)
cat("Efecte fixe individuale (primele 10 țări):\n")
print(head(sort(fe_effects, decreasing = TRUE), 10))
cat("\n")

# --- Model C: Random Effects ---
cat("--- 2.3 Model Random Effects ---\n")
cat("Tratează efectele individuale ca variabile aleatoare: u_i ~ N(0, σ²_u)\n\n")
model_re <- plm(formula_panel, data = pdata, model = "random")
summary_re <- summary(model_re)
print(summary_re)
cat("\n")

# --- Model D: Fixed Effects cu Time Effects ---
cat("--- 2.4 Model Fixed Effects cu Efecte de Timp ---\n")
cat("Two-way FE: controlelază atât pentru efecte țară cât și pentru efecte an.\n\n")
model_fe_time <- plm(formula_panel, data = pdata, model = "within", effect = "twoways")
summary_fe_time <- summary(model_fe_time)
print(summary_fe_time)
cat("\n")

# ==============================================================================
# 3. TESTE PENTRU SELECTAREA MODELULUI
# ==============================================================================

cat("=================================================================\n")
cat("           3. TESTE PENTRU SELECTAREA MODELULUI                  \n")
cat("=================================================================\n\n")

# --- Test Hausman (FE vs RE) ---
cat("--- 3.1 Testul Hausman (FE vs RE) ---\n")
cat("H₀: Efectele aleatorii sunt consistente și eficiente (preferăm RE)\n")
cat("H₁: Efectele aleatorii sunt inconsistente (preferăm FE)\n\n")

hausman_test <- phtest(model_fe, model_re)
print(hausman_test)

cat("\nDecizie: ")
if (hausman_test$p.value < 0.05) {
  cat("p =", round(hausman_test$p.value, 6), "< 0.05 → RESPINGEM H₀\n")
  cat("Selectăm modelul FIXED EFFECTS.\n")
  cat("Interpretare: Efectele individuale sunt CORELATE cu regresorii.\n")
  model_final <- model_fe
  model_type <- "Fixed Effects"
} else {
  cat("p =", round(hausman_test$p.value, 6), "> 0.05 → NU RESPINGEM H₀\n")
  cat("Selectăm modelul RANDOM EFFECTS.\n")
  model_final <- model_re
  model_type <- "Random Effects"
}
cat("\n")

# --- Test F pentru efecte individuale ---
cat("--- 3.2 Test F pentru efecte fixe individuale ---\n")
cat("H₀: Toate efectele individuale sunt egale (αᵢ = α pentru toate i)\n")
cat("H₁: Efectele individuale diferă între țări\n\n")

pFtest_result <- pFtest(model_fe, model_pool)
print(pFtest_result)
cat("Verdict:", ifelse(pFtest_result$p.value < 0.05, 
                       "Efectele fixe sunt semnificative - preferăm FE față de Pooled OLS",
                       "Efectele fixe nu sunt semnificative"), "\n\n")

# --- Test Breusch-Pagan LM pentru efecte aleatorii ---
cat("--- 3.3 Test Breusch-Pagan LM pentru efecte aleatorii ---\n")
cat("H₀: Varianța efectelor individuale = 0 (σ²_u = 0)\n")
cat("H₁: Varianța efectelor individuale > 0\n\n")

plm_lm_test <- plmtest(model_pool, type = "bp")
print(plm_lm_test)
cat("Verdict:", ifelse(plm_lm_test$p.value < 0.05,
                       "Efecte aleatorii semnificative - RE preferat față de Pooled",
                       "Nu avem suficiente dovezi pentru RE"), "\n\n")

# --- Test pentru Efecte de Timp ---
cat("--- 3.4 Test pentru Efecte de Timp ---\n")
cat("H₀: Efectele de timp nu sunt semnificative\n\n")

time_test <- pFtest(model_fe_time, model_fe)
print(time_test)
cat("Verdict:", ifelse(time_test$p.value < 0.05,
                       "Efectele de timp sunt semnificative - consideră two-way FE",
                       "Efectele de timp NU sunt semnificative - one-way FE suficient"), "\n\n")

# ==============================================================================
# 4. DIAGNOSTICE SPECIFICE PANEL
# ==============================================================================

cat("=================================================================\n")
cat("           4. DIAGNOSTICE SPECIFICE PANEL                        \n")
cat("=================================================================\n\n")

# --- 4.1 Test Pesaran CD (Dependență cross-secțională) ---
cat("--- 4.1 Test Pesaran CD (Dependență Cross-Secțională) ---\n")
cat("H₀: Nu există dependență între entități (rezidurile sunt independente cross-secțional)\n")
cat("H₁: Există dependență cross-secțională (șocuri comune afectează toate țările)\n\n")

cd_test <- pcdtest(model_final, test = "cd")
print(cd_test)
cat("\nInterpretare:\n")
if (cd_test$p.value < 0.05) {
  cat("RESPINGEM H₀: Există DEPENDENȚĂ cross-secțională.\n")
  cat("Implicație: Șocuri comune afectează simultan mai multe țări.\n")
  cat("Soluție: Utilizați erori standard robuste cluster (Driscoll-Kraay).\n")
} else {
  cat("NU RESPINGEM H₀: Nu avem dovezi de dependență cross-secțională.\n")
}
cat("\n")

# --- 4.2 Test Breusch-Godfrey pentru Autocorelare Serial ---
cat("--- 4.2 Test Breusch-Godfrey (Autocorelare serială în panel) ---\n")
cat("H₀: Nu există corelație serială în erori\n")
cat("H₁: Există corelație serială de ordinul specificat\n\n")

bg_panel <- pbgtest(model_final)
print(bg_panel)
cat("Verdict:", ifelse(bg_panel$p.value < 0.05,
                       "AUTOCORELARE SERIALĂ detectată!",
                       "Nu avem autocorelare serială"), "\n\n")

# --- 4.3 Test Wooldridge pentru Autocorelare ---
cat("--- 4.3 Test Wooldridge pentru Autocorelare în Panel ---\n")
cat("H₀: Nu există autocorelare de ordinul 1\n\n")

wooldridge_test <- tryCatch({
  pwartest(model_final)
}, error = function(e) {
  cat("Wooldridge test nu poate fi calculat:", e$message, "\n")
  NULL
})

if (!is.null(wooldridge_test)) {
  print(wooldridge_test)
  cat("Verdict:", ifelse(wooldridge_test$p.value < 0.05,
                         "AUTOCORELARE AR(1) detectată!",
                         "Nu avem dovezi de autocorelare AR(1)"), "\n")
}
cat("\n")

# --- 4.4 Test Heteroscedasticitate Panel ---
cat("--- 4.4 Test Breusch-Pagan pentru Heteroscedasticitate în Panel ---\n")
cat("H₀: Varianța erorilor este constantă între entități\n\n")

# BP test pe modelul panel
bp_panel <- bptest(formula_panel, data = df_panel_final, studentize = FALSE)
print(bp_panel)
cat("Verdict:", ifelse(bp_panel$p.value < 0.05,
                       "HETEROSCEDASTICITATE detectată!",
                       "Varianța este omogenă"), "\n\n")

# --- 4.5 Test pentru Heteroscedasticitate Grupată ---
cat("--- 4.5 Test pentru Heteroscedasticitate Grupată (entre țări) ---\n")

# White test modificat pentru panel
bp_grouped <- bptest(lm(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate + factor(Tara), 
                        data = df_panel_final), studentize = FALSE)
print(bp_grouped)
cat("Verdict:", ifelse(bp_grouped$p.value < 0.05,
                       "HETEROSCEDASTICITATE GRUPATĂ detectată!",
                       "Varianța este omogenă între grupuri"), "\n\n")

# ==============================================================================
# 5. REZUMAT DIAGNOSTICE ȘI ERORI ROBUSTE
# ==============================================================================

cat("=================================================================\n")
cat("           5. REZUMAT DIAGNOSTICE & CORECȚII                     \n")
cat("=================================================================\n\n")

diagnostics_summary <- data.frame(
  Test = c("Hausman (FE vs RE)", "F-test efecte fixe", "BP LM efecte aleatorii",
           "F-test efecte timp", "Pesaran CD", "Breusch-Godfrey serial",
           "BP Heteroscedasticitate"),
  Statistica = c(hausman_test$statistic, pFtest_result$statistic, plm_lm_test$statistic,
                 time_test$statistic, cd_test$statistic, bg_panel$statistic,
                 bp_panel$statistic),
  DF = c(hausman_test$parameter, NA, NA, NA, NA, bg_panel$parameter, bp_panel$parameter),
  P_Value = c(hausman_test$p.value, pFtest_result$p.value, plm_lm_test$p.value,
              time_test$p.value, cd_test$p.value, bg_panel$p.value, bp_panel$p.value),
  Verdict = c(ifelse(hausman_test$p.value < 0.05, "FE Preferat", "RE Preferat"),
              ifelse(pFtest_result$p.value < 0.05, "FE > Pooled", "Pooled OK"),
              ifelse(plm_lm_test$p.value < 0.05, "RE > Pooled", "Pooled OK"),
              ifelse(time_test$p.value < 0.05, "Two-way", "One-way OK"),
              ifelse(cd_test$p.value < 0.05, "CD Prezentă!", "OK"),
              ifelse(bg_panel$p.value < 0.05, "Autocorelare!", "OK"),
              ifelse(bp_panel$p.value < 0.05, "Heteroscedastic!", "OK"))
)
print(diagnostics_summary)
write_xlsx(diagnostics_summary, "Output/Rapoarte/Diagnostice_Panel.xlsx")

# --- Erori Standard Robuste ---
cat("\n--- 5.1 Model Final cu Erori Robuste HC ---\n")
cat("Aplicăm erori standard robuste pentru a corecta heteroscedasticitatea și dependența.\n\n")

robust_se <- coeftest(model_final, vcov = vcovHC(model_final, type = "HC1", cluster = "group"))
print(robust_se)

cat("\nComparație SE Standard vs Robust:\n")
se_comparison <- data.frame(
  Variabila = rownames(summary(model_final)$coefficients),
  Coef = coef(model_final),
  SE_Standard = summary(model_final)$coefficients[, 2],
  SE_Robust = robust_se[, 2],
  P_Standard = summary(model_final)$coefficients[, 4],
  P_Robust = robust_se[, 4]
)
print(se_comparison)
write_xlsx(se_comparison, "Output/Rapoarte/Comparatie_SE_Robust.xlsx")

# ==============================================================================
# 6. INTERPRETARE ECONOMICĂ ȘI CONCLUZII
# ==============================================================================

cat("\n=================================================================\n")
cat("           6. INTERPRETARE ECONOMICĂ & CONCLUZII                 \n")
cat("=================================================================\n\n")

cat("MODELUL FINAL SELECTAT:", model_type, "\n\n")

cat("Coeficienți estimați:\n")
print(coef(model_final))

cat("\n--- Interpretare coeficienți (elasticități) ---\n")
coefs <- coef(model_final)
for (i in 1:length(coefs)) {
  var_name <- names(coefs)[i]
  var_coef <- round(coefs[i], 4)
  cat("-", var_name, ":", var_coef, "\n")
  cat("  Interpretare: O creștere cu 1% în", gsub("ln_", "", var_name), 
      "este asociată cu o modificare de", var_coef, "% în furturi.\n\n")
}

cat("--- Recomandări finale ---\n")
cat("1. Model recomandat:", model_type, "(conform Hausman)\n")
cat("2. Utilizați erori robuste cluster pentru inferență datorită heteroscedasticității\n")
if (cd_test$p.value < 0.05) {
  cat("3. Considerați modele cu factori comuni (Driscoll-Kraay SE) pentru dependența CD\n")
}
if (bg_panel$p.value < 0.05) {
  cat("4. Considerați modele dinamice (GMM) pentru corecția autocorelării\n")
}

# Salvare model final - versiune robustă
res_df <- tryCatch({
  df <- as.data.frame(robust_se)
  df$Variabila <- rownames(df)
  # Mutăm Variabila pe prima poziție
  df <- df[, c(ncol(df), 1:(ncol(df)-1))]
  df
}, error = function(e) {
  # Fallback: salvăm coeficienții simpli
  data.frame(
    Variabila = names(coef(model_final)),
    Coeficient = coef(model_final)
  )
})

write_xlsx(res_df, "Output/Rapoarte/Model_Panel_Final.xlsx")
cat("Model Panel salvat cu succes!\n")

cat("\n=================================================================\n")
cat("                    ANALIZĂ PANEL FINALIZATĂ                     \n")
cat("=================================================================\n")

sink()

cat("\n✅ Toate rezultatele au fost salvate în Output/Rapoarte/\n")
cat("   - rezultate_panel_complet.txt\n")
cat("   - Diagnostice_Panel.xlsx\n")
cat("   - Comparatie_SE_Robust.xlsx\n")
cat("   - Model_Panel_Final.xlsx\n")
