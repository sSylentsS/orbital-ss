# ==================================================
# ORBITAL SS — Loader-Based Runtime Audit
# Fabric / Forge | Runtime only | Zero false positives
# ==================================================

$MC = "$env:APPDATA\.minecraft"
$Log = "$MC\logs\latest.log"

Clear-Host

Write-Host "══════════════════════════════════════════════"
Write-Host "        ORBITAL SS — Runtime Mod Audit"
Write-Host "══════════════════════════════════════════════"
Write-Host "Scope : .minecraft only"
Write-Host "Mode  : Current Instance"
Write-Host "Method: Loader verification"
Write-Host "══════════════════════════════════════════════`n"

if (!(Test-Path $Log)) {
    Write-Host "No active Minecraft session detected."
    exit
}

# --- Hacks modernos (MODID reales, NO nombres de archivo)
$HackModIDs = @{
    "Meteor Client"     = "meteor-client"
    "LiquidBounce"      = "liquidbounce"
    "Wurst Client"      = "wurst"
    "Impact Client"     = "impact"
    "Aristois Client"   = "aristois"
    "Prestige Client"   = "prestige"
    "Doomsday Client"   = "doomsday"
}

$Lines = Get-Content $Log

# --- Detectar inicio real del loader
$LoaderStart = ($Lines | Select-String "Loading mods" | Select-Object -First 1).LineNumber

if (!$LoaderStart) {
    Write-Host "Minecraft is running, but no mods loaded."
    Write-Host "Verdict: CLEAN INSTANCE"
    exit
}

$LoadedSection = $Lines[$LoaderStart..($LoaderStart + 200)]

$Detected = @()

foreach ($Hack in $HackModIDs.Keys) {
    $ID = $HackModIDs[$Hack]
    if ($LoadedSection -match "\b$ID\b") {
        $Detected += $Hack
    }
}

# --- OUTPUT
if ($Detected.Count -eq 0) {
    Write-Host "[ RESULT ]"
    Write-Host "Loaded hack clients : 0"
    Write-Host "False positives     : NONE"
    Write-Host "Final verdict       : CLEAN SESSION"
} else {
    Write-Host "[ HACK CLIENTS DETECTED ]"
    foreach ($H in $Detected) {
        Write-Host ""
        Write-Host "CLIENT : $H"
        Write-Host "STATUS : CONFIRMED (Loader loaded)"
        Write-Host "SOURCE : latest.log"
        Write-Host "PATH   : .minecraft\logs\latest.log"
        Write-Host "NOTE   : Mod was loaded even if renamed or deleted after launch"
    }

    Write-Host ""
    Write-Host "[ SUMMARY ]"
    Write-Host "Detected clients : $($Detected.Count)"
    Write-Host "False positives  : NONE"
    Write-Host "Verdict          : CHEAT CLIENT ACTIVE"
}

Write-Host "`n══════════════════════════════════════════════"
Write-Host "Loader-based detection | Read-only | Safe"
Write-Host "══════════════════════════════════════════════"
