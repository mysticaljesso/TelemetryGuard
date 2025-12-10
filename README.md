# TelemetryGuard

**Protecting privacy with WER‑level reporting**

TelemetryGuard is a lightweight PowerShell tool that enforces Windows Error Reporting–style diagnostics across Windows, Office, and Visual Studio. It strips telemetry down to crash logs, licensing checks, and update readiness only.

This project was co‑created with AI assistance to identify the correct registry values and Group Policy settings, and to help write documentation.

---

## ✨ Features
- Dual logging: all output goes to both console and `debug.txt`
- Edition‑aware: detects Windows Enterprise, Education, Professional, or Home and applies the correct telemetry level
- Registry enforcement for Windows, Office, and Visual Studio
- Group Policy equivalents printed alongside registry values
- Exception handling with clear success/failure reporting
- Summary block at the end of each run

---

## 🖥️ Compatibility Matrix

| Product / Edition        | Registry Setting Honored? | Effective Telemetry Level | Notes                                                                 |
|---------------------------|---------------------------|---------------------------|----------------------------------------------------------------------|
| Windows 11 Enterprise     | ✅ Yes (AllowTelemetry=0) | Required only (WER‑style) | Full enforcement: crash/error reports, licensing checks, update readiness only |
| Windows 11 Education      | ✅ Yes (AllowTelemetry=0) | Required only (WER‑style) | Same enforcement as Enterprise                                       |
| Windows 11 Professional   | ⚠️ Ignored (0 → forced 1) | Basic                     | Cannot enforce Required only; Basic telemetry still runs             |
| Windows 11 Home           | ❌ Ignored (≥3)           | Full                      | Telemetry cannot be reduced below Full                               |
| Office 2016+ / 365        | ✅ Yes (SendTelemetry=0)  | Disabled                  | Key honored in modern Office builds; older versions may ignore       |
| Visual Studio 2015+       | ✅ Yes (OptIn=0)          | Disabled                  | Applies to Community, Professional, Enterprise editions              |

---

## ⚙️ System Requirements
- Windows 11 Enterprise or Education recommended
- PowerShell 5.1 or later
- Administrator privileges required to apply registry changes

---

## 🚀 Usage
1. Save `TelemetryGuard.ps1` to a folder.
2. Open PowerShell as Administrator.
3. Run the script:
   ```powershell
   .\TelemetryGuard.ps1
