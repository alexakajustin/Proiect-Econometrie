import json
import re
import os
import pandas as pd

OUTPUT_DIR = "Proiect/Proiect/Output/Rapoarte"
JSON_PATH = f"{OUTPUT_DIR}/results.json"
TXT_PATH = f"{OUTPUT_DIR}/rezultate_modelare.txt"
STATS_PATH = f"{OUTPUT_DIR}/Statistici_Descriptive.csv"

def parse_lm_summary(text_block):
    """
    Parses a standard R lm() summary block to extract coefficients, R2, etc.
    """
    data = {"Coefficients": [], "R2": "N/A", "P_Value_F": "N/A"}
    
    # Extract Coefficients Table
    coef_pattern = r"(Estimate\s+Std\.\s+Error\s+t\s+value\s+Pr\ckpt\|t\|.*?)---"
    match = re.search(r"Coefficients:\s*\n(.*?)\n---", text_block, re.DOTALL)
    
    if match:
        lines = match.group(1).strip().split('\n')
        # Skip header
        for line in lines[1:]:
            parts = line.split()
            if len(parts) >= 5:
                # Name Estimate StdErr tVal PVal Stars
                # Combine parts for Name if it has spaces (rare in this dataset)
                # Assuming first element is var name
                var_name = parts[0]
                est = parts[1]
                p_val = parts[4]
                stars = parts[5] if len(parts) > 5 else ""
                
                data["Coefficients"].append({
                    "Variable": var_name,
                    "Estimate": est,
                    "P_Value": p_val,
                    "Significance": stars
                })

    # Extract R-squared
    r2_match = re.search(r"Multiple R-squared:\s+([\d\.]+)", text_block)
    if r2_match:
        data["R2"] = r2_match.group(1)

    # Extract F-statistic P-value
    f_match = re.search(r"p-value:\s+([<\d\.e\-]+)", text_block)
    if f_match:
        data["P_Value_F"] = f_match.group(1)
        
    return data

def parse_test(text_block, test_name):
    # Standard R test output: "W = 0.98, p-value = 0.04"
    p_match = re.search(r"p-value\s*[=<]\s*([\d\.e\-]+)", text_block)
    val_match = re.search(r"=\s*([\d\.]+),", text_block)
    
    return {
        "Test": test_name,
        "Statistic": val_match.group(1) if val_match else "N/A",
        "P_Value": p_match.group(1) if p_match else "N/A"
    }

def main():
    if not os.path.exists(TXT_PATH):
        print("No R output found.")
        return

    with open(TXT_PATH, "r", encoding="utf-8") as f:
        content = f.read()

    results = {}

    # 1. SIMPLE MODEL
    if "lm(formula = ln_Furturi ~ ln_Someri" in content:
        block = content.split("3. MODEL 2")[0]
        results["Model_Simplu"] = parse_lm_summary(block)

    # 2. MULTIPLE MODEL
    if "3. MODEL 2" in content:
        start = content.find("3. MODEL 2")
        end = content.find("7. MODEL 3")
        block = content[start:end]
        results["Model_Multiplu"] = parse_lm_summary(block)
        
        # Diagnostics
        results["Diagnostics"] = []
        if "Shapiro-Wilk" in block:
            sub = block.split("Shapiro-Wilk")[1].split("\n\n")[0]
            results["Diagnostics"].append(parse_test(sub, "Shapiro-Wilk"))
        if "Breusch-Pagan" in block:
            sub = block.split("Breusch-Pagan")[1].split("\n\n")[0]
            results["Diagnostics"].append(parse_test(sub, "Breusch-Pagan"))
        if "Durbin-Watson" in block:
             sub = block.split("Durbin-Watson")[1].split("\n\n")[0]
             results["Diagnostics"].append(parse_test(sub, "Durbin-Watson"))

    # 3. STEPWISE
    if "7. MODEL 3" in content:
        start = content.find("7. MODEL 3")
        block = content[start:]
        results["Model_Stepwise"] = parse_lm_summary(block)

    # 4. STATS Descriptive
    if os.path.exists(STATS_PATH):
        df = pd.read_csv(STATS_PATH)
        results["Stats"] = df.to_dict(orient="records")

    with open(JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2)
    
    print(f"JSON Generated: {JSON_PATH}")

if __name__ == "__main__":
    main()
