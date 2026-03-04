#requires -Version 7.0
param()

# Build-MojibakeMarkerSet: returns a HashSet[string] of common mojibake markers.
function Build-MojibakeMarkerSet {
  $set = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
  $markers = @(
    "Ã¤","Ã¶","Ã¼","Ã„","Ã–","Ãœ","ÃŸ",
    "â€“","â€”","â€ž","â€œ","â€˜","â€™","â€¦",
    "Â","â‚¬","â„¢"
  )
  foreach($m in $markers){ [void]$set.Add($m) }
  return $set
}