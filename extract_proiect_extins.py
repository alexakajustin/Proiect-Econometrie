
import pypdf
import os

pdf_path = r"c:\Users\Jaxtin\Desktop\Econometrie\Proiect-Econometrie\Resurse\PROIECT_ECONOMETRIE_1084_Dumitriu_Ana_Maria_Dumitrescu_Teodora_Florea_Mihaela_Gabriela\ProiectExtins.pdf"
output_path = r"c:\Users\Jaxtin\Desktop\Econometrie\Proiect-Econometrie\Proiect\Proiect\Output\Rapoarte\ProiectExtins_Content.txt"

print(f"Versiune pypdf: {pypdf.__version__}")

try:
    reader = pypdf.PdfReader(pdf_path)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(f"--- CONTINUT EXTRAS DIN: {os.path.basename(pdf_path)} ---\n\n")
        for i, page in enumerate(reader.pages):
            text = page.extract_text()
            f.write(f"--- PAGINA {i+1} ---\n")
            f.write(text)
            f.write("\n\n")
    print(f"Succes! Text salvat in: {output_path}")
except Exception as e:
    print(f"Eroare: {e}")
