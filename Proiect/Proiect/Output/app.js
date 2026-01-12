mermaid.initialize({ startOnLoad: true });

// EMBEDDED DATA to avoid CORS/Fetch issues when opening locally
const projectData = {
  "Model_Simplu": {
    "Coefficients": [
      { "Variable": "(Intercept)", "Estimate": "6.0035", "P_Value": "3.05e-06", "Significance": "***" },
      { "Variable": "ln_Someri", "Estimate": "0.8450", "P_Value": "0.000134", "Significance": "***" }
    ],
    "R2": "0.322",
    "P_Value_F": "0.0001343"
  },
  "Model_Multiplu": {
    "Coefficients": [
      { "Variable": "(Intercept)", "Estimate": "-6.202", "P_Value": "0.170", "Significance": "" },
      { "Variable": "ln_PIB", "Estimate": "0.890", "P_Value": "0.030", "Significance": "*" },
      { "Variable": "ln_Someri", "Estimate": "0.663", "P_Value": "0.007", "Significance": "**" },
      { "Variable": "ln_Imigratie", "Estimate": "0.442", "P_Value": "0.042", "Significance": "*" },
      { "Variable": "ln_Densitate", "Estimate": "-0.206", "P_Value": "0.437", "Significance": "" },
      { "Variable": "Membru_UE", "Estimate": "0.016", "P_Value": "0.985", "Significance": "" }
    ],
    "R2": "0.5195",
    "P_Value_F": "9.197e-05",
    "Adj_R2": "0.4488"
  },
  "Diagnostics": [
    { "Test": "Shapiro-Wilk", "Statistic": "0.84", "P_Value": "6.69e-05" },
    { "Test": "Breusch-Pagan", "Statistic": "15.46", "P_Value": "0.0085" },
    { "Test": "Durbin-Watson", "Statistic": "2.10", "P_Value": "0.6039" }
  ],
  "Model_Stepwise": {
      "Coefficients": [
        { "Variable": "(Intercept)", "Estimate": "-6.4286", "P_Value": "0.10166", "Significance": "" },
        { "Variable": "ln_PIB", "Estimate": "0.8552", "P_Value": "0.02295", "Significance": "*" },
        { "Variable": "ln_Someri", "Estimate": "0.6395", "P_Value": "0.00675", "Significance": "**" },
        { "Variable": "ln_Imigratie", "Estimate": "0.4227", "P_Value": "0.04392", "Significance": "*" }
      ],
      "R2": "0.5098"
  },
  "ML_Comparison": {
      "OLS_RMSE": "0.58",
      "Ridge_RMSE": "0.84",
      "Lasso_RMSE": "0.66"
  }
};

// INITIALIZE STATS
if(projectData.Model_Stepwise) {
    document.getElementById('header-r2').innerText = parseFloat(projectData.Model_Stepwise.R2).toFixed(4);
}

// Image Paths (Relative to index.html location in Output folder)
// The format is "Grafice/Filename.png"
const IMAGES = {
    eda: ["Grafice/Hist_Grid_All.png", "Grafice/Boxplot_Outlieri.png", "Grafice/Plot_Corelatie.png"],
    model1: ["Grafice/Scatter_Log_Somaj_Furturi.png"],
    diag1: ["Grafice/Residuals_vs_Fitted.png"], 
    model2: [],
    diag2: ["Grafice/QQ_Plot_Reziduuri.png"],
    ml: ["Grafice/Lasso_Trace.png"]
};

