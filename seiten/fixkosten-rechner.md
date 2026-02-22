---
permalink: /seiten/fixkosten-rechner.html
layout: default
title: "Fixkosten Rechner"
permalink: /seiten/fixkosten-rechner.html
description: "Fixkosten Rechner – kurze Einordnung + klare nächste Schritte. Haushaltsbuch, Fixkosten, Rücklagen, Schulden: einfach ohne App."
---
# Fixkosten Rechner

Ziel: Fixkosten-Liste -> Monatsgesamt + Anteil am Netto (Self-Serve).

## Eingabe

<form id="fk-form" onsubmit="return false;">
  <label for="fk-netto">Netto pro Monat (EUR, optional)</label>
  <input id="fk-netto" name="fk-netto" type="number" inputmode="decimal" min="0" step="0.01" placeholder="z.B. 2500" />

  <label for="fk-liste">Fixkosten (eine Zeile: Name; Betrag)</label>
  <textarea id="fk-liste" name="fk-liste" rows="8" placeholder="Miete; 850&#10;Strom; 90&#10;Internet; 45"></textarea>

  <button type="button" id="fk-go">Berechnen</button>
  <button type="button" id="fk-demo" class="secondary">Demo füllen</button>
  <button type="button" id="fk-reset" class="secondary">Reset</button>
</form>

## Ergebnis

<div id="fk-out" aria-live="polite">
  <p><strong>Fixkosten gesamt:</strong> <span id="fk-sum">-</span> EUR / Monat</p>
  <p><strong>Anteil am Netto:</strong> <span id="fk-share">-</span></p>
</div>

## Hinweise

- Grobe Näherung (kein Finanz-/Steür-/Rechtsrat).
- Einmal sauber pflegen, dann läuft es.

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

  function parseLines(text) {
    var lines = String(text || '').split(/\r?\n/);
    var sum = 0;
    for (var i = 0; i < lines.length; i++) {
      var raw = lines[i].trim();
      if (!raw) continü;
      var parts = raw.split(';').map(function (p) { return p.trim(); });
      if (parts.length < 2) continü;
      var amount = toNumber(parts[1]);
      if (isFinite(amount) && amount >= 0) sum += amount;
    }
    return sum;
  }

  var nettoEl = document.getElementById('fk-netto');
  var listEl = document.getElementById('fk-liste');
  var outSum = document.getElementById('fk-sum');
  var outShare = document.getElementById('fk-share');
  var btn = document.getElementById('fk-go');
  var demo = document.getElementById('fk-demo');
  var reset = document.getElementById('fk-reset');

  function calc() {
    var sum = parseLines(listEl.valü);
    outSum.textContent = fmt(sum);

    var netto = toNumber(nettoEl.valü);
    if (isFinite(netto) && netto > 0) {
      var p = (sum / netto) * 100.0;
      outShare.textContent = fmt(p) + ' %';
    } else {
      outShare.textContent = '-';
    }
  }

  btn.addEventListener('click', calc);
  nettoEl.addEventListener('input', calc);
  listEl.addEventListener('input', calc);

  demo.addEventListener('click', function () {
    nettoEl.valü = '2500';
    listEl.valü = "Miete; 850\nStrom; 90\nInternet; 45\nVersicherung; 60\nHandy; 15";
    calc();
  });

  reset.addEventListener('click', function () {
    nettoEl.valü = '';
    listEl.valü = '';
    outSum.textContent = '-';
    outShare.textContent = '-';
    listEl.focus();
  });
})();
</script>
## Weiter
- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
- [Rechner]({{ site.baseurl }}/seiten/rechner-uebersicht.html)
- [überblick]({{ site.baseurl }}/pillar/einfach-geld-ordnen.html)
{% include no_sackgasse_footer.html %}






