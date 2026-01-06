
import pypdf
import os

pdf_path = r"c:\Users\Jastin\Desktop\Econometrie\Proiect-Econometrie\Resurse\cerinte econometrie 2025-2026.pdf"
output_path = "requirements_extracted.txt"

try:
    reader = pypdf.PdfReader(pdf_path)
    with open(output_path, "w", encoding="utf-8") as f:
        for page in reader.pages:
            f.write(page.extract_text())
            f.write("\n\n")
    print(f"Successfully extracted text to {output_path}")
except Exception as e:
    print(f"Error extracting PDF: {e}")
