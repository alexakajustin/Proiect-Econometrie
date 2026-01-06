# ==============================================================================
# PROIECT ECONOMETRIE: APLICAȚIA 1 - ANALIZĂ EXPLORATORIE (EDA)
# ==============================================================================

# 1. Încărcarea Bibliotecilor Necesare
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  readxl,       # Citire Excel
  tidyverse,    # Manipulare date și grafice (ggplot2, dplyr)
  writexl,      # Salvare Excel
  corrplot,     # Matrice de corelație
  psych,        # Statistici descriptive (skewness, kurtosis)
  janitor,      # Curățare nume coloane
  caret         # Pentru împărțirea setului de date (Train/Test)
)

# Setare director de lucru EXPLICIT (pentru a evita erorile de path)
setwd("C:/Users/Jastin/Desktop/Econometrie/Proiect-Econometrie/Proiect/Proiect")

# ==============================================================================
# 1.1 ORGANIZARE ȘI CLEANUP (NOU)
# ==============================================================================

# Definim structura de directoare dorită
dirs <- c("Output", "Output/Date", "Output/Grafice", "Output/Rapoarte")

# Creăm directoarele dacă nu există
for (d in dirs) {
  if (!dir.exists(d)) dir.create(d)
}

# Funcție pentru a muta fișierele "rătăcite" în structura nouă
move_file <- function(file, dest_folder) {
  if (file.exists(file)) {
    new_path <- paste0(dest_folder, "/", file)
    file.rename(from = file, to = new_path)
    print(paste("Movat:", file, "->", dest_folder))
  }
}

# Mutăm fișierele generate anterior (dacă există în root)
move_file("Date_Proiect_Final_2023.xlsx", "Output/Date")
move_file("Date_Antrenare.xlsx", "Output/Date")
move_file("Date_Testare.xlsx", "Output/Date")
move_file("Statistici_Descriptive.csv", "Output/Rapoarte")
move_file("rezultate_analiza.txt", "Output/Rapoarte")
move_file("Hist_Furturi.png", "Output/Grafice")
move_file("Scatter_Somaj_Furturi.png", "Output/Grafice")
move_file("Scatter_Log_Somaj_Furturi.png", "Output/Grafice")
move_file("Plot_Corelatie.png", "Output/Grafice")

# PORNIRE LOGGING: Acum salvăm în folderul Rapoarte
sink("Output/Rapoarte/rezultate_analiza.txt", split = TRUE)

# ==============================================================================
# 2. Încărcarea și Unificarea Datelor
# ==============================================================================

# Căi către fișierele de date
data_path <- "Cleaned Data/"

# Citirea seturilor de date individuale
df_theft <- read_excel(paste0(data_path, "theft_cleaned.xlsx"))
df_gdp <- read_excel(paste0(data_path, "gdp_cleaned.xlsx"))
df_unemp <- read_excel(paste0(data_path, "unemployment_cleaned.xlsx"))
df_immig <- read_excel(paste0(data_path, "immigration_cleaned.xlsx"))
df_police <- read_excel(paste0(data_path, "police_cleaned.xlsx"))
df_pop <- read_excel(paste0(data_path, "population_density_cleaned.xlsx"))

# Funcție pentru transformarea din Wide în Long (Ani pe coloane -> An pe rânduri)
process_wide_data <- function(df, val_name) {
  # Verificăm dacă există coloana 'Country'
  if (!"Country" %in% names(df)) {
    # Încercăm să găsim o coloană care seamănă a țară sau prima coloană
    names(df)[1] <- "Country"
  }
  
  df_long <- df %>%
    pivot_longer(
      cols = -Country,      # Toate coloanele în afară de Country (adică anii)
      names_to = "Year",    # Numele noii coloane pentru ani
      values_to = val_name  # Numele noii coloane pentru valori
    ) %>%
    mutate(Year = as.numeric(Year)) # Asigurăm că Anul este numeric (ex: "2019" -> 2019)
    
  return(df_long)
}

