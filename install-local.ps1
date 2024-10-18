[CmdletBinding()]
param(
  [string]$Destination
)

# Get version name
$tomlFile = ".\typst.toml"
$versionPattern = 'version\s*=\s*"(\d).(\d).(\d)"'
$namePattern = 'name\s*=\s*"(.*)"'
Get-Content $tomlFile | ForEach-Object {
  if ($_ -match $versionPattern) {
    $major = $matches[1]
    $minor = $matches[2]
    $patch = $matches[3]
    $version = "$major.$minor.$patch"
  } elseif ($_ -match $namePattern) {
    $name = $Matches[1]
  }
}

# Get destination
if ($Destination -eq "") {
  $userName = [System.Environment]::UserName
  $typstLocation = "C:\Users\${userName}\AppData\Local\typst\"
  $packLocation = "${typstLocation}\packages\local\${name}\${version}\"
} else {
  $packLocation = $Destination
}

# Create destination if not exist.
if (Test-Path $packLocation -PathType Container) {
  Write-Host "Package ${packLocation} already exists."
} else {
  Write-Host "Package ${packLocation} does not exists. Create folder."
  New-Item -ItemType Directory $packLocation -Force | Out-Null
  New-Item -ItemType Directory "$packLocation\src\" -Force | Out-Null
}

# Copy src folder, typst.toml and README.md
Copy-Item -Path ".\src\*.typ" -Destination "$packLocation\src" -Recurse
Copy-Item ".\typst.toml" -Destination $packLocation
Copy-Item ".\README.md" -Destination $packLocation
