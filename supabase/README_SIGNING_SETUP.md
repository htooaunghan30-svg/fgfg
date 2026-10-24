# One-shot setup (Supabase + Flutter)

## 1) Generate Ed25519 keys (local)
Use Node.js:

```bash
node -e "const {generateKeyPairSync}=require('crypto');const kp=generateKeyPairSync('ed25519');console.log('PUB='+kp.publicKey.export({type:'spki',format:'der'}).toString('base64'));console.log('PRIV='+kp.privateKey.export({type:'pkcs8',format:'der'}).toString('base64'));"
```

## 2) Set Supabase function secrets
```bash
supabase secrets set LICENSE_SIGN_KID=license-ed25519-2026-01
supabase secrets set LICENSE_SIGN_PRIVATE_KEY_B64=<PRIV_BASE64>
supabase secrets set HF_CLIENT_HEADER_VALUE=<your-x-hf-client-value>
```

## 3) Apply migration + deploy function
```bash
supabase db push
supabase functions deploy verify-license
```

## 4) Flutter build arg
Pass public key at build time:

```bash
flutter build apk --dart-define=LICENSE_SIGN_PUBKEY_B64=<PUB_BASE64>
```

## Notes
- Keep your existing verify-license DB logic and replace TODO block in function.
- Signed envelope is required; app will reject unsigned/tampered payload.
