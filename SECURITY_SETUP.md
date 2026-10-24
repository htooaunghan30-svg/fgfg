# Premium License Security Setup

This app now uses a hardened premium license flow:

- Server-side verification on Supabase `verify-license`
- Encrypted local storage via `flutter_secure_storage`
- App signature/package integrity checks at startup
- TLS certificate pinning for license requests
- Polymorphic validation shards for local tamper checks

## Required Build Defines

Set these on release builds:

```powershell
flutter build apk --release --obfuscate --split-debug-info=build/symbols ^
  --dart-define=SUPABASE_PROJECT_REF=YOUR-PROJECT-REF ^
  --dart-define=LICENSE_PREFIX=HF ^
  --dart-define=EXPECTED_PACKAGE_ID=com.example.healthy_life ^
  --dart-define=APP_SIGNATURE_SHA256=YOUR_RELEASE_CERT_SHA256 ^
  --dart-define=LICENSE_TLS_PINS=PIN1_SHA256,PIN2_SHA256
```

For iOS:

```powershell
flutter build ipa --release --obfuscate --split-debug-info=build/symbols ^
  --dart-define=SUPABASE_PROJECT_REF=YOUR-PROJECT-REF ^
  --dart-define=LICENSE_PREFIX=HF ^
  --dart-define=LICENSE_TLS_PINS=PIN1_SHA256,PIN2_SHA256
```

## URL Obfuscation Options

Priority order in app:

1. `LICENSE_VERIFY_URL_ENC` + `LICENSE_VERIFY_URL_KEY`
2. `SUPABASE_PROJECT_REF` (URL assembled from obfuscated parts)
3. `LICENSE_VERIFY_URL` (plain fallback)

Generate encrypted URL value:

```powershell
$u='https://YOUR-PROJECT-REF.functions.supabase.co/verify-license'
$k='YOUR_STRONG_KEY'
$ub=[Text.Encoding]::UTF8.GetBytes($u)
$kb=[Text.Encoding]::UTF8.GetBytes($k)
$out=New-Object byte[] $ub.Length
for($i=0;$i -lt $ub.Length;$i++){ $out[$i] = $ub[$i] -bxor $kb[$i % $kb.Length] -bxor (($i*31)%251) }
[Convert]::ToBase64String($out)
```

Then build with:

```powershell
--dart-define=LICENSE_VERIFY_URL_ENC=OUTPUT_VALUE --dart-define=LICENSE_VERIFY_URL_KEY=YOUR_STRONG_KEY
```

## TLS Pins

Use SHA-256 fingerprint without colons, uppercase.

Get pin example:

```powershell
openssl s_client -connect YOUR-PROJECT-REF.functions.supabase.co:443 -servername YOUR-PROJECT-REF.functions.supabase.co < NUL | openssl x509 -noout -fingerprint -sha256
```

## Android Signature Value

Use your release keystore certificate SHA-256 (uppercase, no colons):

```powershell
keytool -list -v -keystore YOUR_RELEASE_KEYSTORE.jks -alias YOUR_ALIAS
```

## Important

- Do not ship with debug signing in release.
- Keep Supabase `SERVICE_ROLE_KEY` and `LICENSE_PEPPER` only on backend.
- Rotate pins and app signatures with planned update windows.
