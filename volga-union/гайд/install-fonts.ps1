$ErrorActionPreference = 'Stop'
$fontTarget = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
New-Item -ItemType Directory -Force -Path $fontTarget | Out-Null
$registry = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
New-Item -Path $registry -Force | Out-Null
Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class VolgaFonts { [DllImport("gdi32.dll", CharSet=CharSet.Unicode)] public static extern int AddFontResourceEx(string path, uint flags, IntPtr reserved); [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern IntPtr SendMessageTimeout(IntPtr hwnd, uint msg, UIntPtr w, IntPtr l, uint flags, uint timeout, out UIntPtr result); }'
Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'шрифты') -Recurse -Filter '*.ttf' | ForEach-Object {
    $target = Join-Path $fontTarget $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $target -Force
    New-ItemProperty -Path $registry -Name ($_.BaseName + ' (TrueType)') -Value $target -PropertyType String -Force | Out-Null
    $loaded = [VolgaFonts]::AddFontResourceEx($target, 0, [IntPtr]::Zero)
    Write-Output "$($_.Name): registered; loaded=$loaded"
}
$result = [UIntPtr]::Zero
[VolgaFonts]::SendMessageTimeout([IntPtr]0xffff, 0x001d, [UIntPtr]::Zero, [IntPtr]::Zero, 2, 1000, [ref]$result) | Out-Null
