import pandas as pd
import os

data_path = r'c:\Users\Jaxtin\Desktop\Proiecte pentru vacanta\Econometrie(Next)\Proiect\Proiect\Data Used'

files = {
    'unemployment': 'unemployment_2019_2023.xlsx',
    'gdp': 'gdp_per_capita_2019_2023.xlsx',
    'immigration': 'immigration_2019_2023.xlsx',
    'police': 'police_number_2019_2023.xlsx',
    'population_density': 'populatioin_density_2019_2023.xlsx',
    'theft': 'theft_2019_2023.xlsx'
}

# Known EU countries to look for
eu_countries = [
    'Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czechia', 'Denmark',
    'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland',
    'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands',
    'Poland', 'Portugal', 'Romania', 'Slovakia', 'Slovenia', 'Spain', 'Sweden',
    'Iceland', 'Norway', 'Switzerland', 'Liechtenstein', 'Montenegro', 'Serbia',
    'North Macedonia', 'Albania', 'Turkey', 'Türkiye', 'Bosnia and Herzegovina',
    'United Kingdom', 'Kosovo'
]

print("=" * 80)
print("ANALYZING ALL DATA FILES FOR COUNTRY COVERAGE")
print("=" * 80)

country_data = {c: {} for c in eu_countries}

for name, filename in files.items():
    filepath = os.path.join(data_path, filename)
    print(f"\n--- {name.upper()} ---")
    
    try:
        # Read raw to find where data starts
        df_raw = pd.read_excel(filepath, header=None)
        
        # Find the row with "TIME" or year headers (2019, 2020, etc)
        header_row = None
        for i, row in df_raw.iterrows():
            row_str = ' '.join([str(x) for x in row.values])
            if 'TIME' in row_str or '2019' in row_str:
                header_row = i
                break
        
        if header_row is None:
            print(f"  Could not find header row")
            continue
        
        # Read again with proper header
        df = pd.read_excel(filepath, header=header_row)
        print(f"  Header row: {header_row}")
        print(f"  Columns: {list(df.columns)[:8]}...")
        
        # Find country column
        country_col = None
        for col in df.columns:
            if 'GEO' in str(col) or 'TIME' in str(col):
                country_col = col
                break
        
        if country_col is None:
            country_col = df.columns[0]
        
        # Find year columns (2019-2023)
        year_cols = [c for c in df.columns if any(str(y) in str(c) for y in [2019, 2020, 2021, 2022, 2023])]
        print(f"  Year columns found: {year_cols}")
        
        # Check each country
        for country in eu_countries:
            # Find row for this country
            mask = df[country_col].astype(str).str.contains(country, case=False, na=False)
            if mask.any():
                row = df[mask].iloc[0]
                
                # Check if we have data for all years
                years_with_data = []
                for yc in year_cols:
                    val = row[yc]
                    # Check if it's a valid number (not NaN, not ':' which means missing)
                    if pd.notna(val) and str(val).strip() not in [':', '', 'nan', 'None']:
                        try:
                            float(str(val).replace(',', '.').replace(' ', ''))
                            years_with_data.append(yc)
                        except:
                            pass
                
                country_data[country][name] = {
                    'years': years_with_data,
                    'complete': len(years_with_data) >= 5
                }
    
    except Exception as e:
        print(f"  Error: {e}")
        import traceback
        traceback.print_exc()

print("\n" + "=" * 80)
print("COUNTRY DATA COMPLETENESS ANALYSIS")
print("=" * 80)

# Analyze results
complete_all = []
partial = []
missing_some = []

for country in eu_countries:
    datasets = country_data[country]
    
    if len(datasets) == 0:
        continue
    
    num_complete = sum(1 for d in datasets.values() if d['complete'])
    
    if len(datasets) == 6 and num_complete == 6:
        complete_all.append(country)
    elif len(datasets) >= 4:
        partial.append((country, len(datasets), num_complete))
    else:
        missing_some.append((country, len(datasets)))

print(f"\n✅ COUNTRIES WITH COMPLETE DATA IN ALL 6 FILES:")
print("-" * 60)
if complete_all:
    for c in sorted(complete_all):
        print(f"  ✓ {c}")
else:
    print("  (None found with 100% complete data)")

print(f"\n⚠️  COUNTRIES WITH DATA IN 4+ FILES (potentially usable):")
print("-" * 60)
for c, present, complete in sorted(partial, key=lambda x: (-x[2], -x[1])):
    datasets = country_data[c]
    missing = [k for k, v in datasets.items() if not v['complete']]
    print(f"  • {c}: {present}/6 files, {complete} complete")
    if missing:
        print(f"      Incomplete in: {', '.join(missing)}")

# Show detailed breakdown
print("\n" + "=" * 80)
print("DETAILED BREAKDOWN BY COUNTRY")
print("=" * 80)

for country in sorted(eu_countries):
    datasets = country_data[country]
    if len(datasets) == 0:
        continue
    
    all_files = ['unemployment', 'gdp', 'immigration', 'police', 'population_density', 'theft']
    status = []
    for f in all_files:
        if f in datasets:
            if datasets[f]['complete']:
                status.append('✓')
            else:
                status.append('~')
        else:
            status.append('✗')
    
    present = len(datasets)
    complete = sum(1 for d in datasets.values() if d['complete'])
    
    print(f"{country:25} | {'  '.join(status)} | {present}/6 files, {complete} complete")

print("\nLegend: ✓=Complete data  ~=Partial data  ✗=Missing")
print("Files order: unemployment, gdp, immigration, police, pop_density, theft")

# Final recommendation
print("\n" + "=" * 80)
print("🎯 FINAL RECOMMENDATION - BEST COUNTRIES TO USE:")
print("=" * 80)

# Countries with at least 5 files and mostly complete
usable = []
for country in eu_countries:
    datasets = country_data[country]
    if len(datasets) >= 5:
        complete = sum(1 for d in datasets.values() if d['complete'])
        if complete >= 4:
            usable.append(country)

if usable:
    print(f"\nCountries: {', '.join(sorted(usable))}")
    print(f"\nTotal: {len(usable)} countries")
    print(f"Years: 2019-2023 (5 years)")
    print(f"Potential observations: {len(usable)} × 5 = {len(usable) * 5}")
else:
    print("\nNo countries found with sufficient complete data.")
    print("You may need to:")
    print("  1. Use fewer variables (drop some datasets)")
    print("  2. Accept some missing values")
    print("  3. Use a shorter time period")
