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

{% include flow-footer.html %}

<!-- NAV-FOOTER-START -->

## Naechste Schritte

- [Rechner Uebersicht]({{ site.baseurl }}/seiten/rechner-index.html)
- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
- [Monatliche Ausgaben]({{ site.baseurl }}/seiten/monatliche-ausgaben.html)
- [Zurueck zur Uebersicht]({{ site.baseurl }}/seiten/index.html)

- Du bist hier: Rechner Jahreskosten

<!-- NAV-FOOTER-END -->

{% include no_sackgasse_footer.html %}

## Naechste Schritte (Rechner)

- [Rechner-Uebersicht]( {{ site.baseurl }}/seiten/rechner-index.html )
- [Schuldenfrei Uebersicht]( {{ site.baseurl }}/pillar/schuldenfrei.html )
- [Pillar Uebersicht]( {{ site.baseurl }}/pillar/index.html )
