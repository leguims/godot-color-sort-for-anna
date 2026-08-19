<#
Push helper that runs GUT tests only when the last commit touches .gd/.tscn/.json files.
Usage: From the repo root in PowerShell: .\tools\push_with_tests.ps1
#>

# Configure: path to run_gut script (relative to repo root)
$RunGut = "tools\run_gut.ps1"
$Extensions = @('*.gd','*.tscn','*.json')

function Get-LastCommitFiles {
    # Try to get files changed in last commit (works for normal commits)
    $files = git diff --name-only HEAD~1 HEAD 2>$null | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    if (-not $files) {
        # Fallback: possibly initial commit — list files in HEAD
        $files = git show --name-only --pretty="" HEAD 2>$null | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    }
    return $files
}

# Get current branch
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
Write-Output "Current branch: $branch"

$files = Get-LastCommitFiles
if (-not $files) {
    Write-Output "No files found in last commit. Will push without running tests."
    git push origin $branch
    exit $LASTEXITCODE
}

Write-Output "Files in last commit:`n$($files -join "`n")`n"

# Check if any file matches monitored extensions
$shouldRun = $false
foreach ($f in $files) {
    foreach ($ext in $Extensions) {
        if ($f -like $ext) { $shouldRun = $true; break }
    }
    if ($shouldRun) { break }
}

if (-not $shouldRun) {
    Write-Output "No .gd/.tscn/.json files changed — skipping tests and pushing directly."
    git push origin $branch
    exit $LASTEXITCODE
}

# Ensure run_gut exists
if (-not (Test-Path $RunGut)) {
    Write-Error "run_gut script not found at $RunGut. Aborting push."
    exit 2
}

Write-Output "Detected code/data files changed — running GUT via $RunGut"
& "$RunGut"
$gutExit = $LASTEXITCODE
if ($gutExit -ne 0) {
    Write-Error "GUT tests failed (exit code $gutExit). Aborting push."
    exit $gutExit
}

Write-Output "GUT tests passed — pushing branch $branch to origin"
# Push and set upstream if needed
try {
    $upstream = git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null
} catch {
    $upstream = $null
}
if (-not $upstream) {
    git push --set-upstream origin $branch
} else {
    git push origin $branch
}
exit $LASTEXITCODE
