
# ==============================================================================
# SCRIPT 02: ANALIZA TRANSVERSALA (CROSS-SECTIONAL)
# ==============================================================================
# Acest script replica structura din 'Script_proiect_econometrie.R'
# adaptata la datele proiectului nostru (Furturi, PIB, Somaj, etc.)
# ==============================================================================

rm(list = ls()) 

# 1. INCARCARE PACHETE NECESARE
# ==============================
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse, stargazer, magrittr, lmtest, sandwich, 
  olsrr, moments, whitestrap, ggplot2, tseries, caret, 
  DataCombine, car, glmnet, Boruta, readxl, writexl, strucchange, MLmetrics
)

# Setare director (ajustati daca e nevoie)
# setwd("C:/Users/Jaxtin/Desktop/Econometrie/Proiect-Econometrie/Proiect/Proiect")
print(getwd())


# Redirect all output to a file
sink("Output/Rapoarte/02_Cross_Section_Full_Output.txt", split = TRUE)

print("=== START SCRIPT 02 ===")

# 2. INCARCARE DATE
# ==============================
# Citim datele procesate in Script 01 pentru anul tinta (ex: 2022 sau 2023)
# Cautam fisierul generat
files <- list.files("Output/Date", pattern = "Date_CrossSection", full.names = TRUE)
if(length(files) == 0) stop("Nu am gasit fisierul Date_CrossSection. Rulati Script 01 mai intai!")
data_path <- files[length(files)] # Luam cel mai recent/mare an
df_final <- read_xlsx(data_path)

print(paste("Am incarcat datele din:", data_path))
glimpse(df_final)

# Selectam variabilele de interes pentru afisare (asemanator cu select(...) %>% head(10))
df_final %>%
  select(Tara, Furturi, PIB_per_capita, Someri_Mii, Imigratie, Densitate_Populatie, Est_Vest) %>%
  head(10) %>%
  print()

# Statistici descriptive (Stargazer text)
sd_table <- df_final %>%
  select(Furturi, PIB_per_capita, Someri_Mii, Imigratie, Densitate_Populatie) %>%
  as.data.frame() 
stargazer(sd_table, type = "text", title = "Statistici Descriptive")

# ==============================================================================
# 3. REGRESIE SIMPLA (Iteram prin variabile)
# ==============================================================================
# Variabila dependenta: ln_Furturi (Log Furturi)
# Modelam pe rand in functie de: ln_PIB, ln_Someri, ln_Imigratie, etc.

# 3.1 Furturi vs PIB
print("--- MODEL 1: FURTURI vs PIB ---")
rs_pib <- lm(ln_Furturi ~ ln_PIB, data = df_final)
summary(rs_pib)
# Interpretare: La o crestere cu 1% a PIB, Furturile se modifica cu beta%.

# 3.2 Furturi vs Someri
print("--- MODEL 2: FURTURI vs SOMERI ---")
rs_someri <- lm(ln_Furturi ~ ln_Someri, data = df_final)
summary(rs_someri)

# 3.3 Furturi vs Imigratie
print("--- MODEL 3: FURTURI vs IMIGRATIE ---")
rs_imig <- lm(ln_Furturi ~ ln_Imigratie, data = df_final)
summary(rs_imig)

# 3.4 Furturi vs Densitate
print("--- MODEL 4: FURTURI vs DENSITATE ---")
rs_dens <- lm(ln_Furturi ~ ln_Densitate, data = df_final)
summary(rs_dens)

# 3.5 Furturi vs Est_Vest (Variabila Dummy)
print("--- MODEL 5: FURTURI vs DUMMY EST/VEST ---")
rs_est <- lm(ln_Furturi ~ Est_Vest, data = df_final)
summary(rs_est)
# Daca Est_Vest = 1, furturile sunt cu ... % diferite fata de Vest.

# ==============================================================================
# 4. ANALIZA DETALIATA PE UN MODEL SIMPLU (Modelul Optim)
# ==============================================================================
# Alegem modelul cu cel mai bun R2 sau interes economic. 
# Sa presupunem ca 'ln_Someri' este semnificativ.

print("--- ANALIZA DETALIATA: Model ln_Furturi ~ ln_Someri ---")
model_simplu <- rs_someri 
summary(model_simplu)

# Salvare grafic Regresie Simpla
png("Output/Grafice/Regresie_Simpla_Someri.png", width=800, height=600)
plot(df_final$ln_Someri, df_final$ln_Furturi, main="Regresie Simpla: Furturi vs Someri",
     xlab="Log(Someri)", ylab="Log(Furturi)", pch=19, col="blue")
abline(model_simplu, col="red", lwd=2)
dev.off()

# 4.1 Ipoteze Clasice pe Modelul Simplu

# a) Media reziduurilor zero
print("Media Reziduurilor:")
print(mean(resid(model_simplu))) # Trebuie sa fie aproape 0

# b) Homoscedasticitate (Breusch-Pagan & White)
print("Test Breusch-Pagan:")
print(bptest(model_simplu))     # H0: Homoscedasticitate. p > 0.05 => OK

