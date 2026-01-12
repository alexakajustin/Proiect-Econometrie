
import pandas as pd
import os
import re
import numpy as np

# Base paths
base_dir = r"c:\Users\Jastin\Desktop\Econometrie\Proiect-Econometrie\Proiect\Proiect"
raw_dir = os.path.join(base_dir, "Used Data") # Correct folder now
clean_dir = os.path.join(base_dir, "Cleaned Data")

# Files in "Used Data"
files_map = {
    "theft": "theft_2019_2023.xlsx",
    "gdp": "gdp_per_capita_2019_2023.xlsx",
    "unemployment": "unemployment_2019_2023.xlsx",
    "immigration": "immigration_2019_2023.xlsx",
    "population_density": "populatioin_density_2019_2023.xlsx" # Valid typo
}

data_frames = {}

def clean_country_name(name):
    name = str(name).strip()
    name = re.sub(r'\s*\(.*\)', '', name)
    return name

def read_and_extract(key, filename):
    path = os.path.join(raw_dir, filename)
    print(f"Processing {key} from {filename}...")
    
    try:
        # User implies these might be raw Eurostat files now or the ones he uploaded.
        # We try to detect header intelligently.
        # Reading first 20 rows to find header.
        preview = pd.read_excel(path, header=None, nrows=20)
    except Exception as e:
        print(f"FAILED to read {filename}: {e}")
        return None

    header_row = None
    for i, row in preview.iterrows():
        row_str = row.astype(str).values
        # Look for Year columns or TIME
        if "2019" in row_str or "2023" in row_str or "TIME" in row_str:
            header_row = i
            break
            
    if header_row is None:
        print(f"  Could not detect header for {filename}")
        return None
        
    df = pd.read_excel(path, header=header_row)
    col_country = df.columns[0]
    
    # Find ALL year columns
    year_cols = {}
    for c in df.columns:
        c_str = str(c).strip()
        for y in ['2019', '2020', '2021', '2022', '2023']:
             if y == c_str or str(y) in c_str:
                 # Precision check: Ensure it's not "2019Q1" if we only want annual
                 # For now, just taking the column containing the year
                 year_cols[y] = c
    
    # We strictly want 2019, 2020, 2021, 2022, 2023
    # If some are missing here, they will be handled in Imputation step.
    
    if not year_cols:
        print(f"  No year columns found for {filename}. Columns: {list(df.columns)}")
        return None
    
    # Keep Country + Available years
    cols_to_keep = [col_country] + list(year_cols.values())
    df_clean = df[cols_to_keep].copy()
    
    # Rename columns
    renames = {v: k for k, v in year_cols.items()}
    renames[col_country] = "Tara"
    df_clean.rename(columns=renames, inplace=True)
    
    # Clean Country names
    df_clean["Tara"] = df_clean["Tara"].apply(clean_country_name)
    
    # Exclude invalid rows
    invalid_names = ["GEO", "nan", "", "NA", "European Union", "Euro area", "TIME", "Germany (until 1990 former territory of the FRG)"]
    df_clean = df_clean[~df_clean["Tara"].isin(invalid_names)]
    df_clean = df_clean[df_clean["Tara"].notna()]
    df_clean = df_clean[df_clean["Tara"].str.len() > 1]
    
    # Convert to numeric
    years_found = list(renames.values()) # 2019, 2023 etc
    
    # Ensure std years exist as columns
    years_std = ['2019', '2020', '2021', '2022', '2023']
    for y in years_std:
        if y not in df_clean.columns:
            df_clean[y] = np.nan

    for y in years_std:
        df_clean[y] = pd.to_numeric(df_clean[y], errors='coerce')
    
    # 1. IMPUTATION: FFILL / BFILL across years
    # If 2023 is missing, take 2022. If 2019 is missing, take 2020.
    df_clean[years_std] = df_clean[years_std].ffill(axis=1).bfill(axis=1)
    
    # Drop rows that are fully empty (no data for any year)
    df_clean.dropna(subset=years_std, how='all', inplace=True)
    
    df_clean = df_clean[["Tara"] + years_std]
    df_clean.drop_duplicates(subset=["Tara"], inplace=True)
    
    return df_clean

# 1. LOAD ALL
for key, fname in files_map.items():
    df = read_and_extract(key, fname)
    if df is not None:
        data_frames[key] = df

if not data_frames:
    print("No dataframes loaded!")
    exit()

# 2. UNION OF COUNTRIES
# We want to keep a country if it exists in ANY dataset? 
# Or intersection? User said "maximize number of countries".
# The safest for regression is INTERSECTION of imputed datasets.
# But "impute missing countries" implies UNION.
# Strategy: Union. If a country is missing in GDP but present in Theft, fill GDP with mean?
# User said: "si daca o tara nu are nicio data la niciun an, doar pune media celorlalte"
# THIS CONFIRMS UNION + MEAN FILL.

all_countries = set()
for k, df in data_frames.items():
    all_countries.update(df["Tara"].tolist())

sorted_countries = sorted(list(all_countries))
print(f"\nTotal Unique Countries found: {len(sorted_countries)}")
print(sorted_countries)

# 3. IMPUTE MISSING COUNTRIES AND SAVE
if not os.path.exists(clean_dir):
    os.makedirs(clean_dir)

years_std = ['2019', '2020', '2021', '2022', '2023']

for k, df in data_frames.items():
    # Merge with full country list
    df_full = pd.DataFrame({"Tara": sorted_countries})
    df_merged = pd.merge(df_full, df, on="Tara", how="left")
    
    # Check again for NaNs (Missing countries will have NaNs in all years)
    # Fill these NaNs with column mean
    for y in years_std:
        # Calculate mean of existing values
        col_mean = df_merged[y].mean()
        # Fill
        df_merged[y] = df_merged[y].fillna(col_mean)
    
    # Save
    out_name = f"{k}_cleaned.xlsx"
    out_path = os.path.join(clean_dir, out_name)
    df_merged.to_excel(out_path, index=False)
    print(f"Saved {out_name} with {len(df_merged)} rows.")

# --- ADD EST/VEST DUMMY VARIABLE ---
# Eastern Europe (Post-Communist EU members)
EAST_COUNTRIES = [
    "Romania", "Bulgaria", "Poland", "Hungary", "Czechia", "Czech Republic",
    "Slovakia", "Slovenia", "Croatia", "Lithuania", "Latvia", "Estonia",
    "Albania", "Serbia", "North Macedonia", "Montenegro", "Kosovo"
]

# Create a separate file with the Est_Vest classification
df_est_vest = pd.DataFrame({"Tara": sorted_countries})
df_est_vest["Est_Vest"] = df_est_vest["Tara"].apply(
    lambda x: 1 if any(e.lower() in x.lower() for e in EAST_COUNTRIES) else 0
)

est_vest_path = os.path.join(clean_dir, "est_vest_dummy.xlsx")
df_est_vest.to_excel(est_vest_path, index=False)
print(f"\nCreated Est_Vest dummy file with {df_est_vest['Est_Vest'].sum()} Eastern European countries.")
print(f"Countries classified as EAST: {df_est_vest[df_est_vest['Est_Vest'] == 1]['Tara'].tolist()}")
print(f"Countries classified as WEST: {df_est_vest[df_est_vest['Est_Vest'] == 0]['Tara'].tolist()}")

