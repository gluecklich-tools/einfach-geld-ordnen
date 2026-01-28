---
layout: page
title: Snowball Rechner
permalink: /seiten/snowball-rechner.html
---

# Snowball Rechner

Ziel: Aus Schuldenliste + Extra-Budget eine einfache Reihenfolge ableiten (Self-Serve).

## Eingabe

Format pro Zeile:
Name; Rest; Rate; ZinsProzent(optional)

Beispiel:
Kreditkarte; 850; 35; 19.9
Ratenkredit; 4200; 120; 6.5

<form id="sb-form" onsubmit="return false;">
  <label for="sb-list">Schuldenliste (eine Zeile pro Schuld)</label>
  <textarea id="sb-list" name="sb-list" rows="8" placeholder="Name; Rest; Rate; Zins"></textarea>

  <label for="sb-extra">Extra-Budget pro Monat (EUR, optional)</label>
  <input id="sb-extra" name="sb-extra" type="number" inputmode="decimal" min="0" step="0.01" placeholder="z.B. 50" />

  <label for="sb-modus">Modus</label>
  <select id="sb-modus" name="sb-modus">
    <option value="snowball" selected>Snowball (kleinster Rest zuerst)</option>
    <option value="lawine">Lawine (hoechster Zins zuerst)</option>
  </select>

  <button type="button" id="sb-berechnen">Berechnen</button>
  <button type="button" id="sb-demo" class="secondary">Demo fuellen</button>
  <button type="button" id="sb-reset" class="secondary">Reset</button>
</form>

## Ergebnis

<div id="sb-out" aria-live="polite">
  <p><strong>Naechster Fokus:</strong> <span id="sb-focus">-</span></p>
  <p><strong>Reihenfolge:</strong></p>
  <ol id="sb-order"></ol>
  <p><strong>Hinweis:</strong> Dauer ist grob: Rest / (Rate + Extra). Zins-Effekt wird hier nicht simuliert.</p>
</div>

<script>
(function () {
  function toNumber(v) {
    if (v === null || v === undefined) return NaN;
    var s = String(v).replace(',', '.').trim();
    if (s.length === 0) return NaN;
    var n = Number(s);
    return isFinite(n) ? n : NaN;
  }

  function parseLines(text) {
    var lines = String(text || '').split(/\r?\n/);
    var items = [];
    for (var i = 0; i < lines.length; i++) {
      var raw = lines[i].trim();
      if (!raw) continue;
      var parts = raw.split(';').map(function (p) { return p.trim(); });
      if (parts.length < 3) continue;

      var name = parts[0] || ('Schuld ' + (items.length + 1));
      var rest = toNumber(parts[1]);
      var rate = toNumber(parts[2]);
      var zins = parts.length >= 4 ? toNumber(parts[3]) : NaN;

      if (!isFinite(rest) || rest < 0) continue;
      if (!isFinite(rate) || rate <= 0) continue;

      items.push({ name: name, rest: rest, rate: rate, zins: isFinite(zins) ? zins : 0 });
    }
    return items;
  }

  function monthsToPayoff(rest, ratePlusExtra) {
    if (!isFinite(ratePlusExtra) || ratePlusExtra <= 0) return NaN;
    return Math.ceil(rest / ratePlusExtra);
  }

  var listEl = document.getElementById('sb-list');
  var extraEl = document.getElementById('sb-extra');
  var modeEl = document.getElementById('sb-modus');

  var focusEl = document.getElementById('sb-focus');
  var orderEl = document.getElementById('sb-order');

  var btn = document.getElementById('sb-berechnen');
  var demo = document.getElementById('sb-demo');
  var reset = document.getElementById('sb-reset');

  function clearOrder() {
    while (orderEl.firstChild) orderEl.removeChild(orderEl.firstChild);
  }

  function calc() {
    clearOrder();

    var items = parseLines(listEl.value);
    var extra = toNumber(extraEl.value);
    if (!isFinite(extra) || extra < 0) extra = 0;

    if (items.length === 0) {
      focusEl.textContent = '-';
      return;
    }

    var mode = String(modeEl.value || 'snowball');

    items.sort(function (a, b) {
      if (mode === 'lawine') {
        if (b.zins !== a.zins) return b.zins - a.zins;
        return a.rest - b.rest;
      }
      // snowball
      if (a.rest !== b.rest) return a.rest - b.rest;
      return b.zins - a.zins;
    });

    var first = items[0];
    focusEl.textContent = first.name;

    for (var i = 0; i < items.length; i++) {
      var it = items[i];
      var pay = it.rate + (i === 0 ? extra : 0); // Extra nur auf Fokus-Schuld
      var m = monthsToPayoff(it.rest, pay);
      var li = document.createElement('li');
      var z = (it.zins > 0) ? (' | Zins: ' + it.zins.toFixed(2).replace('.', ',') + '%') : '';
      var d = isFinite(m) ? (' | ca. ' + m + ' Monate (bei Rate ' + pay.toFixed(2).replace('.', ',') + ')') : '';
      li.textContent = it.name + ' | Rest: ' + it.rest.toFixed(2).replace('.', ',') + ' | Rate: ' + it.rate.toFixed(2).replace('.', ',') + z + d;
      orderEl.appendChild(li);
    }
  }

  btn.addEventListener('click', calc);

  demo.addEventListener('click', function () {
    listEl.value =
      "Kreditkarte; 850; 35; 19,9\n" +
      "Ratenkredit; 4200; 120; 6,5\n" +
      "Handy; 300; 25; 0\n";
    extraEl.value = "50";
    modeEl.value = "snowball";
    calc();
  });

  reset.addEventListener('click', function () {
    listEl.value = '';
    extraEl.value = '';
    modeEl.value = 'snowball';
    focusEl.textContent = '-';
    clearOrder();
    listEl.focus();
  });
})();
</script>

## Weiter

{% include no_sackgasse_footer.html %}