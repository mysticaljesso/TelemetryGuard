# TelemetryGuard - Protecting privacy with WER‑level reporting.
# A lightweight PowerShell tool that enforces Windows Error Reporting–style diagnostics across Windows, Office, and Visual Studio,
# stripping telemetry down to crash logs, licensing checks, and update readiness only.
# Copyright © Jessica Amy 2025

$logPath = "$PSScriptRoot\debug.txt"

function Write-Log {
    param([string]$message)
    Write-Host $message
    Add-Content -Path $logPath -Value $message
}

# Track results
$windowsResult = "Not attempted"
$officeResult = "Not attempted"
$vsResult = "Not attempted"

# Banner
Write-Log "TelemetryGuard - Protecting privacy with WER‑level reporting."
Write-Log "A lightweight PowerShell tool that enforces Windows Error Reporting–style diagnostics across Windows, Office, and Visual Studio."
Write-Log "Copyright © Jessica Amy 2025"
Write-Log "Run started at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Log "------------------------------------------------------------"

# --- Windows ---
try {
    Write-Log "[Windows] Limiting telemetry and disabling error reporting..."
    $winTelemetryPath = "HKLM:\Software\Policies\Microsoft\Windows\DataCollection"
    $werPath = "HKLM:\Software\Microsoft\Windows\Windows Error Reporting"
    $werPolicyPath = "HKLM:\Software\Policies\Microsoft\Windows\Windows Error Reporting"

    if (-not (Test-Path $winTelemetryPath)) { New-Item -Path $winTelemetryPath -Force | Out-Null }
    if (-not (Test-Path $werPath)) { New-Item -Path $werPath -Force | Out-Null }
    if (-not (Test-Path $werPolicyPath)) { New-Item -Path $werPolicyPath -Force | Out-Null }

    $edition = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID

    if ($edition -like "*Enterprise*" -or $edition -like "*Education*") {
        Set-ItemProperty -Path $winTelemetryPath -Name "AllowTelemetry" -Value 0
        Write-Log "Windows edition detected: $edition. Telemetry set to Required only (0)."
    }
    elseif ($edition -like "*Professional*") {
        Set-ItemProperty -Path $winTelemetryPath -Name "AllowTelemetry" -Value 1
        Write-Log "Windows edition detected: Professional. Telemetry forced to Basic (1). Required only (0) not supported."
    }
    else {
        Set-ItemProperty -Path $winTelemetryPath -Name "AllowTelemetry" -Value 3
        Write-Log "Windows edition detected: $edition. Telemetry cannot be reduced below Full (3)."
    }

    Set-ItemProperty -Path $werPath -Name "Disabled" -Value 1
    Set-ItemProperty -Path $werPolicyPath -Name "DontShowUI" -Value 1

    $telemetry = (Get-ItemProperty -Path $winTelemetryPath).AllowTelemetry
    $disabled = (Get-ItemProperty -Path $werPath).Disabled
    $dontShowUI = (Get-ItemProperty -Path $werPolicyPath).DontShowUI

    Write-Log "Registry Key: $winTelemetryPath → AllowTelemetry=$telemetry"
    Write-Log "Group Policy: Allow Telemetry → $telemetry"
    Write-Log "Registry Key: $werPath → Disabled=$disabled"
    Write-Log "Group Policy: Disable Windows Error Reporting → $disabled"
    Write-Log "Registry Key: $werPolicyPath → DontShowUI=$dontShowUI"
    Write-Log "Group Policy: Do not show UI → $dontShowUI"

    if (($edition -like "*Enterprise*" -or $edition -like "*Education*") -and $telemetry -eq 0 -and $disabled -eq 1 -and $dontShowUI -eq 1) {
        $windowsResult = "Success (WER-level)"
    }
    elseif ($edition -like "*Professional*" -and $telemetry -eq 1) {
        $windowsResult = "Success (Basic only)"
    }
    elseif ($telemetry -eq 3) {
        $windowsResult = "Limited (Full telemetry enforced)"
    }
    else {
        $windowsResult = "Failed"
    }
} catch {
    $windowsResult = "Error"
    Write-Log "Exception while applying Windows settings: $($_.Exception.Message)"
}

# --- Office ---
try {
    Write-Log "[Office] Limiting telemetry..."
    $officePath = "HKCU:\Software\Policies\Microsoft\Office\Common"
    if (-not (Test-Path $officePath)) { New-Item -Path $officePath -Force | Out-Null }
    Set-ItemProperty -Path $officePath -Name "SendTelemetry" -Value 0

    $sendTelemetry = (Get-ItemProperty -Path $officePath).SendTelemetry
    Write-Log "Registry Key: $officePath → SendTelemetry=$sendTelemetry"
    Write-Log "Group Policy: Configure telemetry settings → $sendTelemetry"

    if ($sendTelemetry -eq 0) {
        $officeResult = "Success"
    } else {
        $officeResult = "Failed"
    }
} catch {
    $officeResult = "Error"
    Write-Log "Exception while applying Office settings: $($_.Exception.Message)"
}

# --- Visual Studio ---
try {
    Write-Log "[Visual Studio] Limiting telemetry..."
    $vsPath = "HKCU:\Software\Microsoft\VisualStudio\Telemetry"
    if (-not (Test-Path $vsPath)) { New-Item -Path $vsPath -Force | Out-Null }
    Set-ItemProperty -Path $vsPath -Name "OptIn" -Value 0

    $optIn = (Get-ItemProperty -Path $vsPath).OptIn
    Write-Log "Registry Key: $vsPath → OptIn=$optIn"
    Write-Log "Group Policy: Disable Experience Improvement Program → $optIn"

    if ($optIn -eq 0) {
        $vsResult = "Success"
    } else {
        $vsResult = "Failed"
    }
} catch {
    $vsResult = "Error"
    Write-Log "Exception while applying Visual Studio settings: $($_.Exception.Message)"
}

# --- Summary ---
Write-Log "------------------------------------------------------------"
Write-Log "Summary of TelemetryGuard run:"
Write-Log "Windows: $windowsResult"
Write-Log "Office: $officeResult"
Write-Log "Visual Studio: $vsResult"
Write-Log "Run completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
