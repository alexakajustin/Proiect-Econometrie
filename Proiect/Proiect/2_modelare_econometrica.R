
# ==============================================================================
# PROIECT ECONOMETRIE: APLICAȚIA 1 - ANALIZĂ COMPLETĂ
# ==============================================================================
# Etapa 1: Regresii + Diagnostice complete
# Etapa 2: Selecție variabile + Regularizare (Boruta, Ridge, LASSO, Elastic Net)
# Etapa 4: Prognoză cu interval de încredere
# ==============================================================================

if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  readxl, tidyverse, writexl, broom,         # Data handling
  car, lmtest, sandwich, tseries,            # Diagnostics
  caret, glmnet, Metrics,                    # ML & metrics
  Boruta, strucchange,                       # Variable selection & Chow test
  nortest, moments                           # Normality tests
)

setwd("C:/Users/Jastin/Desktop/Econometrie/Proiect-Econometrie/Proiect/Proiect")

# Sink Output
sink("Output/Rapoarte/rezultate_complet.txt", split = TRUE)

cat("=================================================================\n")
cat("     PROIECT ECONOMETRIE - ANALIZĂ COMPLETĂ (4 ETAPE)           \n")
cat("=================================================================\n\n")

# ==============================================================================
# 0. ÎNCĂRCARE DATE
# ==============================================================================
df_final <- read_excel("Output/Date/Date_Proiect_Final_2023.xlsx")
train_data <- read_excel("Output/Date/Date_Antrenare.xlsx")
test_data <- read_excel("Output/Date/Date_Testare.xlsx")

cat("Date încărcate:\n")
cat("- Total observații:", nrow(df_final), "\n")
cat("- Train set:", nrow(train_data), "\n")
cat("- Test set:", nrow(test_data), "\n\n")

# ==============================================================================
# ETAPA 1: ANALIZA REGRESIILOR
# ==============================================================================

cat("=================================================================\n")
cat("                    ETAPA 1: ANALIZA REGRESIILOR                 \n")
cat("=================================================================\n\n")

# -----------------------------------------------------------------------------
# 1.1 REGRESIE LINIARĂ SIMPLĂ (Furturi ~ Șomeri)
# -----------------------------------------------------------------------------
cat("--- 1.1 REGRESIE LINIARĂ SIMPLĂ ---\n")
cat("Model: ln(Furturi) = β₀ + β₁ × ln(Șomeri) + ε\n\n")

model_simplu <- lm(ln_Furturi ~ ln_Someri, data = train_data)
summary_simplu <- summary(model_simplu)
print(summary_simplu)

cat("\nInterpretare: β₁ =", coef(model_simplu)[2], "\n")
cat("O creștere cu 1% a șomerilor este asociată cu o creștere de",
    round(coef(model_simplu)[2], 3), "% a furturilor.\n\n")

# -----------------------------------------------------------------------------
# 1.2 REGRESIE LINIARĂ MULTIPLĂ (5 variabile)
# -----------------------------------------------------------------------------
cat("--- 1.2 REGRESIE LINIARĂ MULTIPLĂ ---\n")
cat("Model: ln(Y) = β₀ + β₁ln(PIB) + β₂ln(Șom) + β₃ln(Imig) + β₄ln(Dens) + β₅Est + ε\n\n")

model_multi <- lm(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate + Est_Vest, 
                  data = train_data)
summary_multi <- summary(model_multi)
print(summary_multi)

# -----------------------------------------------------------------------------
# 1.3 MODEL DE INTERACȚIUNE
# -----------------------------------------------------------------------------
cat("\n--- 1.3 MODEL DE INTERACȚIUNE ---\n")
cat("Adăugăm termeni de interacțiune între Est_Vest și alte variabile:\n\n")

model_interact <- lm(ln_Furturi ~ ln_PIB * Est_Vest + ln_Someri * Est_Vest + 
                       ln_Imigratie + ln_Densitate, data = train_data)
summary_interact <- summary(model_interact)
print(summary_interact)

cat("\nInterpretare interacțiuni:\n")
cat("- ln_PIB:Est_Vest = efectul diferit al PIB în Est vs Vest\n")
cat("- ln_Someri:Est_Vest = efectul diferit al șomajului în Est vs Vest\n\n")

# ==============================================================================
# 1.4 DIAGNOSTICE COMPLETE
# ==============================================================================

