---
permalink: /seiten/rechner-fixkosten-check.html
layout: default
title: Rechner Fixkosten-Check
permalink: /seiten/rechner-fixkosten-check.html
description: "Rechner Fixkosten-Check – kurze Einordnung + klare nächste Schritte. Haushaltsbuch, Fixkosten, Rücklagen, Schulden: einfach ohne App."
---
# Rechner: Fixkosten-Check (Quote + Ampel)
Du gibst dein Netto-Einkommen und deine Fixkosten ein.
Der Rechner zeigt dir deine **Fixkostenquote** und eine einfache Ampel.
<label for="netto">Netto-Einkommen pro Monat (EUR)</label>
<input id="netto" type="number" min="0" step="1" inputmode="numeric" />
<label for="fix">Fixkosten gesamt pro Monat (EUR)</label>
<input id="fix" type="number" min="0" step="1" inputmode="numeric" />
<p>
  <button id="calcBtn" type="button">Berechnen</button>
</p>
<div id="out" aria-live="polite"></div>
<script>
(function () {
  function esc(s){ return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
  function num(v){ var n = Number(String(v||'0').replace(',', '.')); return isFinite(n) ? n : 0; }
  function fmt(n){
    try { return new Intl.NumberFormat('de-DE').format(n); } catch(e){ return String(n); }
  }
  function fmtEUR(n){
    try { return new Intl.NumberFormat('de-DE', { style:'currency', currency:'EUR' }).format(n); }
    catch(e){ return (Math.round(n*100)/100).toFixed(2) + ' EUR'; }
  }
  var netto = document.getElementById('netto');
  var fix = document.getElementById('fix');
  var btn = document.getElementById('calcBtn');
  var out = document.getElementById('out');
  btn.addEventListener('click', function(){
    var n = num(netto.value);
    var f = num(fix.value);
    if (n <= 0 || f < 0){
      out.innerHTML = '<p><strong>Bitte gueltige Werte eingeben.</strong></p>';
      return;
    }
    var q = (f / n) * 100;
    var qRound = Math.round(q * 10) / 10;
    var amp = 'Gruen';
    var hint = 'Du hast gute Luft. Halte die Fixkosten stabil.';
    if (q >= 35) { amp = 'Gelb'; hint = 'Ok, aber hier steckt oft Sparpotenzial (Vertraege, Abos, Versicherungen).'; }
    if (q >= 50) { amp = 'Rot';  hint = 'Kritisch: Fixkosten sind sehr hoch. Fokus auf groesste Posten und schnelle Kuendigungen.'; }
    var ziel = 0;
    if (q >= 35 && q < 50) ziel = Math.max(0, Math.round((f - (n*0.35))/1));
    if (q >= 50) ziel = Math.max(0, Math.round((f - (n*0.35))/1));
    var html = '';
    html += '<p><strong>Fixkostenquote:</strong> ' + esc(fmt(qRound)) + ' %</p>';
    html += '<p><strong>Ampel:</strong> ' + esc(amp) + '</p>';
    html += '<p>' + esc(hint) + '</p>';
    if (ziel > 0){
      html += '<p><strong>Orientierung:</strong> Wenn du Richtung 35% willst, muesstest du grob ' + esc(fmtEUR(ziel)) + ' pro Monat senken.</p>';
    }
    var frei = Math.max(0, n - f);
    html += '<p><strong>Frei verfuegbar (nach Fixkosten):</strong> ' + esc(fmtEUR(frei)) + '</p>';
    out.innerHTML = html;
  });
})();
</script>
## Weiter
- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
- [Rechner]({{ site.baseurl }}/seiten/rechner-uebersicht.html)
- [Ueberblick]({{ site.baseurl }}/pillar/einfach-geld-ordnen.html)
{% include no_sackgasse_footer.html %}






