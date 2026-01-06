from docx import Document
from docx.shared import Pt, Inches, Cm
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Pt, Inches, Cm, RGBColor
from lxml import etree
import csv
import os

OMML_NS = 'http://schemas.openxmlformats.org/officeDocument/2006/math'

def add_math_equation(paragraph):
    """Adaugă ecuația principală a modelului în format OMML."""
    omml_equation = f'''
    <m:oMath xmlns:m="{OMML_NS}">
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>Furturi</m:t></m:r></m:e><m:sub><m:r><m:t>i</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t> = </m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>β</m:t></m:r></m:e><m:sub><m:r><m:t>0</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t> + </m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>β</m:t></m:r></m:e><m:sub><m:r><m:t>1</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t>·</m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>PIB</m:t></m:r></m:e><m:sub><m:r><m:t>i</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t> + </m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>β</m:t></m:r></m:e><m:sub><m:r><m:t>2</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t>·</m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>Șomaj</m:t></m:r></m:e><m:sub><m:r><m:t>i</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t> + </m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>β</m:t></m:r></m:e><m:sub><m:r><m:t>3</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t>·</m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>Imigrație</m:t></m:r></m:e><m:sub><m:r><m:t>i</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t> + </m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>β</m:t></m:r></m:e><m:sub><m:r><m:t>4</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t>·</m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>Poliție</m:t></m:r></m:e><m:sub><m:r><m:t>i</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t> + </m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>β</m:t></m:r></m:e><m:sub><m:r><m:t>5</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t>·</m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>Densitate</m:t></m:r></m:e><m:sub><m:r><m:t>i</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t> + </m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>β</m:t></m:r></m:e><m:sub><m:r><m:t>6</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t>·</m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>Membru_UE</m:t></m:r></m:e><m:sub><m:r><m:t>i</m:t></m:r></m:sub></m:sSub>
        <m:r><m:t> + </m:t></m:r>
        <m:sSub><m:sSubPr><m:ctrlPr/></m:sSubPr><m:e><m:r><m:t>ε</m:t></m:r></m:e><m:sub><m:r><m:t>i</m:t></m:r></m:sub></m:sSub>
    </m:oMath>
    '''
    math_element = etree.fromstring(omml_equation)
    paragraph._p.append(math_element)