cat("=================================================================\n")
cat("                    DIAGNOSTICE COMPLETE                         \n")
cat("=================================================================\n\n")

# --- VIF (Multicoliniaritate) ---
cat("--- 1.4.1 VIF (Variance Inflation Factor) ---\n")
vif_vals <- vif(model_multi)
print(vif_vals)
cat("Interpretare: VIF > 5 indică multicoliniaritate. VIF > 10 = severă.\n")
cat("Verdict:", ifelse(max(vif_vals) < 5, "OK - fără multicoliniaritate", 
                       "ATENȚIE - multicoliniaritate detectată"), "\n\n")

# --- Test Breusch-Pagan (Heteroscedasticitate) ---
cat("--- 1.4.2 Test Breusch-Pagan (Heteroscedasticitate) ---\n")
bp_test <- bptest(model_multi)
print(bp_test)
cat("H₀: Varianța erorilor este constantă (homoscedasticitate)\n")
cat("Verdict:", ifelse(bp_test$p.value > 0.05, "OK - homoscedasticitate", 
                       "RESPINS - heteroscedasticitate detectată"), "\n\n")

# --- Test White (Heteroscedasticitate) ---
cat("--- 1.4.3 Test White (Heteroscedasticitate) ---\n")
# White test = BP test pe model cu pătrați și interacțiuni
white_model <- lm(resid(model_multi)^2 ~ fitted(model_multi) + I(fitted(model_multi)^2))
white_test <- summary(white_model)
white_stat <- nrow(train_data) * white_test$r.squared
white_pval <- 1 - pchisq(white_stat, df = 2)
cat("Statistica White:", round(white_stat, 4), "\n")
cat("p-value:", round(white_pval, 6), "\n")
cat("Verdict:", ifelse(white_pval > 0.05, "OK - homoscedasticitate", 
                       "RESPINS - heteroscedasticitate detectată"), "\n\n")

# --- Test Durbin-Watson (Autocorelare ordine 1) ---
cat("--- 1.4.4 Test Durbin-Watson (Autocorelare ordine 1) ---\n")
dw_test <- dwtest(model_multi)
print(dw_test)
cat("Interpretare: DW ≈ 2 = fără autocorelare\n")
cat("DW < 2 = autocorelare pozitivă, DW > 2 = autocorelare negativă\n")
cat("Verdict:", ifelse(dw_test$p.value > 0.05, "OK - fără autocorelare", 
                       "RESPINS - autocorelare detectată"), "\n\n")

# --- Test Breusch-Godfrey (Autocorelare ordine superioară) ---
cat("--- 1.4.5 Test Breusch-Godfrey (Autocorelare ordine 1, 2, 3) ---\n")
for (ord in 1:3) {
  bg_test <- bgtest(model_multi, order = ord)
  cat("Ordine", ord, ": LM =", round(bg_test$statistic, 4), 
      ", p-value =", round(bg_test$p.value, 6),
      ", Verdict:", ifelse(bg_test$p.value > 0.05, "OK", "AUTOCORELARE"), "\n")
}
cat("\n")

# --- Test Jarque-Bera (Normalitate) ---
cat("--- 1.4.6 Test Jarque-Bera (Normalitate reziduuri) ---\n")
jb_test <- jarque.bera.test(resid(model_multi))
print(jb_test)
cat("H₀: Reziduurile urmează o distribuție normală\n")
cat("Verdict:", ifelse(jb_test$p.value > 0.05, "OK - normalitate", 
                       "RESPINS - non-normalitate"), "\n\n")

# --- Teste suplimentare normalitate ---
cat("--- 1.4.7 Teste suplimentare normalitate ---\n")
shapiro <- shapiro.test(resid(model_multi))
cat("Shapiro-Wilk: W =", round(shapiro$statistic, 4), ", p-value =", 
    round(shapiro$p.value, 6), "\n")

# --- Skewness și Kurtosis ---
skew <- skewness(resid(model_multi))
kurt <- kurtosis(resid(model_multi))
cat("Skewness:", round(skew, 4), "(0 = simetric)\n")
cat("Kurtosis:", round(kurt, 4), "(3 = normal)\n\n")

