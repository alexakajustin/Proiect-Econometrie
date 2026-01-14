
path = r"c:\Users\Jaxtin\Desktop\Econometrie\Proiect-Econometrie\all_course_content.txt"
with open(path, "r", encoding="utf-8") as f:
    for i, line in enumerate(f):
        if "START OF FILE" in line:
            print(f"{i}: {line.strip()}")
