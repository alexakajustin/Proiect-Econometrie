# Cerințe Proiect Econometrie (2025-2026)

**Instrument Necesar**: Limbajul R  
**Date**: Date reale referitoare la variabile între care există o legătură logică din punct de vedere economic.

## Aplicația 1: Modele de Regresie pe Date Transversale (Cross-Sectional) & Intro în ML
*Focus: Analiza datelor la un moment specific în timp (sau agregate).*

### 1. Fundamentarea Teoretică
- **Contextualizare**: Formalizarea contextului analizei pe baza teoriei economice.
- **Review-ul Literaturii**: Referințe la 5-10 articole științifice recente (ultimii 5 ani).
- **Modelare**: Explicarea modului în care relațiile teoretice sunt traduse în modele empirice.

### 2. Analiza Exploratorie a Datelor (EDA)
- **Descrierea Variabilelor**: Definiții, unități de măsură, surse, periodicitate, metode de colectare.
- **Statistici & Grafice**: Distribuții, corelații.
- **Transformări**: Documentarea tuturor transformărilor (deflaționare, logaritmare, tratare valori lipsă).
- **Împărțire (Split)**: Set de Antrenare (80%) / Set de Testare (20%) pentru validare.
- **Opțional ML**: Clustering (K-Means), PCA, t-SNE sau regresie Kernel.

### 3. Modelare Econometrică Clasică
- **Regresie Multiplă**: Identificarea determinanților, coeficienți, interpretare economică.
- **Validare**:
    - Semnificația parametrilor (testul t).
    - Indicatori de bonitate (R2, Adj R2).
    - **Testarea Ipotezelor**: Normalitate, Homoscedasticitate, Lipsa Autocorelării etc.
    - Aplicarea corecțiilor necesare.
- **Predicție**: Evaluarea performanței pe **Setul de Testare** (RMSE, MAE, MAPE).

### 4. Extensii & Prognoză
- **Forme Funcționale**: Îmbunătățirea modelului (Log-Log, Polinomial etc.).
- **Interacțiune/Dummy**: Adăugarea variabilelor dummy și termenilor de interacțiune.
- **Scenariu de Prognoză**: Crearea unui scenariu de prognoză folosind modelul optim.

### 5. Regularizare & Integrare ML
- **Regularizare**: Aplicare Lasso, Ridge, Elastic Net.
- **Comparație**: Compararea performanțelor modelelor ML vs. Modelul Econometric Optim (RMSE, MAE, R2).
- **Opțional**: ML Avansat (Random Forest, Gradient Boosting).

### 6. Discuții
- Compararea rezultatelor cu ipotezele inițiale și literatura.
- Discuția convergențelor/discrepanțelor dintre Econometrie și ML.

---

## Aplicația 2: Modele cu Date de Tip Panel
*Focus: Date pentru mai multe unități de-a lungul timpului.*

1. **Configurarea Datelor**: Structurarea datelor ca Panel (Unitate + Timp).
2. **Specificarea Modelului**: Definirea modelului și a transformărilor.
3. **Selecția Modelului**: Testare Efecte Fixe (FE) vs. Efecte Aleatoare (RE) (testul Hausman).
4. **Estimare**: Estimarea modelului adecvat.
   - *Opțional*: Testarea reziduurilor, scenarii de prognoză.
5. **Interpretare**: Interpretare econometrică și economică.
6. **Discuții**: Comparare cu literatura/ipoteze.

---

## Prezentarea Finală (Infografic/Structură)
Proiectul trebuie să includă scheme logice comprehensive și următoarele secțiuni obligatorii:
1. **Temă & Echipă**: Titlu, Autori, Coordonator, An.
2. **Introducere**: Motivație.
3. **Teorie**: Review literatură (min 5 articole, ultimii 5 ani), Metodologie.
4. **Secțiune Aplicativă**: Descrierea datelor, Rezultate empirice & interpretare.
5. **Discuții**: Comparații, limitări, cercetări viitoare.
6. **Concluzii**: Principalele descoperiri.
7. **Bibliografie**: Surse recente.
8. **Anexe**: Ilustrații, Declarația semnată privind AI.

## Politica de Utilizare AI
- **Permis**: Schelet de cod, debugging, idei de curățare, sugestii EDA, rafinare text.
- **Obligatoriu**:
    - **Verificarea** logicii și codului generat de AI.
    - **Declararea** utilizării într-un tabel specific (Anexa 1).
    - **Reproductibilitate**: Scriptul R trebuie să reproducă toate rezultatele fără pași manuali.
    - **Susținere**: Fiecare student va primi întrebări individuale pentru verificarea înțelegerii.
