# indexnow-ping.ps1 — submit URLs to IndexNow after a deploy.
#
# IndexNow is supported by Bing, Yandex, Naver, Seznam, and Yep.
# Google does NOT use IndexNow — they read sitemap.xml + Search Console.
#
# Usage (Windows PowerShell 5.1 — the default on Windows 10/11):
#   powershell -ExecutionPolicy Bypass -File .\tools\indexnow-ping.ps1
#   powershell -ExecutionPolicy Bypass -File .\tools\indexnow-ping.ps1 -Urls "https://onlinecalculator.co.nz/finance/gst-calculator/"
#
# Prerequisite: the key file must already be reachable at:
#   https://onlinecalculator.co.nz/f14f367cd310965f5fa459458e7540e7.txt

[CmdletBinding()]
param(
  [string[]] $Urls,
  [string]   $Host_     = 'onlinecalculator.co.nz',
  [string]   $Key       = 'f14f367cd310965f5fa459458e7540e7',
  [string]   $KeyLocation,
  [string]   $Endpoint  = 'https://api.indexnow.org/IndexNow'
)

$ErrorActionPreference = 'Stop'
# Windows PowerShell 5.1 negotiates TLS 1.0 by default; IndexNow needs TLS 1.2.
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
if (-not $KeyLocation) { $KeyLocation = "https://$Host_/$Key.txt" }

if (-not $Urls -or $Urls.Count -eq 0) {
  $sitemapPath = Join-Path $PSScriptRoot '..\sitemap.xml' | Resolve-Path
  Write-Host "Reading URLs from $sitemapPath"
  [xml]$xml = Get-Content -Path $sitemapPath -Raw -Encoding UTF8
  $Urls = $xml.urlset.url | ForEach-Object { $_.loc }
}

if ($Urls.Count -eq 0) { Write-Error 'No URLs to submit.'; exit 1 }

# IndexNow accepts up to 10,000 URLs per POST. We're well under that.
$payload = @{
  host        = $Host_
  key         = $Key
  keyLocation = $KeyLocation
  urlList     = $Urls
} | ConvertTo-Json -Depth 4

Write-Host "Submitting $($Urls.Count) URLs to IndexNow for host '$Host_'..."
try {
  $resp = Invoke-WebRequest -Uri $Endpoint -Method Post -ContentType 'application/json; charset=utf-8' -Body $payload -UseBasicParsing
  Write-Host "HTTP $($resp.StatusCode) $($resp.StatusDescription)"
  if ($resp.Content) { Write-Host $resp.Content }
} catch {
  $code = $_.Exception.Response.StatusCode.value__
  Write-Warning "IndexNow returned HTTP $code"
  if ($_.Exception.Response) {
    $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
    Write-Warning $reader.ReadToEnd()
  }
  exit 1
}

# IndexNow response codes:
#   200 — URLs submitted successfully
#   202 — Accepted; key validation pending
#   400 — Bad request (malformed)
#   403 — Forbidden (key file missing/wrong contents at keyLocation)
#   422 — Unprocessable (URLs don't match host)
#   429 — Too many requests
