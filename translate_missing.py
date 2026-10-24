import json, re, time
from deep_translator import GoogleTranslator

# HTML tag to protect placeholders
def protect_placeholders(text):
    return re.sub(r'(\{[\w_]+\})', r'<span translate="no">\1</span>', text)

def revert_placeholders(text):
    text = re.sub(r'<span translate="no">\s*(\{[\w_]+\})\s*</span>', r'\1', text, flags=re.IGNORECASE)
    text = re.sub(r'<span class="notranslate">\s*(\{[\w_]+\})\s*</span>', r'\1', text, flags=re.IGNORECASE)
    # just in case it modified spacing
    text = re.sub(r'<span[^>]*>(.*?)</span>', r'\1', text)
    return text

def escape_dart_string(v):
    # escape single quotes and newlines
    v = v.replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n')
    return v

with open('missing.json', 'r', encoding='utf-8') as f:
    missing = json.load(f)

with open('lib/core/localization/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Extract EN keys
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
                    if val_str.startswith("'") and val_str.endswith("',"):
                        val_str = val_str[1:-2]
                    elif val_str.startswith("'") and val_str.endswith("'"):
                        val_str = val_str[1:-1]
                    # basic unescape
                    val_str = val_str.replace("\\'", "'").replace('\\n', '\n')
                    keys[key] = val_str
    return keys

en_vals = extract_keys(text, '_enValues')
# Extract overlay studio EN keys
ov_en = {}
m_overlay = re.search(r'static const Map<String, Map<String, String>> _overlayStudioTextOverrides\s*=\s*\{(.*?)\};', text, flags=re.DOTALL)
if m_overlay:
    overlay_content = m_overlay.group(1)
    overlay_en_match = re.search(r"'en'\s*:\s*\{([^{}]+)\}", overlay_content, flags=re.DOTALL)
    if overlay_en_match:
        for m in re.finditer(r"'([a-zA-Z0-9_\.-]+)'\s*:\s*'(.*?)'(?:\s*,|\s*$)", overlay_en_match.group(1), flags=re.DOTALL):
            ov_en[m.group(1)] = m.group(2).replace("\\'", "'").replace('\\n', '\n')

all_en = {**en_vals, **ov_en}

target_langs = {'es': 'es', 'ja': 'ja', 'my': 'my', 'hi': 'hi', 'pt': 'pt', 'zh': 'zh-CN', 'de': 'de'}
all_translations = {}

for lang, googl_lang in target_langs.items():
    if not missing.get(lang): continue
    print(f"Translating for {lang}...")
    all_translations[lang] = {}
    translator = GoogleTranslator(source='en', target=googl_lang)
    for key in missing[lang]:
        if key not in all_en: continue
        original_val = all_en[key]
        protected = protect_placeholders(original_val)
        
        try:
            translated = translator.translate(protected)
            if not translated: translated = original_val
        except Exception as e:
            print(f"Error translating {key}: {e}")
            translated = original_val
        final_val = revert_placeholders(translated)
        all_translations[lang][key] = escape_dart_string(final_val)

        time.sleep(0.1) # small delay to prevent rate limiting

# Now we inject back into app_localizations.dart
new_text = text
for lang, trs in all_translations.items():
    if not trs: continue
    # For _xxValues
    main_keys = {k: v for k, v in trs.items() if not k.startswith('overlay.studio.')}
    if main_keys:
        injection = ""
        for k, v in main_keys.items():
            injection += f"    '{k}': '{v}',\n"
        # Find _xxValues end
        pattern = r"(static const Map<String, String> _" + lang + r"Values\s*=\s*\{.*?)(    '[^']+':\s*'.*?',\n?)(\s*\}\;)"
        # We can just match the end of the block
        match = re.search(r"static const Map<String, String> _" + lang + r"Values\s*=\s*\{.*?\n(\s*)\}\;", new_text, flags=re.DOTALL)
        if match:
            # insertion point is just before the closing };
            end_pos = match.end(1) # position of whitespace before };
            block_start = match.start()
            block_end = match.end()
            body = new_text[block_start:block_end]
            body = body.replace("\n};", "\n" + injection + "  };")
            new_text = new_text[:block_start] + body + new_text[block_end:]

    # For _overlayStudioTextOverrides
    ov_keys = {k: v for k, v in trs.items() if k.startswith('overlay.studio.')}
    if ov_keys:
        injection = ""
        for k, v in ov_keys.items():
            injection += f"      '{k}': '{v}',\n"
        
        # In _overlayStudioTextOverrides, find the 'lang': { block
        # First ensure 'lang': { exists, or inject it
        match = re.search(r"('" + lang + r"'\s*:\s*\{.*?\n)(\s*)\},", new_text, flags=re.DOTALL)
        if match:
            # We add to the existing block in _overlayStudioTextOverrides
            block_start = match.start()
            block_end = match.end()
            body = new_text[block_start:block_end]
            body = body.replace("\n    },", "\n" + injection + "    },")
            new_text = new_text[:block_start] + body + new_text[block_end:]
        else:
            # Block might not exist or slightly different format
            pass

with open('lib/core/localization/app_localizations.dart', 'w', encoding='utf-8') as f:
    f.write(new_text)

print("Translation injection complete!")
