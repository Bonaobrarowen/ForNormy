# Builds manifest.js next to this script from files in the same folder.
# Run again after adding or renaming photos or the song.

$here = $PSScriptRoot
if (-not $here) { $here = (Get-Location).Path }

$imageExt = @(".jpg", ".jpeg", ".png", ".gif", ".webp")
$audioExt = @(".mp3", ".m4a", ".wav", ".ogg")
$skip = @("manifest.js")

$files = Get-ChildItem -LiteralPath $here -File -ErrorAction SilentlyContinue

$photos = @(
    $files | Where-Object {
        $imageExt -contains $_.Extension.ToLower() -and $skip -notcontains $_.Name
    } | ForEach-Object { $_.Name } | Sort-Object
)

$audios = @(
    $files | Where-Object { $audioExt -contains $_.Extension.ToLower() }
)

$song = $null
$hit = $audios | Where-Object {
    $_.BaseName -match '(?i)silent.*sanctuary.*14' -or $_.BaseName -match '(?i)\b14\b'
} | Select-Object -First 1
if ($hit) {
    $song = $hit.Name
}
elseif ($audios.Count -gt 0) {
    $song = $audios[0].Name
}

$obj = [ordered]@{
    song   = $song
    photos = @($photos)
}
$json = ($obj | ConvertTo-Json -Compress -Depth 5)
$out = "window.MEDIA_MANIFEST = $json;"
$dest = Join-Path $here "manifest.js"
[System.IO.File]::WriteAllText($dest, $out)

Write-Host "Wrote $dest"
Write-Host "  song: $song"
Write-Host "  photos: $($photos.Count)"
