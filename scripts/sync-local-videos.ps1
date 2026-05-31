param(
  [string]$SourceRoot = "videos",
  [string]$DestinationRoot = "client/assets/local_videos",
  [int]$EpisodesPerDrama = 1,
  [ValidateSet("Smallest", "EpisodeOrder")]
  [string]$SelectionMode = "Smallest"
)

$ErrorActionPreference = "Stop"

function Get-EpisodeNumber {
  param([string]$FileName)

  if ($FileName -match "(\d+)") {
    return [int]$Matches[1]
  }

  return [int]::MaxValue
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repoRoot $SourceRoot
$destinationPath = Join-Path $repoRoot $DestinationRoot

if (-not (Test-Path -LiteralPath $sourcePath)) {
  throw "Source video directory not found: $sourcePath"
}

New-Item -ItemType Directory -Force -Path $destinationPath | Out-Null

$resolvedRepoRoot = (Resolve-Path -LiteralPath $repoRoot).Path
$resolvedDestinationPath = (Resolve-Path -LiteralPath $destinationPath).Path
$expectedPrefix = $resolvedRepoRoot.TrimEnd("\") + "\"
if (-not $resolvedDestinationPath.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw "Destination must be inside repository root: $resolvedDestinationPath"
}

$generatedVideos = Get-ChildItem -LiteralPath $destinationPath -File -Filter "drama*_ep*.mp4"
foreach ($generatedVideo in $generatedVideos) {
  Remove-Item -LiteralPath $generatedVideo.FullName -Force
}

$catalogEntries = @()
$dramaIndex = 0
$dramaDirs = Get-ChildItem -LiteralPath $sourcePath -Directory | Sort-Object Name
foreach ($dramaDir in $dramaDirs) {
  $dramaIndex += 1

  $episodeFiles = Get-ChildItem -LiteralPath $dramaDir.FullName -File -Filter "*.mp4"
  if ($SelectionMode -eq "EpisodeOrder") {
    $episodes = $episodeFiles |
      Sort-Object @{ Expression = { Get-EpisodeNumber $_.Name } }, Name |
      Select-Object -First $EpisodesPerDrama
  } else {
    $episodes = $episodeFiles |
      Sort-Object Length, Name |
      Select-Object -First $EpisodesPerDrama
  }

  $episodeIndex = 0
  foreach ($episode in $episodes) {
    $episodeIndex += 1
    $episodeNumber = Get-EpisodeNumber $episode.Name
    if ($episodeNumber -eq [int]::MaxValue) {
      $episodeNumber = $episodeIndex
    }

    $extension = [System.IO.Path]::GetExtension($episode.Name).ToLowerInvariant()
    $targetName = "drama{0:D2}_ep{1:D3}{2}" -f $dramaIndex, $episodeNumber, $extension
    $targetFile = Join-Path $destinationPath $targetName
    Copy-Item -LiteralPath $episode.FullName -Destination $targetFile -Force

    $catalogEntries += [ordered]@{
      asset = "assets/local_videos/$targetName"
      title = $dramaDir.Name
      episodeNumber = $episodeNumber
      displayEpisode = "Episode $episodeNumber"
      sourceFile = $episode.Name
    }

    $sizeMb = [Math]::Round($episode.Length / 1MB, 1)
    Write-Host "Copied $($dramaDir.Name)/$($episode.Name) -> $targetName ($sizeMb MB)"
  }
}

$catalog = [ordered]@{
  version = 1
  generatedAt = (Get-Date).ToString("o")
  videos = $catalogEntries
}

$catalogPath = Join-Path $destinationPath "catalog.json"
$catalog | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $catalogPath -Encoding UTF8

Write-Host "Local videos synced to $destinationPath"
Write-Host "Catalog written to $catalogPath"
