CERINȚE PROIECT ECONOMETRIE
DATA SCIENCE LAB. Powered by ASE
2025-2026
Facultatea de Cibernetică, Statistică și Informatică Economică
Specializarea Informatică Economică
APLICAȚIA 1
Modele de regresie pe date de tip transversal și introducere în analiza econometrică asistată de machine learning
Folosind date reale referitoare la variabile între care există o legătură logică din punctul de vedere al teoriei economice¹ se cere:
1. Fundamentarea teoretică și contextualizarea aplicației
a. Să se formalizeze contextul analizei pe baza teoriei economice, cu reliefarea stadiului actual al cunoașterii pentru problematica aleasă, prin raportare la cele mai recente 5-10 articole științifice (din ultimii 5 ani).
b. Se va evidenția modul în care relațiile teoretice pot fi traduse în modele empirice, precum și potențialele extinderi prin tehnici de analiză predictivă.
2. Analiza exploratorie a datelor
a. Se vor descrie variabilele identificate (definiții, unități de măsură, surse, periodicitate, metode de colectare).
b. Se vor efectua analize statistice descriptive și analize grafice privind distribuțiile și corelațiile dintre variabile.
c. Se vor documenta toate transformările aplicate datelor (deflaționare, logaritmare, tratarea valorilor lipsă etc.).
d. Setul de date va fi împărțit în set de antrenare (train) și set de testare (test), pentru a permite evaluarea comparativă a performanței modelelor econometrice în afara eșantionului.
e. Opțional, în completarea metodelor tradiționale, se pot aplica și tehnici exploratorii de tip machine learning, precum:
i. identificarea pattern-urilor și grupărilor prin clustering (K-Means, hierarchical clustering);
ii. reducerea dimensionalității prin PCA sau t-SNE;
iii. estimarea relațiilor non-liniare preliminare prin metode de regresie simplă cu kernel sau spline.
¹ Modelare la nivel macroeconomic (testarea empirică a curbei lui Phillips, a legii lui Okun, testarea empirică a curbei lui Laffer, determinanți ai sectorului public, impactul componentelor de mediu, sociale și de guvernanță asupra creșterii economice), folosirea datelor microeconomice din Eurobarometre pentru a dezvolta modele de impact la nivel micro (a se vedea site-ul GESIS), utilizarea obiectivelor de dezvoltare sustenabilă, a indicatorilor ESG la nivel suveran, a indicatorilor sustenabili de guvernanțe (SGI).
APLICAȚIA 1
Modele de regresie pe date de tip transversal și introducere în analiza econometrică asistată de machine learning
3. Modelare econometrică clasică
a. Se vor identifica principalii determinanți ai fenomenului analizat prin construirea de modele de regresie multiplă, cu interpretarea economică și econometrică a rezultatelor.
b. Se va testa validitatea modelului (semnificația parametrilor, indicatorii de bonitate, verificarea ipotezelor clasice, aplicarea corecțiilor necesare) și se va evidenția modelul optim pe baza criteriilor econometrice.
c. Se va evalua capacitatea predictivă în afara eșantionului pe setul de testare, folosind indicatori precum RMSE, MAE, MAPE sau R² ajustat.
4. Extinderea modelului și scenarii de prognoză
a. Se va îmbunătăți modelul prin adoptarea unei alte forme funcționale (log-log, polinomială) și prin adăugarea de variabile dummy și termeni de interacțiune.
b. Se vor reliefa beneficiile acestor transformări, iar pe modelul optim (validat anterior) se va construi un scenariu de prognoză, cu evidențierea ipotezelor de lucru.
5. Regularizare și integrarea tehnicilor ML
a. Se vor aplica tehnici de regularizare (Lasso, Ridge, Elastic Net) pe modelul multifactorial considerat.
b. Se vor realiza comparații între performanțele modelelor ML și cele ale modelului econometric optim (prin indicatori precum RMSE, MAE, R² ajustat).
c. Se vor discuta diferențele dintre modelele explicative (orientate pe interpretarea parametrilor) și modelele predictive (orientate pe acuratețea predicției).
d. Opțional, se pot explora și alte metode de regresie avansată (Random Forest, Gradient Boosting, SVR) pentru evidențierea diferențelor între abordările explicative și predictive.
6. Discuții și validarea rezultatelor
a. Se vor interpreta rezultatele în raport cu ipotezele inițiale și literatura de specialitate.
b. Se vor evidenția convergențele și discrepanțele între rezultatele econometrice și cele generate de metodele ML.
c. Se vor discuta limitările studiului (date, metode, bias) și se vor formula direcții pentru cercetări viitoare, inclusiv potențiale extinderi cu modele non-liniare sau de învățare automată.
APLICAȚIA 2
Modele cu date de tip panel
Să se dezvolte un model de regresie pe date de tip panel pentru analiza determinanților fenomenului ales, ce va respecta următoarele specificații tehnice:

