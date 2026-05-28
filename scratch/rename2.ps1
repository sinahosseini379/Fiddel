$ErrorActionPreference = "Stop"

$basePath = "c:\Users\sinah\OneDrive\اسناد\GitHub\Fiddel\luci-app-fiddel"

Write-Host "Phase 2: Fixing remaining passwall/PassWall references..."

$files = Get-ChildItem -Path $basePath -Recurse -File | Where-Object { $_.FullName -notmatch '\\\.git\\' }
foreach ($file in $files) {
    try {
        $content = [System.IO.File]::ReadAllText($file.FullName)
        $original = $content
        
        # Display strings - branding
        $content = $content -replace 'PassWall 2', 'Fiddel'
        $content = $content -replace 'PassWall2', 'Fiddel'
        $content = $content -replace 'Passwall\(2\)', 'Fiddel'
        
        # Internal logic identifiers
        $content = $content -replace 'passwall_logic', 'fiddel_logic'
        
        # Comments
        $content = $content -replace 'Passwall Inner implement', 'Fiddel Inner implement'
        $content = $content -replace 'passwall ', 'fiddel '
        
        # Copyright / Organization names
        $content = $content -replace 'Openwrt-Passwall Organization', 'Fiddel Organization'
        $content = $content -replace 'Openwrt-Passwall', 'Fiddel'
        
        # Makefile LUCI_TITLE
        $content = $content -replace 'LuCI support for Fiddel', 'LuCI support for Fiddel'
        
        if ($content -ne $original) {
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
            Write-Host "Fixed: $($file.FullName)"
        }
    } catch {
        Write-Host "Skipped: $($file.FullName) - $_"
    }
}

Write-Host "Phase 2 Done!"