# --- Distanța Cook (Outlieri) ---
cat("--- 1.4.8 Distanța Cook (Detectare Outlieri) ---\n")
cook_d <- cooks.distance(model_multi)
threshold <- 4 / nrow(train_data)
outliers <- which(cook_d > threshold)
cat("Prag Cook's D:", round(threshold, 4), "\n")
cat("Număr outlieri detectați:", length(outliers), "\n")
if (length(outliers) > 0) {
  cat("Observații cu influență mare:", paste(outliers, collapse = ", "), "\n")
  cat("Țări potențial outlier:", paste(train_data$Tara[outliers], collapse = ", "), "\n")
}
cat("\n")

# Salvare diagnostice
df_diagnostics <- data.frame(
  Test = c("VIF (max)", "Breusch-Pagan", "White", "Durbin-Watson", 
           "Breusch-Godfrey (1)", "Jarque-Bera", "Shapiro-Wilk"),
  Statistica = c(max(vif_vals), bp_test$statistic, white_stat, dw_test$statistic,
                 bgtest(model_multi, 1)$statistic, jb_test$statistic, shapiro$statistic),
  P_Value = c(NA, bp_test$p.value, white_pval, dw_test$p.value,
              bgtest(model_multi, 1)$p.value, jb_test$p.value, shapiro$p.value),
  Verdict = c(ifelse(max(vif_vals) < 5, "OK", "MULTICOLINIARITATE"),
              ifelse(bp_test$p.value > 0.05, "OK", "HETEROSCEDASTICITATE"),
              ifelse(white_pval > 0.05, "OK", "HETEROSCEDASTICITATE"),
              ifelse(dw_test$p.value > 0.05, "OK", "AUTOCORELARE"),
              ifelse(bgtest(model_multi, 1)$p.value > 0.05, "OK", "AUTOCORELARE"),
              ifelse(jb_test$p.value > 0.05, "OK", "NON-NORMALITATE"),
              ifelse(shapiro$p.value > 0.05, "OK", "NON-NORMALITATE"))
)
write_xlsx(df_diagnostics, "Output/Rapoarte/Diagnostice_Complete.xlsx")

# --- Chow Test (Stabilitate structurală) ---
cat("--- 1.4.9 Chow Test (Stabilitate structurală Est vs Vest) ---\n")

# Separate models for East and West
train_est <- train_data %>% filter(Est_Vest == 1)
train_vest <- train_data %>% filter(Est_Vest == 0)

if (nrow(train_est) >= 5 & nrow(train_vest) >= 5) {
  model_est <- lm(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate, data = train_est)
  model_vest <- lm(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate, data = train_vest)
  model_combined <- lm(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate, data = train_data)
  
  # Chow statistic
  RSS_combined <- sum(resid(model_combined)^2)
  RSS_est <- sum(resid(model_est)^2)
  RSS_vest <- sum(resid(model_vest)^2)
  
  k <- 5  # număr de parametri
  n <- nrow(train_data)
  n1 <- nrow(train_est)
  n2 <- nrow(train_vest)
  
  chow_stat <- ((RSS_combined - (RSS_est + RSS_vest)) / k) / ((RSS_est + RSS_vest) / (n - 2*k))
  chow_pval <- 1 - pf(chow_stat, k, n - 2*k)
  
  cat("F-statistic Chow:", round(chow_stat, 4), "\n")
  cat("p-value:", round(chow_pval, 6), "\n")
  cat("H₀: Coeficienții sunt stabili între Est și Vest\n")
  cat("Verdict:", ifelse(chow_pval > 0.05, "OK - stabilitate structurală", 
                         "RESPINS - diferențe structurale Est vs Vest"), "\n\n")
} else {
  cat("Nu suficiente date pentru Chow test pe subgrupuri Est/Vest\n\n")
}

# ==============================================================================
# ETAPA 2: SELECȚIA VARIABILELOR ȘI REGULARIZARE
# ==============================================================================

cat("=================================================================\n")
cat("          ETAPA 2: SELECȚIE VARIABILE & REGULARIZARE             \n")
cat("=================================================================\n\n")

# --- Algoritmul Boruta ---
cat("--- 2.1 Algoritmul Boruta (Selecție variabile) ---\n")

# Prepare data for Boruta
boruta_data <- train_data %>% 
  select(ln_Furturi, ln_PIB, ln_Someri, ln_Imigratie, ln_Densitate, Est_Vest) %>%
  drop_na()

