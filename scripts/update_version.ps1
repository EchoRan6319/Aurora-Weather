# AuroraWeather Version Sync Script
# Reads version from Git tag and updates project files

param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "=== AuroraWeather Version Sync Script ===" -ForegroundColor Cyan
Write-Host "Project Root: $ProjectRoot" -ForegroundColor Gray

# Get latest Git tag
$LatestTag = git describe --tags --abbrev=0 2>$null

if (-not $LatestTag) {
    Write-Error "No Git tag found. Please create a tag first (e.g., git tag v1.0.0)"
    exit 1
}

# Remove 'v' prefix to get version
$Version = $LatestTag -replace '^v', ''

Write-Host "Latest Git tag: $LatestTag" -ForegroundColor Green
Write-Host "Extracted version: $Version" -ForegroundColor Green

# File paths
$PubspecPath = Join-Path $ProjectRoot "pubspec.yaml"
$AppConstantsPath = Join-Path $ProjectRoot "lib\core\constants\app_constants.dart"

# 1. Update pubspec.yaml
if (Test-Path $PubspecPath) {
    $PubspecContent = Get-Content $PubspecPath -Raw
    $CurrentPubspecVersion = [regex]::Match($PubspecContent, '^version:\s*(.+)$', [System.Text.RegularExpressions.RegexOptions]::Multiline).Groups[1].Value.Trim()

    Write-Host ""
    Write-Host "Current pubspec.yaml version: $CurrentPubspecVersion" -ForegroundColor Yellow

    if ($CurrentPubspecVersion -ne $Version) {
        if ($DryRun) {
            Write-Host "[DryRun] Would update pubspec.yaml to: $Version" -ForegroundColor Cyan
        } else {
            $NewPubspecContent = $PubspecContent -replace '^version:\s*.+$', "version: $Version"
            Set-Content $PubspecPath $NewPubspecContent -NoNewline
            Write-Host "OK pubspec.yaml updated to: $Version" -ForegroundColor Green
        }
    } else {
        Write-Host "OK pubspec.yaml is already up to date" -ForegroundColor Green
    }
} else {
    Write-Error "pubspec.yaml not found"
}

# 2. Update app_constants.dart
if (Test-Path $AppConstantsPath) {
    $AppConstantsContent = Get-Content $AppConstantsPath -Raw
    $CurrentAppVersion = [regex]::Match($AppConstantsContent, "static const String appVersion = '(.+?)';").Groups[1].Value

    Write-Host ""
    Write-Host "Current app_constants.dart version: $CurrentAppVersion" -ForegroundColor Yellow

    if ($CurrentAppVersion -ne $Version) {
        if ($DryRun) {
            Write-Host "[DryRun] Would update app_constants.dart to: $Version" -ForegroundColor Cyan
        } else {
            $NewAppConstantsContent = $AppConstantsContent -replace "static const String appVersion = '(.+?)';", "static const String appVersion = '$Version';"
            Set-Content $AppConstantsPath $NewAppConstantsContent -NoNewline
            Write-Host "OK app_constants.dart updated to: $Version" -ForegroundColor Green
        }
    } else {
        Write-Host "OK app_constants.dart is already up to date" -ForegroundColor Green
    }
} else {
    Write-Error "app_constants.dart not found"
}

Write-Host ""
Write-Host "=== Version Sync Complete ===" -ForegroundColor Cyan

# Show current Git status
Write-Host ""
Write-Host "Git Status:" -ForegroundColor Gray
git status --short
