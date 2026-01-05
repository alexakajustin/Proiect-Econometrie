import pandas as pd
import os
import shutil

# Paths
data_path = r'c:\Users\Jaxtin\Desktop\Proiecte pentru vacanta\Econometrie(Next)\Proiect\Proiect\Data Used'
output_path = r'c:\Users\Jaxtin\Desktop\Proiecte pentru vacanta\Econometrie(Next)\Proiect\Proiect\Cleaned Data'

# Create output folder
os.makedirs(output_path, exist_ok=True)

# The 26 countries with complete data
good_countries = [
    'Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czechia', 
    'Denmark', 'Finland', 'Germany', 'Greece', 'Hungary', 'Iceland',
    'Ireland', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands',
    'Poland', 'Portugal', 'Romania', 'Slovakia', 'Slovenia', 'Spain',
    'Sweden', 'Switzerland'
]

files = {
    'unemployment_2019_2023.xlsx': 'unemployment',
    'gdp_per_capita_2019_2023.xlsx': 'gdp',
    'immigration_2019_2023.xlsx': 'immigration',
    'police_number_2019_2023.xlsx': 'police',
    'populatioin_density_2019_2023.xlsx': 'population_density',
    'theft_2019_2023.xlsx': 'theft'
}

print("=" * 70)
print("HARMONIZING DATA - KEEPING ONLY 26 COMPLETE COUNTRIES")
print("=" * 70)

for filename, name in files.items():
    filepath = os.path.join(data_path, filename)
    print(f"\n📄 Processing: {filename}")
    
    try:
        # Read raw to find header row
        df_raw = pd.read_excel(filepath, header=None)
        
        # Find header row (contains TIME or year)
        header_row = None
        for i, row in df_raw.iterrows():
            row_str = ' '.join([str(x) for x in row.values])
            if 'TIME' in row_str or '2019' in row_str:
                header_row = i
                break
        
        if header_row is None:
            print(f"   ⚠️  Could not find header row, skipping")
            continue
        
        # Read with proper header
        df = pd.read_excel(filepath, header=header_row)
        print(f"   Original rows: {len(df)}")
        
        # Find country column
        country_col = df.columns[0]
        
        # Filter to only good countries
        mask = df[country_col].astype(str).apply(
            lambda x: any(country.lower() == x.lower().strip() for country in good_countries)
        )
        df_filtered = df[mask].copy()
        
        print(f"   Filtered rows: {len(df_filtered)}")
        
        # Keep only year columns (2019-2023) plus country column
        year_cols = []
        for col in df.columns:
            col_str = str(col)
            if any(str(year) in col_str for year in [2019, 2020, 2021, 2022, 2023]):
                # Skip "Unnamed" columns (these are flag columns)
                if 'Unnamed' not in col_str:
                    year_cols.append(col)
        
        # If year_cols is empty, try different approach
        if not year_cols:
            year_cols = [c for c in df.columns[1:] if 'Unnamed' not in str(c)]
        
        # Create clean dataframe
        cols_to_keep = [country_col] + year_cols
        df_clean = df_filtered[cols_to_keep].copy()
        
        # Rename country column to 'Country'
        df_clean = df_clean.rename(columns={country_col: 'Country'})
        
        # Clean up column names (remove extra spaces)
        df_clean.columns = [str(c).strip() for c in df_clean.columns]
        
        # Sort by country name
        df_clean = df_clean.sort_values('Country').reset_index(drop=True)
        
        print(f"   Columns: {list(df_clean.columns)}")
        print(f"   Countries: {df_clean['Country'].tolist()}")
        
        # Save to new folder
        output_file = os.path.join(output_path, f"{name}_cleaned.xlsx")
        df_clean.to_excel(output_file, index=False)
        print(f"   ✅ Saved to: {name}_cleaned.xlsx")
        
    except Exception as e:
        print(f"   ❌ Error: {e}")
        import traceback
        traceback.print_exc()

print("\n" + "=" * 70)
print("✅ DONE! All cleaned files saved to:")
print(f"   {output_path}")
print("=" * 70)

# List the output files
print("\n📁 Output files:")
for f in os.listdir(output_path):
    size = os.path.getsize(os.path.join(output_path, f))
    print(f"   • {f} ({size:,} bytes)")
