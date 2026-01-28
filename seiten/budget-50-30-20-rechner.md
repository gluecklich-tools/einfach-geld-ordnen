---
layout: page
title: 50/30/20 Rechner
permalink: /seiten/budget-50-30-20-rechner.html
---

# 50/30/20 Rechner

Ziel: Aus Netto -> Budget-Aufteilung (Self-Serve).

## Eingabe

<form id="b532-form" onsubmit="return false;">
  <label for="b532-netto">Netto pro Monat (EUR)</label>
  <input id="b532-netto" name="b532-netto" type="number" inputmode="decimal" min="0" step="0.01" placeholder="z.B. 2500" />

  <button type="button" id="b532-go">Berechnen</button>
  <button type="button" id="b532-reset" class="secondary">Reset</button>
</form>

## Ergebnis

<div id="b532-out" aria-live="polite">
  <p><strong>Bedarf (50%):</strong> <span id="b532-need">-</span> EUR</p>
  <p><strong>Wunsch (30%):</strong> <span id="b532-want">-</span> EUR</p>
  <p><strong>Sparen (20%):</strong> <span id="b532-save">-</span> EUR</p>
</div>

## Hinweise

- Grobe Naeherung (kein Finanz-/Steuer-/Rechtsrat).
- Wenn Fixkosten sehr hoch sind: erst Fixkosten senken oder Quote anpassen.

<script>
(function () {
  function toNumber(v) {
    if (v === null || v === undefined) return NaN;
    var s = String(v).replace(',', '.').trim();
    if (s.length === 0) return NaN;
    var n = Number(s);
    return isFinite(n) ? n : NaN;
  }
  function fmt(n) { return n.toFixed(2).replace('.', ','); }

  var nettoEl = document.getElementById('b532-netto');
  var outNeed = document.getElementById('b532-need');
  var outWant = document.getElementById('b532-want');
  var outSave = document.getElementById('b532-save');
  var btn = document.getElementById('b532-go');
  var reset = document.getElementById('b532-reset');

  function calc() {
    var netto = toNumber(nettoEl.value);
    if (!isFinite(netto) || netto < 0) {
      outNeed.textContent = '-';
      outWant.textContent = '-';
      outSave.textContent = '-';
      return;
    }
    outNeed.textContent = fmt(netto * 0.50);
    outWant.textContent = fmt(netto * 0.30);
    outSave.textContent = fmt(netto * 0.20);
  }

  btn.addEventListener('click', calc);
  nettoEl.addEventListener('input', calc);
  reset.addEventListener('click', function () {
    nettoEl.value = '';
    outNeed.textContent = '-';
    outWant.textContent = '-';
    outSave.textContent = '-';
    nettoEl.focus();
  });
})();
</script>

## Weiter

- Rechner: [Rechner-Uebersicht]({{ site.baseurl }}/seiten/rechner-uebersicht.html)
- Downloads (Freebie): [Kostenlose Vorlage]({{ site.baseurl }}/seiten/haushaltsbuch-vorlage-kostenlos.html)
- Vollversion: [Haushaltsbuch Vollversion]({{ site.baseurl }}/seiten/haushaltsbuch-vollversion.html)

{% include no_sackgasse_footer.html %}