---
layout: default
title: Rechner 50-30-20
permalink: /seiten/rechner-50-30-20.html
---
# Rechner: 50-30-20 (dein Budget-Rahmen)
Du gibst dein Netto pro Monat ein.
Der Rechner zeigt dir die drei Bereiche als Orientierung.
<label for="netto">Netto-Einkommen pro Monat (EUR)</label>
<input id="netto" type="number" min="0" step="1" inputmode="numeric" />
<p>
  <button id="calcBtn" type="button">Berechnen</button>
</p>
<div id="out" aria-live="polite"></div>
<script>
(function () {
  function esc(s){ return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
  function num(v){ var n = Number(String(v||'0').replace(',', '.')); return isFinite(n) ? n : 0; }
  function fmtEUR(n){
    try { return new Intl.NumberFormat('de-DE', { style:'currency', currency:'EUR' }).format(n); }
    catch(e){ return (Math.round(n*100)/100).toFixed(2) + ' EUR'; }
  }
  var netto = document.getElementById('netto');
  var btn = document.getElementById('calcBtn');
  var out = document.getElementById('out');
  btn.addEventListener('click', function(){
    var n = num(netto.value);
    if (n <= 0){
      out.innerHTML = '<p><strong>Bitte ein gueltiges Netto eingeben.</strong></p>';
      return;
    }
    var need = n * 0.50;
    var want = n * 0.30;
    var save = n * 0.20;
    var html = '';
    html += '<p><strong>50% Bedarf (Fixkosten):</strong> ' + esc(fmtEUR(need)) + '</p>';
    html += '<p><strong>30% Wunsch:</strong> ' + esc(fmtEUR(want)) + '</p>';
    html += '<p><strong>20% Sparen/Schulden:</strong> ' + esc(fmtEUR(save)) + '</p>';
    html += '<p>Hinweis: Wenn deine Fixkosten deutlich ueber 50% liegen, starte mit <em>Fixkosten senken</em> oder einer stabilen Ruecklage.</p>';
    out.innerHTML = html;
  });
})();
</script>
## Weiter
1. [Themen-Seite: 50-30-20 Regel]({{ site.baseurl }}/seiten/50-30-20-regel.html)
2. [Download-Hub: Vorlagen & Dateien]({{ site.baseurl }}/seiten/download-hub-50-30-20.html)
3. [Startseite]({{ site.baseurl }}/index.html)
{% include no_sackgasse_footer.html %}