set.seed(42)
boruta_result <- tryCatch({
  Boruta(ln_Furturi ~ ., data = boruta_data, doTrace = 0, maxRuns = 100)
}, error = function(e) {
  cat("Boruta error:", e$message, "\n")
  NULL
})

if (!is.null(boruta_result)) {
  print(boruta_result)
  boruta_final <- TentativeRoughFix(boruta_result)
  cat("\nVariabile confirmate ca semnificative:\n")
  print(getSelectedAttributes(boruta_final, withTentative = FALSE))
}
cat("\n")

# --- Pregătire Matrice pentru glmnet ---
cat("--- 2.2 Pregătire date pentru regularizare ---\n")
x_train <- model.matrix(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate + Est_Vest, 
                        data = train_data)[,-1]
y_train <- train_data$ln_Furturi

x_test <- model.matrix(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate + Est_Vest, 
                       data = test_data)[,-1]
y_test <- test_data$ln_Furturi

cat("Dimensiuni: Train X =", dim(x_train)[1], "x", dim(x_train)[2], "\n")
cat("            Test X =", dim(x_test)[1], "x", dim(x_test)[2], "\n\n")

# --- Ridge Regression (alpha = 0) ---
cat("--- 2.3 Ridge Regression (α = 0) ---\n")
cv_ridge <- cv.glmnet(x_train, y_train, alpha = 0, nfolds = 5)
lambda_ridge <- cv_ridge$lambda.min
cat("Lambda optim (CV):", round(lambda_ridge, 6), "\n")

model_ridge <- glmnet(x_train, y_train, alpha = 0, lambda = lambda_ridge)
cat("Coeficienți Ridge:\n")
print(coef(model_ridge))

pred_ridge <- predict(model_ridge, newx = x_test)
rmse_ridge <- rmse(y_test, pred_ridge)
mae_ridge <- mae(y_test, pred_ridge)
r2_ridge <- 1 - sum((y_test - pred_ridge)^2) / sum((y_test - mean(y_test))^2)
cat("\nPerformanță Test: RMSE =", round(rmse_ridge, 4), 
    ", MAE =", round(mae_ridge, 4), ", R² =", round(r2_ridge, 4), "\n\n")

# --- LASSO Regression (alpha = 1) ---
cat("--- 2.4 LASSO Regression (α = 1) ---\n")
cv_lasso <- cv.glmnet(x_train, y_train, alpha = 1, nfolds = 5)
lambda_lasso <- cv_lasso$lambda.min
cat("Lambda optim (CV):", round(lambda_lasso, 6), "\n")

model_lasso <- glmnet(x_train, y_train, alpha = 1, lambda = lambda_lasso)
cat("Coeficienți LASSO:\n")
print(coef(model_lasso))
cat("Variabile eliminate (coef = 0):", 
    sum(coef(model_lasso)[-1] == 0), "din", length(coef(model_lasso)[-1]), "\n")

pred_lasso <- predict(model_lasso, newx = x_test)
rmse_lasso <- rmse(y_test, pred_lasso)
mae_lasso <- mae(y_test, pred_lasso)
r2_lasso <- 1 - sum((y_test - pred_lasso)^2) / sum((y_test - mean(y_test))^2)
cat("\nPerformanță Test: RMSE =", round(rmse_lasso, 4), 
    ", MAE =", round(mae_lasso, 4), ", R² =", round(r2_lasso, 4), "\n\n")

# --- Elastic Net (alpha = 0.5) ---
cat("--- 2.5 Elastic Net (α = 0.5) ---\n")
cv_enet <- cv.glmnet(x_train, y_train, alpha = 0.5, nfolds = 5)
lambda_enet <- cv_enet$lambda.min
cat("Lambda optim (CV):", round(lambda_enet, 6), "\n")

model_enet <- glmnet(x_train, y_train, alpha = 0.5, lambda = lambda_enet)
cat("Coeficienți Elastic Net:\n")
print(coef(model_enet))

pred_enet <- predict(model_enet, newx = x_test)
rmse_enet <- rmse(y_test, pred_enet)
mae_enet <- mae(y_test, pred_enet)
r2_enet <- 1 - sum((y_test - pred_enet)^2) / sum((y_test - mean(y_test))^2)
cat("\nPerformanță Test: RMSE =", round(rmse_enet, 4), 
    ", MAE =", round(mae_enet, 4), ", R² =", round(r2_enet, 4), "\n\n")

