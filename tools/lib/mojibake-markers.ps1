#requires -Version 7.0
param()

function New-CharString {
  param([Parameter(Mandatory)][int[]]$Codes)
  $chars = foreach($c in $Codes){ [char]$c }
  return -join $chars
}

function Build-MojibakeMarkerSet {
  $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)

  # "Ã¤","Ã¶","Ã¼","Ã„","Ã–","Ãœ","ÃŸ"
  $pairs = @(
    @(195,164), @(195,182), @(195,188), @(195,132), @(195,150), @(195,156), @(195,159),

    # “smart punctuation” mojibake: "â€“","â€”","â€ž","â€œ","â€˜","â€™","â€¦"
    @(226,128,147), @(226,128,148), @(226,128,158), @(226,128,156), @(226,128,152), @(226,128,153), @(226,128,166),

    # "Â" (often appears before symbols), "â‚¬" (euro), "â„¢" (TM)
    @(194,160), @(226,130,172), @(226,132,162)
  )

  foreach($codeList in $pairs){
    $m = New-CharString -Codes $codeList
    [void]$set.Add($m)
  }

  return $set
}