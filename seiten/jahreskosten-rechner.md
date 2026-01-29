---
layout: page
title: "Jahreskosten Rechner"
permalink: {{ site.baseurl }}/seiten/jahreskosten-rechner.html
---

# Jahreskosten Rechner

Ziel: Jahreskostenliste -> Monatsruecklage (Self-Serve).

## Eingabe

Jahreskosten gesamt (EUR):

<form id="jk-form" onsubmit="return false;">
  <label for="jk-summe">Summe pro Jahr</label>
  <input id="jk-summe" name="jk-summe" type="number" inputmode="decimal" min="0" step="0.01" placeholder="z.B. 1200" />

  <label for="jk-puffer">Puffer (optional, %)</label>
  <input id="jk-puffer" name="jk-puffer" type="number" inputmode="decimal" min="0" max="100" step="0.5" placeholder="z.B. 5" />

  <button type="button" id="jk-berechnen">Berechnen</button>
  <button type="button" id="jk-reset" class="secondary">Reset</button>
</form>

## Ergebnis

<div id="jk-out" aria-live="polite">
  <p><strong>Monatsruecklage:</strong> <span id="jk-monat">-</span> EUR</p>
  <p><strong>Monatsruecklage mit Puffer:</strong> <span id="jk-monat-puffer">-</span> EUR</p>
</div>

## Hinweise

- Grobe Naeherung (kein Finanz-/Steuer-/Rechtsrat).
- Wenn du unregelmaessige Kosten hast: lieber leicht zu hoch ansetzen.

<script>
(function () {
  function toNumber(v) {
    if (v === null || v === undefined) return NaN;
    var s = String(v).replace(',', '.').trim();
    if (s.length === 0) return NaN;
    var n = Number(s);
    return isFinite(n) ? n : NaN;
  }

  function fmt(n) {
    return n.toFixed(2).replace('.', ',');
  }

  var sumEl = document.getElementById('jk-summe');
  var pufEl = document.getElementById('jk-puffer');
  var outMonat = document.getElementById('jk-monat');
  var outMonatPuf = document.getElementById('jk-monat-puffer');
  var btn = document.getElementById('jk-berechnen');
  var reset = document.getElementById('jk-reset');

  function calc() {
    var sum = toNumber(sumEl.value);
    var p = toNumber(pufEl.value);

    if (!isFinite(sum) || sum < 0) {
      outMonat.textContent = '-';
      outMonatPuf.textContent = '-';
      return;
    }

    var monat = sum / 12.0;
    var faktor = 1.0;

    if (isFinite(p) && p >= 0) {
      faktor = 1.0 + (p / 100.0);
    }

    var monatPuf = monat * faktor;

    outMonat.textContent = fmt(monat);
    outMonatPuf.textContent = fmt(monatPuf);
  }

  btn.addEventListener('click', calc);
  sumEl.addEventListener('input', calc);
  pufEl.addEventListener('input', calc);

  reset.addEventListener('click', function () {
    sumEl.value = '';
    pufEl.value = '';
    outMonat.textContent = '-';
    outMonatPuf.textContent = '-';
    sumEl.focus();
  });
})();
</script>

## Weiter
- Rechner: [Rechner-Uebersicht]({{ site.baseurl }}/seiten/rechner-uebersicht.html)
- Downloads (Freebie): [Kostenlose Vorlage]({{ site.baseurl }}/seiten/haushaltsbuch-vorlage-kostenlos.html)
- Vollversion: [Haushaltsbuch Vollversion]({{ site.baseurl }}/seiten/haushaltsbuch-vollversion.html)

{% include no_sackgasse_footer.html %}