def add_hyperlink(paragraph, text, url):
    """Adaugă un hyperlink în paragraf."""
    part = paragraph.part
    r_id = part.relate_to(url, 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink', is_external=True)
    hyperlink = OxmlElement('w:hyperlink')
    hyperlink.set(qn('r:id'), r_id)
    new_run = OxmlElement('w:r')
    rPr = OxmlElement('w:rPr')
    c = OxmlElement('w:color')
    c.set(qn('w:val'), '0563C1')
    rPr.append(c)
    u = OxmlElement('w:u')
    u.set(qn('w:val'), 'single')
    rPr.append(u)
    new_run.append(rPr)
    t = OxmlElement('w:t')
    t.text = text
    new_run.append(t)
    hyperlink.append(new_run)
    paragraph._p.append(hyperlink)

def create_comprehensive_docx():
    doc = Document()
    
    # ======================= PAGINA DE TITLU =======================
    doc.add_heading('ACADEMIA DE STUDII ECONOMICE DIN BUCUREȘTI', 0).alignment = WD_ALIGN_PARAGRAPH.CENTER
    doc.add_paragraph('Facultatea de Cibernetică, Statistică și Informatică Economică').alignment = WD_ALIGN_PARAGRAPH.CENTER
    doc.add_paragraph('Specializarea Informatică Economică').alignment = WD_ALIGN_PARAGRAPH.CENTER
    doc.add_paragraph('\n\n\n')
    
    doc.add_heading('PROIECT ECONOMETRIE', 1).alignment = WD_ALIGN_PARAGRAPH.CENTER
    doc.add_paragraph('\n')
    
    title_p = doc.add_paragraph()
    title_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    title_run = title_p.add_run('Analiza Factorilor Determinanți ai Ratei Criminalității (Furturi) în 26 de Țări Europene')
    title_run.bold = True
    title_run.font.size = Pt(16)
    
    doc.add_paragraph('\n\n\n\n')
    doc.add_paragraph('Autori:').alignment = WD_ALIGN_PARAGRAPH.CENTER
    doc.add_paragraph('[Nume Student 1]').alignment = WD_ALIGN_PARAGRAPH.CENTER
    doc.add_paragraph('[Nume Student 2]').alignment = WD_ALIGN_PARAGRAPH.CENTER
    doc.add_paragraph('[Nume Student 3]').alignment = WD_ALIGN_PARAGRAPH.CENTER
    doc.add_paragraph('\n\n')
    doc.add_paragraph('Coordonator Științific: [Nume Profesor]').alignment = WD_ALIGN_PARAGRAPH.CENTER
    doc.add_paragraph('\n\n\n')
    doc.add_paragraph('București, 2025').alignment = WD_ALIGN_PARAGRAPH.CENTER
    
    doc.add_page_break()
    
    # ======================= CUPRINS =======================
    doc.add_heading('Cuprins', 1)
    cuprins = [
        "1. Fundamentarea Teoretică și Contextualizarea Aplicației",
        "   1.1. Introducere și Motivație",
        "   1.2. Stadiul Actual al Cunoașterii",
        "   1.3. Teoria Economică a Criminalității",
        "   1.4. Modelul Teoretic Propus",
        "2. Analiza Exploratorie a Datelor (EDA)",
        "   2.1. Descrierea Variabilelor",
        "   2.2. Statistici Descriptive",
        "   2.3. Analiza Grafică",
        "3. Modelare Econometrică Clasică",
        "4. Extensii și Prognoze",
        "5. Regularizare și Integrare Învățare Automată",
        "6. Discuții și Concluzii",
        "Bibliografie",
        "Anexe"
    ]
    for item in cuprins:
        doc.add_paragraph(item)
    
    doc.add_page_break()
    
    # ======================= 1. FUNDAMENTAREA TEORETICĂ =======================
    doc.add_heading('1. Fundamentarea Teoretică și Contextualizarea Aplicației', 1)
    
    # --- 1.1 Introducere ---
    doc.add_heading('1.1. Introducere și Motivație', 2)
    
    p1 = doc.add_paragraph()
    p1.add_run('Fenomenul criminalității reprezintă una dintre cele mai complexe probleme sociale și economice ale societăților moderne. ')
    p1.add_run('În contextul european, furturile constituie categoria dominantă de infracțiuni, cu implicații semnificative asupra securității cetățenilor, costurilor economice și calității vieții. ')
    p1.add_run('Conform statisticilor oficiale Eurostat (2024), în anul 2023 au fost înregistrate ')
    p1.add_run('5.387.857 de furturi').bold = True
    p1.add_run(' la nivelul Uniunii Europene, reprezentând o creștere de 4,8% față de anul precedent și 23,5% față de 2021.')
    
    p2 = doc.add_paragraph()
    p2.add_run('Prezenta lucrare își propune să analizeze empiric factorii determinanți ai ratei criminalității (măsurată prin numărul de furturi) în 26 de țări europene, ')
    p2.add_run('pe perioada 2019-2023. Analiza combină metodele econometrice clasice cu tehnici de învățare automată pentru a oferi o perspectivă integrată asupra fenomenului.')
    
    # --- 1.2 Literature Review ---
    doc.add_heading('1.2. Stadiul Actual al Cunoașterii', 2)
    
    doc.add_paragraph('Studiile recente din literatura de specialitate au investigat relația dintre factorii macroeconomici și rata criminalității, oferind perspective variate și uneori contradictorii:')
    
    # Studiu 1
    doc.add_heading('1.2.1. Relația dintre Șomaj și Criminalitate', 3)
    p_study1 = doc.add_paragraph()
    p_study1.add_run('Studiul lui Karpavičius et al. (2024) publicat în revista Economies (MDPI) a analizat șase țări din Europa Centrală și de Est (Lituania, Letonia, Estonia, Polonia, Cehia, Ungaria) folosind regresie panel cu efecte fixe. ')
    p_study1.add_run('Rezultatele au arătat că atât șomajul, cât și inegalitatea veniturilor cresc semnificativ rata criminalității').bold = True
    p_study1.add_run('. Studiul susține ipoteza "efectului de motivație" din teoria economică a criminalității.')
    
    ref1 = doc.add_paragraph()
    ref1.add_run('Sursa: ').italic = True
    add_hyperlink(ref1, 'Karpavičius, T. et al. (2024). What Determines the Crime Rate? A Macroeconomic Case Study. Economies, 12(9), 250.', 'https://doi.org/10.3390/economies12090250')
    
    # Studiu 2
    doc.add_heading('1.2.2. Legătura dintre Dezvoltarea Economică și Criminalitate', 3)
    p_study2 = doc.add_paragraph()
    p_study2.add_run('Remeikienė, Gaspariėnienė și Fedajev (2022) au clasificat țările UE pe baza ratelor criminalității și dezvoltării economice. ')
    p_study2.add_run('Studiul utilizează date panel pentru a examina corelația dintre PIB per capita, șomaj și diferite categorii de infracțiuni').bold = True
    p_study2.add_run('. Rezultatele arată că dezvoltarea economică are un efect complex asupra criminalității - poate reduce unele tipuri de infracțiuni prin scăderea sărăciei, dar poate crește altele prin crearea de oportunități.')
    
    ref2 = doc.add_paragraph()
    ref2.add_run('Sursa: ').italic = True
    add_hyperlink(ref2, 'Remeikienė, R., Gaspariėnienė, L., & Fedajev, A. (2022). Links between Crime and Economic Development: EU Classification. Equilibrium, 17(4).', 'https://doi.org/10.24136/eq.2022.031')
    
    # Studiu 3
    doc.add_heading('1.2.3. Șomajul și Activitățile Criminale în Europa Centrală și de Est', 3)
    p_study3 = doc.add_paragraph()
    p_study3.add_run('Lojanica și Obradović (2020) au analizat empiric relația dintre șomaj și criminalitate în economiile din Europa Centrală și de Est (CEE). ')
    p_study3.add_run('Folosind analiza datelor panel, studiul oferă dovezi pentru ipoteza "motivației" din teoria economică a criminalității, demonstrând că ').bold = True
    p_study3.add_run('creșterea șomajului duce la creșterea activităților criminale în regiune.')
    
    ref3 = doc.add_paragraph()
    ref3.add_run('Sursa: ').italic = True
    add_hyperlink(ref3, 'Lojanica, N. & Obradović, S. (2020). Does Unemployment Lead to Criminal Activities? European Journal of Applied Economics, 17(1).', 'https://doi.org/10.5937/ejae17-24756')
    
    # Studiu 4
    doc.add_heading('1.2.4. Imigrația și Criminalitatea', 3)
    p_study4 = doc.add_paragraph()
    p_study4.add_run('Contrar percepției publice, studiile empirice bazate pe date panel din Europa ')
    p_study4.add_run('nu găsesc o asociere pozitivă semnificativă').bold = True
    p_study4.add_run(' între imigrație și rata criminalității. ')
    p_study4.add_run('Un studiu amplu realizat de Institutul ifo (Germania) pe 215 regiuni europene a concluzionat că nu există o legătură cauzală între rata imigranților și nivelul criminalității. ')
    p_study4.add_run('O analiză a țărilor UE (1995-2016) a arătat că afluxul de refugiați nu a fost asociat statistic cu rate mai mari de infracțiuni contra proprietății.')
    
    ref4 = doc.add_paragraph()
    ref4.add_run('Surse: ').italic = True
    add_hyperlink(ref4, 'Gehrsitz, M. & Ungerer, M. (2022). Jobs, Crime and Votes: A Short-run Evaluation of the Refugee Crisis in Germany. Economica, 89(355), 592-626. DOI: 10.1111/ecca.12420', 'https://doi.org/10.1111/ecca.12420')
    
    # Studiu 5
    doc.add_heading('1.2.5. Statistici Recente Eurostat (2023)', 3)
    p_study5 = doc.add_paragraph()
    p_study5.add_run('Conform raportului Eurostat privind statisticile criminalității în Europa (2024), ')
    p_study5.add_run('în anul 2023:')
    
    stats = [
        "Au fost înregistrate 5.387.857 de furturi în UE (+4,8% față de 2022, +23,5% față de 2021)",
        "Numărul de jafuri a fost de 261.361 (+2,7% față de 2022, +13,2% față de 2021)",
        "Variațiile între țări sunt influențate de diferențele legislative, practicile de înregistrare și ratele de raportare"
    ]
    for stat in stats:
        doc.add_paragraph(stat, style='List Bullet')
    
    ref5 = doc.add_paragraph()
    ref5.add_run('Sursa: ').italic = True
    add_hyperlink(ref5, 'Eurostat - Crime Statistics 2023', 'https://ec.europa.eu/eurostat/statistics-explained/index.php?title=Crime_statistics')
    
    # --- 1.3 Teoria Economică ---
    doc.add_heading('1.3. Teoria Economică a Criminalității', 2)
    
    p_becker = doc.add_paragraph()
    p_becker.add_run('Fundamentul teoretic al prezentei analize îl constituie ')
    p_becker.add_run('teoria economică a criminalității').bold = True
    p_becker.add_run(' dezvoltată de Gary Becker (1968), laureat al Premiului Nobel pentru Economie. ')
    p_becker.add_run('Conform acestei teorii, indivizii sunt actori raționali care evaluează costurile și beneficiile comiterii unei infracțiuni:')
    
    becker_points = [
        "Beneficiile infracțiunii: câștigul material potențial din furt",
        "Costurile infracțiunii: probabilitatea de a fi prins (influențată de prezența poliției), severitatea pedepsei, costul de oportunitate (veniturile pierdute din activități legale)",
        "Decizia de a comite o infracțiune: individul compară utilitatea așteptată din infracțiune cu utilitatea din activități legale"
    ]
    for bp in becker_points:
        doc.add_paragraph(bp, style='List Bullet')
    
    p_ext = doc.add_paragraph()
    p_ext.add_run('Extinderi ale teoriei lui Becker au inclus factori precum: ')
    p_ext.add_run('inegalitatea veniturilor (Ehrlich, 1973), densitatea populației și urbanizarea (Glaeser & Sacerdote, 1999), ')
    p_ext.add_run('și impactul condițiilor macroeconomice asupra motivației criminale.')
    
    # --- 1.4 Modelul Teoretic ---
    doc.add_heading('1.4. Modelul Teoretic Propus', 2)
    
    doc.add_paragraph('Pe baza teoriei economice a criminalității și a literaturii de specialitate, propunem următorul model de regresie multiplă:')
    
    eq_p = doc.add_paragraph()
    eq_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_math_equation(eq_p)
    
    doc.add_paragraph('')
    doc.add_paragraph('Unde variabilele sunt definite astfel:')
    
    var_table = doc.add_table(rows=9, cols=3)
    var_table.style = 'Table Grid'
    headers = ['Variabilă', 'Definiție', 'Semn Așteptat']
    for i, header in enumerate(headers):
        var_table.rows[0].cells[i].text = header
        var_table.rows[0].cells[i].paragraphs[0].runs[0].bold = True
    
    variables = [
        ('Furturi_i', 'Număr de furturi raportate per 100.000 loc.', 'Var. Dependentă'),
        ('PIB_i', 'PIB per capita (€)', '+/– (ambiguu)'),
        ('Șomaj_i', 'Rata șomajului (%)', '+ (pozitiv)'),
        ('Imigrație_i', 'Număr de imigranți', '? (incert)'),
        ('Poliție_i', 'Nr. polițiști per 100.000 loc.', '– (negativ)'),
        ('Densitate_i', 'Densitatea populației (loc/km²)', '+ (pozitiv)'),
        ('Membru_UE_i', 'Variabilă binară (1=UE, 0=Non-UE)', '? (control)'),
        ('ε_i', 'Termenul de eroare stochastică', '–'),
    ]
    for row_idx, (var, defn, sign) in enumerate(variables, start=1):
        var_table.rows[row_idx].cells[0].text = var
        var_table.rows[row_idx].cells[1].text = defn
        var_table.rows[row_idx].cells[2].text = sign
    
    doc.add_paragraph('')
    
    # Ipotezele de cercetare
    doc.add_heading('1.4.1. Ipotezele de Cercetare', 3)
    hipoteze = [
        "H1: Rata șomajului are un efect pozitiv semnificativ asupra ratei furturilor (β₂ > 0)",
        "H2: Prezența poliției are un efect negativ semnificativ asupra ratei furturilor (β₄ < 0)",
        "H3: PIB-ul per capita are un efect ambiguu – poate reduce criminalitatea prin scăderea sărăciei sau o poate crește prin creșterea oportunităților de furt",
        "H4: Imigrația nu are un efect semnificativ asupra ratei furturilor (β₃ ≈ 0)",
        "H5: Densitatea populației crește rata furturilor datorită anonimatului urban (β₅ > 0)",
        "H6 (Binară): Statutul de membru UE poate influența rata criminalității prin libera circulație a bunurilor și persoanelor."
    ]
    for h in hipoteze:
        doc.add_paragraph(h, style='List Bullet')
    
    doc.add_paragraph('')
    doc.add_heading('1.4.2. Traducerea în Modele Empirice și Extinderi ML', 3)
    
    p_ml = doc.add_paragraph()
    p_ml.add_run('Modelul teoretic va fi estimat prin ')
    p_ml.add_run('Metoda celor mai mici pătrate (OLS)').bold = True
    p_ml.add_run(' pentru regresia multiplă, cu verificarea ipotezelor clasice (homoscedasticitate, normalitate, absența autocorelației, lipsa multicoliniarității). ')
    p_ml.add_run('Pentru îmbunătățirea capacității predictive, vor fi aplicate extensii precum:')
    
    ml_ext = [
        "Forme funcționale alternative: Log-Log, Log-Lin pentru interpretare elasticități",
        "Variabile binare și termeni de interacțiune pentru captarea efectelor nonliniare",
        "Tehnici de regularizare: Lasso, Ridge, Elastic Net pentru selecția variabilelor și reducerea supra-ajustării",
        "Comparație cu modele de învățare automată avansate: Random Forest, Gradient Boosting pentru analiză predictivă"
    ]
    for ext in ml_ext:
        doc.add_paragraph(ext, style='List Bullet')
    
    doc.add_page_break()
    
    # ======================= 2. ANALIZA EXPLORATORIE =======================
    doc.add_heading('2. Analiza Exploratorie a Datelor (EDA)', 1)
    doc.add_paragraph('În această secțiune prezentăm statistici descriptive și vizualizări relevante pentru variabilele analizate, obținute în urma prelucrării datelor.')

    # --- 2.1 Statistici Descriptive (Citire din CSV) ---
    stats_csv_path = r'c:\Users\Jastin\Desktop\Econometrie\Proiect-Econometrie\Proiect\Proiect\Output\Rapoarte\Statistici_Descriptive.csv'
    
    if os.path.exists(stats_csv_path):
        doc.add_heading('2.1. Statistici Descriptive', 2)
        try:
            with open(stats_csv_path, newline='') as csvfile:
                reader = csv.reader(csvfile)
                stats_data = list(reader)
            
            if len(stats_data) > 1:
                table = doc.add_table(rows=1, cols=7)
                table.style = 'Table Grid'
                hdr_cells = table.rows[0].cells
                headers = ['Variabila', 'Observații', 'Media', 'Dev. Std.', 'Min', 'Max', 'Asimetrie']
                for i, h in enumerate(headers):
                    hdr_cells[i].text = h
                    hdr_cells[i].paragraphs[0].runs[0].bold = True
                
                # Mapare nume variabile
                var_map = {
                    'Furturi': 'Furturi', 'PIB_per_capita': 'PIB/Capita', 
                    'Someri_Mii': 'Șomeri (Mii)', 'Imigratie': 'Imigrație', 
                    'Politie': 'Poliție', 'Densitate_Populatie': 'Densitate',
                    'ln_Furturi': 'Ln(Furturi)', 'ln_Someri': 'Ln(Șomeri)'
                }

                for row in stats_data[1:]: 
                    # CSV format: id, vars, n, mean, sd, median, trimmed, mad, min, max, range, skew...
                    # Indices: 0=?, 1=vars, 2=n, 3=mean, 4=sd, ..., 8=min, 9=max, ..., 11=skew
                    # Check row length safety
                    if len(row) > 11:
                        var_name = row[0] # Usually first col is row name in R write.csv if no row.names=FALSE
                        # But wait, looking at file output earlier: "vars" "n" ...
                        # Actually R write.csv puts row names in col 1 if not suppressed.
                        # Let's check previous file view. 
                        # Line 13: "   vars n mean..." -> Space separated in view, but it's CSV.
                        # Usually write.csv(x) -> "","vars","n"...
                        # So row[0] is likely the row name (e.g. "An", "Furturi").
                        var_name = row[0]
                        
                        if var_name in var_map:
                            cells = table.add_row().cells
                            cells[0].text = var_map[var_name]
                            cells[1].text = row[2] # n
                            try:
                                cells[2].text = f"{float(row[3]):.2f}" # mean
                                cells[3].text = f"{float(row[4]):.2f}" # sd
                                cells[4].text = f"{float(row[8]):.2f}" # min
                                cells[5].text = f"{float(row[9]):.2f}" # max
                                cells[6].text = f"{float(row[11]):.2f}" # skew
                            except ValueError:
                                pass # Handle header or non-numeric issues gracefully
        except Exception as e:
            doc.add_paragraph(f"[Eroare la citirea tabelului: {e}]")
    
    # --- 2.2 Grafice ---
    doc.add_heading('2.2. Analiza Grafică', 2)
    img_dir = r'c:\Users\Jastin\Desktop\Econometrie\Proiect-Econometrie\Proiect\Proiect\Output\Grafice'
    
    # 1. Histograma
    if os.path.exists(os.path.join(img_dir, 'Hist_Furturi.png')):
        doc.add_picture(os.path.join(img_dir, 'Hist_Furturi.png'), width=Inches(6))
        doc.add_paragraph('Figura 1: Distribuția Logaritmică a Furturilor.', style='Caption')
        doc.add_paragraph('Interpretare: Histograma variabilei dependente (transformată logaritmic) aproximează o distribuție normală (clopotul lui Gauss). Aceasta este o condiție esențială pentru validitatea testelor statistice în regresia OLS. Observăm că majoritatea țărilor se grupează în jurul mediei, fără asimetrii extreme care ar fi existat în datele brute.')
    
    # 2. Scatter Log-Log
    if os.path.exists(os.path.join(img_dir, 'Scatter_Log_Somaj_Furturi.png')):
        doc.add_picture(os.path.join(img_dir, 'Scatter_Log_Somaj_Furturi.png'), width=Inches(6))
        doc.add_paragraph('Figura 2: Relația de tip elasticitate între Șomaj și Furturi (Log-Log).', style='Caption')
        doc.add_paragraph('Interpretare: Graficul de dispersie log-log evidențiază o relație pozitivă clară între numărul de șomeri și numărul de furturi. Panta dreptei de regresie sugerează o elasticitate pozitivă: o creștere procentuală a șomajului este asociată cu o creștere procentuală a infracționalității. Utilizarea scării logaritmice a "armonizat" vizual datele, reducând influența disproporționată a țărilor mari (precum Germania sau Spania) și permițând observarea trendului general.')

    # 3. Corelatie
    if os.path.exists(os.path.join(img_dir, 'Plot_Corelatie.png')):
        doc.add_picture(os.path.join(img_dir, 'Plot_Corelatie.png'), width=Inches(6))
        doc.add_paragraph('Figura 3: Matricea de Corelație a variabilelor.', style='Caption')
        doc.add_paragraph('Interpretare: Matricea indică prezența multicoliniarității severe între variabilele independente cheie. Observăm coeficienți de corelație foarte ridicați (>0.8) între Imigrație, Poliție și Șomaj. Deși Furturile sunt corelate pozitiv cu acești factori (ceea ce așteptam), corelația puternică dintre predictori va face dificilă separarea efectului individual al fiecăruia în regresia simplă. Acest fapt justifică necesitatea utilizării tehnicilor de regularizare (Ridge/Lasso) propuse în capitolele următoare.')
    
    doc.add_heading('2.1. Descrierea Variabilelor și Surse de Date', 2)
    
    sources_table = doc.add_table(rows=7, cols=4)
    sources_table.style = 'Table Grid'
    source_headers = ['Variabilă', 'Unitate', 'Sursă', 'Perioadă']
    for i, h in enumerate(source_headers):
        sources_table.rows[0].cells[i].text = h
        sources_table.rows[0].cells[i].paragraphs[0].runs[0].bold = True
    
    source_data = [
        ('Furturi', 'Nr. infracțiuni', 'Eurostat', '2019-2023'),
        ('PIB per capita', 'EUR', 'Eurostat', '2019-2023'),
        ('Rata Șomajului', '%', 'Eurostat', '2019-2023'),
        ('Imigrație', 'Nr. persoane', 'Eurostat', '2019-2023'),
        ('Poliție', 'Nr. polițiști', 'Eurostat', '2019-2023'),
        ('Densitate Populație', 'loc/km²', 'Eurostat', '2019-2023'),
    ]
    for row_idx, (var, unit, src, period) in enumerate(source_data, start=1):
        sources_table.rows[row_idx].cells[0].text = var
        sources_table.rows[row_idx].cells[1].text = unit
        sources_table.rows[row_idx].cells[2].text = src
        sources_table.rows[row_idx].cells[3].text = period
    
    doc.add_paragraph('')
    doc.add_paragraph('Țări incluse în analiză (26): Austria, Belgia, Bulgaria, Croația, Cipru, Cehia, Danemarca, Finlanda, Germania, Grecia, Ungaria, Islanda, Irlanda, Letonia, Lituania, Luxemburg, Malta, Olanda, Polonia, Portugalia, România, Slovacia, Slovenia, Spania, Suedia, Elveția.')
    
    doc.add_page_break()
    
    # ======================= 3. MODELARE =======================
    doc.add_heading('3. Modelare Econometrică Clasică', 1)
    doc.add_paragraph('[Această secțiune va conține rezultatele estimării OLS, testele de semnificație, validarea ipotezelor și interpretarea coeficienților.]')
    
    doc.add_page_break()
    
    # ======================= 4. EXTENSII =======================
    doc.add_heading('4. Extensii și Prognoze', 1)
    doc.add_paragraph('[Forme funcționale alternative, variabile dummy, scenarii de prognoză.]')
    
    doc.add_page_break()
    
    # ======================= 5. ML =======================
    doc.add_heading('5. Regularizare și Integrare Învățare Automată', 1)
    doc.add_paragraph('[Rezultate Lasso, Ridge, Elastic Net. Comparație cu modele ML.]')
    
    doc.add_page_break()
    
    # ======================= 6. DISCUȚII =======================
    doc.add_heading('6. Discuții și Concluzii', 1)
    doc.add_paragraph('[Interpretarea rezultatelor în raport cu ipotezele, limitări ale studiului, direcții viitoare de cercetare.]')
    
    doc.add_page_break()
    
    # ======================= BIBLIOGRAFIE =======================
    doc.add_heading('Bibliografie', 1)
    
    references = [
        "Becker, G. S. (1968). Crime and Punishment: An Economic Approach. Journal of Political Economy, 76(2), 169-217.",
        "Ehrlich, I. (1973). Participation in Illegitimate Activities: A Theoretical and Empirical Investigation. Journal of Political Economy, 81(3), 521-565.",
        "Eurostat (2024). Crime Statistics - Police-recorded offences. Disponibil la: https://ec.europa.eu/eurostat/",
        "Glaeser, E. L., & Sacerdote, B. (1999). Why is There More Crime in Cities? Journal of Political Economy, 107(S6), S225-S258.",
        "ifo Institute (2023). Immigration and Crime: Evidence from German Panel Data. ifo Working Papers.",
        "College of Policing UK (2023). The impact of police numbers on crime. What Works Centre for Crime Reduction.",
        "World Bank (2023). Enterprise Surveys - Crime against Businesses. Washington, DC.",
    ]
    for ref in references:
        doc.add_paragraph(ref, style='List Bullet')
    
    doc.add_page_break()
    
    # ======================= ANEXE =======================
    doc.add_heading('Anexe', 1)
    doc.add_paragraph('[Codul R, grafice suplimentare, declarația privind utilizarea AI.]')
    
    # Salvare
    filename = 'Draft_Proiect_Econometrie.docx'
    doc.save(filename)
    print(f"Document creat: {filename}")

if __name__ == "__main__":
    create_comprehensive_docx()
