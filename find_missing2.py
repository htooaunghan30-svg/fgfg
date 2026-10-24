import re, json

with open('lib/core/localization/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

def extract_keys(map_name, text):
    m = re.search(r'static const Map<String, String>\s+' + map_name + r'\s*=\s*\{([^{}]+)\};', text)
    if not m: return set()
    content = m.group(1)
    keys = set(re.findall(r"'([a-zA-Z0-9_\.-]+)'\s*:", content))
    return keys

en_keys = extract_keys('_enValues', text)

langs = ['es', 'ja', 'my', 'hi', 'pt', 'zh', 'de']
missing = {}
for l in langs:
    l_keys = extract_keys(f'_{l}Values', text)
    missing[l] = sorted(list(en_keys - l_keys))

# overlay studio
m_overlay = re.search(r'static const Map<String, Map<String, String>> _overlayStudioTextOverrides\s*=\s*\{(.*?)\};', text, flags=re.DOTALL)
if m_overlay:
    overlay_content = m_overlay.group(1)
    overlay_en_match = re.search(r"'en'\s*:\s*\{([^{}]+)\}", overlay_content, flags=re.DOTALL)
    en_ov_keys = set()
    if overlay_en_match:
        en_ov_keys = set(re.findall(r"'([a-zA-Z0-9_\.-]+)'\s*:", overlay_en_match.group(1)))
            
    for l in langs:
        l_match = re.search(fr"'{l}'\s*:\s*\{{([^{{}}]+)\}}", overlay_content, flags=re.DOTALL)
        l_ov_keys = set()
        if l_match:
            l_ov_keys = set(re.findall(r"'([a-zA-Z0-9_\.-]+)'\s*:", l_match.group(1)))
        
        diff = en_ov_keys - l_ov_keys
        missing[l].extend(sorted(list(diff)))

with open('missing_keys.json', 'w', encoding='utf-8') as f:
    json.dump(missing, f, indent=2, ensure_ascii=False)
print("done")
