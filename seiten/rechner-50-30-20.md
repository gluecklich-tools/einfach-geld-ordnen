---
layout: page
title: Rechner - 50-30-20 (Mini)
permalink: /seiten/rechner-50-30-20.html
---

# Rechner - 50-30-20 (Mini)

<p>
<label>Netto-Einkommen pro Monat (EUR): <input id="netto" type="number" min="0" step="1"></label>
</p>

<button type="button" id="calcBtn">Berechnen</button>

<div id="out" style="margin-top:1rem;"></div>

<script>
(function () {
  function n(v){ var x = Number(v); return isFinite(x) ? x : 0; }
  document.getElementById("calcBtn").addEventListener("click", function () {
    var netto = n(document.getElementById("netto").value);
    var bedarf = netto * 0.50;
    var wunsch = netto * 0.30;
    var ziel = netto * 0.20;

    var html = "";
    html += "<ul>";
    html += "<li><strong>50% Bedarf:</strong> " + bedarf.toFixed(0) + " EUR</li>";
    html += "<li><strong>30% Wunsch:</strong> " + wunsch.toFixed(0) + " EUR</li>";
    html += "<li><strong>20% Ziele:</strong> " + ziel.toFixed(0) + " EUR</li>";
    html += "</ul>";
    html += "<p>Hinweis: Das ist ein Rahmen. Wenn Fixkosten zu hoch sind: erst Fixkosten senken.</p>";
    document.getElementById("out").innerHTML = html;
  });
})();
</script>
<!-- NAV-FOOTER-START -->

<!-- NAV-FOOTER-END -->
