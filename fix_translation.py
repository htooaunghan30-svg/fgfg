import re

with open('lib/core/localization/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace SECONDS HELD translation in MY with correct Burmese value
# My translation map:
my_val = "'စက္ကန့် စောင့်ပါ။'"
text = re.sub(
    r"'time_held'\s*:\s*'.*?'",
    r"'time_held': " + my_val,
    text
)
with open('lib/core/localization/app_localizations.dart', 'w', encoding='utf-8') as f:
    f.write(text)
