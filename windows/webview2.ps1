param(
    [ValidateSet('win-x64','win-arm64')][string]$Runtime = "win-$([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString().ToLowerInvariant())",
    [Parameter(Mandatory)][string]$Destination
)
$ErrorActionPreference = 'Stop'
$version = '1.0.4258.31'
$cache = Join-Path $PSScriptRoot ".cache/webview2-$version"
$archive = "$cache.zip"
if (-not (Test-Path "$cache/runtimes/$Runtime/native/WebView2Loader.dll")) {
    New-Item -ItemType Directory -Force -Path (Split-Path $cache) | Out-Null
    Invoke-WebRequest "https://api.nuget.org/v3-flatcontainer/microsoft.web.webview2/$version/microsoft.web.webview2.$version.nupkg" -OutFile $archive
    if ((Get-FileHash -Algorithm SHA256 -LiteralPath $archive).Hash.ToLowerInvariant() -ne '56f7f4b8bf9aee4b8efefbbdd4f67d5f74ebd1b100ed0806da71bf76af481aa9') { throw 'WebView2 package checksum mismatch' }
    Expand-Archive -LiteralPath $archive -DestinationPath $cache -Force
}
$loader = "$cache/runtimes/$Runtime/native/WebView2Loader.dll"
$expected = if ($Runtime -eq 'win-arm64') { '4f48cb32d34298c86cca2108057eea0d900b5e422575e926e8086318a0b9cbf0' } else { '3426dcc55fdfb8b5e7ac623cf33b4ccf283fbf68a0c5a65bddfdb4d749a8abee' }
if ((Get-FileHash -Algorithm SHA256 -LiteralPath $loader).Hash.ToLowerInvariant() -ne $expected) { throw 'WebView2 loader checksum mismatch' }
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
Copy-Item -LiteralPath $loader -Destination $Destination -Force
Copy-Item -LiteralPath "$cache/LICENSE.txt" -Destination (Join-Path $Destination 'WebView2-LICENSE.txt') -Force