# c) Normalitate (Jarque-Bera, Shapiro-Wilk)
print("Test Jarque-Bera:")
print(jarque.bera.test(resid(model_simplu)))
print("Test Shapiro-Wilk:")
print(shapiro.test(resid(model_simplu))) # p > 0.05 => Normalitate

# Grafice Normalitate
png("Output/Grafice/Hist_Reziduuri_Simplu.png", width=800, height=600)
ols_plot_resid_hist(model_simplu)
dev.off()

png("Output/Grafice/QQ_Reziduuri_Simplu.png", width=800, height=600)
ols_plot_resid_qq(model_simplu)
dev.off()

# d) Autocorelare (Durbin-Watson) - mai putin relevant pe cross-section dar cerut
print("Test Durbin-Watson:")
dwtest(model_simplu)

# 4.2 Outlieri si Distanta Cook
png("Output/Grafice/Cooks_Distance_Bar.png", width=800, height=600)
ols_plot_cooksd_bar(model_simplu)
dev.off()

png("Output/Grafice/Cooks_Distance_Chart.png", width=800, height=600)
ols_plot_cooksd_chart(model_simplu)
dev.off()

# Identificare puncte influente (Cook's D > 4/n)
cook_d <- cooks.distance(model_simplu)
influential <- which(cook_d > 4/nrow(df_final))
print(paste("Observatii influente:", length(influential)))
if(length(influential) > 0) {
  print(df_final$Tara[influential])
  
  # Re-estimare fara outlieri (OPTIONAL - ca in exemplu)
  df_clean <- df_final[-influential, ]
  model_simplu_clean <- lm(ln_Furturi ~ ln_Someri, data = df_clean)
  summary(model_simplu_clean)
  print("Model re-estimat fara outlieri.")
} else {
  df_clean <- df_final
  model_simplu_clean <- model_simplu
}

# ==============================================================================
# 5. PROGNOZE (Train / Test Split)
# ==============================================================================
print("--- PROGNOZE SI VALIDARE ---")
set.seed(123)

# Split 80/20
train_index <- createDataPartition(df_clean$ln_Furturi, p = 0.8, list = FALSE)
train_data <- df_clean[train_index, ]
test_data  <- df_clean[-train_index, ]

# Antrenare pe Train
model_train <- lm(ln_Furturi ~ ln_Someri, data = train_data)

# Predictie pe Test
preds <- predict(model_train, newdata = test_data)

# Metrici de performanta
actuals <- test_data$ln_Furturi
rmse_val <- RMSE(preds, actuals)
mae_val <- MAE(preds, actuals)
mape_val <- MAPE(exp(preds), exp(actuals)) # MAPE pe valorile reale (non-log)

print(paste("RMSE:", round(rmse_val, 4)))
print(paste("MAE:", round(mae_val, 4)))
print(paste("MAPE:", round(mape_val, 4)))

# Interval de Incredere pentru cateva valori noi (Scenarii)
# Exemplu: Ce se intampla daca somajul creste?
new_vals <- data.frame(ln_Someri = c(log(50), log(100), log(500))) 
pred_conf <- predict(model_train, newdata = new_vals, interval = "confidence", level = 0.90)
print("Intervale de incredere pentru scenarii de somaj (50k, 100k, 500k):")
print(pred_conf)

# ==============================================================================
# 6. REGRESIE MULTIPLA
# ==============================================================================
print("--- REGRESIE MULTIPLA ---")

# Modelam ln_Furturi in functie de TOTI factorii
# Model 0: Toate variabilele
model_multi <- lm(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate + Est_Vest, data = df_clean)
summary(model_multi)
stargazer(model_multi, type = "text", title="Rezultate Regresie Multipla")

# Verificare Multicoliniaritate (VIF)
print("--- TEST VIF (Multicoliniaritate) ---")
print(vif(model_multi)) # Valori > 5 sau 10 indica probleme

# Test F pentru semnificatia globala (e in summary)

# ==============================================================================
# 7. INTERACTIUNI SI TESTE STRUCTURALE (CHOW)
# ==============================================================================
print("--- INTERACTIUNI ---")

# Cream termeni de interactiune intre Est_Vest si PIB
# Ipoteza: PIB-ul influenteaza furturile DIFERIT in EST fata de VEST
df_clean <- df_clean %>% 
  mutate(ln_PIB_Est = ln_PIB * Est_Vest)

model_interact <- lm(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + Est_Vest + ln_PIB_Est, data = df_clean)
summary(model_interact)

# Comparatie modele
stargazer(model_multi, model_interact, type = "text", title="Comparatie Interactiune")

# Test Chow (Structural Change) - Est vs Vest
# Testam daca parametrii difera semnificativ intre cele doua grupuri
# Nota: sctest din strucchange cere ordonare dupa variabila de ruptura sau timp
# Pentru cross-section, folosim chow test manual sau F-test pe interactiuni (echivalent)

# Varianta Manuala F-test (ca in exemplu)
ssr_restricted <- sum(resid(model_multi)^2) # Model fara interactiuni (doar dummy intercept)
# Model nerestrictionat = Model Interactionat complet (toate pantele difera)
model_unrestricted <- lm(ln_Furturi ~ (ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate) * Est_Vest, data = df_clean)
ssr_unrestricted <- sum(resid(model_unrestricted)^2)

