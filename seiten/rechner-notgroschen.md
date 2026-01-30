---
layout: default
title: Rechner Notgroschen
permalink: /seiten/rechner-notgroschen.html
---
# Rechner: Notgroschen-Ziel & Plan
Du gibst deine monatlichen Ausgaben und deinen Sparbetrag ein.
Der Rechner zeigt dir ein Ziel (1, 2 oder 3 Monate) und wie lange es grob dauert.
<label for="ausgaben">Monatliche Ausgaben (EUR)</label>
<input id="ausgaben" type="number" min="0" step="1" inputmode="numeric" />
<label for="sparrate">Sparrate pro Monat (EUR)</label>
<input id="sparrate" type="number" min="0" step="1" inputmode="numeric" />
<label for="monate">Ziel in Monatsausgaben</label>
<select id="monate">
  <option value="1">1 Monat</option>
  <option value="2">2 Monate</option>
  <option value="3" selected>3 Monate</option>
</select>
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
  var ausgaben = document.getElementById('ausgaben');
  var sparrate = document.getElementById('sparrate');
  var monate = document.getElementById('monate');
  var btn = document.getElementById('calcBtn');
  var out = document.getElementById('out');
  btn.addEventListener('click', function(){
    var a = num(ausgaben.value);
    var s = num(sparrate.value);
    var m = num(monate.value);
    if (a <= 0 || s <= 0 || m <= 0){
      out.innerHTML = '<p><strong>Bitte gueltige Werte eingeben.</strong></p>';
      return;
    }
    var ziel = a * m;
    var months = Math.ceil(ziel / s);
    var html = '';
    html += '<p><strong>Ziel (Notgroschen):</strong> ' + esc(fmtEUR(ziel)) + ' (' + esc(String(m)) + ' Monatsausgaben)</p>';
    html += '<p><strong>Sparrate:</strong> ' + esc(fmtEUR(s)) + ' / Monat</p>';
    html += '<p><strong>Grobe Dauer:</strong> ca. ' + esc(String(months)) + ' Monate</p>';
    html += '<p>Hinweis: Starte klein (500 bis 1.000 EUR), dann baust du weiter auf.</p>';
    out.innerHTML = html;
  });
})();
</script>
## Weiter
1. [Themen-Seite: Notgroschen]({{ site.baseurl }}/seiten/notgroschen.html)
2. [Download-Hub: Vorlagen & Dateien]({{ site.baseurl }}/seiten/download-hub-notgroschen.html)
3. [Startseite]({{ site.baseurl }}/index.html)
{% include no_sackgasse_footer.html %}