[CmdletBinding()]
param()

$exclude = @(
    'C:\Windows',
    'C:\Program Files',
    'C:\Program Files (x86)',
    'C:\ProgramData',
    'C:\Users'
) | ForEach-Object { $_.TrimEnd('\') + '\' }

$desktop = [Environment]::GetFolderPath('Desktop')

if (-not (Test-Path $desktop)) {
    New-Item -ItemType Directory -Path $desktop | Out-Null
}

Write-Verbose "Desktop folder = $desktop"
Write-Verbose "Starting scan of C:\ for empty folders..."

$dirs = Get-ChildItem -Path C:\ -Directory -Recurse -ErrorAction SilentlyContinue
$total = $dirs.Count
$i = 0

$allEmpty = foreach ($dir in $dirs) {
    $i++
    $percent = if ($total -gt 0) { [int](100 * $i / $total) } else { 0 }

    Write-Progress `
        -Activity 'Finding empty folders' `
        -Status "Checking $($dir.FullName)" `
        -CurrentOperation "Folder $i of $total" `
        -PercentComplete $percent

    if ((Get-ChildItem $dir.FullName -Force -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
        Write-Verbose "Empty folder: $($dir.FullName)"
        [pscustomobject]@{ FullName = $dir.FullName }
    }
}

Write-Progress -Activity 'Finding empty folders' -Completed

# Export full list
$allEmpty | Export-Csv -Path (Join-Path $desktop 'EmptyFolders.csv') -NoTypeInformation

# Filter out protected roots
$safeToDelete = $allEmpty | Where-Object {
    $path = $_.FullName
    -not ($exclude | ForEach-Object {
        $path.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase)
    })
}

# Export safe list
$safeToDelete | Export-Csv -Path (Join-Path $desktop 'SafeToDelete.csv') -NoTypeInformation