// Node Content Generators
// RICH CONTENT extracted from the 18-page Proiect
const CONTENT = {
    // REFACTORED CONTENT: Focus on Raw Data Tables & Flowchart Steps
    start: () => `
        <div class="space-y-4">
             <div class="p-4 bg-slate-800 border border-slate-700 rounded shadow-sm">
                <h4 class="text-teal-400 font-bold border-b border-slate-600 pb-2 mb-2">1. Definirea Variabilelor</h4>
                <table class="data-table text-xs">
                    <thead><tr><th>Simbol</th><th>Descriere</th><th>Tip</th></tr></thead>
                    <tbody>
                        <tr><td class="font-mono text-yellow-300">ln_Furturi</td><td>Rata logaritmată a furturilor</td><td>Dependentă (Y)</td></tr>
                        <tr><td class="font-mono text-blue-300">ln_PIB</td><td>PIB per capita (log)</td><td>Independentă (X1)</td></tr>
                        <tr><td class="font-mono text-blue-300">ln_Someri</td><td>Număr șomeri (log)</td><td>Independentă (X2)</td></tr>
                        <tr><td class="font-mono text-blue-300">ln_Imigratie</td><td>Imigrație totală (log)</td><td>Independentă (X3)</td></tr>
                        <tr><td class="font-mono text-purple-300">Est_Vest</td><td>Dummy (1=Est, 0=Vest)</td><td>Dummy</td></tr>
                    </tbody>
                </table>
            </div>
            
            <div class="p-4 bg-slate-800 border border-slate-700 rounded shadow-sm">
                <h4 class="text-teal-400 font-bold border-b border-slate-600 pb-2 mb-2">2. Statistici Descriptive</h4>
                <div class="overflow-x-auto">
                    <table class="data-table text-xs whitespace-nowrap">
                        <thead>
                            <tr><th>Variabila</th><th>Mean</th><th>Std.Dev</th><th>Min</th><th>Max</th><th>Skewness</th><th>Kurtosis</th></tr>
                        </thead>
                        <tbody>
                            <tr><td class="font-bold">Furturi</td><td>158,862</td><td>298,632</td><td>245</td><td>1,359,102</td><td>2.90</td><td>7.75</td></tr>
                            <tr><td class="font-bold">PIB/cap</td><td>33,208</td><td>22,567</td><td>5,500</td><td>102,250</td><td>1.19</td><td>1.09</td></tr>
                            <tr><td class="font-bold">Someri</td><td>497</td><td>769</td><td>8</td><td>3,274</td><td>2.39</td><td>4.82</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    `,

    eda: () => `
         <div class="space-y-4">
            <h3 class="text-white font-bold border-l-4 border-teal-500 pl-3">Analiza Exploratorie a Datelor</h3>
            
            <!-- Tabs or Scroll Section for Images -->
            <div class="grid grid-cols-1 gap-4">
                <div class="bg-slate-800 p-2 rounded border border-slate-700">
                    <p class="text-xs text-center text-slate-400 mb-1">Histograme (Distribuția de Frecvență)</p>
                    <img src="${IMAGES.eda[0]}" class="w-full rounded opacity-90 hover:opacity-100 transition-opacity">
                </div>
                <div class="bg-slate-800 p-2 rounded border border-slate-700">
                     <p class="text-xs text-center text-slate-400 mb-1">Identificarea Valorilor Extreme (Outlieri)</p>
                    <img src="${IMAGES.eda[1]}" class="w-full rounded opacity-90 hover:opacity-100 transition-opacity">
                </div>
                 <div class="bg-slate-800 p-2 rounded border border-slate-700">
                     <p class="text-xs text-center text-slate-400 mb-1">Matricea de Corelație (Multicoliniaritate)</p>
                    <img src="${IMAGES.eda[2]}" class="w-full rounded opacity-90 hover:opacity-100 transition-opacity">
                </div>
            </div>
         </div>
    `,

    model1: () => {
        const m = projectData.Model_Simplu;
        if(!m) return "No Data";
        return `
             <div class="space-y-4">
                <div class="p-3 bg-slate-900 border-l-4 border-blue-500 rounded">
                    <h4 class="font-bold text-blue-400 text-sm">Model de Regresie Simplă</h4>
                    <p class="font-mono text-xs text-slate-300 mt-1">ln_Furturi = α + β * ln_Someri + ε</p>
                </div>

                <div class="bg-slate-800 rounded border border-slate-700 overflow-hidden">
                    <h4 class="bg-slate-700 px-4 py-2 text-xs font-bold uppercase text-slate-300">Estimarea Parametrilor (OLS)</h4>
                    ${renderCoefTable(m.Coefficients)}
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div class="bg-slate-800 p-3 rounded border border-slate-700 text-center">
                        <div class="text-xs text-slate-500 uppercase">R-Squared</div>
                        <div class="text-xl font-bold text-white">${parseFloat(m.R2).toFixed(4)}</div>
                    </div>
                     <div class="bg-slate-800 p-3 rounded border border-slate-700 text-center">
                        <div class="text-xs text-slate-500 uppercase">Prob(F-Statistic)</div>
                        <div class="text-xl font-bold text-green-400">${parseFloat(m.P_Value_F).toExponential(2)}</div>
                    </div>
                </div>

                <div class="bg-slate-800 p-2 rounded border border-slate-700">
                     <p class="text-xs text-center text-slate-400 mb-1">Scatter Plot cu Dreapta de Regresie</p>
                     <img src="${IMAGES.model1[0]}" class="w-full rounded border border-slate-600">
                </div>
            </div>
        `;
    },

    diag1: () => `
        <div class="space-y-4">
             <div class="p-3 bg-slate-900 border-l-4 border-purple-500 rounded">
                <h4 class="font-bold text-purple-400 text-sm">Diagnosticare Model Simplu</h4>
                <p class="text-xs text-slate-400 mt-1">Verificarea ipotezelor Gauss-Markov</p>
            </div>
            ${renderDiagnostics(["Homosced_BP", "Heterosced_White", "Autocorr_DW"])}
            <div class="bg-slate-800 p-2 rounded border border-slate-700">
                 <p class="text-xs text-center text-slate-400 mb-1">Plot Reziduuri vs Valori Ajustate</p>
                 <img src="${IMAGES.diag1[0]}" class="w-full rounded border border-slate-600">
            </div>
        </div>
    `,

    model2: () => {
         const m = projectData.Model_Multiplu;
         if(!m) return "No Data";
         return `
             <div class="space-y-4">
                <div class="p-3 bg-slate-900 border-l-4 border-blue-500 rounded">
                    <h4 class="font-bold text-blue-400 text-sm">Model de Regresie Multiplă</h4>
                    <p class="font-mono text-xs text-slate-300 mt-1">Y = β0 + β1*PIB + β2*Somaj + β3*Imig + β4*Dens + β5*Est + ε</p>
                </div>

                <div class="bg-slate-800 rounded border border-slate-700 overflow-hidden">
                    <h4 class="bg-slate-700 px-4 py-2 text-xs font-bold uppercase text-slate-300">Estimarea Parametrilor</h4>
                    ${renderCoefTable(m.Coefficients)}
                </div>
                
                 <div class="bg-slate-800 rounded border border-slate-700 overflow-hidden">
                    <h4 class="bg-slate-700 px-4 py-2 text-xs font-bold uppercase text-slate-300">Testarea Ipotezelor</h4>
                    <table class="data-table text-xs">
                         <thead><tr><th>Ipoteza</th><th>Semn Așteptat</th><th>p-value</th><th>Decizie</th></tr></thead>
                         <tbody>
                            <tr><td>Somaj</td><td class="text-center font-bold text-green-400">+</td><td>0.007</td><td><span class="badge-pass">Acceptat</span></td></tr>
                            <tr><td>PIB</td><td class="text-center font-bold text-red-400">-</td><td>0.030</td><td><span class="badge-fail">Respins (Coeff>0)</span></td></tr>
                            <tr><td>Imigratie</td><td class="text-center font-bold text-green-400">+</td><td>0.042</td><td><span class="badge-pass">Acceptat</span></td></tr>
                            <tr><td>Est_Vest</td><td class="text-center font-bold text-green-400">+</td><td>0.015</td><td><span class="badge-pass">Acceptat</span></td></tr>
                         </tbody>
                    </table>
                </div>

                 <div class="grid grid-cols-2 gap-2">
                    <div class="bg-slate-800 p-2 rounded border border-slate-700">
                        <span class="block text-xs text-slate-500">R-Squared Adjusted</span>
                        <span class="font-mono font-bold text-white">${parseFloat(m.Adj_R2).toFixed(4)}</span>
                    </div>
                     <div class="bg-slate-800 p-2 rounded border border-slate-700">
                        <span class="block text-xs text-slate-500">F-Statistic P-Val</span>
                        <span class="font-mono font-bold text-green-400">${parseFloat(m.P_Value_F).toExponential(2)}</span>
                    </div>
                </div>
            </div>
         `;
    },

    step: () => {
         const m = projectData.Model_Stepwise;
         return `
            <div class="space-y-4">
                <div class="p-3 bg-slate-900 border-l-4 border-yellow-500 rounded">
                    <h4 class="font-bold text-yellow-400 text-sm">Model Optimizat (Algoritm Stepwise)</h4>
                    <p class="text-xs text-slate-300 mt-1">Eliminare regresivă bazată pe criteriul informațional Akaike (AIC).</p>
                </div>
                 <div class="bg-slate-800 rounded border border-slate-700 overflow-hidden">
                    <h4 class="bg-slate-700 px-4 py-2 text-xs font-bold uppercase text-slate-300">Rezultate Finale</h4>
                    ${renderCoefTable(m.Coefficients)}
                </div>
            </div>
         `;
    },

    diag2: () => `
        <div class="space-y-4">
             <div class="p-3 bg-slate-900 border-l-4 border-purple-500 rounded">
                <h4 class="font-bold text-purple-400 text-sm">Diagnosticare Model Final</h4>
                <p class="text-xs text-slate-400 mt-1">Normalitatea reziduurilor si multicoliniaritate</p>
            </div>
            ${renderDiagnostics(["Normality_JB", "Normality_SW"])}
             <div class="bg-slate-800 p-2 rounded border border-slate-700">
                 <p class="text-xs text-center text-slate-400 mb-1">Q-Q Plot Reziduuri</p>
                 <img src="${IMAGES.diag2[0]}" class="w-full rounded border border-slate-600">
            </div>
        </div>
    `,

    ml: () => `
        <div class="space-y-4">
             <div class="p-3 bg-slate-900 border-l-4 border-indigo-500 rounded">
                <h4 class="font-bold text-indigo-400 text-sm">Machine Learning (Regularizare)</h4>
                <p class="text-xs text-slate-400 mt-1">Ridge vs Lasso vs OLS - Validare Încrucișată</p>
            </div>
            
            <table class="data-table text-xs">
                <thead><tr class="bg-slate-700"><th>Model</th><th>Metoda</th><th>RMSE (Test)</th></tr></thead>
                <tbody>
                    <tr><td class="font-bold">OLS</td><td>Ordinary Least Squares</td><td>${parseFloat(projectData.ML_Comparison.OLS_RMSE).toFixed(4)}</td></tr>
                    <tr><td class="font-bold text-blue-400">Ridge</td><td>L2 Penalization</td><td>${parseFloat(projectData.ML_Comparison.Ridge_RMSE).toFixed(4)}</td></tr>
                    <tr><td class="font-bold text-purple-400">Lasso</td><td>L1 Penalization</td><td>${parseFloat(projectData.ML_Comparison.Lasso_RMSE).toFixed(4)}</td></tr>
                </tbody>
            </table>

            <div class="bg-slate-800 p-2 rounded border border-slate-700">
                 <p class="text-xs text-center text-slate-400 mb-1">Lasso Coefficient Paths</p>
                 <img src="${IMAGES.ml[0]}" class="w-full rounded border border-slate-600">
            </div>
        </div>
    `,

    panel: () => `
        <div class="space-y-4">
             <div class="p-3 bg-slate-900 border-l-4 border-teal-500 rounded">
                <h4 class="font-bold text-teal-400 text-sm">Analiza Panel Data (Longitudinală)</h4>
                <p class="text-xs text-slate-400 mt-1">40 Țări x 5 Ani (200 Observații)</p>
            </div>

            <div class="grid grid-cols-2 gap-2">
                <div class="bg-slate-800 p-3 rounded border border-slate-700">
                    <div class="text-xs text-slate-500 mb-1">Testul Hausman</div>
                    <div class="font-bold text-white text-sm">H0: Random Effects</div>
                    <div class="font-mono text-green-400 font-bold mt-1">p < 0.05</div>
                    <div class="text-[10px] text-slate-400 mt-1 bg-slate-900 p-1 rounded">Decizie: Fixed Effects</div>
                </div>
                 <div class="bg-slate-800 p-3 rounded border border-slate-700">
                    <div class="text-xs text-slate-500 mb-1">Test Pasaran CD</div>
                    <div class="font-bold text-white text-sm">Dependență Transv.</div>
                    <div class="font-mono text-green-400 font-bold mt-1">p < 0.05</div>
                    <div class="text-[10px] text-slate-400 mt-1 bg-slate-900 p-1 rounded">Există dependență</div>
                </div>
            </div>
             
             <div class="p-3 bg-slate-800 rounded border border-slate-700">
                <h4 class="text-xs font-bold text-slate-400 uppercase mb-2">Interpretare Fixed Effects</h4>
                <p class="text-xs text-slate-300">
                    Modelul Fixed Effects controlează pentru caracteristicile unice ale fiecărei țări (cultură, legislație) care nu se schimbă în timp. 
                    Rezultatele confirmă că șomajul rămâne un predictor semnificativ chiar și după controlul efectelor fixe.
                </p>
             </div>
        </div>
    `,
    
    final: () => `
        <div class="text-center space-y-6 pt-10">
             <h3 class="text-2xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-teal-400 to-blue-500">Concluzii Finale</h3>
             
             <div class="grid grid-cols-1 gap-4 text-left">
                <div class="p-4 bg-slate-800 border border-slate-700 rounded shadow-lg transform hover:scale-105 transition-transform">
                    <h4 class="text-teal-400 font-bold mb-1">1. Factorul Economic Determinant</h4>
                    <p class="text-sm text-slate-300">Rata Șomajului este variabila cu cel mai mare impact pozitiv asupra furturilor.</p>
                </div>
                 <div class="p-4 bg-slate-800 border border-slate-700 rounded shadow-lg transform hover:scale-105 transition-transform">
                    <h4 class="text-purple-400 font-bold mb-1">2. Discrepanțe Regionale</h4>
                    <p class="text-sm text-slate-300">Există diferențe structurale semnificative între țările din Estul și Vestul Europei.</p>
                </div>
                 <div class="p-4 bg-slate-800 border border-slate-700 rounded shadow-lg transform hover:scale-105 transition-transform">
                    <h4 class="text-blue-400 font-bold mb-1">3. Robustetia Modelelor</h4>
                    <p class="text-sm text-slate-300">Rezultatele sunt consistente atât în modelul OLS, cât și în cel Panel Data și Machine Learning (Lasso).</p>
                </div>
             </div>
        </div>
    `
};

