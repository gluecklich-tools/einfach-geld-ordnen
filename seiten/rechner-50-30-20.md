---
layout: default
title: Rechner 50-30-20
permalink: /seiten/rechner-50-30-20.html
---
# Rechner: 50/30/20 Budget (Aufteilung in 3 Toepfe)
Gib dein Netto-Einkommen ein. Der Rechner zeigt dir die Richtwerte fuer Bedarf, Wunsch und Zukunft.
<label for="netto">Netto-Einkommen pro Monat (EUR)</label>
<input id="netto" type="number" min="0" step="1" inputmode="numeric" />
<p>
  <button id="calcBtn" type="button">Berechnen</button>
</p>
<div id="out" aria-live="polite"></div>
<script>
(function () {
  function esc(s){ return String(s).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]); }); }
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
      out.innerHTML = '<p><strong>Bitte ein gueltiges Netto-Einkommen eingeben.</strong></p>';
      return;
    }
    var need = n * 0.50;
    var want = n * 0.30;
    var future = n * 0.20;
    var html = '';
    html += '<p><strong>Netto:</strong> ' + esc(fmtEUR(n)) + '</p>';
    html += '<table role="grid"><thead><tr><th>Topf</th><th style="text-align:right;">Richtwert</th></tr></thead><tbody>';
    html += '<tr><td>Bedarf (50%)</td><td style="text-align:right;">' + esc(fmtEUR(need)) + '</td></tr>';
    html += '<tr><td>Wunsch (30%)</td><td style="text-align:right;">' + esc(fmtEUR(want)) + '</td></tr>';
    html += '<tr><td>Zukunft (20%)</td><td style="text-align:right;">' + esc(fmtEUR(future)) + '</td></tr>';
    html += '</tbody></table>';
    html += '<p>Tipp: Wenn du Schulden oder keinen Notgroschen hast, senke "Wunsch" und erhoehe "Zukunft" voruebergehend.</p>';
    out.innerHTML = html;
  });
})();
</script>
## Weiter

- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
- [Rechner-uebersicht]({{ site.baseurl }}/seiten/rechner-uebersicht.html)
- [Projekt-uebersicht]({{ site.baseurl }}/pillar/index.html)

{% include no_sackgasse_footer.html %}






