$ErrorActionPreference = "Stop"

Write-Host "Replacing text contents..."
$files = Get-ChildItem -Path . -Recurse -File | Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\scratch\\' }
foreach ($file in $files) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName)
        if ($content -match '(?i)passwall2') {
            $newContent = $content -creplace 'passwall2', 'fiddel'
            $newContent = $newContent -creplace 'Passwall2', 'Fiddel'
            $newContent = $newContent -creplace 'PASSWALL2', 'FIDDEL'
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBom)
            Write-Host "Updated content in $($file.FullName)"
        }
    } catch {
        Write-Host "Skipped $($file.FullName)"
    }
}

Write-Host "Renaming files..."
$filesToRename = Get-ChildItem -Path . -Recurse -File | Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\scratch\\' -and $_.Name -match '(?i)passwall2' }
foreach ($file in $filesToRename) {
    $newName = $file.Name -creplace 'passwall2', 'fiddel' -creplace 'Passwall2', 'Fiddel'
    Rename-Item -Path $file.FullName -NewName $newName
    Write-Host "Renamed file $($file.Name) to $newName"
}

Write-Host "Renaming directories..."
$dirsToRename = Get-ChildItem -Path . -Recurse -Directory | Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\scratch\\' -and $_.Name -match '(?i)passwall2' } | Sort-Object -Property @{Expression={$_.FullName.Length}; Descending=$true}
foreach ($dir in $dirsToRename) {
    $newName = $dir.Name -creplace 'passwall2', 'fiddel' -creplace 'Passwall2', 'Fiddel'
    Rename-Item -Path $dir.FullName -NewName $newName
    Write-Host "Renamed directory $($dir.Name) to $newName"
}

Write-Host "Done!"
