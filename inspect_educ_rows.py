
import pandas as pd
file_path = r"c:\Users\Jastin\Desktop\Econometrie\Proiect-Econometrie\Proiect\Proiect\Data Used\expected_education_2019_2023.xlsx"
try:
    # Read without header
    df = pd.read_excel(file_path, header=None, skiprows=5, nrows=15)
    print(df)
except Exception as e:
    print(e)
