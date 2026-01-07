
import pandas as pd
import os

# Paths
input_file = r"c:\Users\Jastin\Desktop\Econometrie\Proiect-Econometrie\Proiect\Proiect\Data Used\expected_education_2019_2023.xlsx"
output_file = r"c:\Users\Jastin\Desktop\Econometrie\Proiect-Econometrie\Proiect\Proiect\Cleaned Data\education_cleaned.xlsx"
reference_file = r"c:\Users\Jastin\Desktop\Econometrie\Proiect-Econometrie\Proiect\Proiect\Cleaned Data\theft_cleaned.xlsx"

try:
    # 1. READ REFERENCE DATA
    print(f"Reading reference file for alignment: {reference_file}")
    df_ref = pd.read_excel(reference_file)
    ref_country_col = df_ref.columns[0]
    countries_ref = df_ref[ref_country_col].astype(str).str.strip().tolist()

    # 2. READ EDUCATION DATA
    print(f"Reading education file: {input_file}")
    df = pd.read_excel(input_file, header=8)
    
    # Identify Country column
    country_col = df.columns[0]
    
    # Identify Year Columns (2023, 2022, 2021...)
    # We want to prioritize 2023, but fill gaps with 2022, 2021 etc.
    cols_map = {}
    for col in df.columns:
        c_str = str(col).strip()
        if c_str in ['2023', '2022', '2021', '2020', '2019']:
            cols_map[c_str] = col
    
    print("Year columns found:", cols_map.keys())

    # Create a clean DF with all years of interest
    df_educ = df[[country_col] + list(cols_map.values())].copy()
    
    # Rename columns to standard Years
    rename_dict = {v: k for k, v in cols_map.items()}
    rename_dict[country_col] = 'Tara'
    df_educ = df_educ.rename(columns=rename_dict)

    # Clean Country Names
    df_educ['Tara'] = df_educ['Tara'].astype(str).str.strip()
    df_educ['Tara'] = df_educ['Tara'].str.replace(r' \(.*\)', '', regex=True)

    # Convert Values to Numeric
    for y in cols_map.keys():
        df_educ[y] = pd.to_numeric(df_educ[y], errors='coerce')

    # 3. IMPUTATION (Fill 2023 gaps with 2022, then 2021...)
    # Logic: If 2023 is NaN, take 2022. If 2022 is NaN, take 2021.
    df_educ['Final_Value'] = df_educ['2023']
    if '2022' in df_educ.columns:
        df_educ['Final_Value'] = df_educ['Final_Value'].fillna(df_educ['2022'])
    if '2021' in df_educ.columns:
        df_educ['Final_Value'] = df_educ['Final_Value'].fillna(df_educ['2021'])
    if '2019' in df_educ.columns:
         df_educ['Final_Value'] = df_educ['Final_Value'].fillna(df_educ['2019'])

    # 4. ALIGNMENT
    df_final = pd.DataFrame({'Tara': countries_ref})
    df_final = df_final.merge(df_educ[['Tara', 'Final_Value']], on='Tara', how='left')
    
    # Rename Final_Value to 2023 (as expected by R script for simplicity, or we can keep it generic)
    # The R script looks for column '2023' after pivot? 
    # Actually R script process_wide_data takes YEAR columns.
    # So we should output: Tara, 2023 (where 2023 contains the imputed latest value)
    df_final.columns = ['Tara', '2023']

    # Final Check for missing
    missing = df_final[df_final['2023'].isna()]
    if not missing.empty:
        print("CRITICAL WARNING: Still missing data for:", missing['Tara'].tolist())
    else:
        print("All countries have data (imputed if necessary).")

    # 5. SAVE
    df_final.to_excel(output_file, index=False)
    print(f"Successfully saved ALIGNED and IMPUTED data to {output_file}")
    print(df_final.head(10))

except Exception as e:
    print(f"Error: {e}")
