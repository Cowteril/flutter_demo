param(
  [Parameter(Mandatory = $true)]
  [string]$Slug
)

$ErrorActionPreference = "Stop"

$safeSlug = $Slug.ToLowerInvariant() -replace "[^a-z0-9._-]+", "-"
$safeSlug = $safeSlug.Trim("-")

if ([string]::IsNullOrWhiteSpace($safeSlug)) {
  throw "Slug must contain at least one letter or number."
}

$date = Get-Date -Format "yyyy-MM-dd"
$root = Split-Path -Parent $PSScriptRoot
$runDir = Join-Path $root "runs/$date-$safeSlug"
$templates = Join-Path $root "templates"
$taskCardTemplates = Join-Path $templates "task-cards"

if (Test-Path -LiteralPath $runDir) {
  throw "Run already exists: $runDir"
}

New-Item -ItemType Directory -Path $runDir | Out-Null
Copy-Item -Path (Join-Path $templates "*.md") -Destination $runDir

$taskCardsDir = Join-Path $runDir "task-cards"
New-Item -ItemType Directory -Path $taskCardsDir | Out-Null
Copy-Item -Path (Join-Path $taskCardTemplates "*.md") -Destination $taskCardsDir

Write-Output $runDir
