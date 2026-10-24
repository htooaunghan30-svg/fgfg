param(
  [string]$Kid = "license-ed25519-2026-01",
  [string]$OutDir = "supabase\keys",
  [string]$ClientHeaderValue = "",
  [string]$SupabaseAnonKey = "",
  [string]$AppSignatureSha256 = "",
  [string]$ExpectedPackageId = "com.example.healthy_life",
  [string]$LicensePrefix = "HF",
  [switch]$RunSupabase,
  [switch]$RunFlutterBuild
)

$ErrorActionPreference = "Stop"

function Require-Command([string]$Name) {
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Missing required command: $Name"
  }
}

Write-Host "== License Signing One-Time Setup ==" -ForegroundColor Cyan

Require-Command node

if ($RunSupabase) {
  Require-Command supabase
}

if ($RunFlutterBuild) {
  Require-Command flutter
}

if (-not (Test-Path $OutDir)) {
  New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
}

Write-Host "Generating Ed25519 keypair with Node..." -ForegroundColor Yellow
$nodeOutput = node -e "const {generateKeyPairSync}=require('crypto');const kp=generateKeyPairSync('ed25519');console.log('PUB='+kp.publicKey.export({type:'spki',format:'der'}).toString('base64'));console.log('PRIV='+kp.privateKey.export({type:'pkcs8',format:'der'}).toString('base64'));"

$pubLine = ($nodeOutput | Where-Object { $_ -like "PUB=*" } | Select-Object -First 1)
$privLine = ($nodeOutput | Where-Object { $_ -like "PRIV=*" } | Select-Object -First 1)

if (-not $pubLine -or -not $privLine) {
  throw "Failed to parse Node key generation output."
}

$pub = $pubLine.Substring(4).Trim()
$priv = $privLine.Substring(5).Trim()

$pubPath = Join-Path $OutDir "public_key.b64.txt"
$privPath = Join-Path $OutDir "private_key.b64.txt"
$envPath = Join-Path $OutDir "license_signing.env"
$buildHintPath = Join-Path $OutDir "flutter_build_command.txt"
$definesPath = Join-Path $OutDir "flutter_defines.json"

Set-Content -Path $pubPath -Value $pub -NoNewline
Set-Content -Path $privPath -Value $priv -NoNewline

$envContent = @(
  "LICENSE_SIGN_KID=$Kid"
  "LICENSE_SIGN_PRIVATE_KEY_B64=$priv"
  "LICENSE_SIGN_PUBKEY_B64=$pub"
)
if ($ClientHeaderValue) {
  $envContent += "HF_CLIENT_HEADER_VALUE=$ClientHeaderValue"
}
if ($SupabaseAnonKey) {
  $envContent += "SUPABASE_ANON_KEY=$SupabaseAnonKey"
}
Set-Content -Path $envPath -Value $envContent

$appSigNormalized = ""
if ($AppSignatureSha256) {
  $appSigNormalized = $AppSignatureSha256.ToUpper().Replace(':','')
}

$defines = [ordered]@{
  LICENSE_SIGN_PUBKEY_B64 = $pub
  EXPECTED_PACKAGE_ID = $ExpectedPackageId
  LICENSE_PREFIX = $LicensePrefix
}
if ($appSigNormalized) {
  $defines["APP_SIGNATURE_SHA256"] = $appSigNormalized
}
if ($SupabaseAnonKey) {
  $defines["SUPABASE_ANON_KEY"] = $SupabaseAnonKey
}

$defines | ConvertTo-Json | Set-Content -Path $definesPath

$flutterBuild = "flutter build apk --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=$definesPath"
Set-Content -Path $buildHintPath -Value $flutterBuild

Write-Host "Saved keys:" -ForegroundColor Green
Write-Host "  Public : $pubPath"
Write-Host "  Private: $privPath"
Write-Host "  Env    : $envPath"
Write-Host "  Defines: $definesPath"
Write-Host ""

if ($RunSupabase) {
  Write-Host "Applying Supabase migration..." -ForegroundColor Yellow
  supabase db push

  Write-Host "Setting Supabase secrets..." -ForegroundColor Yellow
  supabase secrets set LICENSE_SIGN_KID=$Kid
  supabase secrets set LICENSE_SIGN_PRIVATE_KEY_B64=$priv
  if ($ClientHeaderValue) {
    supabase secrets set HF_CLIENT_HEADER_VALUE=$ClientHeaderValue
  } else {
    Write-Host "Skip HF_CLIENT_HEADER_VALUE (empty). Set it manually if needed." -ForegroundColor DarkYellow
  }

  Write-Host "Deploying Edge Function verify-license..." -ForegroundColor Yellow
  supabase functions deploy verify-license
}

if ($RunFlutterBuild) {
  Write-Host "Running Flutter build..." -ForegroundColor Yellow
  if (-not $AppSignatureSha256) {
    Write-Host "WARNING: APP_SIGNATURE_SHA256 is missing. Release integrity checks will fail and license activation can be blocked." -ForegroundColor Red
  }
  Invoke-Expression $flutterBuild
} else {
  Write-Host "Flutter build command:" -ForegroundColor Cyan
  Write-Host "  $flutterBuild"
  if (-not $AppSignatureSha256) {
    Write-Host "WARNING: Add -AppSignatureSha256 to avoid 'Missing APP_SIGNATURE_SHA256 configuration.' in release." -ForegroundColor Red
  }
  if (-not $SupabaseAnonKey) {
    Write-Host "WARNING: Add -SupabaseAnonKey to avoid 'Missing authorization header' from verify-license." -ForegroundColor Red
  }
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
