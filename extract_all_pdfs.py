
import pypdf
import os
import glob

resurse_dir = r"c:\Users\Jaxtin\Desktop\Econometrie\Proiect-Econometrie\Resurse"
output_path = r"c:\Users\Jaxtin\Desktop\Econometrie\Proiect-Econometrie\all_course_content.txt"

pdf_files = glob.glob(os.path.join(resurse_dir, "*.pdf"))

with open(output_path, "w", encoding="utf-8") as outfile:
    for pdf_path in pdf_files:
        try:
            filename = os.path.basename(pdf_path)
            print(f"Processing {filename}...")
            outfile.write(f"--- START OF FILE: {filename} ---\n\n")
            
            reader = pypdf.PdfReader(pdf_path)
            for page in reader.pages:
                text = page.extract_text()
                if text:
                    outfile.write(text)
                outfile.write("\n\n")
            
            outfile.write(f"--- END OF FILE: {filename} ---\n\n")
            print(f"Finished {filename}")
        except Exception as e:
            print(f"Error processing {pdf_path}: {e}")
            outfile.write(f"--- ERROR PROCESSING FILE: {filename} ---\n\n")

print(f"All done! Content saved to {output_path}")
