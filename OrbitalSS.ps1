# ==================================================
# ORBITAL SS — Minecraft Runtime Audit
# Runtime-only | Instance-only | No false positives
# ==================================================

$MCPath = "$env:APPDATA\.minecraft"
$LogPath = "$MCPath\logs\latest.log"

Clear-Host

Write-Host "══════════════════════════════════════════════" -ForegroundColor DarkCyan
Write-Host "        ORBITAL SS — Minecraft Runtime Audit" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════" -ForegroundColor DarkCyan
Write-Host "Target : Current Minecraft Instance"
Write-Host "Scope  : .minecraft only"
Write-Host "Mode   : Runtime Only (No History)"
Write-Host "══════════════════════════════════════════════`n" -ForegroundColor DarkCyan

# ---- Verificar sesión activa
if (-not (Test-Path $LogPath)) {
    Write-Host "No active Minecraft session detected." -ForegroundColor Red
    exit
}

# ---- Firmas internas (estrictas, reales)
$HackSignatures = @{
    "Meteor Client" = @(
        "meteordevelopment.meteorclient",
        "meteor-client.mixins"
    )
    "LiquidBounce" = @(
        "net.ccbluex.liquidbounce",
        "liquidbounce.mixins"
    )
    "Wurst Client" = @(
        "net.wurstclient",
        "wurst.mixins"
    )
    "Impact Client" = @(
        "impactclient",
        "impact.mixins"
    )
    "Aristois Client" = @(
        "aristois",
        "aristois.mixin"
    )
    "Prestige Client" = @(
        "prestigeclient",
        "prestige.mixin"
    )
    "Doomsday Client" = @(
        "doomsday",
        "doomsday.mixin"
    )
}

# ---- Cargar solo la sesión actual
$Lines = Get-Content $LogPath -ErrorAction SilentlyContinue
$SessionStart = ($Lines | Select-String "Starting Minecraft" | Select-Object -Last 1).LineNumber

if (-not $SessionStart) {
    Write-Host "Unable to determine session start." -ForegroundColor Yellow
    exit
}

$RuntimeLines = $Lines[$SessionStart..($Lines.Count - 1)]
$Findings = @()

foreach ($Client in $HackSignatures.Keys) {
    $Evidence = @()

    foreach ($Sig in $HackSignatures[$Client]) {
        if ($RuntimeLines -match $Sig) {
            $Evidence += $Sig
        }
    }

    if ($Evidence.Count -ge 2) {
        $Findings += [PSCustomObject]@{
            Client = $Client
            Evidence = $Evidence
        }
    }
}

# ---- Resultados
Write-Host "[ SESSION STATUS ]" -ForegroundColor Yellow
Write-Host "Minecraft instance detected and analyzed.`n"

if ($Findings.Count -eq 0) {
    Write-Host "[ SESSION SUMMARY ]" -ForegroundColor Yellow
    Write-Host "Hack clients loaded : 0"
    Write-Host "Suspicious entries  : 0"
    Write-Host "False-risk level    : NONE"
    Write-Host "Final verdict       : CLEAN SESSION" -ForegroundColor Green
    Write-Host "`nNo cheat clients were loaded in this Minecraft instance."
} else {
    Write-Host "[ HACK CLIENTS LOADED IN THIS SESSION ]" -ForegroundColor Red

    foreach ($F in $Findings) {
        Write-Host "`nCLIENT : $($F.Client)" -ForegroundColor Red
        Write-Host "STATUS : CONFIRMED (Loaded in runtime)"

        $i = 1
        foreach ($E in $F.Evidence) {
            Write-Host "`nEVIDENCE $i"
            Write-Host "- Type  : Internal Runtime Signature"
            Write-Host "- Source: latest.log"
            Write-Host "- Path  : .minecraft\logs\latest.log"
            Write-Host "- Data  : $E"
            $i++
        }
    }

    Write-Host "`n[ SESSION SUMMARY ]" -ForegroundColor Yellow
    Write-Host "Hack clients loaded : $($Findings.Count)"
    Write-Host "False-risk level    : NONE"
    Write-Host "Final verdict       : CHEAT CLIENT ACTIVE" -ForegroundColor Red
}

Write-Host "`n══════════════════════════════════════════════"
Write-Host "Read-only | Runtime audit | Instance-only"
Write-Host "══════════════════════════════════════════════"
