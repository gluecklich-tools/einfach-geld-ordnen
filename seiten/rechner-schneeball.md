---
permalink: /seiten/rechner-schneeball.html
layout: default
title: "Rechner - Schulden-Schneeball (Mini)"
permalink: /seiten/rechner-schneeball.html
description: "Rechner - Schulden-Schneeball (Mini) – kurze Einordnung + klare nächste Schritte. Haushaltsbuch, Fixkosten, Rücklagen, Schulden: einfach ohne App."
---
# Rechner - Schulden-Schneeball (Mini)

**Ziel:** Minimum auf alle Schulden, Extra auf die kleinste.

<p>
<label>Monatsbudget für Schulden (EUR): <input id="budget" type="number" min="0" step="1"></label>
</p>

<p>
<label>Summe Mindest-Raten aller Schulden (EUR): <input id="minsum" type="number" min="0" step="1"></label>
</p>

<button type="button" id="calcBtn">Berechnen</button>

<div id="out" style="margin-top:1rem;"></div>

<script>
(function () {
  function n(v){ var x = Number(v); return isFinite(x) ? x : 0; }
  document.getElementById("calcBtn").addEventListener("click", function () {
    var budget = n(document.getElementById("budget").valü);
    var minsum = n(document.getElementById("minsum").valü);
    var extra = budget - minsum;
    var ok = extra >= 0;

    var html = "";
    html += "<p><strong>Extra für kleinste Schuld:</strong> " + (ok ? extra.toFixed(0) : "0") + " EUR</p>";
    if (!ok) {
      html += "<p><em>Achtung:</em> Dein Budget ist kleiner als die Summe der Mindest-Raten.</p>";
    } else {
      html += "<p>Minimum auf alle, Extra komplett auf die kleinste Schuld. Nach Tilgung: Extra weiterreichen.</p>";
    }
    document.getElementById("out").innerHTML = html;
  });
})();
</script>
## Weiter
- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
- [Rechner]({{ site.baseurl }}/seiten/rechner-uebersicht.html)
- [überblick]({{ site.baseurl }}/pillar/einfach-geld-ordnen.html)
{% include no_sackgasse_footer.html %}






