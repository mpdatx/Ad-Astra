# Update Ad Astra jars in client and server mod directories.
# Edit these paths before first use.
$ClientModsDir = "C:\mc\client\mods"
$ServerModsDir = "C:\mc\server\mods"

$Repo = "mpdatx/Ad-Astra"
$TempDir = Join-Path $env:TEMP "adastra-update"

# Download latest release jars
Write-Host "Fetching latest release from $Repo..."
Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $TempDir | Out-Null
gh release download --repo $Repo --pattern "*.jar" --dir $TempDir
if ($LASTEXITCODE -ne 0) { Write-Error "gh release download failed"; exit 1 }

$NewJars = Get-ChildItem -Path $TempDir -Filter "*.jar"
if ($NewJars.Count -eq 0) { Write-Error "No jars downloaded"; exit 1 }
Write-Host "Downloaded: $($NewJars.Name -join ', ')"

# Remove old Ad Astra jars and copy new ones into a mod directory
function Update-ModDir($dir) {
    if (-not (Test-Path $dir)) { Write-Warning "Directory not found, skipping: $dir"; return }
    Get-ChildItem -Path $dir -Filter "ad_astra*.jar" | Remove-Item -Force
    foreach ($jar in $NewJars) {
        Copy-Item $jar.FullName -Destination $dir
    }
    Write-Host "Updated: $dir"
}

Update-ModDir $ClientModsDir
Update-ModDir $ServerModsDir

Remove-Item -Recurse -Force $TempDir
Write-Host "Done."
