param(
  [string]$FlutterBin = "C:\Users\niuwe\flutter\bin"
)

$ErrorActionPreference = "Stop"

$current = [Environment]::GetEnvironmentVariable("Path", "User")
$parts = @()

if (-not [string]::IsNullOrWhiteSpace($current)) {
  $parts = @($current -split [IO.Path]::PathSeparator | Where-Object {
    -not [string]::IsNullOrWhiteSpace($_)
  })
}

$alreadyPresent = $false
foreach ($part in $parts) {
  if ($part.TrimEnd("\") -ieq $FlutterBin.TrimEnd("\")) {
    $alreadyPresent = $true
    break
  }
}

if (-not $alreadyPresent) {
  $parts += $FlutterBin
}

$newPath = $parts -join [IO.Path]::PathSeparator
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

Write-Output "User PATH updated."
Write-Output $newPath
