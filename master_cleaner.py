
import pandas as pd
import os
import re

# Base paths
base_dir = r"c:\Users\Jastin\Desktop\Econometrie\Proiect-Econometrie\Proiect\Proiect"
raw_dir = os.path.join(base_dir, "Data Used")
clean_dir = os.path.join(base_dir, "Cleaned Data")

# Mapping: Output Keyword -> Input Filename
# Excluding Police as per user preference in model, but user said "look thru all data", 
# so I will include it in cleaning but it won't be used if R script doesn't load it. 
# actually, let's include it to be safe, just in case they change their mind again.
files_map = {
    "theft": "theft_2019_2023.xlsx",
    "gdp": "gdp_per_capita_2019_2023.xlsx",
    "unemployment": "unemployment_2019_2023.xlsx",
    "immigration": "immigration_2019_2023.xlsx",
    "population_density": "populatioin_density_2019_2023.xlsx", # Typo in filename
    "education": "expected_education_2019_2023.xlsx",
    #"police": "police_number_2019_2023.xlsx" # Optional
}

data_frames = {}

def clean_country_name(name):
    # Remove () info, strip whitespace
    name = str(name).strip()
    name = re.sub(r'\s*\(.*\)', '', name)
    return name

def read_and_extract(key, filename):
    path = os.path.join(raw_dir, filename)
    print(f"Processing {key} from {filename}...")
    
    # Try different headers since Eurostat files vary
    # Usually header is around row 8-10 (index 7-9) if "Data extracted..." is at top
    # Or strict logic: look for row containing "TIME" or "2019"
    
    # Read first 15 rows to find header
    try:
        preview = pd.read_excel(path, header=None, nrows=15)
    except Exception as e:
        print(f"FAILED to read {filename}: {e}")
        return None

    header_row = None
    for i, row in preview.iterrows():
        row_str = row.astype(str).values
        if "2023" in row_str or "2022" in row_str or "TIME" in row_str:
            header_row = i
            break
            
    if header_row is None:
        print(f"  Could not detect header for {filename}")
        return None
        
    # Read with correct header
    df = pd.read_excel(path, header=header_row)
    
    # Find Country Column (usually first)
    col_country = df.columns[0]
    
    # Find Year Columns
    # We want 2023 primarily, but impute if missing
    # identifying columns that look like years
    year_map = {}
    for c in df.columns:
        c_str = str(c).strip()
        if c_str in ['2023', '2022', '2021', '2020', '2019']:
            year_map[c_str] = c
            
    if not year_map:
        print(f"  No year columns found for {filename}")
        return None
        
    # Extract relevant data
    # Create copy with standard names
    df_clean = df[[col_country] + list(year_map.values())].copy()
    
    # Rename columns
    renames = {v: k for k, v in year_map.items()}
    renames[col_country] = "Tara"
    df_clean.rename(columns=renames, inplace=True)
    
    # Clean Country
    df_clean["Tara"] = df_clean["Tara"].apply(clean_country_name)
    df_clean = df_clean[df_clean["Tara"] != "GEO"] # Metadata often has GEO (Labels)
    df_clean = df_clean[df_clean["Tara"] != "nan"]
    
    # Convert numbers
    for y in year_map.keys():
        df_clean[y] = pd.to_numeric(df_clean[y], errors='coerce')
        
    # Impute Logic: 2023 <- 2022 <- 2021...
    df_clean["Value"] = df_clean.get("2023", pd.Series([None]*len(df_clean)))
    
    # Cascade fill
    order = ["2023", "2022", "2021", "2020", "2019"]
    for i in range(len(order)-1):
        curr = order[i]
        nxt = order[i+1]
        if curr in df_clean.columns and nxt in df_clean.columns:
             df_clean["Value"] = df_clean["Value"].fillna(df_clean[nxt])
             
    # Final check
    # Keep only Tara + Value (renamed to 2023 for R compat)
    final_df = df_clean[["Tara", "Value"]].copy()
    final_df.rename(columns={"Value": "2023"}, inplace=True)
    
    # Drop NaNs
    final_df.dropna(subset=["2023"], inplace=True)
    final_df.drop_duplicates(subset=["Tara"], inplace=True)
    
    return final_df

# 1. LOAD ALL
for key, fname in files_map.items():
    df = read_and_extract(key, fname)
    if df is not None:
        data_frames[key] = df

# 2. INTERSECTION
# Start with set of countries from first dataset
if not data_frames:
    print("No dataframes loaded!")
    exit()

keys = list(data_frames.keys())
common_countries = set(data_frames[keys[0]]["Tara"])

for k in keys[1:]:
    countries = set(data_frames[k]["Tara"])
    common_countries = common_countries.intersection(countries)

common_countries = sorted(list(common_countries))
print(f"\nFound {len(common_countries)} common countries with good data across ALL datasets.")
print(common_countries)

# 3. FILTER AND SAVE
if not os.path.exists(clean_dir):
    os.makedirs(clean_dir)

for k, df in data_frames.items():
    # Filter only common countries using merge/inner join logic effectively
    # Or purely boolean indexing
    df_filtered = df[df["Tara"].isin(common_countries)].copy()
    
    # Sort alphabetically
    df_filtered.sort_values("Tara", inplace=True)
    
    # Save
    out_name = f"{k}_cleaned.xlsx"
    out_path = os.path.join(clean_dir, out_name)
    df_filtered.to_excel(out_path, index=False)
    print(f"Saved {out_name} with {len(df_filtered)} rows.")
