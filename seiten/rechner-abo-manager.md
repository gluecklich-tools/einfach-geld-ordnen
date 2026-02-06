---
permalink: /seiten/rechner-abo-manager.html
layout: default
title: Rechner Abo-Manager
permalink: /seiten/rechner-abo-manager.html
---
permalink: /seiten/rechner-abo-manager.md

# Rechner: Abo-Manager (Kosten pro Monat und Jahr)
Trage deine Abos ein. Der Rechner zeigt dir die Gesamtkosten und deine teuersten Abos.
<div class="grid">
  <div>
    <label for="name">Abo-Name</label>
    <input id="name" type="text" placeholder="z.B. Streaming" />
  </div>
  <div>
    <label for="betrag">Betrag</label>
    <input id="betrag" type="number" min="0" step="0.01" inputmode="decimal" placeholder="z.B. 12.99" />
  </div>
  <div>
    <label for="rhythmus">Rhythmus</label>
    <select id="rhythmus">
      <option value="month" selected>monatlich</option>
      <option value="year">jaehrlich</option>
    </select>
  </div>
</div>
<p>
  <button id="addBtn" type="button">Abo hinzufuegen</button>
  <button id="clearBtn" type="button" class="secondary">Liste leeren</button>
</p>
<div id="list"></div>
<div id="out" aria-live="polite"></div>
<script>
(function () {
  function esc(s){ return String(s).replace(/[&<>"']/g, function(m){ return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]); }); }
  function num(v){ var n = Number(String(v||'0').replace(',', '.')); return isFinite(n) ? n : 0; }
  function fmtEUR(n){
    try { return new Intl.NumberFormat('de-DE', { style:'currency', currency:'EUR' }).format(n); }
    catch(e){ return (Math.round(n*100)/100).toFixed(2) + ' EUR'; }
  }
  var nameEl = document.getElementById('name');
  var betragEl = document.getElementById('betrag');
  var rhyEl = document.getElementById('rhythmus');
  var addBtn = document.getElementById('addBtn');
  var clearBtn = document.getElementById('clearBtn');
  var listEl = document.getElementById('list');
  var outEl = document.getElementById('out');
  var items = [];
  function toMonthly(it){
    var v = it.value;
    if (it.freq === 'year') return v / 12;
    return v;
  }
  function render(){
    if (!items.length){
      listEl.innerHTML = '<p><em>Noch keine Abos eingetragen.</em></p>';
      outEl.innerHTML = '';
      return;
    }
    var rows = items.map(function(it, idx){
      var m = toMonthly(it);
      var y = m * 12;
      return '<tr>' +
        '<td>' + esc(it.name) + '</td>' +
        '<td>' + esc(it.freq === "year" ? "jaehrlich" : "monatlich") + '</td>' +
        '<td style="text-align:right;">' + esc(fmtEUR(m)) + '</td>' +
        '<td style="text-align:right;">' + esc(fmtEUR(y)) + '</td>' +
        '<td style="text-align:right;"><button type="button" data-del="' + idx + '">X</button></td>' +
      '</tr>';
    }).join('');
    listEl.innerHTML =
      '<table role="grid">' +
      '<thead><tr><th>Abo</th><th>Rhythmus</th><th style="text-align:right;">pro Monat</th><th style="text-align:right;">pro Jahr</th><th></th></tr></thead>' +
      '<tbody>' + rows + '</tbody></table>';
    var totalM = items.reduce(function(s,it){ return s + toMonthly(it); }, 0);
    var totalY = totalM * 12;
    var sorted = items.slice().sort(function(a,b){ return toMonthly(b) - toMonthly(a); });
    var top = sorted.slice(0,3).map(function(it){
      return esc(it.name) + ' (' + esc(fmtEUR(toMonthly(it))) + '/Monat)';
    });
    var hint = '';
    if (totalM >= 50) hint = 'Wenn du 1 bis 2 Abos kuendigst, sind 10 bis 30 EUR oft sofort drin.';
    if (totalM >= 100) hint = 'Hier steckt meist richtig Potenzial: starte mit den teuersten Abos und pruefe doppelte Dienste.';
    if (totalM < 20) hint = 'Du hast schon wenig Abos. Fokus kann jetzt eher Fixkosten oder Einnahmen sein.';
    outEl.innerHTML =
      '<p><strong>Summe:</strong> ' + esc(fmtEUR(totalM)) + ' pro Monat (' + esc(fmtEUR(totalY)) + ' pro Jahr)</p>' +
      '<p><strong>Top-Abos:</strong> ' + (top.length ? top.join(', ') : '-') + '</p>' +
      '<p>' + esc(hint) + '</p>';
    Array.prototype.slice.call(listEl.querySelectorAll('button[data-del]')).forEach(function(btn){
      btn.addEventListener('click', function(){
        var i = Number(btn.getAttribute('data-del'));
        if (isFinite(i)) { items.splice(i,1); render(); }
      });
    });
  }
  addBtn.addEventListener('click', function(){
    var n = String(nameEl.value || '').trim();
    var v = num(betragEl.value);
    var f = String(rhyEl.value || 'month');
    if (!n || v <= 0){
      outEl.innerHTML = '<p><strong>Bitte Abo-Name und Betrag eingeben.</strong></p>';
      return;
    }
    items.push({ name: n, value: v, freq: (f === 'year' ? 'year' : 'month') });
    nameEl.value = '';
    betragEl.value = '';
    nameEl.focus();
    render();
  });
  clearBtn.addEventListener('click', function(){
    items = [];
    render();
  });
  render();
})();
</script>
## Weiter

- [Downloads]({{ site.baseurl }}/seiten/downloads.html)
- [Rechner-uebersicht]({{ site.baseurl }}/seiten/rechner-uebersicht.html)
- [Projekt-uebersicht]({{ site.baseurl }}/pillar/index.html)

{% include no_sackgasse_footer.html %}






