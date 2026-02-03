---
layout: default
title: Rechner Schulden Schneeball
permalink: /seiten/rechner-schulden-schneeball.html
---
# Rechner: Schulden-Schneeball (Plan in Sekunden)
Eintrag pro Zeile: <code>Name; Restschuld; Mindestrate</code>
Optional: Du kannst einen **Extra-Betrag** angeben, der jeden Monat zusaetzlich in den Schneeball geht.
<textarea id="debts" rows="10" style="width:100%;" placeholder="Kredit A; 1200; 60
Kredit B; 3500; 95
Kredit C; 600; 30"></textarea>
<label for="extra">Extra pro Monat (EUR)</label>
<input id="extra" type="number" min="0" step="1" inputmode="numeric" />
<p>
  <button id="calcBtn" type="button">Plan erstellen</button>
</p>
<div id="out" aria-live="polite"></div>
<script>
(function () {
  function esc(s){ return String(s).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]); }); }
  function num(v){ var n = Number(String(v||'0').replace(',', '.')); return isFinite(n) ? n : NaN; }
  function fmtEUR(n){
    try { return new Intl.NumberFormat('de-DE', { style:'currency', currency:'EUR' }).format(n); }
    catch(e){ return (Math.round(n*100)/100).toFixed(2) + ' EUR'; }
  }
  function parseLine(line){
    var parts = line.split(';').map(function(p){ return p.trim(); }).filter(Boolean);
    if (parts.length < 3) return null;
    var name = parts[0];
    var rest = num(parts[1]);
    var minrate = num(parts[2]);
    if (!name || !isFinite(rest) || !isFinite(minrate) || rest <= 0 || minrate < 0) return null;
    return { name:name, rest:rest, minrate:minrate };
  }
  var ta = document.getElementById('debts');
  var extraEl = document.getElementById('extra');
  var btn = document.getElementById('calcBtn');
  var out = document.getElementById('out');
  btn.addEventListener('click', function(){
    var lines = ta.value.split(/\r?\n/).map(function(l){ return l.trim(); }).filter(Boolean);
    var rows = [];
    for (var i=0;i<lines.length;i++){
      var r = parseLine(lines[i]);
      if (r) rows.push(r);
    }
    var extra = num(extraEl.value);
    if (!isFinite(extra) || extra < 0) extra = 0;
    if (!rows.length){
      out.innerHTML = '<p><strong>Keine gueltigen Zeilen gefunden.</strong></p>';
      return;
    }
    // Schneeball: nach Restschuld aufsteigend
    rows.sort(function(a,b){ return a.rest - b.rest; });
    var sumRest = rows.reduce(function(s,r){ return s+r.rest; }, 0);
    var sumMin  = rows.reduce(function(s,r){ return s+r.minrate; }, 0);
    var html = '';
    html += '<p><strong>Restschuld gesamt:</strong> ' + esc(fmtEUR(sumRest)) + '</p>';
    html += '<p><strong>Mindest-Raten gesamt:</strong> ' + esc(fmtEUR(sumMin)) + ' / Monat</p>';
    html += '<p><strong>Extra:</strong> ' + esc(fmtEUR(extra)) + ' / Monat</p>';
    html += '<h2>Reihenfolge (Schneeball)</h2>';
    html += '<ol>';
    rows.forEach(function(r, idx){
      html += '<li><strong>' + esc(r.name) + '</strong> – Rest: ' + esc(fmtEUR(r.rest)) + ', Mindestrate: ' + esc(fmtEUR(r.minrate)) + '</li>';
    });
    html += '</ol>';
    // Grobe Zeit-Schaetzung ohne Zinsen: (Restschuld / (Mindest + Extra)) ist nur Orientierung
    // Wir simulieren: Extra + freiwerdende Rate wird immer auf aktuelle kleinste Schuld gelegt.
    var sim = rows.map(function(r){ return { name:r.name, rest:r.rest, minrate:r.minrate }; });
    var month = 0;
    var maxMonths = 600; // Safety
    while (month < maxMonths){
      var active = sim.filter(function(d){ return d.rest > 0.000001; });
      if (!active.length) break;
      // Ziel = kleinste Restschuld
      active.sort(function(a,b){ return a.rest - b.rest; });
      var target = active[0];
      // Alle Mindest-Raten zahlen
      active.forEach(function(d){
        var pay = Math.min(d.rest, d.minrate);
        d.rest -= pay;
      });
      // Extra + freiwerdende Mindest-Raten (von bereits getilgten) stehen im Schneeball zur Verfuegung
      var freed = sim.filter(function(d){ return d.rest <= 0.000001; }).reduce(function(s,d){ return s + d.minrate; }, 0);
      var snow = extra + freed;
      if (snow > 0 && target.rest > 0.000001){
        var pay2 = Math.min(target.rest, snow);
        target.rest -= pay2;
      }
      month++;
      // Wenn wir uns festfahren wuerden (z.B. Mindest=0 und extra=0), abbrechen
      var still = sim.filter(function(d){ return d.rest > 0.000001; });
      var totalMinStill = still.reduce(function(s,d){ return s + d.minrate; }, 0);
      if (totalMinStill <= 0.000001 && extra <= 0.000001) break;
    }
    if (month >= 600){
      html += '<p><strong>Hinweis:</strong> Die Simulation wurde bei 600 Monaten abgebrochen (nur Orientierung).</p>';
    } else {
      html += '<p><strong>Grobe Dauer-Schaetzung (ohne Zinsen):</strong> ca. ' + esc(String(month)) + ' Monate</p>';
    }
    html += '<p>Wichtig: Das ist eine Orientierung. Zinsen, Gebuehren und Sonderregeln deiner Vertraege koennen die Dauer veraendern.</p>';
    out.innerHTML = html;
  });
})();
</script>

## Weiter
- [Rechner: Schulden-Schneeball]({{site.baseurl}}/seiten/rechner-schneeball.html)
- [Download: Schulden-Schneeball]({{site.baseurl}}/seiten/download-hub-schulden-schneeball.html)
- [Pillar: Schuldenfrei]({{site.baseurl}}/pillar/schuldenfrei.html)

{% include no_sackgasse_footer.html %}
