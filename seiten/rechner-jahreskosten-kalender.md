---
layout: default
title: Rechner Jahreskosten Kalender
permalink: /seiten/rechner-jahreskosten-kalender.html
---
# Rechner: Jahreskosten auf Monatsbudget (einfach umrechnen)
Trage Kosten ein, die nicht monatlich sind. Der Rechner rechnet alles auf **pro Monat** um und zeigt die Summe.
<div class="grid">
  <div>
    <label for="name">Posten</label>
    <input id="name" type="text" placeholder="z.B. Kfz-Versicherung" />
  </div>
  <div>
    <label for="betrag">Betrag (EUR)</label>
    <input id="betrag" type="number" min="0" step="0.01" inputmode="decimal" placeholder="z.B. 480" />
  </div>
  <div>
    <label for="rhythmus">Rhythmus</label>
    <select id="rhythmus">
      <option value="12" selected>jaehrlich (12 Monate)</option>
      <option value="6">halbjaehrlich (6 Monate)</option>
      <option value="3">quartalsweise (3 Monate)</option>
      <option value="1">monatlich (1 Monat)</option>
    </select>
  </div>
</div>
<p>
  <button id="addBtn" type="button">Posten hinzufuegen</button>
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
  function monthly(it){
    var m = it.months;
    if (m <= 0) m = 12;
    return it.value / m;
  }
  function render(){
    if (!items.length){
      listEl.innerHTML = '<p><em>Noch keine Posten eingetragen.</em></p>';
      outEl.innerHTML = '';
      return;
    }
    var rows = items.map(function(it, idx){
      var pm = monthly(it);
      var py = pm * 12;
      return '<tr>' +
        '<td>' + esc(it.name) + '</td>' +
        '<td style="text-align:right;">' + esc(fmtEUR(it.value)) + '</td>' +
        '<td style="text-align:right;">' + esc(String(it.months)) + '</td>' +
        '<td style="text-align:right;">' + esc(fmtEUR(pm)) + '</td>' +
        '<td style="text-align:right;">' + esc(fmtEUR(py)) + '</td>' +
        '<td style="text-align:right;"><button type="button" data-del="' + idx + '">X</button></td>' +
      '</tr>';
    }).join('');
    listEl.innerHTML =
      '<table role="grid">' +
      '<thead><tr><th>Posten</th><th style="text-align:right;">Betrag</th><th style="text-align:right;">Monate</th><th style="text-align:right;">pro Monat</th><th style="text-align:right;">pro Jahr</th><th></th></tr></thead>' +
      '<tbody>' + rows + '</tbody></table>';
    var totalM = items.reduce(function(s,it){ return s + monthly(it); }, 0);
    var totalY = totalM * 12;
    outEl.innerHTML =
      '<p><strong>Summe:</strong> ' + esc(fmtEUR(totalM)) + ' pro Monat (' + esc(fmtEUR(totalY)) + ' pro Jahr)</p>' +
      '<p>Tipp: Lege genau diese Monats-Summe automatisch zur Seite (Unterkonto), dann sind grosse Rechnungen "bezahlt, bevor sie kommen".</p>';
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
    var m = num(rhyEl.value);
    if (!n || v <= 0 || m <= 0){
      outEl.innerHTML = '<p><strong>Bitte Posten, Betrag und Rhythmus eingeben.</strong></p>';
      return;
    }
    items.push({ name: n, value: v, months: m });
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
1. [Themen-Seite: Jahreskosten-Kalender]({{ site.baseurl }}/seiten/jahreskosten-kalender.html)
2. [Download-Hub: Vorlagen & Dateien]({{ site.baseurl }}/seiten/download-hub-jahreskosten-kalender.html)
3. [Startseite]({{ site.baseurl }}/index.html)
{% include no_sackgasse_footer.html %}