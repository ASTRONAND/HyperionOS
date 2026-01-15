$testRoot = Join-Path $PSScriptRoot "..\src"
$buildRoot = Join-Path $PSScriptRoot "..\Build"

$testRoot = Resolve-Path $testRoot

# Clean Build folder
if (Test-Path $buildRoot) {
    Remove-Item -LiteralPath $buildRoot -Recurse -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Path $buildRoot | Out-Null

Write-Host "Building from $testRoot"
Write-Host "Output to      $buildRoot"
Write-Host ""

# Each top-level folder in test/
Get-ChildItem -Path $testRoot -Directory | ForEach-Object {

    $folderRoot = $_.FullName
    Write-Host "== Package: $($_.Name) =="

    # Walk files inside this folder
    Get-ChildItem -Path $folderRoot -File -Recurse | ForEach-Object {

        $src = $_.FullName
        $rel = $src.Substring($folderRoot.Length).TrimStart("\")
        $dst = Join-Path $buildRoot $rel
        $dstDir = Split-Path $dst

        if (-not (Test-Path $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }

        Write-Host "Processing: $rel"
        Write-Host "  > Copying"
        Copy-Item -LiteralPath $src -Destination $dst -Force
        
    }

    Write-Host ""
}

Write-Host "Build complete."


$testRoot = Join-Path $PSScriptRoot "..\test"
$buildRoot = Join-Path $PSScriptRoot "..\Build"

$testRoot = Resolve-Path $testRoot

Write-Host "Building from $testRoot"
Write-Host "Output to      $buildRoot"
Write-Host ""

# Each top-level folder in test/
Get-ChildItem -Path $testRoot -Directory | ForEach-Object {

    $folderRoot = $_.FullName
    Write-Host "== Package: $($_.Name) =="

    # Walk files inside this folder
    Get-ChildItem -Path $folderRoot -File -Recurse | ForEach-Object {

        $src = $_.FullName
        $rel = $src.Substring($folderRoot.Length).TrimStart("\")
        $dst = Join-Path $buildRoot $rel
        $dstDir = Split-Path $dst

        if (-not (Test-Path $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }

        Write-Host "Processing: $rel"

        Write-Host "  > Copying"
        Copy-Item -LiteralPath $src -Destination $dst -Force
    }

    Write-Host ""
}

Write-Host "Build complete."
