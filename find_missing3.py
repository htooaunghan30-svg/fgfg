import json

# Parse by simply reading line by line because Flutter maps format is standard
def extract_keys(content, map_name):
    in_map = False
    keys = {}
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if map_name in line and 'static const Map' in line:
            in_map = True
            continue
        if in_map:
            if '};' in line:
                in_map = False
                break
            line = line.strip()
            if line.startswith("'"):
                idx = line.find("':")
                if idx != -1:
                    key = line[1:idx]
                    val_str = line[idx+2:].strip()
                    # simplistic check
                    if val_str.startswith("'"):
                        val_str = val_str[1:]
                    keys[key] = val_str
    return keys

with open('lib/core/localization/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

en = extract_keys(text, '_enValues')
langs = ['es', 'ja', 'my', 'hi', 'pt', 'zh', 'de']
untranslated = {}

for l in langs:
    l_vals = extract_keys(text, f'_{l}Values')
    l_un = []
    for k, v in en.items():
        if k.startswith('exercise.name.') or 'festival' in k or 'zodiac' in k: continue
        if k in l_vals and l_vals[k] == v:
            l_un.append(k)
        if k not in l_vals:
            l_un.append(k)
    untranslated[l] = l_un

# Overlay Studio 
in_map = False
ov_en = {}
ov_other = {l: {} for l in langs}
current_lang = None
for line in text.split('\n'):
    if '_overlayStudioTextOverrides' in line:
        in_map = True
        continue
    if in_map:
        if '};' in line and not line.strip().startswith("'"):
            break
        s_line = line.strip()
        if s_line.startswith("'en': {"):
            current_lang = 'en'
            continue
        for l in langs:
            if s_line.startswith(f"'{l}': {{"):
                current_lang = l
                break
        
        if current_lang and s_line.startswith("'"):
            idx = s_line.find("':")
            if idx != -1:
                key = s_line[1:idx]
                if key not in ['en', 'es', 'ja', 'my', 'hi', 'pt', 'zh', 'de']:
                    val_str = s_line[idx+2:].strip()
                    if current_lang == 'en':
                        ov_en[key] = val_str
                    else:
                        ov_other[current_lang][key] = val_str

for l in langs:
    for k, v in ov_en.items():
        if k not in ov_other[l] or ov_other[l][k] == v:
            untranslated[l].append(k)

for l in langs:
    print(f"{l}: {len(untranslated[l])} untranslated")

if untranslated['es']:
    print("Example ES:")
    print(untranslated['es'][:20])

with open('missing.json', 'w') as f:
    json.dump(untranslated, f, indent=2)