# Procesăm fiecare set de date pentru a ajunge la formatul: Country, Year, Valoare
df_theft_long <- process_wide_data(df_theft, "Furturi")
df_gdp_long <- process_wide_data(df_gdp, "PIB_per_capita")
df_unemp_long <- process_wide_data(df_unemp, "Someri_Mii") # Corecție: Unitatea este Mii Persoane
df_immig_long <- process_wide_data(df_immig, "Imigratie")
df_police_long <- process_wide_data(df_police, "Politie")
df_pop_long <- process_wide_data(df_pop, "Densitate_Populatie")

# Unificare (Left Join succesiv pe baza Cheilor: Country și Year)
df_total <- df_theft_long %>%
  left_join(df_gdp_long, by = c("Country", "Year")) %>%
  left_join(df_unemp_long, by = c("Country", "Year")) %>%
  left_join(df_immig_long, by = c("Country", "Year")) %>%
  left_join(df_police_long, by = c("Country", "Year")) %>%
  left_join(df_pop_long, by = c("Country", "Year"))

# Verificare rapidă
print("Structura Datelor Unificate (df_total):")
str(df_total)

# Redenumire coloane pentru claritate (în română)
# Ordinea ar trebui să fie: Country, Year, Furturi, PIB, Someri_Mii, Imigratie, Politie, Densitate
colnames(df_total) <- c("Tara", "An", "Furturi", "PIB_per_capita", "Someri_Mii", "Imigratie", "Politie", "Densitate_Populatie")

# ==============================================================================
# 3. Filtrare și Creare Variabile Noi
# ==============================================================================

# Selectăm anul 2023 pentru analiza transversală (Cross-Sectional)
# Dacă lipsesc date pentru 2023, folosim 2022 sau media 2019-2023.
df_2023 <- df_total %>%
  filter(An == 2023)

# Dacă df_2023 este gol (ex: nu sunt încă date pe 2023), luăm 2022
if(nrow(df_2023) == 0) {
  message("Nu există date complete pentru 2023. Se utilizează 2022.")
  df_2023 <- df_total %>% filter(An == 2022)
}

# Adăugare variabilă dummy: Membru_UE_i
# 1 = Membru UE, 0 = Non-UE (Elveția, Islanda etc.)
non_eu_countries <- c("Switzerland", "Iceland", "Norway", "United Kingdom", "Turkey")

df_final <- df_2023 %>%
  mutate(
    Membru_UE = ifelse(Tara %in% non_eu_countries, 0, 1),
    # Transformări Logaritmice (pentru normalizare și rezolvarea scalei)
    # Deoarece avem valori totale (Furturi, Șomeri, Poliție), logaritmarea este CRITICĂ
    ln_Furturi = log(Furturi),
    ln_PIB = log(PIB_per_capita),
    ln_Someri = log(Someri_Mii),
    ln_Imigratie = log(Imigratie + 1), # +1 pentru a evita log(0)
    ln_Politie = log(Politie),
    ln_Densitate = log(Densitate_Populatie)
  )

# Traducerea numelor țărilor în Română (pentru afișare)
translations <- c(
  "Austria" = "Austria", "Belgium" = "Belgia", "Bulgaria" = "Bulgaria", 
  "Croatia" = "Croația", "Cyprus" = "Cipru", "Czechia" = "Cehia", 
  "Denmark" = "Danemarca", "Finland" = "Finlanda", "Germany" = "Germania", 
  "Greece" = "Grecia", "Hungary" = "Ungaria", "Iceland" = "Islanda", 
  "Ireland" = "Irlanda", "Latvia" = "Letonia", "Lithuania" = "Lituania", 
  "Luxembourg" = "Luxemburg", "Malta" = "Malta", "Netherlands" = "Olanda", 
  "Poland" = "Polonia", "Portugal" = "Portugalia", "Romania" = "România", 
  "Slovakia" = "Slovacia", "Slovenia" = "Slovenia", "Spain" = "Spania", 
  "Sweden" = "Suedia", "Switzerland" = "Elveția"
)

