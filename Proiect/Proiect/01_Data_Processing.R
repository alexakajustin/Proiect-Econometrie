
# ==============================================================================
# SCRIPT 01: PROCESARE SI UNIFICARE DATE
# ==============================================================================
# Obiectiv: 
# 1. Citirea seturilor de date individuale (Furturi, PIB, Somaj, Imigratie, Densitate)
# 2. Transformarea lor in format LONG (Tara, An, Valoare)
# 3. Unificarea intr-un singur Master Dataset
# 4. Crearea variabilelor derivate (Dummies, Logaritmi)
# 5. Salvarea datelor finale pentru analizele ulterioare
# ==============================================================================

# 1. Incarcare biblioteci necesare
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, tidyverse, writexl, janitor)

# Setare director de lucru (Asigurati-va ca este setat corect la rulare)
# setwd("C:/Users/Jaxtin/Desktop/Econometrie/Proiect-Econometrie/Proiect/Proiect")
print(paste("Directorul curent:", getwd()))

# Redirect output
if (!dir.exists("Output/Rapoarte")) dir.create("Output/Rapoarte", recursive = TRUE)
sink("Output/Rapoarte/01_Data_Processing_Full_Output.txt", split = TRUE)

print("=== START SCRIPT 01 ===")

# Definire cai catre date
data_path <- "Cleaned Data/"   # Calea este relativa la script (folder curent)

# ==============================================================================
# 2. CITIRE SI PRELUCRARE DATE INDIVIDUALE
# ==============================================================================

# Functie pentru curatarea si pivotarea datelor
# Presupunem ca fisierele au structura: Country, 2010.0, 2011.0 ...
process_file <- function(filename, value_name) {
  full_path <- paste0(data_path, filename)
  
  if(!file.exists(full_path)) {
    stop(paste("EROARE: Fisierul nu exista:", full_path))
  }
  
  df <- read_excel(full_path)
  
  # Redenumire prima coloana daca e necesar
  colnames(df)[1] <- "Tara"
  
  # Transformare din Wide in Long
  df_long <- df %>%
    pivot_longer(
      cols = -Tara, 
      names_to = "An", 
      values_to = value_name
    ) %>%
    mutate(
      An = as.numeric(gsub("\\.0", "", An)), # Curatare nume an (ex: "2019.0" -> 2019)
      Tara = str_trim(Tara) # Eliminare spatii inutile
    )
  
  return(df_long)
}

# Procesare fiecare fisier
print("--- Procesare Fisiere ---")
df_theft <- process_file("theft_cleaned.xlsx", "Furturi")
df_gdp   <- process_file("gdp_cleaned.xlsx", "PIB_per_capita")
df_unemp <- process_file("unemployment_cleaned.xlsx", "Someri_Mii")
df_immig <- process_file("immigration_cleaned.xlsx", "Imigratie")
df_pop   <- process_file("population_density_cleaned.xlsx", "Densitate_Populatie")

print("Fisiere citite cu succes.")

# ==============================================================================
# 3. UNIFICARE DATE (JOIN)
# ==============================================================================

# Unificam toate dataframe-urile pe baza cheii compuse (Tara, An)
df_total <- df_theft %>%
  inner_join(df_gdp, by = c("Tara", "An")) %>%
  inner_join(df_unemp, by = c("Tara", "An")) %>%
  inner_join(df_immig, by = c("Tara", "An")) %>%
  inner_join(df_pop, by = c("Tara", "An"))

print(paste("Dimensiuni Master Data:", nrow(df_total), "randuri,", ncol(df_total), "coloane"))

# ==============================================================================
# 4. CREARE VARIABILE NOI SI DUMMIES
# ==============================================================================

# Lista tari est-europene pentru dummy Est_Vest
eastern_countries <- c(
  "Bulgaria", "Croatia", "Czechia", "Estonia", "Hungary", "Latvia", 
  "Lithuania", "Poland", "Romania", "Slovakia", "Slovenia", "Albania",
  "North Macedonia", "Serbia", "Montenegro", "Bosnia and Herzegovina"
)

# Adaugare variabile
df_processed <- df_total %>%
  mutate(
    # 1. Variabila Dummy Est_Vest (1 daca e in Est, 0 altfel)
    Est_Vest = ifelse(Tara %in% eastern_countries, 1, 0),
    
    # 2. Variabila Dummy 'High_Income' (Exemplu pentru cerinta de variabile dummy)
    # Definim High Income daca PIB > medie
    High_Income = ifelse(PIB_per_capita > mean(PIB_per_capita, na.rm=TRUE), 1, 0),
    
    # 3. Logaritmi (pentru forme functionale log-log si interpretare elasticitati)
    # Adaugam +1 la Imigratie pentru a evita log(0) daca e cazul
    ln_Furturi = log(Furturi),
    ln_PIB = log(PIB_per_capita),
    ln_Someri = log(Someri_Mii),
    ln_Imigratie = log(Imigratie + 1),
    ln_Densitate = log(Densitate_Populatie),
    
    # 4. Patrate (pentru testare neliniaritate ca in exemplu)
    ln_PIB_sq = ln_PIB^2
  )

