# Run GUT tests (headless) — saved working command
# Usage: Open PowerShell in the repo root and run: .\tools\run_gut.ps1
# Adjust $GodotExe if your Godot executable path differs.

$GodotExe = "C:\Program Files\Godot\Godot_v4.7.2-rc1_win64_console.exe"
$GutScript = "sources\addons\gut\gut_cmdln.gd"

if (-not (Test-Path $GodotExe)) {
    Write-Error "Godot executable not found at: $GodotExe"
    exit 1
}
if (-not (Test-Path $GutScript)) {
    Write-Error "GUT script not found at: $GutScript"
    exit 2
}

Write-Output "Using Godot: $GodotExe"
Write-Output "Using GUT script: $GutScript"
Write-Output "Running: $GodotExe --headless --path sources -s $GutScript -- '-gdir=res://tests' '-gexit'"

# Direct invocation (works reliably in this environment)
& "$GodotExe" --headless --path sources -s "$GutScript" -- '-gdir=res://tests' '-gexit'

exit $LASTEXITCODE