# Calcul F-stat Chow
n <- nrow(df_clean)
k <- length(coef(model_unrestricted)) # nr parametri
j <- length(coef(model_multi)) 
# ... logica complexa, simplificam folosind anova()
print("Test Chow (ANOVA intre Model Simplu si Model cu Interactiuni Complete):")
chow_result <- anova(model_multi, model_unrestricted)
print(chow_result)

# Salvare Grafic Chow (Interactiuni ln_Furturi vs ln_Someri pe grupuri)
png("Output/Grafice/02_Stabilitate_Chow.png", width=800, height=600)
ggplot(df_clean, aes(x=ln_Someri, y=ln_Furturi, color=as.factor(Est_Vest))) +
  geom_point() +
  geom_smooth(method="lm", se=FALSE) +
  scale_color_manual(values=c("blue", "red"), labels=c("Vest", "Est")) +
  labs(title="Test Chow: Stabilitate Structurala (Est vs Vest)", 
       x="Log(Someri)", y="Log(Furturi)", color="Grup") +
  theme_minimal()
dev.off()
# Daca p < 0.05 => Exista diferente structurale semnificative intre Est si Vest

# ==============================================================================
# 8. REGULARIZARE (RIDGE, LASSO, ELASTIC NET)
# ==============================================================================
print("--- REGULARIZARE (Machine Learning) ---")

# Pregatire matrice X si vector y
x_vars <- model.matrix(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate + Est_Vest, data = df_clean)[, -1]
y_var <- df_clean$ln_Furturi

# RIDGE (alpha = 0)
print("--- RIDGE ---")
cv_ridge <- cv.glmnet(x_vars, y_var, alpha = 0)
best_lambda_ridge <- cv_ridge$lambda.min
model_ridge <- glmnet(x_vars, y_var, alpha = 0, lambda = best_lambda_ridge)
print(paste("Ridge Lambda Optim:", best_lambda_ridge))
print(coef(model_ridge))

# LASSO (alpha = 1)
print("--- LASSO ---")
cv_lasso <- cv.glmnet(x_vars, y_var, alpha = 1)
best_lambda_lasso <- cv_lasso$lambda.min
model_lasso <- glmnet(x_vars, y_var, alpha = 1, lambda = best_lambda_lasso)
print(paste("Lasso Lambda Optim:", best_lambda_lasso))
print(coef(model_lasso))

# Plot Lasso Trace
png("Output/Grafice/Lasso_Trace_Plot.png", width=800, height=600)
plot(glmnet(x_vars, y_var, alpha = 1), xvar = "lambda", label = TRUE)
dev.off()

# ELASTIC NET (alpha = 0.5)
print("--- ELASTIC NET ---")
cv_enet <- cv.glmnet(x_vars, y_var, alpha = 0.5)
best_lambda_enet <- cv_enet$lambda.min
model_enet <- glmnet(x_vars, y_var, alpha = 0.5, lambda = best_lambda_enet)
print(coef(model_enet))

# Comparatie Performanta (R2 recalculat)
calc_r2 <- function(model, x, y, lambda) {
  preds <- predict(model, s = lambda, newx = x)
  sst <- sum((y - mean(y))^2)
  sse <- sum((y - preds)^2)
  return(1 - sse/sst)
}

r2_ridge <- calc_r2(model_ridge, x_vars, y_var, best_lambda_ridge)
r2_lasso <- calc_r2(model_lasso, x_vars, y_var, best_lambda_lasso)
r2_enet  <- calc_r2(model_enet,  x_vars, y_var, best_lambda_enet)

print(paste("R2 Ridge:", round(r2_ridge, 4)))
print(paste("R2 Lasso:", round(r2_lasso, 4)))
print(paste("R2 ElasticNet:", round(r2_enet, 4)))

# ==============================================================================
# 9. VARIABLE SELECTION (BORUTA)
# ==============================================================================
print("--- BORUTA VARIABLE SELECTION ---")
set.seed(42)
boruta_out <- Boruta(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate + Est_Vest, data = df_clean, doTrace = 0)
print(boruta_out)

png("Output/Grafice/02_Boruta_Selection.png", width=800, height=600)
plot(boruta_out, xlab = "", xaxt = "n", main="Selectia Variabilelor (Algoritmul Boruta)")
lz<-lapply(1:ncol(boruta_out$ImpHistory),function(i)
boruta_out$ImpHistory[is.finite(boruta_out$ImpHistory[,i]),i])
names(lz) <- colnames(boruta_out$ImpHistory)
Labels <- sort(sapply(lz,median))
axis(side = 1,las=2,labels = names(Labels),
at = 1:ncol(boruta_out$ImpHistory), cex.axis = 0.7)
dev.off()

final_vars <- getSelectedAttributes(boruta_out, withTentative = TRUE)
print("Variabile selectate de Boruta:")
print(final_vars)

print("=== Script 02 FINALIZAT ===")
sink()
