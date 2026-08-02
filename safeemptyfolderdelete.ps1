# --- Find and export empty folders safely ---
$exclude = @(
    'C:\Windows',
    'C:\Program Files',
    'C:\Program Files (x86)',
    'C:\ProgramData',
    'C:\Users'
)

# Find all empty folders
$allEmpty = Get-ChildItem -Path C:\ -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        (Get-ChildItem $_.FullName -Force -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0
    } |
    Select-Object FullName

# Export full list
$allEmpty | Export-Csv -Path "$env:USERPROFILE\Desktop\EmptyFolders.csv" -NoTypeInformation

# Filter out protected roots
$safeToDelete = $allEmpty |
    Where-Object {
        $path = $_.FullName
        -not ($exclude | ForEach-Object { $path.StartsWith($_) })
    }

# Export safe list
$safeToDelete | Export-Csv -Path "$env:USERPROFILE\Desktop\SafeToDelete.csv" -NoTypeInformation

Write-Host "✅ Export complete. Review SafeToDelete.csv before deleting."

# --- Optional cleanup with logging (uncomment to activate) ---
# $logPath = "$env:USERPROFILE\Desktop\DeletedFolders.log"
# Import-Csv "$env:USERPROFILE\Desktop\SafeToDelete.csv" |
#     ForEach-Object {
#         $folder = $_.FullName
#         try {
#             Remove-Item $folder -Force -ErrorAction Stop
#             Add-Content -Path $logPath -Value "Deleted: $folder"
#         } catch {
#             Add-Content -Path $logPath -Value "Skipped (error): $folder"
#         }
#     }
# Write-Host "🧹 Safe folders deleted. Log saved to DeletedFolders.log"
