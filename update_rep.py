import re

with open('lib/presentation/widgets/rep_counter.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Make sure context.l10n.t is used
if "'SECONDS HELD' : 'REPS'" in text:
    text = text.replace("'SECONDS HELD' : 'REPS'", "showTime ? context.l10n.t('exercise.seconds_held') : context.l10n.t('progress.reps_short')")
    
    # Needs to import relative l10n
    if 'import "../../core/extensions/localization_extension.dart";' not in text and "import '../../core/extensions/localization_extension.dart';" not in text:
        text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../core/extensions/localization_extension.dart';")
    
    with open('lib/presentation/widgets/rep_counter.dart', 'w', encoding='utf-8') as f:
        f.write(text)
    print('rep_counter.dart updated')

with open('lib/core/localization/app_localizations.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add exercise.seconds_held to english
if "'exercise.seconds_held'" not in text:
    text = text.replace("'home.total_reps': 'Total Reps',", "'home.total_reps': 'Total Reps',\n    'exercise.seconds_held': 'SECONDS HELD',")
    # Add to my
    text = text.replace("'home.total_reps': 'လေ့ကျင့်ခန်းအချက်ရေ',", "'home.total_reps': 'လေ့ကျင့်ခန်းအချက်ရေ',\n    'exercise.seconds_held': 'စက္ကန့် စောင့်ပါ။',")
    
    with open('lib/core/localization/app_localizations.dart', 'w', encoding='utf-8') as f:
        f.write(text)
    print('app_localizations.dart updated')