Se va configura setul de date pentru un eșantion de unități și pentru un interval de timp, creându-se o structură cu date de tip panel adecvată fenomenului analizat.
Să se definească modelul și să se specifice variabilele cu precizarea transformărilor aduse.
Să se testeze alegerea tipului de model RE sau FE cu ajutorul testelor specifice.
Să se estimeze modelul adecvat obținut din analiza etapei 3. Opțional: se vor testa ipotezele pe reziduuri și se vor crea scenarii de prognoză.
Să se interpreteze rezultatele obținute din punct de vedere econometric și economic rezultatele cu testarea ipotezelor modelului, etc.
Să se creioneze o secțiune de discuții pe baza rezultatelor obținute cu validarea acestora cu literatura de specialitate: compararea cu ipotezele inițiale, semnificația rezultatelor, limitări ale studiului, sugestii pentru cercetări viitoare.

Toate aplicațiile se realizează în R!
PREZENTARE
Prezentarea proiectelor la Econometrie se va realiza sub formă de infografic, incluzând scheme logice comprehensive și următoarele secțiuni obligatorii:

Tema (titlul) proiectului și autorii: Includeți titlul proiectului, numele și prenumele autorilor, numele și prenumele conducătorului științific, și anul în care este susținut proiectul.
Introducere: Prezentați argumentele privind alegerea temei lucrării și modul concis de lucru.
Secțiune teoretică:


Literature review: Prezentarea stadiului cunoașterii în domeniu, sumarizând minim 5 articole de specialitate din ultimii 5 ani.
Metodologia cercetării: Descrierea metodologiei utilizate în studiul de caz.


Secțiune aplicativă:


Date utilizate: Descrierea datelor utilizate, modul lor de obținere și transformările aduse acestora.
Rezultatele empirice ale cercetării: Prezentarea, explicarea și interpretarea rezultatelor obținute.


Discuții: Compararea cu ipotezele inițiale, semnificația rezultatelor, limitările studiului, sugestii pentru cercetări viitoare.
Concluzii: Sumarizarea principalelor descoperiri și implicații ale lucrării.
Bibliografie: Utilizarea prioritara a bibliografiei de referință recente (ultimii cinci ani) și indicarea corectă a surselor conform sistemului de citare ales.
Anexe:


Includerea de ilustrații foto-video, grafice și alte elemente relevante pentru lucrare.
Semnarea Fișei de evaluare a proiectului, conform Metodologiei privind integrarea Inteligenței Artificiale în procesul de evaluare ce este anexată cerințelor.

ATENȚIE! Lucrarea este respinsă dacă:

sunt preluate cu copy-paste, fără citare, texte din literatura de specialitate sau de pe Internet;
lipsește contribuția personală (exemplu: preluarea integrală a unei investigații sau a unui studiu de caz realizat de altcineva);
lipsesc integral trimiterile la surse teoretice;
lipsește studiul de caz / investigația empirică / produsul / procedura de comunicare etc.;
lipsește bibliografia;
lipsesc indicările surselor pentru datele din studiul de caz.

PREZENTARE
Sugestii pentru surse de date:

Micro:

• Kaggle - https://www.kaggle.com/
• Data Sweep - https://www.datasweep.app/
• UCI Machine Learning Repository - https://archive.ics.uci.edu/
• Gesis - https://www.gesis.org/en/home

Macro:

• Worldbank - https://data.worldbank.org/
• Eurostat - https://ec.europa.eu/eurostat/data/database
• OECD - https://data.oecd.org/
• Theglobaleconomy - https://www.theglobaleconomy.com/
• INSSE - http://statistici.insse.ro:8077/tempo-online/
• IMF - https://www.imf.org/en/Data
• BNR - https://www.bnr.ro/Data-sets-3205-Mobile.aspx
• UN SDG - https://unstats.un.org/sdgs/dataportal
• SGI - https://www.sgi-network.org/2024/
Sugestii pentru aplicații prezentare:
• Canva – https://www.canva.com/
• Piktochart – https://piktochart.com/
• draw.io - https://app.diagrams.net/
• Napkin.ai - https://www.napkin.ai/
METODOLOGIE PRIVIND INTEGRAREA INTELIGENȚEI ARTIFICIALE ÎN PROCESUL DE EVALARE
1. Principii generale
Prezenta metodologie stabilește cadrul de utilizare responsabilă a tehnologiilor de inteligență artificială (AI) în activitățile de învățare, analiză și evaluare desfășurate în cadrul disciplinei Econometrie. Documentul urmărește alinierea procesului educațional la tendințele universitare internaționale, menținând totodată rigoarea academică și etica profesională specifice Academiei de Studii Economice din București.
Integrarea instrumentelor AI are ca scop sprijinirea procesului educațional, nu substituirea gândirii economice sau a raționamentului statistic. Prin urmare, utilizarea acestor instrumente este permisă cu condiția ca rezultatele să fie asumate critic, verificate empiric și interpretate economic de către studenți.
2. Declarația privind utilizarea instrumentelor AI
Fiecare echipă de studenți are obligația de a include, în fișierul de documentare tehnică, o declarație privind modul în care au fost utilizate instrumentele de inteligență artificială.
Model de declarație:
„Echipa confirmă că a utilizat instrumente de inteligență artificială în scop educațional, exclusiv pentru activități de sprijin, precum redactarea preliminară a codului, verificarea logicii modelelor econometrice, formularea explicațiilor metodologice sau îmbunătățirea clarității textului academic. Toate rezultatele obținute cu ajutorul AI au fost verificate, ajustate și interpretate critic de membrii echipei, care își asumă responsabilitatea integrală pentru validitatea și corectitudinea proiectului.”
Această declarație constituie o parte obligatorie a documentației proiectului și va fi analizată de cadrul didactic în momentul evaluării finale.
3. Documentarea utilizării AI
În scopul asigurării transparenței, fiecare echipă va completa un tabel anexat fișei de evaluare, în care va specifica instrumentele de inteligență artificială utilizate și versiunea acestora, conform Anexei 1. Acest tabel va fi semnat de membrii echipei și transmis împreună cu proiectul final, ca anexă oficială a proiectului.

Reflecția metodologică asupra utilizării AI

În vederea asigurării transparenței procesului de lucru, anexat fișei de evaluare, fiecare echipă va bifa activitățile pentru care au fost utilizate instrumente de inteligență artificială, conform listei din Anexa 1.

Reproducibilitate și trasabilitate

Pentru a garanta rigoarea metodologică, toate analizele econometrice trebuie să fie complet reproductibile în script R, fără pași manuali intermediați. Codul sursă trebuie comentat și explicat, iar toate transformările de date, estimările și testele statistice trebuie documentate clar.
În situațiile în care AI a fost folosită pentru generarea de cod, echipa este responsabilă să verifice funcționalitatea acestuia, să-l adapteze la cerințele proiectului și să demonstreze înțelegerea fiecărui pas. Profesorul poate solicita, în cadrul evaluării, demonstrarea practică a rulării codului și a interpretării rezultatelor.

Verificare individual

În cadrul sesiunii de prezentare a proiectului, fiecare membru al echipei va primi o întrebare individuală referitoare la partea de analiză la care a contribuit. Scopul acestei etape este confirmarea înțelegerii proprii și a implicării efective în elaborarea proiectului.
Întrebările vor urmări aspecte de tipul: alegerea variabilelor și modelelor, interpretarea coeficienților, verificarea ipotezelor econometrice sau justificarea deciziilor metodologice.

Criterii de evaluare

Rubrica de evaluare a proiectului include un criteriu suplimentar referitor la transparența și utilizarea responsabilă a AI. Acest criteriu vizează claritatea declarației, calitatea reflecției asupra modului de utilizare și capacitatea echipei de a explica rezultatele obținute.