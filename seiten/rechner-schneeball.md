---
layout: default
title: "Rechner - Schulden-Schneeball (Mini)"
permalink: /seiten/rechner-schneeball.html
---
# Rechner - Schulden-Schneeball (Mini)

**Ziel:** Minimum auf alle Schulden, Extra auf die kleinste.

<p>
<label>Monatsbudget fuer Schulden (EUR): <input id="budget" type="number" min="0" step="1"></label>
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
    var budget = n(document.getElementById("budget").value);
    var minsum = n(document.getElementById("minsum").value);
    var extra = budget - minsum;
    var ok = extra >= 0;

    var html = "";
    html += "<p><strong>Extra fuer kleinste Schuld:</strong> " + (ok ? extra.toFixed(0) : "0") + " EUR</p>";
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

{% include weiter_links.html %}


{% include no_sackgasse_footer.html %}
