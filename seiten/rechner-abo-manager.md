---
layout: default
title: Rechner Abo-Manager
permalink: /seiten/rechner-abo-manager.html
---
# Rechner: Abo-Manager (Summe pro Monat/Jahr)
Eintrag pro Zeile: <code>Name; Betrag; Intervall</code>
Intervall: <code>monat</code> oder <code>jahr</code>
<textarea id="subs" rows="10" style="width:100%;" placeholder="Netflix; 12.99; monat
Spotify; 10.99; monat
Gym; 240; jahr"></textarea>
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
  function parseLine(line){
    var parts = line.split(';').map(p => p.trim()).filter(Boolean);
    if (parts.length < 2) return null;
    var name = parts[0];
    var amount = num(parts[1]);
    var interval = (parts[2] || 'monat').toLowerCase();
    if (!name || !isFinite(amount)) return null;
    if (interval !== 'monat' && interval !== 'jahr') interval = 'monat';
    var monthly = (interval === 'monat') ? amount : (amount / 12);
    var yearly  = monthly * 12;
    return { name:name, amount:amount, interval:interval, monthly:monthly, yearly:yearly };
  }
  var ta = document.getElementById('subs');
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
    var top = rows.slice(0,3);
    var html = '';
    html += '<p><strong>Summe pro Monat:</strong> ' + esc(fmtEUR(sumM)) + '</p>';
    html += '<p><strong>Summe pro Jahr:</strong> ' + esc(fmtEUR(sumY)) + '</p>';
    html += '<h2>Liste (sortiert nach Monatskosten)</h2>';
    html += '<ol>';
    rows.forEach(function(r){
      html += '<li><strong>' + esc(r.name) + '</strong> – ' + esc(fmtEUR(r.monthly)) + '/Monat (Intervall: ' + esc(r.interval) + ')</li>';
    });
    html += '</ol>';
    html += '<h2>Top 3 (schnellster Hebel)</h2>';
    html += '<ol>';
    top.forEach(function(r){
      html += '<li><strong>' + esc(r.name) + '</strong> – ' + esc(fmtEUR(r.monthly)) + '/Monat</li>';
    });
    html += '</ol>';
    out.innerHTML = html;
  });
})();
</script>
## Weiter
1. [Themen-Seite: Abo-Manager]({{ site.baseurl }}/seiten/abo-manager.html)
2. [Download-Hub: Vorlagen & Dateien]({{ site.baseurl }}/seiten/download-hub-abo-manager.html)
3. [Startseite]({{ site.baseurl }}/index.html)
{% include no_sackgasse_footer.html %}