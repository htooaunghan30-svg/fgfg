#!/usr/bin/env python3
"""Add exercise.label.accuracy, exercise.label.reps, exercise.label.seconds_held
to every language map in app_localizations.dart."""

import re

FILE = 'lib/core/localization/app_localizations.dart'

# New keys per language
NEW_KEYS = {
    'en': {
        'exercise.label.accuracy': 'Accuracy',
        'exercise.label.reps': 'REPS',
        'exercise.label.seconds_held': 'SECONDS HELD',
    },
    'es': {
        'exercise.label.accuracy': 'Precisión',
        'exercise.label.reps': 'REPS',
        'exercise.label.seconds_held': 'SEGUNDOS',
    },
    'ja': {
        'exercise.label.accuracy': '精度',
        'exercise.label.reps': 'レップ',
        'exercise.label.seconds_held': '秒キープ',
    },
    'my': {
        'exercise.label.accuracy': 'တိကျမှု',
        'exercise.label.reps': 'အကြိမ်ရေ',
        'exercise.label.seconds_held': 'ထိန်းထားချိန်',
    },
    'hi': {
        'exercise.label.accuracy': 'सटीकता',
        'exercise.label.reps': 'रेप्स',
        'exercise.label.seconds_held': 'सेकंड होल्ड',
    },
    'pt': {
        'exercise.label.accuracy': 'Precisão',
        'exercise.label.reps': 'REPS',
        'exercise.label.seconds_held': 'SEGUNDOS',
    },
    'zh': {
        'exercise.label.accuracy': '精确度',
        'exercise.label.reps': '次数',
        'exercise.label.seconds_held': '保持秒数',
    },
    'de': {
        'exercise.label.accuracy': 'Genauigkeit',
        'exercise.label.reps': 'WDHL',
        'exercise.label.seconds_held': 'SEKUNDEN',
    },
}

def main():
    with open(FILE, 'r', encoding='utf-8') as f:
        text = f.read()

    for lang, keys in NEW_KEYS.items():
        var_name = f'_{lang}Values'
        # Check if any key already exists
        first_key = list(keys.keys())[0]
        if f"'{first_key}'" in text:
            marker_region = text.find(f"'{first_key}'")
            # Check if it's within the right variable
            var_start = text.rfind(var_name, 0, marker_region)
            if var_start != -1 and (marker_region - var_start) < 200000:
                print(f"  [{lang}] Keys already exist, skipping.")
                continue

        # Find the variable definition
        pattern = rf"(static const Map<String, String> {var_name} = \{{)"
        match = re.search(pattern, text)
        if not match:
            print(f"  [{lang}] Could not find {var_name}, skipping.")
            continue

        insert_pos = match.end()

        # Build the new entries
        lines = []
        for key, value in keys.items():
            escaped_value = value.replace("'", "\\'")
            lines.append(f"\n    '{key}': '{escaped_value}',")
        new_block = ''.join(lines)

        text = text[:insert_pos] + new_block + text[insert_pos:]
        print(f"  [{lang}] Added {len(keys)} keys to {var_name}.")

    with open(FILE, 'w', encoding='utf-8') as f:
        f.write(text)

    print("Done adding exercise labels.")

if __name__ == '__main__':
    main()