# --- OLS Stepwise pentru comparație ---
cat("--- 2.6 OLS Stepwise (Baseline) ---\n")
model_step <- step(model_multi, direction = "both", trace = 0)
pred_ols <- predict(model_step, newdata = test_data)
rmse_ols <- rmse(y_test, pred_ols)
mae_ols <- mae(y_test, pred_ols)
r2_ols <- 1 - sum((y_test - pred_ols)^2) / sum((y_test - mean(y_test))^2)
cat("Performanță Test: RMSE =", round(rmse_ols, 4), 
    ", MAE =", round(mae_ols, 4), ", R² =", round(r2_ols, 4), "\n\n")

# --- Tabel Comparativ ---
cat("--- 2.7 COMPARAȚIE MODELE ---\n")
comparison_df <- data.frame(
  Model = c("OLS Stepwise", "Ridge (α=0)", "LASSO (α=1)", "Elastic Net (α=0.5)"),
  Lambda = c(NA, lambda_ridge, lambda_lasso, lambda_enet),
  RMSE = c(rmse_ols, rmse_ridge, rmse_lasso, rmse_enet),
  MAE = c(mae_ols, mae_ridge, mae_lasso, mae_enet),
  R2_Test = c(r2_ols, r2_ridge, r2_lasso, r2_enet)
)
print(comparison_df)

best_model <- comparison_df$Model[which.min(comparison_df$RMSE)]
cat("\n🏆 MODELUL OPTIM (minim RMSE):", best_model, "\n\n")

write_xlsx(comparison_df, "Output/Rapoarte/Comparatie_Modele_ML.xlsx")

# ==============================================================================
# ETAPA 4: PROGNOZĂ CU INTERVAL DE ÎNCREDERE
# ==============================================================================

cat("=================================================================\n")
cat("          ETAPA 4: PROGNOZĂ CU INTERVAL DE ÎNCREDERE             \n")
cat("=================================================================\n\n")

# --- Predicții pe Test Set ---
cat("--- 4.1 Predicții Out-of-Sample ---\n")

# Predicții cu model OLS (cel mai bun pentru RMSE)
pred_ci <- predict(model_step, newdata = test_data, interval = "confidence", level = 0.90)
pred_pi <- predict(model_step, newdata = test_data, interval = "prediction", level = 0.90)

# Verificăm numele coloanei pentru țară (poate fi Tara sau Country)
country_col <- if("Tara" %in% names(test_data)) test_data$Tara else if("Country" %in% names(test_data)) test_data$Country else rownames(test_data)

forecast_df <- data.frame(
  Tara = country_col,
  Actual_ln = y_test,
  Predicted_ln = pred_ci[, "fit"],
  CI_Lower_90 = pred_ci[, "lwr"],
  CI_Upper_90 = pred_ci[, "upr"],
  PI_Lower_90 = pred_pi[, "lwr"],
  PI_Upper_90 = pred_pi[, "upr"],
  Actual = exp(y_test),
  Predicted = exp(pred_ci[, "fit"]),
  Error_Pct = round((exp(pred_ci[, "fit"]) - exp(y_test)) / exp(y_test) * 100, 2)
)

print(forecast_df)

cat("\n--- 4.2 Metrici de Prognoză ---\n")
cat("RMSE:", round(rmse_ols, 4), "\n")
cat("MAE:", round(mae_ols, 4), "\n")
mape <- mean(abs(forecast_df$Error_Pct))
cat("MAPE:", round(mape, 2), "%\n")
cat("R² (out-of-sample):", round(r2_ols, 4), "\n\n")

# Salvare prognoze
write_xlsx(forecast_df, "Output/Rapoarte/Prognoza_TestSet.xlsx")

cat("=================================================================\n")
cat("                    ANALIZĂ FINALIZATĂ                           \n")
cat("=================================================================\n")

sink()

cat("\n✅ Toate rezultatele au fost salvate în Output/Rapoarte/\n")
cat("   - rezultate_complet.txt\n")
cat("   - Diagnostice_Complete.xlsx\n")
cat("   - Comparatie_Modele_ML.xlsx\n")
cat("   - Prognoza_TestSet.xlsx\n")
