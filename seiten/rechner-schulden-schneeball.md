---
layout: default
title: Rechner Schulden Schneeball
permalink: /seiten/rechner-schulden-schneeball.html
---
# Rechner: Schulden-Schneeball (einfach)
Dieser Rechner ist bewusst simpel: Du gibst **deine Schuldenliste** ein und bekommst eine **sortierte Reihenfolge** (kleinste Restschuld zuerst) plus ein Monatsbudget-Feld als Orientierung.
> Hinweis: Die exakte Laufzeit-Berechnung ist absichtlich nicht drin (sonst wird es schnell unuebersichtlich). Ziel von MVP02 ist der **Flow** + **Selbst-Serve**, nicht High-End-Finanzmathe.
## Eingabe
<label for="budget">Monatsbudget fuer Schuldentilgung (gesamt, optional)</label>
<input id="budget" type="number" min="0" step="1" inputmode="numeric" />
<h2>Schuldenliste</h2>
<p>Eintrag pro Zeile: <code>Name; Restbetrag; Mindestrate; Zins</code> (Zins optional).</p>
<textarea id="debts" rows="10" style="width:100%;" placeholder="Kreditkarte; 850; 35; 19.9
Handy; 240; 20
Ratenkauf; 1200; 60; 7.5"></textarea>
<p>
  <button id="calcBtn" type="button">Reihenfolge berechnen</button>
</p>
<h2>Ergebnis</h2>
<div id="out" aria-live="polite"></div>
<script>
(function () {
  function esc(s){ return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
  function parseLine(line) {
    var parts = line.split(';').map(p => p.trim()).filter(Boolean);
    if (parts.length < 3) return null;
    var name = parts[0];
    var rest = Number(String(parts[1]).replace(',', '.'));
    var min = Number(String(parts[2]).replace(',', '.'));
    var rate = (parts.length >= 4) ? Number(String(parts[3]).replace(',', '.')) : null;
    if (!name || !isFinite(rest) || !isFinite(min)) return null;
    return { name: name, rest: rest, min: min, rate: isFinite(rate) ? rate : null };
  }
  function formatEUR(n){
    try { return new Intl.NumberFormat('de-DE', { style:'currency', currency:'EUR' }).format(n); }
    catch(e){ return n.toFixed(2) + ' EUR'; }
  }
  var btn = document.getElementById('calcBtn');
  var ta  = document.getElementById('debts');
  var out = document.getElementById('out');
  var budget = document.getElementById('budget');
  btn.addEventListener('click', function () {
    var lines = ta.value.split(/\r?\n/).map(l => l.trim()).filter(Boolean);
    var rows = [];
    for (var i=0;i<lines.length;i++){
      var r = parseLine(lines[i]);
      if (r) rows.push(r);
    }
    if (!rows.length){
      out.innerHTML = '<p><strong>Keine gueltigen Zeilen gefunden.</strong></p>';
      return;
    }
    rows.sort(function(a,b){
      if (a.rest !== b.rest) return a.rest - b.rest;
      return a.min - b.min;
    });
    var b = Number(String(budget.value || '0').replace(',', '.'));
    var sumMin = rows.reduce((s,r)=>s+r.min,0);
    var extra = isFinite(b) && b>0 ? Math.max(0, b - sumMin) : null;
    var html = '';
    html += '<ol>';
    rows.forEach(function(r){
      html += '<li><strong>' + esc(r.name) + '</strong> – Rest: ' + esc(formatEUR(r.rest)) + ', Mindestrate: ' + esc(formatEUR(r.min));
      if (r.rate !== null) html += ', Zins: ' + esc(String(r.rate)) + '%';
      html += '</li>';
    });
    html += '</ol>';
    html += '<p><strong>Summe Mindestzahlungen:</strong> ' + esc(formatEUR(sumMin)) + '</p>';
    if (extra !== null){
      html += '<p><strong>Zusaetzlich fuer kleinste Schuld:</strong> ' + esc(formatEUR(extra)) + '</p>';
    }
    out.innerHTML = html;
  });
})();
</script>
## Weiter
1. [Themen-Seite: Schneeball erklaert]({{ site.baseurl }}/seiten/schuldenfrei-schneeball.html)
2. [Download-Hub: Vorlagen & Dateien]({{ site.baseurl }}/seiten/download-hub-schulden-schneeball.html)
3. [Startseite]({{ site.baseurl }}/index.html)
{% include no_sackgasse_footer.html %}