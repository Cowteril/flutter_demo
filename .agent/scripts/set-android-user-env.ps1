param(
  [string]$AndroidSdk = "C:\Users\niuwe\AppData\Local\Android\Sdk",
  [string]$JavaHome = "D:\Java\JDK\jdk-17.0.2"
)

$ErrorActionPreference = "Stop"

[Environment]::SetEnvironmentVariable("ANDROID_HOME", $AndroidSdk, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $AndroidSdk, "User")
[Environment]::SetEnvironmentVariable("JAVA_HOME", $JavaHome, "User")

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$parts = @()

if (-not [string]::IsNullOrWhiteSpace($currentPath)) {
  $parts = @($currentPath -split [IO.Path]::PathSeparator | Where-Object {
    -not [string]::IsNullOrWhiteSpace($_)
  })
}

$entries = @(
  "$AndroidSdk\platform-tools",
  "$AndroidSdk\cmdline-tools\latest\bin",
  "$JavaHome\bin"
)

foreach ($entry in $entries) {
  $exists = $false
  foreach ($part in $parts) {
    if ($part.TrimEnd("\") -ieq $entry.TrimEnd("\")) {
      $exists = $true
      break
    }
  }

  if (-not $exists) {
    $parts += $entry
  }
}

$newPath = $parts -join [IO.Path]::PathSeparator
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

Write-Output "Android user environment updated."
Write-Output "ANDROID_HOME=$AndroidSdk"
Write-Output "JAVA_HOME=$JavaHome"
