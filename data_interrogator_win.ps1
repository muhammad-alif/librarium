# Omni-Spider Script - For the Omnissiah!

# Directory to start searching
$searchDir = $args[0]
if (-not $searchDir) {
    $searchDir = "C:\"
}

# Log file for results
$logFile = "Omni_Spyder_Results.txt"

# Keywords to search for
$keywords = "username|user|login|password|pass|pwd|secret"

Write-Host "[*] Starting Omni-Spider Scan - For the Omnissiah!"
Write-Host "[*] Searching in directory: $searchDir"
Write-Host "[*] Logging results to: $logFile"

# Start the search
Get-ChildItem -Path $searchDir -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "[*] Scanning file: $($_.FullName)"
    Select-String -Path $_.FullName -Pattern $keywords -CaseSensitive | Out-File -FilePath $logFile -Append
}

# Report findings
Write-Host "[*] Omni-Spider Scan Complete!"
Write-Host "[*] Results have been logged in $logFile"

# Execution Command:
# powershell -ExecutionPolicy Bypass -File .\Omnissiah_Scan.ps1 C:\path\to\search
