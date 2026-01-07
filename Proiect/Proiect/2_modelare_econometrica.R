# ==============================================================================
# PROIECT ECONOMETRIE: APLICAȚIA 2 - MODELARE ECONOMETRICĂ CLASICĂ
# ==============================================================================

# 1. Încărcarea Bibliotecilor Necesare
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  readxl,       # Citire Excel
  tidyverse,    # Manipulare date și grafice
  car,          # Teste ipoteze liniare, VIF, Durbin-Watson
  lmtest,       # Teste de diagnosticare (Breusch-Pagan, etc.)
  tseries,      # Teste stat. (Jarque-Bera etc.)
  broom,        # Tidy output pentru modele
  writexl,      # Salvare Excel
  moments,      # Pentru Jarque-Bera
  glmnet        # Pentru Lasso si Ridge (Regularizare)
)

# Setare director de lucru (pentru siguranță)
setwd("C:/Users/Jastin/Desktop/Econometrie/Proiect-Econometrie/Proiect/Proiect")

# PORNIRE LOGGING
sink("Output/Rapoarte/rezultate_regresie.txt", split = TRUE)

# ==============================================================================
# 2. Încărcare Date
# ==============================================================================
df_path <- "Output/Date/Date_Proiect_Final_2023.xlsx"
if (!file.exists(df_path)) {
  stop("Fișierul de date nu există! Rulați întâi scriptul 1_analiza_exploratorie.R")
}

df_final <- read_excel(df_path)
print("Date încărcate cu succes.")
print(paste("Număr observații:", nrow(df_final)))

# ==============================================================================
# 3. Model 1: Regresie Liniară Simplă (Validare H1)
# ==============================================================================
# H1: Șomajul influențează pozitiv furturile.
# Model: ln_Furturi = b0 + b1 * ln_Someri + u

print("==============================================================================")
print("3. MODEL 1: REGRESIE LINIARĂ SIMPLĂ (ln_Furturi ~ ln_Someri)")
print("==============================================================================")

model_simple <- lm(ln_Furturi ~ ln_Someri, data = df_final)
summary_simple <- summary(model_simple)
print(summary_simple)

# Interpretare coeficient
coef_someri <- coef(model_simple)["ln_Someri"]
print(paste("Elasticitate estimată (b1):", round(coef_someri, 4)))
if (coef_someri > 0 && summary_simple$coefficients["ln_Someri", "Pr(>|t|)"] < 0.05) {
  print("CONCLUZIE H1: Ipoteza se validează. Relație pozitivă și semnificativă.")
} else {
  print("CONCLUZIE H1: Ipoteza NU se validează statistic.")
}

# Salvare Rezultate Model Simplu în Excel pentru Word
tidy_simple <- tidy(model_simple)
glance_simple <- glance(model_simple)
write_xlsx(list(Coeficienti = tidy_simple, Sumar = glance_simple), "Output/Rapoarte/Rezultate_Regresie_Simplu.xlsx")


# Grafic Regresie Simplă cu benzi de încredere
p_simple <- ggplot(df_final, aes(x = ln_Someri, y = ln_Furturi)) +
  geom_point(color = "blue", size = 3, alpha = 0.7) +
  geom_smooth(method = "lm", color = "red", fill = "pink", alpha = 0.3) +
  geom_text(aes(label = Tara), vjust = 1.5, size = 3) +
  labs(title = "Regresie Simplă: Elasticitatea Furturi - Șomaj",
       subtitle = paste("R-squared =", round(summary_simple$r.squared, 3)),
       x = "Log(Nr. Șomeri)", y = "Log(Furturi)") +
  theme_minimal()

ggsave("Output/Grafice/Regresie_Simpla.png", plot = p_simple)


# ==============================================================================
# 4. Model 2: Regresie Liniară Multiplă (Modelul Complet)
# ==============================================================================
# Model: ln_Furturi = b0 + b1*ln_PIB + b2*ln_Someri + b3*ln_Imigratie + b4*ln_Politie + b5*Membru_UE + u
# Notă: Excludem Densitatea momentan pentru a nu supraîncărca modelul la puține grade de libertate, sau o includem?
# Userul a cerut "toate variabilele". Le includem pe toate disponibile logaritmate.

print("==============================================================================")
print("4. MODEL 2: REGRESIE MULTIPLĂ (Toate Variabilele)")
print("==============================================================================")

model_multi <- lm(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Politie + ln_Densitate + Membru_UE, data = df_final)
summary_multi <- summary(model_multi)
print(summary_multi)

# Test F Global
f_stat <- summary_multi$fstatistic
p_val_f <- pf(f_stat[1], f_stat[2], f_stat[3], lower.tail = FALSE)
print(paste("Testul F (p-value):", format.pval(p_val_f)))

# Salvare Rezultate Model Multiplu în Excel pentru Word
tidy_multi <- tidy(model_multi)
glance_multi <- glance(model_multi)
write_xlsx(list(Coeficienti = tidy_multi, Sumar = glance_multi), "Output/Rapoarte/Rezultate_Regresie_Multipla.xlsx")

# Salvare VIF în Excel
vif_vals <- vif(model_multi)
df_vif <- data.frame(Variabila = names(vif_vals), VIF = vif_vals)
write_xlsx(df_vif, "Output/Rapoarte/Rezultate_VIF.xlsx")


# ==============================================================================
# 5. Diagnosticare Modele (Verificarea Ipotezelor Gauss-Markov)
# ==============================================================================
print("==============================================================================")
print("5. DIAGNOSTICARE MODEL MULTIPLU")
print("==============================================================================")

