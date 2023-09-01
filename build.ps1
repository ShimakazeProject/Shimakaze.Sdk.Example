#Requires -Version 7
$pfbase = [System.Environment]::Is64BitOperatingSystem ? ${env:ProgramFiles(x86)} : $env:ProgramFiles
$vswhere = "$pfbase\Microsoft Visual Studio\Installer\vswhere.exe"
$msbuild = & $vswhere -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe | select-object -first 1

if (Test-Path out) {
    Remove-Item out -Recurse -Force | Out-Null
}
New-Item -Type Directory out | Out-Null

# Build Phobos
& $msbuild Phobos\Phobos.sln -p:Configuration=Release -v:m
if ($LASTEXITCODE -ne 0) {
    throw "Phobos Build Failed."
}
Move-Item Phobos\Release\Phobos.* out\ -Force

# Build XNA-CNCNet-Client
. Client\BuildScripts\Build-Ares.ps1
Move-Item Client\Compiled\Ares\Resources out\ -Force

# Build dta-mg-client-launcher
dotnet build ClientLauncher -c:Release
if ($LASTEXITCODE -ne 0) {
    throw "ClientLauncher Build Failed."
}
Move-Item ClientLauncher\bin\Release\net471\* out\ -Force

# Build Mod
dotnet pack Mod -c:Release
if ($LASTEXITCODE -ne 0) {
    throw "Mod Build Failed."
}
Move-Item Mod\bin\Release\*.mix out\ -Force
