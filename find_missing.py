import re, json

with open('lib/core/localization/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

def extract_dict(map_name, text):
    m = re.search(r'static const Map<String, String>\s+' + map_name + r'\s*=\s*\{([^{}]+)\};', text)
    if not m: return {}
    content = m.group(1)
    # Match keys and values taking care of multiline strings and escaped quotes
    res = {}
    for m2 in re.finditer(r"'([a-zA-Z0-9_\.-]+)'\s*:\s*'(.*?)'(?:\s*,|\s*$)", content, flags=re.DOTALL):
        res[m2.group(1)] = m2.group(2)
    return res

en_vals = extract_dict('_enValues', text)

langs = ['es', 'ja', 'my', 'hi', 'pt', 'zh', 'de']
missing = {}
for l in langs:
    l_vals = extract_dict(f'_{l}Values', text)
    missing[l] = {k: v for k, v in en_vals.items() if k not in l_vals}

# Extract overlay studio
m_overlay = re.search(r'static const Map<String, Map<String, String>> _overlayStudioTextOverrides\s*=\s*\{(.*?)\};', text, flags=re.DOTALL)
if m_overlay:
    overlay_content = m_overlay.group(1)
    overlay_en_match = re.search(r"'en'\s*:\s*\{([^{}]+)\}", overlay_content, flags=re.DOTALL)
    overlay_en = {}
    if overlay_en_match:
        for m in re.finditer(r"'([a-zA-Z0-9_\.-]+)'\s*:\s*'(.*?)'(?:\s*,|\s*$)", overlay_en_match.group(1), flags=re.DOTALL):
            overlay_en[m.group(1)] = m.group(2)
            
    for l in langs:
        l_match = re.search(fr"'{l}'\s*:\s*\{{([^{{}}]+)\}}", overlay_content, flags=re.DOTALL)
        l_keys = set()
        if l_match:
            l_keys = set(re.findall(r"'([a-zA-Z0-9_\.-]+)'\s*:", l_match.group(1)))
        
        if l not in missing: missing[l] = {}
        for k, v in overlay_en.items():
            if k not in l_keys:
                missing[l][k] = v

with open('missing_keys.json', 'w', encoding='utf-8') as f:
    json.dump(missing, f, indent=2, ensure_ascii=False)