# 5.1. Multicoliniaritate (VIF)
print("--- Test Multicoliniaritate (VIF) ---")
vif_vals <- vif(model_multi)
print(vif_vals)
if (any(vif_vals > 10)) {
  print("ALERTA: Există multicoliniaritate severă (VIF > 10). Coeficienții pot fi instabili.")
} else if (any(vif_vals > 5)) {
  print("ATENTIE: Există multicoliniaritate moderată (VIF > 5).")
} else {
  print("OK: Nu există probleme majore de multicoliniaritate.")
}

# 5.2. Heteroscedasticitate (Testul Breusch-Pagan)
# H0: Homoscedasticitate (Varianță constantă)
print("--- Test Heteroscedasticitate (Breusch-Pagan) ---")
bp_test <- bptest(model_multi)
print(bp_test)
if (bp_test$p.value < 0.05) {
  print("ALERTA: Respingem H0. Există Heteroscedasticitate.")
} else {
  print("OK: Nu putem respinge H0. Ipoteza de Homoscedasticitate este validată.")
}

# 5.3. Normalitatea Reziduurilor (Testul Jarque-Bera - Cerut oficial)
# H0: Reziduurile sunt distribuite normal
print("--- Test Normalitate Reziduuri (Jarque-Bera) ---")
jb_test <- jarque.test(resid(model_multi))
print(jb_test)
if (jb_test$p.value < 0.05) {
  print("ALERTA: Respingem H0. Reziduurile NU sunt normale.")
} else {
  print("OK: Nu putem respinge H0. Reziduurile sunt normale.")
}

# 5.4. Autocorelația Erorilor (Testul Durbin-Watson)
# H0: Nu există autocorelație de ordinul 1
print("--- Test Autocorelatie (Durbin-Watson) ---")
dw_test <- dwtest(model_multi)
print(dw_test)
if (dw_test$p.value < 0.05) {
   print("ALERTA: Există autocorelație (Respingem H0).")
} else {
   print("OK: Nu există autocorelație (H0 validată).")
}

# Salvare Rezultate Teste Diagnostic în Excel
# Creăm un data frame cu rezultatele
df_diag <- data.frame(
  Test = c("Shapiro-Wilk (Normalitate)", "Jarque-Bera (Normalitate)", "Breusch-Pagan (Heteroscedasticitate)", "Durbin-Watson (Autocorelare)"),
  Statistica = c(shapiro_test$statistic, jb_test$statistic, bp_test$statistic, dw_test$statistic),
  P_Value = c(shapiro_test$p.value, jb_test$p.value, bp_test$p.value, dw_test$p.value),
  Concluzie = c(
    ifelse(shapiro_test$p.value > 0.05, "Normal", "Ne-normal"),
    ifelse(jb_test$p.value > 0.05, "Normal", "Ne-normal"),
    ifelse(bp_test$p.value > 0.05, "Homoscedastic", "Heteroscedastic"),
    ifelse(dw_test$p.value > 0.05, "Fara Autocorelare", "Autocorelare")
  )
)
write_xlsx(df_diag, "Output/Rapoarte/Rezultate_Teste_Diagnostic.xlsx")



# ==============================================================================
# 6. Grafice de Diagnostic
# ==============================================================================

# QQ Plot - Normalitate
png("Output/Grafice/QQ_Plot_Reziduuri.png", width = 800, height = 600)
qqPlot(model_multi, main="Q-Q Plot: Verificarea Normalității Reziduurilor")
dev.off()

# Residuals vs Fitted - Heteroscedasticitate / Neliniaritate
png("Output/Grafice/Residuals_vs_Fitted.png", width = 800, height = 600)
plot(model_multi, which = 1, main = "Residuals vs Fitted")
dev.off()

# ==============================================================================
# 7. Model 3: Regresie Multiplă Refinată (Soluție pentru VIF > 10)
# ==============================================================================
# Eliminăm variabila cu VIF-ul cel mai mare (ln_Politie = 13.5) pentru a corecta multicoliniaritatea
# În literatura, numărul de polițiști e adesea endogen (mai multe furturi -> angajăm polițiști),
# deci eliminarea sa poate fi justificată și teoretic (sau tratată prin 2SLS, dar aici simplificăm).

print("==============================================================================")
print("7. MODEL 3: REGRESIE REFINATĂ (Fără ln_Politie)")
print("==============================================================================")

model_refinat <- lm(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate + Membru_UE, data = df_final)
summary_refinat <- summary(model_refinat)
print(summary_refinat)

# Recalculare VIF pentru modelul refinat
print("--- VIF Model Refinat ---")
vif_refinat <- vif(model_refinat)
print(vif_refinat)

# Salvare Rezultate Model Refinat
tidy_refinat <- tidy(model_refinat)
glance_refinat <- glance(model_refinat)
write_xlsx(list(Coeficienti = tidy_refinat, Sumar = glance_refinat), "Output/Rapoarte/Rezultate_Regresie_Refinat.xlsx")

vif_df_refinat <- data.frame(Variabila = names(vif_refinat), VIF = vif_refinat)
write_xlsx(vif_df_refinat, "Output/Rapoarte/Rezultate_VIF_Refinat.xlsx")

print("==============================================================================")
print("Script finalizat. Rezultatele sunt salvate în Output/Rapoarte și Output/Grafice.")

sink()
