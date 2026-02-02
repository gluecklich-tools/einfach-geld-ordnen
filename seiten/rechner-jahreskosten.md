---
layout: default
title: Rechner Jahreskosten
permalink: /seiten/rechner-jahreskosten.html
---
# Rechner: Jahreskosten -> Monatsruecklage
Eintrag pro Zeile: <code>Name; Betrag; Intervall</code>
Intervall: <code>monat</code>, <code>quartal</code>, <code>halbjahr</code>, <code>jahr</code>
<textarea id="items" rows="10" style="width:100%;" placeholder="Kfz-Versicherung; 780; jahr
GEZ; 55.08; quartal
ADAC; 54; jahr
Wartung Heizung; 180; jahr"></textarea>
<p>
  <button id="calcBtn" type="button">Auswerten</button>
</p>
<div id="out" aria-live="polite"></div>
<script>
(function () {
  function esc(s){ return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
  function num(v){ var n = Number(String(v||'0').replace(',', '.')); return isFinite(n) ? n : NaN; }
  function fmtEUR(n){
    try { return new Intl.NumberFormat('de-DE', { style:'currency', currency:'EUR' }).format(n); }
    catch(e){ return (Math.round(n*100)/100).toFixed(2) + ' EUR'; }
  }
  function factor(interval){
    interval = (interval || 'jahr').toLowerCase();
    if (interval === 'monat') return 1;
    if (interval === 'quartal') return 3;
    if (interval === 'halbjahr') return 6;
    if (interval === 'jahr') return 12;
    return 12;
  }
  function parseLine(line){
    var parts = line.split(';').map(p => p.trim()).filter(Boolean);
    if (parts.length < 2) return null;
    var name = parts[0];
    var amount = num(parts[1]);
    var interval = parts[2] ? parts[2].toLowerCase() : 'jahr';
    if (!name || !isFinite(amount)) return null;
    var f = factor(interval);
    var monthly = amount / f;
    var yearly = monthly * 12;
    return { name:name, amount:amount, interval:interval, monthly:monthly, yearly:yearly };
  }
  var ta = document.getElementById('items');
  var btn = document.getElementById('calcBtn');
  var out = document.getElementById('out');
  btn.addEventListener('click', function(){
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
    rows.sort(function(a,b){ return b.monthly - a.monthly; });
    var sumM = rows.reduce((s,r)=>s+r.monthly,0);
    var sumY = rows.reduce((s,r)=>s+r.yearly,0);
    var html = '';
    html += '<p><strong>Monatsruecklage gesamt:</strong> ' + esc(fmtEUR(sumM)) + '</p>';
    html += '<p><strong>Jahressumme (hochgerechnet):</strong> ' + esc(fmtEUR(sumY)) + '</p>';
    html += '<h2>Liste (sortiert nach Monatslast)</h2>';
    html += '<ol>';
    rows.forEach(function(r){
      html += '<li><strong>' + esc(r.name) + '</strong> – ' + esc(fmtEUR(r.monthly)) + '/Monat (Intervall: ' + esc(r.interval) + ', Betrag: ' + esc(fmtEUR(r.amount)) + ')</li>';
    });
    html += '</ol>';
    out.innerHTML = html;
  });
})();
</script>

## Weiter
- [Jahreskosten Kalender]({{ site.baseurl }}/seiten/jahreskosten-kalender.html)
- [Download Hub Jahreskosten Kalender]({{ site.baseurl }}/seiten/download-hub-jahreskosten-kalender.html)
- [Index]({{ site.baseurl }}/index.html)
{% include no_sackgasse_footer.html %}
