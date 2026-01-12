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
  caret,        # Pentru împărțirea setului de date (Train/Test)
  gridExtra     # Pentru aranjarea graficelor în grid
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
df_pop <- read_excel(paste0(data_path, "population_density_cleaned.xlsx"))

# Funcție pentru transformarea din Wide în Long (Ani pe coloane -> An pe rânduri)
process_wide_data <- function(df, val_name) {
  # Verificăm dacă există coloana 'Country'
  if (!"Country" %in% names(df)) {
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
df_unemp_long <- process_wide_data(df_unemp, "Someri_Mii")
df_immig_long <- process_wide_data(df_immig, "Imigratie")
df_pop_long <- process_wide_data(df_pop, "Densitate_Populatie")

# Unificare (Left Join succesiv pe baza Cheilor: Country și Year)
df_total <- df_theft_long %>%
  left_join(df_gdp_long, by = c("Country", "Year")) %>%
  left_join(df_unemp_long, by = c("Country", "Year")) %>%
  left_join(df_immig_long, by = c("Country", "Year")) %>%
  left_join(df_pop_long, by = c("Country", "Year"))

# Verificare rapidă
print("Structura Datelor Unificate (df_total):")
str(df_total)

# Redenumire coloane pentru claritate (în română)
colnames(df_total) <- c("Tara", "An", "Furturi", "PIB_per_capita", "Someri_Mii", "Imigratie", "Densitate_Populatie")

# ==============================================================================
# 3. Filtrare și Creare Variabile Noi
# ==============================================================================

# Selectăm anul 2023 pentru analiza transversală (Cross-Sectional)
df_2023 <- df_total %>%
  filter(An == 2023)

if(nrow(df_2023) == 0) {
  message("Nu există date complete pentru 2023. Se utilizează 2022.")
  df_2023 <- df_total %>% filter(An == 2022)
}

# Adăugare variabilă dummy: Est_Vest (1 = Est, 0 = Vest)
eastern_countries <- c("Bulgaria", "Croatia", "Czechia", "Estonia", "Hungary", "Latvia", 
                       "Lithuania", "Poland", "Romania", "Slovakia", "Slovenia", "Albania",
                       "North Macedonia", "Serbia", "Montenegro", "Bosnia and Herzegovina")

df_final <- df_2023 %>%
  mutate(
    Est_Vest = ifelse(Tara %in% eastern_countries, 1, 0),
    # Transformări Logaritmice
    ln_Furturi = log(Furturi),
    ln_PIB = log(PIB_per_capita),
    ln_Someri = log(Someri_Mii),
    ln_Imigratie = log(Imigratie + 1), 
    ln_Densitate = log(Densitate_Populatie)
  )

# Traducerea numelor țărilor în Română
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

df_final$Tara <- translations[df_final$Tara]

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
write.csv(desc_stats, "Output/Rapoarte/Statistici_Descriptive.csv")

# 4.2. Matricea de Corelație
cor_matrix <- cor(df_final %>% select(Furturi, PIB_per_capita, Someri_Mii, Imigratie, Densitate_Populatie, Est_Vest), use = "complete.obs")
print("Matricea de Corelație:")
print(cor_matrix)

# Plot Corelație
png("Output/Grafice/Plot_Corelatie.png", width = 800, height = 600)
corrplot(cor_matrix, method = "color", type = "upper", 
         addCoef.col = "black", tl.col = "black", tl.srt = 45, 
         title = "Matricea de Corelatie a Variabilelor", mar=c(0,0,1,0))
dev.off()

# 4.3. Histograme si Densitate
plot_hist_density <- function(data, column, title, color_fill) {
  ggplot(data, aes_string(x = column)) +
    geom_histogram(aes(y = ..density..), binwidth = 0.5, fill = color_fill, color = "black", alpha = 0.7) +
    geom_density(alpha = .3, fill = "red") +
    labs(title = title, x = column, y = "Densitate") +
    theme_minimal()
}

p_hist1 <- plot_hist_density(df_final, "ln_Furturi", "Distribuție Furturi (Log)", "skyblue")
p_hist2 <- plot_hist_density(df_final, "ln_PIB", "Distribuție PIB (Log)", "lightgreen")
p_hist3 <- plot_hist_density(df_final, "ln_Someri", "Distribuție Șomaj (Log)", "orange")

png("Output/Grafice/Hist_Grid_All.png", width = 1000, height = 800)
gridExtra::grid.arrange(p_hist1, p_hist2, p_hist3, ncol = 2)
dev.off()

ggsave("Output/Grafice/Hist_Furturi.png", plot = p_hist1)

# 4.4. Boxplots
df_long_z <- df_final %>%
  select(starts_with("ln_")) %>%
  scale() %>%
  as.data.frame() %>%
  pivot_longer(cols = everything(), names_to = "Variabila", values_to = "Z_Score")

p_box <- ggplot(df_long_z, aes(x = Variabila, y = Z_Score, fill = Variabila)) +
  geom_boxplot() +
  labs(title = "Boxplot Standardizat (Identificare Outlieri)", y = "Z-Score (Deviații Standard)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("Output/Grafice/Boxplot_Outlieri.png", plot = p_box)

# 4.5. Top 5 / Bottom 5 Țări
plot_top_bottom <- function(df, var_col, title_text) {
  df_sorted <- df %>% arrange(desc(!!sym(var_col)))
  df_subset <- bind_rows(head(df_sorted, 5), tail(df_sorted, 5))
  
  ggplot(df_subset, aes(x = reorder(Tara, !!sym(var_col)), y = !!sym(var_col), fill = !!sym(var_col))) +
    geom_bar(stat = "identity") +
    coord_flip() +
    labs(title = title_text, x = "Țara", y = var_col) +
    theme_minimal()
}

p_bar1 <- plot_top_bottom(df_final, "Furturi", "Top/Bottom 5 Țări după Nr. Furturi")
ggsave("Output/Grafice/Bar_Top_Furturi.png", plot = p_bar1)

# 4.6. Pair Plot
png("Output/Grafice/Pairs_Plot.png", width = 1000, height = 1000)
pairs.panels(df_final %>% select(ln_Furturi, ln_PIB, ln_Someri, ln_Imigratie), 
             method = "pearson", 
             hist.col = "#00AFBB",
             density = TRUE, 
             ellipses = TRUE
)
dev.off()

# 4.7. Scatter Plot Log-Log
p3 <- ggplot(df_final, aes(x = ln_Someri, y = ln_Furturi)) +
  geom_point(color = "darkgreen", size = 3) +
  geom_smooth(method = "lm", color = "orange", se = TRUE, fill = "wheat") +
  geom_text(aes(label = Tara), vjust = 1.5, size = 3) +
  labs(title = "Relația Log-Log: Șomaj vs Furturi", 
       subtitle = paste("Corelație:", round(cor(df_final$ln_Someri, df_final$ln_Furturi), 2)),
       x = "Log(Nr. Șomeri)", y = "Log(Furturi)") +
  theme_minimal()

ggsave("Output/Grafice/Scatter_Log_Somaj_Furturi.png", plot = p3)

# ==============================================================================
# 5. Împărțire Set Date (Train / Test)
# ==============================================================================
set.seed(123)
train_index <- createDataPartition(df_final$Furturi, p = 0.8, list = FALSE)
train_data <- df_final[train_index, ]
test_data <- df_final[-train_index, ]

write_xlsx(train_data, "Output/Date/Date_Antrenare.xlsx")
write_xlsx(test_data, "Output/Date/Date_Testare.xlsx")

print("Script finalizat cu succes! Rezultatele sunt in folderul 'Output'.")
sink()