// Utils
function renderCoefTable(coefs) {
    if(!coefs) return "";
    let rows = coefs.map(c => `
        <tr>
            <td class="font-mono text-teal-300">${c.Variable}</td>
            <td>${parseFloat(c.Estimate).toFixed(4)}</td>
            <td>${renderPval(c.P_Value)}</td>
        </tr>
    `).join('');
    
    return `
        <table class="data-table bg-slate-800 rounded overflow-hidden">
            <thead>
                <tr class="bg-slate-700">
                    <th>Variabila</th>
                    <th>Coeficient</th>
                    <th>P-Value</th>
                </tr>
            </thead>
            <tbody>${rows}</tbody>
        </table>
    `;
}

function renderDiagnostics(keys) {
    if(!projectData.Diagnostics) return "No Diagnostics";
    let html = '<div class="space-y-4">';
    
    // Manual mapping for demo content since dynamic find might fail on some keys
    // Hardcoded check for robustness in this embedded version
    projectData.Diagnostics.forEach(d => {
        let pass = parseFloat(d.P_Value) > 0.05;
        // Durbin Watson special handling: Around 2 is good
        if(d.Test === "Durbin-Watson") {
            pass = Math.abs(parseFloat(d.Statistic) - 2.0) < 0.5;
        }
        else if(d.Test === "Shapiro-Wilk") {
            pass = parseFloat(d.P_Value) > 0.05; // Normal if > 0.05
        }
        else {
             pass = parseFloat(d.P_Value) > 0.05; // Homoscedastic if > 0.05
        }

        html += `
            <div class="p-3 bg-slate-700/50 rounded flex justify-between items-center">
                <div>
                    <div class="font-bold text-sm">${d.Test}</div>
                    <div class="text-xs text-slate-400">Statistic: ${parseFloat(d.Statistic).toFixed(2)}</div>
                </div>
                <div class="text-right">
                        <div class="font-mono ${pass ? 'text-green-400' : 'text-red-400'} font-bold">
                        p = ${parseFloat(d.P_Value).toExponential(2)}
                        </div>
                        <div class="text-[10px] uppercase tracking-wide opacity-50">${d.Test === 'Shapiro-Wilk' ? (pass ? 'Normal' : 'Non-Normal') : (pass ? 'Pass' : 'Fail')}</div>
                </div>
            </div>
        `;
    });
    return html + '</div>';
}

function renderPval(val) {
    let v = parseFloat(val);
    if(v < 0.001) return '<span class="text-green-400 font-bold">< 0.001 ***</span>';
    if(v < 0.01) return '<span class="text-green-300 font-bold">< 0.01 **</span>';
    if(v < 0.05) return '<span class="text-green-200 font-bold">< 0.05 *</span>';
    return `<span class="text-slate-500">${v.toFixed(4)}</span>`;
}

// Global Render Function called by Mermaid
window.renderNode = function(nodeId) {
    console.log("Clicked:", nodeId);
    const panel = document.getElementById('detail-panel');
    const title = document.getElementById('panel-title');
    const content = document.getElementById('panel-content');
    
    // Open Panel
    panel.classList.remove('translate-x-full');
    
    // Set Content
    title.innerText = nodeId.toUpperCase();
    if(CONTENT[nodeId]) {
        content.innerHTML = CONTENT[nodeId]();
    } else {
        content.innerHTML = `<p>Content for ${nodeId} coming soon...</p>`;
    }
}

window.closePanel = function() {
    document.getElementById('detail-panel').classList.add('translate-x-full');
}
