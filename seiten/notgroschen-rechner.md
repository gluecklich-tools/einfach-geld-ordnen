---
layout: default
title: "Notgroschen Rechner"
permalink: /seiten/notgroschen-rechner.html
---
# Notgroschen Rechner

Ziel: Aus Monatsausgaben + Risiko-Level einen Zielbereich fuer den Notgroschen ableiten (Self-Serve).

## Eingabe

<form id="ng-form" onsubmit="return false;">
  <label for="ng-fix">Monatliche Fixkosten (EUR)</label>
  <input id="ng-fix" name="ng-fix" type="number" inputmode="decimal" min="0" step="0.01" placeholder="z.B. 1100" />

  <label for="ng-var">Monatliche variable Ausgaben (EUR)</label>
  <input id="ng-var" name="ng-var" type="number" inputmode="decimal" min="0" step="0.01" placeholder="z.B. 500" />

  <label for="ng-risiko">Risiko-Level</label>
  <select id="ng-risiko" name="ng-risiko">
    <option value="niedrig">niedrig (1-3 Monate)</option>
    <option value="mittel" selected>mittel (3-6 Monate)</option>
    <option value="hoch">hoch (6-9 Monate)</option>
  </select>

  <label for="ng-monate">Sparziel-Dauer (optional, Monate)</label>
  <input id="ng-monate" name="ng-monate" type="number" inputmode="numeric" min="1" step="1" placeholder="z.B. 12" />

  <button type="button" id="ng-berechnen">Berechnen</button>
  <button type="button" id="ng-reset" class="secondary">Reset</button>
</form>

## Ergebnis

<div id="ng-out" aria-live="polite">
  <p><strong>Monatsausgaben (Fix + Variabel):</strong> <span id="ng-monatsausgaben">-</span> EUR</p>
  <p><strong>Notgroschen-Zielbereich:</strong> <span id="ng-range">-</span> EUR</p>
  <p><strong>Empfohlene Sparrate (optional):</strong> <span id="ng-sparrate">-</span> EUR / Monat</p>
</div>

## Hinweise

- Grobe Naeherung (kein Finanz-/Steuer-/Rechtsrat).
- Wenn Einkommen schwankt oder Risiko hoch ist: eher oberen Bereich nutzen.
- Wenn du gerade startest: zuerst 300-1.000 EUR Mini-Notgroschen aufbauen, dann Bandbreite.

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

  function monthsRange(level) {
    if (level === 'niedrig') return [1, 3];
    if (level === 'hoch') return [6, 9];
    return [3, 6]; // mittel default
  }

  var fixEl = document.getElementById('ng-fix');
  var varEl = document.getElementById('ng-var');
  var lvlEl = document.getElementById('ng-risiko');
  var monEl = document.getElementById('ng-monate');

  var outMon = document.getElementById('ng-monatsausgaben');
  var outRange = document.getElementById('ng-range');
  var outRate = document.getElementById('ng-sparrate');

  var btn = document.getElementById('ng-berechnen');
  var reset = document.getElementById('ng-reset');

  function calc() {
    var fix = toNumber(fixEl.value);
    var vari = toNumber(varEl.value);
    var lvl = String(lvlEl.value || 'mittel');
    var m = toNumber(monEl.value);

    if (!isFinite(fix) || fix < 0) fix = NaN;
    if (!isFinite(vari) || vari < 0) vari = NaN;

    if (!isFinite(fix) || !isFinite(vari)) {
      outMon.textContent = '-';
      outRange.textContent = '-';
      outRate.textContent = '-';
      return;
    }

    var monatsausgaben = fix + vari;
    var r = monthsRange(lvl);
    var lo = monatsausgaben * r[0];
    var hi = monatsausgaben * r[1];

    outMon.textContent = fmt(monatsausgaben);
    outRange.textContent = fmt(lo) + ' bis ' + fmt(hi);

    if (isFinite(m) && m >= 1) {
      var ziel = hi; // konservativ: obere Grenze
      var rate = ziel / m;
      outRate.textContent = fmt(rate);
    } else {
      outRate.textContent = '-';
    }
  }

  btn.addEventListener('click', calc);
  fixEl.addEventListener('input', calc);
  varEl.addEventListener('input', calc);
  lvlEl.addEventListener('change', calc);
  monEl.addEventListener('input', calc);

  reset.addEventListener('click', function () {
    fixEl.value = '';
    varEl.value = '';
    lvlEl.value = 'mittel';
    monEl.value = '';
    outMon.textContent = '-';
    outRange.textContent = '-';
    outRate.textContent = '-';
    fixEl.focus();
  });
})();
</script>

## Weiter

{% include weiter_links.html %}
