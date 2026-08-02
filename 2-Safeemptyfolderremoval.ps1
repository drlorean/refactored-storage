$csv = Join-Path ([Environment]::GetFolderPath('Desktop')) 'SafeToDelete.csv'

if (Test-Path $csv) {
    Write-Host "Reading delete list from $csv" -ForegroundColor Cyan

    $items = Import-Csv $csv
    Write-Host "Found $($items.Count) item(s) to process." -ForegroundColor Cyan

    foreach ($item in $items) {
        $target = $item.FullName

        if ([string]::IsNullOrWhiteSpace($target)) {
            Write-Warning "Skipping row with no FullName value."
            continue
        }

        Write-Host "Processing: $target" -ForegroundColor Yellow

        if (Test-Path $target) {
            try {
                Remove-Item $target -Force -ErrorAction Stop
                Write-Host "Removed: $target" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to remove ${target}: $($_.Exception.Message)"
            }
        }
        else {
            Write-Host "Not found, skipping: $target" -ForegroundColor DarkYellow
        }
    }
}
else {
    Write-Error "CSV not found: $csv"
}
