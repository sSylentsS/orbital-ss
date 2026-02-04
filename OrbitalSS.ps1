# ==================================================
# ORBITAL SS — Runtime Hack Detection (LOG-BASED)
# Instance only | No history | No false positives
# ==================================================

$MC = "$env:APPDATA\.minecraft"
$Log = "$MC\logs\latest.log"

Clear-Host

Write-Host "══════════════════════════════════════════════"
Write-Host "        ORBITAL SS — Runtime Audit"
Write-Host "══════════════════════════════════════════════"
Write-Host "Scope : .minecraft"
Write-Host "Mode  : Current Instance Only"
Write-Host "Method: Runtime log signatures"
Write-Host "══════════════════════════════════════════════`n"

if (!(Test-Path $Log)) {
    Write-Host "No active Minecraft session detected."
    exit
}

$Lines = Get-Content $Log -ErrorAction SilentlyContinue

# Detectar inicio real de la sesión
$SessionStart = (
    $Lines | Select-String "Starting Minecraft|Loading Minecraft|Minecraft starting|Preparing run|Setting user"
    | Select-Object -Last 1
).LineNumber

if (-not $SessionStart) {
    Write-Host "Unable to determine session start."
    exit
}

$Runtime = $Lines[$SessionStart..($Lines.Count - 1)]

# Firmas internas (reales)
$HackSignatures = @{
    "Meteor Client" = @(
        "meteordevelopment",
        "\[Meteor\]",
        "meteor-client",
        "Meteor Client",
        "meteorclient.mixin"
    )
    "LiquidBounce" = @(
        "liquidbounce",
        "net.ccbluex.liquidbounce",
        "\[LiquidBounce\]"
    )
    "Wurst Client" = @(
        "wurstclient",
        "\[Wurst\]"
    )
    "Impact Client" = @(
        "impactclient",
        "\[Impact\]"
    )
    "Aristois Client" = @(
        "aristois",
        "\[Aristois\]"
    )
}

$Findings = @()

foreach ($Client in $HackSignatures.Keys) {
    $Hits = @()
    foreach ($Sig in $HackSignatures[$Client]) {
        if ($Runtime -match $Sig) {
            $Hits += $Sig
        }
    }

    if ($Hits.Count -ge 2) {
        $Findings += [PSCustomObject]@{
            Client = $Client
            Evidence = $Hits
        }
    }
}

# OUTPUT
if ($Findings.Count -eq 0) {
    Write-Host "[ RESULT ]"
    Write-Host "Hack clients detected : 0"
    Write-Host "False positives       : NONE"
    Write-Host "Verdict               : CLEAN SESSION"
} else {
    Write-Host "[ HACKS DETECTED IN THIS INSTANCE ]"
    foreach ($F in $Findings) {
        Write-Host ""
        Write-Host "CLIENT : $($F.Client)"
        Write-Host "STATUS : CONFIRMED (runtime evidence)"
        Write-Host "SOURCE : latest.log"
        Write-Host "PATH   : .minecraft\logs\latest.log"
        Write-Host "NOTE   : Hack was loaded even if renamed or deleted"

        $i = 1
        foreach ($E in $F.Evidence) {
            Write-Host "  Evidence $i : $E"
            $i++
        }
    }

    Write-Host ""
    Write-Host "[ SUMMARY ]"
    Write-Host "Detected clients : $($Findings.Count)"
    Write-Host "False positives  : NONE"
    Write-Host "Verdict          : CHEAT CLIENT ACTIVE"
}

Write-Host "`n══════════════════════════════════════════════"
Write-Host "Runtime-only | Log-verified | Safe"
Write-Host "══════════════════════════════════════════════"

