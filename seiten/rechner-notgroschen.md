---
layout: default
title: Rechner Notgroschen
permalink: /seiten/rechner-notgroschen.html
---
# Rechner: Notgroschen (Dauer bis Ziel)
Du gibst dein Ziel und deinen monatlichen Betrag ein, der Rechner zeigt dir die grobe Dauer.
<label for="ziel">Zielbetrag (EUR)</label>
<input id="ziel" type="number" min="0" step="1" inputmode="numeric" />
<label for="rate">Monatlicher Sparbetrag (EUR)</label>
<input id="rate" type="number" min="0" step="1" inputmode="numeric" />
<p>
  <button id="calcBtn" type="button">Berechnen</button>
</p>
<div id="out" aria-live="polite"></div>
<script>
(function () {
  function esc(s){ return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
  function num(v){ var n = Number(String(v||'0').replace(',', '.')); return isFinite(n) ? n : 0; }
  function formatInt(n){ try { return new Intl.NumberFormat('de-DE').format(n); } catch(e){ return String(n); } }
  var ziel = document.getElementById('ziel');
  var rate = document.getElementById('rate');
  var btn  = document.getElementById('calcBtn');
  var out  = document.getElementById('out');
  btn.addEventListener('click', function(){
    var z = num(ziel.value);
    var r = num(rate.value);
    if (z <= 0 || r <= 0){
      out.innerHTML = '<p><strong>Bitte Zielbetrag und monatlichen Betrag eingeben.</strong></p>';
      return;
    }
    var months = Math.ceil(z / r);
    var years = Math.floor(months / 12);
    var restM = months % 12;
    var txt = '<p><strong>Grobe Dauer:</strong> ' + esc(formatInt(months)) + ' Monate</p>';
    if (years > 0){
      txt += '<p>(=' + esc(formatInt(years)) + ' Jahre';
      if (restM > 0) txt += ' + ' + esc(formatInt(restM)) + ' Monate';
      txt += ')</p>';
    }
    out.innerHTML = txt;
  });
})();
</script>
## Weiter
1. [Themen-Seite: Notgroschen-System]({{ site.baseurl }}/seiten/notgroschen-system.html)
2. [Download-Hub: Vorlagen & Dateien]({{ site.baseurl }}/seiten/download-hub-notgroschen.html)
3. [Startseite]({{ site.baseurl }}/index.html)
{% include no_sackgasse_footer.html %}