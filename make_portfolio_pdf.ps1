# Converts portfolio_v15.html -> portfolio_v15.pdf using your local Chrome (or Edge).
# Run this in your OWN PowerShell window (not inside the Claude sandbox):
#   powershell -ExecutionPolicy Bypass -File "C:\Users\blusb\data\repos\portfolio\make_portfolio_pdf.ps1"
$ErrorActionPreference = 'Stop'
$html = 'C:\Users\blusb\data\repos\portfolio\portfolio_v15.html'
$pdf  = 'C:\Users\blusb\data\repos\portfolio\portfolio_v15.pdf'

$candidates = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LocalAppData\Google\Chrome\Application\chrome.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
)
$browser = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { Write-Host 'No Chrome or Edge found.' -ForegroundColor Red; exit 1 }
Write-Host "Using: $browser"

$url = 'file:///' + ($html.Replace('\','/'))
if (Test-Path $pdf) { Remove-Item $pdf -Force }

& $browser --headless --disable-gpu --no-pdf-header-footer --run-all-compositor-stages-before-draw --print-to-pdf="$pdf" $url 2>$null
Start-Sleep -Seconds 2

if (Test-Path $pdf) {
  $mb = (Get-Item $pdf).Length / 1MB
  Write-Host ("OK -> {0}  ({1:N1} MB)" -f $pdf, $mb) -ForegroundColor Green
  Start-Process $pdf
} else {
  Write-Host 'Conversion failed. Fallback: open the HTML in Chrome and use Ctrl+P -> Save as PDF (Margins: None, Background graphics: ON).' -ForegroundColor Yellow
}