df_final$Tara <- recode(df_final$Tara, !!!translations)

# Salvare set de date final
write_xlsx(df_final, "Output/Date/Date_Proiect_Final_2023.xlsx")
print("Setul de date final a fost salvat.")

# ==============================================================================
# 4. Analiza Exploratorie (EDA)
# ==============================================================================

# 4.1. Statistici Descriptive
desc_stats <- describe(df_final %>% select_if(is.numeric))
print("Statistici Descriptive:")
print(desc_stats)

# Salvare statistici în CSV
write.csv(desc_stats, "Output/Rapoarte/Statistici_Descriptive.csv")

# 4.2. Matricea de Corelație
cor_matrix <- cor(df_final %>% select(Furturi, PIB_per_capita, Someri_Mii, Imigratie, Politie, Densitate_Populatie, Membru_UE), use = "complete.obs")
print("Matricea de Corelație:")
print(cor_matrix)

# Plot Corelație
png("Output/Grafice/Plot_Corelatie.png", width = 800, height = 600)
corrplot(cor_matrix, method = "color", type = "upper", 
         addCoef.col = "black", tl.col = "black", tl.srt = 45, 
         title = "Matricea de Corelatie a Variabilelor", mar=c(0,0,1,0))
dev.off()

# 4.3. Histograme (Distribuții)
# MODIFICARE: Folosim Logaritmul pentru a avea o distribuție vizibilă (nu "cod de bare")
p1 <- ggplot(df_final, aes(x = ln_Furturi)) +
  geom_histogram(aes(y = ..density..), binwidth = 0.5, fill = "skyblue", color = "black") +
  geom_density(alpha = .2, fill = "#FF6666") +
  labs(title = "Distribuția [Logaritmică] a Furturilor", x = "Log(Furturi)", y = "Densitate") +
  theme_minimal()

ggsave("Output/Grafice/Hist_Furturi.png", plot = p1)

# 4.4. Scatter Plots (Relații)
# Exemplu: Șomeri vs Furturi
p2 <- ggplot(df_final, aes(x = Someri_Mii, y = Furturi)) +
  geom_point(color = "blue") +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  geom_text(aes(label = Tara), vjust = 1.5, size = 3) +
  labs(title = "Relația Nr. Șomeri - Furturi", x = "Nr. Șomeri (Mii)", y = "Furturi") +
  theme_minimal()

ggsave("Output/Grafice/Scatter_Somaj_Furturi.png", plot = p2)

# 4.5. Scatter Plot Log-Log (Unități Armonizate / Elasticitate)
# Răspuns la cerința userului pentru unități armonizate
p3 <- ggplot(df_final, aes(x = ln_Someri, y = ln_Furturi)) +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", color = "orange", se = FALSE) +
  geom_text(aes(label = Tara), vjust = 1.5, size = 3) +
  labs(title = "Relația [Log] Șomeri - [Log] Furturi (Unități Armonizate)", 
       x = "Log(Nr. Șomeri)", y = "Log(Furturi)") +
  theme_minimal()

ggsave("Output/Grafice/Scatter_Log_Somaj_Furturi.png", plot = p3)

# ==============================================================================
# 5. Împărțire Set Date (Train / Test)
# ==============================================================================
set.seed(123) # Pentru reproductibilitate
train_index <- createDataPartition(df_final$Furturi, p = 0.8, list = FALSE)
train_data <- df_final[train_index, ]
test_data <- df_final[-train_index, ]

print(paste("Dimensiune Train:", nrow(train_data)))
print(paste("Dimensiune Test:", nrow(test_data)))

# Salvare Train/Test
write_xlsx(train_data, "Output/Date/Date_Antrenare.xlsx")
write_xlsx(test_data, "Output/Date/Date_Testare.xlsx")

print("Script finalizat cu succes! Rezultatele sunt in folderul 'Output'.")

# OPRIRE LOGGING
sink()
