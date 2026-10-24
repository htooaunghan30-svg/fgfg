param(
  [string]$LicenseKey = 'HF-MWEV-83R4-SGJ7-HSY7',
  [string]$DeviceId = 'manual-test-device',
  [string]$AppVersion = '1.0.0',
  [string]$Platform = 'windows'
)

$projectRef = 'vlkflfffznjgvthysong'
$anon = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZsa2ZsZmZmem5qZ3Z0aHlzb25nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE3MjQ1OTYsImV4cCI6MjA4NzMwMDU5Nn0.TkhamYt4_gUTB1pyRKvjceXRXHypl23bsMYRMjyYsm4'
$clientHeader = 'jhlhle72938hwwueyf88hhehjjJKHUhu00090jkhghgjkgyghjgjhkhhgfydedewdsfcghj8856gjhhgghjghghjg8098jklkhhjkhj'

$urls = @(
  "https://$projectRef.functions.supabase.co/verify-license",
  "https://$projectRef.supabase.co/functions/v1/verify-license"
)

$headers = @{
  'Content-Type'  = 'application/json'
  'Accept'        = 'application/json'
  'x-hf-client'   = $clientHeader
  'Authorization' = "Bearer $anon"
  'apikey'        = $anon
}

$body = @{
  licenseKey = $LicenseKey
  deviceId   = $DeviceId
  appVersion = $AppVersion
  platform   = $Platform
} | ConvertTo-Json -Depth 10

foreach ($url in $urls) {
  "`n============================================================"
  "URL: $url"

  try {
    $resp = Invoke-WebRequest -Uri $url -Method Post -Headers $headers -Body $body -ErrorAction Stop
    $raw = $resp.Content
  }
  catch {
    $resp = $_.Exception.Response
    if (-not $resp) {
      "REQUEST FAILED (no response): $($_.Exception.Message)"
      continue
    }

    $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
    $raw = $reader.ReadToEnd()
    "STATUS: $([int]$resp.StatusCode) $($resp.StatusDescription)"
  }

  "=== RAW BODY ==="
  $raw

  $json = $null
  try { $json = $raw | ConvertFrom-Json } catch {}

  if (-not $json) {
    "Could not parse JSON body."
    continue
  }

  $isSigned = ($null -ne $json.kid -and $null -ne $json.alg -and $null -ne $json.payload -and $null -ne $json.signature)

  "=== ENVELOPE CHECK ==="
  [pscustomobject]@{
    has_kid       = $null -ne $json.kid
    has_alg       = $null -ne $json.alg
    has_payload   = $null -ne $json.payload
    has_signature = $null -ne $json.signature
    detected_type = if ($isSigned) { 'SIGNED_ENVELOPE' } else { 'PLAIN_JSON' }
  } | Format-List | Out-String

  if ($isSigned) {
    $payload = $json.payload
    "=== PAYLOAD ==="
    $payload | ConvertTo-Json -Depth 20
  }
  else {
    "=== PLAIN JSON ==="
    $json | ConvertTo-Json -Depth 20
  }
}
