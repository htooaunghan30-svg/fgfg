#!/usr/bin/env python3
"""Remove duplicate keys in each language map of app_localizations.dart.
Keeps the FIRST occurrence of each key and removes later duplicates."""

import re, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

FILE = 'lib/core/localization/app_localizations.dart'

def find_and_remove_dupes():
    with open(FILE, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    langs = ['en', 'es', 'ja', 'my', 'hi', 'pt', 'zh', 'de']
    all_to_remove = set()

    for lang in langs:
        var_name = f'_{lang}Values'
        var_start = -1
        var_end = -1
        brace_count = 0
        in_var = False

        for i, line in enumerate(lines):
            if f'Map<String, String> {var_name}' in line:
                var_start = i
                in_var = True
            if in_var:
                brace_count += line.count('{') - line.count('}')
                if brace_count <= 0 and var_start >= 0:
                    var_end = i
                    break

        if var_start < 0 or var_end < 0:
            continue

        seen_keys = {}
        lang_remove = set()

        for i in range(var_start, var_end + 1):
            line = lines[i]
            key_match = re.search(r"'([^']+)':\s*", line)
            if key_match:
                key = key_match.group(1)
                if key in seen_keys:
                    lang_remove.add(i)
                    # Check if next lines are value continuations
                    j = i + 1
                    while j <= var_end:
                        next_line = lines[j].strip()
                        if not next_line:
                            j += 1
                            continue
                        next_key_match = re.search(r"'([^']+)':\s*", lines[j])
                        if next_key_match:
                            break
                        if next_line.startswith("'") or next_line.startswith('"'):
                            lang_remove.add(j)
                            j += 1
                        else:
                            break
                else:
                    seen_keys[key] = i

        if lang_remove:
            print(f'  [{lang}] Removing {len(lang_remove)} duplicate lines')
            all_to_remove.update(lang_remove)

    if all_to_remove:
        new_lines = [line for i, line in enumerate(lines) if i not in all_to_remove]
        with open(FILE, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        print(f'Removed {len(all_to_remove)} duplicate lines total.')
    else:
        print('No duplicates found.')

if __name__ == '__main__':
    find_and_remove_dupes()