# Traducere Nume Tari (Optional, pentru grafice frumoase)
translations <- c(
  "Austria" = "Austria", "Belgium" = "Belgia", "Bulgaria" = "Bulgaria", 
  "Croatia" = "Croația", "Cyprus" = "Cipru", "Czechia" = "Cehia", 
  "Denmark" = "Danemarca", "Finland" = "Finlanda", "Germany" = "Germania", 
  "Greece" = "Grecia", "Hungary" = "Ungaria", "Iceland" = "Islanda", 
  "Ireland" = "Irlanda", "Latvia" = "Letonia", "Lithuania" = "Lituania", 
  "Luxembourg" = "Luxemburg", "Malta" = "Malta", "Netherlands" = "Olanda", 
  "Poland" = "Polonia", "Portugal" = "Portugalia", "Romania" = "România", 
  "Slovakia" = "Slovacia", "Slovenia" = "Slovenia", "Spain" = "Spania", 
  "Sweden" = "Suedia", "Switzerland" = "Elveția", "France" = "Franta", 
  "Italy" = "Italia", "Norway" = "Norvegia"
)

# Aplicam traducerea unde exista, altfel pastram originalul
df_processed$Tara_RO <- ifelse(df_processed$Tara %in% names(translations), 
                               translations[df_processed$Tara], 
                               df_processed$Tara)

# ==============================================================================
# 5. ANALIZA EXPLORATORIE (GRAFICE)
# ==============================================================================

# Verificare si creare director Output/Grafice
if (!dir.exists("Output/Grafice")) dir.create("Output/Grafice", recursive = TRUE)

print("--- GENERARE GRAFICE EXPLORATORII ---")

# 5.1 Histograme pentru variabilele principale (Logaritmate)
# Setam layout 2x2
png("Output/Grafice/01_Histograme_Variabile.png", width = 1000, height = 800)
par(mfrow = c(2, 2))
hist(df_processed$ln_Furturi, main = "Histograma Log(Furturi)", col = "skyblue", border = "white", xlab = "ln_Furturi")
hist(df_processed$ln_PIB, main = "Histograma Log(PIB)", col = "lightgreen", border = "white", xlab = "ln_PIB")
hist(df_processed$ln_Someri, main = "Histograma Log(Someri)", col = "salmon", border = "white", xlab = "ln_Someri")
hist(df_processed$ln_Imigratie, main = "Histograma Log(Imigratie)", col = "orange", border = "white", xlab = "ln_Imigratie")
par(mfrow = c(1, 1)) # Reset layout
dev.off()
print("Salvat: Output/Grafice/01_Histograme_Variabile.png")

# 5.2 Boxplot pentru detectia outlierilor (Furturi pe Ani)
png("Output/Grafice/01_Boxplot_Evolutie_Furturi.png", width = 1000, height = 600)
boxplot(ln_Furturi ~ An, data = df_processed, 
        main = "Distributia Furturilor (Log) pe Ani",
        col = "lightblue", las = 2)
dev.off()
print("Salvat: Output/Grafice/01_Boxplot_Evolutie_Furturi.png")

# 5.3 Matrice de Corelatie (Variabile Numerice)
png("Output/Grafice/01_Matrice_Corelatie.png", width = 800, height = 800)
# Selectam doar var numerice logaritmate
nums <- df_processed %>% select(ln_Furturi, ln_PIB, ln_Someri, ln_Imigratie, ln_Densitate)
cor_matrix <- cor(nums, use = "complete.obs")
# Folosim image() din base R pentru a nu depinde de alte pachete (corrplot)
image(1:ncol(cor_matrix), 1:ncol(cor_matrix), cor_matrix, axes = FALSE, xlab="", ylab="", 
      main = "Matrice de Corelatie", col = heat.colors(20))
axis(1, 1:ncol(cor_matrix), colnames(cor_matrix), las=2)
axis(2, 1:ncol(cor_matrix), colnames(cor_matrix), las=2)
text(expand.grid(1:ncol(cor_matrix), 1:ncol(cor_matrix)), labels = round(c(cor_matrix), 2))
dev.off()
print("Salvat: Output/Grafice/01_Matrice_Corelatie.png")


# ==============================================================================
# 6. SALVARE REZULTATE FINALE
# ==============================================================================

# Verificare si creare director Output/Date
if (!dir.exists("Output/Date")) dir.create("Output/Date", recursive = TRUE)

# Salvare fisier principal
write_xlsx(df_processed, "Output/Date/Date_Proiect_Final_Total.xlsx")
print("Salvat: Output/Date/Date_Proiect_Final_Total.xlsx")

# Salvare subset pentru 2023 (Analiza Transversala)
# Daca 2023 nu are date complete, incercam 2022
rows_2023 <- df_processed %>% filter(An == 2023)
target_year <- 2023
if(nrow(rows_2023) < 10) {
  print("ATENTIE: Date insuficiente pentru 2023. Se utilizeaza 2022 pentru Cross-Section.")
  target_year <- 2022
}

df_cross_section <- df_processed %>% filter(An == target_year)
write_xlsx(df_cross_section, paste0("Output/Date/Date_CrossSection_", target_year, ".xlsx"))
print(paste0("Salvat: Output/Date/Date_CrossSection_", target_year, ".xlsx"))

print("=== Script 01 FINALIZAT ===")
sink()
