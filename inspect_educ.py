
import pandas as pd
import os

file_path = r"c:\Users\Jastin\Desktop\Econometrie\Proiect-Econometrie\Proiect\Proiect\Data Used\expected_education_2019_2023.xlsx"

try:
    if not os.path.exists(file_path):
        print(f"File not found: {file_path}")
    else:
        df = pd.read_excel(file_path)
        print("Columns:", df.columns.tolist())
        print("First 5 rows:")
        print(df.head())
        # Check for year columns
        print("\nData Types:")
        print(df.dtypes)
except Exception as e:
    print(f"Error: {e}")
