import re

with open('lib/core/localization/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Pattern for 'home.situp_notice': '...', (accounting for escaped characters inside the string)
pattern = r"[ \t]*'home\.situp_notice'\s*:\s*'[^'\\]*(?:\\.[^'\\]*)*',?\r?\n?"
new_text = re.sub(pattern, "", text)

with open('lib/core/localization/app_localizations.dart', 'w', encoding='utf-8') as f:
    f.write(new_text)

print(f"Removed {len(text) - len(new_text)} bytes")
