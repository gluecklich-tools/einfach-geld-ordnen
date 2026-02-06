param()

$ErrorActionPreference="Stop"
Set-StrictMode -Version Latest
try{Remove-Module PSReadLine -ErrorAction SilentlyContinue}catch{}
try{chcp 65001|Out-Null}catch{}; [Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)

$base="https://gluecklich-tools.github.io/einfach-geld-ordnen"
$urls=@(
  "$base/",
  "$base/seiten/index.html",
  "$base/seiten/downloads.html",
  "$base/seiten/rechner-uebersicht.html",
  "$base/seiten/datenschutz.html",
  "$base/seiten/impressum.html",
  "$base/seiten/download-hub-index.html",
  "$base/seiten/freebie.html",
  "$base/seiten/faq_probleme_loesen.html",
  "$base/pillar/schuldenfrei.html",
  "$base/pillar/notgroschen.html",
  "$base/pillar/fixkosten.html"
)

"SMOKE CORE (HEAD nocache):"
foreach($u in $urls){
  $uu = ("{0}?nocache={1}" -f $u, ([guid]::NewGuid().ToString("n")))
  try{
    $r=Invoke-WebRequest -Uri $uu -Method Head -MaximumRedirection 5 -TimeoutSec 20
    "{0}  {1}" -f $r.StatusCode, $u
  } catch {
    $code = try { $_.Exception.Response.StatusCode.value__ } catch { "ERR" }
    "{0}  {1}" -f $code, $u
  }
}