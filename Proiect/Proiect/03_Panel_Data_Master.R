
# ==============================================================================
# SCRIPT 03: ANALIZA DATE DE TIP PANEL (PANEL DATA)
# ==============================================================================
# Acest script implementeaza Aplicatia 2 conform cerintelor.
# Obiectiv: Modelarea evolutiei furturilor in timp si spatiu (Tari x Ani).
# ==============================================================================

rm(list = ls()) 

# 1. INCARCARE PACHETE
# ==============================
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse, readxl, plm, lmtest, sandwich, car, Formula, stargazer, writexl
)

# Setare director (ajustati daca e nevoie)
# setwd("C:/Users/Jaxtin/Desktop/Econometrie/Proiect-Econometrie/Proiect/Proiect")
print(getwd())

# Redirect output
sink("Output/Rapoarte/03_Panel_Full_Output.txt", split = TRUE)

print("=== START SCRIPT 03 ===")

# 2. INCARCARE DATE
# ==============================
# Incarcam Master Data generat de Script 01
files <- list.files("Output/Date", pattern = "Date_Proiect_Final_Total", full.names = TRUE)
if(length(files) == 0) stop("Nu am gasit fisierul Date_Proiect_Final_Total. Rulati Script 01!")
df_panel_raw <- read_xlsx(files[1])

print("Date incarcate. Structura Panel:")
# Transformare in pdata.frame (Format specific librariei plm)
# Index: Country (Individual), An (Time)
pdf <- pdata.frame(df_panel_raw, index = c("Tara", "An"))

# Verificare structura (Balanced / Unbalanced)
print(pdim(pdf))
head(pdf)

# ==============================================================================
# 3. ESTIMARE MODELE
# ==============================================================================
# Variabila dependenta: ln_Furturi
# Variabile independente: ln_PIB, ln_Someri, ln_Imigratie, ln_Densitate

formula_panel <- ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate

# 3.1 Model POLS (Pooled OLS)
print("--- MODEL POOLED OLS ---")
model_pool <- plm(formula_panel, data = pdf, model = "pooling")
summary(model_pool)

# 3.2 Model FE (Fixed Effects / Within)
print("--- MODEL FIXED EFFECTS (WITHIN) ---")
model_fe <- plm(formula_panel, data = pdf, model = "within")
summary(model_fe)

# 3.3 Model RE (Random Effects)
print("--- MODEL RANDOM EFFECTS ---")
model_re <- plm(formula_panel, data = pdf, model = "random")
summary(model_re)

# 3.4 Model Two-Ways (Efecte Fixe de Timp si Individ)
print("--- MODEL TWO-WAYS FE ---")
model_tw <- plm(formula_panel, data = pdf, model = "within", effect = "twoways")
summary(model_tw)

# Comparatie Tabelara
stargazer(model_pool, model_fe, model_re, model_tw, type = "text", 
          column.labels = c("Pooled", "Fixed Effects", "Random Effects", "Two-Ways"))

# ==============================================================================
# 4. TESTE DE SELECTIE A MODELULUI
# ==============================================================================

print("--- 4.1 Test F pentru Efecte Fixe (Pooled vs FE) ---")
print(pFtest(model_fe, model_pool))

print("--- 4.2 Test Breusch-Pagan SOS (Pooled vs RE) ---")
print(plmtest(model_pool, type = "bp")) 

print("--- 4.3 Test Hausman (FE vs RE) ---")
print(phtest(model_fe, model_re))

print("--- 4.4 Test pentru Efecte de Timp ---")
print(pFtest(model_tw, model_fe))

# ==============================================================================
# 5. DIAGNOSTICE PE MODELUL ALES (Presupunem FE sau RE conform testelor)
# ==============================================================================
# Pentru exemplificare, vom face diagnostice pe modelul FE (cel mai comun)
final_model <- model_fe 
print("--- DIAGNOSTICE PE MODELUL SELECTAT (FE) ---")

# 5.1 Testare Dependenta Transversala
print("--- Test Pesaran CD ---")
print(pcdtest(final_model, test = "cd"))

# 5.2 Testare Autocorelare Seriala
print("--- Test Breusch-Godfrey Panel ---")
print(pbgtest(final_model))

# 5.3 Testare Heteroscedasticitate
print("--- Test Breusch-Pagan Robust ---")
print(bptest(ln_Furturi ~ ln_PIB + ln_Someri + ln_Imigratie + ln_Densitate + factor(Tara), data = df_panel_raw, studentize=F))

# ==============================================================================
# 6. ESTIMARE ROBUSTA (Daca avem probleme detectate mai sus)
# ==============================================================================
print("--- ESTIMARE CU ERORI STANDARD ROBUSTE (HAC) ---")

robust_se <- vcovHC(final_model, method = "arellano")
print(coeftest(final_model, vcov = robust_se))

stargazer(final_model, coeftest(final_model, vcov = robust_se), type="text",
          title = "Model Standard vs Model Robust",
          column.labels = c("Standard", "Robust (HAC)"))

print("=== Script 03 FINALIZAT ===")
sink()

print("=== Script 03 FINALIZAT ===")
