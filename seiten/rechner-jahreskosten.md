---
layout: page
title: Rechner - Jahreskosten pro Monat (Mini)
permalink: /seiten/rechner-jahreskosten.html
---

# Rechner - Jahreskosten pro Monat (Mini)

<p>
<label>Jahreskosten (EUR): <input id="year" type="number" min="0" step="1"></label>
</p>

<button type="button" id="calcBtn">Berechnen</button>

<div id="out" style="margin-top:1rem;"></div>

<script>
(function () {
  function n(v){ var x = Number(v); return isFinite(x) ? x : 0; }
  document.getElementById("calcBtn").addEventListener("click", function () {
    var year = n(document.getElementById("year").value);
    var month = year / 12;
    document.getElementById("out").innerHTML =
      "<p><strong>Ruecklage pro Monat:</strong> " + month.toFixed(2) + " EUR</p>" +
      "<p>Praxis: Lege diesen Betrag monatlich in einen eigenen Topf.</p>";
  });
})();
</script>

## Weiter

<!-- NAV-FOOTER-START -->
{% include no_sackgasse_footer.html %}

<!-- NAV-FOOTER-END -->
