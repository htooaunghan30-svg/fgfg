import 'dart:convert';

import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('my'),
    Locale('hi'),
    Locale('pt'),
    Locale('zh'),
    Locale('de'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localization =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localization == null) {
      return AppLocalizations(const Locale('en'));
    }
    return localization;
  }

  String get languageCode {
    final code = locale.languageCode.toLowerCase();
    if (_localizedValues.containsKey(code)) {
      return code;
    }
    return 'en';
  }

  String t(String key, {Map<String, String> params = const {}}) {
    final languageValues =
        _localizedValues[languageCode] ?? _localizedValues['en']!;
    final iconicOverrides = _iconicTextOverrides[languageCode];
    final overlayStudioOverrides = _overlayStudioTextOverrides[languageCode];
    String text =
        overlayStudioOverrides?[key] ??
        iconicOverrides?[key] ??
        languageValues[key] ??
        _overlayStudioTextOverrides['en']?[key] ??
        _iconicTextOverrides['en']?[key] ??
        _localizedValues['en']![key] ??
        key;

    var repaired = _repairMojibake(text);
    if (_shouldFallbackFromLocalizedText(repaired)) {
      final fallbackEnglish = _overlayStudioTextOverrides['en']?[key] ??
          _iconicTextOverrides['en']?[key] ??
          _localizedValues['en']?[key];
      if (fallbackEnglish != null && fallbackEnglish.isNotEmpty) {
        repaired = _repairMojibake(fallbackEnglish);
      }
    }
    if (_shouldFallbackFromLocalizedText(repaired) || repaired == key) {
      repaired = _fallbackDisplayText(key, fallback: repaired);
    }

    params.forEach((placeholder, value) {
      repaired = repaired.replaceAll('{$placeholder}', value);
    });
    return repaired;
  }

  static String _repairMojibake(String text) {
    if (text.isEmpty) {
      return text;
    }

    var current = text;
    for (var i = 0; i < 3; i++) {
      final repaired = _decodeLatin1AsUtf8(current);
      if (repaired == current) {
        break;
      }
      current = repaired;
    }
    return current;
  }

  static String _decodeLatin1AsUtf8(String text) {
    if (!_looksMisencoded(text)) {
      return text;
    }

    try {
      return utf8.decode(latin1.encode(text), allowMalformed: true);
    } catch (_) {
      return text;
    }
  }

  static bool _looksMisencoded(String text) {
    const suspiciousFragments = [
      '\u00C3',
      '\u00C2',
      '\u00E2\u20AC',
      '\u00E2\u20AC\u2122',
      '\u00E2\u20AC\u0153',
      '\u00E2\u20AC\u00A2',
      '\u00E2\u20AC\u201C',
      '\u00E2\u20AC\u201D',
      '\u00F0\u0178',
      '\u00EF\u00B8',
      '\u00E3\u201A',
      '\u00E3\u0192',
      '\u00E6\u00A0',
      '\u00E5\u00BF',
    ];

    for (final fragment in suspiciousFragments) {
      if (text.contains(fragment)) {
        return true;
      }
    }

    final markerCount = RegExp('[\u00C3\u00C2\u00E2\u00F0\u00EF]').allMatches(text).length;
    if (markerCount >= 2) {
      return true;
    }

    return false;
  }

  static bool _isLikelyCorruptedText(String text) {
    if (text.isEmpty) {
      return false;
    }

    // When source strings are already replaced with repeated '?', decoding
    // cannot recover them. Use English fallback instead of showing gibberish.
    if (RegExp(r'\?{2,}').hasMatch(text)) {
      return true;
    }
    if (text.contains('\uFFFD')) {
      return true;
    }
    if (_looksMisencoded(text)) {
      return true;
    }
    if (RegExp(r'[ÃÂâðï]{2,}').hasMatch(text)) {
      return true;
    }
    return false;
  }

  static bool _shouldFallbackFromLocalizedText(String text) {
    if (text.isEmpty) {
      return true;
    }
    return _isLikelyCorruptedText(text);
  }

  static String _fallbackDisplayText(String key, {required String fallback}) {
    if (fallback.isNotEmpty &&
        fallback != key &&
        !_isLikelyCorruptedText(fallback)) {
      return fallback;
    }

    final lastSegment = key.split('.').last;
    final readable = lastSegment
        .replaceAll('_', ' ')
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .trim();

    if (readable.isEmpty) {
      return 'Text unavailable';
    }

    return readable[0].toUpperCase() + readable.substring(1);
  }
  static const Map<String, Map<String, String>> _iconicTextOverrides = {
    'en': {
      'nav.iconic': 'Iconic',
      'iconic.menu.title': 'Iconic Programs',
      'iconic.menu.subtitle':
          'Choose a premium post-process look for recorded videos. Each program feels distinct, cinematic, and elegant without adding heat during live capture.',
      'iconic.program.zodiac.eyebrow': 'Post-Processed Signature',
      'iconic.program.zodiac.title': 'Zodiac Program',
      'iconic.program.zodiac.description':
          'Applies a luxury zodiac overlay after recording. All 12 signs use distinct palettes, symbols, aura tinting, and engraved styling.',
      'iconic.program.zodiac.tag.sign_themes': '12 Sign Themes',
      'iconic.program.zodiac.tag.luxury_capsule': 'Luxury Capsule',
      'iconic.program.zodiac.tag.embossed_coin': 'Embossed Coin',
      'iconic.program.zodiac.footer':
          'Recommended for iconic exports. Live capture stays lightweight while the luxury treatment is added after recording.',
      'iconic.program.festival.eyebrow': 'Cultural Celebration',
      'iconic.program.festival.title': 'World Festival Program',
      'iconic.program.festival.description':
          'Applies a unique luxury overlay based on the nearest world festival or sporting event, with its own palette, glow, and branding.',
      'iconic.program.festival.tag.festivals': '70 Festivals',
      'iconic.program.festival.tag.date_aware': 'Date-Aware',
      'iconic.program.festival.tag.luxury_overlay': 'Luxury Overlay',
      'iconic.program.festival.footer':
          'The theme automatically switches to the nearest upcoming celebration and is applied during post-processing.',
      'iconic.program.studio.eyebrow': 'Fully Customizable',
      'iconic.program.studio.title': 'Luxury Overlay Studio Program',
      'iconic.program.studio.description':
          'Use your own premium overlay system with editable rep counter, accuracy bar, narrative flow, icons, color palettes, and finish controls.',
      'iconic.program.studio.tag.custom_program': 'Custom Program',
      'iconic.program.studio.tag.luxury_editor': 'Luxury Editor',
      'iconic.program.studio.tag.premium_control': 'Premium Control',
      'iconic.program.studio.footer':
          'Pick this when you want your own handcrafted luxury overlay instead of a fixed zodiac or festival treatment.',
      'iconic.program.studio.action': 'Open Studio',
      'iconic.program.standard.eyebrow': 'Lightweight Default',
      'iconic.program.standard.title': 'Standard Export',
      'iconic.program.standard.description':
          'Keeps the current simple overlay when you do not want a branded cinematic look.',
      'iconic.program.standard.tag.default': 'Default',
      'iconic.program.standard.tag.minimal': 'Minimal',
      'iconic.program.standard.tag.fast_export': 'Fast Export',
      'iconic.program.standard.footer':
          'Use this if you want the existing export style with no premium art direction.',
      'iconic.info.title': 'How It Works',
      'iconic.info.step1': '1. Pick a program here.',
      'iconic.info.step2': '2. Record your workout as usual.',
      'iconic.info.step3':
          '3. The selected style is applied only after recording during post-processing.',
      'iconic.preview.post_process': 'POST-PROCESS PREVIEW',
      'iconic.preview.standard.caption':
          'Default export overlay\nkeeps the current lightweight look.',
      'iconic.preview.editable_luxe': 'EDITABLE LUXE',
    },
    'es': {
      'nav.iconic': 'Ic\u00F3nico',
      'iconic.menu.title': 'Programas Icónicos',
      'iconic.menu.subtitle':
          'Elige un estilo premium de posprocesado para tus videos grabados. Cada programa se siente distinto, cinematográfico y elegante sin añadir calor durante la captura en vivo.',
      'iconic.program.zodiac.eyebrow': 'Firma Posprocesada',
      'iconic.program.zodiac.title': 'Programa Zodiacal',
      'iconic.program.zodiac.description':
          'Aplica una superposición zodiacal de lujo después de grabar. Los 12 signos usan paletas, símbolos, tintes de aura y grabados distintos.',
      'iconic.program.zodiac.tag.sign_themes': '12 Temas de Signos',
      'iconic.program.zodiac.tag.luxury_capsule': 'Cápsula de Lujo',
      'iconic.program.zodiac.tag.embossed_coin': 'Moneda en Relieve',
      'iconic.program.zodiac.footer':
          'Recomendado para exportaciones icónicas. La captura en vivo sigue siendo ligera y el acabado de lujo se añade después de grabar.',
      'iconic.program.festival.eyebrow': 'Celebración Cultural',
      'iconic.program.festival.title': 'Programa de Festivales',
      'iconic.program.festival.description':
          'Aplica una superposición de lujo única basada en el festival mundial o evento deportivo más cercano, con su propia paleta, brillo y marca visual.',
      'iconic.program.festival.tag.festivals': '70 Festivales',
      'iconic.program.festival.tag.date_aware': 'Según la Fecha',
      'iconic.program.festival.tag.luxury_overlay': 'Overlay de Lujo',
      'iconic.program.festival.footer':
          'El tema cambia automáticamente a la próxima celebración más cercana y se aplica durante el posprocesado.',
      'iconic.program.studio.eyebrow': 'Totalmente Personalizable',
      'iconic.program.studio.title': 'Studio de Overlay de Lujo',
      'iconic.program.studio.description':
          'Usa tu propio sistema premium de overlay con contador editable, barra de precisión, flujo narrativo, iconos, paletas de color y controles de acabado.',
      'iconic.program.studio.tag.custom_program': 'Programa Personalizado',
      'iconic.program.studio.tag.luxury_editor': 'Editor de Lujo',
      'iconic.program.studio.tag.premium_control': 'Control Premium',
      'iconic.program.studio.footer':
          'Elige esto si quieres tu propio overlay de lujo hecho a mano en lugar de un estilo fijo de zodiaco o festival.',
      'iconic.program.studio.action': 'Abrir Studio',
      'iconic.program.standard.eyebrow': 'Predeterminado Ligero',
      'iconic.program.standard.title': 'Exportación Estándar',
      'iconic.program.standard.description':
          'Mantiene la superposición simple actual cuando no quieres un look cinematográfico de marca.',
      'iconic.program.standard.tag.default': 'Predeterminado',
      'iconic.program.standard.tag.minimal': 'Minimal',
      'iconic.program.standard.tag.fast_export': 'Exportación Rápida',
      'iconic.program.standard.footer':
          'Usa esto si quieres el estilo de exportación actual sin una dirección artística premium.',
      'iconic.info.title': 'Cómo Funciona',
      'iconic.info.step1': '1. Elige un programa aquí.',
      'iconic.info.step2': '2. Graba tu entrenamiento como siempre.',
      'iconic.info.step3':
          '3. El estilo seleccionado se aplica solo después de grabar, durante el posprocesado.',
      'iconic.preview.post_process': 'VISTA PREVIA POSPROCESADA',
      'iconic.preview.standard.caption':
          'La superposición de exportación predeterminada\nmantiene el aspecto ligero actual.',
      'iconic.preview.editable_luxe': 'LUJO EDITABLE',
      'overlay.studio.preview_phase_subtitle': '',
      'overlay.studio.master_mode_subtitle': '',
      'overlay.studio.text_branding_subtitle': '',
      'overlay.studio.show_branding_bar_subtitle': '',
      'overlay.studio.banner_border_subtitle': '',
      'overlay.studio.narrative_flow_subtitle': '',
      'overlay.studio.icon_system_subtitle': '',
      'overlay.studio.color_system_subtitle': '',
      'overlay.studio.layout_control_subtitle': '',
      'overlay.studio.luxe_finish_subtitle': '',
      'overlay.studio.svg_description_selected': '',
      'overlay.studio.svg_description_empty': '',
    },
    'ja': {
      'nav.iconic': '\u30A2\u30A4\u30B3\u30CB\u30C3\u30AF',
      'iconic.menu.title': 'アイコニックプログラム',
      'iconic.menu.subtitle':
          '録画した動画にプレミアムなポストプロセス演出を選べます。各プログラムは、ライブ撮影中に負荷を増やさず、個性的で映画的、そして上品に仕上がります。',
      'iconic.program.zodiac.eyebrow': 'ポスト処理シグネチャ',
      'iconic.program.zodiac.title': 'ゾディアックプログラム',
      'iconic.program.zodiac.description':
          '録画後に高級感のある星座オーバーレイを適用します。12星座それぞれに異なる配色、記号、オーラ、刻印スタイルがあります。',
      'iconic.program.zodiac.tag.sign_themes': '12星座テーマ',
      'iconic.program.zodiac.tag.luxury_capsule': 'ラグジュアリー',
      'iconic.program.zodiac.tag.embossed_coin': 'エンボスコイン',
      'iconic.program.zodiac.footer':
          '印象的な書き出しにおすすめです。ライブ撮影は軽量のまま、録画後に高級な演出が加わります。',
      'iconic.program.festival.eyebrow': 'カルチャーセレブレーション',
      'iconic.program.festival.title': 'ワールドフェスティバル',
      'iconic.program.festival.description':
          '最も近い世界の祭典やスポーツイベントに合わせた高級オーバーレイを適用します。各テーマに固有の配色、発光、ブランド表現があります。',
      'iconic.program.festival.tag.festivals': '70の祭典',
      'iconic.program.festival.tag.date_aware': '日付連動',
      'iconic.program.festival.tag.luxury_overlay': '高級オーバーレイ',
      'iconic.program.festival.footer':
          'テーマは次に近い祝祭へ自動で切り替わり、録画後のポスト処理で反映されます。',
      'iconic.program.studio.eyebrow': '自由にカスタマイズ',
      'iconic.program.studio.title': 'ラグジュアリースタジオ',
      'iconic.program.studio.description':
          '回数表示、精度バー、演出の流れ、アイコン、配色、仕上げ操作まで編集できる独自のプレミアムオーバーレイを使えます。',
      'iconic.program.studio.tag.custom_program': 'カスタム',
      'iconic.program.studio.tag.luxury_editor': '高級エディタ',
      'iconic.program.studio.tag.premium_control': 'プレミアム操作',
      'iconic.program.studio.footer':
          '固定の星座や祭典スタイルではなく、自分だけの高級オーバーレイを作りたいときに選んでください。',
      'iconic.program.studio.action': 'スタジオを開く',
      'iconic.program.standard.eyebrow': '軽量デフォルト',
      'iconic.program.standard.title': '標準書き出し',
      'iconic.program.standard.description':
          'ブランド感のある映画風演出が不要なときは、現在のシンプルなオーバーレイを維持します。',
      'iconic.program.standard.tag.default': '標準',
      'iconic.program.standard.tag.minimal': 'ミニマル',
      'iconic.program.standard.tag.fast_export': '高速書き出し',
      'iconic.program.standard.footer':
          'プレミアムな演出なしで、今の書き出しスタイルを使いたい場合はこちらです。',
      'iconic.info.title': '使い方',
      'iconic.info.step1': '1. ここでプログラムを選びます。',
      'iconic.info.step2': '2. いつも通りにワークアウトを録画します。',
      'iconic.info.step3': '3. 選んだスタイルは録画後のポスト処理で適用されます。',
      'iconic.preview.post_process': 'ポスト処理プレビュー',
      'iconic.preview.standard.caption':
          '標準の書き出しオーバーレイで\n現在の軽量な見た目を維持します。',
      'iconic.preview.editable_luxe': '編集可能ラグジュアリー',
      'overlay.studio.preview_phase': 'プレビューフェーズ',
      'overlay.studio.preview_phase_subtitle': '',
      'overlay.studio.master_mode': 'マスターモード',
      'overlay.studio.master_mode_subtitle': '',
      'overlay.studio.performance_mode': 'パフォーマンスモード',
      'overlay.studio.text_branding': 'テキストとブランディング',
      'overlay.studio.text_branding_subtitle': '',
      'overlay.studio.show_branding_bar': 'ブランドバーを表示する',
      'overlay.studio.show_branding_bar_subtitle': '',
      'overlay.studio.title_field': 'タイトル',
      'overlay.studio.subtitle_field': '字幕',
      'overlay.studio.branding_field': 'ブランディング',
      'overlay.studio.banner_border': 'バナーの枠線',
      'overlay.studio.banner_border_subtitle': '',
      'overlay.studio.narrative_flow': '物語の流れ',
      'overlay.studio.narrative_flow_subtitle': '',
      'overlay.studio.cue_label': 'キュー {number}',
      'overlay.studio.icon_system': 'アイコンシステム',
      'overlay.studio.icon_system_subtitle': '',
      'overlay.studio.default_slot': 'デフォルト',
      'overlay.studio.up_phase': 'アップフェーズ',
      'overlay.studio.down_phase': 'ダウンフェーズ',
      'overlay.studio.color_system': 'カラーシステム',
      'overlay.studio.color_system_subtitle': '',
      'overlay.studio.primary_color': '主要な',
      'overlay.studio.secondary_color': '二次',
      'overlay.studio.accent_color': 'アクセント',
      'overlay.studio.layout_control': 'レイアウト制御',
      'overlay.studio.layout_control_subtitle': '',
      'overlay.studio.counter_cluster': 'カウンタークラスター',
      'overlay.studio.stats_card_slot': '統計カードスロット',
      'overlay.studio.global_scale': '地球規模',
      'overlay.studio.overlay_opacity': 'オーバーレイの不透明度',
      'overlay.studio.luxe_finish': '豪華な仕上げ',
      'overlay.studio.luxe_finish_subtitle': '',
      'overlay.studio.vignette_focus': 'ビネットフォーカス',
      'overlay.studio.bloom_glow': 'ブルームグロー',
      'overlay.studio.sparkle_field': 'スパークルフィールド',
      'overlay.studio.sheen_sweep': 'シーンスイープ',
      'overlay.studio.border_width': '枠線の幅',
      'overlay.studio.rotation': '回転',
      'overlay.studio.colors': '色 ({count})',
      'overlay.studio.presets': 'プリセット',
      'overlay.studio.svg_import_failed': 'SVG インポートに失敗しました: {error}',
      'overlay.studio.no_svg_selected': 'SVG がまだ選択されていません',
      'overlay.studio.svg_description_selected': '',
      'overlay.studio.svg_description_empty': '',
      'overlay.studio.fallback_badge': 'フォールバック バッジ: {glyph}',
      'overlay.studio.importing': 'インポート中...',
      'overlay.studio.replace_svg': 'SVGを置き換える',
      'overlay.studio.choose_svg': 'SVGを選択してください',
      'overlay.studio.supported_input': 'サポートされている入力: `.svg` ファイルのみ。',
    },
    'my': {
      'nav.iconic': 'Iconic',
      'iconic.menu.title': 'Iconic Program များ',
      'iconic.menu.subtitle':
          'Record လုပ်ထားသော video များအတွက် premium post-process style ကိုရွေးနိုင်သည်။ Program တစ်ခုချင်းစီကို live capture အတွင်း phone မပူစေဘဲ ထူးခြားပြီး cinematic ဆန်ကာ အလှတရားရှိစေရန် ပြုလုပ်ထားသည်။',
      'iconic.program.zodiac.eyebrow': 'Post-process Signature',
      'iconic.program.zodiac.title': 'Zodiac Program',
      'iconic.program.zodiac.description':
          'Recording ပြီးနောက် luxury zodiac overlay ကိုထည့်ပေးသည်။ ရာသီခွင် ၁၂ ခုစီမှာ မတူညီသော color palette, symbol, aura tint နှင့် engraved style များရှိသည်။',
      'iconic.program.zodiac.tag.sign_themes': 'ရာသီခွင် ၁၂ မျိုး',
      'iconic.program.zodiac.tag.luxury_capsule': 'Luxury Capsule',
      'iconic.program.zodiac.tag.embossed_coin': 'Embossed Coin',
      'iconic.program.zodiac.footer':
          'Iconic export များအတွက် အထူးသင့်တော်သည်။ Live capture ကပေါ့ပါးနေသေးပြီး luxury treatment ကို recording ပြီးနောက်မှ ထည့်ပေးသည်။',
      'iconic.program.festival.eyebrow': 'ယဉ်ကျေးမှု အထိမ်းအမှတ်',
      'iconic.program.festival.title': 'World Festival Program',
      'iconic.program.festival.description':
          'အနီးစပ်ဆုံး world festival သို့မဟုတ် sporting event အပေါ်မူတည်ပြီး unique luxury overlay ကိုထည့်ပေးသည်။ Festival တစ်ခုစီမှာ ကိုယ်ပိုင် palette, glow နှင့် branding ရှိသည်။',
      'iconic.program.festival.tag.festivals': 'Festival ၇၀',
      'iconic.program.festival.tag.date_aware': 'နေ့စွဲအလိုက်',
      'iconic.program.festival.tag.luxury_overlay': 'Luxury Overlay',
      'iconic.program.festival.footer':
          'Theme ကို အနီးဆုံးလာမည့် celebration အလိုက် အလိုအလျောက်ပြောင်းပေးပြီး post-processing အချိန်မှာ apply လုပ်ပေးသည်။',
      'iconic.program.studio.eyebrow': 'စိတ်ကြိုက် ပြင်ဆင်နိုင်သည်',
      'iconic.program.studio.title': 'Luxury Overlay Studio Program',
      'iconic.program.studio.description':
          'Rep counter, accuracy bar, narrative flow, icon, color palette နှင့် finish control များကို editable လုပ်နိုင်သော ကိုယ်ပိုင် premium overlay system ကိုသုံးနိုင်သည်။',
      'iconic.program.studio.tag.custom_program': 'Custom Program',
      'iconic.program.studio.tag.luxury_editor': 'Luxury Editor',
      'iconic.program.studio.tag.premium_control': 'Premium Control',
      'iconic.program.studio.footer':
          'Fixed zodiac သို့မဟုတ် festival style အစား ကိုယ်ပိုင် luxury overlay တစ်ခုဖန်တီးချင်လျှင် ဒီ option ကိုရွေးပါ။',
      'iconic.program.studio.action': 'Studio ဖွင့်မည်',
      'iconic.program.standard.eyebrow': 'ပေါ့ပါးသော Default',
      'iconic.program.standard.title': 'Standard Export',
      'iconic.program.standard.description':
          'Branded cinematic look မလိုချင်သောအခါ လက်ရှိ simple overlay ကိုပဲ ဆက်သုံးပေးသည်။',
      'iconic.program.standard.tag.default': 'Default',
      'iconic.program.standard.tag.minimal': 'Minimal',
      'iconic.program.standard.tag.fast_export': 'မြန်သော Export',
      'iconic.program.standard.footer':
          'Premium art direction မပါဘဲ လက်ရှိ export style ကိုပဲ သုံးချင်လျှင် ဒီ option ကိုရွေးပါ။',
      'iconic.info.title': 'အသုံးပြုပုံ',
      'iconic.info.step1': '1. ဒီနေရာမှာ program တစ်ခုကိုရွေးပါ။',
      'iconic.info.step2': '2. ပုံမှန်အတိုင်း workout ကို record လုပ်ပါ။',
      'iconic.info.step3':
          '3. ရွေးထားသော style ကို recording ပြီးနောက် post-processing အချိန်တွင်သာ apply လုပ်ပေးသည်။',
      'iconic.preview.post_process': 'POST-PROCESS PREVIEW',
      'iconic.preview.standard.caption':
          'Default export overlay က\nလက်ရှိပေါ့ပါးသောပုံစံကို ဆက်ထိန်းထားပေးသည်။',
      'iconic.preview.editable_luxe': 'EDITABLE LUXE',
      'overlay.studio.preview_phase_subtitle': '',
      'overlay.studio.master_mode': 'မာစတာမုဒ်',
      'overlay.studio.master_mode_subtitle': '',
      'overlay.studio.performance_mode': 'စွမ်းဆောင်ရည်မုဒ်',
      'overlay.studio.text_branding_subtitle': '',
      'overlay.studio.show_branding_bar_subtitle': '',
      'overlay.studio.title_field': 'ခေါင်းစဉ်',
      'overlay.studio.subtitle_field': 'စာတန်းထိုး',
      'overlay.studio.branding_field': 'တံဆိပ်တပ်ခြင်း။',
      'overlay.studio.banner_border': 'ဆိုင်းဘုတ်နယ်စပ်',
      'overlay.studio.banner_border_subtitle': '',
      'overlay.studio.narrative_flow': 'Narrative Flow',
      'overlay.studio.narrative_flow_subtitle': '',
      'overlay.studio.cue_label': 'Cue {number}',
      'overlay.studio.icon_system': 'Icon စနစ်',
      'overlay.studio.icon_system_subtitle': '',
      'overlay.studio.default_slot': 'ပုံသေ',
      'overlay.studio.up_phase': 'UP အဆင့်',
      'overlay.studio.down_phase': 'ဆင်းတဲ့အဆင့်',
      'overlay.studio.color_system': 'အရောင်စနစ်',
      'overlay.studio.color_system_subtitle': '',
      'overlay.studio.primary_color': 'မူလတန်း',
      'overlay.studio.secondary_color': 'အလယ်တန်း',
      'overlay.studio.accent_color': 'လေယူလေသိမ်း',
      'overlay.studio.layout_control': 'အပြင်အဆင် ထိန်းချုပ်မှု',
      'overlay.studio.layout_control_subtitle': '',
      'overlay.studio.counter_cluster': 'ကောင်တာ အစုအဖွဲ့',
      'overlay.studio.stats_card_slot': 'Stats ကတ်အထိုင်',
      'overlay.studio.global_scale': 'ကမ္ဘာ့အတိုင်းအတာ',
      'overlay.studio.overlay_opacity': 'ထပ်ဆင့်အလင်းပိတ်',
      'overlay.studio.luxe_finish': 'Luxe Finish',
      'overlay.studio.luxe_finish_subtitle': '',
      'overlay.studio.vignette_focus': 'အမွမ်းအာရုံ',
      'overlay.studio.bloom_glow': 'ပွင့်လန်းသည်။',
      'overlay.studio.sparkle_field': 'ကွန့်မြူးသောအကွက်',
      'overlay.studio.sheen_sweep': 'Sheen လှည်း',
      'overlay.studio.border_width': 'နယ်နိမိတ်အကျယ်',
      'overlay.studio.rotation': 'အလှည့်',
      'overlay.studio.colors': 'အရောင်များ ({count})',
      'overlay.studio.presets': 'ကြိုတင်သတ်မှတ်မှုများ',
      'overlay.studio.svg_description_selected': '',
      'overlay.studio.svg_description_empty': '',
      'overlay.studio.fallback_badge': 'နောက်ခံတံဆိပ်- {glyph}',
    },
    'hi': {
      'nav.iconic': '\u0906\u0907\u0915\u0949\u0928\u093F\u0915',
      'iconic.menu.title': 'आइकॉनिक प्रोग्राम',
      'iconic.menu.subtitle':
          'रिकॉर्ड किए गए वीडियो के लिए प्रीमियम पोस्ट-प्रोसेस लुक चुनें। हर प्रोग्राम अलग, सिनेमैटिक और सुंदर महसूस होता है, और लाइव कैप्चर के दौरान अतिरिक्त गर्मी नहीं बढ़ाता।',
      'iconic.program.zodiac.eyebrow': 'पोस्ट-प्रोसेस सिग्नेचर',
      'iconic.program.zodiac.title': 'ज़ोडिएक प्रोग्राम',
      'iconic.program.zodiac.description':
          'रिकॉर्डिंग के बाद लग्ज़री ज़ोडिएक ओवरले लागू करता है। सभी 12 राशियों के लिए अलग रंग, प्रतीक, ऑरा टिंट और नक्काशीदार स्टाइल हैं।',
      'iconic.program.zodiac.tag.sign_themes': '12 राशि थीम',
      'iconic.program.zodiac.tag.luxury_capsule': 'लग्ज़री कैप्सूल',
      'iconic.program.zodiac.tag.embossed_coin': 'उभरा हुआ कॉइन',
      'iconic.program.zodiac.footer':
          'आइकॉनिक एक्सपोर्ट के लिए उपयुक्त। लाइव कैप्चर हल्का रहता है और रिकॉर्डिंग के बाद लग्ज़री फिनिश जुड़ती है।',
      'iconic.program.festival.eyebrow': 'सांस्कृतिक उत्सव',
      'iconic.program.festival.title': 'वर्ल्ड फेस्टिवल प्रोग्राम',
      'iconic.program.festival.description':
          'सबसे नज़दीकी विश्व उत्सव या खेल आयोजन के आधार पर एक अनोखा लग्ज़री ओवरले लागू करता है। हर थीम की अपनी रंग-सज्जा, ग्लो और ब्रांडिंग होती है।',
      'iconic.program.festival.tag.festivals': '70 उत्सव',
      'iconic.program.festival.tag.date_aware': 'तारीख़ अनुसार',
      'iconic.program.festival.tag.luxury_overlay': 'लग्ज़री ओवरले',
      'iconic.program.festival.footer':
          'थीम अपने आप सबसे नज़दीकी आने वाले उत्सव पर बदल जाती है और पोस्ट-प्रोसेसिंग के दौरान लागू होती है।',
      'iconic.program.studio.eyebrow': 'पूरी तरह अनुकूलन योग्य',
      'iconic.program.studio.title': 'लग्ज़री ओवरले स्टूडियो',
      'iconic.program.studio.description':
          'एडिटेबल रेप काउंटर, एक्युरेसी बार, नैरेटिव फ्लो, आइकॉन, रंग योजनाएँ और फिनिश कंट्रोल के साथ अपना प्रीमियम ओवरले सिस्टम इस्तेमाल करें।',
      'iconic.program.studio.tag.custom_program': 'कस्टम प्रोग्राम',
      'iconic.program.studio.tag.luxury_editor': 'लग्ज़री एडिटर',
      'iconic.program.studio.tag.premium_control': 'प्रीमियम कंट्रोल',
      'iconic.program.studio.footer':
          'यदि आप तय ज़ोडिएक या फेस्टिवल स्टाइल की जगह अपना खुद का लग्ज़री ओवरले बनाना चाहते हैं, तो इसे चुनें।',
      'iconic.program.studio.action': 'स्टूडियो खोलें',
      'iconic.program.standard.eyebrow': 'हल्का डिफ़ॉल्ट',
      'iconic.program.standard.title': 'स्टैंडर्ड एक्सपोर्ट',
      'iconic.program.standard.description':
          'जब आपको ब्रांडेड सिनेमैटिक लुक नहीं चाहिए, तब यह मौजूदा सरल ओवरले बनाए रखता है।',
      'iconic.program.standard.tag.default': 'डिफ़ॉल्ट',
      'iconic.program.standard.tag.minimal': 'मिनिमल',
      'iconic.program.standard.tag.fast_export': 'तेज़ एक्सपोर्ट',
      'iconic.program.standard.footer':
          'यदि आप बिना प्रीमियम आर्ट डायरेक्शन के मौजूदा एक्सपोर्ट स्टाइल चाहते हैं, तो इसे चुनें।',
      'iconic.info.title': 'यह कैसे काम करता है',
      'iconic.info.step1': '1. यहाँ एक प्रोग्राम चुनें।',
      'iconic.info.step2': '2. सामान्य तरीके से अपना वर्कआउट रिकॉर्ड करें।',
      'iconic.info.step3':
          '3. चुनी हुई स्टाइल रिकॉर्डिंग के बाद पोस्ट-प्रोसेसिंग के दौरान लागू होती है।',
      'iconic.preview.post_process': 'पोस्ट-प्रोसेस प्रीव्यू',
      'iconic.preview.standard.caption':
          'डिफ़ॉल्ट एक्सपोर्ट ओवरले\nमौजूदा हल्का लुक बनाए रखता है।',
      'iconic.preview.editable_luxe': 'एडिटेबल लक्स',
      'overlay.studio.preview_phase_subtitle': '',
      'overlay.studio.master_mode_subtitle': '',
      'overlay.studio.text_branding_subtitle': '',
      'overlay.studio.show_branding_bar_subtitle': '',
      'overlay.studio.banner_border_subtitle': '',
      'overlay.studio.narrative_flow_subtitle': '',
      'overlay.studio.icon_system_subtitle': '',
      'overlay.studio.color_system_subtitle': '',
      'overlay.studio.layout_control_subtitle': '',
      'overlay.studio.luxe_finish_subtitle': '',
      'overlay.studio.svg_description_selected': '',
      'overlay.studio.svg_description_empty': '',
    },
    'pt': {
      'nav.iconic': 'Ic\u00F4nico',
      'iconic.menu.title': 'Programas Icônicos',
      'iconic.menu.subtitle':
          'Escolha um visual premium de pós-processamento para vídeos gravados. Cada programa foi pensado para parecer distinto, cinematográfico e elegante sem adicionar calor durante a captura ao vivo.',
      'iconic.program.zodiac.eyebrow': 'Assinatura Pós-processada',
      'iconic.program.zodiac.title': 'Programa do Zodíaco',
      'iconic.program.zodiac.description':
          'Aplica um overlay luxuoso de zodíaco após a gravação. Os 12 signos usam paletas, símbolos, tons de aura e estilo gravado distintos.',
      'iconic.program.zodiac.tag.sign_themes': '12 Temas dos Signos',
      'iconic.program.zodiac.tag.luxury_capsule': 'Cápsula de Luxo',
      'iconic.program.zodiac.tag.embossed_coin': 'Moeda em Relevo',
      'iconic.program.zodiac.footer':
          'Recomendado para exportações icônicas. A captura ao vivo continua leve e o acabamento luxuoso é adicionado após a gravação.',
      'iconic.program.festival.eyebrow': 'Celebração Cultural',
      'iconic.program.festival.title': 'Programa de Festivais',
      'iconic.program.festival.description':
          'Aplica um overlay luxuoso único com base no festival mundial ou evento esportivo mais próximo, com sua própria paleta, brilho e identidade visual.',
      'iconic.program.festival.tag.festivals': '70 Festivais',
      'iconic.program.festival.tag.date_aware': 'Sensível à Data',
      'iconic.program.festival.tag.luxury_overlay': 'Overlay de Luxo',
      'iconic.program.festival.footer':
          'O tema muda automaticamente para a celebração futura mais próxima e é aplicado durante o pós-processamento.',
      'iconic.program.studio.eyebrow': 'Totalmente Personalizável',
      'iconic.program.studio.title': 'Studio de Overlay Luxuoso',
      'iconic.program.studio.description':
          'Use seu próprio sistema premium de overlay com contador editável, barra de precisão, fluxo narrativo, ícones, paletas de cores e controles de acabamento.',
      'iconic.program.studio.tag.custom_program': 'Programa Personalizado',
      'iconic.program.studio.tag.luxury_editor': 'Editor de Luxo',
      'iconic.program.studio.tag.premium_control': 'Controle Premium',
      'iconic.program.studio.footer':
          'Escolha isto se quiser seu próprio overlay luxuoso artesanal em vez de um estilo fixo de zodíaco ou festival.',
      'iconic.program.studio.action': 'Abrir Studio',
      'iconic.program.standard.eyebrow': 'Padrão Leve',
      'iconic.program.standard.title': 'Exportação Padrão',
      'iconic.program.standard.description':
          'Mantém o overlay simples atual quando você não quer um visual cinematográfico com marca.',
      'iconic.program.standard.tag.default': 'Padrão',
      'iconic.program.standard.tag.minimal': 'Minimal',
      'iconic.program.standard.tag.fast_export': 'Exportação Rápida',
      'iconic.program.standard.footer':
          'Use isto se quiser o estilo de exportação atual sem direção de arte premium.',
      'iconic.info.title': 'Como Funciona',
      'iconic.info.step1': '1. Escolha um programa aqui.',
      'iconic.info.step2': '2. Grave seu treino normalmente.',
      'iconic.info.step3':
          '3. O estilo selecionado é aplicado somente após a gravação, durante o pós-processamento.',
      'iconic.preview.post_process': 'PRÉVIA PÓS-PROCESSO',
      'iconic.preview.standard.caption':
          'O overlay padrão de exportação\nmantém o visual leve atual.',
      'iconic.preview.editable_luxe': 'LUXO EDITÁVEL',
      'overlay.studio.preview_phase': 'Fase de visualização',
      'overlay.studio.preview_phase_subtitle': '',
      'overlay.studio.master_mode': 'Modo Mestre',
      'overlay.studio.master_mode_subtitle': '',
      'overlay.studio.performance_mode': 'Modo de desempenho',
      'overlay.studio.text_branding': 'Texto e marca',
      'overlay.studio.text_branding_subtitle': '',
      'overlay.studio.show_branding_bar': 'Mostrar barra de branding',
      'overlay.studio.show_branding_bar_subtitle': '',
      'overlay.studio.title_field': 'Título',
      'overlay.studio.subtitle_field': 'Legenda',
      'overlay.studio.branding_field': 'Marca',
      'overlay.studio.banner_border': 'Borda do banner',
      'overlay.studio.banner_border_subtitle': '',
      'overlay.studio.narrative_flow': 'Fluxo Narrativo',
      'overlay.studio.narrative_flow_subtitle': '',
      'overlay.studio.cue_label': 'Dica {número}',
      'overlay.studio.icon_system': 'Sistema de ícones',
      'overlay.studio.icon_system_subtitle': '',
      'overlay.studio.default_slot': 'Padrão',
      'overlay.studio.up_phase': 'Fase ACIMA',
      'overlay.studio.down_phase': 'Fase PARA BAIXO',
      'overlay.studio.color_system': 'Sistema de cores',
      'overlay.studio.color_system_subtitle': '',
      'overlay.studio.primary_color': 'Primário',
      'overlay.studio.secondary_color': 'Secundário',
      'overlay.studio.accent_color': 'Sotaque',
      'overlay.studio.layout_control': 'Controle de Layout',
      'overlay.studio.layout_control_subtitle': '',
      'overlay.studio.counter_cluster': 'Cluster de contador',
      'overlay.studio.stats_card_slot': 'Slot para cartão de estatísticas',
      'overlay.studio.global_scale': 'Escala global',
      'overlay.studio.overlay_opacity': 'Opacidade de sobreposição',
      'overlay.studio.luxe_finish': 'Acabamento luxuoso',
      'overlay.studio.luxe_finish_subtitle': '',
      'overlay.studio.vignette_focus': 'Foco da vinheta',
      'overlay.studio.bloom_glow': 'Brilho de flor',
      'overlay.studio.sparkle_field': 'Campo de brilho',
      'overlay.studio.sheen_sweep': 'Varredura de brilho',
      'overlay.studio.border_width': 'Largura da borda',
      'overlay.studio.rotation': 'Rotação',
      'overlay.studio.colors': 'Cores ({count})',
      'overlay.studio.presets': 'Predefinições',
      'overlay.studio.svg_import_failed': 'Falha na importação de SVG: {error}',
      'overlay.studio.no_svg_selected': 'Nenhum SVG selecionado ainda',
      'overlay.studio.svg_description_selected': '',
      'overlay.studio.svg_description_empty': '',
      'overlay.studio.fallback_badge': 'Selo substituto: {glyph}',
      'overlay.studio.importing': 'Importando...',
      'overlay.studio.replace_svg': 'Substituir SVG',
      'overlay.studio.choose_svg': 'Escolha SVG',
      'overlay.studio.supported_input': 'Entrada suportada: somente arquivos `.svg`.',
    },
    'zh': {
      'nav.iconic': '\u6807\u5FD7\u98CE\u683C',
      'iconic.menu.title': '标志风格方案',
      'iconic.menu.subtitle':
          '为已录制的视频选择高级后期风格。每个方案都能呈现不同、电影感且优雅的效果，同时不会在实时拍摄时增加手机负担。',
      'iconic.program.zodiac.eyebrow': '后期签名风格',
      'iconic.program.zodiac.title': '星座方案',
      'iconic.program.zodiac.description':
          '在录制后应用奢华星座叠层。12 个星座都拥有不同的配色、符号、光晕色调与雕刻风格。',
      'iconic.program.zodiac.tag.sign_themes': '12 星座主题',
      'iconic.program.zodiac.tag.luxury_capsule': '奢华系列',
      'iconic.program.zodiac.tag.embossed_coin': '浮雕徽章',
      'iconic.program.zodiac.footer':
          '适合用于高质感导出。实时拍摄保持轻量，奢华效果会在录制后添加。',
      'iconic.program.festival.eyebrow': '文化庆典',
      'iconic.program.festival.title': '世界节庆方案',
      'iconic.program.festival.description':
          '根据最近的世界节庆或体育赛事应用独特的奢华叠层。每个主题都有自己的配色、光效和品牌风格。',
      'iconic.program.festival.tag.festivals': '70 个节庆',
      'iconic.program.festival.tag.date_aware': '按日期切换',
      'iconic.program.festival.tag.luxury_overlay': '奢华叠层',
      'iconic.program.festival.footer':
          '主题会自动切换到最近即将到来的庆典，并在后期处理中应用到视频上。',
      'iconic.program.studio.eyebrow': '完全可自定义',
      'iconic.program.studio.title': '奢华叠层工作室',
      'iconic.program.studio.description':
          '使用你自己的高级叠层系统，可编辑次数计数、准确度条、叙事流程、图标、配色和完成控制。',
      'iconic.program.studio.tag.custom_program': '自定义方案',
      'iconic.program.studio.tag.luxury_editor': '奢华编辑器',
      'iconic.program.studio.tag.premium_control': '高级控制',
      'iconic.program.studio.footer':
          '如果你想要自己打造奢华叠层，而不是固定的星座或节庆风格，就选择这个。',
      'iconic.program.studio.action': '打开工作室',
      'iconic.program.standard.eyebrow': '轻量默认',
      'iconic.program.standard.title': '标准导出',
      'iconic.program.standard.description':
          '当你不需要品牌化电影风格时，会保留当前简洁的叠层样式。',
      'iconic.program.standard.tag.default': '默认',
      'iconic.program.standard.tag.minimal': '极简',
      'iconic.program.standard.tag.fast_export': '快速导出',
      'iconic.program.standard.footer':
          '如果你想继续使用当前导出风格而不加入高级美术方向，就选择这个。',
      'iconic.info.title': '使用方式',
      'iconic.info.step1': '1. 在这里选择一个方案。',
      'iconic.info.step2': '2. 像平常一样录制你的训练。',
      'iconic.info.step3': '3. 所选风格只会在录制后，于后期处理中应用。',
      'iconic.preview.post_process': '后期预览',
      'iconic.preview.standard.caption':
          '默认导出叠层\n保留当前轻量风格。',
      'iconic.preview.editable_luxe': '可编辑奢华版',
      'overlay.studio.preview_phase': '预览阶段',
      'overlay.studio.preview_phase_subtitle': '',
      'overlay.studio.master_mode': '大师模式',
      'overlay.studio.master_mode_subtitle': '',
      'overlay.studio.performance_mode': '性能模式',
      'overlay.studio.text_branding': '文字与品牌',
      'overlay.studio.text_branding_subtitle': '',
      'overlay.studio.show_branding_bar': '显示品牌栏',
      'overlay.studio.show_branding_bar_subtitle': '',
      'overlay.studio.title_field': '标题',
      'overlay.studio.subtitle_field': '字幕',
      'overlay.studio.branding_field': '品牌推广',
      'overlay.studio.banner_border': '横幅边框',
      'overlay.studio.banner_border_subtitle': '',
      'overlay.studio.narrative_flow': '叙事流程',
      'overlay.studio.narrative_flow_subtitle': '',
      'overlay.studio.cue_label': '提示{number}',
      'overlay.studio.icon_system': '图标系统',
      'overlay.studio.icon_system_subtitle': '',
      'overlay.studio.default_slot': '默认',
      'overlay.studio.up_phase': '上行阶段',
      'overlay.studio.down_phase': '下行阶段',
      'overlay.studio.color_system': '色彩系统',
      'overlay.studio.color_system_subtitle': '',
      'overlay.studio.primary_color': '基本的',
      'overlay.studio.secondary_color': '中学',
      'overlay.studio.accent_color': '口音',
      'overlay.studio.layout_control': '布局控制',
      'overlay.studio.layout_control_subtitle': '',
      'overlay.studio.counter_cluster': '计数器集群',
      'overlay.studio.stats_card_slot': '统计卡槽',
      'overlay.studio.global_scale': 'Global scale',
      'overlay.studio.overlay_opacity': '叠加不透明度',
      'overlay.studio.luxe_finish': '奢华饰面',
      'overlay.studio.luxe_finish_subtitle': '',
      'overlay.studio.vignette_focus': '小插图焦点',
      'overlay.studio.bloom_glow': '绽放光芒',
      'overlay.studio.sparkle_field': '闪光场',
      'overlay.studio.sheen_sweep': '光泽扫',
      'overlay.studio.border_width': '边框宽度',
      'overlay.studio.rotation': '旋转',
      'overlay.studio.colors': '颜色（{count}）',
      'overlay.studio.presets': '预设',
      'overlay.studio.svg_import_failed': 'SVG 导入失败：{error}',
      'overlay.studio.no_svg_selected': '尚未选择 SVG',
      'overlay.studio.svg_description_selected': '',
      'overlay.studio.svg_description_empty': '',
      'overlay.studio.fallback_badge': '后备徽章：{glyph}',
      'overlay.studio.importing': '输入...',
      'overlay.studio.replace_svg': '替换 SVG',
      'overlay.studio.choose_svg': '选择SVG',
      'overlay.studio.supported_input': '支持的输入：仅限“.svg”文件。',
    },
    'de': {
      'nav.iconic': 'Ikonisch',
      'iconic.menu.title': 'Iconic-Programme',
      'iconic.menu.subtitle':
          'Wähle einen Premium-Look für die Nachbearbeitung deiner aufgenommenen Videos. Jedes Programm wirkt eigenständig, filmisch und elegant, ohne das Gerät bei der Live-Aufnahme zusätzlich zu belasten.',
      'iconic.program.zodiac.eyebrow': 'Nachbearbeitete Signatur',
      'iconic.program.zodiac.title': 'Zodiac-Programm',
      'iconic.program.zodiac.description':
          'Fügt nach der Aufnahme ein luxuriöses Sternzeichen-Overlay hinzu. Alle 12 Zeichen haben eigene Farbwelten, Symbole, Aura-Tönungen und Gravurstile.',
      'iconic.program.zodiac.tag.sign_themes': '12 Sternzeichen-Themen',
      'iconic.program.zodiac.tag.luxury_capsule': 'Luxus-Kapsel',
      'iconic.program.zodiac.tag.embossed_coin': 'Geprägte Münze',
      'iconic.program.zodiac.footer':
          'Empfohlen für ikonische Exporte. Die Live-Aufnahme bleibt leichtgewichtig, während der Luxus-Look erst nach der Aufnahme hinzugefügt wird.',
      'iconic.program.festival.eyebrow': 'Kulturelle Feier',
      'iconic.program.festival.title': 'Weltfestival-Programm',
      'iconic.program.festival.description':
          'Fügt ein einzigartiges Luxus-Overlay basierend auf dem nächsten Weltfestival oder Sportereignis hinzu. Jedes Thema hat seine eigene Farbpalette, Leuchtwirkung und Markenoptik.',
      'iconic.program.festival.tag.festivals': '70 Festivals',
      'iconic.program.festival.tag.date_aware': 'Datumsabhängig',
      'iconic.program.festival.tag.luxury_overlay': 'Luxus-Overlay',
      'iconic.program.festival.footer':
          'Das Thema wechselt automatisch zur nächsten bevorstehenden Feier und wird bei der Nachbearbeitung angewendet.',
      'iconic.program.studio.eyebrow': 'Vollständig Anpassbar',
      'iconic.program.studio.title': 'Luxus-Overlay-Studio',
      'iconic.program.studio.description':
          'Nutze dein eigenes Premium-Overlay-System mit bearbeitbarem Wiederholungszähler, Genauigkeitsbalken, Erzählfluss, Symbolen, Farbpaletten und Finish-Steuerung.',
      'iconic.program.studio.tag.custom_program': 'Eigenes Programm',
      'iconic.program.studio.tag.luxury_editor': 'Luxus-Editor',
      'iconic.program.studio.tag.premium_control': 'Premium-Steuerung',
      'iconic.program.studio.footer':
          'Wähle dies, wenn du dein eigenes handgemachtes Luxus-Overlay statt eines festen Sternzeichen- oder Festival-Stils möchtest.',
      'iconic.program.studio.action': 'Studio Öffnen',
      'iconic.program.standard.eyebrow': 'Leichtes Standardprofil',
      'iconic.program.standard.title': 'Standard-Export',
      'iconic.program.standard.description':
          'Behält das aktuelle einfache Overlay bei, wenn du keinen markenbezogenen Kino-Look möchtest.',
      'iconic.program.standard.tag.default': 'Standard',
      'iconic.program.standard.tag.minimal': 'Minimal',
      'iconic.program.standard.tag.fast_export': 'Schneller Export',
      'iconic.program.standard.footer':
          'Nutze dies, wenn du den bisherigen Exportstil ohne Premium-Art-Direction verwenden möchtest.',
      'iconic.info.title': 'So Funktioniert Es',
      'iconic.info.step1': '1. Wähle hier ein Programm.',
      'iconic.info.step2': '2. Nimm dein Workout wie gewohnt auf.',
      'iconic.info.step3':
          '3. Der gewählte Stil wird erst nach der Aufnahme in der Nachbearbeitung angewendet.',
      'iconic.preview.post_process': 'NACHBEARBEITUNGSVORSCHAU',
      'iconic.preview.standard.caption':
          'Das Standard-Export-Overlay\nbehält den aktuellen leichten Look bei.',
      'iconic.preview.editable_luxe': 'EDITIERBARER LUXUS',
      'overlay.studio.preview_phase': 'Vorschauphase',
      'overlay.studio.preview_phase_subtitle': '',
      'overlay.studio.master_mode': 'Master-Modus',
      'overlay.studio.master_mode_subtitle': '',
      'overlay.studio.performance_mode': 'Leistungsmodus',
      'overlay.studio.text_branding': 'Text & Branding',
      'overlay.studio.text_branding_subtitle': '',
      'overlay.studio.show_branding_bar': 'Branding-Leiste anzeigen',
      'overlay.studio.show_branding_bar_subtitle': '',
      'overlay.studio.title_field': 'Titel',
      'overlay.studio.subtitle_field': 'Untertitel',
      'overlay.studio.branding_field': 'Branding',
      'overlay.studio.banner_border': 'Banner-Grenze',
      'overlay.studio.banner_border_subtitle': '',
      'overlay.studio.narrative_flow': 'Erzählfluss',
      'overlay.studio.narrative_flow_subtitle': '',
      'overlay.studio.cue_label': 'Stichwort {number}',
      'overlay.studio.icon_system': 'Symbolsystem',
      'overlay.studio.icon_system_subtitle': '',
      'overlay.studio.default_slot': 'Standard',
      'overlay.studio.up_phase': 'UP-Phase',
      'overlay.studio.down_phase': 'AB-Phase',
      'overlay.studio.color_system': 'Farbsystem',
      'overlay.studio.color_system_subtitle': '',
      'overlay.studio.primary_color': 'Primär',
      'overlay.studio.secondary_color': 'Sekundär',
      'overlay.studio.accent_color': 'Akzent',
      'overlay.studio.layout_control': 'Layoutkontrolle',
      'overlay.studio.layout_control_subtitle': '',
      'overlay.studio.counter_cluster': 'Zählercluster',
      'overlay.studio.stats_card_slot': 'Steckplatz für Statistikkarten',
      'overlay.studio.global_scale': 'Globaler Maßstab',
      'overlay.studio.overlay_opacity': 'Deckkraft der Überlagerung',
      'overlay.studio.luxe_finish': 'Luxuriöses Finish',
      'overlay.studio.luxe_finish_subtitle': '',
      'overlay.studio.vignette_focus': 'Vignettenfokus',
      'overlay.studio.bloom_glow': 'Blütenglanz',
      'overlay.studio.sparkle_field': 'Glitzerfeld',
      'overlay.studio.sheen_sweep': 'Glanzfeger',
      'overlay.studio.border_width': 'Randbreite',
      'overlay.studio.rotation': 'Drehung',
      'overlay.studio.colors': 'Farben ({count})',
      'overlay.studio.presets': 'Voreinstellungen',
      'overlay.studio.svg_import_failed': 'SVG-Import fehlgeschlagen: {error}',
      'overlay.studio.no_svg_selected': 'Noch kein SVG ausgewählt',
      'overlay.studio.svg_description_selected': '',
      'overlay.studio.svg_description_empty': '',
      'overlay.studio.fallback_badge': 'Fallback-Abzeichen: {glyph}',
      'overlay.studio.importing': 'Importieren...',
      'overlay.studio.replace_svg': 'Ersetzen Sie SVG',
      'overlay.studio.choose_svg': 'Wählen Sie SVG',
      'overlay.studio.supported_input': 'Unterstützte Eingabe: nur „.svg“-Dateien.',
    },
  };

  static const Map<String, Map<String, String>> _overlayStudioTextOverrides = {
    'en': {
      'overlay.studio.title': 'Luxury Overlay Studio',
      'overlay.studio.saving': 'Saving...',
      'overlay.studio.saving_soon': 'Saving soon...',
      'overlay.studio.saved': 'Saved',
      'overlay.studio.reset': 'Reset',
      'overlay.studio.rep_counter_style': 'Rep Counter Style',
      'overlay.studio.rep_counter_style_subtitle':
          'Choose a silhouette, then tune softness, glow, depth, orbit energy, and animation with sliders.',
      'overlay.studio.show_rep_counter': 'Show rep counter',
      'overlay.studio.show_rep_counter_subtitle':
          'Toggle the circular rep counter UI.',
      'overlay.studio.counter_ring_thickness': 'Ring thickness',
      'overlay.studio.counter_shape': 'Shape',
      'overlay.studio.counter_contour_softness': 'Contour softness',
      'overlay.studio.counter_glow': 'Counter glow',
      'overlay.studio.counter_surface_depth': 'Surface depth',
      'overlay.studio.counter_orbit_intensity': 'Orbit intensity',
      'overlay.studio.counter_bevel_shine': 'Bevel shine',
      'overlay.studio.counter_halo_spread': 'Halo spread',
      'overlay.studio.counter_core_cut': 'Core cut',
      'overlay.studio.counter_jewel_sparkle': 'Jewel sparkle',
      'overlay.studio.counter_animation': 'Animation',
      'overlay.studio.counter_border': 'Counter Border',
      'overlay.studio.accuracy_bar': 'Accuracy Bar',
      'overlay.studio.accuracy_bar_subtitle':
          'Pick a visual language, then sculpt intensity, markers, spill behavior, and liquid glow with sliders.',
      'overlay.studio.show_accuracy_bar': 'Show accuracy bar',
      'overlay.studio.show_accuracy_bar_subtitle':
          'Toggle the horizontal accuracy indicator.',
      'overlay.studio.accuracy_style': 'Style',
      'overlay.studio.accuracy_shape': 'Shape',
      'overlay.studio.accuracy_style_intensity': 'Style intensity',
      'overlay.studio.accuracy_frame_depth': 'Frame depth',
      'overlay.studio.accuracy_gloss_veil': 'Gloss veil',
      'overlay.studio.accuracy_jewel_inset': 'Jewel inset',
      'overlay.studio.accuracy_flare_bloom': 'Flare bloom',
      'overlay.studio.show_threshold_line': 'Show threshold line',
      'overlay.studio.accuracy_marker_density': 'Marker density',
      'overlay.studio.accuracy_bar_glow': 'Bar glow',
      'overlay.studio.accuracy_spill_length': 'Spill length',
      'overlay.studio.accuracy_spill_width': 'Spill width',
      'overlay.studio.accuracy_threshold_glow': 'Threshold glow',
      'overlay.studio.accuracy_liquid_motion': 'Liquid motion',
      'overlay.studio.accuracy_border': 'Bar Border',
      'overlay.studio.rep_no': 'Rep No.',
      'overlay.studio.cue_text_label': '{label} Text',
      'overlay.studio.cue_helper':
          'This text appears after the selected rep reaches 80% accuracy.',
      'overlay.studio.cue_gradient_start': '{label} Gradient Start',
      'overlay.studio.cue_gradient_end': '{label} Gradient End',
      'overlay.studio.custom_color': 'Custom color',
      'overlay.studio.select_color': 'Select Color',
      'overlay.studio.apply': 'Apply',
      'overlay.studio.save_failed': 'Failed to save overlay settings: {error}',
      'overlay.studio.enum.counter_shape.circle': 'Circle',
      'overlay.studio.enum.counter_shape.arc': 'Arc',
      'overlay.studio.enum.counter_shape.hex': 'Hex Luxe',
      'overlay.studio.enum.counter_shape.octagon': 'Octagon',
      'overlay.studio.enum.counter_shape.shield': 'Shield Crest',
      'overlay.studio.enum.counter_shape.diamond': 'Diamond Cut',
      'overlay.studio.enum.counter_shape.flower': 'Flower',
      'overlay.studio.enum.counter_shape.lotus': 'Lotus',
      'overlay.studio.enum.counter_shape.crown': 'Crown',
      'overlay.studio.enum.counter_shape.star': 'Starburst',
      'overlay.studio.enum.accuracy_style.gradient': 'Gradient',
      'overlay.studio.enum.accuracy_style.segmented': 'Segmented',
      'overlay.studio.enum.accuracy_style.flat': 'Flat',
      'overlay.studio.enum.accuracy_style.glass': 'Glass',
      'overlay.studio.enum.accuracy_style.neon': 'Neon',
      'overlay.studio.enum.accuracy_style.prism': 'Prism',
      'overlay.studio.enum.accuracy_style.velvet': 'Velvet',
      'overlay.studio.enum.accuracy_shape.capsule': 'Capsule',
      'overlay.studio.enum.accuracy_shape.beveled': 'Beveled',
      'overlay.studio.enum.accuracy_shape.prism': 'Prism Cut',
      'overlay.studio.enum.accuracy_shape.crest': 'Royal Crest',
      'overlay.studio.enum.accuracy_shape.ribbon': 'Ribbon Luxe',
    },
    'es': {
      'overlay.studio.title': 'Studio de Overlay de Lujo',
      'overlay.studio.saving': 'Guardando...',
      'overlay.studio.saving_soon': 'Se guardar\u00e1 pronto...',
      'overlay.studio.saved': 'Guardado',
      'overlay.studio.reset': 'Restablecer',
    },
    'ja': {
      'overlay.studio.title': '\u30e9\u30b0\u30b8\u30e5\u30a2\u30ea\u30fc\u30aa\u30fc\u30d0\u30fc\u30ec\u30a4\u30b9\u30bf\u30b8\u30aa',
      'overlay.studio.saving': '\u4fdd\u5b58\u4e2d...',
      'overlay.studio.saving_soon': '\u307e\u3082\u306a\u304f\u4fdd\u5b58...',
      'overlay.studio.saved': '\u4fdd\u5b58\u6e08\u307f',
      'overlay.studio.reset': '\u30ea\u30bb\u30c3\u30c8',
    },
    'my': {
      'overlay.studio.title': 'Luxury Overlay Studio',
      'overlay.studio.saving': '\u101e\u102d\u1019\u103a\u1038\u1014\u1031\u101e\u100a\u103a...',
      'overlay.studio.saving_soon':
          '\u1019\u1000\u103c\u102c\u1001\u1004\u103a \u101e\u102d\u1019\u103a\u1038\u1019\u100a\u103a...',
      'overlay.studio.saved': '\u101e\u102d\u1019\u103a\u1038\u1015\u103c\u102e\u1038',
      'overlay.studio.reset': '\u1015\u103c\u1014\u103a\u101c\u100a\u103a\u1001\u103b\u1019\u103e\u1010\u103a',
      'overlay.studio.show_rep_counter':
          'Rep counter \u1015\u103c',
      'overlay.studio.show_rep_counter_subtitle':
          '\u101d\u102d\u102f\u1004\u103a\u1038\u1015\u102f\u1036 rep counter UI \u1000\u102d\u102f \u1015\u103c/\u1016\u103b\u1000\u103a \u101c\u102f\u1015\u103a\u1015\u102b\u104b',
      'overlay.studio.show_accuracy_bar':
          'Accuracy bar \u1015\u103c',
      'overlay.studio.show_accuracy_bar_subtitle':
          '\u1021\u101c\u103b\u102c\u1038\u101c\u102d\u102f\u1000\u103a accuracy indicator \u1000\u102d\u102f \u1015\u103c/\u1016\u103b\u1000\u103a \u101c\u102f\u1015\u103a\u1015\u102b\u104b',
      'overlay.studio.rep_no': 'Rep \u1014\u1036\u1015\u102b\u1010\u103a',
      'overlay.studio.cue_helper':
          '\u101b\u103d\u1031\u1038\u1001\u103b\u101a\u103a\u1011\u102c\u1038\u101e\u1031\u102c rep \u101e\u100a\u103a accuracy 80% \u101b\u1031\u102c\u1000\u103a\u101e\u1031\u102c\u1021\u1001\u103b\u102d\u1014\u103a\u1010\u103d\u1004\u103a \u1024\u1005\u102c\u101e\u102c\u1038 \u1015\u1031\u102b\u103a\u101c\u102c\u1019\u100a\u103a\u104b',
      'overlay.studio.custom_color': '\u1005\u102d\u1010\u103a\u1000\u103c\u102d\u102f\u1000\u103a Color',
      'overlay.studio.select_color': 'Color \u101b\u103d\u1031\u1038\u1015\u102b',
      'overlay.studio.apply': '\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u1019\u100a\u103a',
      'overlay.studio.save_failed':
          'Overlay settings \u1019\u103b\u102c\u1038 \u101e\u102d\u1019\u103a\u1038\u1006\u100a\u103a\u1038\u1019\u103e\u102f \u1019\u1021\u102c\u1004\u103a\u1019\u103c\u1004\u103a\u1015\u102b: {error}',
    },
    'hi': {
      'overlay.studio.title': '\u0932\u0915\u094d\u091c\u093c\u0930\u0940 \u0913\u0935\u0930\u0932\u0947 \u0938\u094d\u091f\u0942\u0921\u093f\u092f\u094b',
      'overlay.studio.saving': '\u0938\u0947\u0935 \u0939\u094b \u0930\u0939\u093e \u0939\u0948...',
      'overlay.studio.saving_soon': '\u091c\u0932\u094d\u0926 \u0938\u0947\u0935 \u0939\u094b\u0917\u093e...',
      'overlay.studio.saved': '\u0938\u0947\u0935 \u0939\u094b \u0917\u092f\u093e',
      'overlay.studio.reset': '\u0930\u0940\u0938\u0947\u091f',
    },
    'pt': {
      'overlay.studio.title': 'Studio de Overlay Luxuoso',
      'overlay.studio.saving': 'Salvando...',
      'overlay.studio.saving_soon': 'Salvando em breve...',
      'overlay.studio.saved': 'Salvo',
      'overlay.studio.reset': 'Redefinir',
    },
    'zh': {
      'overlay.studio.title': '\u5962\u534e\u53e0\u5c42\u5de5\u4f5c\u5ba4',
      'overlay.studio.saving': '\u6b63\u5728\u4fdd\u5b58...',
      'overlay.studio.saving_soon': '\u5373\u5c06\u4fdd\u5b58...',
      'overlay.studio.saved': '\u5df2\u4fdd\u5b58',
      'overlay.studio.reset': '\u91cd\u7f6e',
    },
    'de': {
      'overlay.studio.title': 'Luxus-Overlay-Studio',
      'overlay.studio.saving': 'Speichern...',
      'overlay.studio.saving_soon': 'Wird gleich gespeichert...',
      'overlay.studio.saved': 'Gespeichert',
      'overlay.studio.reset': 'Zur\u00fccksetzen',
    },
  };
  static const Map<String, String> _enValues = {
    'app.title': 'H&F',
    'nav.exercises': 'Exercises',
    'nav.progress': 'Progress',
    'nav.recordings': 'Record and Profile',
    'common.cancel': 'Cancel',
    'common.retry': 'Retry',
    'common.load_exercises': 'Load Exercises',
    'common.clear_data': 'Clear Data',
    'common.ok': 'OK',
    'common.close': 'Close',
    'common.error_with_message': 'Error: {message}',
    'common.copy': 'Copy',
    'common.remove': 'Remove',
    'premium.license.title': 'Premium License',
    'premium.license.heading': 'Contact and Premium License Purchasing',
    'premium.license.contact_us': 'Contact Us',
    'premium.license.active': 'Premium Active',
    'premium.license.inactive': 'Premium Inactive',
    'premium.license.expires': 'Expires: {date}',
    'premium.license.field_label': 'License Key',
    'premium.license.field_hint': 'HF-XXXX-XXXX-XXXX-XXXX',
    'premium.license.enter_key': 'Please enter your license key.',
    'premium.license.wait': 'Please wait...',
    'premium.license.activate': 'Activate License',
    'premium.license.deactivate_device': 'Deactivate on this device',
    'premium.license.security_notes': 'Security Notes',
    'premium.license.security_body':
        'If activation is verified on the server, it is stored with encrypted secure storage and bound to this device.',
    'premium.license.disabled_device': 'Premium disabled on this device.',
    'premium.license.copied': 'Copied: {value}',
    'premium.license.already_active':
        'License is already active on this device.',
    'premium.license.activated': 'Premium activated successfully.',
    'overlay.studio.preview_phase': 'Preview Phase',
    'overlay.studio.preview_phase_subtitle':
        'Switch the demo state without keeping phase controls inside the pinned preview.',
    'overlay.studio.master_mode': 'Master Mode',
    'overlay.studio.master_mode_subtitle':
        'Tune exporter performance and luxury overlay behavior.',
    'overlay.studio.performance_mode': 'Performance mode',
    'overlay.studio.apply_festival_luxe': 'Apply World Festival Luxe',
    'overlay.studio.remove_festival_luxe': 'Remove World Festival Luxe',
    'overlay.studio.text_branding': 'Text & Branding',
    'overlay.studio.text_branding_subtitle':
        'Luxury naming, subtitle tone, and signature line.',
    'overlay.studio.show_branding_bar': 'Show branding bar',
    'overlay.studio.show_branding_bar_subtitle':
        'Toggle the top logo and text bar.',
    'overlay.studio.title_field': 'Title',
    'overlay.studio.subtitle_field': 'Subtitle',
    'overlay.studio.branding_field': 'Branding',
    'overlay.studio.banner_border': 'Banner Border',
    'overlay.studio.banner_border_subtitle':
        'TikTok-style multi-color gradient border.',
    'overlay.studio.narrative_flow': 'Narrative Flow',
    'overlay.studio.narrative_flow_subtitle':
        'These 4 text cues appear only in post-process. Set the rep number beside each text. The text reveals only when that exact rep reaches 80% accuracy.',
    'overlay.studio.cue_label': 'Cue {number}',
    'overlay.studio.icon_system': 'Icon System',
    'overlay.studio.icon_system_subtitle':
        'Import SVG icons per phase. We clean white backdrops, tighten rough bounds, and keep export output polished.',
    'overlay.studio.default_slot': 'Default',
    'overlay.studio.up_phase': 'UP phase',
    'overlay.studio.down_phase': 'DOWN phase',
    'overlay.studio.color_system': 'Color System',
    'overlay.studio.color_system_subtitle':
        'Primary, metallic accent, and phase-specific color control.',
    'overlay.studio.primary_color': 'Primary',
    'overlay.studio.secondary_color': 'Secondary',
    'overlay.studio.accent_color': 'Accent',
    'overlay.studio.layout_control': 'Layout Control',
    'overlay.studio.layout_control_subtitle':
        'Move the accuracy and rep cluster, keep the branding bar stable, and tune overall scale.',
    'overlay.studio.counter_cluster': 'Counter cluster',
    'overlay.studio.stats_card_slot': 'Stats card slot',
    'overlay.studio.global_scale': 'Global scale',
    'overlay.studio.overlay_opacity': 'Overlay opacity',
    'overlay.studio.luxe_finish': 'Luxe Finish',
    'overlay.studio.luxe_finish_subtitle':
        'Add premium atmosphere without changing your existing theme system.',
    'overlay.studio.vignette_focus': 'Vignette focus',
    'overlay.studio.bloom_glow': 'Bloom glow',
    'overlay.studio.sparkle_field': 'Sparkle field',
    'overlay.studio.sheen_sweep': 'Sheen sweep',
    'overlay.studio.border_width': 'Border width',
    'overlay.studio.rotation': 'Rotation',
    'overlay.studio.colors': 'Colors ({count})',
    'overlay.studio.presets': 'Presets',
    'overlay.studio.svg_import_failed': 'SVG import failed: {error}',
    'overlay.studio.no_svg_selected': 'No SVG selected yet',
    'overlay.studio.svg_description_selected':
        'Export uses this sanitized SVG. White backgrounds and rough bounds are cleaned automatically.',
    'overlay.studio.svg_description_empty':
        'SVG only. Pick a file and we will sanitize it for cleaner export badges.',
    'overlay.studio.fallback_badge': 'Fallback badge: {glyph}',
    'overlay.studio.importing': 'Importing...',
    'overlay.studio.replace_svg': 'Replace SVG',
    'overlay.studio.choose_svg': 'Choose SVG',
    'overlay.studio.supported_input': 'Supported input: `.svg` files only.',
    'recordings.player_title': 'Workout Recording',
    'analytics.no_data_available': 'No data available',
    'analytics.chart.date': 'Date',
    'analytics.chart.accuracy_percent': 'Accuracy (%)',
    'analytics.chart.repetitions': 'Repetitions',
    'analytics.title': 'Advanced Analytics',
    'analytics.performance_summary': 'Performance Summary',
    'analytics.consistency': 'Consistency',
    'analytics.improvement': 'Improvement',
    'analytics.peak': 'Peak',
    'exercise.recording.exporting_video': 'Exporting video',
    'exercise.recording.applying_overlay_effects':
        'Applying your selected overlay effects...',
    'exercise.recording.saved_raw_fallback':
        'Video saved. Overlay export fell back to raw recording.',
    'exercise.recording.saved_without_overlay':
        'Video saved without post-process overlay: {error}',
    'premium.badge': 'PREMIUM',
    'premium.menu_only': 'This menu is available for Premium users only.',
    'home.exercises_list': 'Exercise List',
    'home.exercises_simple_form': 'Exercise Form',
    'home.no_supported_exercises': 'No supported exercises available',
    'home.check_exercise_config': 'Please check your exercise configuration',
    'home.error_loading_exercise': 'Error loading exercise: {error}',
    'home.image_reference_count': '{count} image reference',
    'home.today_progress_premium': 'Today\'s Progress (Premium)',
    'home.today_progress_locked_desc':
        'Progressive menu data is available for Premium users.',
    'home.today_progress': 'Today\'s Progress',
    'home.total_reps': 'Total Reps',
    'exercise.seconds_held': 'SECONDS HELD',
    'home.workouts': 'Workouts',
    'home.calories': 'Calories',
    'home.daily_goal': 'Daily Goal: {current}/{goal}',
    'home.daily_goal_achieved': 'Daily goal achieved!',
    'home.progress_premium_title': 'Progress Is Premium',
    'home.progress_premium_message':
        'Detailed progress analytics are unlocked in Premium.',
    'home.recordings_premium_title': 'Recordings Are Premium',
    'home.recordings_premium_message':
        'Video recording history is available in Premium only.',
    'home.simple_form': '{name} Form',
    'home.quick_form_summary': 'Quick Form Summary',
    'home.form_images': 'Form Images',
    'home.exercise_list_notice_title': 'Quick Reminder',
    'home.exercise_list_notice_message':
        'Please review each exercise form as there may be some notice. note- situp exercise have some important notice',
    'home.simple_form_notice':
        'Accuracy Bar and Counting Note:\nOur AI is designed to recognize exercises that closely follow our visual guides. It provides a smooth counting experience with good accuracy, though it does not provide formal technical coaching. Do not forget that our app does not have 100% accuracy.\n\nFor the side view exercise, stay in the side view position, and for the front view exercise, stay in the front view position. That way, the results will be correct.\n\nTracking may be inaccurate if:\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Your entire body is not visible in the camera frame.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ There is more than one person in the camera frame.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ The room is too dark or has strong lens flares/glare.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Place the camera in a position that is not too low or too high from your body.',
    'exercise.guide.title': 'Quick Guide',
    'exercise.guide.step1':
        'If you want to create a landmark, click the skeleton button.',
    'exercise.guide.step2':
        'If you want to record a video, click the record button.',
    'exercise.guide.step3':
        'If you want to stop and save the recording video, double tap the screen or click the back button.',
    'exercise.guide.step4':
        'When you are done with the exercise, click the complete button and then click the save button again to save the exercise.',
    'exercise.error.setup_title': 'Setup Error',
    'exercise.error.setup_message': 'Failed to initialize: {error}',
    'exercise.error.pose_title': 'Pose Detection Error',
    'exercise.error.pose_message':
        'Unable to initialize pose detection. Please make sure Google Play Services is updated.',
    'exercise.premium.landmarks': 'Landmark overlay is a Premium feature.',
    'exercise.premium.recording':
        'Video recording is available in the premium version. Upgrade to unlock this feature.',
    'exercise.recording.failed_start': 'Failed to record screen: {error}',
    'exercise.recording.permission_denied':
        'Permission denied for screen/audio recording',
    'exercise.recording.failed_save': 'Failed to save screen recording',
    'exercise.recording.saved_gallery': 'Saved to Gallery ({album})',
    'exercise.recording.saved_app': 'Saved to app storage: {path}',
    'exercise.recording.saved_phone': 'Video saved to phone storage',
    'exercise.recording.failed_video': 'Failed to record video: {error}',
    'exercise.recording.preparing_luxury_video':
        'We\'re preparing your luxury workout video for you.',
    'exercise.recording.keep_screen_open':
        'Please keep this screen open for a moment.',
    'exercise.premium.title': 'Premium Feature',
    'exercise.premium.not_now': 'Not Now',
    'exercise.premium.upgrade': 'Upgrade',
    'exercise.premium.required_title': 'Premium Required',
    'exercise.premium.required_message':
        'Workout saving, counting, and progress tracking are available in Premium only.',
    'exercise.camera.error_title': 'Camera Error',
    'exercise.camera.error_message':
        'Unable to initialize camera. Please check permissions and try again.',
    'exercise.counting_premium': 'Counting (Premium)',
    'exercise.summary.title': 'Workout Complete!',
    'exercise.summary.total_reps': 'Total Reps',
    'exercise.summary.avg_accuracy': 'Average Accuracy',
    'exercise.summary.duration': 'Duration',
    'exercise.summary.seconds': '{value} seconds',
    'exercise.summary.best_accuracy': 'Best Rep Accuracy',
    'exercise.summary.close': 'Close',
    'exercise.summary.view_details': 'Save',
    'exercise.card.type.dynamic': 'Dynamic',
    'exercise.card.type.static': 'Static',
    'exercise.card.view.front': 'Front View',
    'exercise.card.view.side': 'Side View',
    'exercise.card.total_reps': 'Total Reps',
    'exercise.card.avg_accuracy': 'Avg Accuracy',
    'exercise.card.select': 'Select Exercise',
    'exercise.time.today': 'Today',
    'exercise.time.yesterday': 'Yesterday',
    'exercise.time.days_ago': '{value} days ago',
    'exercise.time.weeks_ago': '{value} weeks ago',
    'exercise.time.months_ago': '{value} months ago',
    'guide.squat.subtitle':
        'Keep your chest up, hips back, and knees tracking over toes.',
    'guide.squat.step1': 'Stand shoulder-width apart and brace your core.',
    'guide.squat.step2':
        'Lower until thighs are near parallel while keeping your heels down.',
    'guide.squat.step3':
        'Drive through your heels to stand tall without locking your knees.',
    'guide.pushup.subtitle':
        'Maintain a straight line from head to heel and control each rep.',
    'guide.pushup.step1':
        'Start in a high plank with hands slightly wider than shoulders.',
    'guide.pushup.step2':
        'Lower your chest by bending elbows at about a 45-degree angle.',
    'guide.pushup.step3':
        'Push back up while keeping core tight and hips level.',
    'guide.situp.subtitle':
        'Use controlled core movement instead of pulling with your neck.',
    'guide.situp.step1': 'Lie on your back with knees bent and feet planted.',
    'guide.situp.step2': 'Lift your torso up by tightening your abs.',
    'guide.situp.step3':
        'Lower slowly to the floor with control before the next rep.',
    'guide.bicep.subtitle':
        'Keep elbows close to your sides and avoid swinging.',
    'guide.bicep.step1':
        'Stand upright with dumbbells and palms facing forward.',
    'guide.bicep.step2':
        'Curl the weights up by bending elbows without moving shoulders.',
    'guide.bicep.step3': 'Lower the weights slowly to full extension.',
    'guide.shoulder.subtitle':
        'Press vertically while keeping ribs down and core engaged.',
    'guide.shoulder.step1':
        'Start with weights at shoulder height and wrists neutral.',
    'guide.shoulder.step2': 'Press up until arms are extended over your head.',
    'guide.shoulder.step3': 'Lower under control back to shoulder level.',
    'guide.leg.subtitle':
        'Move through a controlled range and avoid knee snapping.',
    'guide.leg.step1': 'Sit with back supported and legs under the pad.',
    'guide.leg.step2':
        'Extend knees to lift the pad while keeping hips stable.',
    'guide.leg.step3': 'Lower slowly until knees are bent, then repeat.',
    'settings.title': 'Settings',
    'settings.premium_features': 'Premium Features',
    'settings.app_settings': 'App Settings',
    'settings.profile_name': 'Profile Name',
    'settings.appearance': 'Appearance',
    'settings.data': 'Data',
    'settings.about': 'About',
    'settings.premium_account': 'Premium Account',
    'settings.unlock_all_features': 'Unlock all premium features',
    'settings.voice_counting': 'Voice Counting',
    'settings.speak_count': 'Speak the count during reps',
    'settings.voice_counting_language': 'Voice Counting Language',
    'settings.upgrade_to_premium': 'Upgrade to Premium',
    'settings.upgrade_subtitle': 'Get voice count, video recording, and more',
    'settings.voice_coach': 'Voice Coach',
    'settings.voice_feedback': 'Get real-time voice feedback',
    'settings.show_landmarks': 'Show Landmarks',
    'settings.display_skeleton': 'Display skeleton overlay',
    'settings.auto_recording': 'Auto Recording',
    'settings.auto_recording_subtitle': 'Automatically record workouts',
    'settings.theme': 'Theme',
    'settings.language': 'Language',
    'settings.language_subtitle': 'Change app language',
    'settings.clear_data': 'Clear Data',
    'settings.clear_data_subtitle': 'Delete all workout history',
    'settings.version': 'Version',
    'settings.privacy_policy': 'Privacy Policy',
    'settings.terms': 'Terms of Service',
    'settings.disclaimer': 'Disclaimer',
    'legal.last_updated': 'Last updated: {date}',
    'legal.privacy.content':
        '1) Data we process\n'
        'H&F stores workout logs, badge progress, app preferences, and optional recording file paths on your device.\n\n'
        '2) Premium activation\n'
        'Premium activation needs internet at least once. During activation, license key, device identifier hash, app version, and platform are sent to our license server. After activation, premium entitlement is validated locally and the app can be used offline.\n\n'
        '3) Camera, microphone, storage, and processing power\n'
        'Camera is used for pose detection. It uses your device\'s processing power to analyze the pose. Microphone and screen recording permissions are used only when you use recording features. Saved videos remain on your device or gallery.\n\n'
        '4) How we use data\n'
        'Data is used to count reps, calculate accuracy, track progress, unlock badges, and provide premium features.\n\n'
        '5) Sharing\n'
        'We do not sell your personal data. License verification data is processed only to activate and protect premium access.\n\n'
        '6) Your control\n'
        'You can clear all data or uninstall the app at any time. Clearing data removes local history and stored premium state.\n\n'
        '7) Security\n'
        'The app uses integrity checks and secure local storage to reduce tampering risks, but no system is perfectly secure.',
    'legal.terms.content':
        'By using H&F, you agree to these Terms.\n\n'
        '1) Use of service\n'
        'H&F is a fitness support app. You are responsible for your own safety and health decisions.\n\n'
        '2) Account and license\n'
        'Premium requires a valid license key. Licenses may be limited by device and can be blocked for abuse, revocation, or security violations.\n\n'
        '3) Offline mode\n'
        'After successful activation, core and premium features can run offline on the same device. Reinstalling, clearing sensitive data, or integrity failure may require online activation again.\n\n'
        '4) Restrictions\n'
        'Do not tamper with security, reverse engineer licensing, or use the app for unlawful activities.\n\n'
        '5) Intellectual property\n'
        'App software, branding, and content remain the property of H&F and its licensors.\n\n'
        '6) No warranty\n'
        'The app is provided \"as is\" without guarantees of uninterrupted operation or specific fitness outcomes. My app counter may have overcounted or undercounted for various reasons.\n\n'
        '7) Limitation of liability\n'
        'H&F is not liable for indirect, incidental, or consequential damages from app use.',
    'legal.disclaimer.content':
        'H&F is not a medical service and does not provide medical advice, diagnosis, or treatment.\n\n'
        '1) Training risk\n'
        'Exercise has injury risk. Stop immediately if you feel pain, dizziness, breathing issues, or discomfort, and consult a qualified professional.\n\n'
        '2) AI counting and form feedback\n'
        'Pose detection and rep counting are estimates and may be wrong because of camera angle, lighting, occlusion, clothing, or movement speed.\n\n'
        '3) Recording performance\n'
        'Counting/voice counting is designed to work well during normal workouts while the phone is on. Pose detection (counting) and video recording can run together \n\n'
        '4) Emergency situations\n'
        'Do not rely on this app for emergencies. Contact local emergency services right away when needed.\n\n'
        '5) User responsibility\n'
        'You are responsible for safe workout space, proper technique, and obtaining any needed medical clearance before training.\n\n'
        '6) Recording and privacy of others\n'
        'If you record workouts, you are responsible for getting consent from anyone who may appear in video or audio.\n\n'
        '7) Results\n'
        'Fitness results vary by person. H&F does not guarantee specific performance or health outcomes.',
    'legal.accepted_notice': 'You accepted this on {date}.',
    'settings.select_theme': 'Select Theme',
    'settings.select_language': 'Select Language',
    'onboarding.language_title': 'Choose your language',
    'onboarding.language_subtitle':
        'You can change this later in Settings.',
    'onboarding.name_title': 'What\'s your name?',
    'onboarding.name_subtitle': 'This will appear on your profile.',
    'onboarding.name_hint': 'Enter your name',
    'onboarding.name_required': 'Please enter your name',
    'onboarding.disclaimer_title': 'Disclaimer',
    'onboarding.terms_title': 'Terms of Service',
    'onboarding.accept_notice':
        'Agree to continue using the app.',
    'onboarding.accept_checkbox': 'I agree',
    'onboarding.continue': 'Continue',
    'onboarding.start_app': 'Start App',
    'settings.clear_all_data': 'Clear All Data',
    'settings.clear_all_data_desc':
        'This will delete all your workout history, achievements, and settings. This action cannot be undone.',
    'settings.clear_success': 'All user data cleared successfully.',
    'settings.clear_failed': 'Clear data failed: {error}',
    'theme.light': 'Light',
    'theme.dark': 'Dark',
    'theme.gold': 'Gold',
    'theme.pink': 'Pink',
    'progress.title': 'Progress & Analytics',
    'progress.overview': 'Overview',
    'progress.exercises': 'Exercises',
    'progress.badges': 'Badges',
    'progress.no_data': 'No data available',
    'progress.weekly_summary': 'Weekly Summary',
    'progress.streak_days': '{count} day streak',
    'progress.recent_workouts': 'Recent Workouts',
    'progress.no_workouts': 'No workouts yet',
    'progress.workout_summary': '{reps} reps ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ {accuracy}% accuracy',
    'progress.achievements': 'Achievements',
    'progress.badges_unlocked': '{unlocked}/{total} badges unlocked',
    'progress.view_all_achievements': 'View All Achievements',
    'progress.day.sun': 'Sun',
    'progress.day.mon': 'Mon',
    'progress.day.tue': 'Tue',
    'progress.day.wed': 'Wed',
    'progress.day.thu': 'Thu',
    'progress.day.fri': 'Fri',
    'progress.day.sat': 'Sat',
    'progress.time.just_now': 'Just now',
    'progress.time.minutes_ago': '{value}m ago',
    'progress.time.hours_ago': '{value}h ago',
    'progress.time.days_ago': '{value}d ago',
    'progress.time.weeks_ago': '{value}w ago',
    'progress.analytics_intro_title': 'Understanding Exercise Analytics',
    'progress.analytics_intro_line1':
        'Total Reps = all reps saved for this exercise across all sessions.',
    'progress.analytics_intro_line2':
        'Avg Accuracy = average form accuracy from all saved sessions.',
    'progress.analytics_intro_line3':
        'Trend chart = accuracy over time (higher line means better form).',
    'progress.analytics_intro_line4':
        'Analytics update only after you save a workout session.',
    'progress.read_exercise_analytics_title': 'How to read exercise analytics',
    'progress.read_exercise_analytics_line1':
        'Latest Accuracy = your most recent form score.',
    'progress.read_exercise_analytics_line2':
        'Best Accuracy = your highest score so far.',
    'progress.read_exercise_analytics_line3':
        'Session bars show the last 6 sessions. Taller bar means better accuracy.',
    'progress.read_exercise_analytics_line4':
        'The number under each bar is the reps for that session.',
    'progress.latest_accuracy': 'Latest Accuracy',
    'progress.best_accuracy': 'Best Accuracy',
    'progress.trend_vs_previous_session': '{sign}{delta}% vs previous session',
    'progress.last_sessions_accuracy_title': 'Last Sessions (Accuracy %)',
    'progress.reps_short': 'reps',
    'progress.chart_accuracy_trend_legend':
        'Taller bars indicate better accuracy. Labels below are reps per session.',
    'progress.total_reps_all_time': 'Total Reps (all time)',
    'progress.avg_accuracy_all_sessions': 'Avg Accuracy (all sessions)',
    'progress.sessions': 'Sessions',
    'progress.chart_accuracy_trend':
        'Chart shows accuracy trend by session date.',
    'progress.no_sessions':
        'No sessions yet. Save a workout to see analytics here.',
    'badges.empty':
        'No badges yet.\nStart workouts to unlock your first milestone.',
    'badges.collection': 'Your Badge Collection',
    'badges.current_status': 'Current Badge Status',
    'badges.unlocked_count': '{unlocked}/{total} badges unlocked',
    'badges.tier': 'Tier: {tier}',
    'badges.next_target':
        'Next target: {name} ({progress}/{requirement}) - {percent}% overall complete',
    'badges.how_it_works': 'How This Badge System Works',
    'badges.guide_1':
        'Badges use a 5-days-active, 2-days-rest rhythm. Only active days can count toward progress.',
    'badges.guide_2':
        'Rest-day workouts are saved normally but do not add or subtract badge progress.',
    'badges.guide_3':
        'Daily targets are capped: doing extra reps/sets beyond the limit does not give extra badge credit.',
    'badges.guide_4':
        'No dumbbells or machines needed: you can still earn badges using alternatives (e.g., push-ups for Upper, squats for Lower).',
    'badges.guide_5':
        'Progress is calculated from saved workout logs, so real workout data directly drives unlocks.',
    'badges.unlocked_on': 'Unlocked on {date}',
    'badges.tap_full_plan': 'Tap to view full plan',
    'badges.new_unlock_today': 'Newly unlocked today! Great work.',
    'badges.unlocked_banner':
        'Unlocked! Excellent consistency. Keep this momentum going.',
    'badges.poster_saved_note':
        'Badge poster auto-saved to gallery album: {album}.',
    'badges.poster_save_failed_note':
        'Badge poster could not be saved to gallery. Check photo permission.',
    'badges.no_tier': 'No tier unlocked yet',
    'badges.motivation_unlocked':
        'Great job. This badge is secured; now push for the next tier.',
    'badges.motivation_almost':
        'Almost there. Only {remaining} more qualified day(s) to unlock this badge.',
    'badges.motivation_keep':
        'Stay consistent. Every qualified day moves this badge forward.',
    'tier.bronze': 'Bronze',
    'tier.silver': 'Silver',
    'tier.gold': 'Gold',
    'tier.platinum': 'Platinum',
    'badge.first_workout.name': 'First Steps',
    'badge.first_workout.narrative':
        'Complete your first qualified workout day.',
    'badge.first_workout.detail1':
        'Goal: 1 qualified day from saved workout logs.',
    'badge.first_workout.detail2':
        'Upper target: 8 reps total (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise).',
    'badge.first_workout.detail3': 'Core target: 10 reps total (Sit-up).',
    'badge.first_workout.detail4':
        'Lower target: 12 reps total (Squat / Leg Extension).',
    'badge.prep.name': '15-Day Prep',
    'badge.prep.narrative':
        'Build consistency with a 15-day preparation rhythm.',
    'badge.prep.detail1':
        '15-day prep with 5 active days + 2 rest days cycle (Days 6-7 and 13-14 are rest).',
    'badge.prep.detail2':
        'Days 1-3: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': 'Days 4-5: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': 'Days 8-12: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': 'Day 15: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = saved sessions per category in a day; rest-day workouts do not add progress.',
    'badge.prep.detail8':
        'If you miss a required active day, prep progress resets and the run restarts from Day 1 on your next workout day.',
    'badge.bronze.name': 'Month 1 Bronze',
    'badge.bronze.narrative': 'Foundation month for full-program consistency.',
    'badge.bronze.detail1':
        '30 qualified active days with a 5 active + 2 rest cycle.',
    'badge.bronze.detail2':
        'Upper daily: 18 reps + 3 sets (combined across Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise).',
    'badge.bronze.detail3': 'Core daily: 24 reps + 3 sets (Sit-up).',
    'badge.bronze.detail4':
        'Lower daily: 30 reps + 3 sets (combined across Squat / Leg Extension).',
    'badge.bronze.detail5':
        'Extra reps/sets beyond the daily cap do not add badge progress.',
    'badge.bronze.detail6':
        'Even if you miss a day, you don\'t have to start over from day one.',
    'badge.silver.name': 'Month 2 Silver',
    'badge.silver.narrative':
        'Progression month with higher volume requirements.',
    'badge.silver.detail1':
        '30 qualified active days with a 5 active + 2 rest cycle.',
    'badge.silver.detail2':
        'Upper daily: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise combined).',
    'badge.silver.detail3': 'Core daily: 32 reps + 4 sets (Sit-up).',
    'badge.silver.detail4':
        'Lower daily: 40 reps + 4 sets (Squat / Leg Extension combined).',
    'badge.silver.detail5':
        'Only active days count; rest days are ignored for progress.',
    'badge.silver.detail6':
        'Even if you miss a day, you don\'t have to start over from day one.',
    'badge.gold.name': 'Month 3 Gold',
    'badge.gold.narrative': 'Mastery month with advanced endurance targets.',
    'badge.gold.detail1':
        '30 qualified active days with a 5 active + 2 rest cycle.',
    'badge.gold.detail2':
        'Upper daily: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise combined).',
    'badge.gold.detail3': 'Core daily: 40 reps + 4 sets (Sit-up).',
    'badge.gold.detail4':
        'Lower daily: 50 reps + 4 sets (Squat / Leg Extension combined).',
    'badge.gold.detail5':
        'Progress uses saved workout logs; extra reps beyond the cap do not add credit.',
    'badge.gold.detail6':
        'Even if you miss a day, you don\'t have to start over from day one.',
    'badge.default.goal': 'Goal: {description}',
    'badge.default.requirement': 'Requirement: {requirement} qualified day(s).',
    'badge.default.status': 'Current status: {progress}/{requirement}.',
    'badge.poster.badge_label': 'Badge',
    'badge.poster.user_label': 'Achieved By',
    'badge.poster.requirements_label': 'Qualified Data',
    'leaderboard.title': 'Leaderboard',
    'leaderboard.achievements': 'Achievements',
    'leaderboard.global': 'Global',
    'leaderboard.achievement_progress': 'Achievement Progress',
    'leaderboard.personal_bests': 'Personal Bests',
    'leaderboard.most_reps': 'Most Reps',
    'leaderboard.best_accuracy': 'Best Accuracy',
    'leaderboard.longest_streak': 'Longest Streak',
    'leaderboard.days': 'Days',
    'leaderboard.global_simulated': 'Global Leaderboard (Simulated)',
    'leaderboard.points': '{score} pts',
    'recordings.tab.recordings': 'Record',
    'recordings.tab.profile': 'Profile',
    'recordings.failed_load': 'Failed to load recordings',
    'recordings.empty': 'No recorded videos yet',
    'recordings.file_not_found': 'Video file not found',
    'recordings.file_incomplete':
        'Recording file is incomplete. Please record again.',
    'profile.guest_name': 'User',
    'profile.user_name_label': 'User Name',
    'profile.edit_name': 'Edit',
    'profile.name_hint': 'Enter your name',
    'profile.save_name': 'Save',
    'profile.photo_title': 'Profile Photo',
    'profile.photo_subtitle':
        'Add a full-body photo to personalize your profile.',
    'profile.photo_add': 'Add Photo',
    'profile.photo_change': 'Change Photo',
    'profile.photo_remove': 'Remove Photo',
    'profile.photo_remove_confirm': 'Remove your profile photo?',
    'profile.photo_too_large':
        'Photo is too large. Please choose a smaller image.',
    'profile.photo_error': 'Couldn\'t save the photo. Please try another image.',
    'profile.photo_badge_notice':
        'If no profile photo is added, badge posters will be generated without your photo.',
    'profile.exercise_totals_title': 'All-Time Exercise Totals',
    'profile.exercise_totals_subtitle':
        'From your first workout to your latest.',
    'profile.exercise_empty': 'No exercise data yet',
    'profile.badges_title': 'Badges Earned',
    'profile.badges_empty': 'No badges yet',
    'profile.badge_gallery_saved_note':
        'When a badge unlocks, its poster is auto-saved in gallery album: {album}.',
    'iconic.menu.title': 'Iconic Programs',
    'iconic.menu.subtitle':
        'Choose a premium post-process look for recorded videos. Each program is designed to feel distinct, cinematic, and elegant without adding heat during live capture.',
    'iconic.program.zodiac.eyebrow': 'Post-Processed Signature',
    'iconic.program.zodiac.description':
        'Applies a luxury zodiac overlay after recording. All 12 signs now use distinct palettes, symbols, aura tinting, and engraved styling, with the preview anchored to the Aries art direction.',
    'iconic.program.zodiac.tag.sign_themes': '12 Sign Themes',
    'iconic.program.zodiac.tag.luxury_capsule': 'Luxury Capsule',
    'iconic.program.zodiac.tag.embossed_coin': 'Embossed Coin',
    'iconic.program.zodiac.footer':
        'Recommended for iconic exports. Live capture stays lightweight so the phone does not overheat, while post-process adds the luxury treatment after recording.',
    'iconic.program.festival.eyebrow': 'Cultural Celebration',
    'iconic.program.festival.description':
        'Applies a unique luxury overlay based on the nearest world festival or sporting event. Each festival has its own color palette, ring glow, accuracy bar gradient, and overlay branding.',
    'iconic.program.festival.tag.festivals': '70 Festivals',
    'iconic.program.festival.tag.date_aware': 'Date-Aware',
    'iconic.program.festival.tag.luxury_overlay': 'Luxury Overlay',
    'iconic.program.festival.footer':
        'The theme automatically switches to the nearest upcoming celebration. Record your workout and the active festival look is applied during post-processing.',
    'iconic.program.studio.eyebrow': 'Fully Customizable',
    'iconic.program.studio.description':
        'Use your own premium overlay system with editable rep counter, accuracy bar, narrative flow, icons, color palettes, and finish controls.',
    'iconic.program.studio.tag.custom_program': 'Custom Program',
    'iconic.program.studio.tag.luxury_editor': 'Luxury Editor',
    'iconic.program.studio.tag.premium_control': 'Premium Control',
    'iconic.program.studio.footer':
        'Pick this when you want your own handcrafted luxury overlay instead of a fixed zodiac or festival treatment.',
    'iconic.program.studio.action': 'Open Studio',
    'iconic.program.standard.eyebrow': 'Lightweight Default',
    'iconic.program.standard.description':
        'Keeps the current simple overlay when you do not want a branded cinematic look.',
    'iconic.program.standard.tag.default': 'Default',
    'iconic.program.standard.tag.minimal': 'Minimal',
    'iconic.program.standard.tag.fast_export': 'Fast Export',
    'iconic.program.standard.footer':
        'Use this if you want the existing export style with no premium art direction.',
    'iconic.info.title': 'How It Works',
    'iconic.info.step1': '1. Pick a program here.',
    'iconic.info.step2': '2. Record your workout as usual.',
    'iconic.info.step3':
        '3. The selected style is applied only after recording during post-processing.',
    'iconic.preview.post_process': 'POST-PROCESS PREVIEW',
    'iconic.preview.standard.caption':
        'Default export overlay\nkeeps the current lightweight look.',
    'iconic.preview.editable_luxe': 'EDITABLE LUXE',
    'camera.overlay.skeleton': 'Skeleton',
    'camera.overlay.stop': 'Stop',
    'camera.overlay.record': 'Record',
    'camera.overlay.complete': 'Complete',
    'lang.en': 'English',
    'lang.es': 'Spanish',
    'lang.ja': 'Japanese',
    'lang.my': 'Burmese',
    'lang.hi': 'Hindi',
    'lang.pt': 'Portuguese',
    'lang.zh': 'Mandarin Chinese',
    'lang.de': 'German',
  };

  static const Map<String, String> _esValues = {
    'app.title': 'H&F',
    'nav.exercises': 'Ejercicios',
    'nav.progress': 'Progreso',
    'nav.recordings': 'Grabar y perfil',
    'common.cancel': 'Cancelar',
    'common.retry': 'Reintentar',
    'common.load_exercises': 'Cargar ejercicios',
    'common.clear_data': 'Borrar datos',
    'common.ok': 'OK',
    'common.close': 'Cerrar',
    'common.error_with_message': 'Error: {message}',
    'common.copy': 'Copiar',
    'common.remove': 'Eliminar',
    'premium.license.title': 'Licencia Premium',
    'premium.license.heading': 'Contacto y compra de licencia Premium',
    'premium.license.contact_us': 'Contáctanos',
    'premium.license.active': 'Premium activo',
    'premium.license.inactive': 'Premium inactivo',
    'premium.license.expires': 'Vence: {date}',
    'premium.license.field_label': 'Clave de licencia',
    'premium.license.field_hint': 'HF-XXXX-XXXX-XXXX-XXXX',
    'premium.license.enter_key': 'Ingresa tu clave de licencia.',
    'premium.license.wait': 'Espera...',
    'premium.license.activate': 'Activar licencia',
    'premium.license.deactivate_device': 'Desactivar en este dispositivo',
    'premium.license.security_notes': 'Notas de seguridad',
    'premium.license.security_body':
        'Si la activación se verifica en el servidor, se guarda en almacenamiento seguro cifrado y se vincula a este dispositivo.',
    'premium.license.disabled_device':
        'Premium desactivado en este dispositivo.',
    'premium.license.copied': 'Copiado: {value}',
    'premium.license.already_active':
        'La licencia ya está activa en este dispositivo.',
    'premium.license.activated': 'Premium activado correctamente.',
    'overlay.studio.preview_phase': 'Fase de vista previa',
    'overlay.studio.preview_phase_subtitle':
        'Cambia el estado de demostración sin dejar los controles de fase dentro de la vista previa fijada.',
    'overlay.studio.master_mode': 'Modo maestro',
    'overlay.studio.master_mode_subtitle':
        'Ajusta el rendimiento de exportación y el comportamiento del overlay de lujo.',
    'overlay.studio.performance_mode': 'Modo de rendimiento',
    'overlay.studio.apply_festival_luxe': 'Apply World Festival Luxe',
    'overlay.studio.remove_festival_luxe': 'Remove World Festival Luxe',
    'overlay.studio.text_branding': 'Texto y marca',
    'overlay.studio.text_branding_subtitle':
        'Nombre de lujo, tono del subtítulo y línea distintiva.',
    'overlay.studio.show_branding_bar': 'Mostrar barra de marca',
    'overlay.studio.show_branding_bar_subtitle':
        'Activa o desactiva la barra superior con logo y texto.',
    'overlay.studio.title_field': 'Título',
    'overlay.studio.subtitle_field': 'Subtítulo',
    'overlay.studio.branding_field': 'Marca',
    'overlay.studio.banner_border': 'Borde del banner',
    'overlay.studio.banner_border_subtitle':
        'Borde degradado multicolor estilo TikTok.',
    'overlay.studio.narrative_flow': 'Flujo narrativo',
    'overlay.studio.narrative_flow_subtitle':
        'Estas 4 frases aparecen solo en el posprocesado. Define el número de repetición de cada texto. El texto solo aparece cuando esa repetición alcanza 80% de precisión.',
    'overlay.studio.cue_label': 'Texto {number}',
    'overlay.studio.icon_system': 'Sistema de iconos',
    'overlay.studio.icon_system_subtitle':
        'Importa iconos SVG por fase. Limpiamos fondos blancos, ajustamos bordes irregulares y mantenemos una exportación pulida.',
    'overlay.studio.default_slot': 'Predeterminado',
    'overlay.studio.up_phase': 'Fase SUBIDA',
    'overlay.studio.down_phase': 'Fase BAJADA',
    'overlay.studio.color_system': 'Sistema de color',
    'overlay.studio.color_system_subtitle':
        'Control de color principal, acento metálico y colores por fase.',
    'overlay.studio.primary_color': 'Primario',
    'overlay.studio.secondary_color': 'Secundario',
    'overlay.studio.accent_color': 'Acento',
    'overlay.studio.layout_control': 'Control de diseño',
    'overlay.studio.layout_control_subtitle':
        'Mueve el grupo de precisión y repeticiones, mantén estable la barra de marca y ajusta la escala general.',
    'overlay.studio.counter_cluster': 'Grupo del contador',
    'overlay.studio.stats_card_slot': 'Posición de tarjeta de estadísticas',
    'overlay.studio.global_scale': 'Escala global',
    'overlay.studio.overlay_opacity': 'Opacidad del overlay',
    'overlay.studio.luxe_finish': 'Acabado luxe',
    'overlay.studio.luxe_finish_subtitle':
        'Agrega una atmósfera premium sin cambiar tu sistema de tema actual.',
    'overlay.studio.vignette_focus': 'Enfoque de viñeta',
    'overlay.studio.bloom_glow': 'Brillo bloom',
    'overlay.studio.sparkle_field': 'Campo de destellos',
    'overlay.studio.sheen_sweep': 'Barrido de brillo',
    'overlay.studio.border_width': 'Ancho del borde',
    'overlay.studio.rotation': 'Rotación',
    'overlay.studio.colors': 'Colores ({count})',
    'overlay.studio.presets': 'Preajustes',
    'overlay.studio.svg_import_failed': 'La importación SVG falló: {error}',
    'overlay.studio.no_svg_selected': 'Aún no se ha seleccionado un SVG',
    'overlay.studio.svg_description_selected':
        'La exportación usa este SVG saneado. Los fondos blancos y los bordes irregulares se limpian automáticamente.',
    'overlay.studio.svg_description_empty':
        'Solo SVG. Elige un archivo y lo sanearemos para obtener insignias de exportación más limpias.',
    'overlay.studio.fallback_badge': 'Insignia de respaldo: {glyph}',
    'overlay.studio.importing': 'Importando...',
    'overlay.studio.replace_svg': 'Reemplazar SVG',
    'overlay.studio.choose_svg': 'Elegir SVG',
    'overlay.studio.supported_input':
        'Entrada compatible: solo archivos `.svg`.',
    'recordings.player_title': 'Grabación de entrenamiento',
    'analytics.no_data_available': 'No hay datos disponibles',
    'analytics.chart.date': 'Fecha',
    'analytics.chart.accuracy_percent': 'Precisión (%)',
    'analytics.chart.repetitions': 'Repeticiones',
    'analytics.title': 'Analíticas avanzadas',
    'analytics.performance_summary': 'Resumen de rendimiento',
    'analytics.consistency': 'Constancia',
    'analytics.improvement': 'Mejora',
    'analytics.peak': 'Pico',
    'exercise.recording.exporting_video': 'Exportando video',
    'exercise.recording.applying_overlay_effects':
        'Aplicando los efectos de overlay seleccionados...',
    'exercise.recording.saved_raw_fallback':
        'Video guardado. La exportación del overlay volvió a la grabación original.',
    'exercise.recording.saved_without_overlay':
        'Video guardado sin overlay de posprocesado: {error}',
    'premium.badge': 'PREMIUM',
    'premium.menu_only':
        'Este menÃƒÆ’Ã‚Âº estÃƒÆ’Ã‚Â¡ disponible solo para usuarios Premium.',
    'home.exercises_list': 'Lista de ejercicios',
    'home.exercises_simple_form': 'Formulario simple de ejercicio',
    'home.no_supported_exercises': 'No hay ejercicios compatibles disponibles',
    'home.check_exercise_config': 'Revisa la configuraciÃƒÆ’Ã‚Â³n de ejercicios',
    'home.error_loading_exercise': 'Error al cargar el ejercicio: {error}',
    'home.image_reference_count': '{count} referencia de imagen',
    'home.today_progress_premium': 'Progreso de hoy (Premium)',
    'home.today_progress_locked_desc':
        'Los datos del menÃƒÆ’Ã‚Âº progresivo estÃƒÆ’Ã‚Â¡n disponibles para usuarios Premium.',
    'home.today_progress': 'Progreso de hoy',
    'home.total_reps': 'Repeticiones totales',
    'home.workouts': 'Entrenamientos',
    'home.calories': 'CalorÃƒÆ’Ã‚Â­as',
    'home.daily_goal': 'Meta diaria: {current}/{goal}',
    'home.daily_goal_achieved': 'Ãƒâ€šÃ‚Â¡Meta diaria lograda!',
    'home.progress_premium_title': 'El progreso es Premium',
    'home.progress_premium_message':
        'Las analÃƒÆ’Ã‚Â­ticas detalladas de progreso estÃƒÆ’Ã‚Â¡n desbloqueadas en Premium.',
    'home.recordings_premium_title': 'Las grabaciones son Premium',
    'home.recordings_premium_message':
        'El historial de grabaciÃƒÆ’Ã‚Â³n de video estÃƒÆ’Ã‚Â¡ disponible solo en Premium.',
    'home.simple_form': 'Formulario de {name}',
    'home.quick_form_summary': 'Resumen rÃƒÆ’Ã‚Â¡pido del formulario',
    'home.form_images': 'ImÃƒÆ’Ã‚Â¡genes de la forma',
    'home.exercise_list_notice_title': 'Recordatorio rÃƒÆ’Ã‚Â¡pido',
    'home.exercise_list_notice_message':
        'Revisa cada formulario de ejercicio porque puede haber avisos. Nota: el ejercicio situp tiene un aviso importante.',
    'home.simple_form_notice':
        'Nota sobre la barra de precisiÃƒÆ’Ã‚Â³n y el conteo:\nNuestra IA estÃƒÆ’Ã‚Â¡ diseÃƒÆ’Ã‚Â±ada para reconocer ejercicios que siguen de cerca nuestras guÃƒÆ’Ã‚Â­as visuales. Ofrece un conteo fluido con buena precisiÃƒÆ’Ã‚Â³n, aunque no proporciona asesorÃƒÆ’Ã‚Â­a tÃƒÆ’Ã‚Â©cnica formal. No olvides que nuestra app no tiene 100% de precisiÃƒÆ’Ã‚Â³n.\n\nPara el ejercicio en vista lateral, mantente en posiciÃƒÆ’Ã‚Â³n lateral, y para el ejercicio en vista frontal, mantente en posiciÃƒÆ’Ã‚Â³n frontal. AsÃƒÆ’Ã‚Â­ los resultados serÃƒÆ’Ã‚Â¡n correctos.\n\nEl seguimiento puede ser inexacto si:\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Tu cuerpo completo no estÃƒÆ’Ã‚Â¡ visible en el encuadre de la cÃƒÆ’Ã‚Â¡mara.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Hay mÃƒÆ’Ã‚Â¡s de una persona en la cÃƒÆ’Ã‚Â¡mara.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ La habitaciÃƒÆ’Ã‚Â³n estÃƒÆ’Ã‚Â¡ muy oscura o tiene destellos/reflejos fuertes.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Coloca la cÃƒÆ’Ã‚Â¡mara en una posiciÃƒÆ’Ã‚Â³n que no estÃƒÆ’Ã‚Â© demasiado baja ni demasiado alta respecto a tu cuerpo.',
    'exercise.guide.title': 'GuÃƒÆ’Ã‚Â­a rÃƒÆ’Ã‚Â¡pida',
    'exercise.guide.step1':
        'Si quieres crear un landmark, pulsa el botÃƒÆ’Ã‚Â³n de esqueleto.',
    'exercise.guide.step2':
        'Si quieres grabar un video, pulsa el botÃƒÆ’Ã‚Â³n de grabar.',
    'exercise.guide.step3':
        'Si quieres detener y guardar la grabaciÃƒÆ’Ã‚Â³n, toca dos veces la pantalla o pulsa el botÃƒÆ’Ã‚Â³n de atrÃƒÆ’Ã‚Â¡s.',
    'exercise.guide.step4':
        'Cuando termines el ejercicio, pulsa el botÃƒÆ’Ã‚Â³n de completar y luego pulsa Guardar para guardar el ejercicio.',
    'exercise.error.setup_title': 'Error de configuraciÃƒÆ’Ã‚Â³n',
    'exercise.error.setup_message': 'No se pudo iniciar: {error}',
    'exercise.error.pose_title': 'Error de detecciÃƒÆ’Ã‚Â³n de pose',
    'exercise.error.pose_message':
        'No se pudo iniciar la detecciÃƒÆ’Ã‚Â³n de pose. AsegÃƒÆ’Ã‚Âºrate de que Google Play Services estÃƒÆ’Ã‚Â© actualizado.',
    'exercise.premium.landmarks':
        'La superposiciÃƒÆ’Ã‚Â³n de landmarks es una funciÃƒÆ’Ã‚Â³n Premium.',
    'exercise.premium.recording':
        'La grabaciÃƒÆ’Ã‚Â³n de video estÃƒÆ’Ã‚Â¡ disponible en la versiÃƒÆ’Ã‚Â³n Premium. Actualiza para desbloquear esta funciÃƒÆ’Ã‚Â³n.',
    'exercise.recording.failed_start': 'No se pudo grabar la pantalla: {error}',
    'exercise.recording.permission_denied':
        'Permiso denegado para grabaciÃƒÆ’Ã‚Â³n de pantalla/audio',
    'exercise.recording.failed_save':
        'No se pudo guardar la grabaciÃƒÆ’Ã‚Â³n de pantalla',
    'exercise.recording.saved_gallery': 'Guardado en la galerÃƒÆ’Ã‚Â­a ({album})',
    'exercise.recording.saved_app':
        'Guardado en el almacenamiento de la app: {path}',
    'exercise.recording.saved_phone':
        'Video guardado en el almacenamiento del telÃƒÆ’Ã‚Â©fono',
    'exercise.recording.failed_video': 'No se pudo grabar el video: {error}',
    'exercise.recording.preparing_luxury_video':
        'Estamos preparando tu video de entrenamiento de lujo para ti.',
    'exercise.recording.keep_screen_open':
        'MantÃƒÆ’Ã‚Â©n esta pantalla abierta por un momento.',
    'exercise.premium.title': 'FunciÃƒÆ’Ã‚Â³n Premium',
    'exercise.premium.not_now': 'Ahora no',
    'exercise.premium.upgrade': 'Actualizar',
    'exercise.premium.required_title': 'Premium requerido',
    'exercise.premium.required_message':
        'Guardar entrenamiento, conteo y seguimiento de progreso estÃƒÆ’Ã‚Â¡n disponibles solo en Premium.',
    'exercise.camera.error_title': 'Error de cÃƒÆ’Ã‚Â¡mara',
    'exercise.camera.error_message':
        'No se pudo iniciar la cÃƒÆ’Ã‚Â¡mara. Revisa permisos e intÃƒÆ’Ã‚Â©ntalo de nuevo.',
    'exercise.counting_premium': 'Conteo (Premium)',
    'exercise.summary.title': 'Ãƒâ€šÃ‚Â¡Entrenamiento completado!',
    'exercise.summary.total_reps': 'Repeticiones totales',
    'exercise.summary.avg_accuracy': 'PrecisiÃƒÆ’Ã‚Â³n promedio',
    'exercise.summary.duration': 'DuraciÃƒÆ’Ã‚Â³n',
    'exercise.summary.seconds': '{value} segundos',
    'exercise.summary.best_accuracy': 'Mejor precisiÃƒÆ’Ã‚Â³n por repeticiÃƒÆ’Ã‚Â³n',
    'exercise.summary.close': 'Cerrar',
    'exercise.summary.view_details': 'Guardar',
    'exercise.card.type.dynamic': 'DinÃƒÆ’Ã‚Â¡mico',
    'exercise.card.type.static': 'EstÃƒÆ’Ã‚Â¡tico',
    'exercise.card.view.front': 'Vista frontal',
    'exercise.card.view.side': 'Vista lateral',
    'exercise.card.total_reps': 'Repeticiones totales',
    'exercise.card.avg_accuracy': 'PrecisiÃƒÆ’Ã‚Â³n prom.',
    'exercise.card.select': 'Seleccionar ejercicio',
    'exercise.time.today': 'Hoy',
    'exercise.time.yesterday': 'Ayer',
    'exercise.time.days_ago': 'hace {value} dÃƒÆ’Ã‚Â­as',
    'exercise.time.weeks_ago': 'hace {value} semanas',
    'exercise.time.months_ago': 'hace {value} meses',
    'guide.squat.subtitle':
        'MantÃƒÆ’Ã‚Â©n el pecho arriba, caderas atrÃƒÆ’Ã‚Â¡s y rodillas alineadas con los pies.',
    'guide.squat.step1':
        'PÃƒÆ’Ã‚Â¡rate con los pies al ancho de los hombros y activa el core.',
    'guide.squat.step2':
        'Baja hasta que los muslos estÃƒÆ’Ã‚Â©n casi paralelos manteniendo los talones apoyados.',
    'guide.squat.step3':
        'Empuja con los talones para subir sin bloquear las rodillas.',
    'guide.pushup.subtitle':
        'MantÃƒÆ’Ã‚Â©n una lÃƒÆ’Ã‚Â­nea recta de la cabeza a los talones y controla cada repeticiÃƒÆ’Ã‚Â³n.',
    'guide.pushup.step1':
        'Comienza en plancha alta con manos un poco mÃƒÆ’Ã‚Â¡s anchas que los hombros.',
    'guide.pushup.step2':
        'Baja el pecho flexionando los codos a unos 45 grados.',
    'guide.pushup.step3':
        'Empuja hacia arriba manteniendo el core firme y las caderas niveladas.',
    'guide.situp.subtitle':
        'Usa un movimiento controlado del core en lugar de tirar del cuello.',
    'guide.situp.step1':
        'AcuÃƒÆ’Ã‚Â©state boca arriba con rodillas flexionadas y pies apoyados.',
    'guide.situp.step2': 'Eleva el torso contrayendo el abdomen.',
    'guide.situp.step3':
        'Baja lentamente con control antes de la siguiente repeticiÃƒÆ’Ã‚Â³n.',
    'guide.bicep.subtitle':
        'MantÃƒÆ’Ã‚Â©n los codos cerca del cuerpo y evita balancearte.',
    'guide.bicep.step1': 'PÃƒÆ’Ã‚Â¡rate erguido con mancuernas y palmas al frente.',
    'guide.bicep.step2':
        'Flexiona los codos para subir las pesas sin mover los hombros.',
    'guide.bicep.step3':
        'Baja las pesas lentamente hasta la extensiÃƒÆ’Ã‚Â³n completa.',
    'guide.shoulder.subtitle':
        'Empuja verticalmente manteniendo las costillas abajo y el core activo.',
    'guide.shoulder.step1':
        'Empieza con las pesas a la altura de los hombros y muÃƒÆ’Ã‚Â±ecas neutras.',
    'guide.shoulder.step2':
        'Empuja hacia arriba hasta extender los brazos sobre la cabeza.',
    'guide.shoulder.step3': 'Baja con control hasta la altura de los hombros.',
    'guide.leg.subtitle':
        'MuÃƒÆ’Ã‚Â©vete en un rango controlado y evita golpear las rodillas.',
    'guide.leg.step1':
        'SiÃƒÆ’Ã‚Â©ntate con la espalda apoyada y las piernas bajo la almohadilla.',
    'guide.leg.step2':
        'Extiende las rodillas para levantar la almohadilla manteniendo las caderas estables.',
    'guide.leg.step3': 'Baja lentamente hasta flexionar las rodillas y repite.',
    'settings.title': 'Ajustes',
    'settings.premium_features': 'Funciones Premium',
    'settings.app_settings': 'Ajustes de la app',
    'settings.profile_name': 'Nombre de perfil',
    'settings.appearance': 'Apariencia',
    'settings.data': 'Datos',
    'settings.about': 'Acerca de',
    'settings.premium_account': 'Cuenta Premium',
    'settings.unlock_all_features': 'Desbloquear todas las funciones premium',
    'settings.voice_counting': 'Conteo por voz',
    'settings.speak_count': 'Decir el conteo durante las repeticiones',
    'settings.voice_counting_language': 'Idioma del conteo por voz',
    'settings.upgrade_to_premium': 'Actualizar a Premium',
    'settings.upgrade_subtitle': 'ObtÃƒÆ’Ã‚Â©n conteo de voz, grabaciÃƒÆ’Ã‚Â³n de video y mÃƒÆ’Ã‚Â¡s',
    'settings.voice_coach': 'Coach de voz',
    'settings.voice_feedback': 'Recibe feedback de voz en tiempo real',
    'settings.show_landmarks': 'Mostrar landmarks',
    'settings.display_skeleton': 'Mostrar superposiciÃƒÆ’Ã‚Â³n del esqueleto',
    'settings.auto_recording': 'GrabaciÃƒÆ’Ã‚Â³n automÃƒÆ’Ã‚Â¡tica',
    'settings.auto_recording_subtitle': 'Grabar entrenamientos automÃƒÆ’Ã‚Â¡ticamente',
    'settings.theme': 'Tema',
    'settings.language': 'Idioma',
    'settings.language_subtitle': 'Cambiar idioma de la app',
    'settings.clear_data': 'Borrar datos',
    'settings.clear_data_subtitle':
        'Eliminar todo el historial de entrenamientos',
    'settings.version': 'VersiÃƒÆ’Ã‚Â³n',
    'settings.privacy_policy': 'PolÃƒÆ’Ã‚Â­tica de privacidad',
    'settings.terms': 'TÃƒÆ’Ã‚Â©rminos de servicio',
    'settings.disclaimer': 'Descargo de responsabilidad',
    'legal.last_updated': 'ÃƒÆ’Ã…Â¡ltima actualizaciÃƒÆ’Ã‚Â³n: {date}',
    'legal.privacy.content':
        '1) Datos que procesamos\n'
        'H&F almacena registros de entrenamiento, progreso de insignias, preferencias de la app y rutas opcionales de archivos de grabaciÃƒÆ’Ã‚Â³n en tu dispositivo.\n\n'
        '2) ActivaciÃƒÆ’Ã‚Â³n Premium\n'
        'La activaciÃƒÆ’Ã‚Â³n Premium necesita internet al menos una vez. Durante la activaciÃƒÆ’Ã‚Â³n, clave de licencia, hash del identificador del dispositivo, versiÃƒÆ’Ã‚Â³n de la app y plataforma se envÃƒÆ’Ã‚Â­an a nuestro servidor de licencias. DespuÃƒÆ’Ã‚Â©s de la activaciÃƒÆ’Ã‚Â³n, la elegibilidad Premium se valida localmente y la app puede usarse sin conexiÃƒÆ’Ã‚Â³n.\n\n'
        '3) CÃƒÆ’Ã‚Â¡mara, micrÃƒÆ’Ã‚Â³fono, almacenamiento y potencia de procesamiento\n'
        'La cÃƒÆ’Ã‚Â¡mara se usa para la detecciÃƒÆ’Ã‚Â³n de postura. Usa la potencia de procesamiento de tu dispositivo para analizar la postura. Los permisos de micrÃƒÆ’Ã‚Â³fono y grabaciÃƒÆ’Ã‚Â³n de pantalla se usan solo cuando activas las funciones de grabaciÃƒÆ’Ã‚Â³n. Los videos guardados permanecen en tu dispositivo o galerÃƒÆ’Ã‚Â­a.\n\n'
        '4) CÃƒÆ’Ã‚Â³mo usamos los datos\n'
        'Los datos se usan para contar repeticiones, calcular precisiÃƒÆ’Ã‚Â³n, registrar progreso, desbloquear insignias y ofrecer funciones Premium.\n\n'
        '5) Compartir\n'
        'No vendemos tus datos personales. Los datos de verificaciÃƒÆ’Ã‚Â³n de licencia se procesan solo para activar y proteger el acceso Premium.\n\n'
        '6) Tu control\n'
        'Puedes borrar todo o desinstalar la app en cualquier momento. Borrar datos elimina el historial local y el estado Premium almacenado.\n\n'
        '7) Seguridad\n'
        'La app usa verificaciones de integridad y almacenamiento local seguro para reducir riesgos de manipulaciÃƒÆ’Ã‚Â³n, pero ningÃƒÆ’Ã‚Âºn sistema es completamente seguro.',
    'legal.terms.content':
        'Al usar H&F aceptas estos TÃƒÆ’Ã‚Â©rminos.\n\n'
        '1) Uso del servicio\n'
        'H&F es una app de apoyo fitness. Eres responsable de tu seguridad y decisiones de salud.\n\n'
        '2) Cuenta y licencia\n'
        'Premium requiere una clave de licencia vÃƒÆ’Ã‚Â¡lida. Las licencias pueden limitarse por dispositivo y bloquearse por abuso, revocaciÃƒÆ’Ã‚Â³n o violaciones de seguridad.\n\n'
        '3) Modo sin conexiÃƒÆ’Ã‚Â³n\n'
        'Tras una activaciÃƒÆ’Ã‚Â³n exitosa, las funciones bÃƒÆ’Ã‚Â¡sicas y Premium pueden ejecutarse sin internet en el mismo dispositivo. Reinstalar, borrar datos sensibles o fallas de integridad pueden requerir activaciÃƒÆ’Ã‚Â³n en lÃƒÆ’Ã‚Â­nea otra vez.\n\n'
        '4) Restricciones\n'
        'No manipules la seguridad, intentes ingenierÃƒÆ’Ã‚Â­a inversa de licencias ni uses la app para actividades ilegales.\n\n'
        '5) Propiedad intelectual\n'
        'El software, la marca y el contenido de la app siguen siendo propiedad de H&F y sus licenciantes.\n\n'
        '6) Sin garantÃƒÆ’Ã‚Â­a\n'
        'La app se ofrece "tal cual" sin garantÃƒÆ’Ã‚Â­as de operaciÃƒÆ’Ã‚Â³n ininterrumpida ni resultados fitness especÃƒÆ’Ã‚Â­ficos. El contador de mi app puede haber contado de mÃƒÆ’Ã‚Â¡s o de menos por diversos motivos.\n\n'
        '7) LimitaciÃƒÆ’Ã‚Â³n de responsabilidad\n'
        'H&F no es responsable por daÃƒÆ’Ã‚Â±os indirectos, incidentales o consecuentes por el uso de la app.',
    'legal.disclaimer.content':
        'H&F no es un servicio mÃƒÆ’Ã‚Â©dico y no ofrece asesoramiento, diagnÃƒÆ’Ã‚Â³stico ni tratamiento mÃƒÆ’Ã‚Â©dico.\n\n'
        '1) Riesgo del entrenamiento\n'
        'El ejercicio presenta riesgo de lesiones. Detente de inmediato si sientes dolor, mareo, dificultad para respirar o malestar y consulta a un profesional calificado.\n\n'
        '2) Conteo de IA y retroalimentaciÃƒÆ’Ã‚Â³n de forma\n'
        'La detecciÃƒÆ’Ã‚Â³n de postura y el conteo son estimaciones y pueden fallar por ÃƒÆ’Ã‚Â¡ngulo de cÃƒÆ’Ã‚Â¡mara, iluminaciÃƒÆ’Ã‚Â³n, oclusiÃƒÆ’Ã‚Â³n, ropa o velocidad del movimiento.\n\n'
        '3) Rendimiento durante la grabaciÃƒÆ’Ã‚Â³n\n'
        'El conteo/voz estÃƒÆ’Ã‚Â¡ diseÃƒÆ’Ã‚Â±ado para funcionar bien durante entrenamientos normales con el telÃƒÆ’Ã‚Â©fono encendido. La detecciÃƒÆ’Ã‚Â³n de postura (conteo) y la grabaciÃƒÆ’Ã‚Â³n de video pueden ejecutarse a la vez .\n\n'
        '4) Situaciones de emergencia\n'
        'No confÃƒÆ’Ã‚Â­es en esta app para emergencias. Contacta a los servicios de emergencia locales de inmediato cuando sea necesario.\n\n'
        '5) Responsabilidad del usuario\n'
        'Eres responsable de un espacio de entrenamiento seguro, tÃƒÆ’Ã‚Â©cnica adecuada y obtener cualquier autorizaciÃƒÆ’Ã‚Â³n mÃƒÆ’Ã‚Â©dica antes de entrenar.\n\n'
        '6) Grabaciones y privacidad de terceros\n'
        'Si grabas entrenamientos, debes obtener el consentimiento de quienes puedan aparecer en video o audio.\n\n'
        '7) Resultados\n'
        'Los resultados fitness varÃƒÆ’Ã‚Â­an por persona. H&F no garantiza rendimientos o resultados de salud especÃƒÆ’Ã‚Â­ficos.',
    'settings.select_theme': 'Seleccionar tema',
    'settings.select_language': 'Seleccionar idioma',
    'onboarding.language_title': 'Elige tu idioma',
    'onboarding.language_subtitle':
        'Puedes cambiarlo mÃƒÆ’Ã‚Â¡s tarde en Ajustes.',
    'onboarding.name_title': 'Ãƒâ€šÃ‚Â¿CuÃƒÆ’Ã‚Â¡l es tu nombre?',
    'onboarding.name_subtitle': 'Esto aparecerÃƒÆ’Ã‚Â¡ en tu perfil.',
    'onboarding.name_hint': 'Escribe tu nombre',
    'onboarding.name_required': 'Por favor, escribe tu nombre',
    'onboarding.disclaimer_title': 'Aviso',
    'onboarding.terms_title': 'TÃƒÆ’Ã‚Â©rminos de servicio',
    'onboarding.accept_notice':
        'Acepta para continuar usando la app.',
    'onboarding.accept_checkbox': 'Acepto',
    'onboarding.continue': 'Continuar',
    'onboarding.start_app': 'Iniciar app',
    'settings.clear_all_data': 'Borrar todos los datos',
    'settings.clear_all_data_desc':
        'Esto eliminarÃƒÆ’Ã‚Â¡ todo tu historial de entrenamientos, logros y ajustes. Esta acciÃƒÆ’Ã‚Â³n no se puede deshacer.',
    'settings.clear_success':
        'Todos los datos del usuario se borraron correctamente.',
    'settings.clear_failed': 'Error al borrar datos: {error}',
    'theme.light': 'Claro',
    'theme.dark': 'Oscuro',
    'theme.gold': 'Dorado',
    'theme.pink': 'Rosa',
    'progress.title': 'Progreso y analÃƒÆ’Ã‚Â­ticas',
    'progress.overview': 'Resumen',
    'progress.exercises': 'Ejercicios',
    'progress.badges': 'Insignias',
    'progress.no_data': 'No hay datos disponibles',
    'progress.weekly_summary': 'Resumen semanal',
    'progress.streak_days': 'racha de {count} dÃƒÆ’Ã‚Â­as',
    'progress.recent_workouts': 'Entrenamientos recientes',
    'progress.no_workouts': 'AÃƒÆ’Ã‚Âºn no hay entrenamientos',
    'progress.workout_summary':
        '{reps} repeticiones ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ {accuracy}% de precisiÃƒÆ’Ã‚Â³n',
    'progress.achievements': 'Logros',
    'progress.badges_unlocked': '{unlocked}/{total} insignias desbloqueadas',
    'progress.view_all_achievements': 'Ver todos los logros',
    'progress.day.sun': 'Dom',
    'progress.day.mon': 'Lun',
    'progress.day.tue': 'Mar',
    'progress.day.wed': 'MiÃƒÆ’Ã‚Â©',
    'progress.day.thu': 'Jue',
    'progress.day.fri': 'Vie',
    'progress.day.sat': 'SÃƒÆ’Ã‚Â¡b',
    'progress.time.just_now': 'Ahora mismo',
    'progress.time.minutes_ago': 'hace {value}m',
    'progress.time.hours_ago': 'hace {value}h',
    'progress.time.days_ago': 'hace {value}d',
    'progress.time.weeks_ago': 'hace {value}s',
    'progress.analytics_intro_title':
        'CÃƒÆ’Ã‚Â³mo entender las analÃƒÆ’Ã‚Â­ticas de ejercicio',
    'progress.analytics_intro_line1':
        'Repeticiones totales = todas las repeticiones guardadas de este ejercicio en todas las sesiones.',
    'progress.analytics_intro_line2':
        'PrecisiÃƒÆ’Ã‚Â³n prom. = precisiÃƒÆ’Ã‚Â³n promedio de la forma en todas las sesiones guardadas.',
    'progress.analytics_intro_line3':
        'GrÃƒÆ’Ã‚Â¡fico de tendencia = precisiÃƒÆ’Ã‚Â³n a lo largo del tiempo (una lÃƒÆ’Ã‚Â­nea mÃƒÆ’Ã‚Â¡s alta significa mejor forma).',
    'progress.analytics_intro_line4':
        'Las analÃƒÆ’Ã‚Â­ticas se actualizan solo despuÃƒÆ’Ã‚Â©s de guardar una sesiÃƒÆ’Ã‚Â³n de entrenamiento.',
    'progress.read_exercise_analytics_title':
        'CÃƒÆ’Ã‚Â³mo leer las analÃƒÆ’Ã‚Â­ticas de ejercicio',
    'progress.read_exercise_analytics_line1':
        'PrecisiÃƒÆ’Ã‚Â³n mÃƒÆ’Ã‚Â¡s reciente = tu puntuaciÃƒÆ’Ã‚Â³n de forma mÃƒÆ’Ã‚Â¡s reciente.',
    'progress.read_exercise_analytics_line2':
        'Mejor precisiÃƒÆ’Ã‚Â³n = tu puntuaciÃƒÆ’Ã‚Â³n mÃƒÆ’Ã‚Â¡s alta hasta ahora.',
    'progress.read_exercise_analytics_line3':
        'Las barras de sesiones muestran las ÃƒÆ’Ã‚Âºltimas 6 sesiones. Una barra mÃƒÆ’Ã‚Â¡s alta significa mejor precisiÃƒÆ’Ã‚Â³n.',
    'progress.read_exercise_analytics_line4':
        'El nÃƒÆ’Ã‚Âºmero debajo de cada barra son las repeticiones de esa sesiÃƒÆ’Ã‚Â³n.',
    'progress.latest_accuracy': 'PrecisiÃƒÆ’Ã‚Â³n mÃƒÆ’Ã‚Â¡s reciente',
    'progress.best_accuracy': 'Mejor precisiÃƒÆ’Ã‚Â³n',
    'progress.trend_vs_previous_session':
        '{sign}{delta}% vs la sesiÃƒÆ’Ã‚Â³n anterior',
    'progress.last_sessions_accuracy_title': 'ÃƒÆ’Ã…Â¡ltimas sesiones (precisiÃƒÆ’Ã‚Â³n %)',
    'progress.reps_short': 'reps',
    'progress.chart_accuracy_trend_legend':
        'Las barras mÃƒÆ’Ã‚Â¡s altas indican mejor precisiÃƒÆ’Ã‚Â³n. Las etiquetas debajo son reps por sesiÃƒÆ’Ã‚Â³n.',
    'progress.total_reps_all_time': 'Repeticiones totales (histÃƒÆ’Ã‚Â³rico)',
    'progress.avg_accuracy_all_sessions':
        'PrecisiÃƒÆ’Ã‚Â³n prom. (todas las sesiones)',
    'progress.sessions': 'Sesiones',
    'progress.chart_accuracy_trend':
        'El grÃƒÆ’Ã‚Â¡fico muestra la tendencia de precisiÃƒÆ’Ã‚Â³n por fecha de sesiÃƒÆ’Ã‚Â³n.',
    'progress.no_sessions':
        'AÃƒÆ’Ã‚Âºn no hay sesiones. Guarda un entrenamiento para ver analÃƒÆ’Ã‚Â­ticas aquÃƒÆ’Ã‚Â­.',
    'badges.empty':
        'AÃƒÆ’Ã‚Âºn no hay insignias.\nEmpieza a entrenar para desbloquear tu primer hito.',
    'badges.collection': 'Tu colecciÃƒÆ’Ã‚Â³n de insignias',
    'badges.current_status': 'Estado actual de insignias',
    'badges.unlocked_count': '{unlocked}/{total} insignias desbloqueadas',
    'badges.tier': 'Nivel: {tier}',
    'badges.next_target':
        'Siguiente objetivo: {name} ({progress}/{requirement}) - {percent}% completado',
    'badges.how_it_works': 'CÃƒÆ’Ã‚Â³mo funciona este sistema de insignias',
    'badges.guide_1':
        'Las insignias usan un ritmo de 5 dÃƒÆ’Ã‚Â­as activos y 2 dÃƒÆ’Ã‚Â­as de descanso. Solo los dÃƒÆ’Ã‚Â­as activos cuentan para el progreso.',
    'badges.guide_2':
        'Los entrenamientos en dÃƒÆ’Ã‚Â­a de descanso se guardan normalmente pero no suman ni restan progreso de insignias.',
    'badges.guide_3':
        'Las metas diarias tienen lÃƒÆ’Ã‚Â­mite: hacer repeticiones/series extra no da crÃƒÆ’Ã‚Â©dito adicional.',
    'badges.guide_4':
        'No se necesitan mancuernas ni mÃƒÆ’Ã‚Â¡quinas: tambiÃƒÆ’Ã‚Â©n puedes ganar insignias usando alternativas (p. ej., push-ups para Upper, squats para Lower).',
    'badges.guide_5':
        'El progreso se calcula desde los registros guardados; los datos reales impulsan los desbloqueos.',
    'badges.unlocked_on': 'Desbloqueado el {date}',
    'badges.tap_full_plan': 'Toca para ver el plan completo',
    'badges.new_unlock_today': 'Ãƒâ€šÃ‚Â¡Desbloqueado hoy! Buen trabajo.',
    'badges.unlocked_banner':
        'Ãƒâ€šÃ‚Â¡Desbloqueado! Excelente constancia. MantÃƒÆ’Ã‚Â©n este ritmo.',
    'badges.poster_saved_note':
        'El pÃƒÆ’Ã‚Â³ster de la insignia se guardÃƒÆ’Ã‚Â³ automÃƒÆ’Ã‚Â¡ticamente en la galerÃƒÆ’Ã‚Â­a: {album}.',
    'badges.poster_save_failed_note':
        'No se pudo guardar el pÃƒÆ’Ã‚Â³ster en la galerÃƒÆ’Ã‚Â­a. Revisa el permiso de fotos.',
    'badges.no_tier': 'AÃƒÆ’Ã‚Âºn no hay nivel desbloqueado',
    'badges.motivation_unlocked':
        'Buen trabajo. Esta insignia ya estÃƒÆ’Ã‚Â¡ asegurada; ahora ve por el siguiente nivel.',
    'badges.motivation_almost':
        'Casi listo. Solo faltan {remaining} dÃƒÆ’Ã‚Â­a(s) calificado(s) para desbloquear esta insignia.',
    'badges.motivation_keep':
        'SÃƒÆ’Ã‚Â© constante. Cada dÃƒÆ’Ã‚Â­a calificado impulsa esta insignia.',
    'tier.bronze': 'Bronce',
    'tier.silver': 'Plata',
    'tier.gold': 'Oro',
    'tier.platinum': 'Platino',
    'badge.first_workout.name': 'Primeros pasos',
    'badge.first_workout.narrative':
        'Completa tu primer dÃƒÆ’Ã‚Â­a de entrenamiento calificado.',
    'badge.first_workout.detail1':
        'Meta: 1 dÃƒÆ’Ã‚Â­a calificado de registros de entrenamiento guardados.',
    'badge.first_workout.detail2':
        'Objetivo Upper: 8 repeticiones en total (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise).',
    'badge.first_workout.detail3':
        'Objetivo Core: 10 repeticiones en total (Sit-up).',
    'badge.first_workout.detail4':
        'Objetivo Lower: 12 repeticiones en total (Squat / Leg Extension).',
    'badge.prep.name': 'PreparaciÃƒÆ’Ã‚Â³n de 15 dÃƒÆ’Ã‚Â­as',
    'badge.prep.narrative':
        'Construye constancia con un ritmo de preparaciÃƒÆ’Ã‚Â³n de 15 dÃƒÆ’Ã‚Â­as.',
    'badge.prep.detail1':
        'PreparaciÃƒÆ’Ã‚Â³n de 15 dÃƒÆ’Ã‚Â­as con ciclo de 5 dÃƒÆ’Ã‚Â­as activos + 2 dÃƒÆ’Ã‚Â­as de descanso (los dÃƒÆ’Ã‚Â­as 6-7 y 13-14 son descanso).',
    'badge.prep.detail2':
        'DÃƒÆ’Ã‚Â­as 1-3: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': 'DÃƒÆ’Ã‚Â­as 4-5: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': 'DÃƒÆ’Ã‚Â­as 8-12: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': 'DÃƒÆ’Ã‚Â­a 15: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = sesiones guardadas por categorÃƒÆ’Ã‚Â­a en un dÃƒÆ’Ã‚Â­a; los dÃƒÆ’Ã‚Â­as de descanso no suman progreso.',
    'badge.prep.detail8':
        'Si faltas a un dÃƒÆ’Ã‚Â­a activo obligatorio, el progreso del prep se reinicia y la racha vuelve a DÃƒÆ’Ã‚Â­a 1 en tu prÃƒÆ’Ã‚Â³ximo dÃƒÆ’Ã‚Â­a de entrenamiento.',
    'badge.bronze.name': 'Mes 1 Bronce',
    'badge.bronze.narrative':
        'Mes base para constancia en el programa completo.',
    'badge.bronze.detail1':
        '30 dÃƒÆ’Ã‚Â­as activos calificados con un ciclo de 5 activos + 2 descanso.',
    'badge.bronze.detail2':
        'Upper diario: 18 reps + 3 sets (combinadas en Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise).',
    'badge.bronze.detail3': 'Core diario: 24 reps + 3 sets (Sit-up).',
    'badge.bronze.detail4':
        'Lower diario: 30 reps + 3 sets (combinadas en Squat / Leg Extension).',
    'badge.bronze.detail5':
        'Reps/sets extra mÃƒÆ’Ã‚Â¡s allÃƒÆ’Ã‚Â¡ del lÃƒÆ’Ã‚Â­mite diario no suman progreso.',
    'badge.bronze.detail6':
        'Incluso si pierdes un dÃƒÆ’Ã‚Â­a, no tienes que volver a empezar desde el dÃƒÆ’Ã‚Â­a uno.',
    'badge.silver.name': 'Mes 2 Plata',
    'badge.silver.narrative':
        'Mes de progresiÃƒÆ’Ã‚Â³n con requisitos de mayor volumen.',
    'badge.silver.detail1':
        '30 dÃƒÆ’Ã‚Â­as activos calificados con un ciclo de 5 activos + 2 descanso.',
    'badge.silver.detail2':
        'Upper diario: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise combinadas).',
    'badge.silver.detail3': 'Core diario: 32 reps + 4 sets (Sit-up).',
    'badge.silver.detail4':
        'Lower diario: 40 reps + 4 sets (Squat / Leg Extension combinadas).',
    'badge.silver.detail5':
        'Solo los dÃƒÆ’Ã‚Â­as activos cuentan; los dÃƒÆ’Ã‚Â­as de descanso se ignoran.',
    'badge.silver.detail6':
        'Incluso si pierdes un dÃƒÆ’Ã‚Â­a, no tienes que volver a empezar desde el dÃƒÆ’Ã‚Â­a uno.',
    'badge.gold.name': 'Mes 3 Oro',
    'badge.gold.narrative':
        'Mes de maestrÃƒÆ’Ã‚Â­a con objetivos avanzados de resistencia.',
    'badge.gold.detail1':
        '30 dÃƒÆ’Ã‚Â­as activos calificados con un ciclo de 5 activos + 2 descanso.',
    'badge.gold.detail2':
        'Upper diario: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise combinadas).',
    'badge.gold.detail3': 'Core diario: 40 reps + 4 sets (Sit-up).',
    'badge.gold.detail4':
        'Lower diario: 50 reps + 4 sets (Squat / Leg Extension combinadas).',
    'badge.gold.detail5':
        'El progreso usa registros guardados; reps extra no suman crÃƒÆ’Ã‚Â©dito.',
    'badge.gold.detail6':
        'Incluso si pierdes un dÃƒÆ’Ã‚Â­a, no tienes que volver a empezar desde el dÃƒÆ’Ã‚Â­a uno.',
    'badge.default.goal': 'Meta: {description}',
    'badge.default.requirement':
        'Requisito: {requirement} dÃƒÆ’Ã‚Â­a(s) calificado(s).',
    'badge.default.status': 'Estado actual: {progress}/{requirement}.',
    'badge.poster.badge_label': 'Insignia',
    'badge.poster.user_label': 'Logrado por',
    'badge.poster.requirements_label': 'Datos calificados',
    'leaderboard.title': 'ClasificaciÃƒÆ’Ã‚Â³n',
    'leaderboard.achievements': 'Logros',
    'leaderboard.global': 'Global',
    'leaderboard.achievement_progress': 'Progreso de logros',
    'leaderboard.personal_bests': 'Mejores marcas',
    'leaderboard.most_reps': 'MÃƒÆ’Ã‚Â¡s repeticiones',
    'leaderboard.best_accuracy': 'Mejor precisiÃƒÆ’Ã‚Â³n',
    'leaderboard.longest_streak': 'Racha mÃƒÆ’Ã‚Â¡s larga',
    'leaderboard.days': 'DÃƒÆ’Ã‚Â­as',
    'leaderboard.global_simulated': 'ClasificaciÃƒÆ’Ã‚Â³n global (simulada)',
    'leaderboard.points': '{score} pts',
    'recordings.tab.recordings': 'Grabar',
    'recordings.tab.profile': 'Perfil',
    'recordings.failed_load': 'No se pudieron cargar las grabaciones',
    'recordings.empty': 'AÃƒÆ’Ã‚Âºn no hay videos grabados',
    'recordings.file_not_found': 'Archivo de video no encontrado',
    'recordings.file_incomplete':
        'El archivo de grabaciÃƒÆ’Ã‚Â³n estÃƒÆ’Ã‚Â¡ incompleto. Graba de nuevo.',
    'profile.guest_name': 'Usuario',
    'profile.user_name_label': 'Nombre de usuario',
    'profile.edit_name': 'Editar',
    'profile.name_hint': 'Escribe tu nombre',
    'profile.save_name': 'Guardar',
    'profile.photo_title': 'Foto de perfil',
    'profile.photo_subtitle':
        'Agrega una foto de cuerpo completo para personalizar tu perfil.',
    'profile.photo_add': 'Agregar foto',
    'profile.photo_change': 'Cambiar foto',
    'profile.photo_remove': 'Quitar foto',
    'profile.photo_remove_confirm': 'Ãƒâ€šÃ‚Â¿Eliminar tu foto de perfil?',
    'profile.photo_too_large':
        'La foto es demasiado grande. Elige una imagen mÃƒÆ’Ã‚Â¡s pequeÃƒÆ’Ã‚Â±a.',
    'profile.photo_error':
        'No se pudo guardar la foto. IntÃƒÆ’Ã‚Â©ntalo con otra imagen.',
    'profile.photo_badge_notice':
        'Si no agregas una foto de perfil, los pÃƒÆ’Ã‚Â³steres de insignias se crearÃƒÆ’Ã‚Â¡n sin tu foto.',
    'profile.exercise_totals_title': 'Totales de ejercicios',
    'profile.exercise_totals_subtitle': 'Desde tu primera hasta tu ÃƒÆ’Ã‚Âºltima sesiÃƒÆ’Ã‚Â³n.',
    'profile.exercise_empty': 'AÃƒÆ’Ã‚Âºn no hay datos de ejercicio',
    'profile.badges_title': 'Badges obtenidas',
    'profile.badges_empty': 'AÃƒÆ’Ã‚Âºn no hay badges',
    'profile.badge_gallery_saved_note':
        'Cuando desbloqueas una insignia, su pÃƒÆ’Ã‚Â³ster se guarda automÃƒÆ’Ã‚Â¡ticamente en la galerÃƒÆ’Ã‚Â­a: {album}.',
    'iconic.menu.title': 'Programas icÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³nicos',
    'iconic.menu.subtitle':
        'Elige un estilo premium de posprocesado para tus videos grabados. Cada programa estÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ diseÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â±ado para sentirse distinto, cinematogrÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡fico y elegante sin aÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â±adir calor durante la captura en vivo.',
    'iconic.program.zodiac.eyebrow': 'Firma posprocesada',
    'iconic.program.zodiac.description':
        'Aplica una superposiciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n zodiacal de lujo despuÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â©s de grabar. Los 12 signos usan paletas, sÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­mbolos, tintes de aura y grabados distintos, con la vista previa basada en la direcciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n artÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­stica de Aries.',
    'iconic.program.zodiac.tag.sign_themes': '12 temas zodiacales',
    'iconic.program.zodiac.tag.luxury_capsule': 'CÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡psula de lujo',
    'iconic.program.zodiac.tag.embossed_coin': 'Moneda en relieve',
    'iconic.program.zodiac.footer':
        'Recomendado para exportaciones icÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³nicas. La captura en vivo sigue siendo ligera para que el telÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â©fono no se caliente, y el acabado de lujo se aÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â±ade despuÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â©s de grabar.',
    'iconic.program.festival.eyebrow': 'CelebraciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n cultural',
    'iconic.program.festival.description':
        'Aplica una superposiciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n de lujo ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âºnica basada en el festival mundial o evento deportivo mÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡s cercano. Cada festival tiene su propia paleta, brillo de aro, degradado de precisiÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n y marca visual.',
    'iconic.program.festival.tag.festivals': '70 festivales',
    'iconic.program.festival.tag.date_aware': 'SegÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Âºn la fecha',
    'iconic.program.festival.tag.luxury_overlay': 'Overlay de lujo',
    'iconic.program.festival.footer':
        'El tema cambia automÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡ticamente a la celebraciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n prÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³xima mÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡s cercana. Graba tu entrenamiento y el estilo activo del festival se aplica durante el posprocesado.',
    'iconic.program.studio.eyebrow': 'Totalmente personalizable',
    'iconic.program.studio.description':
        'Usa tu propio sistema premium de overlay con contador editable, barra de precisiÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n, flujo narrativo, iconos, paletas de color y controles de acabado.',
    'iconic.program.studio.tag.custom_program': 'Programa personalizado',
    'iconic.program.studio.tag.luxury_editor': 'Editor de lujo',
    'iconic.program.studio.tag.premium_control': 'Control premium',
    'iconic.program.studio.footer':
        'Elige esto si quieres tu propio overlay de lujo hecho a mano en lugar de un estilo fijo de zodiaco o festival.',
    'iconic.program.studio.action': 'Abrir estudio',
    'iconic.program.standard.eyebrow': 'Predeterminado ligero',
    'iconic.program.standard.description':
        'Mantiene la superposiciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n simple actual cuando no quieres un look cinematogrÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡fico de marca.',
    'iconic.program.standard.tag.default': 'Predeterminado',
    'iconic.program.standard.tag.minimal': 'Minimalista',
    'iconic.program.standard.tag.fast_export': 'ExportaciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n rÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¡pida',
    'iconic.program.standard.footer':
        'Usa esto si quieres el estilo de exportaciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n actual sin una direcciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n artÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­stica premium.',
    'iconic.info.title': 'CÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³mo funciona',
    'iconic.info.step1': '1. Elige un programa aquÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â­.',
    'iconic.info.step2': '2. Graba tu entrenamiento como siempre.',
    'iconic.info.step3':
        '3. El estilo seleccionado se aplica solo despuÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â©s de grabar, durante el posprocesado.',
    'iconic.preview.post_process': 'VISTA PREVIA POSPROCESADA',
    'iconic.preview.standard.caption':
        'La superposiciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n de exportaciÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â³n predeterminada\nmantiene el aspecto ligero actual.',
    'iconic.preview.editable_luxe': 'LUJO EDITABLE',
    'camera.overlay.skeleton': 'Esqueleto',
    'camera.overlay.stop': 'Detener',
    'camera.overlay.record': 'Grabar',
    'camera.overlay.complete': 'Completar',
    'lang.en': 'InglÃƒÆ’Ã‚Â©s',
    'lang.es': 'EspaÃƒÆ’Ã‚Â±ol',
    'lang.ja': 'JaponÃƒÆ’Ã‚Â©s',
    'lang.my': 'Birmano',
    'lang.hi': 'Hindi',
    'lang.pt': 'PortuguÃƒÆ’Ã‚Â©s',
    'lang.zh': 'Chino mandarÃƒÆ’Ã‚Â­n',
    'lang.de': 'AlemÃƒÆ’Ã‚Â¡n',
  };

  static const Map<String, String> _jaValues = {
    'app.title': 'H&F',
    'nav.exercises': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Âº',
    'nav.progress': 'ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€',
    'nav.recordings': 'ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«',
    'common.cancel': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã‚Â«',
    'common.retry': 'ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂÃƒÂ¨Ã‚Â©Ã‚Â¦ÃƒÂ¨Ã‚Â¡Ã…â€™',
    'common.load_exercises': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚ÂªÃ‚Â­ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ¨Ã‚Â¾Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã¢â€šÂ¬',
    'common.clear_data': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤',
    'common.ok': 'OK',
    'common.close': 'ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ‹Å“ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹',
    'common.error_with_message': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼: {message}',
    'premium.badge': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ',
    'premium.menu_only': 'ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚Â¡ÃƒÂ£Ã†â€™Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã‚Â¥ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã†â€™Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¶ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'home.exercises_list': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¨Ã‚Â¦Ã‚Â§',
    'home.exercises_simple_form': 'ÃƒÂ§Ã‚Â°Ã‚Â¡ÃƒÂ¦Ã‹Å“Ã¢â‚¬Å“ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ',
    'home.no_supported_exercises': 'ÃƒÂ¥Ã‚Â¯Ã‚Â¾ÃƒÂ¥Ã‚Â¿Ã…â€œÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“',
    'home.check_exercise_config': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ¨Ã‚Â¨Ã‚Â­ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â¢Ã‚ÂºÃƒÂ¨Ã‚ÂªÃ‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾',
    'home.error_loading_exercise': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚ÂªÃ‚Â­ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ¨Ã‚Â¾Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¦Ã¢â‚¬Â¢Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸: {error}',
    'home.image_reference_count': 'ÃƒÂ¥Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ¨Ã¢â€šÂ¬Ã†â€™ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ¥Ã†â€™Ã‚Â {count} ÃƒÂ¦Ã…Â¾Ã…Â¡',
    'home.today_progress_premium': 'ÃƒÂ¤Ã‚Â»Ã…Â ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'home.today_progress_locked_desc': 'ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¡ÃƒÂ£Ã†â€™Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã‚Â¥ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚Â©Ã‚Â³ÃƒÂ§Ã‚Â´Ã‚Â°ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'home.today_progress': 'ÃƒÂ¤Ã‚Â»Ã…Â ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€',
    'home.total_reps': 'ÃƒÂ§Ã‚Â·Ã‚ÂÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°',
    'home.workouts': 'ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ',
    'home.calories': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼',
    'home.daily_goal': '1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã¢â€žÂ¢: {current}/{goal}',
    'home.daily_goal_achieved': '1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ©Ã‚ÂÃ¢â‚¬ÂÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¯Ã‚Â¼Ã‚Â',
    'home.progress_premium_title': 'ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½',
    'home.progress_premium_message': 'ÃƒÂ¨Ã‚Â©Ã‚Â³ÃƒÂ§Ã‚Â´Ã‚Â°ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'home.recordings_premium_title': 'ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½',
    'home.recordings_premium_message': 'ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ¥Ã‚Â±Ã‚Â¥ÃƒÂ¦Ã‚Â­Ã‚Â´ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'home.simple_form': '{name} ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ',
    'home.quick_form_summary': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â°Ã‚Â¡ÃƒÂ¦Ã‹Å“Ã¢â‚¬Å“ÃƒÂ¦Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¨Ã‚Â¦Ã‚Â',
    'home.form_images': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ¥Ã†â€™Ã‚Â',
    'home.exercise_list_notice_title': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â€šÂ¬ÃƒÂ£Ã†â€™Ã‚Â¼',
    'home.exercise_list_notice_message':
        'ÃƒÂ¥Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã‚Â³Ã‚Â¨ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â¹ÃƒÂ©Ã‚Â Ã¢â‚¬Â¦ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ¥Ã‚Â Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ§Ã‚Â¢Ã‚ÂºÃƒÂ¨Ã‚ÂªÃ‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â³Ã‚Â¨ÃƒÂ¨Ã‚Â¨Ã‹Å“: situp ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ¦Ã‚Â³Ã‚Â¨ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â¹ÃƒÂ©Ã‚Â Ã¢â‚¬Â¦ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'home.simple_form_notice':
        'ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã‚Â³Ã‚Â¨ÃƒÂ¦Ã¢â‚¬Å¾Ã‚Â:\nÃƒÂ¦Ã…â€œÃ‚Â¬AIÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ËœÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚ÂªÃ‚ÂÃƒÂ¨Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ¨Ã‚Â¨Ã‚Â­ÃƒÂ¨Ã‚Â¨Ã‹â€ ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ¥Ã‚Â¼Ã‚ÂÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ¦Ã…Â Ã¢â€šÂ¬ÃƒÂ¨Ã‚Â¡Ã¢â‚¬Å“ÃƒÂ¦Ã…â€™Ã¢â‚¬Â¡ÃƒÂ¥Ã‚Â°Ã…Â½ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã‚ÂÃ…â€™100%ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ§Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â ÃƒÂ¦Ã¢â‚¬Â°Ã‚Â¿ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\nÃƒÂ¦Ã‚Â¨Ã‚ÂªÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â¨Ã‚Â®ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã‚Â¨Ã‚ÂªÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â¨Ã‚Â®ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ§Ã‚ÂµÃ‚ÂÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ§Ã‚Â¢Ã‚ÂºÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\nÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚Â Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â¨Ã‹â€ ÃƒÂ¦Ã‚Â¸Ã‚Â¬ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ§Ã‚Â¢Ã‚ÂºÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢:\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â¡ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ¦Ã…Â¾Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â¡ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¨Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¦Ã‹Å“Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¥Ã‚Â±Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¦Ã…Â¡Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ…Â½ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚Â¼Ã‚Â·ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢/ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã‚Â°Ã¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â¡ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚Â¯Ã‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¤Ã‚Â½Ã…Â½ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ…Â½ÃƒÂ£Ã‚ÂÃ…Â¡ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ…Â½ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ¤Ã‚Â½Ã‚ÂÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.guide.title': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã¢â‚¬Â°',
    'exercise.guide.step1': 'ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ¥Ã‚Â Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â±ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã…â€œÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã…Â Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.guide.step2': 'ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ¥Ã‚Â Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã†â€™Ã…â€œÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã…Â Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.guide.step3': 'ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‚ÂÃ…â€œÃƒÂ¦Ã‚Â­Ã‚Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã†â€™Ã¢â€šÂ¬ÃƒÂ£Ã†â€™Ã¢â‚¬â€œÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¦Ã‹â€ Ã‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã…â€œÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã…Â Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.guide.step4': 'ÃƒÂ©Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ§Ã‚ÂµÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â ÃƒÂ£Ã†â€™Ã…â€œÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã…Â Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã†â€™Ã…â€œÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã…Â Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.error.setup_title': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼',
    'exercise.error.setup_message': 'ÃƒÂ¥Ã‹â€ Ã‚ÂÃƒÂ¦Ã…â€œÃ…Â¸ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¦Ã¢â‚¬Â¢Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸: {error}',
    'exercise.error.pose_title': 'ÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¥Ã¢â‚¬Â¹Ã‚Â¢ÃƒÂ¦Ã‚Â¤Ã…â€œÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼',
    'exercise.error.pose_message':
        'ÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¥Ã¢â‚¬Â¹Ã‚Â¢ÃƒÂ¦Ã‚Â¤Ã…â€œÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‹â€ Ã‚ÂÃƒÂ¦Ã…â€œÃ…Â¸ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡Google Play Services ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ§Ã‚Â¢Ã‚ÂºÃƒÂ¨Ã‚ÂªÃ‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.premium.landmarks': 'ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.premium.recording': 'ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ§Ã¢â‚¬Â°Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.recording.failed_start': 'ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¦Ã¢â‚¬Â¢Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸: {error}',
    'exercise.recording.permission_denied': 'ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã‚ÂÃ‚Â¢/ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã‚Â©ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬Â¹Ã¢â‚¬â„¢ÃƒÂ¥Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸',
    'exercise.recording.failed_save': 'ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¦Ã¢â‚¬Â¢Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸',
    'exercise.recording.saved_gallery': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â®ÃƒÂ£Ã†â€™Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ¯Ã‚Â¼Ã‹â€ {album}ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'exercise.recording.saved_app': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ¥Ã¢â‚¬Â Ã¢â‚¬Â¦ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸: {path}',
    'exercise.recording.saved_phone': 'ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â«Ã‚Â¯ÃƒÂ¦Ã…â€œÃ‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸',
    'exercise.recording.failed_video': 'ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¦Ã¢â‚¬Â¢Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸: {error}',
    'exercise.recording.preparing_luxury_video':
        'ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚Â´Ã…Â¡ÃƒÂ¦Ã¢â‚¬Å¾Ã…Â¸ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã‚ÂºÃ¢â‚¬â€œÃƒÂ¥Ã¢â‚¬Å¡Ã¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.recording.keep_screen_open':
        'ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â°ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.premium.title': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½',
    'exercise.premium.not_now': 'ÃƒÂ¤Ã‚Â»Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾',
    'exercise.premium.upgrade': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â°',
    'exercise.premium.required_title': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢',
    'exercise.premium.required_message': 'ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ¨Ã‚Â¿Ã‚Â½ÃƒÂ¨Ã‚Â·Ã‚Â¡ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.camera.error_title': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â¡ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼',
    'exercise.camera.error_message': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â¡ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‹â€ Ã‚ÂÃƒÂ¦Ã…â€œÃ…Â¸ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â¨Ã‚Â©ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â¢Ã‚ÂºÃƒÂ¨Ã‚ÂªÃ‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂÃƒÂ¨Ã‚Â©Ã‚Â¦ÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.counting_premium': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'exercise.summary.title': 'ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â ÃƒÂ¯Ã‚Â¼Ã‚Â',
    'exercise.summary.total_reps': 'ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â¨Ã‹â€ ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°',
    'exercise.summary.avg_accuracy': 'ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'exercise.summary.duration': 'ÃƒÂ¦Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Å“',
    'exercise.summary.seconds': '{value} ÃƒÂ§Ã‚Â§Ã¢â‚¬â„¢',
    'exercise.summary.best_accuracy': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¯Ã‚Â¼Ã‹â€ 1ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'exercise.summary.close': 'ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ‹Å“ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹',
    'exercise.summary.view_details': 'ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“',
    'exercise.card.type.dynamic': 'ÃƒÂ£Ã†â€™Ã¢â€šÂ¬ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã…Â ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯',
    'exercise.card.type.static': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯',
    'exercise.card.view.front': 'ÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ©Ã‚ÂÃ‚Â¢',
    'exercise.card.view.side': 'ÃƒÂ¦Ã‚Â¨Ã‚Âª',
    'exercise.card.total_reps': 'ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â¨Ã‹â€ ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°',
    'exercise.card.avg_accuracy': 'ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'exercise.card.select': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ©Ã‚ÂÃ‚Â¸ÃƒÂ¦Ã…Â Ã…Â¾',
    'exercise.time.today': 'ÃƒÂ¤Ã‚Â»Ã…Â ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥',
    'exercise.time.yesterday': 'ÃƒÂ¦Ã‹Å“Ã‚Â¨ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥',
    'exercise.time.days_ago': '{value}ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'exercise.time.weeks_ago': '{value}ÃƒÂ©Ã¢â€šÂ¬Ã‚Â±ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'exercise.time.months_ago': '{value}ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'guide.squat.subtitle': 'ÃƒÂ¨Ã†â€™Ã‚Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚ÂµÃ‚Â·ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â¡ÃƒÂ©Ã¢â‚¬â€œÃ‚Â¢ÃƒÂ§Ã‚Â¯Ã¢â€šÂ¬ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‚Â¾Ã…â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚Â¼Ã¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ‚Â¤ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ¥Ã¢â‚¬Â¦Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â¹ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.squat.step1': 'ÃƒÂ¨Ã‚Â¶Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ¥Ã‚Â¹Ã¢â‚¬Â¦ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã‚Â¹Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â·Ã‚Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.squat.step2': 'ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã‚ÂµÃ‚Â®ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã‚ÂÃ…Â¡ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚Â¤Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â¼ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.squat.step3': 'ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¦Ã…Â Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ§Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â¡ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.pushup.subtitle': 'ÃƒÂ©Ã‚Â Ã‚Â­ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ§Ã‚Â·Ã…Â¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã‚Â1ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ£Ã‚ÂÃ…Â¡ÃƒÂ£Ã‚ÂÃ‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â³ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.pushup.step1': 'ÃƒÂ¤Ã‚Â¸Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ¥Ã‚Â¹Ã¢â‚¬Â¦ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ¥Ã‚Â°Ã¢â‚¬ËœÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ¥Ã‚ÂºÃ†â€™ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Â¹ÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.pushup.step2': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã‹Å“ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â´Ã¢â‚¬Å¾45ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â²ÃƒÂ£Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¨Ã†â€™Ã‚Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.pushup.step3': 'ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã‚Â¹Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â·Ã‚Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã¢â‚¬Â¦Ã‚Â°ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã‚Â°Ã‚Â´ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ¦Ã…Â Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.situp.subtitle': 'ÃƒÂ©Ã‚Â¦Ã¢â‚¬â€œÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¥Ã‚Â¼Ã¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ…Â¡ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã‚Â¹Ã‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â³ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.situp.step1': 'ÃƒÂ¤Ã‚Â»Ã‚Â°ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â²ÃƒÂ£Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â¶Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‚ÂºÃ…Â ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.situp.step2': 'ÃƒÂ¨Ã¢â‚¬Â¦Ã‚Â¹ÃƒÂ§Ã‚Â­Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â·Ã‚Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚ÂµÃ‚Â·ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.situp.step3': 'ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â ÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ¦Ã‹â€ Ã‚Â»ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã¢â‚¬Å¡Ã¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.bicep.subtitle': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã‹Å“ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã‚ÂÃ‚Â´ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã¢â‚¬ÂºÃ‚ÂºÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.bicep.step1': 'ÃƒÂ£Ã†â€™Ã¢â€šÂ¬ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â€žÂ¢ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â²ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ§Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.bicep.step2': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ…Â¡ÃƒÂ¨Ã¢â‚¬Å¡Ã‹Å“ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â²ÃƒÂ£Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¡ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.bicep.step3': 'ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â ÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¤Ã‚Â¼Ã‚Â¸ÃƒÂ£Ã‚ÂÃ‚Â°ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.shoulder.subtitle': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ©Ã‚ÂªÃ‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã‚Â¹Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â·Ã‚Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¦Ã…Â Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.shoulder.step1': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¦Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Â¹ÃƒÂ©Ã‚Â¦Ã¢â‚¬â€œÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã‚Â¥ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.shoulder.step2': 'ÃƒÂ©Ã‚Â Ã‚Â­ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¦Ã…Â Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.shoulder.step3': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â³ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.leg.subtitle': 'ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ¥Ã…Â¸Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â³ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â¹Ã‚Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¤Ã‚Â¼Ã‚Â¸ÃƒÂ£Ã‚ÂÃ‚Â°ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.leg.step1': 'ÃƒÂ¨Ã†â€™Ã…â€™ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã¢â‚¬Å¾Ã…Â¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã†â€™Ã¢â‚¬ËœÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¥Ã‚ÂºÃ‚Â§ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.leg.step2': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â¡ÃƒÂ©Ã¢â‚¬â€œÃ‚Â¢ÃƒÂ§Ã‚Â¯Ã¢â€šÂ¬ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¼Ã‚Â¸ÃƒÂ£Ã‚ÂÃ‚Â°ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã†â€™Ã¢â‚¬ËœÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.leg.step3': 'ÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â²ÃƒÂ£Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â ÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'settings.title': 'ÃƒÂ¨Ã‚Â¨Ã‚Â­ÃƒÂ¥Ã‚Â®Ã…Â¡',
    'settings.premium_features': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½',
    'settings.app_settings': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ¨Ã‚Â¨Ã‚Â­ÃƒÂ¥Ã‚Â®Ã…Â¡',
    'settings.profile_name': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ¥Ã‚ÂÃ‚Â',
    'settings.appearance': 'ÃƒÂ¥Ã‚Â¤Ã¢â‚¬â€œÃƒÂ¨Ã‚Â¦Ã‚Â³',
    'settings.data': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿',
    'settings.about': 'ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¦',
    'settings.premium_account': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ',
    'settings.unlock_all_features': 'ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤',
    'settings.voice_counting': 'ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ',
    'settings.speak_count': 'ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¨Ã‚ÂªÃ‚Â­ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹',
    'settings.voice_counting_language': 'ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬ÃƒÂ¨Ã‚ÂªÃ…Â¾',
    'settings.upgrade_to_premium': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â°',
    'settings.upgrade_subtitle': 'ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ‚Â©ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½',
    'settings.voice_coach': 'ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â³ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â',
    'settings.voice_feedback': 'ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯',
    'settings.show_landmarks': 'ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã‚Â¤Ã‚Âº',
    'settings.display_skeleton': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â±ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã‚Â¤Ã‚Âº',
    'settings.auto_recording': 'ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»',
    'settings.auto_recording_subtitle': 'ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»',
    'settings.theme': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã…Â¾',
    'settings.language': 'ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬ÃƒÂ¨Ã‚ÂªÃ…Â¾',
    'settings.language_subtitle': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬ÃƒÂ¨Ã‚ÂªÃ…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´',
    'settings.clear_data': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤',
    'settings.clear_data_subtitle': 'ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¥Ã‚Â±Ã‚Â¥ÃƒÂ¦Ã‚Â­Ã‚Â´ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤',
    'settings.version': 'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³',
    'settings.privacy_policy': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â¼',
    'settings.terms': 'ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ§Ã‚Â´Ã¢â‚¬Å¾',
    'settings.disclaimer': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚ÂÃƒÂ¨Ã‚Â²Ã‚Â¬ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â¹ÃƒÂ©Ã‚Â Ã¢â‚¬Â¦',
    'legal.last_updated': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ§Ã‚ÂµÃ¢â‚¬Å¡ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥: {date}',
    'legal.privacy.content':
        '1) ÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ©Ã¢â‚¬ÂºÃ¢â‚¬Â ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿\n'
        'H&FÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ¨Ã‚Â¨Ã‚Â­ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ…Â ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â³ÃƒÂ¤Ã‚Â»Ã‚Â»ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã¢â‚¬ËœÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â«Ã‚Â¯ÃƒÂ¦Ã…â€œÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '2) ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã…Â Ã‚Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œ\n'
        'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã…Â Ã‚Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚Â°Ã¢â‚¬ËœÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¦Ã…Â½Ã‚Â¥ÃƒÂ§Ã‚Â¶Ã…Â¡ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã…Â Ã‚Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ¦Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ§Ã‚Â«Ã‚Â¯ÃƒÂ¦Ã…â€œÃ‚Â«ÃƒÂ¨Ã‚Â­Ã‹Å“ÃƒÂ¥Ã‹â€ Ã‚Â¥ÃƒÂ¥Ã‚Â­Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â¸ÃƒÂ©Ã¢â€šÂ¬Ã‚ÂÃƒÂ¤Ã‚Â¿Ã‚Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã…Â Ã‚Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ¥Ã‚Â¾Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¦Ã‚Â¨Ã‚Â©ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ§Ã‚Â«Ã‚Â¯ÃƒÂ¦Ã…â€œÃ‚Â«ÃƒÂ¥Ã¢â‚¬Â Ã¢â‚¬Â¦ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¦Ã‚Â¤Ã…â€œÃƒÂ¨Ã‚Â¨Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂªÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '3) ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â¡ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â»ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã†â€™Ã‚Â»ÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â¦ÃƒÂ§Ã‚ÂÃ¢â‚¬Â ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¥Ã…Â Ã¢â‚¬Âº\n'
        'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â¡ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ¦Ã‚Â¤Ã…â€œÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ¦Ã…Â¾Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ§Ã‚Â«Ã‚Â¯ÃƒÂ¦Ã…â€œÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â¦ÃƒÂ§Ã‚ÂÃ¢â‚¬Â ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¥Ã…Â Ã¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã‚Â©ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ¥Ã‚Â Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ§Ã‚Â«Ã‚Â¯ÃƒÂ¦Ã…â€œÃ‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â®ÃƒÂ£Ã†â€™Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¦Ã‚Â®Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '4) ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾\n'
        'ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¨Ã‚Â¨Ã‹â€ ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚Â¿Ã‚Â½ÃƒÂ¨Ã‚Â·Ã‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ…Â ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â³ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '5) ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â±ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°\n'
        'ÃƒÂ¥Ã¢â€šÂ¬Ã¢â‚¬Â¹ÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â²Ã‚Â©ÃƒÂ¥Ã‚Â£Ã‚Â²ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ¨Ã‚ÂªÃ‚ÂÃƒÂ¨Ã‚Â¨Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã…Â Ã‚Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â­Ã‚Â·ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â¦ÃƒÂ§Ã‚ÂÃ¢â‚¬Â ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '6) ÃƒÂ£Ã†â€™Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¶ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â®Ã‚Â¡ÃƒÂ§Ã‚ÂÃ¢â‚¬Â \n'
        'ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¤ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ¥Ã‚Â±Ã‚Â¥ÃƒÂ¦Ã‚Â­Ã‚Â´ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ§Ã…Â Ã‚Â¶ÃƒÂ¦Ã¢â‚¬Â¦Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã‚Â¶Ã‹â€ ÃƒÂ¥Ã…Â½Ã‚Â»ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '7) ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¥ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£\n'
        'ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬â€œÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã‚Â¸Ã¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â§ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'legal.terms.content':
        'H&FÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ§Ã‚Â´Ã¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '1) ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Å“ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨\n'
        'H&FÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¯ÃƒÂ¦Ã‚ÂÃ‚Â´ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ¥Ã‚ÂÃ‚Â¥ÃƒÂ¥Ã‚ÂºÃ‚Â·ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‹â€ Ã‚Â¤ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â­ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¨Ã‚Â²Ã‚Â¬ÃƒÂ¤Ã‚Â»Ã‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '2) ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹\n'
        'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã…Â Ã‚Â¹ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ§Ã‚Â«Ã‚Â¯ÃƒÂ¦Ã…â€œÃ‚Â«ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¤Ã‚Â¹Ã‚Â±ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚ÂÃ¢â‚¬â€œÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ¦Ã‚Â¶Ã‹â€ ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¥ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ¤Ã‚Â¾Ã‚ÂµÃƒÂ¥Ã‚Â®Ã‚Â³ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã†â€™Ã¢â‚¬â€œÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '3) ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂªÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â°\n'
        'ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã…Â Ã‚Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ‹Å“ÃƒÂ§Ã‚Â«Ã‚Â¯ÃƒÂ¦Ã…â€œÃ‚Â«ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¥Ã…Â¸Ã‚ÂºÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂªÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã‚Â©Ã…Â¸ÃƒÂ¥Ã‚Â¯Ã¢â‚¬Â ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã‚Â¶Ã‹â€ ÃƒÂ¥Ã…Â½Ã‚Â»ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â§ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¦Ã¢â‚¬Â¢Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ‚Â©ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã…Â Ã‚Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ¥Ã‚Â Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '4) ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â¹ÃƒÂ©Ã‚Â Ã¢â‚¬Â¦\n'
        'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¥ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬â€œÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã†â€™Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ¦Ã‚Â³Ã¢â‚¬Â¢ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ‚Â¸ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ§Ã‚Â¦Ã‚ÂÃƒÂ¦Ã‚Â­Ã‚Â¢ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '5) ÃƒÂ§Ã…Â¸Ã‚Â¥ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â²Ã‚Â¡ÃƒÂ§Ã¢â‚¬ÂÃ‚Â£\n'
        'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â½ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â§ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã†â€™Ã¢â‚¬â€œÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â³ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¯H&FÃƒÂ£Ã‚ÂÃ…Â ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â³ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚Â²Ã‚Â¡ÃƒÂ§Ã¢â‚¬ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '6) ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â¨Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚ÂÃ‚Â¦ÃƒÂ¨Ã‚ÂªÃ‚Â\n'
        'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â€šÂ¬Ã…â€™ÃƒÂ§Ã‚ÂÃ‚Â¾ÃƒÂ§Ã…Â Ã‚Â¶ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ…Â ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ§Ã‚Â¶Ã¢â€žÂ¢ÃƒÂ§Ã‚Â¶Ã…Â¡ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ§Ã‚Â¨Ã‚Â¼ÃƒÂ¥Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ§Ã¢â‚¬Â°Ã‚Â¹ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â¨Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€œÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ§Ã‚ÂÃ¢â‚¬Â ÃƒÂ§Ã¢â‚¬ÂÃ‚Â±ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ¥Ã‚Â¤Ã…Â¡ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã‚ÂÃ‹â€ ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ¥Ã‚Â°Ã¢â‚¬ËœÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã‚ÂÃ‹â€ ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ¥Ã‚Â Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '7) ÃƒÂ¨Ã‚Â²Ã‚Â¬ÃƒÂ¤Ã‚Â»Ã‚Â»ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ©Ã¢â€žÂ¢Ã‚Â\n'
        'H&FÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Å“ÃƒÂ¦Ã…Â½Ã‚Â¥ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚ÂÃ‚Â¶ÃƒÂ§Ã¢â€žÂ¢Ã‚ÂºÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ§Ã‚ÂµÃ‚ÂÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¥Ã‚Â®Ã‚Â³ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¨Ã‚Â²Ã‚Â¬ÃƒÂ¤Ã‚Â»Ã‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â²Ã‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'legal.disclaimer.content':
        'H&FÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã…â€™Ã‚Â»ÃƒÂ§Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Å“ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã…â€™Ã‚Â»ÃƒÂ§Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ¥Ã…Â Ã‚Â©ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â¨Ã‚ÂºÃƒÂ¦Ã¢â‚¬â€œÃ‚Â­ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã‚Â²Ã‚Â»ÃƒÂ§Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '1) ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯\n'
        'ÃƒÂ©Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã¢â€šÂ¬Ã‚ÂªÃƒÂ¦Ã‹â€ Ã¢â‚¬ËœÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ§Ã¢â‚¬â€Ã¢â‚¬ÂºÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã¢â‚¬ËœÃ‚Â¼ÃƒÂ¥Ã‚ÂÃ‚Â¸ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â°ÃƒÂ©Ã¢â‚¬ÂºÃ‚Â£ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¥Ã‚Â¿Ã‚Â«ÃƒÂ¦Ã¢â‚¬Å¾Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã¢â‚¬Å¾Ã…Â¸ÃƒÂ£Ã‚ÂÃ‹Å“ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ£Ã‚ÂÃ‚Â¡ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¦Ã‚Â­Ã‚Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â³Ã¢â‚¬Â¡ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ¥Ã‚Â°Ã¢â‚¬Å¡ÃƒÂ©Ã¢â‚¬â€œÃ¢â€šÂ¬ÃƒÂ¥Ã‚Â®Ã‚Â¶ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¨Ã‚Â«Ã¢â‚¬Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '2) AIÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯\n'
        'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ¦Ã‚Â¤Ã…â€œÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã…Â½Ã‚Â¨ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ¥Ã¢â€šÂ¬Ã‚Â¤ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â¡ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚Â§Ã¢â‚¬â„¢ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ¦Ã‹Å“Ã…Â½ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã‚ÂÃ‚Â®ÃƒÂ¨Ã¢â‚¬ÂÃ‚Â½ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â¡Ã‚Â£ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ©Ã¢â€šÂ¬Ã…Â¸ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¨Ã‚ÂªÃ‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '3) ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ¦Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ¨Ã†â€™Ã‚Â½\n'
        'ÃƒÂ©Ã¢â€šÂ¬Ã…Â¡ÃƒÂ¥Ã‚Â¸Ã‚Â¸ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã†â€™Ã¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚ÂµÃ‚Â·ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ /ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ¨Ã‚Â¨Ã‚Â­ÃƒÂ¨Ã‚Â¨Ã‹â€ ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ¦Ã‚Â¤Ã…â€œÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '4) ÃƒÂ§Ã‚Â·Ã…Â ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â¥ÃƒÂ¦Ã¢â€žÂ¢Ã¢â‚¬Å¡\n'
        'ÃƒÂ§Ã‚Â·Ã…Â ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â¥ÃƒÂ¦Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ©Ã‚Â Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚Â¿Ã…â€œÃƒÂ£Ã‚ÂÃ‹Å“ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ©Ã¢â€šÂ¬Ã…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ¥Ã…Â¸Ã…Â¸ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â·Ã…Â ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â¥ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Å“ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â¸ÃƒÂ©Ã¢â€šÂ¬Ã‚Â£ÃƒÂ§Ã‚ÂµÃ‚Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '5) ÃƒÂ£Ã†â€™Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¶ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚Â²Ã‚Â¬ÃƒÂ¤Ã‚Â»Ã‚Â»\n'
        'ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ§Ã‚Â©Ã‚ÂºÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã‚ÂÃ‚Â©ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â¡ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ¥Ã…â€™Ã‚Â»ÃƒÂ§Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã¢â‚¬Â°Ã‚Â¿ÃƒÂ¨Ã‚ÂªÃ‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¶ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚Â²Ã‚Â¬ÃƒÂ¤Ã‚Â»Ã‚Â»ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '6) ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ¤Ã‚Â»Ã¢â‚¬â€œÃƒÂ¨Ã¢â€šÂ¬Ã¢â‚¬Â¦ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â¼\n'
        'ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ¥Ã‚Â Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã‹Å“Ã‚Â ÃƒÂ¥Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Â¦ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '7) ÃƒÂ§Ã‚ÂµÃ‚ÂÃƒÂ¦Ã…Â¾Ã…â€œ\n'
        'ÃƒÂ©Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã‚ÂµÃ‚ÂÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ§Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡H&FÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ§Ã¢â‚¬Â°Ã‚Â¹ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ¥Ã‚ÂÃ‚Â¥ÃƒÂ¥Ã‚ÂºÃ‚Â·ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚ÂµÃ‚ÂÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â¨Ã‚Â¼ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'settings.select_theme': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ©Ã‚ÂÃ‚Â¸ÃƒÂ¦Ã…Â Ã…Â¾',
    'settings.select_language': 'ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬ÃƒÂ¨Ã‚ÂªÃ…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ©Ã‚ÂÃ‚Â¸ÃƒÂ¦Ã…Â Ã…Â¾',
    'onboarding.language_title': 'ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬ÃƒÂ¨Ã‚ÂªÃ…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ©Ã‚ÂÃ‚Â¸ÃƒÂ¦Ã…Â Ã…Â¾',
    'onboarding.language_subtitle': 'ÃƒÂ¥Ã‚Â¾Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¨Ã‚Â¨Ã‚Â­ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'onboarding.name_title': 'ÃƒÂ£Ã‚ÂÃ…Â ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¯Ã‚Â¼Ã…Â¸',
    'onboarding.name_subtitle': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'onboarding.name_hint': 'ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ¥Ã…Â Ã¢â‚¬Âº',
    'onboarding.name_required': 'ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ¥Ã…Â Ã¢â‚¬ÂºÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾',
    'onboarding.disclaimer_title': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚ÂÃƒÂ¨Ã‚Â²Ã‚Â¬ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â¹ÃƒÂ©Ã‚Â Ã¢â‚¬Â¦',
    'onboarding.terms_title': 'ÃƒÂ¥Ã‹â€ Ã‚Â©ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ§Ã‚Â´Ã¢â‚¬Å¾',
    'onboarding.accept_notice': 'ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â¶Ã…Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'onboarding.accept_checkbox': 'ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢',
    'onboarding.continue': 'ÃƒÂ§Ã‚Â¶Ã…Â¡ÃƒÂ¨Ã‚Â¡Ã…â€™',
    'onboarding.start_app': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Â¹ÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹',
    'settings.clear_all_data': 'ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤',
    'settings.clear_all_data_desc': 'ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¥Ã‚Â±Ã‚Â¥ÃƒÂ¦Ã‚Â­Ã‚Â´ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚Â®Ã…Â¸ÃƒÂ§Ã‚Â¸Ã‚Â¾ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â¨Ã‚Â­ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã¢â‚¬Å“Ã‚ÂÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã¢â‚¬Â¦Ã†â€™ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¦Ã‹â€ Ã‚Â»ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'settings.clear_success': 'ÃƒÂ£Ã†â€™Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¶ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'settings.clear_failed': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¦Ã¢â‚¬Â¢Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸: {error}',
    'theme.light': 'ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‹â€ ',
    'theme.dark': 'ÃƒÂ£Ã†â€™Ã¢â€šÂ¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯',
    'theme.gold': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â´ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã¢â‚¬Â°',
    'theme.pink': 'ÃƒÂ£Ã†â€™Ã¢â‚¬ÂÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯',
    'progress.title': 'ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚Â',
    'progress.overview': 'ÃƒÂ¦Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¨Ã‚Â¦Ã‚Â',
    'progress.exercises': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Âº',
    'progress.badges': 'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸',
    'progress.no_data': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“',
    'progress.weekly_summary': 'ÃƒÂ©Ã¢â€šÂ¬Ã‚Â±ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Å“ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼',
    'progress.streak_days': '{count}ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ©Ã¢â€šÂ¬Ã‚Â£ÃƒÂ§Ã‚Â¶Ã…Â¡',
    'progress.recent_workouts': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ËœÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ',
    'progress.no_workouts': 'ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“',
    'progress.workout_summary': '{reps}ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦{accuracy}%',
    'progress.achievements': 'ÃƒÂ¥Ã‚Â®Ã…Â¸ÃƒÂ§Ã‚Â¸Ã‚Â¾',
    'progress.badges_unlocked': '{unlocked}/{total}ÃƒÂ¥Ã¢â€šÂ¬Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤',
    'progress.view_all_achievements': 'ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚Â®Ã…Â¸ÃƒÂ§Ã‚Â¸Ã‚Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â¦Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹',
    'progress.day.sun': 'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥',
    'progress.day.mon': 'ÃƒÂ¦Ã…â€œÃ‹â€ ',
    'progress.day.tue': 'ÃƒÂ§Ã‚ÂÃ‚Â«',
    'progress.day.wed': 'ÃƒÂ¦Ã‚Â°Ã‚Â´',
    'progress.day.thu': 'ÃƒÂ¦Ã…â€œÃ‚Â¨',
    'progress.day.fri': 'ÃƒÂ©Ã¢â‚¬Â¡Ã¢â‚¬Ëœ',
    'progress.day.sat': 'ÃƒÂ¥Ã…â€œÃ…Â¸',
    'progress.time.just_now': 'ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã‚ÂÃ‚Â£ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ¤Ã‚Â»Ã…Â ',
    'progress.time.minutes_ago': '{value}ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'progress.time.hours_ago': '{value}ÃƒÂ¦Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'progress.time.days_ago': '{value}ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'progress.time.weeks_ago': '{value}ÃƒÂ©Ã¢â€šÂ¬Ã‚Â±ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'progress.analytics_intro_title': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚Â¦Ã¢â‚¬Â¹ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â¹',
    'progress.analytics_intro_line1': 'ÃƒÂ§Ã‚Â·Ã‚ÂÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â° = ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ‚Â¹ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â¨Ã‚Â®ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â¨Ã‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.analytics_intro_line2': 'ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ = ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.analytics_intro_line3': 'ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‹â€  = ÃƒÂ¦Ã¢â€žÂ¢Ã¢â‚¬Å¡ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Å“ÃƒÂ§Ã‚ÂµÃ…â€™ÃƒÂ©Ã‚ÂÃ…Â½ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â©ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¨Ã¢â‚¬Â°Ã‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.analytics_intro_line4': 'ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ¥Ã‚Â¾Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.read_exercise_analytics_title': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¨Ã‚Â¦Ã¢â‚¬Â¹ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â¹',
    'progress.read_exercise_analytics_line1': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ = ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ËœÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.read_exercise_analytics_line2': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ = ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.read_exercise_analytics_line3':
        'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¨Ã‚Â¿Ã¢â‚¬Ëœ6ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â©ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.read_exercise_analytics_line4': 'ÃƒÂ¥Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¥Ã‚Â­Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.latest_accuracy': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'progress.best_accuracy': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'progress.trend_vs_previous_session': '{sign}{delta}%ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ¦Ã‚Â¯Ã¢â‚¬ÂÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'progress.last_sessions_accuracy_title': 'ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ËœÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦%ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'progress.reps_short': 'ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾',
    'progress.chart_accuracy_trend_legend': 'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â©ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã¢â€žÂ¢ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.total_reps_all_time': 'ÃƒÂ§Ã‚Â·Ã‚ÂÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¦Ã…â€œÃ…Â¸ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Å“ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'progress.avg_accuracy_all_sessions': 'ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'progress.sessions': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³',
    'progress.chart_accuracy_trend': 'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¦Ã…Â½Ã‚Â¨ÃƒÂ§Ã‚Â§Ã‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.no_sessions': 'ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.empty': 'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\nÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¥Ã‹â€ Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.collection': 'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â³ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³',
    'badges.current_status': 'ÃƒÂ§Ã‚ÂÃ‚Â¾ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ§Ã…Â Ã‚Â¶ÃƒÂ¦Ã‚Â³Ã‚Â',
    'badges.unlocked_count': '{unlocked}/{total}ÃƒÂ¥Ã¢â€šÂ¬Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤',
    'badges.tier': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢: {tier}',
    'badges.next_target':
        'ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã¢â€žÂ¢: {name} ({progress}/{requirement}) - ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ {percent}% ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â ',
    'badges.how_it_works': 'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¤Ã‚Â»Ã¢â‚¬Â¢ÃƒÂ§Ã‚ÂµÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¿',
    'badges.guide_1': 'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã‚ÂÃ‚Â¯5ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã‚Â»2ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã‚ÂÃ‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.guide_2': 'ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â¸Ã¢â‚¬ÂºÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.guide_3': '1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â¶Ã¢â‚¬Â¦ÃƒÂ£Ã‚ÂÃ‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°/ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã‚Â¿Ã‚Â½ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.guide_4':
        'ÃƒÂ£Ã†â€™Ã¢â€šÂ¬ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â€žÂ¢ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡OKÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â»Ã‚Â£ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â¿ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚ÂÃ‚Â²ÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ¯Ã‚Â¼Ã‹â€ Upper ÃƒÂ£Ã‚ÂÃ‚Â¯ push-upsÃƒÂ£Ã¢â€šÂ¬Ã‚ÂLower ÃƒÂ£Ã‚ÂÃ‚Â¯ squats ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã‚ÂÃ‚Â©ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.guide_5': 'ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ¨Ã‚Â¨Ã‹â€ ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚Â®Ã…Â¸ÃƒÂ©Ã…Â¡Ã¢â‚¬ÂºÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¦Ã‹Å“Ã‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.unlocked_on': '{date} ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤',
    'badges.tap_full_plan': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â¦Ã¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹',
    'badges.new_unlock_today': 'ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¯Ã‚Â¼Ã‚ÂÃƒÂ£Ã‚ÂÃ…Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.unlocked_banner': 'ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¯Ã‚Â¼Ã‚ÂÃƒÂ¥Ã¢â‚¬Å¾Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ§Ã‚Â¶Ã¢â€žÂ¢ÃƒÂ§Ã‚Â¶Ã…Â¡ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã¢â‚¬Â¹Ã‚Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¡ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.poster_saved_note':
        'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â®ÃƒÂ£Ã†â€™Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â  {album} ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.poster_save_failed_note':
        'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â®ÃƒÂ£Ã†â€™Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ¦Ã‚Â¨Ã‚Â©ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â¢Ã‚ÂºÃƒÂ¨Ã‚ÂªÃ‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.no_tier': 'ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“',
    'badges.motivation_unlocked': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã…â€™Ã¢â‚¬Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.motivation_almost': 'ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ¥Ã‚Â°Ã¢â‚¬ËœÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ‚Â¨ {remaining} ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.motivation_keep': 'ÃƒÂ§Ã‚Â¶Ã¢â€žÂ¢ÃƒÂ§Ã‚Â¶Ã…Â¡ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã‚Â¤Ã‚Â§ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â¡ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â¯Ã…Â½ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã‚Â©Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â­ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'tier.bronze': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€œÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Âº',
    'tier.silver': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼',
    'tier.gold': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â´ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã¢â‚¬Â°',
    'tier.platinum': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã…Â ',
    'badge.first_workout.name': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã¢â‚¬â€',
    'badge.first_workout.narrative': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¥Ã‹â€ Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ¤Ã‚Â»Ã‹Å“ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.first_workout.detail1': 'ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã¢â€žÂ¢: ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ¤Ã‚Â»Ã‹Å“ÃƒÂ£Ã‚ÂÃ‚Â1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.first_workout.detail2':
        'Upper ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã¢â€žÂ¢: ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â¨Ã‹â€ 8ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise)ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.first_workout.detail3': 'Core ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã¢â€žÂ¢: ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â¨Ã‹â€ 10ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ (Sit-up)ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.first_workout.detail4': 'Lower ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã¢â€žÂ¢: ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â¨Ã‹â€ 12ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ (Squat / Leg Extension)ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.name': '15ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¦Ã‚ÂºÃ¢â‚¬â€œÃƒÂ¥Ã¢â‚¬Å¡Ã¢â€žÂ¢',
    'badge.prep.narrative': '15ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã‚ÂºÃ¢â‚¬â€œÃƒÂ¥Ã¢â‚¬Å¡Ã¢â€žÂ¢ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ§Ã‚Â¶Ã¢â€žÂ¢ÃƒÂ§Ã‚Â¶Ã…Â¡ÃƒÂ¥Ã…Â Ã¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã‚ÂÃ‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail1': '5ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ + 2ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ‚Â®15ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ¯Ã‚Â¼Ã‹â€ 6-7ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¨13-14ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail2':
        '1-3ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥: Upper 8ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾x2ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ; Core 10ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾x2ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ; Lower 12ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾x2ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail3': '4-5ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥: Upper 10x2; Core 12x2; Lower 15x2ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail4': '8-12ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥: Upper 12x2; Core 15x2; Lower 18x2ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail5': '15ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®: Upper 12x3; Core 15x3; Lower 18x3ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€  = 1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã†â€™Ã¢â‚¬Â ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â´ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ¥Ã‹â€ Ã‚Â¥ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail8':
        'ÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ©Ã‚Â Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ©Ã¢â€šÂ¬Ã†â€™ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂprepÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¦ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°Day 1ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂÃƒÂ©Ã¢â‚¬â€œÃ¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.name': '1ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â® ÃƒÂ£Ã†â€™Ã¢â‚¬â€œÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Âº',
    'badge.bronze.narrative': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã…Â¸Ã‚ÂºÃƒÂ§Ã‚Â¤Ã…Â½ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã‚ÂÃ‚ÂªÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹1ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail1': '5ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ + 2ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ¤Ã‚Â»Ã‹Å“ÃƒÂ£Ã‚ÂÃ‚Â30ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail2':
        'Upper: 30ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ + 3ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã‹â€ Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail3': 'Core: 36ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ + 3ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã‹â€ Sit-upÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail4': 'Lower: 45ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ + 3ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã‹â€ Squat / Leg Extension ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail5': 'ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â¶Ã¢â‚¬Â¦ÃƒÂ£Ã‚ÂÃ‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°/ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail6': '1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ©Ã¢â€šÂ¬Ã†â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã¢â€šÂ¬Ã‚Â1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.name': '2ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â® ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â¼',
    'badge.silver.narrative': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã†â€™Ã…â€œÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¥ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¦Ã‚Â±Ã¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail1': '5ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ + 2ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ¤Ã‚Â»Ã‹Å“ÃƒÂ£Ã‚ÂÃ‚Â30ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail2':
        'Upper: 48ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ + 4ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã‹â€ Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail3': 'Core: 60ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ + 4ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã‹â€ Sit-upÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail4': 'Lower: 80ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ + 4ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã‹â€ Squat / Leg Extension ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail5': 'ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã‚ÂÃ‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ§Ã¢â‚¬Å¾Ã‚Â¡ÃƒÂ¨Ã‚Â¦Ã¢â‚¬â€œÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail6': '1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ©Ã¢â€šÂ¬Ã†â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã¢â€šÂ¬Ã‚Â1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.name': '3ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â® ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â´ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã¢â‚¬Â°',
    'badge.gold.narrative': 'ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ§Ã‚Â´Ã…Â¡ÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¤Ã‚Â¹Ã¢â‚¬Â¦ÃƒÂ¥Ã…Â Ã¢â‚¬ÂºÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ©Ã‚ÂÃ¢â‚¬ÂÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail1': '5ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ + 2ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂµÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¯ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ¤Ã‚Â»Ã‹Å“ÃƒÂ£Ã‚ÂÃ‚Â30ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail2':
        'Upper: 60ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ + 4ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã‹â€ Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail3': 'Core: 100ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ + 4ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã‹â€ Sit-upÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail4': 'Lower: 100ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ + 4ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â»ÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ¯Ã‚Â¼Ã‹â€ Squat / Leg Extension ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail5': 'ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ¨Ã‚Â¨Ã‹â€ ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¨Ã‚Â¶Ã¢â‚¬Â¦ÃƒÂ©Ã‚ÂÃ…Â½ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail6': '1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ©Ã¢â€šÂ¬Ã†â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã¢â€šÂ¬Ã‚Â1ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¾ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.default.goal': 'ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â¨Ã¢â€žÂ¢: {description}',
    'badge.default.requirement': 'ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¤Ã‚Â»Ã‚Â¶: ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ¤Ã‚Â»Ã‹Å“ÃƒÂ£Ã‚ÂÃ‚Â {requirement} ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.default.status': 'ÃƒÂ§Ã‚ÂÃ‚Â¾ÃƒÂ¥Ã…â€œÃ‚Â¨: {progress}/{requirement}.',
    'badge.poster.badge_label': 'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸',
    'badge.poster.user_label': 'ÃƒÂ©Ã‚ÂÃ¢â‚¬ÂÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¨Ã¢â€šÂ¬Ã¢â‚¬Â¦',
    'badge.poster.requirements_label': 'ÃƒÂ©Ã‚ÂÃ‚Â©ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿',
    'leaderboard.title': 'ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°',
    'leaderboard.achievements': 'ÃƒÂ¥Ã‚Â®Ã…Â¸ÃƒÂ§Ã‚Â¸Ã‚Â¾',
    'leaderboard.global': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â«',
    'leaderboard.achievement_progress': 'ÃƒÂ¥Ã‚Â®Ã…Â¸ÃƒÂ§Ã‚Â¸Ã‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ©Ã¢â€šÂ¬Ã‚Â²ÃƒÂ¦Ã‚ÂÃ¢â‚¬â€',
    'leaderboard.personal_bests': 'ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã‚Â·Ã‚Â±ÃƒÂ£Ã†â€™Ã¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã‹â€ ',
    'leaderboard.most_reps': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¥Ã‚Â¤Ã…Â¡ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°',
    'leaderboard.best_accuracy': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚Â²Ã‚Â¾ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'leaderboard.longest_streak': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ©Ã¢â‚¬Â¢Ã‚Â·ÃƒÂ©Ã¢â€šÂ¬Ã‚Â£ÃƒÂ§Ã‚Â¶Ã…Â¡',
    'leaderboard.days': 'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥',
    'leaderboard.global_simulated': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â­ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã…Â¸ÃƒÂ£Ã†â€™Ã‚Â¥ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â·ÃƒÂ£Ã†â€™Ã‚Â§ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'leaderboard.points': '{score} pt',
    'recordings.tab.recordings': 'ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»',
    'recordings.tab.profile': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«',
    'recordings.failed_load': 'ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚ÂªÃ‚Â­ÃƒÂ£Ã‚ÂÃ‚Â¿ÃƒÂ¨Ã‚Â¾Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸',
    'recordings.empty': 'ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“',
    'recordings.file_not_found': 'ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¨Ã‚Â¦Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“',
    'recordings.file_incomplete': 'ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.guest_name': 'ÃƒÂ£Ã†â€™Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¶ÃƒÂ£Ã†â€™Ã‚Â¼',
    'profile.user_name_label': 'ÃƒÂ£Ã†â€™Ã‚Â¦ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¶ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ¥Ã‚ÂÃ‚Â',
    'profile.edit_name': 'ÃƒÂ§Ã‚Â·Ã‚Â¨ÃƒÂ©Ã¢â‚¬ÂºÃ¢â‚¬Â ',
    'profile.name_hint': 'ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ¥Ã…Â Ã¢â‚¬Âº',
    'profile.save_name': 'ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“',
    'profile.photo_title': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸',
    'profile.photo_subtitle': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â¿Ã‚Â½ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â«ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã¢â‚¬Å¡Ã‚ÂºÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¡ÃƒÂ£Ã‚ÂÃ¢â‚¬Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.photo_add': 'ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â¿Ã‚Â½ÃƒÂ¥Ã…Â Ã‚Â ',
    'profile.photo_change': 'ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´',
    'profile.photo_remove': 'ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤',
    'profile.photo_remove_confirm': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¥Ã¢â‚¬Â°Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¯Ã‚Â¼Ã…Â¸',
    'profile.photo_too_large': 'ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚Â®Ã‚Â¹ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã‚Â¤Ã‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã‚ÂÃ…Â½ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã‚Â°Ã‚ÂÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ¥Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ©Ã‚ÂÃ‚Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.photo_error': 'ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ…Â¸ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã‹â€ Ã‚Â¥ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ¥Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â©Ã‚Â¦ÃƒÂ£Ã‚ÂÃ¢â‚¬â€ÃƒÂ£Ã‚ÂÃ‚Â¦ÃƒÂ£Ã‚ÂÃ‚ÂÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.photo_badge_notice':
        'ÃƒÂ£Ã†â€™Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚Â­ÃƒÂ£Ã†â€™Ã¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¦Ã…â€œÃ‚ÂªÃƒÂ¨Ã‚Â¨Ã‚Â­ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚Â Ã‚Â´ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã¢â‚¬Â Ã¢â€žÂ¢ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.exercise_totals_title': 'ÃƒÂ§Ã‚Â´Ã‚Â¯ÃƒÂ¨Ã‚Â¨Ã‹â€ ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°',
    'profile.exercise_totals_subtitle': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¥Ã‹â€ Ã‚ÂÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã†â€™Ã¢â‚¬Â¹ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â°ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â°ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â§ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.exercise_empty': 'ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ©Ã‚ÂÃ¢â‚¬Â¹ÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“',
    'profile.badges_title': 'ÃƒÂ§Ã‚ÂÃ‚Â²ÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸',
    'profile.badges_empty': 'ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ‚Â ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã‚ÂÃ…â€™ÃƒÂ£Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ£Ã¢â‚¬Å¡Ã…Â ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â‚¬ÂºÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Å“',
    'profile.badge_gallery_saved_note':
        'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã†â€™ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¸ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ£Ã‚ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¿ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â®ÃƒÂ£Ã†â€™Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â©ÃƒÂ£Ã†â€™Ã‚ÂªÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ£Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¢ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â  {album} ÃƒÂ£Ã‚ÂÃ‚Â«ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã¢â‚¬Â¹Ã¢â‚¬Â¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ£Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ£Ã¢â‚¬Å¡Ã…â€™ÃƒÂ£Ã‚ÂÃ‚Â¾ÃƒÂ£Ã‚ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'iconic.menu.title': 'Ã£â€šÂ¢Ã£â€šÂ¤Ã£â€šÂ³Ã£Æ’â€¹Ã£Æ’Æ’Ã£â€šÂ¯Ã£Æ’â€”Ã£Æ’Â­Ã£â€šÂ°Ã£Æ’Â©Ã£Æ’Â ',
    'iconic.menu.subtitle':
        'Ã©Å’Â²Ã§â€Â»Ã£Ââ€”Ã£ÂÅ¸Ã¥â€¹â€¢Ã§â€Â»Ã£ÂÂ«Ã©ÂÂ©Ã§â€Â¨Ã£Ââ„¢Ã£â€šâ€¹Ã£Æ’â€”Ã£Æ’Â¬Ã£Æ’Å¸Ã£â€šÂ¢Ã£Æ’Â Ã£ÂÂªÃ£Æ’ÂÃ£â€šÂ¹Ã£Æ’Ë†Ã£Æ’â€”Ã£Æ’Â­Ã£â€šÂ»Ã£â€šÂ¹Ã¦Â¼â€Ã¥â€¡ÂºÃ£â€šâ€™Ã©ÂÂ¸Ã£ÂÂ¹Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€šÃ¥Ââ€žÃ£Æ’â€”Ã£Æ’Â­Ã£â€šÂ°Ã£Æ’Â©Ã£Æ’Â Ã£ÂÂ¯Ã£â‚¬ÂÃ£Æ’Â©Ã£â€šÂ¤Ã£Æ’â€“Ã¦â€™Â®Ã¥Â½Â±Ã¤Â¸Â­Ã£ÂÂ®Ã§â„¢ÂºÃ§â€ Â±Ã£â€šâ€™Ã¥Â¢â€”Ã£â€šâ€žÃ£Ââ€¢Ã£ÂÅ¡Ã£ÂÂ«Ã£â‚¬ÂÃ¥â‚¬â€¹Ã¦â‚¬Â§Ã§Å¡â€žÃ£ÂÂ§Ã¦ËœÂ Ã§â€Â»Ã§Å¡â€žÃ£Ââ€¹Ã£ÂÂ¤Ã¤Â¸Å Ã¥â€œÂÃ£ÂÂ«Ã¨Â¦â€¹Ã£ÂË†Ã£â€šâ€¹Ã£â€šË†Ã£Ââ€ Ã¨Â¨Â­Ã¨Â¨Ë†Ã£Ââ€¢Ã£â€šÅ’Ã£ÂÂ¦Ã£Ââ€žÃ£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.program.zodiac.eyebrow': 'Ã£Æ’ÂÃ£â€šÂ¹Ã£Æ’Ë†Ã£Æ’â€”Ã£Æ’Â­Ã£â€šÂ»Ã£â€šÂ¹Ã¦Â¼â€Ã¥â€¡Âº',
    'iconic.program.zodiac.description':
        'Ã©Å’Â²Ã§â€Â»Ã¥Â¾Å’Ã£ÂÂ«Ã©Â«ËœÃ§Â´Å¡Ã¦â€žÅ¸Ã£ÂÂ®Ã£Ââ€šÃ£â€šâ€¹Ã¦ËœÅ¸Ã¥ÂºÂ§Ã£â€šÂªÃ£Æ’Â¼Ã£Æ’ÂÃ£Æ’Â¼Ã£Æ’Â¬Ã£â€šÂ¤Ã£â€šâ€™Ã©ÂÂ©Ã§â€Â¨Ã£Ââ€”Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š12Ã¦ËœÅ¸Ã¥ÂºÂ§Ã£ÂÂÃ£â€šÅ’Ã£ÂÅ¾Ã£â€šÅ’Ã£ÂÂ«Ã§â€¢Â°Ã£ÂÂªÃ£â€šâ€¹Ã©â€¦ÂÃ¨â€°Â²Ã£â‚¬ÂÃ£â€šÂ·Ã£Æ’Â³Ã£Æ’Å“Ã£Æ’Â«Ã£â‚¬ÂÃ£â€šÂªÃ£Æ’Â¼Ã£Æ’Â©Ã£ÂÂ®Ã¨â€°Â²Ã¥â€˜Â³Ã£â‚¬ÂÃ¥Ë†Â»Ã¥ÂÂ°Ã©Â¢Â¨Ã£â€šÂ¹Ã£â€šÂ¿Ã£â€šÂ¤Ã£Æ’Â«Ã£ÂÅ’Ã£Ââ€šÃ£â€šÅ Ã£â‚¬ÂÃ£Æ’â€”Ã£Æ’Â¬Ã£Æ’â€œÃ£Æ’Â¥Ã£Æ’Â¼Ã£ÂÂ¯Ã§â€°Â¡Ã§Â¾Å Ã¥ÂºÂ§Ã£ÂÂ®Ã£â€šÂ¢Ã£Æ’Â¼Ã£Æ’Ë†Ã¦â€“Â¹Ã¥Ââ€˜Ã£ÂÂ«Ã¥ÂË†Ã£â€šÂÃ£Ââ€ºÃ£ÂÂ¦Ã£Ââ€žÃ£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.program.zodiac.tag.sign_themes': '12Ã¦ËœÅ¸Ã¥ÂºÂ§Ã£Æ’â€ Ã£Æ’Â¼Ã£Æ’Å¾',
    'iconic.program.zodiac.tag.luxury_capsule': 'Ã£Æ’Â©Ã£â€šÂ°Ã£â€šÂ¸Ã£Æ’Â¥Ã£â€šÂ¢Ã£Æ’ÂªÃ£Æ’Â¼Ã¦Â¼â€Ã¥â€¡Âº',
    'iconic.program.zodiac.tag.embossed_coin': 'Ã£â€šÂ¨Ã£Æ’Â³Ã£Æ’Å“Ã£â€šÂ¹Ã£â€šÂ³Ã£â€šÂ¤Ã£Æ’Â³',
    'iconic.program.zodiac.footer':
        'Ã¥ÂÂ°Ã¨Â±Â¡Ã§Å¡â€žÃ£ÂÂªÃ¦â€ºÂ¸Ã£ÂÂÃ¥â€¡ÂºÃ£Ââ€”Ã£ÂÂ«Ã£ÂÅ Ã£Ââ„¢Ã£Ââ„¢Ã£â€šÂÃ£ÂÂ§Ã£Ââ„¢Ã£â‚¬â€šÃ£Æ’Â©Ã£â€šÂ¤Ã£Æ’â€“Ã¦â€™Â®Ã¥Â½Â±Ã£ÂÂ¯Ã¨Â»Â½Ã©â€¡ÂÃ£ÂÂ®Ã£ÂÂ¾Ã£ÂÂ¾Ã£ÂÂªÃ£ÂÂ®Ã£ÂÂ§Ã§Â«Â¯Ã¦Å“Â«Ã£ÂÅ’Ã§â€ Â±Ã£ÂÂÃ£ÂÂªÃ£â€šÅ Ã£ÂÂ«Ã£ÂÂÃ£ÂÂÃ£â‚¬ÂÃ¨Â±ÂªÃ¨ÂÂ¯Ã£ÂÂªÃ¦Â¼â€Ã¥â€¡ÂºÃ£ÂÂ¯Ã©Å’Â²Ã§â€Â»Ã¥Â¾Å’Ã£ÂÂ®Ã¥â€¡Â¦Ã§Ââ€ Ã£ÂÂ§Ã¨Â¿Â½Ã¥Å Â Ã£Ââ€¢Ã£â€šÅ’Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.program.festival.eyebrow': 'Ã£â€šÂ«Ã£Æ’Â«Ã£Æ’ÂÃ£Æ’Â£Ã£Æ’Â¼Ã£â€šÂ»Ã£Æ’Â¬Ã£Æ’â€“Ã£Æ’Â¬Ã£Æ’Â¼Ã£â€šÂ·Ã£Æ’Â§Ã£Æ’Â³',
    'iconic.program.festival.description':
        'Ã¦Å“â‚¬Ã£â€šâ€šÃ¨Â¿â€˜Ã£Ââ€žÃ¤Â¸â€“Ã§â€¢Å’Ã£ÂÂ®Ã§Â¥Â­Ã¥â€¦Â¸Ã£â€šâ€žÃ£â€šÂ¹Ã£Æ’ÂÃ£Æ’Â¼Ã£Æ’â€žÃ£â€šÂ¤Ã£Æ’â„¢Ã£Æ’Â³Ã£Æ’Ë†Ã£ÂÂ«Ã¥Å¸ÂºÃ£ÂÂ¥Ã£Ââ€žÃ£ÂÂ¦Ã£â‚¬ÂÃ§â€°Â¹Ã¥Ë†Â¥Ã£ÂÂªÃ©Â«ËœÃ§Â´Å¡Ã£â€šÂªÃ£Æ’Â¼Ã£Æ’ÂÃ£Æ’Â¼Ã£Æ’Â¬Ã£â€šÂ¤Ã£â€šâ€™Ã©ÂÂ©Ã§â€Â¨Ã£Ââ€”Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€šÃ¥Ââ€žÃ§Â¥Â­Ã¥â€¦Â¸Ã£Ââ€Ã£ÂÂ¨Ã£ÂÂ«Ã§â€¹Â¬Ã¨â€¡ÂªÃ£ÂÂ®Ã©â€¦ÂÃ¨â€°Â²Ã£â‚¬ÂÃ£Æ’ÂªÃ£Æ’Â³Ã£â€šÂ°Ã£ÂÂ®Ã¥â€¦â€°Ã£â‚¬ÂÃ§Â²Â¾Ã¥ÂºÂ¦Ã£Æ’ÂÃ£Æ’Â¼Ã£ÂÂ®Ã£â€šÂ°Ã£Æ’Â©Ã£Æ’â€¡Ã£Æ’Â¼Ã£â€šÂ·Ã£Æ’Â§Ã£Æ’Â³Ã£â‚¬ÂÃ£Æ’â€“Ã£Æ’Â©Ã£Æ’Â³Ã£Æ’â€°Ã¦Â¼â€Ã¥â€¡ÂºÃ£ÂÅ’Ã£Ââ€šÃ£â€šÅ Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.program.festival.tag.festivals': '70Ã£ÂÂ®Ã§Â¥Â­Ã¥â€¦Â¸',
    'iconic.program.festival.tag.date_aware': 'Ã¦â€”Â¥Ã¤Â»ËœÃ©â‚¬Â£Ã¥â€¹â€¢',
    'iconic.program.festival.tag.luxury_overlay': 'Ã©Â«ËœÃ§Â´Å¡Ã£â€šÂªÃ£Æ’Â¼Ã£Æ’ÂÃ£Æ’Â¼Ã£Æ’Â¬Ã£â€šÂ¤',
    'iconic.program.festival.footer':
        'Ã£Æ’â€ Ã£Æ’Â¼Ã£Æ’Å¾Ã£ÂÂ¯Ã¦Å“â‚¬Ã£â€šâ€šÃ¨Â¿â€˜Ã£Ââ€žÃ¦Â¬Â¡Ã£ÂÂ®Ã§Â¥ÂÃ§Â¥Â­Ã£ÂÂ¸Ã¨â€¡ÂªÃ¥â€¹â€¢Ã£ÂÂ§Ã¥Ë†â€¡Ã£â€šÅ Ã¦â€ºÂ¿Ã£â€šÂÃ£â€šÅ Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€šÃ£Æ’Â¯Ã£Æ’Â¼Ã£â€šÂ¯Ã£â€šÂ¢Ã£â€šÂ¦Ã£Æ’Ë†Ã£â€šâ€™Ã©Å’Â²Ã§â€Â»Ã£Ââ„¢Ã£â€šâ€¹Ã£ÂÂ¨Ã£â‚¬ÂÃ£ÂÂÃ£ÂÂ®Ã¦â„¢â€šÃ§â€šÂ¹Ã£ÂÂ§Ã¦Å“â€°Ã¥Å Â¹Ã£ÂÂªÃ§Â¥Â­Ã¥â€¦Â¸Ã£Æ’â€¡Ã£â€šÂ¶Ã£â€šÂ¤Ã£Æ’Â³Ã£ÂÅ’Ã£Æ’ÂÃ£â€šÂ¹Ã£Æ’Ë†Ã£Æ’â€”Ã£Æ’Â­Ã£â€šÂ»Ã£â€šÂ¹Ã£ÂÂ§Ã©ÂÂ©Ã§â€Â¨Ã£Ââ€¢Ã£â€šÅ’Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.program.studio.eyebrow': 'Ã£Æ’â€¢Ã£Æ’Â«Ã£â€šÂ«Ã£â€šÂ¹Ã£â€šÂ¿Ã£Æ’Å¾Ã£â€šÂ¤Ã£â€šÂº',
    'iconic.program.studio.description':
        'Ã¥â€ºÅ¾Ã¦â€¢Â°Ã£â€šÂ«Ã£â€šÂ¦Ã£Æ’Â³Ã£â€šÂ¿Ã£Æ’Â¼Ã£â‚¬ÂÃ§Â²Â¾Ã¥ÂºÂ¦Ã£Æ’ÂÃ£Æ’Â¼Ã£â‚¬ÂÃ¦Â¼â€Ã¥â€¡ÂºÃ£ÂÂ®Ã¦ÂµÂÃ£â€šÅ’Ã£â‚¬ÂÃ£â€šÂ¢Ã£â€šÂ¤Ã£â€šÂ³Ã£Æ’Â³Ã£â‚¬ÂÃ©â€¦ÂÃ¨â€°Â²Ã£â‚¬ÂÃ¤Â»â€¢Ã¤Â¸Å Ã£Ââ€™Ã¨Â¨Â­Ã¥Â®Å¡Ã£ÂÂ¾Ã£ÂÂ§Ã§Â·Â¨Ã©â€ºâ€ Ã£ÂÂ§Ã£ÂÂÃ£â€šâ€¹Ã¨â€¡ÂªÃ¥Ë†â€ Ã¥Â°â€šÃ§â€Â¨Ã£ÂÂ®Ã£Æ’â€”Ã£Æ’Â¬Ã£Æ’Å¸Ã£â€šÂ¢Ã£Æ’Â Ã£â€šÂªÃ£Æ’Â¼Ã£Æ’ÂÃ£Æ’Â¼Ã£Æ’Â¬Ã£â€šÂ¤Ã£â€šâ€™Ã¤Â½Â¿Ã£ÂË†Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.program.studio.tag.custom_program': 'Ã£â€šÂ«Ã£â€šÂ¹Ã£â€šÂ¿Ã£Æ’Â Ã£Æ’â€”Ã£Æ’Â­Ã£â€šÂ°Ã£Æ’Â©Ã£Æ’Â ',
    'iconic.program.studio.tag.luxury_editor': 'Ã£Æ’Â©Ã£â€šÂ°Ã£â€šÂ¸Ã£Æ’Â¥Ã£â€šÂ¢Ã£Æ’ÂªÃ£Æ’Â¼Ã§Â·Â¨Ã©â€ºâ€ ',
    'iconic.program.studio.tag.premium_control': 'Ã£Æ’â€”Ã£Æ’Â¬Ã£Æ’Å¸Ã£â€šÂ¢Ã£Æ’Â Ã¥Ë†Â¶Ã¥Â¾Â¡',
    'iconic.program.studio.footer':
        'Ã¥â€ºÂºÃ¥Â®Å¡Ã£ÂÂ®Ã¦ËœÅ¸Ã¥ÂºÂ§Ã£â€šâ€žÃ§Â¥Â­Ã¥â€¦Â¸Ã¦Â¼â€Ã¥â€¡ÂºÃ£ÂÂ§Ã£ÂÂ¯Ã£ÂÂªÃ£ÂÂÃ£â‚¬ÂÃ¨â€¡ÂªÃ¥Ë†â€ Ã£ÂÂ Ã£Ââ€˜Ã£ÂÂ®Ã¦â€°â€¹Ã¤Â½Å“Ã£â€šÅ Ã£Æ’Â©Ã£â€šÂ°Ã£â€šÂ¸Ã£Æ’Â¥Ã£â€šÂ¢Ã£Æ’ÂªÃ£Æ’Â¼Ã£â€šÂªÃ£Æ’Â¼Ã£Æ’ÂÃ£Æ’Â¼Ã£Æ’Â¬Ã£â€šÂ¤Ã£â€šâ€™Ã¤Â½Â¿Ã£Ââ€žÃ£ÂÅ¸Ã£Ââ€žÃ£ÂÂ¨Ã£ÂÂÃ£ÂÂ«Ã©ÂÂ¸Ã£â€šâ€œÃ£ÂÂ§Ã£ÂÂÃ£ÂÂ Ã£Ââ€¢Ã£Ââ€žÃ£â‚¬â€š',
    'iconic.program.studio.action': 'Ã£â€šÂ¹Ã£â€šÂ¿Ã£â€šÂ¸Ã£â€šÂªÃ£â€šâ€™Ã©â€“â€¹Ã£ÂÂ',
    'iconic.program.standard.eyebrow': 'Ã¨Â»Â½Ã©â€¡ÂÃ£Æ’â€¡Ã£Æ’â€¢Ã£â€šÂ©Ã£Æ’Â«Ã£Æ’Ë†',
    'iconic.program.standard.description':
        'Ã£Æ’â€“Ã£Æ’Â©Ã£Æ’Â³Ã£Æ’â€°Ã¦â€žÅ¸Ã£ÂÂ®Ã£Ââ€šÃ£â€šâ€¹Ã£â€šÂ·Ã£Æ’ÂÃ£Æ’Å¾Ã£Æ’â€ Ã£â€šÂ£Ã£Æ’Æ’Ã£â€šÂ¯Ã¦Â¼â€Ã¥â€¡ÂºÃ£ÂÅ’Ã¤Â¸ÂÃ¨Â¦ÂÃ£ÂÂªÃ£ÂÂ¨Ã£ÂÂÃ£ÂÂ¯Ã£â‚¬ÂÃ§ÂÂ¾Ã¥Å“Â¨Ã£ÂÂ®Ã£â€šÂ·Ã£Æ’Â³Ã£Æ’â€”Ã£Æ’Â«Ã£ÂÂªÃ£â€šÂªÃ£Æ’Â¼Ã£Æ’ÂÃ£Æ’Â¼Ã£Æ’Â¬Ã£â€šÂ¤Ã£â€šâ€™Ã§Â¶Â­Ã¦Å’ÂÃ£Ââ€”Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.program.standard.tag.default': 'Ã¦Â¨â„¢Ã¦Âºâ€“',
    'iconic.program.standard.tag.minimal': 'Ã£Æ’Å¸Ã£Æ’â€¹Ã£Æ’Å¾Ã£Æ’Â«',
    'iconic.program.standard.tag.fast_export': 'Ã©Â«ËœÃ©â‚¬Å¸Ã¦â€ºÂ¸Ã£ÂÂÃ¥â€¡ÂºÃ£Ââ€”',
    'iconic.program.standard.footer':
        'Ã£Æ’â€”Ã£Æ’Â¬Ã£Æ’Å¸Ã£â€šÂ¢Ã£Æ’Â Ã£ÂÂªÃ£â€šÂ¢Ã£Æ’Â¼Ã£Æ’Ë†Ã¦Â¼â€Ã¥â€¡ÂºÃ£ÂÂªÃ£Ââ€”Ã£ÂÂ§Ã£â‚¬ÂÃ¤Â»Å Ã£ÂÂ®Ã¦â€ºÂ¸Ã£ÂÂÃ¥â€¡ÂºÃ£Ââ€”Ã£â€šÂ¹Ã£â€šÂ¿Ã£â€šÂ¤Ã£Æ’Â«Ã£â€šâ€™Ã¤Â½Â¿Ã£Ââ€žÃ£ÂÅ¸Ã£Ââ€žÃ¥Â Â´Ã¥ÂË†Ã£ÂÂ¯Ã£Ââ€œÃ£ÂÂ¡Ã£â€šâ€°Ã£â€šâ€™Ã©ÂÂ¸Ã£ÂÂ³Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.info.title': 'Ã¤Â½Â¿Ã£Ââ€žÃ¦â€“Â¹',
    'iconic.info.step1': '1. Ã£Ââ€œÃ£Ââ€œÃ£ÂÂ§Ã£Æ’â€”Ã£Æ’Â­Ã£â€šÂ°Ã£Æ’Â©Ã£Æ’Â Ã£â€šâ€™Ã©ÂÂ¸Ã£ÂÂ³Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.info.step2': '2. Ã£Ââ€žÃ£ÂÂ¤Ã£â€šâ€šÃ©â‚¬Å¡Ã£â€šÅ Ã£ÂÂ«Ã£Æ’Â¯Ã£Æ’Â¼Ã£â€šÂ¯Ã£â€šÂ¢Ã£â€šÂ¦Ã£Æ’Ë†Ã£â€šâ€™Ã©Å’Â²Ã§â€Â»Ã£Ââ€”Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.info.step3':
        '3. Ã©ÂÂ¸Ã¦Å Å¾Ã£Ââ€”Ã£ÂÅ¸Ã£â€šÂ¹Ã£â€šÂ¿Ã£â€šÂ¤Ã£Æ’Â«Ã£ÂÂ¯Ã©Å’Â²Ã§â€Â»Ã¥Â¾Å’Ã£ÂÂ®Ã£Æ’ÂÃ£â€šÂ¹Ã£Æ’Ë†Ã£Æ’â€”Ã£Æ’Â­Ã£â€šÂ»Ã£â€šÂ¹Ã¦â„¢â€šÃ£ÂÂ«Ã£ÂÂ®Ã£ÂÂ¿Ã©ÂÂ©Ã§â€Â¨Ã£Ââ€¢Ã£â€šÅ’Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.preview.post_process': 'Ã£Æ’ÂÃ£â€šÂ¹Ã£Æ’Ë†Ã£Æ’â€”Ã£Æ’Â­Ã£â€šÂ»Ã£â€šÂ¹Ã£Æ’â€”Ã£Æ’Â¬Ã£Æ’â€œÃ£Æ’Â¥Ã£Æ’Â¼',
    'iconic.preview.standard.caption':
        'Ã¦Â¨â„¢Ã¦Âºâ€“Ã£ÂÂ®Ã¦â€ºÂ¸Ã£ÂÂÃ¥â€¡ÂºÃ£Ââ€”Ã£â€šÂªÃ£Æ’Â¼Ã£Æ’ÂÃ£Æ’Â¼Ã£Æ’Â¬Ã£â€šÂ¤Ã£ÂÅ’\nÃ§ÂÂ¾Ã¥Å“Â¨Ã£ÂÂ®Ã¨Â»Â½Ã©â€¡ÂÃ£ÂÂªÃ¨Â¦â€¹Ã£ÂÅ¸Ã§â€ºÂ®Ã£â€šâ€™Ã¤Â¿ÂÃ£ÂÂ¡Ã£ÂÂ¾Ã£Ââ„¢Ã£â‚¬â€š',
    'iconic.preview.editable_luxe': 'Ã§Â·Â¨Ã©â€ºâ€ Ã¥ÂÂ¯Ã¨Æ’Â½Ã£Æ’Â©Ã£â€šÂ°Ã£â€šÂ¸Ã£Æ’Â¥Ã£â€šÂ¢Ã£Æ’ÂªÃ£Æ’Â¼',
    'camera.overlay.skeleton': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â±ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã†â€™Ã‚Â³',
    'camera.overlay.stop': 'ÃƒÂ¥Ã‚ÂÃ…â€œÃƒÂ¦Ã‚Â­Ã‚Â¢',
    'camera.overlay.record': 'ÃƒÂ©Ã…â€™Ã‚Â²ÃƒÂ§Ã¢â‚¬ÂÃ‚Â»',
    'camera.overlay.complete': 'ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â ',
    'lang.en': 'ÃƒÂ¨Ã¢â‚¬Â¹Ã‚Â±ÃƒÂ¨Ã‚ÂªÃ…Â¾',
    'lang.es': 'ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ£Ã†â€™Ã…Â¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ¨Ã‚ÂªÃ…Â¾',
    'lang.ja': 'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¨Ã‚ÂªÃ…Â¾',
    'lang.my': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Å“ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã…Â¾ÃƒÂ¨Ã‚ÂªÃ…Â¾',
    'lang.hi': 'ÃƒÂ£Ã†â€™Ã¢â‚¬â„¢ÃƒÂ£Ã†â€™Ã‚Â³ÃƒÂ£Ã†â€™Ã¢â‚¬Â¡ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â£ÃƒÂ£Ã†â€™Ã‚Â¼ÃƒÂ¨Ã‚ÂªÃ…Â¾',
    'lang.pt': 'ÃƒÂ£Ã†â€™Ã‚ÂÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ£Ã†â€™Ã‹â€ ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ£Ã†â€™Ã‚Â«ÃƒÂ¨Ã‚ÂªÃ…Â¾',
    'lang.zh': 'ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â½ÃƒÂ¨Ã‚ÂªÃ…Â¾ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¦Ã‚Â¨Ã¢â€žÂ¢ÃƒÂ¦Ã‚ÂºÃ¢â‚¬â€œÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'lang.de': 'ÃƒÂ£Ã†â€™Ã¢â‚¬Â°ÃƒÂ£Ã¢â‚¬Å¡Ã‚Â¤ÃƒÂ£Ã†â€™Ã¢â‚¬Å¾ÃƒÂ¨Ã‚ÂªÃ…Â¾',
  };

  static const Map<String, String> _myValues = {
    'app.title': 'H&F',
    'nav.exercises': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1019\u103b\u102c\u1038',
    'nav.progress': '\u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f',
    'nav.recordings': '\u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u1014\u103e\u1004\u1037\u103a \u1015\u101b\u102d\u102f\u1016\u102d\u102f\u1004\u103a',
    'common.cancel': '\u1015\u101a\u103a\u1016\u103b\u1000\u103a',
    'common.retry': '\u1015\u103c\u1014\u103a\u1000\u103c\u102d\u102f\u1038\u1005\u102c\u1038',
    'common.load_exercises': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1019\u103b\u102c\u1038 \u1015\u103c\u1014\u103a\u1010\u1004\u103a',
    'common.clear_data': '\u1012\u1031\u1010\u102c\u1016\u103b\u1000\u103a',
    'common.ok': 'OK',
    'common.close': '\u1015\u102d\u1010\u103a',
    'common.error_with_message': '\u1021\u1019\u103e\u102c\u1038: {message}',
    'common.copy': '\u1000\u1030\u1038\u101a\u1030',
    'common.remove': '\u1016\u101a\u103a\u101b\u103e\u102c\u1038',
    'premium.license.title': 'Premium \u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a',
    'premium.license.heading':
        '\u1006\u1000\u103a\u101e\u103d\u101a\u103a\u101b\u1014\u103a\u1014\u103e\u1004\u1037\u103a Premium \u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a \u101d\u101a\u103a\u101a\u1030\u101b\u1014\u103a',
    'premium.license.contact_us': '\u1006\u1000\u103a\u101e\u103d\u101a\u103a\u101b\u1014\u103a',
    'premium.license.active': 'Premium \u1016\u103d\u1004\u1037\u103a\u1011\u102c\u1038\u101e\u100a\u103a',
    'premium.license.inactive': 'Premium \u1019\u1016\u103d\u1004\u1037\u103a\u101b\u101e\u1031\u1038',
    'premium.license.expires': '\u101e\u1000\u103a\u1010\u1019\u103a\u1038\u1000\u102f\u1014\u103a: {date}',
    'premium.license.field_label': '\u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a\u1000\u1031\u1038',
    'premium.license.field_hint': 'HF-XXXX-XXXX-XXXX-XXXX',
    'premium.license.enter_key':
        '\u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a\u1000\u1031\u1038 \u101b\u102d\u102f\u1000\u103a\u1011\u100a\u1037\u103a\u1015\u102b',
    'premium.license.wait': '\u1001\u103b\u1031\u1038\u1005\u1031\u102c\u1004\u1037\u103a\u1015\u102b...',
    'premium.license.activate': '\u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a \u1016\u103d\u1004\u1037\u103a\u1019\u100a\u103a',
    'premium.license.deactivate_device':
        '\u1024\u1005\u1000\u103a\u1015\u1031\u102b\u103a\u1010\u103d\u1004\u103a \u1015\u102d\u1010\u103a\u1019\u100a\u103a',
    'premium.license.security_notes':
        '\u101c\u102f\u1036\u1001\u103c\u102f\u1036\u101b\u1031\u1038 \u1019\u103e\u1010\u103a\u1005\u102f',
    'premium.license.security_body':
        '\u1016\u103d\u1004\u1037\u103a\u101b\u1014\u103a\u1000\u102d\u102f server \u1019\u103e \u1021\u1010\u100a\u103a\u1015\u103c\u102f\u1015\u103c\u102e\u1038\u1015\u102b\u1000 encrypted secure storage \u1011\u1032\u1010\u103d\u1004\u103a \u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u1015\u103c\u102e\u1038 \u1024\u1005\u1000\u103a\u1014\u103e\u1004\u1037\u103a \u1001\u103b\u102d\u1010\u103a\u1006\u1000\u103a\u1011\u102c\u1038\u1015\u102b\u101e\u100a\u103a\u104b',
    'premium.license.disabled_device':
        'Premium \u1000\u102d\u102f \u1024\u1005\u1000\u103a\u1015\u1031\u102b\u103a\u1010\u103d\u1004\u103a \u1015\u102d\u1010\u103a\u1015\u103c\u102e\u1038',
    'premium.license.copied': '\u1000\u1030\u1038\u101a\u1030\u1015\u103c\u102e\u1038: {value}',
    'premium.license.already_active':
        '\u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a\u1000\u102d\u102f \u1024\u1005\u1000\u103a\u1015\u1031\u102b\u103a\u1010\u103d\u1004\u103a \u1016\u103d\u1004\u1037\u103a\u1011\u102c\u1038\u1015\u103c\u102e\u1038\u1015\u102b\u101e\u100a\u103a\u104b',
    'premium.license.activated':
        'Premium \u1016\u103d\u1004\u1037\u103a\u1015\u103c\u102e\u1038\u1015\u102b\u1015\u103c\u102e\u104b',
    'overlay.studio.preview_phase':
        '\u1021\u1005\u1019\u103a\u1038\u1019\u103c\u1004\u103a\u1000\u103d\u1004\u103a\u1038 phase',
    'overlay.studio.preview_phase_subtitle':
        '\u1015\u1004\u103a\u1010\u103d\u1004\u103a\u1010\u1015\u103a\u1011\u102c\u1038\u101e\u1031\u102c preview \u1011\u1032\u1010\u103d\u1004\u103a phase control \u1019\u1011\u102c\u1038\u1018\u1032 demo state \u1000\u102d\u102f \u1015\u103c\u1031\u102c\u1004\u103a\u1038\u101c\u1032\u1014\u102d\u102f\u1004\u103a\u1015\u102b\u101e\u100a\u103a\u104b',
    'overlay.studio.master_mode': 'Master Mode',
    'overlay.studio.master_mode_subtitle':
        'export \u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u101b\u100a\u103a\u1015\u103c\u1004\u103a\u1011\u1014\u103a\u1038\u1019\u103e\u102f\u1014\u103e\u1004\u1037\u103a luxury overlay \u1021\u1015\u103c\u102f\u1021\u1019\u1030\u1000\u102d\u102f \u100a\u103e\u102d\u1014\u103e\u102d\u102f\u1004\u103a\u1015\u102b\u101e\u100a\u103a\u104b',
    'overlay.studio.performance_mode': 'Performance mode',
    'overlay.studio.apply_festival_luxe': 'Apply World Festival Luxe',
    'overlay.studio.remove_festival_luxe': 'Remove World Festival Luxe',
    'overlay.studio.text_branding': 'စာသားနှင့် Branding',
    'overlay.studio.text_branding_subtitle':
        'luxury အမည်, subtitle tone နှင့် signature line ကိုပြင်နိုင်သည်။',
    'overlay.studio.show_branding_bar': 'branding bar ပြ',
    'overlay.studio.show_branding_bar_subtitle':
        'အပေါ်ဘက် logo နှင့် text bar ကို ဖွင့်/ပိတ်လုပ်ပါ။',
    'overlay.studio.title_field': 'Title',
    'overlay.studio.subtitle_field': 'Subtitle',
    'overlay.studio.branding_field': 'Branding',
    'overlay.studio.banner_border': 'Banner Border',
    'overlay.studio.banner_border_subtitle':
        'TikTok ပုံစံ အရောင်စုံ gradient border',
    'overlay.studio.narrative_flow': 'Narrative Flow',
    'overlay.studio.narrative_flow_subtitle':
        'ဤစာသား ၄ ခုသည် post-process တွင်သာပေါ်မည်။ စာသားတစ်ခုစီအတွက် rep နံပါတ်သတ်မှတ်နိုင်ပြီး အဲဒီ rep သည် 80% accuracy ရောက်မှ ပေါ်မည်။',
    'overlay.studio.cue_label': 'Cue {number}',
    'overlay.studio.icon_system': 'Icon System',
    'overlay.studio.icon_system_subtitle':
        'phase တစ်ခုချင်းစီအတွက် SVG icon များထည့်နိုင်သည်။ အဖြူနောက်ခံနှင့် အကန့်အသတ်မရှင်းသည့်ဘောင်များကို သန့်စင်ပေးပြီး export ကို ပိုသေသပ်စေပါသည်။',
    'overlay.studio.default_slot': 'Default',
    'overlay.studio.up_phase': 'UP phase',
    'overlay.studio.down_phase': 'DOWN phase',
    'overlay.studio.color_system': 'Color System',
    'overlay.studio.color_system_subtitle':
        'အဓိကအရောင်, metallic accent နှင့် phase-specific အရောင်များကို ထိန်းချုပ်နိုင်သည်။',
    'overlay.studio.primary_color': 'Primary',
    'overlay.studio.secondary_color': 'Secondary',
    'overlay.studio.accent_color': 'Accent',
    'overlay.studio.layout_control': 'Layout Control',
    'overlay.studio.layout_control_subtitle':
        'accuracy နှင့် rep cluster နေရာကိုပြောင်းနိုင်ပြီး branding bar ကို တည်ငြိမ်စွာထားကာ overall scale ကိုညှိနိုင်သည်။',
    'overlay.studio.counter_cluster': 'Counter cluster',
    'overlay.studio.stats_card_slot': 'Stats card slot',
    'overlay.studio.global_scale': 'Global scale',
    'overlay.studio.overlay_opacity': 'Overlay opacity',
    'overlay.studio.luxe_finish': 'Luxe Finish',
    'overlay.studio.luxe_finish_subtitle':
        'လက်ရှိ theme system ကိုမပြောင်းဘဲ premium atmosphere ထပ်ထည့်ပါ။',
    'overlay.studio.vignette_focus': 'Vignette focus',
    'overlay.studio.bloom_glow': 'Bloom glow',
    'overlay.studio.sparkle_field': 'Sparkle field',
    'overlay.studio.sheen_sweep': 'Sheen sweep',
    'overlay.studio.border_width': 'Border width',
    'overlay.studio.rotation': 'Rotation',
    'overlay.studio.colors': 'Colors ({count})',
    'overlay.studio.presets': 'Presets',
    'overlay.studio.svg_import_failed':
        'SVG import မအောင်မြင်ပါ: {error}',
    'overlay.studio.no_svg_selected':
        'SVG မရွေးထားရသေးပါ',
    'overlay.studio.svg_description_selected':
        'Export တွင် ဤ sanitized SVG ကို သုံးပါမည်။ အဖြူနောက်ခံနှင့် မညီညာသည့် bounds များကို အလိုအလျောက် သန့်စင်ပါသည်။',
    'overlay.studio.svg_description_empty':
        'SVG ဖိုင်သာရသည်။ ဖိုင်ရွေးပါ, export badge များ ပိုသန့်ရှင်းစေရန် sanitize လုပ်ပေးပါမည်။',
    'overlay.studio.fallback_badge': 'Fallback badge: {glyph}',
    'overlay.studio.importing': 'Import လုပ်နေသည်...',
    'overlay.studio.replace_svg': 'SVG အစားထိုး',
    'overlay.studio.choose_svg': 'SVG ရွေးပါ',
    'overlay.studio.supported_input':
        'လက်ခံသော input: `.svg` ဖိုင်များသာ။',
    'recordings.player_title': 'Workout Recording',
    'analytics.no_data_available': 'ဒေတာမရှိသေးပါ',
    'analytics.chart.date': 'နေ့စွဲ',
    'analytics.chart.accuracy_percent': 'တိကျမှု (%)',
    'analytics.chart.repetitions': 'အကြိမ်ရေ',
    'analytics.title': 'အသေးစိတ် Analytics',
    'analytics.performance_summary': 'စွမ်းဆောင်ရည် အကျဉ်းချုပ်',
    'analytics.consistency': 'တည်ငြိမ်မှု',
    'analytics.improvement': 'တိုးတက်မှု',
    'analytics.peak': 'အမြင့်ဆုံး',
    'exercise.recording.exporting_video':
        'ဗီဒီယို export လုပ်နေသည်',
    'exercise.recording.applying_overlay_effects':
        'သင်ရွေးထားသော overlay effect များကို အသုံးပြုနေသည်...',
    'exercise.recording.saved_raw_fallback':
        'ဗီဒီယိုသိမ်းပြီးပါပြီ။ overlay export မရသဖြင့် raw recording ကိုအသုံးပြုထားသည်။',
    'exercise.recording.saved_without_overlay':
        'post-process overlay မပါဘဲ ဗီဒီယိုသိမ်းပြီးပါပြီ: {error}',
    'premium.badge': '\u1015\u101b\u102e\u1019\u102e\u101a\u1019\u103a',
    'premium.menu_only': '\u1024\u1019\u102e\u1014\u1030\u1038\u1000\u102d\u102f \u1015\u101b\u102e\u1019\u102e\u101a\u1019\u103a\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u1030\u1019\u103b\u102c\u1038\u101e\u102c \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b',
    'home.exercises_list': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1005\u102c\u101b\u1004\u103a\u1038',
    'home.exercises_simple_form': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1015\u102f\u1036\u1005\u1036',
    'home.no_supported_exercises': '\u1011\u1031\u102c\u1000\u103a\u1015\u1036\u1037\u1011\u102c\u1038\u101e\u1031\u102c \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1019\u103b\u102c\u1038 \u1019\u101b\u103e\u102d\u1015\u102b',
    'home.check_exercise_config': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038 \u1006\u1000\u103a\u1010\u1004\u103a\u1000\u102d\u102f \u1005\u1005\u103a\u1006\u1031\u1038\u1015\u102b',
    'home.error_loading_exercise':
        '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1000\u102d\u102f \u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u101b\u102c\u1010\u103d\u1004\u103a \u1021\u1019\u103e\u102c\u1038: {error}',
    'home.image_reference_count': '\u1015\u102f\u1036\u100a\u103d\u103e\u1014\u103a\u1038 {count} \u1015\u102f\u1036',
    'home.today_progress_premium': '\u1012\u102e\u1014\u1031\u1037 \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f (Premium)',
    'home.today_progress_locked_desc':
        '\u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f \u1019\u102e\u1014\u1030\u1038\u1012\u1031\u1010\u102c\u1019\u103b\u102c\u1038\u1000\u102d\u102f Premium \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u1030\u1019\u103b\u102c\u1038\u101e\u102c \u101b\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b',
    'home.today_progress': '\u1012\u102e\u1014\u1031\u1037 \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f',
    'home.total_reps': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1021\u1001\u103b\u1000\u103a\u101b\u1031',
    'home.workouts': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f\u1019\u103b\u102c\u1038',
    'home.calories': '\u1000\u101a\u103a\u101c\u102d\u102f\u101b\u102e',
    'home.daily_goal': '\u1014\u1031\u1037\u1005\u1009\u103a\u101b\u100a\u103a\u1019\u103e\u1014\u103a\u1038\u1001\u103b\u1000\u103a: {current}/{goal}',
    'home.daily_goal_achieved': '\u1014\u1031\u1037\u1005\u1009\u103a\u101b\u100a\u103a\u1019\u103e\u1014\u103a\u1038\u1001\u103b\u1000\u103a \u1015\u103c\u100a\u1037\u103a\u1015\u103c\u102e\u1038!',
    'home.progress_premium_title': '\u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u101e\u100a\u103a Premium \u1010\u103d\u1004\u103a\u101e\u102c\u101b\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a.',
    'home.progress_premium_message':
        '\u1021\u101e\u1031\u1038\u1005\u102d\u1010\u103a\u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1005\u102c\u101b\u1004\u103a\u1038\u1019\u103b\u102c\u1038\u1000\u102d\u102f Premium \u1010\u103d\u1004\u103a\u101e\u102c \u101b\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b',
    'home.recordings_premium_title': 'Recording \u101e\u100a\u103a Premium\u1010\u103d\u1004\u103a\u101e\u102c\u101b\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a.',
    'home.recordings_premium_message':
        '\u1017\u102e\u1012\u102e\u101a\u102d\u102f\u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u101e\u1019\u102d\u102f\u1004\u103a\u1038\u1000\u102d\u102f Premium \u1010\u103d\u1004\u103a\u101e\u102c \u101b\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b',
    'home.simple_form': '{name} \u1015\u102f\u1036\u1005\u1036',
    'home.quick_form_summary': '\u1015\u102f\u1036\u1005\u1036 \u1021\u1000\u103b\u1009\u103a\u1038\u1001\u103b\u102f\u1015\u103a',
    'home.form_images': '\u1015\u102f\u1036\u1005\u1036\u1015\u102f\u1036\u1019\u103b\u102c\u1038',
    'home.exercise_list_notice_title': '\u1021\u1019\u103c\u1014\u103a\u101e\u1010\u102d\u1015\u1031\u1038\u1001\u103b\u1000\u103a',
    'home.exercise_list_notice_message':
        '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1015\u102f\u1036\u1005\u1036\u1010\u102d\u102f\u1004\u103a\u1038\u1010\u103d\u1004\u103a \u101e\u1010\u102d\u1015\u103c\u102f\u1001\u103b\u1000\u103a\u1019\u103b\u102c\u1038 \u101b\u103e\u102d\u1014\u102d\u102f\u1004\u103a\u1010\u102c\u1000\u103c\u1031\u102c\u1004\u1037\u103a \u101e\u1031\u1001\u103b\u102c\u1005\u1005\u103a\u1006\u1031\u1038\u1015\u102b\u104b Note- situp exercise \u1019\u103e\u102c \u1021\u101b\u1031\u1038\u1000\u103c\u102e\u1038\u1010\u1032\u1037 \u101e\u1010\u102d\u1015\u103c\u102f\u1001\u103b\u1000\u103a\u101b\u103e\u102d\u1015\u102b\u1010\u101a\u103a\u104b',
    'home.simple_form_notice':
        '\u1010\u102d\u1000\u103b\u1019\u103e\u102f\u1018\u102c\u1038\u1014\u103e\u1004\u1037\u103a \u1000\u1031\u102c\u1004\u1037\u103a\u101b\u1031\u1010\u103d\u1000\u103a\u1019\u103e\u102f \u101e\u1010\u102d\u1015\u1031\u1038\u1001\u103b\u1000\u103a:\n\u1000\u103b\u103d\u1014\u103a\u102f\u1015\u103a\u1010\u102d\u102f\u1037 AI \u101e\u100a\u103a \u101c\u1019\u103a\u1038\u100a\u103d\u103e\u1014\u103a\u1015\u102f\u1036\u1019\u103b\u102c\u1038\u1014\u103e\u1004\u1037\u103a \u1000\u102d\u102f\u1000\u103a\u100a\u102e\u101e\u1031\u102c \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u1019\u103e\u1010\u103a\u1019\u102d\u101b\u1014\u103a \u1012\u102e\u1007\u102d\u102f\u1004\u103a\u1038\u1011\u102c\u1038\u101e\u100a\u103a\u104b \u1000\u1031\u102c\u1004\u1037\u103a\u101b\u1031\u1010\u103d\u1000\u103a\u1019\u103e\u102f \u1001\u103b\u1031\u102c\u1019\u103d\u1031\u1037\u1015\u103c\u102e\u1038 \u1010\u102d\u1000\u103b\u1019\u103e\u102f\u1000\u1031\u102c\u1004\u103a\u1038\u101e\u1031\u102c\u103a\u101c\u100a\u103a\u1038 \u1014\u100a\u103a\u1038\u1015\u100a\u102c\u1015\u102d\u102f\u1004\u103a\u1038 \u1000\u102d\u102f\u1001\u103b\u103a\u1021\u1016\u103c\u1005\u103a \u1019\u101f\u102f\u1010\u103a\u1015\u102b\u104b \u1021\u1000\u103a\u1015\u103a\u104f \u1010\u102d\u1000\u103b\u1019\u103e\u102f\u101e\u100a\u103a 100% \u1019\u101f\u102f\u1010\u103a\u1000\u103c\u1031\u102c\u1004\u103a\u1038\u101c\u100a\u103a\u1038 \u1019\u103e\u1010\u103a\u101e\u102c\u1038\u1015\u102b\u104b\n\nSide view \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1019\u103b\u102c\u1038\u1021\u1010\u103d\u1000\u103a \u1018\u1031\u1038\u1018\u1000\u103a\u1021\u1014\u1031\u1021\u1011\u102c\u1038\u1000\u102d\u102f \u1011\u102d\u1014\u103a\u1038\u1011\u102c\u1038\u1015\u102b\u104a Front view \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1019\u103b\u102c\u1038\u1021\u1010\u103d\u1000\u103a \u1021\u101b\u103e\u1031\u1037\u1018\u1000\u103a\u1021\u1014\u1031\u1021\u1011\u102c\u1038\u1000\u102d\u102f \u1011\u102d\u1014\u103a\u1038\u1011\u102c\u1038\u1015\u102b\u104b \u1021\u1032\u1012\u102e\u101c\u102d\u102f \u101c\u102f\u1015\u103a\u101c\u103b\u103e\u1004\u103a \u101b\u101c\u1012\u103a\u1019\u103e\u1014\u103a\u1000\u1014\u103a\u1015\u102b\u101c\u102d\u1019\u1037\u103a\u1019\u100a\u103a\u104b\n\n\u1021\u1031\u102c\u1000\u103a\u1015\u102b\u1021\u1001\u103c\u1031\u1021\u1014\u1031\u1019\u103b\u102c\u1038\u1010\u103d\u1004\u103a \u1010\u102d\u1000\u103b\u1019\u103e\u102f \u1019\u1016\u103c\u1005\u103a\u1014\u102d\u102f\u1004\u103a\u1015\u102b:\n\u2022 \u1001\u1014\u1039\u1013\u102c\u1000\u102d\u102f\u101a\u103a\u1010\u1005\u103a\u1001\u102f\u101c\u102f\u1036\u1038 \u1000\u1004\u103a\u1019\u101b\u102c\u1021\u1010\u103d\u1004\u103a\u1038 \u1019\u1015\u102b\u101d\u1004\u103a\u1015\u102b\u1000\n\u2022 \u1000\u1004\u103a\u1019\u101b\u102c\u1011\u1032\u1019\u103e\u102c \u101c\u1030\u1010\u1005\u103a\u101a\u1031\u102c\u1000\u103a\u1011\u1000\u103a\u1015\u102d\u102f\u101b\u103e\u102d\u1014\u1031\u1015\u102b\u1000\u104b\n\u2022 \u1021\u1001\u1014\u103a\u1038\u1021\u101c\u1004\u103a\u1038\u1019\u1019\u103e\u1014\u103a\u1000\u1014\u103a\u1001\u103c\u1004\u103a\u1038 \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u1015\u103c\u1004\u103a\u1038\u1011\u1014\u103a\u1010\u1032\u1037 \u1021\u101c\u1004\u103a\u1038\u1015\u103c\u1014\u103a\u1019\u103e\u102f/\u1019\u102e\u1038\u1010\u1031\u102c\u1000\u103a\u101b\u103e\u102d\u1015\u102b\u1000\n\u2022 \u1000\u1004\u103a\u1019\u101b\u102c\u1000\u102d\u102f \u1000\u102d\u102f\u101a\u103a\u1001\u1014\u1039\u1013\u102c\u1011\u1000\u103a \u1021\u101b\u1019\u103a\u1038\u101c\u100a\u103a\u1038\u1014\u102d\u1019\u1037\u103a\u104a \u1021\u101b\u1019\u103a\u1038\u101c\u100a\u103a\u1038\u1019\u1019\u103c\u1004\u1037\u103a\u101e\u1031\u102c \u1021\u1014\u1031\u1021\u1011\u102c\u1038\u1010\u103d\u1004\u103a\u1011\u102c\u1038\u1015\u102b\u104b',
    'exercise.guide.title': '\u1021\u1019\u103c\u1014\u103a\u101c\u1019\u103a\u1038\u100a\u103d\u103e\u1014\u103a',
    'exercise.guide.step1':
        'Landmark \u1016\u1014\u103a\u1010\u102e\u1038\u101c\u102d\u102f\u101c\u103b\u103e\u1004\u103a skeleton \u1001\u101c\u102f\u1010\u103a\u1000\u102d\u102f \u1014\u103e\u102d\u1015\u103a\u1015\u102b\u104b',
    'exercise.guide.step2':
        '\u1017\u102e\u1012\u102e\u101a\u102d\u102f\u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u101c\u102f\u1015\u103a\u101c\u102d\u102f\u101c\u103b\u103e\u1004\u103a record \u1001\u101c\u102f\u1010\u103a\u1000\u102d\u102f \u1014\u103e\u102d\u1015\u103a\u1015\u102b\u104b',
    'exercise.guide.step3':
        'Recording \u1000\u102d\u102f\u101b\u1015\u103a\u1015\u103c\u102e\u1038 \u101e\u102d\u1019\u103a\u1038\u101c\u102d\u102f\u101c\u103b\u103e\u1004\u103a \u1005\u1000\u101b\u1004\u103a\u1000\u102d\u102f double tap \u101c\u102f\u1015\u103a\u1015\u102b \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a back \u1001\u101c\u102f\u1010\u103a\u1000\u102d\u102f \u1014\u103e\u102d\u1015\u103a\u1015\u102b\u104b',
    'exercise.guide.step4':
        '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1015\u103c\u102e\u1038\u1015\u102b\u1000 complete \u1001\u101c\u102f\u1010\u103a\u1000\u102d\u102f \u1014\u103e\u102d\u1015\u103a\u1015\u103c\u102e\u1038 Save \u1001\u101c\u102f\u1010\u103a\u1000\u102d\u102f \u1011\u1015\u103a\u1014\u103e\u102d\u1015\u103a\u104d \u101e\u102d\u1019\u103a\u1038\u1015\u102b\u104b',
    'exercise.error.setup_title': '\u1005\u1010\u1004\u103a\u1019\u103e\u102f \u1021\u1019\u103e\u102c\u1038',
    'exercise.error.setup_message': '\u1005\u1010\u1004\u103a\u101b\u1014\u103a \u1019\u1021\u1031\u102c\u1004\u103a\u1019\u103c\u1004\u103a\u1015\u102b: {error}',
    'exercise.error.pose_title': 'Pose Detection \u1021\u1019\u103e\u102c\u1038',
    'exercise.error.pose_message':
        'Pose detection service \u1019\u101b\u1015\u102b\u1000 Google Play Services \u1000\u102d\u102f \u1014\u1031\u102c\u1000\u103a\u1006\u102f\u1036\u1038\u1017\u102c\u1038\u101b\u103e\u1004\u103a\u1038\u1016\u103c\u1005\u103a\u1019\u1016\u103c\u1005\u103a \u1005\u1005\u103a\u1006\u1031\u1038\u1015\u102b\u104b',
    'exercise.premium.landmarks':
        'Landmark overlay \u101e\u100a\u103a Premium \u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u1001\u103b\u1000\u103a \u1016\u103c\u1005\u103a\u101e\u100a\u103a\u104b',
    'exercise.premium.recording':
        '\u1017\u102e\u1012\u102e\u101a\u102d\u102f Recording \u1000\u102d\u102f Premium \u1019\u103b\u102c\u1038\u1010\u103d\u1004\u103a\u101e\u102c \u101b\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b Upgrade \u101c\u102f\u1015\u103a\u1015\u102b\u104b',
    'exercise.recording.failed_start': '\u1005\u1000\u101b\u1004\u103a Recording \u1019\u1005\u1010\u1004\u103a\u1014\u102d\u102f\u1004\u103a\u1015\u102b: {error}',
    'exercise.recording.permission_denied':
        '\u1005\u1000\u101b\u1004\u103a/\u1021\u101e\u1036 Recording \u1001\u103d\u1004\u1037\u103a\u1015\u103c\u102f\u1001\u103b\u1000\u103a \u1004\u103c\u1004\u103a\u1038\u1015\u101a\u103a\u1011\u102c\u1038\u101e\u100a\u103a',
    'exercise.recording.failed_save': '\u1005\u1000\u101b\u1004\u103a Recording \u1000\u102d\u102f \u1019\u101e\u102d\u1019\u103a\u1038\u1014\u102d\u102f\u1004\u103a\u1015\u102b',
    'exercise.recording.saved_gallery': 'Gallery \u1010\u103d\u1004\u103a \u101e\u102d\u1019\u103a\u1038\u1015\u103c\u102e\u1038 ({album})',
    'exercise.recording.saved_app': 'App storage \u1010\u103d\u1004\u103a \u101e\u102d\u1019\u103a\u1038\u1015\u103c\u102e\u1038: {path}',
    'exercise.recording.saved_phone': '\u1016\u102f\u1014\u103a\u1038\u101e\u102d\u102f\u101c\u103e\u1031\u102c\u1004\u103a\u1019\u103e\u102f\u1010\u103d\u1004\u103a \u1017\u102e\u1012\u102e\u101a\u102d\u102f \u101e\u102d\u1019\u103a\u1038\u1015\u103c\u102e\u1038',
    'exercise.recording.failed_video':
        '\u1017\u102e\u1012\u102e\u101a\u102d\u102f Recording \u1019\u1021\u1031\u102c\u1004\u103a\u1019\u103c\u1004\u103a\u1015\u102b: {error}',
    'exercise.recording.preparing_luxury_video':
        '\u101e\u1004\u1037\u103a\u1021\u1010\u103d\u1000\u103a luxury workout video \u1000\u102d\u102f \u1015\u103c\u1004\u103a\u1006\u1004\u103a\u1014\u1031\u1015\u102b\u1010\u101a\u103a\u104b',
    'exercise.recording.keep_screen_open':
        '\u1000\u103b\u1031\u1038\u1007\u1030\u1038\u1015\u103c\u102f\u104d \u1012\u102e screen \u1000\u102d\u102f \u1001\u100f\u1016\u103d\u1004\u1037\u103a\u1011\u102c\u1038\u1015\u1031\u1038\u1015\u102b\u104b',
    'exercise.premium.title': 'Premium \u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u1001\u103b\u1000\u103a',
    'exercise.premium.not_now': '\u1019\u101f\u102f\u1010\u103a\u101e\u1031\u1038',
    'exercise.premium.upgrade': 'Upgrade',
    'exercise.premium.required_title': 'Premium \u101c\u102d\u102f\u1021\u1015\u103a\u101e\u100a\u103a',
    'exercise.premium.required_message':
        '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f \u101e\u102d\u1019\u103a\u1038\u1006\u100a\u103a\u1038\u1001\u103c\u1004\u103a\u1038\u104a \u1000\u1031\u102c\u1004\u1037\u103a\u101b\u1031\u1010\u103d\u1000\u103a\u1001\u103c\u1004\u103a\u1038\u1014\u103e\u1004\u1037\u103a \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1000\u102d\u102f Premium \u1010\u103d\u1004\u103a\u101e\u102c \u101b\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b',
    'exercise.camera.error_title': '\u1000\u1004\u103a\u1019\u101b\u102c \u1021\u1019\u103e\u102c\u1038',
    'exercise.camera.error_message':
        '\u1000\u1004\u103a\u1019\u101b\u102c\u1000\u102d\u102f \u1005\u1010\u1004\u103a\u1019\u101b\u1015\u102b\u104b \u1001\u103d\u1004\u1037\u103a\u1015\u103c\u102f\u1001\u103b\u1000\u103a \u1005\u1005\u103a\u1015\u103c\u102e\u1038 \u1015\u103c\u1014\u103a\u1000\u103c\u102d\u102f\u1038\u1005\u102c\u1038\u1015\u102b\u104b',
    'exercise.counting_premium': '\u1000\u1031\u102c\u1004\u1037\u103a (Premium)',
    'exercise.summary.title': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f \u1015\u103c\u102e\u1038\u1006\u102f\u1036\u1038\u1015\u103c\u102e!',
    'exercise.summary.total_reps': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1021\u1001\u103b\u1000\u103a\u101b\u1031 \u1005\u102f\u1005\u102f\u1015\u1031\u102b\u1004\u103a\u1038',
    'exercise.summary.avg_accuracy': '\u1015\u103b\u1019\u103a\u1038\u1019\u103b\u103e \u1010\u102d\u1000\u103b\u1019\u103e\u102f',
    'exercise.summary.duration': '\u1000\u103c\u102c\u1001\u103b\u102d\u1014\u103a',
    'exercise.summary.seconds': '{value} \u1005\u1000\u1039\u1000\u1014\u1037\u103a',
    'exercise.summary.best_accuracy': '\u1021\u1000\u1031\u102c\u1004\u103a\u1038\u1006\u102f\u1036\u1038 \u1010\u102d\u1000\u103b\u1019\u103e\u102f',
    'exercise.summary.close': '\u1015\u102d\u1010\u103a',
    'exercise.summary.view_details': '\u101e\u102d\u1019\u103a\u1038\u1019\u101a\u103a',
    'exercise.card.type.dynamic': 'Dynamic',
    'exercise.card.type.static': 'Static',
    'exercise.card.view.front': '\u101b\u103e\u1031\u1037\u1019\u103c\u1004\u103a\u1000\u103d\u1004\u103a\u1038',
    'exercise.card.view.side': '\u1018\u1031\u1038\u1019\u103c\u1004\u103a\u1000\u103d\u1004\u103a\u1038',
    'exercise.card.total_reps': '\u1005\u102f\u1005\u102f\u1015\u1031\u102b\u1004\u103a\u1038 \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1021\u1001\u103b\u1000\u103a\u101b\u1031',
    'exercise.card.avg_accuracy': '\u1015\u103b\u1019\u103a\u1038\u1019\u103b\u103e \u1010\u102d\u1000\u103b\u1019\u103e\u102f',
    'exercise.card.select': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u101b\u103d\u1031\u1038\u1015\u102b',
    'exercise.time.today': '\u101a\u1014\u1031\u1037',
    'exercise.time.yesterday': '\u1019\u1014\u1031\u1037\u1000',
    'exercise.time.days_ago': '{value} \u101b\u1000\u103a\u1021\u101b\u1004\u103a',
    'exercise.time.weeks_ago': '{value} \u1015\u1010\u103a\u1021\u101b\u1004\u103a',
    'exercise.time.months_ago': '{value} \u101c\u1021\u101b\u1004\u103a',
    'guide.squat.subtitle':
        '\u101b\u1004\u103a\u1001\u103d\u1004\u103a\u1000\u102d\u102f \u1011\u1031\u102c\u1004\u103a\u1011\u102c\u1038\u1015\u103c\u102e\u1038 \u1010\u1004\u103a\u1015\u102b\u1038\u1014\u1031\u102c\u1000\u103a\u1016\u1000\u103a\u101b\u103d\u103e\u1031\u1037\u1000\u102c \u1019\u102d\u102f\u1000\u103a\u1001\u102f\u1036\u1038\u1000\u102d\u102f \u1001\u103c\u1031\u1016\u103b\u102c\u1038\u1021\u1031\u102c\u1000\u103a\u1015\u1031\u102b\u103a\u1010\u1014\u103a\u1038\u1010\u100a\u103a\u1011\u102c\u1038\u1015\u102b\u104b',
    'guide.squat.step1':
        '\u1001\u103c\u1031\u1010\u1036\u1001\u103d\u1014\u103a\u1000\u102d\u102f \u101c\u1000\u103a\u1001\u102f\u1036\u1021\u1000\u103d\u102c\u1021\u101d\u1031\u1038\u1014\u1032\u1037 \u101b\u1015\u103a\u1015\u103c\u102e\u1038 \u1021\u1005\u102c\u1001\u1014\u1039\u1013\u102c\u1000\u102d\u102f \u1010\u1004\u103a\u1038\u1011\u102c\u1038\u1015\u102b\u104b',
    'guide.squat.step2':
        '\u1001\u103c\u1031\u1001\u101c\u102f\u1010\u103a\u1000\u102d\u102f \u1019\u1019\u103c\u103e\u1031\u102c\u1000\u103a\u1015\u1032 \u1010\u1004\u103a\u1015\u102b\u1038\u1000\u102d\u102f \u1021\u1031\u102c\u1000\u103a\u101e\u102d\u102f\u1037 \u1001\u103b\u1015\u103c\u102e\u1038 \u1001\u103c\u1031\u1011\u1031\u102c\u1000\u103a\u101e\u102c\u1038\u1019\u103b\u102c\u1038 \u1021\u1005\u103d\u1014\u103a\u1038\u1021\u1014\u102c\u1038\u1014\u102e\u1038\u1015\u102b\u1038 \u1021\u1006\u1004\u1037\u103a\u1021\u1011\u102d \u1001\u103b\u1015\u102b\u104b',
    'guide.squat.step3':
        '\u1001\u103c\u1031\u1001\u101c\u102f\u1010\u103a\u1016\u103c\u1004\u1037\u103a \u1010\u103d\u1014\u103a\u1038\u104d \u1019\u102d\u102f\u1000\u103a\u1001\u102f\u1036\u1038\u1000\u102d\u102f \u101c\u1031\u102c\u1037\u1001\u103a\u1019\u101c\u102f\u1015\u103a\u1018\u1032 \u1011\u1015\u103c\u1014\u103a\u1015\u102b\u104b',
    'guide.pushup.subtitle':
        '\u1009\u102e\u1038\u1019\u103e \u1001\u103c\u1031\u1016\u103b\u102c\u1038\u1021\u1011\u102d \u1010\u1014\u103a\u1038\u1010\u1005\u103a\u1000\u103c\u1031\u102c\u1004\u103a\u1038\u101c\u102d\u102f\u1011\u102c\u1038\u1015\u103c\u102e\u1038 \u1015\u103c\u1014\u103a\u101c\u102f\u1015\u103a\u1019\u103e\u102f\u1010\u102d\u102f\u1004\u103a\u1038\u1000\u102d\u102f \u1011\u102d\u1014\u103a\u1038\u1001\u103b\u102f\u1015\u103a\u1015\u102b\u104b',
    'guide.pushup.step1':
        '\u101c\u1000\u103a\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u101c\u1000\u103a\u1001\u102f\u1036\u1011\u1000\u103a \u1021\u1014\u100a\u103a\u1038\u1004\u101a\u103a\u1000\u103b\u101a\u103a\u1005\u103d\u102c\u1011\u102c\u1038\u1015\u103c\u102e\u1038 high plank \u1014\u1032\u1037 \u1005\u1010\u1004\u103a\u1015\u102b\u104b',
    'guide.pushup.step2': '\u101c\u1000\u103a\u1001\u102f\u1036\u1000\u102d\u102f 45 \u1012\u102e\u1002\u101b\u102e\u1001\u1014\u1037\u103a \u1001\u103b\u102d\u102f\u1038\u104d \u101b\u1004\u103a\u1018\u1010\u103a\u1000\u102d\u102f \u1021\u1031\u102c\u1000\u103a\u1001\u103b\u1015\u102b\u104b',
    'guide.pushup.step3':
        '\u1021\u1005\u102c\u1001\u1014\u1039\u1013\u102c\u1000\u102d\u102f \u1010\u1004\u103a\u1038\u1011\u102c\u1038\u1015\u103c\u102e\u1038 \u1010\u1004\u103a\u1015\u102b\u1038\u1000\u102d\u102f \u1010\u1014\u103a\u1038\u1010\u100a\u103a\u1038\u1011\u102c\u1038\u1000\u102c \u1021\u1015\u1031\u102b\u103a\u101e\u102d\u102f\u1037 \u1010\u103d\u1014\u103a\u1038\u1010\u1004\u103a\u1015\u102b\u104b',
    'guide.situp.subtitle':
        '\u101c\u100a\u103a\u1015\u1004\u103a\u1038\u1000\u102d\u102f \u1019\u1006\u103d\u1032\u1018\u1032 \u1001\u1014\u1039\u1013\u102c\u1017\u101f\u102d\u102f\u1000\u102d\u102f \u1011\u102d\u1014\u103a\u1038\u1001\u103b\u102f\u1015\u103a\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u1015\u102b\u104b',
    'guide.situp.step1':
        '\u1014\u1031\u102c\u1000\u103a\u1000\u103b\u1031\u102c\u1015\u1031\u102b\u103a\u1021\u102d\u1015\u103a\u104d \u1012\u1030\u1038\u1000\u102d\u102f \u1001\u1031\u102b\u1000\u103a\u1015\u103c\u102e\u1038 \u1001\u103c\u1031\u1016\u101d\u102b\u1038\u1000\u102d\u102f \u1019\u103c\u1031\u1015\u103c\u1004\u103a\u1015\u1031\u102b\u103a\u1011\u102c\u1038\u1015\u102b\u104b',
    'guide.situp.step2':
        '\u101d\u1019\u103a\u1038\u1017\u102d\u102f\u1000\u103a\u1000\u102d\u102f \u1010\u1004\u103a\u1038\u1010\u1004\u103a\u1015\u103c\u102e\u1038 \u1000\u102d\u102f\u101a\u103a\u1001\u1014\u1039\u1013\u102c\u1000\u102d\u102f \u1021\u1015\u1031\u102b\u103a\u101e\u102d\u102f\u1037 \u1011\u1019\u103a\u1038\u1015\u102b\u104b',
    'guide.situp.step3': '\u1014\u1031\u102c\u1000\u103a\u1006\u102f\u1036\u1038\u1015\u103c\u1014\u103a\u1001\u103b\u1015\u103c\u102e\u1038 \u1014\u1031\u102c\u1000\u103a\u1010\u1005\u103a\u1000\u103c\u102d\u1019\u103a\u1021\u1010\u103d\u1000\u103a \u1011\u102d\u1014\u103a\u1038\u1001\u103b\u102f\u1015\u103a\u1015\u102b\u104b',
    'guide.bicep.subtitle':
        '\u1010\u1036\u1010\u1031\u102c\u1004\u103a\u1000\u102d\u102f \u1000\u102d\u102f\u101a\u103a\u1014\u102c\u1038\u1019\u103e\u102c\u1011\u102c\u1038\u1015\u103c\u102e\u1038 \u101c\u103e\u102f\u1015\u103a\u101a\u1019\u103a\u1038\u1001\u103c\u1004\u103a\u1038\u1000\u102d\u102f \u101b\u103e\u1031\u102c\u1004\u103a\u1015\u102b\u104b',
    'guide.bicep.step1':
        '\u1012\u1019\u103a\u1018\u1032\u101c\u103a\u1000\u102d\u102f \u1000\u102d\u102f\u1004\u103a\u1015\u103c\u102e\u1038 \u101c\u1000\u103a\u1016\u101d\u102b\u1038\u1000\u102d\u102f \u101b\u103e\u1031\u1037\u101e\u102d\u102f\u1037 \u1019\u103b\u1000\u103a\u1014\u103e\u102c\u1019\u1030\u1000\u102c \u101b\u1015\u103a\u1015\u102b\u104b',
    'guide.bicep.step2': '\u1015\u1001\u102f\u1036\u1038\u1019\u101c\u103e\u102f\u1015\u103a\u1018\u1032 \u1010\u1036\u1010\u1031\u102c\u1004\u103a\u1001\u103b\u102d\u102f\u1038\u104d \u1021\u101c\u1031\u1038\u1001\u103b\u102d\u1014\u103a\u1000\u102d\u102f \u1019\u103c\u103e\u1031\u102c\u1000\u103a\u1015\u102b\u104b',
    'guide.bicep.step3': '\u1021\u101c\u1031\u1038\u1001\u103b\u102d\u1014\u103a\u1000\u102d\u102f \u1021\u1015\u103c\u100a\u1037\u103a\u1010\u1014\u103a\u1021\u1031\u102c\u1004\u103a \u1010\u1016\u103c\u100a\u103a\u1038\u1016\u103c\u100a\u103a\u1038 \u1015\u103c\u1014\u103a\u1001\u103b\u1015\u102b\u104b',
    'guide.shoulder.subtitle':
        '\u1021\u1030\u1001\u1031\u102b\u1004\u103a\u1038\u1000\u102d\u102f \u1001\u103b\u1011\u102c\u1038\u1015\u103c\u102e\u1038 \u1001\u1014\u1039\u1013\u102c\u1017\u101f\u102d\u102f\u1000\u102d\u102f \u1010\u1004\u103a\u1038\u1011\u102c\u1038\u1000\u102c \u1021\u1015\u1031\u102b\u103a\u101e\u102d\u102f\u1037 \u1010\u1014\u103a\u1038\u1010\u1014\u103a\u1038\u1010\u1004\u103a\u1015\u102b\u104b',
    'guide.shoulder.step1': '\u1015\u1001\u102f\u1036\u1038\u1021\u1019\u103c\u1004\u1037\u103a\u1019\u103e\u102c \u1005\u1010\u1004\u103a\u1015\u103c\u102e\u1038 \u101c\u1000\u103a\u1019\u1031\u102c\u1004\u103a\u1038\u1000\u102d\u102f \u1010\u1014\u103a\u1038\u1011\u102c\u1038\u1015\u102b\u104b',
    'guide.shoulder.step2': '\u1001\u1031\u102b\u1004\u103a\u1038\u1021\u1015\u1031\u102b\u103a\u101e\u102d\u102f\u1037 \u101c\u1000\u103a\u1019\u103b\u102c\u1038\u1010\u1014\u103a\u1038\u1010\u1014\u103a\u1038\u1010\u1004\u103a\u1015\u102b\u104b',
    'guide.shoulder.step3': '\u1015\u1001\u102f\u1036\u1038\u1021\u1019\u103c\u1004\u1037\u103a\u101e\u102d\u102f\u1037 \u1011\u102d\u1014\u103a\u1038\u1001\u103b\u102f\u1015\u103a\u1000\u102c \u1015\u103c\u1014\u103a\u1001\u103b\u1015\u102b\u104b',
    'guide.leg.subtitle':
        '\u101c\u103e\u102f\u1015\u103a\u101b\u103e\u102c\u1038\u1019\u103e\u102f\u1021\u1000\u103d\u102c\u1021\u101d\u1031\u1038\u1000\u102d\u102f \u1011\u102d\u1014\u103a\u1038\u1001\u103b\u102f\u1015\u103a\u1015\u103c\u102e\u1038 \u1012\u1030\u1038\u1000\u102d\u102f \u1010\u1004\u103a\u1038\u1010\u102d\u1010\u103a\u1019\u101c\u102f\u1015\u103a\u1015\u102b\u1014\u103e\u1004\u1037\u103a\u104b',
    'guide.leg.step1':
        '\u1000\u103b\u1031\u102c\u1000\u102d\u102f \u1011\u1031\u102c\u1000\u103a\u1011\u102c\u1038\u1015\u103c\u102e\u1038 \u1001\u103c\u1031\u1011\u1031\u102c\u1000\u103a\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u1015\u1010\u103a\u1011\u102d\u102f\u1038\u1000\u1030\u100a\u102e\u1019\u103e\u102f\u1021\u1031\u102c\u1000\u103a\u1019\u103e\u102c \u1011\u102c\u1038\u1015\u102b\u104b',
    'guide.leg.step2':
        '\u1010\u1004\u103a\u1015\u102b\u1038\u1000\u102d\u102f \u1010\u100a\u103a\u1004\u103c\u102d\u1019\u103a\u1011\u102c\u1038\u1000\u102c \u1012\u1030\u1038\u1000\u102d\u102f \u1010\u102d\u102f\u1038\u1001\u103b\u104d \u1015\u1010\u103a\u1011\u102d\u102f\u1038\u1000\u1030\u100a\u102e\u1019\u103e\u102f\u1000\u102d\u102f \u1019\u103c\u103e\u1031\u102c\u1000\u103a\u1015\u102b\u104b',
    'guide.leg.step3':
        '\u1012\u1030\u1038\u1000\u102d\u102f \u1001\u1031\u102b\u1000\u103a\u1015\u103c\u102e\u1038 \u1010\u1016\u103c\u100a\u103a\u1038\u1016\u103c\u100a\u103a\u1038 \u1015\u103c\u1014\u103a\u1001\u103b\u1015\u102b\u104a \u1011\u102d\u102f\u1037\u1014\u1031\u102c\u1000\u103a \u1015\u103c\u1014\u103a\u101c\u102f\u1015\u103a\u1015\u102b\u104b',
    'settings.title': '\u1006\u1000\u103a\u1010\u1004\u103a',
    'settings.premium_features': 'Premium \u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u1001\u103b\u1000\u103a\u1019\u103b\u102c\u1038',
    'settings.app_settings': '\u1021\u1000\u103a\u1015\u103a\u1006\u1000\u103a\u1010\u1004\u103a',
    'settings.profile_name': '\u1015\u101b\u102d\u102f\u1016\u102d\u102f\u1004\u103a \u1014\u102c\u1019\u100a\u103a',
    'settings.appearance': '\u1015\u102f\u1036\u1015\u1014\u103a\u1038\u101e\u100f\u1039\u100c\u102c\u1014\u103a',
    'settings.data': '\u1012\u1031\u1010\u102c',
    'settings.about': '\u1021\u1000\u103c\u1031\u102c\u1004\u103a\u1038',
    'settings.premium_account': 'Premium \u1021\u1000\u1031\u102c\u1004\u1037\u103a',
    'settings.unlock_all_features': 'Premium \u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u1001\u103b\u1000\u103a\u1019\u103b\u102c\u1038\u1021\u102c\u1038\u101c\u102f\u1036\u1038 \u1016\u103d\u1004\u1037\u103a\u1015\u102b',
    'settings.voice_counting': '\u1021\u101e\u1036\u1016\u103c\u1004\u1037\u103a \u1000\u1031\u102c\u1004\u1037\u103a',
    'settings.speak_count': '\u1015\u103c\u1014\u103a\u101c\u102f\u1015\u103a\u1019\u103e\u102f\u1021\u1001\u102b\u1010\u102d\u102f\u1004\u103a\u1038 \u1000\u1031\u102c\u1004\u1037\u103a\u1000\u102d\u102f \u1021\u101e\u1036\u1016\u103c\u1004\u1037\u103a\u1015\u103c\u1031\u102c',
    'settings.voice_counting_language': '\u1021\u101e\u1036\u1000\u1031\u102c\u1004\u1037\u103a \u1018\u102c\u101e\u102c',
    'settings.upgrade_to_premium': 'Premium \u101e\u102d\u102f\u1037 \u1010\u1004\u103a\u1019\u103c\u103e\u1004\u1037\u103a',
    'settings.upgrade_subtitle':
        '\u1021\u101e\u1036\u1000\u1031\u102c\u1004\u1037\u103a\u104a \u1017\u102e\u1012\u102e\u101a\u102d\u102f\u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038 \u1014\u103e\u1004\u1037\u103a \u1021\u1001\u103c\u102c\u1038 \u1021\u1004\u103a\u1039\u1002\u102b\u101b\u1015\u103a\u1019\u103b\u102c\u1038 \u101b\u101a\u1030\u1015\u102b',
    'settings.voice_coach': 'Voice Coach',
    'settings.voice_feedback': '\u1021\u1001\u103b\u102d\u1014\u103a\u1014\u103e\u1004\u1037\u103a\u1010\u1015\u103c\u1031\u1038\u100a\u102e \u1021\u101e\u1036\u1016\u103b\u1031\u102c\u103a\u1016\u103c\u1031\u101b\u1031\u1038',
    'settings.show_landmarks': 'Landmarks \u1015\u103c',
    'settings.display_skeleton': 'Skeleton overlay \u1015\u103c',
    'settings.auto_recording': '\u1021\u101c\u102d\u102f\u1021\u101c\u103b\u1031\u102c\u1000\u103a Recording',
    'settings.auto_recording_subtitle':
        '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f\u1000\u102d\u102f \u1021\u101c\u102d\u102f\u1021\u101c\u103b\u1031\u102c\u1000\u103a Recording \u101c\u102f\u1015\u103a',
    'settings.theme': 'Theme',
    'settings.language': '\u1018\u102c\u101e\u102c',
    'settings.language_subtitle': '\u1021\u1000\u103a\u1015\u103a \u1018\u102c\u101e\u102c \u1015\u103c\u1031\u102c\u1004\u103a\u1038',
    'settings.clear_data': '\u1012\u1031\u1010\u102c \u1016\u103b\u1000\u103a',
    'settings.clear_data_subtitle': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f\u101e\u1019\u102d\u102f\u1004\u103a\u1038\u1021\u102c\u1038\u101c\u102f\u1036\u1038 \u1016\u103b\u1000\u103a',
    'settings.version': '\u1017\u102c\u1038\u101b\u103e\u1004\u103a\u1038',
    'settings.privacy_policy': '\u1000\u102d\u102f\u101a\u103a\u101b\u1031\u1038\u1021\u1001\u103b\u1000\u103a\u1021\u101c\u1000\u103a \u1019\u1030\u101d\u102b\u1012',
    'settings.terms': '\u101e\u102f\u1036\u1038\u1005\u103d\u1032\u1019\u103e\u102f\u1005\u100a\u103a\u1038\u1019\u103b\u1009\u103a\u1038\u1019\u103b\u102c\u1038',
    'settings.disclaimer': '\u1010\u102c\u101d\u1014\u103a\u1019\u1001\u1036\u1001\u103b\u1000\u103a',
    'legal.last_updated': '\u1014\u1031\u102c\u1000\u103a\u1006\u102f\u1036\u1038\u1015\u103c\u1004\u103a\u1006\u1004\u103a\u101e\u100a\u1037\u103a\u101b\u1000\u103a: {date}',
    'legal.privacy.content':
        '1) \u1000\u103b\u103d\u1014\u103a\u102f\u1015\u103a\u1010\u102d\u102f\u1037\u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u101e\u1031\u102c\u1012\u1031\u1010\u102c\u1019\u103b\u102c\u1038\n'
        'H&F \u101e\u100a\u103a \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u1019\u103b\u102c\u1038\u104a \u1018\u1010\u103a\u1002\u103b\u103a\u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u104a \u1021\u1000\u103a\u1015\u103a\u101b\u103d\u1031\u1038\u1001\u103b\u101a\u103a\u1019\u103e\u102f\u1019\u103b\u102c\u1038\u1014\u103e\u1004\u1037\u103a \u1010\u1005\u103a\u1001\u103b\u102d\u102f\u1037\u101e\u1031\u102c \u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u1016\u102d\u102f\u1004\u103a\u101c\u1019\u103a\u1038\u1000\u103c\u1031\u102c\u1004\u103a\u1038\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u101e\u1004\u1037\u103a\u1005\u1000\u103a\u104c \u101e\u102d\u1019\u103a\u1038\u1006\u100a\u103a\u1038\u1011\u102c\u1038\u101e\u100a\u103a\u104b\n\n'
        '2) \u1015\u101b\u102e\u1019\u102e\u101a\u1019\u103a\u1016\u103d\u1004\u1037\u103a\u101c\u103e\u1005\u103a\u1001\u103c\u1004\u103a\u1038\n'
        '\u1015\u101b\u102e\u1019\u102e\u101a\u1019\u103a\u1000\u102d\u102f \u1010\u1005\u103a\u1000\u103c\u102d\u1019\u103a\u101e\u102c\u1021\u1014\u100a\u103a\u1038\u1006\u102f\u1036\u1038 \u1021\u1004\u103a\u1010\u102c\u1014\u1000\u103a\u101c\u102d\u102f\u1021\u1015\u103a\u101e\u100a\u103a\u104b \u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u101b\u102c\u1010\u103d\u1004\u103a \u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a \u1000\u102e\u1038\u104a \u1005\u1000\u103a\u1014\u1032\u1037 \u101e\u1010\u103a\u1019\u103e\u1010\u103a\u1001\u103b\u1000\u103a hash\u104a \u1021\u1000\u103a\u1015\u103a\u1017\u102c\u1038\u101b\u103e\u1004\u103a\u1038\u1014\u1032\u1037 \u1015\u101c\u1000\u103a\u1016\u1031\u102c\u1004\u103a\u1038\u1000\u102d\u102f \u1000\u103b\u103d\u1014\u103a\u102f\u1015\u103a\u1010\u102d\u102f\u1006\u102c\u1017\u102c\u101e\u102d\u102f\u1037 \u1015\u102d\u102f\u1037\u1015\u1031\u1038\u101e\u100a\u103a\u104b \u1016\u103d\u1004\u1037\u103a\u101c\u103e\u1005\u103a\u1015\u103c\u102e\u1038\u1014\u1031\u102c\u1000\u103a \u1015\u101b\u102e\u1019\u102e\u101a\u1019\u103a\u1001\u103d\u1004\u1037\u103a\u1000\u102d\u102f \u1019\u102d\u1019\u102d\u1005\u1000\u103a\u1021\u1010\u103d\u1004\u103a\u1038\u101e\u102c\u1005\u1005\u103a\u1006\u1031\u1038\u1015\u103c\u102e\u1038 \u1021\u1031\u102c\u1037\u1016\u103a\u101c\u102d\u102f\u1004\u103a\u1038\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b\n\n'
        '3) \u1000\u1004\u103a\u1019\u101b\u102c\u104a \u1019\u102d\u102f\u1000\u103a\u1000\u101b\u102d\u102f\u1016\u102f\u1036\u1038\u104a \u101e\u102d\u102f\u101c\u103e\u1031\u102c\u1004\u103a\u1019\u103e\u102f\u1014\u103e\u1004\u1037\u103a \u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u1014\u102d\u102f\u1004\u103a\u1005\u103d\u1019\u103a\u1038\n'
        '\u1000\u1004\u103a\u1019\u101b\u102c\u1000\u102d\u102f \u1021\u1014\u1031\u1021\u1011\u102c\u1038\u1016\u1031\u102c\u103a\u1011\u102f\u1010\u103a\u101b\u1014\u103a \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u100a\u103a\u104b \u1021\u1014\u1031\u1021\u1011\u102c\u1038\u1000\u102d\u102f \u1001\u103d\u1032\u1001\u103c\u1019\u103a\u1038\u1005\u102d\u1010\u103a\u1016\u103c\u102c\u101b\u1014\u103a \u101e\u1004\u1037\u103a\u1005\u1000\u103a\u104f \u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u1014\u102d\u102f\u1004\u103a\u1005\u103d\u1019\u103a\u1038\u1000\u102d\u102f \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u100a\u103a\u104b \u1019\u102d\u102f\u1000\u103a\u1000\u101b\u102d\u102f\u1016\u102f\u1036\u1038\u1014\u1032\u1037 \u1019\u103b\u1000\u103a\u1014\u103e\u102c\u1015\u103c\u1004\u103a \u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u1001\u103d\u1004\u1037\u103a\u1015\u103c\u102f\u1001\u103b\u1000\u103a\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u1021\u1004\u103a\u1039\u1002\u102b\u101b\u1015\u103a\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u100a\u1037\u103a\u1021\u1001\u102b\u101e\u102c \u101c\u102d\u102f\u1021\u1015\u103a\u101e\u100a\u103a\u104b \u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u101e\u1031\u102c \u1017\u102e\u1012\u102e\u101a\u102d\u102f\u1019\u103b\u102c\u1038\u101e\u100a\u103a \u101e\u1004\u103a\u104f\u1005\u1000\u103a \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u1002\u101a\u103a\u101c\u101b\u102e\u104c \u1005\u102f\u1036\u101c\u1004\u103a\u1014\u1031\u1015\u102b\u101e\u100a\u103a\u104b\n\n'
        '4) \u1012\u1031\u1010\u102c\u1000\u102d\u102f \u1019\u100a\u103a\u101e\u102d\u102f\u1037 \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u1014\u100a\u103a\u1038\n'
        '\u1012\u1031\u1010\u102c\u1000\u102d\u102f \u1021\u101c\u103e\u100a\u1037\u103a\u1021\u1015\u103c\u1031\u102c\u1004\u103a\u1038\u1019\u103b\u102c\u1038\u1010\u103d\u1000\u103a\u101b\u1014\u103a\u104a \u1010\u102d\u1000\u103b\u1019\u103e\u102f\u1000\u102d\u102f\u1010\u103d\u1000\u103a\u101b\u1014\u103a\u104a \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1000\u102d\u102f \u1001\u103b\u102d\u1014\u103a\u1006\u103d\u1032\u101b\u1014\u103a\u104a \u1018\u1010\u103a\u1002\u103b\u103a\u1016\u103d\u1004\u1037\u103a\u101b\u1014\u103a\u1014\u103e\u1004\u1037\u103a \u1015\u101b\u102e\u1019\u102e\u101a\u1019\u103a\u1005\u1014\u1005\u103a\u1019\u103b\u102c\u1038\u1015\u1031\u1038\u101b\u1014\u103a \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u100a\u103a\u104b\n\n'
        '5) \u1019\u103b\u103e\u101d\u1031\u1001\u103c\u1004\u103a\u1038\n'
        '\u101e\u1004\u103a\u104f\u1000\u102d\u102f\u101a\u103a\u101b\u1031\u1038\u1000\u102d\u102f\u101a\u103a\u1010\u102c\u1012\u1031\u1010\u102c\u1000\u102d\u102f \u101b\u1031\u102c\u1004\u103a\u1038\u1001\u103b\u1001\u103c\u1004\u103a\u1038 \u1019\u101b\u103e\u102d\u1015\u102b\u104b \u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a\u1015\u103c\u1014\u103a\u101c\u100a\u103a\u1005\u1005\u103a\u1006\u1031\u1038\u1019\u103e\u102f\u1012\u1031\u1010\u102c\u1000\u102d\u102f \u1015\u101b\u102e\u1019\u102e\u101a\u1019\u103a\u101b\u101a\u1030\u1001\u103c\u1004\u103a\u1038\u1014\u103e\u1004\u1037\u103a \u1000\u102c\u1000\u103d\u101a\u103a\u101b\u1014\u103a\u101e\u102c \u1015\u103c\u102f\u101c\u102f\u1015\u103a\u101e\u100a\u103a\u104b\n\n'
        '6) \u101e\u1004\u103a\u104f\u1011\u102d\u1014\u103a\u1038\u1001\u103b\u102f\u1015\u103a\u1019\u103e\u102f\n'
        '\u101e\u1004\u103a\u101e\u100a\u103a \u1021\u1001\u103b\u102d\u1014\u103a\u1019\u101b\u103d\u1031\u1038 \u1012\u1031\u1010\u102c\u1021\u102c\u1038\u101c\u102f\u1036\u1038 \u1016\u103b\u1000\u103a\u1015\u1005\u103a \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u1021\u1000\u103a\u1015\u103a\u1016\u101a\u103a\u101b\u103e\u102c\u1038\u1014\u102d\u102f\u1004\u103a\u1015\u102b\u101e\u100a\u103a\u104b \u1012\u1031\u1010\u102c\u1016\u103b\u1000\u103a\u1001\u103c\u1004\u103a\u1038\u101e\u100a\u103a \u1016\u102f\u1014\u103a\u1038\u1010\u103d\u1004\u103a\u1038\u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u101e\u1031\u102c \u1000\u103b\u103d\u1014\u103a\u1010\u1031\u102c\u103a\u1010\u102d\u102f\u1037app \u1014\u103e\u1004\u1037\u103a\u1006\u102d\u102f\u1004\u103a\u101e\u1031\u102c\u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u1019\u103b\u102c\u1038\u1014\u103e\u1004\u1037\u103a \u101e\u102d\u1019\u103a\u1038\u1006\u100a\u103a\u1038\u1011\u102c\u1038\u101e\u1031\u102c \u1015\u101b\u102e\u1019\u102e\u101a\u1019\u103a\u1021\u1001\u103c\u1031\u1021\u1014\u1031\u1000\u102d\u102f \u1016\u103b\u1000\u103a\u101e\u102d\u1019\u103a\u1038\u1015\u102b\u101e\u100a\u103a\u104b\n\n'
        '7) \u101c\u102f\u1036\u1001\u103c\u102f\u1036\u101b\u1031\u1038\n'
        '\u1021\u1000\u103a\u1015\u103a\u101e\u100a\u103a \u1019\u1010\u101b\u102c\u1038\u1016\u103b\u1000\u103a\u1019\u103e\u102f\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u101c\u103b\u103e\u1031\u102c\u1037\u1001\u103b\u101b\u1014\u103a \u1021\u1015\u103c\u100a\u1037\u103a\u1021\u101d\u1005\u1005\u103a\u1006\u1031\u1038\u1019\u103e\u102f\u1014\u103e\u1004\u1037\u103a \u101c\u102f\u1036\u1001\u103c\u102f\u1036\u101e\u1031\u102c \u1005\u1000\u103a\u1010\u103d\u1004\u103a\u1038\u101e\u102d\u1019\u103a\u1038\u1006\u100a\u103a\u1038\u1019\u103e\u102f\u1000\u102d\u102f\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u100a\u103a\u104a \u101e\u102d\u102f\u1037\u101e\u1031\u102c\u103a \u1018\u101a\u103a\u1005\u1014\u1005\u103a\u1019\u103e\u101c\u100a\u103a\u1038 \u1021\u1015\u103c\u100a\u1037\u103a\u1021\u101d\u101c\u102f\u1036\u1001\u103c\u102f\u1036\u1019\u103e\u102f\u1019\u101b\u103e\u102d\u1014\u102d\u102f\u1004\u103a\u1015\u102b\u104b',
    'legal.terms.content':
        'H&F \u1000\u102d\u102f \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u1001\u103c\u1004\u103a\u1038\u1021\u102c\u1038\u1016\u103c\u1004\u1037\u103a \u1024\u1005\u100a\u103a\u1038\u1019\u103b\u1009\u103a\u1038\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u101e\u1004\u103a\u101c\u1000\u103a\u1001\u1036\u1015\u102b\u101e\u100a\u103a\u104b\n\n'
        '1) \u101d\u1014\u103a\u1006\u1031\u102c\u1004\u103a\u1019\u103e\u102f\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u1001\u103c\u1004\u103a\u1038\n'
        'H&F \u101e\u100a\u103a \u1000\u103b\u1014\u103a\u1038\u1019\u102c\u101b\u1031\u1038\u1021\u1011\u1031\u102c\u1000\u103a\u1021\u1000\u1030\u1016\u103c\u1005\u103a\u101e\u100a\u1037\u103a \u1021\u1000\u103a\u1015\u103a\u1016\u103c\u1005\u103a\u101e\u100a\u103a\u104b \u101e\u1004\u103a\u101e\u100a\u103a \u101e\u1004\u1037\u103a\u101c\u102f\u1036\u1001\u103c\u102f\u1036\u1019\u103e\u102f\u1014\u103e\u1004\u1037\u103a \u1000\u103b\u1014\u103a\u1038\u1019\u102c\u101b\u1031\u1038\u1006\u102d\u102f\u1004\u103a\u101b\u102c\u1006\u102f\u1036\u1038\u1016\u103c\u1010\u103a\u1001\u103b\u1000\u103a\u1019\u103b\u102c\u1038\u1021\u1010\u103d\u1000\u103a \u1010\u102c\u101d\u1014\u103a\u101a\u1030\u101b\u1015\u102b\u1019\u100a\u103a\u104b\n\n'
        '2) \u1021\u1000\u1031\u102c\u1004\u1037\u103a\u1014\u103e\u1004\u1037\u103a \u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a\n'
        '\u1015\u101b\u102e\u1019\u102e\u101a\u1019\u103a\u1021\u1010\u103d\u1000\u103a \u1010\u101b\u102c\u1038\u101d\u1004\u103a \u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a\u1000\u102e\u1038\u101c\u102d\u102f\u1021\u1015\u103a\u101e\u100a\u103a\u104b \u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u1005\u1000\u103a\u1021\u101c\u102d\u102f\u1000\u103a \u1000\u1014\u1037\u103a\u101e\u1010\u103a\u1011\u102c\u1038\u1015\u103c\u102e\u1038\u104a \u1005\u1000\u103a\u1010\u1005\u103a\u101c\u102f\u1036\u1038\u1011\u1000\u103a\u1015\u102d\u102f\u1010\u1032\u1037\u101e\u102f\u1036\u1038\u1005\u103d\u1032\u1019\u103e\u102f\u104a \u1005\u102e\u1005\u1005\u103a\u1019\u103e\u102f \u1004\u103c\u1004\u103a\u1038\u1001\u103b\u1001\u103c\u1004\u103a\u1038\u104a \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u101c\u102f\u1036\u1001\u103c\u102f\u1036\u101b\u1031\u1038\u1016\u1031\u102c\u1000\u103a\u1011\u103d\u1004\u103a\u1038\u1019\u103e\u102f\u1015\u103c\u102f\u101c\u102f\u1015\u103a\u1019\u102d\u1001\u103c\u1004\u103a\u1038\u1000\u103c\u1031\u102c\u1004\u1037\u103a \u101b\u102f\u1015\u103a\u101e\u102d\u1019\u103a\u1038\u1001\u1036\u101b\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b\n\n'
        '3) \u1021\u1031\u102c\u1037\u1016\u103a\u101c\u102d\u102f\u1004\u103a\u1038\u1014\u100a\u103a\u1038\n'
        '\u1021\u1031\u102c\u1004\u103a\u1019\u103c\u1004\u103a\u1005\u103d\u102c\u1016\u103d\u1004\u1037\u103a\u101c\u103e\u1005\u103a\u1015\u103c\u102e\u1038\u1014\u1031\u102c\u1000\u103a \u1021\u1001\u103c\u1031\u1001\u1036\u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u1001\u103b\u1000\u103a\u1019\u103b\u102c\u1038\u1014\u103e\u1004\u1037\u103a \u1015\u101b\u102e\u1019\u102e\u101a\u1019\u103a\u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u1001\u103b\u1000\u103a\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u1010\u1005\u103a\u1001\u102f\u1010\u100a\u103a\u1038\u101e\u1031\u102c \u1005\u1000\u103a\u1019\u103e \u1021\u1031\u102c\u1037\u1016\u103a\u101c\u102d\u102f\u1004\u103a\u1038\u1016\u103c\u1004\u1037\u103a \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b \u1011\u1015\u103a\u1019\u1036\u1010\u1015\u103a\u1006\u1004\u103a\u1001\u103c\u1004\u103a\u1038\u104a \u1000\u102d\u102f\u101a\u103a\u101b\u1031\u1038\u1000\u102d\u102f\u101a\u103a\u1010\u102c\u1012\u1031\u1010\u102c \u1016\u103b\u1000\u103a\u1001\u103c\u1004\u103a\u1038 \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u101c\u102f\u1036\u1001\u103c\u102f\u1036\u101b\u1031\u1038\u1005\u1005\u103a\u1006\u1031\u1038\u1019\u103e\u102f \u1019\u1021\u1031\u102c\u1004\u103a\u1019\u103c\u1004\u103a\u1019\u103e\u102f\u1019\u103b\u102c\u1038\u1000\u103c\u1031\u102c\u1004\u1037\u103a \u1011\u1015\u103a\u1019\u1036\u1021\u103d\u1014\u103a\u101c\u102d\u102f\u1004\u103a\u1038\u1016\u103d\u1004\u1037\u103a\u101c\u103e\u1005\u103a\u101b\u1014\u103a \u101c\u102d\u102f\u1021\u1015\u103a\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b\n\n'
        '4) \u1000\u1014\u1037\u103a\u101e\u1010\u103a\u1001\u103b\u1000\u103a\u1019\u103b\u102c\u1038\n'
        '\u101c\u102f\u1036\u1001\u103c\u102f\u1036\u101b\u1031\u1038\u1000\u102d\u102f \u101c\u103e\u100a\u1037\u103a\u101c\u100a\u103a\u1015\u103c\u1031\u102c\u1004\u103a\u1038\u101c\u1032\u1001\u103c\u1004\u103a\u1038\u104a \u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a \u1015\u103c\u102f\u101c\u102f\u1015\u103a\u1001\u103c\u1004\u103a\u1038\u1000\u102d\u102f\u1014\u1031\u102c\u1000\u103a\u1000\u103c\u1031\u102c\u1004\u103a\u1038\u1015\u103c\u1014\u103a\u101c\u102d\u102f\u1000\u103a\u104d \u1016\u1031\u102c\u103a\u1011\u102f\u1010\u103a\u1001\u103c\u1004\u103a\u1038 \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u1010\u101b\u102c\u1038\u1019\u101d\u1004\u103a \u101c\u102f\u1015\u103a\u1004\u1014\u103a\u1038\u1019\u103b\u102c\u1038\u1021\u1010\u103d\u1000\u103a \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u1001\u103c\u1004\u103a\u1038 \u1019\u1015\u103c\u102f\u101b\u104b\n\n'
        '5) \u1019\u1030\u1015\u102d\u102f\u1004\u103a\u1001\u103d\u1004\u1037\u103a\n'
        '\u1021\u1000\u103a\u1015\u103a\u1006\u1031\u102c\u1037\u1016\u103a\u101d\u1032\u104a \u1018\u101b\u1014\u103a\u1038\u1014\u1032\u1037 \u1021\u1000\u103c\u1031\u102c\u1004\u103a\u1038\u1021\u101b\u102c\u1019\u103b\u102c\u1038\u101e\u100a\u103a H&F \u1014\u103e\u1004\u1037\u103a \u1011\u102d\u102f\u101c\u102d\u102f\u1004\u103a\u1005\u1004\u103a\u101b\u103e\u1004\u103a\u1019\u103b\u102c\u1038\u104f \u1015\u102d\u102f\u1004\u103a\u1006\u102d\u102f\u1004\u103a\u1019\u103e\u102f\u1016\u103c\u1005\u103a\u101e\u100a\u103a\u104b\n\n'

        '6) \u1021\u102c\u1019\u1001\u1036 \u1019\u101b\u103e\u102d\u1001\u103c\u1004\u103a\u1038\n'
        '\u1021\u1000\u103a\u1015\u103a\u1000\u102d\u102f "\u101c\u1000\u103a\u101b\u103e\u102d\u1021\u1001\u103c\u1031\u1021\u1014\u1031\u1016\u103c\u1004\u1037\u103a" \u1015\u1031\u1038\u101e\u100a\u103a\u104a \u1001\u103b\u103d\u1010\u103a\u101a\u103d\u1004\u103a\u1038\u1019\u103e\u102f\u101c\u102f\u1036\u1038\u101d\u1019\u101b\u103e\u102d\u101f\u102f\u1021\u102c\u1019\u1019\u1001\u1036\u1015\u102b. \u101e\u1010\u103a\u1019\u103e\u1010\u103a\u1011\u102c\u1038\u101e\u1031\u102c \u1000\u103b\u1014\u103a\u1038\u1019\u102c\u101b\u1031\u1038\u101b\u101c\u1012\u103a\u1000\u102d\u102f \u1019\u101e\u1031\u1001\u103b\u102c\u1014\u102d\u102f\u1004\u103a\u1015\u102b\u104b \u1021\u1000\u103c\u1031\u102c\u1004\u103a\u1038\u1021\u1019\u103b\u102d\u102f\u1038\u1019\u103b\u102d\u102f\u1038\u1000\u103c\u1031\u102c\u1004\u1037\u103a \u1021\u1000\u103a\u1015\u103a\u1000\u1031\u102c\u1004\u103a\u1010\u102c\u101e\u100a\u103a \u1015\u102d\u102f\u1010\u103d\u1000\u103a\u1019\u102d\u1001\u103c\u1004\u103a\u1038 \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u101c\u103b\u1031\u102c\u1037\u1010\u103d\u1000\u103a\u1019\u102d\u1001\u103c\u1004\u103a\u1038 \u1016\u103c\u1005\u103a\u1014\u102d\u102f\u1004\u103a\u1015\u102b\u101e\u100a\u103a\u104b\n\n'
        '7) \u1010\u102c\u101d\u1014\u103a\u1000\u1014\u1037\u103a\u101e\u1010\u103a\u1001\u103c\u1004\u103a\u1038\n'
        'H&F \u101e\u100a\u103a \u1021\u1000\u103a\u1015\u103a\u1000\u102d\u102f \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u1031\u102c\u1000\u103c\u1031\u102c\u1004\u1037\u103a \u1016\u103c\u1005\u103a\u1015\u1031\u102b\u103a\u101c\u102c\u101e\u100a\u1037\u103a \u1021\u101c\u101a\u103a\u1021\u101c\u1010\u103a\u104a \u1001\u103b\u102d\u102f\u1037\u101a\u103d\u1004\u103a\u1038\u1019\u103e\u102f \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u1021\u1000\u103b\u102d\u102f\u1038\u101e\u1000\u103a\u101b\u1031\u102c\u1000\u103a\u1019\u103e\u102f \u1015\u103b\u1000\u103a\u1000\u103d\u1000\u103a\u1019\u103e\u102f\u1019\u103b\u102c\u1038\u1021\u1010\u103d\u1000\u103a \u1010\u102c\u101d\u1014\u103a\u1019\u101a\u1030\u1015\u102b\u104b',
    'legal.disclaimer.content':
        'H&F \u101e\u100a\u103a \u1006\u1031\u1038\u1018\u1000\u103a\u1006\u102d\u102f\u1004\u103a\u101b\u102c \u101d\u1014\u103a\u1006\u1031\u102c\u1004\u103a\u1019\u103e\u102f \u1019\u101f\u102f\u1010\u103a\u101e\u1016\u103c\u1004\u1037\u103a \u1006\u1031\u1038\u1018\u1000\u103a\u1006\u102d\u102f\u1004\u103a\u101b\u102c \u1021\u1000\u103c\u1036\u1015\u103c\u102f\u1001\u103b\u1000\u103a\u104a \u101b\u102c\u1002\u102b\u101e\u102d\u1001\u103c\u1004\u103a\u1038 \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u1000\u102f\u101e\u1019\u103e\u102f \u1019\u1015\u1031\u1038\u1015\u102b\u104b\n\n'
        '1) \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f \u1012\u100f\u103a\u101b\u102c\u1021\u1014\u1039\u1010\u101b\u102c\u101a\u103a\n'
        '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f\u1010\u103d\u1004\u103a \u1011\u102d\u1001\u102d\u102f\u1000\u103a\u1012\u100f\u103a\u101b\u102c\u101b\u1014\u102d\u102f\u1004\u103a\u1001\u103b\u1031 \u101b\u103e\u102d\u101e\u100a\u103a\u104b \u1014\u102c\u1000\u103b\u1004\u103a\u1019\u103e\u102f\u104a \u1019\u1030\u1038\u101d\u102b\u1038\u1019\u103e\u102f\u104a \u1021\u101e\u1000\u103a\u101b\u103e\u102f\u1015\u103c\u103f\u1014\u102c \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u1019\u1019\u103b\u103e\u1031\u102c\u103a\u101c\u1004\u1037\u103a\u101b\u101e\u100a\u1037\u103a \u1001\u1036\u1005\u102c\u1038\u1001\u103b\u1000\u103a\u1010\u103d\u1031\u1037\u101b\u1015\u102b\u1000 \u1001\u103b\u1000\u103a\u1001\u103b\u1004\u103a\u1038\u101b\u1015\u103a\u101c\u102d\u102f\u1000\u103a\u1015\u102b\u104a \u1021\u101b\u100a\u103a\u1021\u1001\u103b\u1004\u103a\u1038\u101b\u103e\u102d\u1015\u100a\u102c\u101b\u103e\u1004\u103a\u1010\u1005\u103a\u1026\u1038\u1021\u102c\u1038 \u1010\u102d\u102f\u1004\u103a\u1015\u1004\u103a\u1015\u102b\u104b\n\n'
        '2) AI \u1000\u102d\u1014\u103a\u1038\u1002\u100f\u1014\u103a\u1038\u1014\u103e\u1004\u1037\u103a \u101b\u103e\u1031\u1037\u1005\u103d\u102c\u1015\u103c\u1014\u103a\u101c\u100a\u103a\u101e\u102f\u1036\u1038\u101e\u1015\u103a\u1019\u103e\u102f\n'
        '\u1021\u1014\u1031\u1021\u1011\u102c\u1038\u1015\u103c\u1014\u103a\u101c\u100a\u103a\u101e\u102d\u101b\u103e\u102d\u1001\u103c\u1004\u103a\u1038\u1014\u103e\u1004\u1037\u103a \u1021\u101c\u103e\u100a\u1037\u103a\u1021\u1015\u103c\u1031\u102c\u1004\u103a\u1038\u1021\u101b\u1031\u1021\u1010\u103d\u1000\u103a \u1010\u1005\u103a\u1001\u102f\u1001\u103b\u1004\u103a\u1038\u1005\u102e\u101e\u100a\u103a \u1021\u1010\u1010\u103a\u1014\u102d\u102f\u1004\u103a\u1006\u102f\u1036\u1038\u1000\u1031\u102c\u1004\u103a\u1038\u1019\u103d\u1014\u103a\u1005\u103d\u102c\u1010\u103d\u1000\u103a\u1001\u103b\u1000\u103a\u1001\u1014\u1037\u103a\u1019\u103e\u1014\u103a\u1038\u1011\u102c\u1038\u1010\u102c\u1016\u103c\u1005\u103a\u1015\u103c\u102e\u1038 \u1000\u1004\u103a\u1019\u101b\u102c \u1011\u1031\u102c\u1004\u1037\u103a\u1001\u103c\u102c\u1038\u104a \u1019\u102e\u1038\u101b\u1031\u102c\u1004\u103a\u1001\u103c\u100a\u103a\u104a \u1021\u1010\u102c\u1038\u1021\u1006\u102e\u1038\u104a \u1021\u1040\u1010\u103a\u1021\u1005\u102c\u1038 \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u101c\u103e\u102f\u1015\u103a\u101b\u103e\u102c\u1038\u1019\u103e\u102f \u1021\u101b\u103e\u102d\u1014\u103a\u1000\u103c\u1031\u102c\u1004\u1037\u103a \u1021\u1019\u103e\u102c\u1038 \u1016\u103c\u1005\u103a\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b\n\n'
        '3) \u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u1010\u1004\u103a\u1019\u103e\u102f\u1014\u103e\u1004\u1037\u103a \u1005\u103d\u1019\u103a\u1038\u1006\u1031\u102c\u1004\u103a\u101b\u100a\u103a\n'
        '\u1016\u102f\u1014\u103a\u1038\u1016\u103d\u1004\u1037\u103a\u1015\u103c\u102e\u1038 \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u101c\u102f\u1015\u103a\u101b\u102c\u1019\u103e\u102c counting/voice counting \u1000\u102d\u102f \u1000\u1031\u102c\u1004\u103a\u1038\u1000\u1031\u102c\u1004\u103a\u1038\u101c\u102f\u1015\u103a\u1014\u102d\u102f\u1004\u103a\u1021\u1031\u102c\u1004\u103a \u1016\u1014\u103a\u1010\u102e\u1038\u1011\u102c\u1038\u1015\u102b\u1010\u101a\u103a\u104b Pose detection (counting) \u1014\u1032\u1037 video recording \u1000\u102d\u102f \u1010\u1015\u103c\u102d\u102f\u1004\u103a\u1010\u100a\u103a\u1038\u101c\u102f\u1015\u103a\u1014\u102d\u102f\u1004\u103a\u1021\u1031\u102c\u1004\u103a\u101c\u100a\u103a\u1038 \u1005\u1014\u1005\u103a\u1010\u1000\u103b \u1015\u103c\u102f\u101c\u102f\u1015\u103a\u1011\u102c\u1038\u1015\u102b\u1010\u101a\u103a\u104b\n\n'
        '4) \u1021\u101b\u1031\u1038\u1015\u1031\u102b\u103a \u1021\u1001\u103c\u1031\u1021\u1014\u1031\u1019\u103b\u102c\u1038\n'
        '\u1021\u101b\u1031\u1038\u1015\u1031\u102b\u103a \u1021\u1001\u103c\u1031\u1021\u1014\u1031\u1019\u103b\u102c\u1038\u1021\u1010\u103d\u1000\u103a \u1024\u1021\u1000\u103a\u1015\u103a\u1000\u102d\u102f \u1019\u1015\u103c\u102f\u101c\u102f\u1015\u103a\u1011\u102c\u1038\u1015\u102b\u104b \u101c\u102d\u102f\u1021\u1015\u103a\u101c\u103b\u103e\u1004\u103a \u1012\u1031\u101e\u1001\u1036 \u1021\u101b\u1031\u1038\u1015\u1031\u102b\u103a \u101d\u1014\u103a\u1006\u1031\u102c\u1004\u103a\u1019\u103e\u102f\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u1001\u103b\u1000\u103a\u1001\u103b\u1004\u103a\u1038\u1006\u1000\u103a\u101e\u103d\u101a\u103a\u1015\u102b\u104b\n\n'
        '5) \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u1030\u104f \u1010\u102c\u101d\u1014\u103a\n'
        '\u101c\u102f\u1036\u1001\u103c\u102f\u1036\u101e\u1031\u102c \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1010\u100a\u103a\u1014\u1031\u101b\u102c\u104a \u1019\u103e\u1014\u103a\u1000\u1014\u103a\u101e\u1031\u102c \u1014\u100a\u103a\u1038\u101c\u1019\u103a\u1038\u1014\u103e\u1004\u1037\u103a \u101c\u102d\u102f\u1021\u1015\u103a\u101e\u100a\u1037\u103a \u1006\u1031\u1038\u1018\u1000\u103a\u1006\u102d\u102f\u1004\u103a\u101b\u102c \u1000\u102d\u1005\u1039\u1005\u101b\u1015\u103a\u1019\u103b\u102c\u1038 \u101b\u101a\u1030\u1001\u103c\u1004\u103a\u1038\u101e\u100a\u103a \u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u1030\u104f \u1010\u102c\u101d\u1014\u103a\u1016\u103c\u1005\u103a\u101e\u100a\u103a\u104b\n\n'
        '6) \u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u1010\u1004\u103a\u1001\u103c\u1004\u103a\u1038\u1014\u103e\u1004\u1037\u103a \u1010\u1001\u103c\u102c\u1038\u101e\u1030\u1019\u103b\u102c\u1038\u104f \u1000\u102d\u102f\u101a\u103a\u101b\u1031\u1038\u1021\u1001\u103b\u1000\u103a\u1021\u101c\u1000\u103a\n'
        '\u101e\u1004\u103a\u101e\u100a\u103a \u1021\u101c\u1031\u1037\u1021\u1000\u103b\u1004\u1037\u103a\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038\u1010\u1004\u103a\u101e\u1031\u102c\u1021\u1001\u102b \u1017\u102e\u1012\u102e\u101a\u102d\u102f \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u1021\u101e\u1036\u1011\u1032\u1010\u103d\u1004\u103a \u101c\u102c\u101b\u1031\u102c\u1000\u103a\u1014\u102d\u102f\u1004\u103a\u101e\u1030\u1019\u103b\u102c\u1038\u1021\u102c\u1038 \u1001\u103d\u1004\u1037\u103a\u1015\u103c\u102f\u1001\u103b\u1000\u103a \u101b\u101a\u1030\u1011\u102c\u1038\u101b\u1015\u102b\u1019\u100a\u103a\u104b\n\n'
        '7) \u101b\u101c\u1012\u103a\u1019\u103b\u102c\u1038\n'
        '\u1000\u103b\u1014\u103a\u1038\u1019\u102c\u101b\u1031\u1038\u101b\u101c\u1012\u103a\u1019\u103b\u102c\u1038\u101e\u100a\u103a \u1010\u1005\u103a\u1026\u1038\u1001\u103b\u1004\u103a\u1038\u1005\u102e \u1021\u101c\u102d\u102f\u1000\u103a \u1019\u1010\u1030\u100a\u102e\u1000\u103c\u1015\u102b\u104b H&F \u101e\u100a\u103a \u101e\u1010\u103a\u1019\u103e\u1010\u103a\u1011\u102c\u1038\u101e\u1031\u102c \u1005\u103d\u1019\u103a\u1038\u1006\u1031\u102c\u1004\u103a\u101b\u100a\u103a \u101e\u102d\u102f\u1037\u1019\u101f\u102f\u1010\u103a \u1000\u103b\u1014\u103a\u1038\u1019\u102c\u101b\u1031\u1038\u101b\u101c\u1012\u103a\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u1021\u102c\u1019\u1001\u1036 \u1019\u101c\u102f\u1015\u103a\u1015\u102b\u104b',
    'legal.accepted_notice': '{date} \u1010\u103d\u1004\u103a \u101e\u1018\u1031\u102c\u1010\u1030\u1015\u103c\u102e\u1038\u1015\u103c\u102e\u104b',
    'settings.select_theme': 'Theme \u101b\u103d\u1031\u1038',
    'settings.select_language': '\u1018\u102c\u101e\u102c \u101b\u103d\u1031\u1038',
    'onboarding.language_title': '\u1018\u102c\u101e\u102c \u101b\u103d\u1031\u1038\u1001\u103b\u101a\u103a\u1015\u102b',
    'onboarding.language_subtitle': '\u1014\u1031\u102c\u1000\u103a\u1019\u103e Settings \u1019\u103e\u102c \u1015\u103c\u1031\u102c\u1004\u103a\u1038\u101c\u1032\u1014\u102d\u102f\u1004\u103a\u1015\u102b\u1010\u101a\u103a\u104b',
    'onboarding.name_title': '\u1014\u102c\u1019\u100a\u103a \u1018\u102c\u101c\u1032?',
    'onboarding.name_subtitle': '\u1012\u102e\u1014\u102c\u1019\u100a\u103a\u1000\u102d\u102f \u1015\u101b\u102d\u102f\u1016\u102d\u102f\u1004\u103a\u1019\u103e\u102c \u1015\u103c\u1015\u102b\u1019\u101a\u103a\u104b',
    'onboarding.name_hint': '\u1014\u102c\u1019\u100a\u103a \u101b\u102d\u102f\u1000\u103a\u1011\u100a\u1037\u103a\u1015\u102b',
    'onboarding.name_required': '\u1014\u102c\u1019\u100a\u103a \u101b\u102d\u102f\u1000\u103a\u1011\u100a\u1037\u103a\u1015\u102b',
    'onboarding.disclaimer_title': '\u101e\u1010\u102d\u1015\u1031\u1038\u1001\u103b\u1000\u103a',
    'onboarding.terms_title': '\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u1019\u103e\u102f \u1005\u100a\u103a\u1038\u1000\u1019\u103a\u1038\u1001\u103b\u1000\u103a\u1019\u103b\u102c\u1038',
    'onboarding.accept_notice':
        '\u1021\u1000\u103a\u1015\u103a\u1000\u102d\u102f \u1006\u1000\u103a\u101c\u1000\u103a\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101b\u1014\u103a \u101e\u1018\u1031\u102c\u1010\u1030\u101b\u1014\u103a\u101c\u102d\u102f\u1015\u102b\u101e\u100a\u103a\u104b',
    'onboarding.accept_checkbox': '\u101e\u1018\u1031\u102c\u1010\u1030\u1015\u102b\u101e\u100a\u103a',
    'onboarding.continue': '\u1006\u1000\u103a\u101c\u1000\u103a',
    'onboarding.start_app': '\u1021\u1000\u103a\u1015\u103a\u1005\u1010\u1004\u103a\u101b\u1014\u103a',
    'settings.clear_all_data': '\u1012\u1031\u1010\u102c\u1021\u102c\u1038\u101c\u102f\u1036\u1038 \u1016\u103b\u1000\u103a',
    'settings.clear_all_data_desc':
        '\u101e\u1004\u103a\u1037\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f\u101e\u1019\u102d\u102f\u1004\u103a\u1038\u104a \u1021\u1031\u102c\u1004\u103a\u1019\u103c\u1004\u103a\u1019\u103e\u102f\u1019\u103b\u102c\u1038\u1014\u103e\u1004\u1037\u103a \u1006\u1000\u103a\u1010\u1004\u103a\u1019\u103b\u102c\u1038\u1021\u102c\u1038\u101c\u102f\u1036\u1038 \u1016\u103b\u1000\u103a\u1019\u100a\u103a\u1016\u103c\u1005\u103a\u1015\u103c\u102e\u1038 \u1015\u103c\u1014\u103a\u1019\u101b\u1014\u102d\u102f\u1004\u103a\u1015\u102b\u104b',
    'settings.clear_success': '\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u1030\u1012\u1031\u1010\u102c\u1021\u102c\u1038\u101c\u102f\u1036\u1038 \u1016\u103b\u1000\u103a\u1015\u103c\u102e\u1038\u1015\u103c\u102e\u104b',
    'settings.clear_failed': '\u1012\u1031\u1010\u102c \u1016\u103b\u1000\u103a\u1019\u1021\u1031\u102c\u1004\u103a\u1019\u103c\u1004\u103a: {error}',
    'theme.light': '\u1021\u101c\u1004\u103a\u1038',
    'theme.dark': '\u1019\u103e\u1031\u102c\u1004\u103a',
    'theme.gold': '\u101b\u103d\u103e\u1031\u101b\u1031\u102c\u1004\u103a',
    'theme.pink': '\u1015\u1014\u103a\u1038\u101b\u1031\u102c\u1004\u103a',
    'progress.title': '\u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1014\u103e\u1004\u1037\u103a \u1001\u103d\u1032\u1001\u103c\u1019\u103a\u1038\u101e\u102f\u1036\u1038\u101e\u1015\u103a\u1001\u103b\u1000\u103a',
    'progress.overview': '\u1021\u1000\u103b\u1009\u103a\u1038\u1001\u103b\u102f\u1015\u103a',
    'progress.exercises': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1019\u103b\u102c\u1038',
    'progress.badges': '\u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a\u1019\u103b\u102c\u1038',
    'progress.no_data': '\u1012\u1031\u1010\u102c \u1019\u101b\u103e\u102d\u1015\u102b',
    'progress.weekly_summary': '\u1021\u1015\u1010\u103a\u1005\u1009\u103a \u1021\u1000\u103b\u1009\u103a\u1038\u1001\u103b\u102f\u1015\u103a',
    'progress.streak_days': '{count} \u101b\u1000\u103a\u1006\u1000\u103a',
    'progress.recent_workouts': '\u1019\u1000\u103c\u102c\u101e\u1031\u1038\u1019\u102e \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f\u1019\u103b\u102c\u1038',
    'progress.no_workouts': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f \u1019\u101b\u103e\u102d\u101e\u1031\u1038\u1015\u102b',
    'progress.workout_summary': '{reps} reps \u2022 \u1010\u102d\u1000\u103b\u1019\u103e\u102f {accuracy}%',
    'progress.achievements': '\u1021\u1031\u102c\u1004\u103a\u1019\u103c\u1004\u103a\u1019\u103e\u102f\u1019\u103b\u102c\u1038',
    'progress.badges_unlocked': '{unlocked}/{total} \u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a\u1019\u103b\u102c\u1038 \u1016\u103d\u1004\u1037\u103a\u1015\u103c\u102e\u1038',
    'progress.view_all_achievements': '\u1021\u1031\u102c\u1004\u103a\u1019\u103c\u1004\u103a\u1019\u103e\u102f\u1021\u102c\u1038\u101c\u102f\u1036\u1038 \u1000\u103c\u100a\u1037\u103a\u101b\u1014\u103a',
    'progress.day.sun': '\u1010\u1014\u1004\u103a\u1039\u1002\u1014\u103d\u1031',
    'progress.day.mon': '\u1010\u1014\u1004\u103a\u1039\u101c\u102c',
    'progress.day.tue': '\u1021\u1004\u103a\u1039\u1002\u102b',
    'progress.day.wed': '\u1017\u102f\u1012\u1039\u1013\u101f\u1030\u1038',
    'progress.day.thu': '\u1000\u103c\u102c\u101e\u1015\u1010\u1031\u1038',
    'progress.day.fri': '\u101e\u1031\u102c\u1000\u103c\u102c',
    'progress.day.sat': '\u1005\u1014\u1031',
    'progress.time.just_now': '\u1021\u1001\u102f\u101c\u1031\u1038\u1010\u1004\u103a',
    'progress.time.minutes_ago': '{value} \u1019\u102d\u1014\u1005\u103a\u1000',
    'progress.time.hours_ago': '{value} \u1014\u102c\u101b\u102e\u1000',
    'progress.time.days_ago': '{value} \u101b\u1000\u103a\u1000',
    'progress.time.weeks_ago': '{value} \u1015\u1010\u103a\u1000',
    'progress.analytics_intro_title':
        '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038 \u1021\u1001\u103b\u1000\u103a\u1021\u101c\u1000\u103a\u1019\u103b\u102c\u1038\u1000\u102d\u102f \u1018\u101a\u103a\u101c\u102d\u102f\u1014\u102c\u1038\u101c\u100a\u103a\u1019\u101c\u1032',
    'progress.analytics_intro_line1':
        '\u1005\u102f\u1005\u102f\u1015\u1031\u102b\u1004\u103a\u1038 Reps = \u1012\u102e\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1021\u1010\u103d\u1000\u103a \u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u101e\u1031\u102c session \u1021\u102c\u1038\u101c\u102f\u1036\u1038\u1011\u1032\u1000 \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1021\u1001\u103b\u1000\u103a\u101b\u1031 \u1005\u102f\u1005\u102f\u1015\u1031\u102b\u1004\u103a\u1038\u104b',
    'progress.analytics_intro_line2':
        '\u1015\u103b\u1019\u103a\u1038\u1019\u103b\u103e \u1010\u102d\u1000\u103b\u1019\u103e\u102f = \u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u101e\u1031\u102c session \u1021\u102c\u1038\u101c\u102f\u1036\u1038\u104f \u1015\u102f\u1036\u1005\u1036\u1010\u102d\u1000\u103b\u1019\u103e\u102f \u1015\u103b\u1019\u103a\u1038\u1019\u103b\u103e\u104b',
    'progress.analytics_intro_line3':
        'Trend chart = \u1021\u1001\u103b\u102d\u1014\u103a\u1010\u1005\u103a\u101c\u103b\u103e\u1031\u102c\u1000\u103a \u1010\u102d\u1000\u103b\u1019\u103e\u102f (\u101c\u102d\u102f\u1004\u103a\u1038\u1019\u103c\u1004\u1037\u103a\u101c\u103b\u103e\u1004\u103a \u1015\u102f\u1036\u1005\u1036\u1000\u1031\u102c\u1004\u103a\u1038\u101e\u100a\u103a)\u104b',
    'progress.analytics_intro_line4':
        'Analytics \u101e\u100a\u103a workout session \u1000\u102d\u102f save \u101c\u102f\u1015\u103a\u1015\u103c\u102e\u1038\u1019\u103e\u101e\u102c update \u1016\u103c\u1005\u103a\u101e\u100a\u103a\u104b',
    'progress.read_exercise_analytics_title':
        '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038 \u1001\u103d\u1032\u1001\u103c\u1019\u103a\u1038\u101e\u102f\u1036\u1038\u101e\u1015\u103a\u1001\u103b\u1000\u103a\u1000\u102d\u102f \u1018\u101a\u103a\u101c\u102d\u102f\u1016\u1010\u103a\u1019\u101c\u1032',
    'progress.read_exercise_analytics_line1':
        '\u1014\u1031\u102c\u1000\u103a\u1006\u102f\u1036\u1038 \u1010\u102d\u1000\u103b\u1019\u103e\u102f = \u1019\u1000\u103c\u102c\u101e\u1031\u1038\u1019\u102e session \u101b\u1032\u1037 form score\u104b',
    'progress.read_exercise_analytics_line2':
        '\u1021\u1000\u1031\u102c\u1004\u103a\u1038\u1006\u102f\u1036\u1038 \u1010\u102d\u1000\u103b\u1019\u103e\u102f = \u101a\u1001\u102f\u1021\u1001\u103b\u102d\u1014\u103a\u1011\u102d \u1021\u1019\u103c\u1004\u1037\u103a\u1006\u102f\u1036\u1038 score\u104b',
    'progress.read_exercise_analytics_line3':
        'Session bar \u1019\u103b\u102c\u1038\u1000 \u1014\u1031\u102c\u1000\u103a\u1006\u102f\u1036\u1038 6 sessions \u1000\u102d\u102f \u1015\u103c\u101e\u100a\u103a\u104b Bar \u1019\u103c\u1004\u1037\u103a\u101c\u1031\u101c\u1031 \u1010\u102d\u1000\u103b\u1019\u103e\u102f\u1000\u1031\u102c\u1004\u103a\u1038\u101c\u1031\u101c\u1031\u104b',
    'progress.read_exercise_analytics_line4':
        'Bar \u1010\u1005\u103a\u1001\u102f\u1005\u102e\u1021\u1031\u102c\u1000\u103a\u1000 \u1000\u102d\u1014\u103a\u1038\u1002\u100f\u1014\u103a\u1038\u1000 \u1021\u1032\u1012\u102e session \u101b\u1032\u1037 reps \u1021\u101b\u1031\u1021\u1010\u103d\u1000\u103a \u1016\u103c\u1005\u103a\u101e\u100a\u103a\u104b',
    'progress.latest_accuracy': '\u1014\u1031\u102c\u1000\u103a\u1006\u102f\u1036\u1038 \u1010\u102d\u1000\u103b\u1019\u103e\u102f',
    'progress.best_accuracy': '\u1021\u1000\u1031\u102c\u1004\u103a\u1038\u1006\u102f\u1036\u1038 \u1010\u102d\u1000\u103b\u1019\u103e\u102f',
    'progress.trend_vs_previous_session':
        '\u101a\u1001\u1004\u103a session \u1014\u103e\u1004\u1037\u103a \u1014\u103e\u102d\u102f\u1004\u103a\u1038\u101a\u103e\u1009\u103a {sign}{delta}%',
    'progress.last_sessions_accuracy_title': '\u1014\u1031\u102c\u1000\u103a\u1006\u102f\u1036\u1038 Sessions (\u1010\u102d\u1000\u103b\u1019\u103e\u102f %)',
    'progress.reps_short': 'reps',
    'progress.chart_accuracy_trend_legend':
        'Bar \u1019\u103c\u1004\u1037\u103a\u101c\u1031\u101c\u1031 \u1010\u102d\u1000\u103b\u1019\u103e\u102f\u1000\u1031\u102c\u1004\u103a\u1038\u101c\u1031\u101c\u1031\u104b \u1021\u1031\u102c\u1000\u103a\u1000 label \u1000 session \u1010\u1005\u103a\u1001\u102f\u1001\u103b\u1004\u103a\u1038\u1005\u102e\u101b\u1032\u1037 reps \u1016\u103c\u1005\u103a\u101e\u100a\u103a\u104b',
    'progress.total_reps_all_time': '\u1005\u102f\u1005\u102f\u1015\u1031\u102b\u1004\u103a\u1038 Reps (\u1005\u101c\u102f\u1015\u103a\u1001\u103b\u102d\u1014\u103a\u1019\u103e\u101a\u1001\u102f\u1021\u1011\u102d)',
    'progress.avg_accuracy_all_sessions': '\u1015\u103b\u1019\u103a\u1038\u1019\u103b\u103e \u1010\u102d\u1000\u103b\u1019\u103e\u102f (sessions \u1021\u102c\u1038\u101c\u102f\u1036\u1038)',
    'progress.sessions': 'Sessions',
    'progress.chart_accuracy_trend':
        'Chart \u101e\u100a\u103a session \u1014\u1031\u1037\u101b\u1000\u103a\u1021\u101c\u102d\u102f\u1000\u103a \u1010\u102d\u1000\u103b\u1019\u103e\u102f \u101c\u1019\u103a\u1038\u1000\u103c\u1031\u102c\u1004\u103a\u1038\u1015\u103c\u101e\u100a\u103a\u104b',
    'progress.no_sessions':
        'Session \u1019\u101b\u103e\u102d\u101e\u1031\u1038\u1015\u102b\u104b Workout \u1000\u102d\u102f save \u101c\u102f\u1015\u103a\u1015\u103c\u102e\u1038\u1019\u103e analytics \u1000\u102d\u102f \u1019\u103c\u1004\u103a\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a\u104b',
    'badges.empty':
        '\u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a \u1019\u101b\u103e\u102d\u101e\u1031\u1038\u1015\u102b\u104b\n\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f\u1005\u1010\u1004\u103a\u1015\u103c\u102e\u1038 \u1015\u1011\u1019\u1019\u102d\u102f\u1004\u103a\u101c\u103a\u1005\u1010\u102d\u102f\u1004\u103a\u1038\u1000\u102d\u102f \u1016\u103d\u1004\u1037\u103a\u1015\u102b\u104b',
    'badges.collection': '\u101e\u1004\u103a\u1037 \u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a\u1005\u102f\u1005\u100a\u103a\u1038\u1019\u103e\u102f',
    'badges.current_status': '\u101c\u1000\u103a\u101b\u103e\u102d \u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a \u1021\u1001\u103c\u1031\u1021\u1014\u1031',
    'badges.unlocked_count': '{unlocked}/{total} \u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a\u1019\u103b\u102c\u1038 \u1016\u103d\u1004\u1037\u103a\u1015\u103c\u102e\u1038',
    'badges.tier': '\u1021\u1006\u1004\u1037\u103a: {tier}',
    'badges.next_target':
        '\u1014\u1031\u102c\u1000\u103a\u1011\u1015\u103a\u101b\u100a\u103a\u1019\u103e\u1014\u103a\u1038\u1001\u103b\u1000\u103a: {name} ({progress}/{requirement}) - \u1005\u102f\u1005\u102f\u1015\u1031\u102b\u1004\u103a\u1038 {percent}% \u1015\u103c\u102e\u1038',
    'badges.how_it_works': '\u1012\u102e\u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a\u1005\u1014\u1005\u103a \u1018\u101a\u103a\u101c\u102d\u102f\u1021\u101c\u102f\u1015\u103a\u101c\u102f\u1015\u103a\u101c\u1032',
    'badges.guide_1':
        '\u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a\u1019\u103b\u102c\u1038\u101e\u100a\u103a 5 \u101b\u1000\u103a \u101c\u103e\u102f\u1015\u103a\u101b\u103e\u102c\u1038 + 2 \u101b\u1000\u103a \u1014\u102c\u1038 \u1005\u1014\u1005\u103a\u1016\u103c\u1005\u103a\u101e\u100a\u103a\u104b \u101c\u103e\u102f\u1015\u103a\u101b\u103e\u102c\u1038\u101b\u1000\u103a\u1019\u103b\u102c\u1038\u101e\u102c \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1010\u103d\u1000\u103a\u1015\u102b\u104b',
    'badges.guide_2':
        '\u1014\u102c\u1038\u101b\u1000\u103a\u1010\u103d\u1004\u103a \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f\u1000\u102d\u102f \u101e\u102c\u1019\u1014\u103a\u1021\u1010\u102d\u102f\u1004\u103a\u1038 \u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u101e\u1031\u102c\u103a\u101c\u100a\u103a\u1038 \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1019\u1010\u102d\u102f\u1038/\u1019\u101c\u103b\u1031\u102c\u1037\u1015\u102b\u104b',
    'badges.guide_3':
        '\u1014\u1031\u1037\u1005\u1009\u103a\u101b\u100a\u103a\u1019\u103e\u1014\u103a\u1038\u1001\u103b\u1000\u103a\u1010\u103d\u1004\u103a \u1021\u1000\u1014\u103a\u1037\u1021\u101e\u1010\u103a\u101b\u103e\u102d\u101e\u100a\u103a\u104b \u1021\u1000\u1014\u103a\u1037\u1021\u101e\u1010\u103a\u1000\u103b\u1031\u102c\u103a\u1010\u1032\u1037 Reps/sets \u1010\u103d\u1031\u101c\u102f\u1015\u103a\u101b\u1004\u103a\u101c\u100a\u103a\u1038\u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a\u1015\u102d\u102f\u1019\u1015\u1031\u1038\u1015\u102b.\u104b',
    'badges.guide_4':
        '\u1012\u1019\u103a\u1018\u1032\u101c\u103a/\u1005\u1000\u103a \u1019\u101c\u102d\u102f\u1015\u102b\u104b \u1021\u1005\u102c\u1038\u1011\u102d\u102f\u1038\u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u1001\u103b\u1000\u103a\u1016\u103c\u1004\u1037\u103a\u101c\u100a\u103a\u1038\u1021\u101c\u1031\u1038\u1010\u102f\u1036\u1038\u1010\u103d\u1031/\u1005\u1000\u103a\u1010\u103d\u1031\u1019\u101c\u102d\u102f\u1018\u1032 \u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a\u101b\u1014\u102d\u102f\u1004\u103a\u101e\u100a\u103a (Upper \u1021\u1010\u103d\u1000\u103a push-ups, Lower \u1021\u1010\u103d\u1000\u103a squats \u1005\u101e\u100a\u103a)\u104b',
    'badges.guide_5':
        '\u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1000\u102d\u102f \u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u101e\u1031\u102c workout logs \u1019\u103e\u1010\u103d\u1000\u103a\u101e\u100a\u103a\u104b \u1021\u1019\u103e\u1014\u103a\u1010\u1000\u101a\u103a\u101c\u102f\u1015\u103a\u1006\u1031\u102c\u1004\u103a\u1011\u102c\u1038\u101e\u1031\u102c\u1012\u1031\u1010\u102c\u1016\u103c\u1004\u1037\u103a\u101e\u102c\u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a\u1000\u102d\u102f \u1016\u103d\u1004\u1037\u103a\u101c\u103e\u1005\u103a\u101e\u100a\u103a\u104b',
    'badges.unlocked_on': '{date} \u1010\u103d\u1004\u103a \u1016\u103d\u1004\u1037\u103a\u1015\u103c\u102e\u1038',
    'badges.tap_full_plan': '\u1021\u1005\u102e\u1021\u1005\u1009\u103a\u1021\u1015\u103c\u100a\u1037\u103a \u1000\u103c\u100a\u1037\u103a\u101b\u1014\u103a \u1011\u102d\u1015\u102b',
    'badges.new_unlock_today': '\u1012\u102e\u1014\u1031\u1037 \u1016\u103d\u1004\u1037\u103a\u1015\u103c\u102e\u1038! \u1000\u1031\u102c\u1004\u103a\u1038\u1015\u102b\u1010\u101a\u103a\u104b',
    'badges.unlocked_banner':
        '\u1016\u103d\u1004\u1037\u103a\u1015\u103c\u102e\u1038! \u1010\u100a\u103a\u1019\u103c\u1032\u1019\u103e\u102f \u1021\u101c\u103d\u1014\u103a\u1000\u1031\u102c\u1004\u103a\u1038\u1015\u102b\u1010\u101a\u103a\u104b \u1006\u1000\u103a\u1015\u103c\u102e\u1038 \u1011\u102d\u1014\u103a\u1038\u1015\u102b\u104b',
    'badges.poster_saved_note':
        'Badge \u1015\u102d\u102f\u1005\u1010\u102c\u1000\u102d\u102f gallery album {album} \u1011\u1032\u101e\u102d\u102f\u1037 \u1021\u101c\u102d\u102f\u1021\u101c\u103b\u1031\u102c\u1000\u103a \u101e\u102d\u1019\u103a\u1038\u1015\u103c\u102e\u1038\u1015\u102b\u1015\u103c\u102e\u104b',
    'badges.poster_save_failed_note':
        'Badge \u1015\u102d\u102f\u1005\u1010\u102c\u1000\u102d\u102f gallery \u1011\u1032 \u1019\u101e\u102d\u1019\u103a\u1038\u1014\u102d\u102f\u1004\u103a\u1015\u102b\u104b Photo permission \u1000\u102d\u102f \u1005\u1005\u103a\u1015\u102b\u104b',
    'badges.no_tier': '\u1021\u1006\u1004\u1037\u103a \u1019\u1016\u103d\u1004\u1037\u103a\u101b\u101e\u1031\u1038\u1015\u102b',
    'badges.motivation_unlocked':
        '\u1000\u1031\u102c\u1004\u103a\u1038\u1015\u102b\u1010\u101a\u103a\u104b \u1012\u102e\u1021\u1019\u103e\u1010\u103a\u1010\u1036\u1006\u102d\u1015\u103a\u1000\u102d\u102f \u101b\u1015\u103c\u102e\u1038\u1014\u1031\u102c\u1000\u103a \u1014\u1031\u102c\u1000\u103a\u1021\u1006\u1004\u1037\u103a\u1000\u102d\u102f \u1015\u103c\u1014\u103a\u1010\u102d\u102f\u1038\u1015\u102b\u104b',
    'badges.motivation_almost':
        '\u1014\u102e\u1038\u1015\u103c\u102e\u104b \u1014\u1031\u102c\u1000\u103a\u1011\u1015\u103a {remaining} \u101b\u1000\u103a \u1021\u101b\u100a\u103a\u1021\u1001\u103b\u1004\u103a\u1038\u101b\u101b\u103e\u102d\u101b\u1004\u103a \u1016\u103d\u1004\u1037\u103a\u1014\u102d\u102f\u1004\u103a\u1015\u102b\u101e\u100a\u103a\u104b',
    'badges.motivation_keep':
        '\u1010\u100a\u103a\u1004\u103c\u102d\u1019\u103a\u1011\u102c\u1038\u1015\u102b\u104b \u1021\u101b\u100a\u103a\u1021\u1001\u103b\u1004\u103a\u1038\u101b\u1000\u103a\u1010\u102d\u102f\u1004\u103a\u1038\u1000 \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1000\u102d\u102f \u1010\u1000\u103a\u1005\u1031\u101e\u100a\u103a\u104b',
    'tier.bronze': '\u1000\u103c\u1031\u1038',
    'tier.silver': '\u1004\u103d\u1031',
    'tier.gold': '\u101b\u103d\u103e\u1031',
    'tier.platinum': '\u1015\u101c\u1000\u103a\u1010\u102e\u1014\u1019\u103a',
    'badge.first_workout.name': '\u1015\u1011\u1019\u1021\u1006\u1004\u1037\u103a\u1019\u103b\u102c\u1038',
    'badge.first_workout.narrative':
        '\u1021\u101b\u100a\u103a\u1021\u1001\u103b\u1004\u103a\u1038\u101b\u101b\u103e\u102d\u101b\u1014\u103a \u1015\u1011\u1019\u1014\u1031\u1037\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1019\u103e\u102f\u1000\u102d\u102f \u1015\u103c\u102e\u1038\u1021\u1031\u102c\u1004\u103a\u101c\u102f\u1015\u103a\u1015\u102b\u104b',
    'badge.first_workout.detail1':
        '\u101b\u100a\u103a\u1019\u103e\u1014\u103a\u1038\u1001\u103b\u1000\u103a:  1 \u101b\u1000\u103a\u1021\u1010\u103d\u1004\u103a\u1038\u1021\u1031\u102c\u1000\u103a\u1015\u102b\u101e\u1010\u103a\u1019\u103e\u1010\u103a\u1011\u102c\u1038\u1010\u1032\u1037\u1021\u1010\u102d\u102f\u1004\u103a\u1038\u1015\u102e\u1038\u1021\u1031\u102c\u1004\u103a\u101c\u102f\u1015\u103a\u1015\u102b\u104b',
    'badge.first_workout.detail2':
        'Upper \u101b\u100a\u103a\u1019\u103e\u1014\u103a\u1038\u1001\u103b\u1000\u103a: \u1005\u102f\u1005\u102f\u1015\u1031\u102b\u1004\u103a\u1038 8 reps (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise)\u0964',
    'badge.first_workout.detail3':
        'Core \u101b\u100a\u103a\u1019\u103e\u1014\u103a\u1038\u1001\u103b\u1000\u103a: \u1005\u102f\u1005\u102f\u1015\u1031\u102b\u1004\u103a\u1038 10 reps (Sit-up)\u0964',
    'badge.first_workout.detail4':
        'Lower \u101b\u100a\u103a\u1019\u103e\u1014\u103a\u1038\u1001\u103b\u1000\u103a: \u1005\u102f\u1005\u102f\u1015\u1031\u102b\u1004\u103a\u1038 12 reps (Squat / Leg Extension)(\u1010\u1005\u103a\u1001\u102f\u1019\u101f\u102f\u1010\u103a\u1010\u1005\u103a\u1001\u102f)\u0964',
    'badge.prep.name': '15-\u101b\u1000\u103a \u1015\u103c\u1004\u103a\u1006\u1004\u103a\u1019\u103e\u102f',
    'badge.prep.narrative': '15-\u101b\u1000\u103a \u1015\u103c\u1004\u103a\u1006\u1004\u103a\u1019\u103e\u102f \u1005\u1014\u1005\u103a\u1016\u103c\u1004\u1037\u103a \u1010\u100a\u103a\u1019\u103c\u1032\u1019\u103e\u102f \u1010\u100a\u103a\u1006\u1031\u102c\u1000\u103a\u1015\u102b\u104b',
    'badge.prep.detail1':
        '5 \u101b\u1000\u103a \u101c\u103e\u102f\u1015\u103a\u101b\u103e\u102c\u1038 + 2 \u101b\u1000\u103a \u1014\u102c\u1038 \u1005\u1000\u103a\u101d\u1014\u103a\u1038\u1016\u103c\u1004\u1037\u103a 15 \u101b\u1000\u103a \u1015\u103c\u1004\u103a\u1006\u1004\u103a\u1019\u103e\u102f (6-7 \u101b\u1000\u103a\u1014\u103e\u1004\u1037\u103a 13-14 \u101b\u1000\u103a\u101e\u100a\u103a \u1014\u102c\u1038\u101b\u1000\u103a)\u104b',
    'badge.prep.detail2':
        '1-3 \u101b\u1000\u103a: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': '4-5 \u101b\u1000\u103a: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': '8-12 \u101b\u1000\u103a: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': '15 \u101b\u1000\u103a: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = \u1010\u1005\u103a\u101b\u1000\u103a\u1021\u1010\u103d\u1004\u103a\u1038 \u1021\u1019\u103b\u102d\u102f\u1038\u1021\u1005\u102c\u1038\u1021\u101c\u102d\u102f\u1000\u103a \u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u101e\u1031\u102c sessions \u1021\u101b\u1031\u1021\u1010\u103d\u1000\u103a\u104b \u1014\u102c\u1038\u101b\u1000\u103a\u1019\u103b\u102c\u1038\u101e\u100a\u103a \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1019\u1010\u1000\u103a\u1015\u102b\u104b',
    'badge.prep.detail8':
        '\u101c\u103e\u102f\u1015\u103a\u101b\u103e\u102c\u1038\u101b\u1000\u103a (workout day) \u1010\u1005\u103a\u101b\u1000\u103a\u1015\u103b\u1000\u103a\u101e\u103d\u102c\u1038\u101b\u1004\u103a prep progress \u1000\u102d\u102f reset \u101c\u102f\u1015\u103a\u1015\u103c\u102e\u1038 \u1014\u1031\u102c\u1000\u103a\u1010\u1005\u103a\u1000\u103c\u102d\u1019\u103a \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1010\u1032\u1037\u1014\u1031\u1037\u1000 Day 1 \u1021\u1016\u103c\u1005\u103a \u1015\u103c\u1014\u103a\u1005\u1015\u102b\u1019\u101a\u103a\u104b',
    'badge.bronze.name': '\u101c 1 \u1000\u103c\u1031\u1038',
    'badge.bronze.narrative': '\u1021\u1015\u103c\u100a\u1037\u103a\u1021\u1005\u102f\u1036 \u1005\u1014\u1005\u103a\u1021\u1010\u103d\u1000\u103a \u1021\u1001\u103c\u1031\u1001\u1036\u101c\u104b',
    'badge.bronze.detail1':
        '5 \u101c\u103e\u102f\u1015\u103a\u101b\u103e\u102c\u1038 + 2 \u1014\u102c\u1038 \u1005\u1000\u103a\u101d\u1014\u103a\u1038\u1016\u103c\u1004\u1037\u103a \u1021\u101b\u100a\u103a\u1021\u1001\u103b\u1004\u103a\u1038\u101b\u1000\u103a 30 \u101b\u1000\u103a\u104b',
    'badge.bronze.detail2':
        'Upper \u1014\u1031\u1037\u1005\u1009\u103a: 18 reps + 3 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise \u1015\u1031\u102b\u1004\u103a\u1038\u1005\u100a\u103a\u1038)\u104b',
    'badge.bronze.detail3': 'Core \u1014\u1031\u1037\u1005\u1009\u103a: 24 reps + 3 sets (Sit-up)\u104b',
    'badge.bronze.detail4':
        'Lower \u1014\u1031\u1037\u1005\u1009\u103a: 30 reps + 3 sets (Squat / Leg Extension \u1015\u1031\u102b\u1004\u103a\u1038\u1005\u100a\u103a\u1038)\u104b',
    'badge.bronze.detail5': '\u1014\u1031\u1037\u1005\u1009\u103a \u1021\u1000\u1014\u103a\u1037\u1021\u101e\u1010\u103a\u1000\u103b\u1031\u102c\u103a Reps/Sets \u1019\u1015\u102b\u101d\u1004\u103a\u1015\u102b\u104b',
    'badge.bronze.detail6':
        '\u1010\u1005\u103a\u101b\u1000\u103a\u1015\u103b\u1000\u103a\u1000\u103d\u1000\u103a\u101e\u103d\u102c\u1038\u101b\u1004\u103a\u1010\u1031\u102c\u1004\u103a Day 1 \u1000\u1014\u1031 \u1021\u1005\u1015\u103c\u1014\u103a\u1005\u101b\u102c\u1019\u101c\u102d\u102f\u1015\u102b\u104b',
    'badge.silver.name': '\u101c 2 \u1004\u103d\u1031',
    'badge.silver.narrative': '\u1015\u102d\u102f\u1019\u102d\u102f\u1019\u103c\u1004\u1037\u103a\u1019\u102c\u1038\u1010\u1032\u1037 \u1015\u1019\u102c\u100f\u101c\u102d\u102f\u1021\u1015\u103a\u101e\u100a\u1037\u103a \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u101c\u104b',
    'badge.silver.detail1':
        '5 \u101c\u103e\u102f\u1015\u103a\u101b\u103e\u102c\u1038 + 2 \u1014\u102c\u1038 \u1005\u1000\u103a\u101d\u1014\u103a\u1038\u1016\u103c\u1004\u1037\u103a \u1021\u101b\u100a\u103a\u1021\u1001\u103b\u1004\u103a\u1038\u101b\u1000\u103a 30 \u101b\u1000\u103a\u104b',
    'badge.silver.detail2':
        'Upper \u1014\u1031\u1037\u1005\u1009\u103a: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise \u1015\u1031\u102b\u1004\u103a\u1038\u1005\u100a\u103a\u1038)\u104b',
    'badge.silver.detail3': 'Core \u1014\u1031\u1037\u1005\u1009\u103a: 32 reps + 4 sets (Sit-up)\u104b',
    'badge.silver.detail4':
        'Lower \u1014\u1031\u1037\u1005\u1009\u103a: 40 reps + 4 sets (Squat / Leg Extension \u1015\u1031\u102b\u1004\u103a\u1038\u1005\u100a\u103a\u1038)\u104b',
    'badge.silver.detail5':
        '\u101c\u103e\u102f\u1015\u103a\u101b\u103e\u102c\u1038\u101b\u1000\u103a\u1019\u103b\u102c\u1038\u101e\u102c \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1010\u103d\u1000\u103a\u1015\u102b\u1010\u101a\u103a\u104b \u1014\u102c\u1038\u101b\u1000\u103a\u1000\u102d\u102f \u1019\u1010\u103d\u1000\u103a\u1015\u102b\u104b',
    'badge.silver.detail6':
        '\u1010\u1005\u103a\u101b\u1000\u103a\u1015\u103b\u1000\u103a\u1000\u103d\u1000\u103a\u101e\u103d\u102c\u1038\u101b\u1004\u103a\u1010\u1031\u102c\u1004\u103a Day 1 \u1000\u1014\u1031 \u1021\u1005\u1000\u1015\u103c\u1014\u103a\u1005\u1005\u101b\u102c\u1019\u101c\u102d\u102f\u1015\u102b\u104b',
    'badge.gold.name': '\u101c 3 \u101b\u103d\u103e\u1031',
    'badge.gold.narrative': '\u1000\u103c\u1036\u1037\u1001\u102d\u102f\u1004\u103a\u101e\u1000\u103a\u101e\u102c\u1019\u103e\u102f\u1019\u103c\u1004\u1037\u103a \u1010\u1000\u103a\u1005\u1031\u101e\u1031\u102c \u101c\u104b',
    'badge.gold.detail1':
        '5 \u101c\u103e\u102f\u1015\u103a\u101b\u103e\u102c\u1038 + 2 \u1014\u102c\u1038 \u1005\u1000\u103a\u101d\u1014\u103a\u1038\u1016\u103c\u1004\u1037\u103a \u1021\u101b\u100a\u103a\u1021\u1001\u103b\u1004\u103a\u1038\u101b\u1000\u103a 30 \u101b\u1000\u103a\u0964',
    'badge.gold.detail2':
        'Upper \u1014\u1031\u1037\u1005\u1009\u103a: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise \u1015\u1031\u102b\u1004\u103a\u1038\u1005\u100a\u103a\u1038)\u104b',
    'badge.gold.detail3': 'Core \u1014\u1031\u1037\u1005\u1009\u103a: 40 reps + 4 sets (Sit-up)\u104b',
    'badge.gold.detail4':
        'Lower \u1014\u1031\u1037\u1005\u1009\u103a: 50 reps + 4 sets (Squat / Leg Extension \u1015\u1031\u102b\u1004\u103a\u1038\u1005\u100a\u103a\u1038)\u104b',
    'badge.gold.detail5':
        '\u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f\u1000\u102d\u102f \u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u101e\u1031\u102c logs \u1016\u103c\u1004\u1037\u103a\u1010\u103d\u1000\u103a\u1015\u103c\u102e\u1038 \u1021\u1000\u1014\u103a\u1037\u1021\u101e\u1010\u103a\u1000\u103b\u1031\u102c\u103a Reps \u1019\u1010\u103d\u1000\u103a\u1015\u102b\u104b',
    'badge.gold.detail6':
        '\u1010\u1005\u103a\u101b\u1000\u103a\u1015\u103b\u1000\u103a\u1000\u103d\u1000\u103a\u101e\u103d\u102c\u1038\u101b\u1004\u103a\u1010\u1031\u102c\u1004\u103a Day 1 \u1000\u1014\u1031 \u1021\u1005\u1015\u103c\u1014\u103a\u1005\u101b\u102c\u1019\u101c\u102d\u102f\u1015\u102b\u104b',
    'badge.default.goal': '\u101b\u100a\u103a\u1019\u103e\u1014\u103a\u1038\u1001\u103b\u1000\u103a: {description}',
    'badge.default.requirement': '\u101c\u102d\u102f\u1021\u1015\u103a\u1001\u103b\u1000\u103a: \u1021\u101b\u100a\u103a\u1021\u1001\u103b\u1004\u103a\u1038\u101b\u1000\u103a {requirement} \u101b\u1000\u103a\u104b',
    'badge.default.status': '\u101c\u1000\u103a\u101b\u103e\u102d: {progress}/{requirement}.',
    'badge.poster.badge_label': 'Badge',
    'badge.poster.user_label': '\u101b\u101b\u103e\u102d\u101e\u1030',
    'badge.poster.requirements_label': '\u1021\u101b\u100a\u103a\u1021\u1001\u103b\u1004\u103a\u1038 \u1012\u1031\u1010\u102c',
    'leaderboard.title': 'Leaderboard',
    'leaderboard.achievements': '\u1021\u1031\u102c\u1004\u103a\u1019\u103c\u1004\u103a\u1019\u103e\u102f\u1019\u103b\u102c\u1038',
    'leaderboard.global': '\u1000\u1019\u1039\u1018\u102c\u101c\u102f\u1036\u1038\u1006\u102d\u102f\u1004\u103a\u101b\u102c',
    'leaderboard.achievement_progress': '\u1021\u1031\u102c\u1004\u103a\u1019\u103c\u1004\u103a\u1019\u103e\u102f \u1010\u102d\u102f\u1038\u1010\u1000\u103a\u1019\u103e\u102f',
    'leaderboard.personal_bests': '\u1000\u102d\u102f\u101a\u103a\u101b\u1031\u1038\u1021\u1000\u1031\u102c\u1004\u103a\u1038\u1006\u102f\u1036\u1038',
    'leaderboard.most_reps': 'Reps \u1021\u1019\u103b\u102c\u1038\u1006\u102f\u1036\u1038',
    'leaderboard.best_accuracy': '\u1021\u1000\u1031\u102c\u1004\u103a\u1038\u1006\u102f\u1036\u1038 \u1010\u102d\u1000\u103b\u1019\u103e\u102f',
    'leaderboard.longest_streak': '\u1021\u101b\u103e\u100a\u103a\u1006\u102f\u1036\u1038 \u1006\u1000\u103a\u1010\u102d\u102f\u1000\u103a',
    'leaderboard.days': '\u101b\u1000\u103a',
    'leaderboard.global_simulated': '\u1000\u1019\u1039\u1018\u102c\u101c\u102f\u1036\u1038\u1006\u102d\u102f\u1004\u103a\u101b\u102c Leaderboard (\u1005\u1019\u103a\u1038\u101e\u1015\u103a)',
    'leaderboard.points': '{score} \u1019\u103e\u1010\u103a',
    'recordings.tab.recordings': '\u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038',
    'recordings.tab.profile': '\u1015\u101b\u102d\u102f\u1016\u102d\u102f\u1004\u103a',
    'recordings.failed_load': 'Recording \u1019\u1010\u1004\u103a\u1014\u102d\u102f\u1004\u103a\u1015\u102b',
    'recordings.empty': '\u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u101e\u1031\u102c \u1017\u102e\u1012\u102e\u101a\u102d\u102f\u1019\u101b\u103e\u102d\u1015\u102b',
    'recordings.file_not_found': '\u1017\u102e\u1012\u102e\u101a\u102d\u102f\u1016\u102d\u102f\u1004\u103a \u1019\u1010\u103d\u1031\u1037\u1015\u102b',
    'recordings.file_incomplete': 'Recording \u1016\u102d\u102f\u1004\u103a \u1019\u1015\u103c\u100a\u1037\u103a\u1005\u102f\u1036\u1015\u102b\u104b \u1015\u103c\u1014\u103a\u1019\u103e\u1010\u103a\u1015\u102b\u104b',
    'profile.guest_name': '\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u1030',
    'profile.user_name_label': '\u1021\u101e\u102f\u1036\u1038\u1015\u103c\u102f\u101e\u1030 \u1014\u102c\u1019\u100a\u103a',
    'profile.edit_name': '\u1015\u103c\u1004\u103a\u1019\u100a\u103a',
    'profile.name_hint': '\u1014\u102c\u1019\u100a\u103a \u101b\u102d\u102f\u1000\u103a\u1011\u100a\u1037\u103a\u1015\u102b',
    'profile.save_name': '\u101e\u102d\u1019\u103a\u1038\u1019\u100a\u103a',
    'profile.photo_title': '\u1015\u101b\u102d\u102f\u1016\u102d\u102f\u1004\u103a \u1013\u102c\u1010\u103a\u1015\u102f\u1036',
    'profile.photo_subtitle':
        '\u1000\u102d\u102f\u101a\u103a\u101c\u102f\u1036\u1038\u1015\u103c\u100a\u1037\u103a\u1015\u102f\u1036\u1000\u102d\u102f\u1011\u100a\u1037\u103a\u1015\u103c\u102e\u1038 \u1015\u101b\u102d\u102f\u1016\u102d\u102f\u1004\u103a\u1000\u102d\u102f \u1000\u102d\u102f\u101a\u103a\u1015\u102d\u102f\u1004\u103a\u1021\u1031\u102c\u1004\u103a\u101c\u102f\u1015\u103a\u1015\u102b\u104b',
    'profile.photo_add': '\u1013\u102c\u1010\u103a\u1015\u102f\u1036 \u1011\u100a\u1037\u103a\u1019\u100a\u103a',
    'profile.photo_change': '\u1013\u102c\u1010\u103a\u1015\u102f\u1036 \u1015\u103c\u1031\u102c\u1004\u103a\u1038\u1019\u100a\u103a',
    'profile.photo_remove': '\u1013\u102c\u1010\u103a\u1015\u102f\u1036 \u1016\u101a\u103a\u1019\u100a\u103a',
    'profile.photo_remove_confirm': '\u1015\u101b\u102d\u102f\u1016\u102d\u102f\u1004\u103a \u1013\u102c\u1010\u103a\u1015\u102f\u1036\u1000\u102d\u102f \u1016\u101a\u103a\u101b\u103e\u102c\u1038\u1019\u101c\u102c\u1038?',
    'profile.photo_too_large':
        '\u1013\u102c\u1010\u103a\u1015\u102f\u1036 \u1021\u101b\u103d\u101a\u103a\u1021\u1005\u102c\u1038\u1000\u103c\u102e\u1038\u1014\u1031\u1015\u102b\u1010\u101a\u103a\u104b \u1015\u102d\u102f\u101e\u1031\u1038\u1010\u1032\u1037\u1015\u102f\u1036\u1000\u102d\u102f\u101b\u103d\u1031\u1038\u1015\u102b\u104b',
    'profile.photo_error':
        '\u1013\u102c\u1010\u103a\u1015\u102f\u1036\u1000\u102d\u102f \u101e\u102d\u1019\u103a\u1038\u1019\u101b\u1015\u102b\u104b \u1021\u1001\u103c\u102c\u1038\u1015\u102f\u1036\u1014\u1032\u1037 \u1015\u103c\u1014\u103a\u1000\u103c\u102d\u102f\u1038\u1005\u102c\u1038\u1015\u102b\u104b',
    'profile.photo_badge_notice':
        '\u1015\u101b\u102d\u102f\u1016\u102d\u102f\u1004\u103a\u1013\u102c\u1010\u103a\u1015\u102f\u1036 \u1019\u1011\u100a\u1037\u103a\u1011\u102c\u1038\u101e\u1031\u1038\u101c\u103b\u103e\u1004\u103a badge \u1015\u102d\u102f\u1005\u1010\u102c\u1010\u103d\u1004\u103a \u101e\u1004\u1037\u103a\u1013\u102c\u1010\u103a\u1015\u102f\u1036 \u1019\u1015\u102b\u101d\u1004\u103a\u1015\u102b\u104b',
    'profile.exercise_totals_title': '\u1005\u102f\u1005\u102f\u1015\u1031\u102b\u1004\u103a\u1038 \u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1019\u103b\u102c\u1038',
    'profile.exercise_totals_subtitle': '\u1005\u1010\u1004\u103a\u101e\u100a\u1037\u103a\u1014\u1031\u1037\u1019\u103e \u1014\u1031\u102c\u1000\u103a\u1006\u102f\u1036\u1038\u1021\u1011\u102d\u104b',
    'profile.exercise_empty': '\u101c\u1031\u1037\u1000\u103b\u1004\u1037\u103a\u1001\u1014\u103a\u1038\u1012\u1031\u1010\u102c \u1019\u101b\u103e\u102d\u101e\u1031\u1038\u1015\u102b',
    'profile.badges_title': '\u101b\u101b\u103e\u102d\u1011\u102c\u1038\u101e\u1031\u102c Badge \u1019\u103b\u102c\u1038',
    'profile.badges_empty': 'Badge \u1019\u101b\u103e\u102d\u101e\u1031\u1038\u1015\u102b',
    'profile.badge_gallery_saved_note':
        'Badge \u1016\u103d\u1004\u1037\u103a\u101c\u103e\u1005\u103a\u1010\u102d\u102f\u1004\u103a\u1038 \u1015\u102d\u102f\u1005\u1010\u102c\u1000\u102d\u102f gallery album {album} \u1011\u1032 \u1021\u101c\u102d\u102f\u1021\u101c\u103b\u1031\u102c\u1000\u103a \u101e\u102d\u1019\u103a\u1038\u1011\u102c\u1038\u1015\u102b\u1019\u100a\u103a\u104b',
    'iconic.menu.title': '??????????? ????????????',
    'iconic.menu.subtitle':
        '????????????????? ???????????????? premium post-process style ?????????? Program ??????????????? live capture ????????? ???????????????????????? ???????? cinematic ????????? ????????????? ??????????? ?????????????????????',
    'iconic.program.zodiac.eyebrow': 'Post-process signature',
    'iconic.program.zodiac.description':
        '????????????????? zodiac luxury overlay ??? ????????????? ???????? ?? ?????????? palette, symbol, aura tint, engraved style ????? ?????????????? preview ??? Aries art direction ????????????????????',
    'iconic.program.zodiac.tag.sign_themes': '???????? ?? ?????',
    'iconic.program.zodiac.tag.luxury_capsule': 'Luxury capsule',
    'iconic.program.zodiac.tag.embossed_coin': 'Embossed coin',
    'iconic.program.zodiac.footer':
        'Iconic export ????? ???????????????? Live capture ??? ??????????????????? ?????????????? luxury treatment ??? recording ?????? ?????????????',
    'iconic.program.festival.eyebrow': '?????????? ?????????',
    'iconic.program.festival.description':
        '???????? world festival ????????? sporting event ?????????????? luxury overlay ????????????? ????????????? Festival ??????????????? color palette, ring glow, accuracy bar gradient ??? overlay branding ???????????????????',
    'iconic.program.festival.tag.festivals': '??????? ??',
    'iconic.program.festival.tag.date_aware': '????????????',
    'iconic.program.festival.tag.luxury_overlay': 'Luxury overlay',
    'iconic.program.festival.footer':
        'Theme ? ?????????????? ???????????? ??????????????????????????? Workout ??? record ????????????? active festival style ??? post-processing ?????? ?????????????',
    'iconic.program.studio.eyebrow': '??????????????????????',
    'iconic.program.studio.description':
        'Rep counter, accuracy bar, narrative flow, icons, color palettes ??? finish controls ?????? editable ???????????? ?????????? premium overlay system ??? ???????????????',
    'iconic.program.studio.tag.custom_program': 'Custom program',
    'iconic.program.studio.tag.luxury_editor': 'Luxury editor',
    'iconic.program.studio.tag.premium_control': 'Premium control',
    'iconic.program.studio.footer':
        '????????????? zodiac ????????? festival style ??????? ?????????????????????? luxury overlay ??? ??????????? ?? option ??????????',
    'iconic.program.studio.action': 'Studio ????????',
    'iconic.program.standard.eyebrow': '?????????? ???????',
    'iconic.program.standard.description':
        'Branded cinematic look ?????????????? ?????? simple overlay ??? ????????????????',
    'iconic.program.standard.tag.default': '???????',
    'iconic.program.standard.tag.minimal': '?????????',
    'iconic.program.standard.tag.fast_export': '????? export',
    'iconic.program.standard.footer':
        'Premium art direction ????? ?????? export style ????? ??????????? ?? option ??? ???????',
    'iconic.info.title': '???????????',
    'iconic.info.step1': '1. ????????? program ????????????',
    'iconic.info.step2': '2. ?????????????? workout ??? record ???????',
    'iconic.info.step3':
        '3. ?????????? style ??? recording ?????? post-processing ???????? ?????????????',
    'iconic.preview.post_process': 'POST-PROCESS PREVIEW',
    'iconic.preview.standard.caption':
        '??????? export overlay ?\n???????????????? look ??? ?????????????????',
    'iconic.preview.editable_luxe': 'EDITABLE LUXE',
    'camera.overlay.skeleton': '\u1021\u101b\u102d\u102f\u1038\u1015\u102f\u1036',
    'camera.overlay.stop': '\u101b\u1015\u103a',
    'camera.overlay.record': '\u1019\u103e\u1010\u103a\u1010\u1019\u103a\u1038',
    'camera.overlay.complete': '\u1015\u103c\u102e\u1038\u1006\u102f\u1036\u1038',
    'lang.en': '\u1021\u1004\u103a\u1039\u1002\u101c\u102d\u1015\u103a',
    'lang.es': '\u1005\u1015\u102d\u1014\u103a',
    'lang.ja': '\u1002\u103b\u1015\u1014\u103a',
    'lang.my': '\u1017\u1019\u102c',
    'lang.hi': '\u101f\u102d\u1014\u1039\u1012\u102e',
    'lang.pt': '\u1015\u1031\u102b\u103a\u1010\u1030\u1002\u102e',
    'lang.zh': '\u1019\u1014\u103a\u1012\u101b\u1004\u103a\u1038 \u1010\u101b\u102f\u1010\u103a',
    'lang.de': '\u1002\u103b\u102c\u1019\u1014\u103a',
  };

  static const Map<String, String> _hiValues = {
    'app.title': 'H&F',
    'nav.exercises': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®',
    'nav.progress': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿',
    'nav.recordings': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â²',
    'common.cancel': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¦ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'common.retry': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã†â€™ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'common.load_exercises': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'common.clear_data': 'ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'common.ok': 'OK',
    'common.close': 'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¦ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'common.error_with_message': 'ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿: {message}',
    'common.copy': 'कॉपी',
    'common.remove': 'हटाएँ',
    'premium.license.title': 'प्रीमियम लाइसेंस',
    'premium.license.heading': 'संपर्क और प्रीमियम लाइसेंस खरीद',
    'premium.license.contact_us': 'संपर्क करें',
    'premium.license.active': 'प्रीमियम सक्रिय',
    'premium.license.inactive': 'प्रीमियम निष्क्रिय',
    'premium.license.expires': 'समाप्ति: {date}',
    'premium.license.field_label': 'लाइसेंस कुंजी',
    'premium.license.field_hint': 'HF-XXXX-XXXX-XXXX-XXXX',
    'premium.license.enter_key': 'कृपया अपनी लाइसेंस कुंजी दर्ज करें।',
    'premium.license.wait': 'कृपया प्रतीक्षा करें...',
    'premium.license.activate': 'लाइसेंस सक्रिय करें',
    'premium.license.deactivate_device': 'इस डिवाइस पर निष्क्रिय करें',
    'premium.license.security_notes': 'सुरक्षा नोट्स',
    'premium.license.security_body':
        'यदि सक्रियण सर्वर पर सत्यापित होता है, तो इसे एन्क्रिप्टेड सुरक्षित स्टोरेज में सहेजा जाता है और इस डिवाइस से जोड़ा जाता है।',
    'premium.license.disabled_device':
        'इस डिवाइस पर प्रीमियम निष्क्रिय कर दिया गया है।',
    'premium.license.copied': 'कॉपी किया गया: {value}',
    'premium.license.already_active':
        'लाइसेंस इस डिवाइस पर पहले से सक्रिय है।',
    'premium.license.activated': 'प्रीमियम सफलतापूर्वक सक्रिय हो गया।',
    'overlay.studio.preview_phase': 'पूर्वावलोकन चरण',
    'overlay.studio.preview_phase_subtitle':
        'पिन किए गए पूर्वावलोकन के अंदर चरण नियंत्रण रखे बिना डेमो स्थिति बदलें।',
    'overlay.studio.master_mode': 'मास्टर मोड',
    'overlay.studio.master_mode_subtitle':
        'एक्सपोर्ट प्रदर्शन और लक्ज़री ओवरले व्यवहार को समायोजित करें।',
    'overlay.studio.performance_mode': 'परफॉर्मेंस मोड',
    'overlay.studio.apply_festival_luxe': 'Apply World Festival Luxe',
    'overlay.studio.remove_festival_luxe': 'Remove World Festival Luxe',
    'overlay.studio.text_branding': 'टेक्स्ट और ब्रांडिंग',
    'overlay.studio.text_branding_subtitle':
        'लक्ज़री नाम, सबटाइटल टोन और सिग्नेचर लाइन।',
    'overlay.studio.show_branding_bar': 'ब्रांडिंग बार दिखाएँ',
    'overlay.studio.show_branding_bar_subtitle':
        'ऊपरी लोगो और टेक्स्ट बार को चालू या बंद करें।',
    'overlay.studio.title_field': 'शीर्षक',
    'overlay.studio.subtitle_field': 'उपशीर्षक',
    'overlay.studio.branding_field': 'ब्रांडिंग',
    'overlay.studio.banner_border': 'बैनर बॉर्डर',
    'overlay.studio.banner_border_subtitle':
        'TikTok शैली का बहुरंगी ग्रेडिएंट बॉर्डर।',
    'overlay.studio.narrative_flow': 'नैरेटिव फ्लो',
    'overlay.studio.narrative_flow_subtitle':
        'ये 4 टेक्स्ट संकेत केवल पोस्ट-प्रोसेस में दिखाई देते हैं। हर टेक्स्ट के साथ रेप नंबर सेट करें। टेक्स्ट तभी दिखेगा जब वही रेप 80% सटीकता तक पहुँचे।',
    'overlay.studio.cue_label': 'संकेत {number}',
    'overlay.studio.icon_system': 'आइकन सिस्टम',
    'overlay.studio.icon_system_subtitle':
        'हर चरण के लिए SVG आइकन आयात करें। हम सफेद पृष्ठभूमि हटाते हैं, किनारों को साफ करते हैं और एक्सपोर्ट आउटपुट को बेहतर रखते हैं।',
    'overlay.studio.default_slot': 'डिफ़ॉल्ट',
    'overlay.studio.up_phase': 'UP चरण',
    'overlay.studio.down_phase': 'DOWN चरण',
    'overlay.studio.color_system': 'रंग प्रणाली',
    'overlay.studio.color_system_subtitle':
        'मुख्य, धात्विक एक्सेंट और चरण-विशिष्ट रंग नियंत्रण।',
    'overlay.studio.primary_color': 'प्राथमिक',
    'overlay.studio.secondary_color': 'द्वितीयक',
    'overlay.studio.accent_color': 'एक्सेंट',
    'overlay.studio.layout_control': 'लेआउट नियंत्रण',
    'overlay.studio.layout_control_subtitle':
        'एक्यूरेसी और रेप क्लस्टर को स्थानांतरित करें, ब्रांडिंग बार को स्थिर रखें और कुल स्केल समायोजित करें।',
    'overlay.studio.counter_cluster': 'काउंटर क्लस्टर',
    'overlay.studio.stats_card_slot': 'स्टैट्स कार्ड स्लॉट',
    'overlay.studio.global_scale': 'कुल स्केल',
    'overlay.studio.overlay_opacity': 'ओवरले अपारदर्शिता',
    'overlay.studio.luxe_finish': 'लक्ज़ फिनिश',
    'overlay.studio.luxe_finish_subtitle':
        'मौजूदा थीम सिस्टम बदले बिना प्रीमियम माहौल जोड़ें।',
    'overlay.studio.vignette_focus': 'विग्नेट फोकस',
    'overlay.studio.bloom_glow': 'ब्लूम ग्लो',
    'overlay.studio.sparkle_field': 'स्पार्कल फ़ील्ड',
    'overlay.studio.sheen_sweep': 'शीन स्वीप',
    'overlay.studio.border_width': 'बॉर्डर चौड़ाई',
    'overlay.studio.rotation': 'घुमाव',
    'overlay.studio.colors': 'रंग ({count})',
    'overlay.studio.presets': 'प्रीसेट',
    'overlay.studio.svg_import_failed': 'SVG आयात विफल: {error}',
    'overlay.studio.no_svg_selected': 'अभी तक कोई SVG चयनित नहीं है',
    'overlay.studio.svg_description_selected':
        'एक्सपोर्ट इस साफ किए गए SVG का उपयोग करता है। सफेद पृष्ठभूमि और असमान किनारे अपने आप ठीक कर दिए जाते हैं।',
    'overlay.studio.svg_description_empty':
        'केवल SVG। एक फ़ाइल चुनें और हम साफ़ एक्सपोर्ट बैज के लिए इसे सुधार देंगे।',
    'overlay.studio.fallback_badge': 'फ़ॉलबैक बैज: {glyph}',
    'overlay.studio.importing': 'आयात हो रहा है...',
    'overlay.studio.replace_svg': 'SVG बदलें',
    'overlay.studio.choose_svg': 'SVG चुनें',
    'overlay.studio.supported_input':
        'समर्थित इनपुट: केवल `.svg` फ़ाइलें।',
    'recordings.player_title': 'वर्कआउट रिकॉर्डिंग',
    'analytics.no_data_available': 'कोई डेटा उपलब्ध नहीं है',
    'analytics.chart.date': 'तारीख',
    'analytics.chart.accuracy_percent': 'सटीकता (%)',
    'analytics.chart.repetitions': 'रेप्स',
    'analytics.title': 'उन्नत विश्लेषण',
    'analytics.performance_summary': 'प्रदर्शन सारांश',
    'analytics.consistency': 'निरंतरता',
    'analytics.improvement': 'सुधार',
    'analytics.peak': 'सर्वोच्च',
    'exercise.recording.exporting_video': 'वीडियो एक्सपोर्ट हो रहा है',
    'exercise.recording.applying_overlay_effects':
        'आपके चुने हुए ओवरले प्रभाव लागू किए जा रहे हैं...',
    'exercise.recording.saved_raw_fallback':
        'वीडियो सहेज लिया गया। ओवरले एक्सपोर्ट के बजाय मूल रिकॉर्डिंग उपयोग हुई।',
    'exercise.recording.saved_without_overlay':
        'पोस्ट-प्रोसेस ओवरले के बिना वीडियो सहेजा गया: {error}',
    'premium.badge': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â®',
    'premium.menu_only': 'ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å“ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'home.exercises_list': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'home.exercises_simple_form': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®',
    'home.no_supported_exercises': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'home.check_exercise_config': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã†â€™ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'home.error_loading_exercise': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿: {error}',
    'home.image_reference_count': '{count} ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â­ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°',
    'home.today_progress_premium': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ (ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â®)',
    'home.today_progress_locked_desc':
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å“ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'home.today_progress': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿',
    'home.total_reps': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸',
    'home.workouts': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸',
    'home.calories': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'home.daily_goal': 'ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯: {current}/{goal}',
    'home.daily_goal_achieved': 'ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â !',
    'home.progress_premium_title': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ',
    'home.progress_premium_message':
        'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã†â€™ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'home.recordings_premium_title': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'home.recordings_premium_message':
        'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'home.simple_form': '{name} ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®',
    'home.quick_form_summary': 'ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¶',
    'home.form_images': 'ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°',
    'home.exercise_list_notice_title': 'ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¦ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'home.exercise_list_notice_message':
        'ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â° exercise form ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã†â€™ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸: situp exercise ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'home.simple_form_notice':
        'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸:\nÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ AI ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¦ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ , ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã†â€™ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¦ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª 100% ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\nÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¥Ã‚Â¤\n\nÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ :\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â°/ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¥Ã‚Â¤\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.guide.title': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡',
    'exercise.guide.step1':
        'ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.guide.step2':
        'ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.guide.step3':
        'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.guide.step4':
        'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° Complete ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° Save ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.error.setup_title': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿',
    'exercise.error.setup_message': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â­ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾: {error}',
    'exercise.error.pose_title': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿',
    'exercise.error.pose_message':
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã†â€™ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ Google Play Services ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.premium.landmarks': 'ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å“ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.premium.recording':
        'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.recording.failed_start':
        'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬: {error}',
    'exercise.recording.permission_denied':
        'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨/ÃƒÂ Ã‚Â¤Ã¢â‚¬ËœÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã†â€™ÃƒÂ Ã‚Â¤Ã‚Â¤',
    'exercise.recording.failed_save': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'exercise.recording.saved_gallery': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ({album})',
    'exercise.recording.saved_app': 'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾: {path}',
    'exercise.recording.saved_phone': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'exercise.recording.failed_video': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â²: {error}',
    'exercise.recording.preparing_luxury_video':
        'ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.recording.keep_screen_open':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã†â€™ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.premium.title': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â°',
    'exercise.premium.not_now': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'exercise.premium.upgrade': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡',
    'exercise.premium.required_title': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'exercise.premium.required_message':
        'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ, ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.camera.error_title': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿',
    'exercise.camera.error_message':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'exercise.counting_premium': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ (ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â®)',
    'exercise.summary.title': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾!',
    'exercise.summary.total_reps': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸',
    'exercise.summary.avg_accuracy': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'exercise.summary.duration': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿',
    'exercise.summary.seconds': '{value} ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¡',
    'exercise.summary.best_accuracy': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'exercise.summary.close': 'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¦ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'exercise.summary.view_details': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ',
    'exercise.card.type.dynamic': 'ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'exercise.card.type.static': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'exercise.card.view.front': 'ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡',
    'exercise.card.view.side': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡',
    'exercise.card.total_reps': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸',
    'exercise.card.avg_accuracy': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'exercise.card.select': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'exercise.time.today': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã…â€œ',
    'exercise.time.yesterday': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â²',
    'exercise.time.days_ago': '{value} ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡',
    'exercise.time.weeks_ago': '{value} ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡',
    'exercise.time.months_ago': '{value} ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡',
    'guide.squat.subtitle':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‹Å“ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.squat.step1': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã…â€™ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.squat.step2':
        'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‹Å“ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.squat.step3': 'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‹Å“ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.pushup.subtitle':
        'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.pushup.step1':
        'ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã…â€™ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.pushup.step2':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ 45 ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.pushup.step3': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¶ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.situp.subtitle': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.situp.step1': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â  ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã‹Å“ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.situp.step2': 'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.situp.step3': 'ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡-ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.bicep.subtitle': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.bicep.step1': 'ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡, ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.bicep.step2': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.bicep.step3': 'ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡-ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.shoulder.subtitle':
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.shoulder.step1': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â°, ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.shoulder.step2': 'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.shoulder.step3': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.leg.subtitle':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‹Å“ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.leg.step1': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â  ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¥ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.leg.step2': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‹Å“ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'guide.leg.step3': 'ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'settings.title': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸',
    'settings.premium_features': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸',
    'settings.app_settings': 'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸',
    'settings.profile_name': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®',
    'settings.appearance': 'ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'settings.data': 'ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'settings.about': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¯',
    'settings.premium_account': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸',
    'settings.unlock_all_features': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'settings.voice_counting': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€',
    'settings.speak_count': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã…â€™ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'settings.voice_counting_language': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'settings.upgrade_to_premium': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡',
    'settings.upgrade_subtitle': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸, ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'settings.voice_coach': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¡',
    'settings.voice_feedback': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â²-ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'settings.show_landmarks': 'ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â',
    'settings.display_skeleton': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å“ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â',
    'settings.auto_recording': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬ËœÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€',
    'settings.auto_recording_subtitle': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'settings.theme': 'ÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®',
    'settings.language': 'ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'settings.language_subtitle': 'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'settings.clear_data': 'ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'settings.clear_data_subtitle': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â',
    'settings.version': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¨',
    'settings.privacy_policy': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'settings.terms': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'settings.disclaimer': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â£',
    'legal.last_updated': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸: {date}',
    'legal.privacy.content':
        '1) ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã…â€™ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡\n'
        'H&F ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€, ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿, ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¥ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '2) ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â£\n'
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã…â€™ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â€šÂ¬, ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¶, ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¦, ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€  ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬ËœÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '3) ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾, ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨, ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°\n'
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€  ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '4) ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡\n'
        'ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡, ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¬ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡, ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡, ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '5) ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾\n'
        'ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '6) ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â£\n'
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '7) ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¾\n'
        'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ , ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'legal.terms.content':
        'H&F ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '1) ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€\n'
        'H&F ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '2) ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸\n'
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€, ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â£, ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‹Å“ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '3) ÃƒÂ Ã‚Â¤Ã¢â‚¬ËœÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡\n'
        'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¦ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬ËœÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨, ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ËœÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '4) ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â§\n'
        'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â§ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '5) ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã…â€™ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾\n'
        'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â°, ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ H&F ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å“ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '6) ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡\n'
        'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ \"ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ \" ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ , ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '7) ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾\n'
        'H&F ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·, ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢, ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'legal.disclaimer.content':
        'H&F ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€  ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹, ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨, ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '1) ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â®\n'
        'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¦, ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°, ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '2) ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢\n'
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â£, ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¶ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¾, ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â§, ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢, ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '3) ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã…â€™ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨\n'
        'ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€/ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ (ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€) ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¥ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '4) ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â\n'
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å“ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '5) ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬\n'
        'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨, ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '6) ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾\n'
        'ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡, ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬ËœÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤\n\n'
        '7) ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®\n'
        'ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ H&F ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â· ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'settings.select_theme': 'ÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'settings.select_language': 'ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'onboarding.language_title': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'onboarding.language_subtitle': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¦ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'onboarding.name_title': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ?',
    'onboarding.name_subtitle': 'ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'onboarding.name_hint': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'onboarding.name_required': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã†â€™ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'onboarding.disclaimer_title': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â£',
    'onboarding.terms_title': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'onboarding.accept_notice':
        'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'onboarding.accept_checkbox': 'ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â',
    'onboarding.continue': 'ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'onboarding.start_app': 'ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'settings.clear_all_data': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'settings.clear_all_data_desc':
        'ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸, ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'settings.clear_success': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'settings.clear_failed': 'ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â²: {error}',
    'theme.light': 'ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸',
    'theme.dark': 'ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'theme.gold': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡',
    'theme.pink': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'progress.title': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â£',
    'progress.overview': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¨',
    'progress.exercises': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®',
    'progress.badges': 'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ',
    'progress.no_data': 'ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'progress.weekly_summary': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¶',
    'progress.streak_days': '{count} ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'progress.recent_workouts': 'ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸',
    'progress.no_workouts': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'progress.workout_summary': '{reps} ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ {accuracy}% ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'progress.achievements': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â',
    'progress.badges_unlocked': '{unlocked}/{total} ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'progress.view_all_achievements': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'progress.day.sun': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿',
    'progress.day.mon': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â®',
    'progress.day.tue': 'ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â²',
    'progress.day.wed': 'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§',
    'progress.day.thu': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚Â',
    'progress.day.fri': 'ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°',
    'progress.day.sat': 'ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿',
    'progress.time.just_now': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'progress.time.minutes_ago': '{value}m ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡',
    'progress.time.hours_ago': '{value}h ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡',
    'progress.time.days_ago': '{value}d ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡',
    'progress.time.weeks_ago': '{value}w ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡',
    'progress.analytics_intro_title': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'progress.analytics_intro_line1':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ = ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'progress.analytics_intro_line2':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ = ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'progress.analytics_intro_line3':
        'ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ = ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¥ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ (ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ )ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'progress.analytics_intro_line4':
        'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€  ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'progress.read_exercise_analytics_title': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¢ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'progress.read_exercise_analytics_line1':
        'ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ = ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'progress.read_exercise_analytics_line2':
        'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â  ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ = ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¬ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'progress.read_exercise_analytics_line3':
        'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ 6 ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾, ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'progress.read_exercise_analytics_line4':
        'ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'progress.latest_accuracy': 'ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'progress.best_accuracy': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â  ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'progress.trend_vs_previous_session':
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ {sign}{delta}%',
    'progress.last_sessions_accuracy_title': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â° (ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ %)',
    'progress.reps_short': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸',
    'progress.chart_accuracy_trend_legend':
        'ÃƒÂ Ã‚Â¤Ã…Â ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'progress.total_reps_all_time': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ (ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¯)',
    'progress.avg_accuracy_all_sessions': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ (ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°)',
    'progress.sessions': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°',
    'progress.chart_accuracy_trend':
        'ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'progress.no_sessions':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â£ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.empty':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤\nÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.collection': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹',
    'badges.current_status': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿',
    'badges.unlocked_count': '{unlocked}/{total} ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'badges.tier': 'ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â°: {tier}',
    'badges.next_target':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯: {name} ({progress}/{requirement}) - ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² {percent}% ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'badges.how_it_works': 'ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ',
    'badges.guide_1':
        'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ 5 ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ + 2 ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.guide_2':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.guide_3':
        'ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡; ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸/ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.guide_4':
        'ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡: ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ (Upper ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â push-ups, Lower ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â squats)ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.guide_5':
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ; ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.unlocked_on': '{date} ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'badges.tap_full_plan': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'badges.new_unlock_today': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â ! ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¢ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.unlocked_banner':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾! ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.poster_saved_note':
        'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â® {album} ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.poster_save_failed_note':
        'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.no_tier': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'badges.motivation_unlocked':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ; ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â« ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¢ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.motivation_almost':
        'ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â {remaining} ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badges.motivation_keep':
        'ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¢ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'tier.bronze': 'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…â€œ',
    'tier.silver': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°',
    'tier.gold': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡',
    'tier.platinum': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â®',
    'badge.first_workout.name': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â®',
    'badge.first_workout.narrative': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.first_workout.detail1':
        'ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯: ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ 1 ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.first_workout.detail2':
        'Upper ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯: ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² 8 ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise).',
    'badge.first_workout.detail3': 'Core ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯: ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² 10 ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ (Sit-up).',
    'badge.first_workout.detail4':
        'Lower ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯: ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² 12 ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ (Squat / Leg Extension).',
    'badge.prep.name': '15-ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'badge.prep.narrative': '15-ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.prep.detail1':
        '5 ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ + 2 ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¥ 15-ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ (ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ 6-7 ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ 13-14 ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®).',
    'badge.prep.detail2':
        'ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ 1-3: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': 'ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ 4-5: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': 'ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ 8-12: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': 'ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ 15: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â£ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°; ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.prep.detail8':
        'ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ , ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ prep ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€  ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ Day 1 ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.bronze.name': 'ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ 1 ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…â€œ',
    'badge.bronze.narrative': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.bronze.detail1':
        '5 ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ + 2 ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¥ 30 ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.bronze.detail2':
        'Upper ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢: 18 reps + 3 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤).',
    'badge.bronze.detail3': 'Core ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢: 24 reps + 3 sets (Sit-up).',
    'badge.bronze.detail4':
        'Lower ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢: 30 reps + 3 sets (Squat / Leg Extension ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤).',
    'badge.bronze.detail5':
        'ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸/ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.bronze.detail6':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â, ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.silver.name': 'ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ 2 ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°',
    'badge.silver.narrative': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Å“ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.silver.detail1':
        '5 ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ + 2 ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¥ 30 ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.silver.detail2':
        'Upper ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤).',
    'badge.silver.detail3': 'Core ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢: 32 reps + 4 sets (Sit-up).',
    'badge.silver.detail4':
        'Lower ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢: 40 reps + 4 sets (Squat / Leg Extension ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤).',
    'badge.silver.detail5':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡; ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.silver.detail6':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â, ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.gold.name': 'ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ 3 ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡',
    'badge.gold.narrative': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.gold.detail1': '5 ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ + 2 ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¥ 30 ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.gold.detail2':
        'Upper ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤).',
    'badge.gold.detail3': 'Core ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢: 40 reps + 4 sets (Sit-up).',
    'badge.gold.detail4':
        'Lower ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢: 50 reps + 4 sets (Squat / Leg Extension ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤).',
    'badge.gold.detail5':
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ; ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.gold.detail6':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã…Â¸ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â, ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.default.goal': 'ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â·ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯: {description}',
    'badge.default.requirement': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾: {requirement} ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'badge.default.status': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¥ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿: {progress}/{requirement}.',
    'badge.poster.badge_label': 'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ',
    'badge.poster.user_label': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'badge.poster.requirements_label': 'ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'leaderboard.title': 'ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡',
    'leaderboard.achievements': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â',
    'leaderboard.global': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â²',
    'leaderboard.achievement_progress': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿',
    'leaderboard.personal_bests': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸',
    'leaderboard.most_reps': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸',
    'leaderboard.best_accuracy': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'leaderboard.longest_streak': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'leaderboard.days': 'ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨',
    'leaderboard.global_simulated': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ (ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¡)',
    'leaderboard.points': '{score} ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢',
    'recordings.tab.recordings': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡',
    'recordings.tab.profile': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â²',
    'recordings.failed_load': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'recordings.empty': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'recordings.file_not_found': 'ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'recordings.file_incomplete':
        'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â§ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã†â€™ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'profile.guest_name': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾',
    'profile.user_name_label': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®',
    'profile.edit_name': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'profile.name_hint': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'profile.save_name': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'profile.photo_title': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹',
    'profile.photo_subtitle':
        'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'profile.photo_add': 'ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'profile.photo_change': 'ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'profile.photo_remove': 'ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â',
    'profile.photo_remove_confirm': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â?',
    'profile.photo_too_large':
        'ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã†â€™ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'profile.photo_error':
        'ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¥Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬ÂºÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¤Ã‚Â¿ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¸ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'profile.photo_badge_notice':
        'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‹â€ , ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â«ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ ÃƒÂ Ã‚Â¤Ã‚Â¶ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'profile.exercise_totals_title': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â² ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡',
    'profile.exercise_totals_subtitle': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã¢â‚¬â€œÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'profile.exercise_empty': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚ÂµÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¯ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â® ÃƒÂ Ã‚Â¤Ã‚Â¡ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'profile.badges_title': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ',
    'profile.badges_empty': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‹â€  ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'profile.badge_gallery_saved_note':
        'ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¬ ÃƒÂ Ã‚Â¤Ã‚Â­ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã…â€œ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾, ÃƒÂ Ã‚Â¤Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã…Â¸ÃƒÂ Ã‚Â¤Ã‚Â° ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‹â€ ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ ÃƒÂ Ã‚Â¤Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â® {album} ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â ÃƒÂ Ã‚Â¤Ã‚Âª ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Âµ ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¥Ã‚Â¤',
    'iconic.menu.title': 'Ã Â¤â€ Ã Â¤â€¡Ã Â¤â€¢Ã Â¥â€°Ã Â¤Â¨Ã Â¤Â¿Ã Â¤â€¢ Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â€¹Ã Â¤â€”Ã Â¥ÂÃ Â¤Â°Ã Â¤Â¾Ã Â¤Â®',
    'iconic.menu.subtitle':
        'Ã Â¤Â°Ã Â¤Â¿Ã Â¤â€¢Ã Â¥â€°Ã Â¤Â°Ã Â¥ÂÃ Â¤Â¡ Ã Â¤â€¢Ã Â¤Â¿Ã Â¤Â Ã Â¤â€”Ã Â¤Â Ã Â¤ÂµÃ Â¥â‚¬Ã Â¤Â¡Ã Â¤Â¿Ã Â¤Â¯Ã Â¥â€¹ Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â²Ã Â¤Â¿Ã Â¤Â Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â‚¬Ã Â¤Â®Ã Â¤Â¿Ã Â¤Â¯Ã Â¤Â® Ã Â¤ÂªÃ Â¥â€¹Ã Â¤Â¸Ã Â¥ÂÃ Â¤Å¸-Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â€¹Ã Â¤Â¸Ã Â¥â€¡Ã Â¤Â¸ Ã Â¤Â²Ã Â¥ÂÃ Â¤â€¢ Ã Â¤Å¡Ã Â¥ÂÃ Â¤Â¨Ã Â¥â€¡Ã Â¤â€šÃ Â¥Â¤ Ã Â¤Â¹Ã Â¤Â° Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â€¹Ã Â¤â€”Ã Â¥ÂÃ Â¤Â°Ã Â¤Â¾Ã Â¤Â® Ã Â¤â€¢Ã Â¥â€¹ Ã Â¤ÂÃ Â¤Â¸Ã Â¤Â¾ Ã Â¤Â¬Ã Â¤Â¨Ã Â¤Â¾Ã Â¤Â¯Ã Â¤Â¾ Ã Â¤â€”Ã Â¤Â¯Ã Â¤Â¾ Ã Â¤Â¹Ã Â¥Ë† Ã Â¤â€¢Ã Â¤Â¿ Ã Â¤Â²Ã Â¤Â¾Ã Â¤â€¡Ã Â¤Âµ Ã Â¤â€¢Ã Â¥Ë†Ã Â¤ÂªÃ Â¥ÂÃ Â¤Å¡Ã Â¤Â° Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â¦Ã Â¥Å’Ã Â¤Â°Ã Â¤Â¾Ã Â¤Â¨ Ã Â¤Â«Ã Â¥â€¹Ã Â¤Â¨ Ã Â¤ÂªÃ Â¤Â° Ã Â¤â€¦Ã Â¤Â¤Ã Â¤Â¿Ã Â¤Â°Ã Â¤Â¿Ã Â¤â€¢Ã Â¥ÂÃ Â¤Â¤ Ã Â¤â€”Ã Â¤Â°Ã Â¥ÂÃ Â¤Â®Ã Â¥â‚¬ Ã Â¤Â¡Ã Â¤Â¾Ã Â¤Â²Ã Â¥â€¡ Ã Â¤Â¬Ã Â¤Â¿Ã Â¤Â¨Ã Â¤Â¾ Ã Â¤â€¦Ã Â¤Â²Ã Â¤â€”, Ã Â¤Â¸Ã Â¤Â¿Ã Â¤Â¨Ã Â¥â€¡Ã Â¤Â®Ã Â¥Ë†Ã Â¤Å¸Ã Â¤Â¿Ã Â¤â€¢ Ã Â¤â€Ã Â¤Â° Ã Â¤ÂÃ Â¤Â²Ã Â¤Â¿Ã Â¤â€”Ã Â¥â€¡Ã Â¤â€šÃ Â¤Å¸ Ã Â¤Â²Ã Â¤â€”Ã Â¥â€¡Ã Â¥Â¤',
    'iconic.program.zodiac.eyebrow': 'Ã Â¤ÂªÃ Â¥â€¹Ã Â¤Â¸Ã Â¥ÂÃ Â¤Å¸-Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â€¹Ã Â¤Â¸Ã Â¥â€¡Ã Â¤Â¸ Ã Â¤Â¸Ã Â¤Â¿Ã Â¤â€”Ã Â¥ÂÃ Â¤Â¨Ã Â¥â€¡Ã Â¤Å¡Ã Â¤Â°',
    'iconic.program.zodiac.description':
        'Ã Â¤Â°Ã Â¤Â¿Ã Â¤â€¢Ã Â¥â€°Ã Â¤Â°Ã Â¥ÂÃ Â¤Â¡Ã Â¤Â¿Ã Â¤â€šÃ Â¤â€” Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â¬Ã Â¤Â¾Ã Â¤Â¦ Ã Â¤Â²Ã Â¤â€”Ã Â¥ÂÃ Â¤Å“Ã Â¤Â¼Ã Â¤Â°Ã Â¥â‚¬ Ã Â¤Â°Ã Â¤Â¾Ã Â¤Â¶Ã Â¤Â¿Ã Â¤Å¡Ã Â¤â€¢Ã Â¥ÂÃ Â¤Â° Ã Â¤â€œÃ Â¤ÂµÃ Â¤Â°Ã Â¤Â²Ã Â¥â€¡ Ã Â¤Â²Ã Â¤Â¾Ã Â¤â€”Ã Â¥â€š Ã Â¤â€¢Ã Â¤Â°Ã Â¤Â¤Ã Â¤Â¾ Ã Â¤Â¹Ã Â¥Ë†Ã Â¥Â¤ Ã Â¤â€¦Ã Â¤Â¬ Ã Â¤Â¸Ã Â¤Â­Ã Â¥â‚¬ 12 Ã Â¤Â°Ã Â¤Â¾Ã Â¤Â¶Ã Â¤Â¿Ã Â¤Â¯Ã Â¥â€¹Ã Â¤â€š Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â²Ã Â¤Â¿Ã Â¤Â Ã Â¤â€¦Ã Â¤Â²Ã Â¤â€” Ã Â¤ÂªÃ Â¥Ë†Ã Â¤Â²Ã Â¥â€¡Ã Â¤Å¸, Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¤Â¤Ã Â¥â‚¬Ã Â¤â€¢, Ã Â¤â€ Ã Â¤Â­Ã Â¤Â¾ Ã Â¤Å¸Ã Â¤Â¿Ã Â¤â€šÃ Â¤Å¸ Ã Â¤â€Ã Â¤Â° Ã Â¤â€°Ã Â¤â€¢Ã Â¥â€¡Ã Â¤Â°Ã Â¥â‚¬ Ã Â¤Â¹Ã Â¥ÂÃ Â¤Ë† Ã Â¤Â¸Ã Â¥ÂÃ Â¤Å¸Ã Â¤Â¾Ã Â¤â€¡Ã Â¤Â²Ã Â¤Â¿Ã Â¤â€šÃ Â¤â€” Ã Â¤Â¹Ã Â¥Ë†, Ã Â¤â€Ã Â¤Â° Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â‚¬Ã Â¤ÂµÃ Â¥ÂÃ Â¤Â¯Ã Â¥â€š Aries Ã Â¤â€¢Ã Â¤Â²Ã Â¤Â¾-Ã Â¤Â¦Ã Â¤Â¿Ã Â¤Â¶Ã Â¤Â¾ Ã Â¤ÂªÃ Â¤Â° Ã Â¤â€ Ã Â¤Â§Ã Â¤Â¾Ã Â¤Â°Ã Â¤Â¿Ã Â¤Â¤ Ã Â¤Â¹Ã Â¥Ë†Ã Â¥Â¤',
    'iconic.program.zodiac.tag.sign_themes': '12 Ã Â¤Â°Ã Â¤Â¾Ã Â¤Â¶Ã Â¤Â¿ Ã Â¤Â¥Ã Â¥â‚¬Ã Â¤Â®',
    'iconic.program.zodiac.tag.luxury_capsule': 'Ã Â¤Â²Ã Â¤â€”Ã Â¥ÂÃ Â¤Å“Ã Â¤Â¼Ã Â¤Â°Ã Â¥â‚¬ Ã Â¤â€¢Ã Â¥Ë†Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â¸Ã Â¥â€šÃ Â¤Â²',
    'iconic.program.zodiac.tag.embossed_coin': 'Ã Â¤ÂÃ Â¤Â®Ã Â¥ÂÃ Â¤Â¬Ã Â¥â€°Ã Â¤Â¸Ã Â¥ÂÃ Â¤Â¡ Ã Â¤â€¢Ã Â¥â€°Ã Â¤â€¡Ã Â¤Â¨',
    'iconic.program.zodiac.footer':
        'Ã Â¤â€ Ã Â¤â€¡Ã Â¤â€¢Ã Â¥â€°Ã Â¤Â¨Ã Â¤Â¿Ã Â¤â€¢ Ã Â¤ÂÃ Â¤â€¢Ã Â¥ÂÃ Â¤Â¸Ã Â¤ÂªÃ Â¥â€¹Ã Â¤Â°Ã Â¥ÂÃ Â¤Å¸ Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â²Ã Â¤Â¿Ã Â¤Â Ã Â¤â€¦Ã Â¤Â¨Ã Â¥ÂÃ Â¤Â¶Ã Â¤â€šÃ Â¤Â¸Ã Â¤Â¿Ã Â¤Â¤Ã Â¥Â¤ Ã Â¤Â²Ã Â¤Â¾Ã Â¤â€¡Ã Â¤Âµ Ã Â¤â€¢Ã Â¥Ë†Ã Â¤ÂªÃ Â¥ÂÃ Â¤Å¡Ã Â¤Â° Ã Â¤Â¹Ã Â¤Â²Ã Â¥ÂÃ Â¤â€¢Ã Â¤Â¾ Ã Â¤Â°Ã Â¤Â¹Ã Â¤Â¤Ã Â¤Â¾ Ã Â¤Â¹Ã Â¥Ë† Ã Â¤Â¤Ã Â¤Â¾Ã Â¤â€¢Ã Â¤Â¿ Ã Â¤Â«Ã Â¥â€¹Ã Â¤Â¨ Ã Â¤Å“Ã Â¤Â¼Ã Â¥ÂÃ Â¤Â¯Ã Â¤Â¾Ã Â¤Â¦Ã Â¤Â¾ Ã Â¤â€”Ã Â¤Â°Ã Â¥ÂÃ Â¤Â® Ã Â¤Â¨ Ã Â¤Â¹Ã Â¥â€¹, Ã Â¤â€Ã Â¤Â° Ã Â¤Â°Ã Â¤Â¿Ã Â¤â€¢Ã Â¥â€°Ã Â¤Â°Ã Â¥ÂÃ Â¤Â¡Ã Â¤Â¿Ã Â¤â€šÃ Â¤â€” Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â¬Ã Â¤Â¾Ã Â¤Â¦ Ã Â¤Â²Ã Â¤â€”Ã Â¥ÂÃ Â¤Å“Ã Â¤Â¼Ã Â¤Â°Ã Â¥â‚¬ Ã Â¤Å¸Ã Â¥ÂÃ Â¤Â°Ã Â¥â‚¬Ã Â¤Å¸Ã Â¤Â®Ã Â¥â€¡Ã Â¤â€šÃ Â¤Å¸ Ã Â¤Å“Ã Â¥â€¹Ã Â¤Â¡Ã Â¤Â¼Ã Â¤Â¾ Ã Â¤Å“Ã Â¤Â¾Ã Â¤Â¤Ã Â¤Â¾ Ã Â¤Â¹Ã Â¥Ë†Ã Â¥Â¤',
    'iconic.program.festival.eyebrow': 'Ã Â¤Â¸Ã Â¤Â¾Ã Â¤â€šÃ Â¤Â¸Ã Â¥ÂÃ Â¤â€¢Ã Â¥Æ’Ã Â¤Â¤Ã Â¤Â¿Ã Â¤â€¢ Ã Â¤â€°Ã Â¤Â¤Ã Â¥ÂÃ Â¤Â¸Ã Â¤Âµ',
    'iconic.program.festival.description':
        'Ã Â¤Â¸Ã Â¤Â¬Ã Â¤Â¸Ã Â¥â€¡ Ã Â¤Â¨Ã Â¤Å“Ã Â¤Â¼Ã Â¤Â¦Ã Â¥â‚¬Ã Â¤â€¢Ã Â¥â‚¬ Ã Â¤ÂµÃ Â¤Â¿Ã Â¤Â¶Ã Â¥ÂÃ Â¤Âµ Ã Â¤â€°Ã Â¤Â¤Ã Â¥ÂÃ Â¤Â¸Ã Â¤Âµ Ã Â¤Â¯Ã Â¤Â¾ Ã Â¤â€“Ã Â¥â€¡Ã Â¤Â² Ã Â¤â€ Ã Â¤Â¯Ã Â¥â€¹Ã Â¤Å“Ã Â¤Â¨ Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤â€ Ã Â¤Â§Ã Â¤Â¾Ã Â¤Â° Ã Â¤ÂªÃ Â¤Â° Ã Â¤ÂÃ Â¤â€¢ Ã Â¤â€¦Ã Â¤Â¨Ã Â¥â€¹Ã Â¤â€“Ã Â¤Â¾ Ã Â¤Â²Ã Â¤â€”Ã Â¥ÂÃ Â¤Å“Ã Â¤Â¼Ã Â¤Â°Ã Â¥â‚¬ Ã Â¤â€œÃ Â¤ÂµÃ Â¤Â°Ã Â¤Â²Ã Â¥â€¡ Ã Â¤Â²Ã Â¤Â¾Ã Â¤â€”Ã Â¥â€š Ã Â¤â€¢Ã Â¤Â°Ã Â¤Â¤Ã Â¤Â¾ Ã Â¤Â¹Ã Â¥Ë†Ã Â¥Â¤ Ã Â¤Â¹Ã Â¤Â° Ã Â¤â€°Ã Â¤Â¤Ã Â¥ÂÃ Â¤Â¸Ã Â¤Âµ Ã Â¤â€¢Ã Â¥â‚¬ Ã Â¤â€¦Ã Â¤ÂªÃ Â¤Â¨Ã Â¥â‚¬ Ã Â¤Â°Ã Â¤â€šÃ Â¤â€”-Ã Â¤Â¸Ã Â¤Å“Ã Â¥ÂÃ Â¤Å“Ã Â¤Â¾, Ã Â¤Â°Ã Â¤Â¿Ã Â¤â€šÃ Â¤â€” Ã Â¤â€”Ã Â¥ÂÃ Â¤Â²Ã Â¥â€¹, Ã Â¤ÂÃ Â¤â€¢Ã Â¥ÂÃ Â¤Â¯Ã Â¥ÂÃ Â¤Â°Ã Â¥â€¡Ã Â¤Â¸Ã Â¥â‚¬ Ã Â¤Â¬Ã Â¤Â¾Ã Â¤Â° Ã Â¤â€”Ã Â¥ÂÃ Â¤Â°Ã Â¥â€¡Ã Â¤Â¡Ã Â¤Â¿Ã Â¤ÂÃ Â¤â€šÃ Â¤Å¸ Ã Â¤â€Ã Â¤Â° Ã Â¤Â¬Ã Â¥ÂÃ Â¤Â°Ã Â¤Â¾Ã Â¤â€šÃ Â¤Â¡Ã Â¤Â¿Ã Â¤â€šÃ Â¤â€” Ã Â¤Â¹Ã Â¥â€¹Ã Â¤Â¤Ã Â¥â‚¬ Ã Â¤Â¹Ã Â¥Ë†Ã Â¥Â¤',
    'iconic.program.festival.tag.festivals': '70 Ã Â¤â€°Ã Â¤Â¤Ã Â¥ÂÃ Â¤Â¸Ã Â¤Âµ',
    'iconic.program.festival.tag.date_aware': 'Ã Â¤Â¤Ã Â¤Â¾Ã Â¤Â°Ã Â¥â‚¬Ã Â¤â€“Ã Â¤Â¼ Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤â€¦Ã Â¤Â¨Ã Â¥ÂÃ Â¤Â¸Ã Â¤Â¾Ã Â¤Â°',
    'iconic.program.festival.tag.luxury_overlay': 'Ã Â¤Â²Ã Â¤â€”Ã Â¥ÂÃ Â¤Å“Ã Â¤Â¼Ã Â¤Â°Ã Â¥â‚¬ Ã Â¤â€œÃ Â¤ÂµÃ Â¤Â°Ã Â¤Â²Ã Â¥â€¡',
    'iconic.program.festival.footer':
        'Ã Â¤Â¥Ã Â¥â‚¬Ã Â¤Â® Ã Â¤â€¦Ã Â¤ÂªÃ Â¤Â¨Ã Â¥â€¡ Ã Â¤â€ Ã Â¤Âª Ã Â¤Â¸Ã Â¤Â¬Ã Â¤Â¸Ã Â¥â€¡ Ã Â¤Â¨Ã Â¤Å“Ã Â¤Â¼Ã Â¤Â¦Ã Â¥â‚¬Ã Â¤â€¢Ã Â¥â‚¬ Ã Â¤â€ Ã Â¤Â¨Ã Â¥â€¡ Ã Â¤ÂµÃ Â¤Â¾Ã Â¤Â²Ã Â¥â€¡ Ã Â¤â€°Ã Â¤Â¤Ã Â¥ÂÃ Â¤Â¸Ã Â¤Âµ Ã Â¤ÂªÃ Â¤Â° Ã Â¤Â¬Ã Â¤Â¦Ã Â¤Â² Ã Â¤Å“Ã Â¤Â¾Ã Â¤Â¤Ã Â¥â‚¬ Ã Â¤Â¹Ã Â¥Ë†Ã Â¥Â¤ Ã Â¤â€¦Ã Â¤ÂªÃ Â¤Â¨Ã Â¤Â¾ Ã Â¤ÂµÃ Â¤Â°Ã Â¥ÂÃ Â¤â€¢Ã Â¤â€ Ã Â¤â€°Ã Â¤Å¸ Ã Â¤Â°Ã Â¤Â¿Ã Â¤â€¢Ã Â¥â€°Ã Â¤Â°Ã Â¥ÂÃ Â¤Â¡ Ã Â¤â€¢Ã Â¤Â°Ã Â¥â€¡Ã Â¤â€š Ã Â¤â€Ã Â¤Â° Ã Â¤Â¸Ã Â¤â€¢Ã Â¥ÂÃ Â¤Â°Ã Â¤Â¿Ã Â¤Â¯ Ã Â¤â€°Ã Â¤Â¤Ã Â¥ÂÃ Â¤Â¸Ã Â¤Âµ Ã Â¤Â²Ã Â¥ÂÃ Â¤â€¢ Ã Â¤ÂªÃ Â¥â€¹Ã Â¤Â¸Ã Â¥ÂÃ Â¤Å¸-Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â€¹Ã Â¤Â¸Ã Â¥â€¡Ã Â¤Â¸Ã Â¤Â¿Ã Â¤â€šÃ Â¤â€” Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â¦Ã Â¥Å’Ã Â¤Â°Ã Â¤Â¾Ã Â¤Â¨ Ã Â¤Â²Ã Â¤Â¾Ã Â¤â€”Ã Â¥â€š Ã Â¤Â¹Ã Â¥â€¹ Ã Â¤Å“Ã Â¤Â¾Ã Â¤ÂÃ Â¤â€”Ã Â¤Â¾Ã Â¥Â¤',
    'iconic.program.studio.eyebrow': 'Ã Â¤ÂªÃ Â¥â€šÃ Â¤Â°Ã Â¥â‚¬ Ã Â¤Â¤Ã Â¤Â°Ã Â¤Â¹ Ã Â¤â€¦Ã Â¤Â¨Ã Â¥ÂÃ Â¤â€¢Ã Â¥â€šÃ Â¤Â²Ã Â¤Â¨Ã Â¤Â¯Ã Â¥â€¹Ã Â¤â€”Ã Â¥ÂÃ Â¤Â¯',
    'iconic.program.studio.description':
        'Ã Â¤ÂÃ Â¤Â¡Ã Â¤Â¿Ã Â¤Å¸Ã Â¥â€¡Ã Â¤Â¬Ã Â¤Â² Ã Â¤Â°Ã Â¥â€¡Ã Â¤Âª Ã Â¤â€¢Ã Â¤Â¾Ã Â¤â€°Ã Â¤â€šÃ Â¤Å¸Ã Â¤Â°, Ã Â¤ÂÃ Â¤â€¢Ã Â¥ÂÃ Â¤Â¯Ã Â¥ÂÃ Â¤Â°Ã Â¥â€¡Ã Â¤Â¸Ã Â¥â‚¬ Ã Â¤Â¬Ã Â¤Â¾Ã Â¤Â°, Ã Â¤Â¨Ã Â¥Ë†Ã Â¤Â°Ã Â¥â€¡Ã Â¤Å¸Ã Â¤Â¿Ã Â¤Âµ Ã Â¤Â«Ã Â¥ÂÃ Â¤Â²Ã Â¥â€¹, Ã Â¤â€ Ã Â¤â€¡Ã Â¤â€¢Ã Â¤Â¨, Ã Â¤Â°Ã Â¤â€šÃ Â¤â€”-Ã Â¤ÂªÃ Â¥Ë†Ã Â¤Â²Ã Â¥â€¡Ã Â¤Å¸ Ã Â¤â€Ã Â¤Â° Ã Â¤Â«Ã Â¤Â¿Ã Â¤Â¨Ã Â¤Â¿Ã Â¤Â¶ Ã Â¤â€¢Ã Â¤â€šÃ Â¤Å¸Ã Â¥ÂÃ Â¤Â°Ã Â¥â€¹Ã Â¤Â²Ã Â¥ÂÃ Â¤Â¸ Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â¸Ã Â¤Â¾Ã Â¤Â¥ Ã Â¤â€¦Ã Â¤ÂªÃ Â¤Â¨Ã Â¤Â¾ Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â‚¬Ã Â¤Â®Ã Â¤Â¿Ã Â¤Â¯Ã Â¤Â® Ã Â¤â€œÃ Â¤ÂµÃ Â¤Â°Ã Â¤Â²Ã Â¥â€¡ Ã Â¤Â¸Ã Â¤Â¿Ã Â¤Â¸Ã Â¥ÂÃ Â¤Å¸Ã Â¤Â® Ã Â¤â€¡Ã Â¤Â¸Ã Â¥ÂÃ Â¤Â¤Ã Â¥â€¡Ã Â¤Â®Ã Â¤Â¾Ã Â¤Â² Ã Â¤â€¢Ã Â¤Â°Ã Â¥â€¡Ã Â¤â€šÃ Â¥Â¤',
    'iconic.program.studio.tag.custom_program': 'Ã Â¤â€¢Ã Â¤Â¸Ã Â¥ÂÃ Â¤Å¸Ã Â¤Â® Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â€¹Ã Â¤â€”Ã Â¥ÂÃ Â¤Â°Ã Â¤Â¾Ã Â¤Â®',
    'iconic.program.studio.tag.luxury_editor': 'Ã Â¤Â²Ã Â¤â€”Ã Â¥ÂÃ Â¤Å“Ã Â¤Â¼Ã Â¤Â°Ã Â¥â‚¬ Ã Â¤ÂÃ Â¤Â¡Ã Â¤Â¿Ã Â¤Å¸Ã Â¤Â°',
    'iconic.program.studio.tag.premium_control': 'Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â‚¬Ã Â¤Â®Ã Â¤Â¿Ã Â¤Â¯Ã Â¤Â® Ã Â¤Â¨Ã Â¤Â¿Ã Â¤Â¯Ã Â¤â€šÃ Â¤Â¤Ã Â¥ÂÃ Â¤Â°Ã Â¤Â£',
    'iconic.program.studio.footer':
        'Ã Â¤Å“Ã Â¤Â¬ Ã Â¤â€ Ã Â¤Âª Ã Â¤Â¤Ã Â¤Â¯ Ã Â¤Â°Ã Â¤Â¾Ã Â¤Â¶Ã Â¤Â¿Ã Â¤Å¡Ã Â¤â€¢Ã Â¥ÂÃ Â¤Â° Ã Â¤Â¯Ã Â¤Â¾ Ã Â¤â€°Ã Â¤Â¤Ã Â¥ÂÃ Â¤Â¸Ã Â¤Âµ Ã Â¤Â¶Ã Â¥Ë†Ã Â¤Â²Ã Â¥â‚¬ Ã Â¤â€¢Ã Â¥â‚¬ Ã Â¤Å“Ã Â¤â€”Ã Â¤Â¹ Ã Â¤â€¦Ã Â¤ÂªÃ Â¤Â¨Ã Â¤Â¾ Ã Â¤â€“Ã Â¥ÂÃ Â¤Â¦ Ã Â¤â€¢Ã Â¤Â¾ Ã Â¤Â¹Ã Â¤Â¾Ã Â¤Â¥ Ã Â¤Â¸Ã Â¥â€¡ Ã Â¤Â¤Ã Â¥Ë†Ã Â¤Â¯Ã Â¤Â¾Ã Â¤Â° Ã Â¤â€¢Ã Â¤Â¿Ã Â¤Â¯Ã Â¤Â¾ Ã Â¤â€”Ã Â¤Â¯Ã Â¤Â¾ Ã Â¤Â²Ã Â¤â€”Ã Â¥ÂÃ Â¤Å“Ã Â¤Â¼Ã Â¤Â°Ã Â¥â‚¬ Ã Â¤â€œÃ Â¤ÂµÃ Â¤Â°Ã Â¤Â²Ã Â¥â€¡ Ã Â¤Å¡Ã Â¤Â¾Ã Â¤Â¹Ã Â¤Â¤Ã Â¥â€¡ Ã Â¤Â¹Ã Â¥â€¹Ã Â¤â€š, Ã Â¤Â¤Ã Â¤Â¬ Ã Â¤â€¡Ã Â¤Â¸Ã Â¥â€¡ Ã Â¤Å¡Ã Â¥ÂÃ Â¤Â¨Ã Â¥â€¡Ã Â¤â€šÃ Â¥Â¤',
    'iconic.program.studio.action': 'Ã Â¤Â¸Ã Â¥ÂÃ Â¤Å¸Ã Â¥â€šÃ Â¤Â¡Ã Â¤Â¿Ã Â¤Â¯Ã Â¥â€¹ Ã Â¤â€“Ã Â¥â€¹Ã Â¤Â²Ã Â¥â€¡Ã Â¤â€š',
    'iconic.program.standard.eyebrow': 'Ã Â¤Â¹Ã Â¤Â²Ã Â¥ÂÃ Â¤â€¢Ã Â¤Â¾ Ã Â¤Â¡Ã Â¤Â¿Ã Â¤Â«Ã Â¤Â¼Ã Â¥â€°Ã Â¤Â²Ã Â¥ÂÃ Â¤Å¸',
    'iconic.program.standard.description':
        'Ã Â¤Å“Ã Â¤Â¬ Ã Â¤â€ Ã Â¤Âª Ã Â¤Â¬Ã Â¥ÂÃ Â¤Â°Ã Â¤Â¾Ã Â¤â€šÃ Â¤Â¡Ã Â¥â€¡Ã Â¤Â¡ Ã Â¤Â¸Ã Â¤Â¿Ã Â¤Â¨Ã Â¥â€¡Ã Â¤Â®Ã Â¥Ë†Ã Â¤Å¸Ã Â¤Â¿Ã Â¤â€¢ Ã Â¤Â²Ã Â¥ÂÃ Â¤â€¢ Ã Â¤Â¨Ã Â¤Â¹Ã Â¥â‚¬Ã Â¤â€š Ã Â¤Å¡Ã Â¤Â¾Ã Â¤Â¹Ã Â¤Â¤Ã Â¥â€¡, Ã Â¤Â¤Ã Â¤Â¬ Ã Â¤Â®Ã Â¥Å’Ã Â¤Å“Ã Â¥â€šÃ Â¤Â¦Ã Â¤Â¾ Ã Â¤Â¸Ã Â¤Â°Ã Â¤Â² Ã Â¤â€œÃ Â¤ÂµÃ Â¤Â°Ã Â¤Â²Ã Â¥â€¡ Ã Â¤â€¢Ã Â¥â€¹ Ã Â¤Â¬Ã Â¤Â¨Ã Â¤Â¾Ã Â¤Â Ã Â¤Â°Ã Â¤â€“Ã Â¤Â¤Ã Â¤Â¾ Ã Â¤Â¹Ã Â¥Ë†Ã Â¥Â¤',
    'iconic.program.standard.tag.default': 'Ã Â¤Â¡Ã Â¤Â¿Ã Â¤Â«Ã Â¤Â¼Ã Â¥â€°Ã Â¤Â²Ã Â¥ÂÃ Â¤Å¸',
    'iconic.program.standard.tag.minimal': 'Ã Â¤Â®Ã Â¤Â¿Ã Â¤Â¨Ã Â¤Â¿Ã Â¤Â®Ã Â¤Â²',
    'iconic.program.standard.tag.fast_export': 'Ã Â¤Â¤Ã Â¥â€¡Ã Â¤Å“Ã Â¤Â¼ Ã Â¤ÂÃ Â¤â€¢Ã Â¥ÂÃ Â¤Â¸Ã Â¤ÂªÃ Â¥â€¹Ã Â¤Â°Ã Â¥ÂÃ Â¤Å¸',
    'iconic.program.standard.footer':
        'Ã Â¤â€¦Ã Â¤â€”Ã Â¤Â° Ã Â¤â€ Ã Â¤Âª Ã Â¤Â¬Ã Â¤Â¿Ã Â¤Â¨Ã Â¤Â¾ Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â‚¬Ã Â¤Â®Ã Â¤Â¿Ã Â¤Â¯Ã Â¤Â® Ã Â¤â€ Ã Â¤Â°Ã Â¥ÂÃ Â¤Å¸ Ã Â¤Â¡Ã Â¤Â¾Ã Â¤Â¯Ã Â¤Â°Ã Â¥â€¡Ã Â¤â€¢Ã Â¥ÂÃ Â¤Â¶Ã Â¤Â¨ Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â®Ã Â¥Å’Ã Â¤Å“Ã Â¥â€šÃ Â¤Â¦Ã Â¤Â¾ Ã Â¤ÂÃ Â¤â€¢Ã Â¥ÂÃ Â¤Â¸Ã Â¤ÂªÃ Â¥â€¹Ã Â¤Â°Ã Â¥ÂÃ Â¤Å¸ Ã Â¤Â¸Ã Â¥ÂÃ Â¤Å¸Ã Â¤Â¾Ã Â¤â€¡Ã Â¤Â² Ã Â¤Å¡Ã Â¤Â¾Ã Â¤Â¹Ã Â¤Â¤Ã Â¥â€¡ Ã Â¤Â¹Ã Â¥Ë†Ã Â¤â€š, Ã Â¤Â¤Ã Â¥â€¹ Ã Â¤â€¡Ã Â¤Â¸Ã Â¥â€¡ Ã Â¤Å¡Ã Â¥ÂÃ Â¤Â¨Ã Â¥â€¡Ã Â¤â€šÃ Â¥Â¤',
    'iconic.info.title': 'Ã Â¤Â¯Ã Â¤Â¹ Ã Â¤â€¢Ã Â¥Ë†Ã Â¤Â¸Ã Â¥â€¡ Ã Â¤â€¢Ã Â¤Â¾Ã Â¤Â® Ã Â¤â€¢Ã Â¤Â°Ã Â¤Â¤Ã Â¤Â¾ Ã Â¤Â¹Ã Â¥Ë†',
    'iconic.info.step1': '1. Ã Â¤Â¯Ã Â¤Â¹Ã Â¤Â¾Ã Â¤Â Ã Â¤ÂÃ Â¤â€¢ Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â€¹Ã Â¤â€”Ã Â¥ÂÃ Â¤Â°Ã Â¤Â¾Ã Â¤Â® Ã Â¤Å¡Ã Â¥ÂÃ Â¤Â¨Ã Â¥â€¡Ã Â¤â€šÃ Â¥Â¤',
    'iconic.info.step2': '2. Ã Â¤Â¸Ã Â¤Â¾Ã Â¤Â®Ã Â¤Â¾Ã Â¤Â¨Ã Â¥ÂÃ Â¤Â¯ Ã Â¤Â¤Ã Â¤Â°Ã Â¥â‚¬Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â¸Ã Â¥â€¡ Ã Â¤â€¦Ã Â¤ÂªÃ Â¤Â¨Ã Â¤Â¾ Ã Â¤ÂµÃ Â¤Â°Ã Â¥ÂÃ Â¤â€¢Ã Â¤â€ Ã Â¤â€°Ã Â¤Å¸ Ã Â¤Â°Ã Â¤Â¿Ã Â¤â€¢Ã Â¥â€°Ã Â¤Â°Ã Â¥ÂÃ Â¤Â¡ Ã Â¤â€¢Ã Â¤Â°Ã Â¥â€¡Ã Â¤â€šÃ Â¥Â¤',
    'iconic.info.step3':
        '3. Ã Â¤Å¡Ã Â¥ÂÃ Â¤Â¨Ã Â¥â‚¬ Ã Â¤â€”Ã Â¤Ë† Ã Â¤Â¶Ã Â¥Ë†Ã Â¤Â²Ã Â¥â‚¬ Ã Â¤Â°Ã Â¤Â¿Ã Â¤â€¢Ã Â¥â€°Ã Â¤Â°Ã Â¥ÂÃ Â¤Â¡Ã Â¤Â¿Ã Â¤â€šÃ Â¤â€” Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â¬Ã Â¤Â¾Ã Â¤Â¦ Ã Â¤â€¢Ã Â¥â€¡Ã Â¤ÂµÃ Â¤Â² Ã Â¤ÂªÃ Â¥â€¹Ã Â¤Â¸Ã Â¥ÂÃ Â¤Å¸-Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â€¹Ã Â¤Â¸Ã Â¥â€¡Ã Â¤Â¸Ã Â¤Â¿Ã Â¤â€šÃ Â¤â€” Ã Â¤â€¢Ã Â¥â€¡ Ã Â¤Â¦Ã Â¥Å’Ã Â¤Â°Ã Â¤Â¾Ã Â¤Â¨ Ã Â¤Â²Ã Â¤Â¾Ã Â¤â€”Ã Â¥â€š Ã Â¤Â¹Ã Â¥â€¹Ã Â¤Â¤Ã Â¥â‚¬ Ã Â¤Â¹Ã Â¥Ë†Ã Â¥Â¤',
    'iconic.preview.post_process': 'Ã Â¤ÂªÃ Â¥â€¹Ã Â¤Â¸Ã Â¥ÂÃ Â¤Å¸-Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â€¹Ã Â¤Â¸Ã Â¥â€¡Ã Â¤Â¸ Ã Â¤ÂªÃ Â¥ÂÃ Â¤Â°Ã Â¥â‚¬Ã Â¤ÂµÃ Â¥ÂÃ Â¤Â¯Ã Â¥â€š',
    'iconic.preview.standard.caption':
        'Ã Â¤Â¡Ã Â¤Â¿Ã Â¤Â«Ã Â¤Â¼Ã Â¥â€°Ã Â¤Â²Ã Â¥ÂÃ Â¤Å¸ Ã Â¤ÂÃ Â¤â€¢Ã Â¥ÂÃ Â¤Â¸Ã Â¤ÂªÃ Â¥â€¹Ã Â¤Â°Ã Â¥ÂÃ Â¤Å¸ Ã Â¤â€œÃ Â¤ÂµÃ Â¤Â°Ã Â¤Â²Ã Â¥â€¡\nÃ Â¤Â®Ã Â¥Å’Ã Â¤Å“Ã Â¥â€šÃ Â¤Â¦Ã Â¤Â¾ Ã Â¤Â¹Ã Â¤Â²Ã Â¥ÂÃ Â¤â€¢Ã Â¤Â¾ Ã Â¤Â²Ã Â¥ÂÃ Â¤â€¢ Ã Â¤Â¬Ã Â¤Â¨Ã Â¤Â¾Ã Â¤Â Ã Â¤Â°Ã Â¤â€“Ã Â¤Â¤Ã Â¤Â¾ Ã Â¤Â¹Ã Â¥Ë†Ã Â¥Â¤',
    'iconic.preview.editable_luxe': 'Ã Â¤ÂÃ Â¤Â¡Ã Â¤Â¿Ã Â¤Å¸Ã Â¥â€¡Ã Â¤Â¬Ã Â¤Â² Ã Â¤Â²Ã Â¤â€”Ã Â¥ÂÃ Â¤Å“Ã Â¤Â¼',
    'camera.overlay.skeleton': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â²',
    'camera.overlay.stop': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¹ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'camera.overlay.record': 'ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¥Ã¢â‚¬Â°ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¡',
    'camera.overlay.complete': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¾ ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¢ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡',
    'lang.en': 'ÃƒÂ Ã‚Â¤Ã¢â‚¬Â¦ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¼ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'lang.es': 'ÃƒÂ Ã‚Â¤Ã‚Â¸ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã¢â‚¬Â¡ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¶',
    'lang.ja': 'ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'lang.my': 'ÃƒÂ Ã‚Â¤Ã‚Â¬ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'lang.hi': 'ÃƒÂ Ã‚Â¤Ã‚Â¹ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'lang.pt': 'ÃƒÂ Ã‚Â¤Ã‚ÂªÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â¤ÃƒÂ Ã‚Â¤Ã¢â‚¬â€ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â²ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'lang.zh': 'ÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã¢â‚¬Å¡ÃƒÂ Ã‚Â¤Ã‚Â¦ÃƒÂ Ã‚Â¤Ã‚Â¾ÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¤Ã‚Â¿ÃƒÂ Ã‚Â¤Ã‚Â¨ ÃƒÂ Ã‚Â¤Ã…Â¡ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬ÃƒÂ Ã‚Â¤Ã‚Â¨ÃƒÂ Ã‚Â¥Ã¢â€šÂ¬',
    'lang.de': 'ÃƒÂ Ã‚Â¤Ã…â€œÃƒÂ Ã‚Â¤Ã‚Â°ÃƒÂ Ã‚Â¥Ã‚ÂÃƒÂ Ã‚Â¤Ã‚Â®ÃƒÂ Ã‚Â¤Ã‚Â¨',
  };

  static const Map<String, String> _ptValues = {
    'app.title': 'H&F',
    'nav.exercises': 'ExercÃƒÆ’Ã‚Â­cios',
    'nav.progress': 'Progresso',
    'nav.recordings': 'Gravar e perfil',
    'common.cancel': 'Cancelar',
    'common.retry': 'Tentar novamente',
    'common.load_exercises': 'Carregar exercÃƒÆ’Ã‚Â­cios',
    'common.clear_data': 'Limpar dados',
    'common.ok': 'OK',
    'common.close': 'Fechar',
    'common.error_with_message': 'Erro: {message}',
    'premium.badge': 'PREMIUM',
    'premium.menu_only':
        'Este menu estÃƒÆ’Ã‚Â¡ disponÃƒÆ’Ã‚Â­vel apenas para usuÃƒÆ’Ã‚Â¡rios Premium.',
    'home.exercises_list': 'Lista de exercÃƒÆ’Ã‚Â­cios',
    'home.exercises_simple_form': 'FormulÃƒÆ’Ã‚Â¡rio simples de exercÃƒÆ’Ã‚Â­cio',
    'home.no_supported_exercises': 'Nenhum exercÃƒÆ’Ã‚Â­cio compatÃƒÆ’Ã‚Â­vel disponÃƒÆ’Ã‚Â­vel',
    'home.check_exercise_config': 'Verifique a configuraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de exercÃƒÆ’Ã‚Â­cios',
    'home.error_loading_exercise': 'Erro ao carregar exercÃƒÆ’Ã‚Â­cio: {error}',
    'home.image_reference_count': '{count} imagem de referÃƒÆ’Ã‚Âªncia',
    'home.today_progress_premium': 'Progresso de hoje (Premium)',
    'home.today_progress_locked_desc':
        'Os dados do menu de progresso estÃƒÆ’Ã‚Â£o disponÃƒÆ’Ã‚Â­veis apenas para usuÃƒÆ’Ã‚Â¡rios Premium.',
    'home.today_progress': 'Progresso de hoje',
    'home.total_reps': 'RepetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes totais',
    'home.workouts': 'Treinos',
    'home.calories': 'Calorias',
    'home.daily_goal': 'Meta diÃƒÆ’Ã‚Â¡ria: {current}/{goal}',
    'home.daily_goal_achieved': 'Meta diÃƒÆ’Ã‚Â¡ria alcanÃƒÆ’Ã‚Â§ada!',
    'home.progress_premium_title': 'Progresso ÃƒÆ’Ã‚Â© Premium',
    'home.progress_premium_message':
        'AnÃƒÆ’Ã‚Â¡lises detalhadas de progresso sÃƒÆ’Ã‚Â£o desbloqueadas no Premium.',
    'home.recordings_premium_title': 'GravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes sÃƒÆ’Ã‚Â£o Premium',
    'home.recordings_premium_message':
        'O histÃƒÆ’Ã‚Â³rico de gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes estÃƒÆ’Ã‚Â¡ disponÃƒÆ’Ã‚Â­vel apenas no Premium.',
    'home.simple_form': 'FormulÃƒÆ’Ã‚Â¡rio de {name}',
    'home.quick_form_summary': 'Resumo rÃƒÆ’Ã‚Â¡pido do formulÃƒÆ’Ã‚Â¡rio',
    'home.form_images': 'Imagens do formulÃƒÆ’Ã‚Â¡rio',
    'home.exercise_list_notice_title': 'Lembrete rÃƒÆ’Ã‚Â¡pido',
    'home.exercise_list_notice_message':
        'Revise cada formulÃƒÆ’Ã‚Â¡rio de exercÃƒÆ’Ã‚Â­cio, pois pode haver avisos. Nota: o exercÃƒÆ’Ã‚Â­cio situp tem um aviso importante.',
    'home.simple_form_notice':
        'Aviso sobre barra de precisÃƒÆ’Ã‚Â£o e contagem:\nNossa IA foi projetada para reconhecer exercÃƒÆ’Ã‚Â­cios que sigam de perto nossos guias visuais. Ela oferece contagem suave com boa precisÃƒÆ’Ã‚Â£o, mas nÃƒÆ’Ã‚Â£o fornece coaching tÃƒÆ’Ã‚Â©cnico formal. Lembre-se de que nosso app nÃƒÆ’Ã‚Â£o tem 100% de precisÃƒÆ’Ã‚Â£o.\n\nPara exercÃƒÆ’Ã‚Â­cios de visÃƒÆ’Ã‚Â£o lateral, permaneÃƒÆ’Ã‚Â§a na posiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o lateral, e para exercÃƒÆ’Ã‚Â­cios de visÃƒÆ’Ã‚Â£o frontal, permaneÃƒÆ’Ã‚Â§a na posiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o frontal. Assim os resultados serÃƒÆ’Ã‚Â£o corretos.\n\nA mediÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o pode ser imprecisa se:\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Seu corpo inteiro nÃƒÆ’Ã‚Â£o estiver visÃƒÆ’Ã‚Â­vel no enquadramento da cÃƒÆ’Ã‚Â¢mera.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ HÃƒÆ’Ã‚Â¡ mais de uma pessoa na cÃƒÆ’Ã‚Â¢mera.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ O ambiente estiver muito escuro ou com reflexos/flare fortes.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Posicione a cÃƒÆ’Ã‚Â¢mera em um local que nÃƒÆ’Ã‚Â£o fique muito baixo nem muito alto em relaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o ao seu corpo.',
    'exercise.guide.title': 'Guia rÃƒÆ’Ã‚Â¡pido',
    'exercise.guide.step1':
        'Se quiser criar um landmark, toque no botÃƒÆ’Ã‚Â£o de esqueleto.',
    'exercise.guide.step2':
        'Se quiser gravar um vÃƒÆ’Ã‚Â­deo, toque no botÃƒÆ’Ã‚Â£o de gravar.',
    'exercise.guide.step3':
        'Para parar e salvar a gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o, dÃƒÆ’Ã‚Âª dois toques na tela ou toque no botÃƒÆ’Ã‚Â£o voltar.',
    'exercise.guide.step4':
        'Quando terminar o exercÃƒÆ’Ã‚Â­cio, toque no botÃƒÆ’Ã‚Â£o concluir e depois toque em Salvar para salvar o exercÃƒÆ’Ã‚Â­cio.',
    'exercise.error.setup_title': 'Erro de configuraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o',
    'exercise.error.setup_message': 'Falha ao iniciar: {error}',
    'exercise.error.pose_title': 'Erro de detecÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de pose',
    'exercise.error.pose_message':
        'NÃƒÆ’Ã‚Â£o foi possÃƒÆ’Ã‚Â­vel iniciar a detecÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de pose. Verifique se o Google Play Services estÃƒÆ’Ã‚Â¡ atualizado.',
    'exercise.premium.landmarks':
        'A sobreposiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de landmarks ÃƒÆ’Ã‚Â© um recurso Premium.',
    'exercise.premium.recording':
        'A gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de vÃƒÆ’Ã‚Â­deo estÃƒÆ’Ã‚Â¡ disponÃƒÆ’Ã‚Â­vel na versÃƒÆ’Ã‚Â£o Premium. FaÃƒÆ’Ã‚Â§a upgrade para desbloquear.',
    'exercise.recording.failed_start': 'Falha ao gravar a tela: {error}',
    'exercise.recording.permission_denied':
        'PermissÃƒÆ’Ã‚Â£o negada para gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de tela/ÃƒÆ’Ã‚Â¡udio',
    'exercise.recording.failed_save': 'Falha ao salvar a gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de tela',
    'exercise.recording.saved_gallery': 'Salvo na galeria ({album})',
    'exercise.recording.saved_app': 'Salvo no armazenamento do app: {path}',
    'exercise.recording.saved_phone':
        'VÃƒÆ’Ã‚Â­deo salvo no armazenamento do telefone',
    'exercise.recording.failed_video': 'Falha ao gravar vÃƒÆ’Ã‚Â­deo: {error}',
    'exercise.recording.preparing_luxury_video':
        'Estamos preparando seu vÃƒÆ’Ã‚Â­deo de treino premium para vocÃƒÆ’Ã‚Âª.',
    'exercise.recording.keep_screen_open':
        'Mantenha esta tela aberta por um momento.',
    'exercise.premium.title': 'Recurso Premium',
    'exercise.premium.not_now': 'Agora nÃƒÆ’Ã‚Â£o',
    'exercise.premium.upgrade': 'Upgrade',
    'exercise.premium.required_title': 'Premium necessÃƒÆ’Ã‚Â¡rio',
    'exercise.premium.required_message':
        'Salvar treino, contagem e acompanhamento de progresso estÃƒÆ’Ã‚Â£o disponÃƒÆ’Ã‚Â­veis apenas no Premium.',
    'exercise.camera.error_title': 'Erro de cÃƒÆ’Ã‚Â¢mera',
    'exercise.camera.error_message':
        'NÃƒÆ’Ã‚Â£o foi possÃƒÆ’Ã‚Â­vel iniciar a cÃƒÆ’Ã‚Â¢mera. Verifique permissÃƒÆ’Ã‚Âµes e tente novamente.',
    'exercise.counting_premium': 'Contagem (Premium)',
    'exercise.summary.title': 'Treino concluÃƒÆ’Ã‚Â­do!',
    'exercise.summary.total_reps': 'RepetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes totais',
    'exercise.summary.avg_accuracy': 'PrecisÃƒÆ’Ã‚Â£o mÃƒÆ’Ã‚Â©dia',
    'exercise.summary.duration': 'DuraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o',
    'exercise.summary.seconds': '{value} segundos',
    'exercise.summary.best_accuracy': 'Melhor precisÃƒÆ’Ã‚Â£o por repetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o',
    'exercise.summary.close': 'Fechar',
    'exercise.summary.view_details': 'Salvar',
    'exercise.card.type.dynamic': 'DinÃƒÆ’Ã‚Â¢mico',
    'exercise.card.type.static': 'EstÃƒÆ’Ã‚Â¡tico',
    'exercise.card.view.front': 'VisÃƒÆ’Ã‚Â£o frontal',
    'exercise.card.view.side': 'VisÃƒÆ’Ã‚Â£o lateral',
    'exercise.card.total_reps': 'RepetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes totais',
    'exercise.card.avg_accuracy': 'PrecisÃƒÆ’Ã‚Â£o mÃƒÆ’Ã‚Â©d.',
    'exercise.card.select': 'Selecionar exercÃƒÆ’Ã‚Â­cio',
    'exercise.time.today': 'Hoje',
    'exercise.time.yesterday': 'Ontem',
    'exercise.time.days_ago': 'hÃƒÆ’Ã‚Â¡ {value} dias',
    'exercise.time.weeks_ago': 'hÃƒÆ’Ã‚Â¡ {value} semanas',
    'exercise.time.months_ago': 'hÃƒÆ’Ã‚Â¡ {value} meses',
    'guide.squat.subtitle':
        'Mantenha o peito erguido, quadris para trÃƒÆ’Ã‚Â¡s e joelhos alinhados aos pÃƒÆ’Ã‚Â©s.',
    'guide.squat.step1': 'Fique na largura dos ombros e contraia o core.',
    'guide.squat.step2':
        'DesÃƒÆ’Ã‚Â§a atÃƒÆ’Ã‚Â© as coxas ficarem quase paralelas, mantendo os calcanhares no chÃƒÆ’Ã‚Â£o.',
    'guide.squat.step3':
        'Empurre pelos calcanhares para subir sem travar os joelhos.',
    'guide.pushup.subtitle':
        'Mantenha uma linha reta da cabeÃƒÆ’Ã‚Â§a aos calcanhares e controle cada repetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o.',
    'guide.pushup.step1':
        'Comece em prancha alta com as mÃƒÆ’Ã‚Â£os um pouco mais largas que os ombros.',
    'guide.pushup.step2':
        'DesÃƒÆ’Ã‚Â§a o peito flexionando os cotovelos em cerca de 45 graus.',
    'guide.pushup.step3':
        'Empurre para cima mantendo o core firme e o quadril nivelado.',
    'guide.situp.subtitle':
        'Use o core de forma controlada em vez de puxar o pescoÃƒÆ’Ã‚Â§o.',
    'guide.situp.step1':
        'Deite de costas com joelhos flexionados e pÃƒÆ’Ã‚Â©s apoiados.',
    'guide.situp.step2': 'Eleve o tronco contraindo o abdÃƒÆ’Ã‚Â´men.',
    'guide.situp.step3':
        'DesÃƒÆ’Ã‚Â§a devagar com controle antes da prÃƒÆ’Ã‚Â³xima repetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o.',
    'guide.bicep.subtitle':
        'Mantenha os cotovelos prÃƒÆ’Ã‚Â³ximos ao corpo e evite balanÃƒÆ’Ã‚Â§o.',
    'guide.bicep.step1':
        'Fique ereto com halteres e palmas voltadas para frente.',
    'guide.bicep.step2':
        'Flexione os cotovelos para subir os pesos sem mover os ombros.',
    'guide.bicep.step3': 'DesÃƒÆ’Ã‚Â§a os pesos lentamente atÃƒÆ’Ã‚Â© a extensÃƒÆ’Ã‚Â£o total.',
    'guide.shoulder.subtitle':
        'Pressione na vertical mantendo as costelas baixas e o core ativo.',
    'guide.shoulder.step1':
        'Comece com os pesos na altura dos ombros e punhos neutros.',
    'guide.shoulder.step2': 'Pressione atÃƒÆ’Ã‚Â© estender os braÃƒÆ’Ã‚Â§os acima da cabeÃƒÆ’Ã‚Â§a.',
    'guide.shoulder.step3': 'DesÃƒÆ’Ã‚Â§a com controle atÃƒÆ’Ã‚Â© a altura dos ombros.',
    'guide.leg.subtitle':
        'Movimente-se com controle e evite estender o joelho com impacto.',
    'guide.leg.step1':
        'Sente-se com as costas apoiadas e as pernas sob o apoio.',
    'guide.leg.step2':
        'Estenda os joelhos para levantar o apoio mantendo os quadris estÃƒÆ’Ã‚Â¡veis.',
    'guide.leg.step3': 'DesÃƒÆ’Ã‚Â§a lentamente atÃƒÆ’Ã‚Â© dobrar os joelhos e repita.',
    'settings.title': 'ConfiguraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes',
    'settings.premium_features': 'Recursos Premium',
    'settings.app_settings': 'ConfiguraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes do app',
    'settings.profile_name': 'Nome do perfil',
    'settings.appearance': 'AparÃƒÆ’Ã‚Âªncia',
    'settings.data': 'Dados',
    'settings.about': 'Sobre',
    'settings.premium_account': 'Conta Premium',
    'settings.unlock_all_features': 'Desbloquear todos os recursos Premium',
    'settings.voice_counting': 'Contagem por voz',
    'settings.speak_count': 'Falar a contagem durante as repetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes',
    'settings.voice_counting_language': 'Idioma da contagem por voz',
    'settings.upgrade_to_premium': 'Upgrade para Premium',
    'settings.upgrade_subtitle': 'Tenha contagem de voz, gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de vÃƒÆ’Ã‚Â­deo e mais',
    'settings.voice_coach': 'Voice Coach',
    'settings.voice_feedback': 'Receba feedback por voz em tempo real',
    'settings.show_landmarks': 'Mostrar landmarks',
    'settings.display_skeleton': 'Exibir sobreposiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o do esqueleto',
    'settings.auto_recording': 'GravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o automÃƒÆ’Ã‚Â¡tica',
    'settings.auto_recording_subtitle': 'Gravar treinos automaticamente',
    'settings.theme': 'Tema',
    'settings.language': 'Idioma',
    'settings.language_subtitle': 'Alterar idioma do app',
    'settings.clear_data': 'Limpar dados',
    'settings.clear_data_subtitle': 'Excluir todo o histÃƒÆ’Ã‚Â³rico de treinos',
    'settings.version': 'VersÃƒÆ’Ã‚Â£o',
    'settings.privacy_policy': 'PolÃƒÆ’Ã‚Â­tica de privacidade',
    'settings.terms': 'Termos de serviÃƒÆ’Ã‚Â§o',
    'settings.disclaimer': 'IsenÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de responsabilidade',
    'legal.last_updated': 'ÃƒÆ’Ã…Â¡ltima atualizaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o: {date}',
    'legal.privacy.content':
        '1) Dados que processamos\n'
        'O H&F armazena registros de treino, progresso de conquistas, preferÃƒÆ’Ã‚Âªncias do app e caminhos de arquivos de gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o opcionais no seu dispositivo.\n\n'
        '2) AtivaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o Premium\n'
        'A ativaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o Premium requer internet ao menos uma vez. Durante a ativaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o, chave de licenÃƒÆ’Ã‚Â§a, hash do identificador do dispositivo, versÃƒÆ’Ã‚Â£o do app e plataforma sÃƒÆ’Ã‚Â£o enviados ao servidor de licenÃƒÆ’Ã‚Â§as. ApÃƒÆ’Ã‚Â³s a ativaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o, o direito Premium ÃƒÆ’Ã‚Â© validado localmente e o app pode ser usado offline.\n\n'
        '3) CÃƒÆ’Ã‚Â¢mera, microfone, armazenamento e poder de processamento\n'
        'A cÃƒÆ’Ã‚Â¢mera ÃƒÆ’Ã‚Â© usada para detecÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de postura. Ela usa o poder de processamento do seu dispositivo para analisar a postura. As permissÃƒÆ’Ã‚Âµes de microfone e gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de tela sÃƒÆ’Ã‚Â£o solicitadas apenas quando vocÃƒÆ’Ã‚Âª usa os recursos de gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o. VÃƒÆ’Ã‚Â­deos salvos permanecem no dispositivo ou galeria.\n\n'
        '4) Como usamos os dados\n'
        'Os dados sÃƒÆ’Ã‚Â£o usados para contar repetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes, calcular precisÃƒÆ’Ã‚Â£o, acompanhar progresso, desbloquear conquistas e fornecer recursos Premium.\n\n'
        '5) Compartilhamento\n'
        'NÃƒÆ’Ã‚Â£o vendemos seus dados pessoais. Os dados de verificaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de licenÃƒÆ’Ã‚Â§a sÃƒÆ’Ã‚Â£o processados apenas para ativar e proteger o acesso Premium.\n\n'
        '6) Seu controle\n'
        'VocÃƒÆ’Ã‚Âª pode apagar tudo ou desinstalar o app a qualquer momento. Apagar dados remove histÃƒÆ’Ã‚Â³rico local e o estado Premium armazenado.\n\n'
        '7) SeguranÃƒÆ’Ã‚Â§a\n'
        'O app usa checagens de integridade e armazenamento local seguro para reduzir riscos de violaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o, mas nenhum sistema ÃƒÆ’Ã‚Â© completamente seguro.',
    'legal.terms.content':
        'Ao usar o H&F, vocÃƒÆ’Ã‚Âª concorda com estes Termos.\n\n'
        '1) Uso do serviÃƒÆ’Ã‚Â§o\n'
        'O H&F ÃƒÆ’Ã‚Â© um aplicativo de apoio fitness. VocÃƒÆ’Ã‚Âª ÃƒÆ’Ã‚Â© responsÃƒÆ’Ã‚Â¡vel pela sua seguranÃƒÆ’Ã‚Â§a e decisÃƒÆ’Ã‚Âµes de saÃƒÆ’Ã‚Âºde.\n\n'
        '2) Conta e licenÃƒÆ’Ã‚Â§a\n'
        'O Premium requer uma chave de licenÃƒÆ’Ã‚Â§a vÃƒÆ’Ã‚Â¡lida. As licenÃƒÆ’Ã‚Â§as podem ser limitadas por dispositivo e bloqueadas por abuso, revogaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o ou violaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes de seguranÃƒÆ’Ã‚Â§a.\n\n'
        '3) Modo offline\n'
        'ApÃƒÆ’Ã‚Â³s ativaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o bem-sucedida, recursos principais e Premium podem rodar offline no mesmo dispositivo. Reinstalar, apagar dados sensÃƒÆ’Ã‚Â­veis ou falhas de integridade podem exigir ativaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o online novamente.\n\n'
        '4) RestriÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes\n'
        'NÃƒÆ’Ã‚Â£o tente violar a seguranÃƒÆ’Ã‚Â§a, fazer engenharia reversa da licenÃƒÆ’Ã‚Â§a ou usar o app para atividades ilegais.\n\n'
        '5) Propriedade intelectual\n'
        'O software, a marca e o conteÃƒÆ’Ã‚Âºdo do app permanecem propriedade do H&F e seus licenciadores.\n\n'
        '6) Sem garantia\n'
        'O app ÃƒÆ’Ã‚Â© fornecido "como estÃƒÆ’Ã‚Â¡", sem garantias de operaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o contÃƒÆ’Ã‚Â­nua ou resultados fitness especÃƒÆ’Ã‚Â­ficos. O contador do meu app pode ter contado a mais ou a menos por vÃƒÆ’Ã‚Â¡rios motivos.\n\n'
        '7) LimitaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de responsabilidade\n'
        'O H&F nÃƒÆ’Ã‚Â£o se responsabiliza por danos indiretos, incidentais ou consequentes decorrentes do uso do app.',
    'legal.disclaimer.content':
        'O H&F nÃƒÆ’Ã‚Â£o ÃƒÆ’Ã‚Â© um serviÃƒÆ’Ã‚Â§o mÃƒÆ’Ã‚Â©dico e nÃƒÆ’Ã‚Â£o fornece aconselhamento mÃƒÆ’Ã‚Â©dico, diagnÃƒÆ’Ã‚Â³stico ou tratamento.\n\n'
        '1) Risco de treino\n'
        'ExercÃƒÆ’Ã‚Â­cios apresentam risco de lesÃƒÆ’Ã‚Âµes. Pare imediatamente se sentir dor, tontura, dificuldade para respirar ou desconforto, e consulte um profissional qualificado.\n\n'
        '2) Contagem e feedback de IA\n'
        'DetecÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de postura e contagem de repetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes sÃƒÆ’Ã‚Â£o estimativas e podem estar erradas por causa do ÃƒÆ’Ã‚Â¢ngulo da cÃƒÆ’Ã‚Â¢mera, iluminaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o, oclusÃƒÆ’Ã‚Â£o, roupas ou velocidade do movimento.\n\n'
        '3) Desempenho durante gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o\n'
        'A contagem/contagem por voz foi projetada para funcionar bem em treinos normais com o telefone ligado. A detecÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de postura (contagem) e a gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de vÃƒÆ’Ã‚Â­deo podem rodar juntas .\n\n'
        '4) SituaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes de emergÃƒÆ’Ã‚Âªncia\n'
        'NÃƒÆ’Ã‚Â£o dependa deste app para emergÃƒÆ’Ã‚Âªncias. Contate os serviÃƒÆ’Ã‚Â§os de emergÃƒÆ’Ã‚Âªncia locais imediatamente quando necessÃƒÆ’Ã‚Â¡rio.\n\n'
        '5) Responsabilidade do usuÃƒÆ’Ã‚Â¡rio\n'
        'VocÃƒÆ’Ã‚Âª ÃƒÆ’Ã‚Â© responsÃƒÆ’Ã‚Â¡vel por um espaÃƒÆ’Ã‚Â§o de treino seguro, tÃƒÆ’Ã‚Â©cnica adequada e obter qualquer liberaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o mÃƒÆ’Ã‚Â©dica necessÃƒÆ’Ã‚Â¡ria antes de treinar.\n\n'
        '6) GravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o e privacidade de terceiros\n'
        'Se gravar treinos, obtenha consentimento de qualquer pessoa que possa aparecer no vÃƒÆ’Ã‚Â­deo ou ÃƒÆ’Ã‚Â¡udio.\n\n'
        '7) Resultados\n'
        'Os resultados fitness variam por pessoa. O H&F nÃƒÆ’Ã‚Â£o garante desempenho especÃƒÆ’Ã‚Â­fico ou resultados de saÃƒÆ’Ã‚Âºde.',
    'settings.select_theme': 'Selecionar tema',
    'settings.select_language': 'Selecionar idioma',
    'onboarding.language_title': 'Escolha seu idioma',
    'onboarding.language_subtitle':
        'VocÃƒÆ’Ã‚Âª pode alterar depois nas ConfiguraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes.',
    'onboarding.name_title': 'Qual ÃƒÆ’Ã‚Â© o seu nome?',
    'onboarding.name_subtitle': 'Isso aparecerÃƒÆ’Ã‚Â¡ no seu perfil.',
    'onboarding.name_hint': 'Digite seu nome',
    'onboarding.name_required': 'Por favor, digite seu nome',
    'onboarding.disclaimer_title': 'Aviso',
    'onboarding.terms_title': 'Termos de serviÃƒÆ’Ã‚Â§o',
    'onboarding.accept_notice':
        'Concorde para continuar usando o app.',
    'onboarding.accept_checkbox': 'Concordo',
    'onboarding.continue': 'Continuar',
    'onboarding.start_app': 'Iniciar app',
    'settings.clear_all_data': 'Limpar todos os dados',
    'settings.clear_all_data_desc':
        'Isso excluirÃƒÆ’Ã‚Â¡ todo o histÃƒÆ’Ã‚Â³rico de treinos, conquistas e configuraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes. Esta aÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o nÃƒÆ’Ã‚Â£o pode ser desfeita.',
    'settings.clear_success':
        'Todos os dados do usuÃƒÆ’Ã‚Â¡rio foram limpos com sucesso.',
    'settings.clear_failed': 'Falha ao limpar dados: {error}',
    'theme.light': 'Claro',
    'theme.dark': 'Escuro',
    'theme.gold': 'Dourado',
    'theme.pink': 'Rosa',
    'progress.title': 'Progresso e anÃƒÆ’Ã‚Â¡lise',
    'progress.overview': 'VisÃƒÆ’Ã‚Â£o geral',
    'progress.exercises': 'ExercÃƒÆ’Ã‚Â­cios',
    'progress.badges': 'Emblemas',
    'progress.no_data': 'Nenhum dado disponÃƒÆ’Ã‚Â­vel',
    'progress.weekly_summary': 'Resumo semanal',
    'progress.streak_days': '{count} dias de sequÃƒÆ’Ã‚Âªncia',
    'progress.recent_workouts': 'Treinos recentes',
    'progress.no_workouts': 'Nenhum treino ainda',
    'progress.workout_summary': '{reps} reps ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ {accuracy}% de precisÃƒÆ’Ã‚Â£o',
    'progress.achievements': 'Conquistas',
    'progress.badges_unlocked': '{unlocked}/{total} emblemas desbloqueados',
    'progress.view_all_achievements': 'Ver todas as conquistas',
    'progress.day.sun': 'Dom',
    'progress.day.mon': 'Seg',
    'progress.day.tue': 'Ter',
    'progress.day.wed': 'Qua',
    'progress.day.thu': 'Qui',
    'progress.day.fri': 'Sex',
    'progress.day.sat': 'SÃƒÆ’Ã‚Â¡b',
    'progress.time.just_now': 'Agora mesmo',
    'progress.time.minutes_ago': '{value}m atrÃƒÆ’Ã‚Â¡s',
    'progress.time.hours_ago': '{value}h atrÃƒÆ’Ã‚Â¡s',
    'progress.time.days_ago': '{value}d atrÃƒÆ’Ã‚Â¡s',
    'progress.time.weeks_ago': '{value}s atrÃƒÆ’Ã‚Â¡s',
    'progress.analytics_intro_title': 'Entendendo as anÃƒÆ’Ã‚Â¡lises de exercÃƒÆ’Ã‚Â­cio',
    'progress.analytics_intro_line1':
        'RepetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes totais = todas as reps salvas deste exercÃƒÆ’Ã‚Â­cio em todas as sessÃƒÆ’Ã‚Âµes.',
    'progress.analytics_intro_line2':
        'PrecisÃƒÆ’Ã‚Â£o mÃƒÆ’Ã‚Â©dia = mÃƒÆ’Ã‚Â©dia de precisÃƒÆ’Ã‚Â£o de forma de todas as sessÃƒÆ’Ã‚Âµes salvas.',
    'progress.analytics_intro_line3':
        'GrÃƒÆ’Ã‚Â¡fico de tendÃƒÆ’Ã‚Âªncia = precisÃƒÆ’Ã‚Â£o ao longo do tempo (linha mais alta = melhor forma).',
    'progress.analytics_intro_line4':
        'As anÃƒÆ’Ã‚Â¡lises sÃƒÆ’Ã‚Â³ atualizam apÃƒÆ’Ã‚Â³s salvar uma sessÃƒÆ’Ã‚Â£o de treino.',
    'progress.read_exercise_analytics_title':
        'Como ler as anÃƒÆ’Ã‚Â¡lises de exercÃƒÆ’Ã‚Â­cio',
    'progress.read_exercise_analytics_line1':
        'PrecisÃƒÆ’Ã‚Â£o mais recente = sua pontuaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de forma mais recente.',
    'progress.read_exercise_analytics_line2':
        'Melhor precisÃƒÆ’Ã‚Â£o = sua maior pontuaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o atÃƒÆ’Ã‚Â© agora.',
    'progress.read_exercise_analytics_line3':
        'As barras de sessÃƒÆ’Ã‚Â£o mostram as ÃƒÆ’Ã‚Âºltimas 6 sessÃƒÆ’Ã‚Âµes. Barra mais alta significa melhor precisÃƒÆ’Ã‚Â£o.',
    'progress.read_exercise_analytics_line4':
        'O nÃƒÆ’Ã‚Âºmero abaixo de cada barra ÃƒÆ’Ã‚Â© o total de repetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes daquela sessÃƒÆ’Ã‚Â£o.',
    'progress.latest_accuracy': 'PrecisÃƒÆ’Ã‚Â£o mais recente',
    'progress.best_accuracy': 'Melhor precisÃƒÆ’Ã‚Â£o',
    'progress.trend_vs_previous_session': '{sign}{delta}% vs sessÃƒÆ’Ã‚Â£o anterior',
    'progress.last_sessions_accuracy_title': 'ÃƒÆ’Ã…Â¡ltimas sessÃƒÆ’Ã‚Âµes (PrecisÃƒÆ’Ã‚Â£o %)',
    'progress.reps_short': 'reps',
    'progress.chart_accuracy_trend_legend':
        'Barras mais altas indicam melhor precisÃƒÆ’Ã‚Â£o. Os rÃƒÆ’Ã‚Â³tulos abaixo sÃƒÆ’Ã‚Â£o reps por sessÃƒÆ’Ã‚Â£o.',
    'progress.total_reps_all_time': 'RepetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes totais (geral)',
    'progress.avg_accuracy_all_sessions': 'PrecisÃƒÆ’Ã‚Â£o mÃƒÆ’Ã‚Â©dia (todas as sessÃƒÆ’Ã‚Âµes)',
    'progress.sessions': 'SessÃƒÆ’Ã‚Âµes',
    'progress.chart_accuracy_trend':
        'O grÃƒÆ’Ã‚Â¡fico mostra a tendÃƒÆ’Ã‚Âªncia de precisÃƒÆ’Ã‚Â£o por data de sessÃƒÆ’Ã‚Â£o.',
    'progress.no_sessions':
        'Nenhuma sessÃƒÆ’Ã‚Â£o ainda. Salve um treino para ver as anÃƒÆ’Ã‚Â¡lises aqui.',
    'badges.empty':
        'Nenhum emblema ainda.\nComece a treinar para desbloquear seu primeiro marco.',
    'badges.collection': 'Sua coleÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de emblemas',
    'badges.current_status': 'Status atual do emblema',
    'badges.unlocked_count': '{unlocked}/{total} emblemas desbloqueados',
    'badges.tier': 'NÃƒÆ’Ã‚Â­vel: {tier}',
    'badges.next_target':
        'PrÃƒÆ’Ã‚Â³ximo alvo: {name} ({progress}/{requirement}) - {percent}% concluÃƒÆ’Ã‚Â­do',
    'badges.how_it_works': 'Como este sistema de emblemas funciona',
    'badges.guide_1':
        'Os emblemas usam ritmo de 5 dias ativos e 2 dias de descanso. Apenas dias ativos contam para o progresso.',
    'badges.guide_2':
        'Treinos em dia de descanso sÃƒÆ’Ã‚Â£o salvos normalmente, mas nÃƒÆ’Ã‚Â£o somam nem subtraem progresso.',
    'badges.guide_3':
        'Metas diÃƒÆ’Ã‚Â¡rias tÃƒÆ’Ã‚Âªm limite: reps/sets extra nÃƒÆ’Ã‚Â£o dÃƒÆ’Ã‚Â£o crÃƒÆ’Ã‚Â©dito adicional.',
    'badges.guide_4':
        'NÃƒÆ’Ã‚Â£o precisa de halteres ou mÃƒÆ’Ã‚Â¡quinas: vocÃƒÆ’Ã‚Âª ainda pode ganhar emblemas com alternativas (ex.: push-ups para Upper, squats para Lower).',
    'badges.guide_5':
        'O progresso ÃƒÆ’Ã‚Â© calculado a partir dos logs salvos; dados reais determinam os desbloqueios.',
    'badges.unlocked_on': 'Desbloqueado em {date}',
    'badges.tap_full_plan': 'Toque para ver o plano completo',
    'badges.new_unlock_today': 'Desbloqueado hoje! ÃƒÆ’Ã¢â‚¬Å“timo trabalho.',
    'badges.unlocked_banner':
        'Desbloqueado! Excelente consistÃƒÆ’Ã‚Âªncia. Mantenha o ritmo.',
    'badges.poster_saved_note':
        'O pÃƒÆ’Ã‚Â´ster do emblema foi salvo automaticamente no ÃƒÆ’Ã‚Â¡lbum da galeria: {album}.',
    'badges.poster_save_failed_note':
        'NÃƒÆ’Ã‚Â£o foi possÃƒÆ’Ã‚Â­vel salvar o pÃƒÆ’Ã‚Â´ster na galeria. Verifique a permissÃƒÆ’Ã‚Â£o de fotos.',
    'badges.no_tier': 'Nenhum nÃƒÆ’Ã‚Â­vel desbloqueado ainda',
    'badges.motivation_unlocked':
        'Bom trabalho. Este emblema estÃƒÆ’Ã‚Â¡ garantido; agora avance para o prÃƒÆ’Ã‚Â³ximo nÃƒÆ’Ã‚Â­vel.',
    'badges.motivation_almost':
        'Quase lÃƒÆ’Ã‚Â¡. Faltam apenas {remaining} dia(s) qualificado(s).',
    'badges.motivation_keep':
        'Mantenha a consistÃƒÆ’Ã‚Âªncia. Cada dia qualificado avanÃƒÆ’Ã‚Â§a este emblema.',
    'tier.bronze': 'Bronze',
    'tier.silver': 'Prata',
    'tier.gold': 'Ouro',
    'tier.platinum': 'Platina',
    'badge.first_workout.name': 'Primeiros passos',
    'badge.first_workout.narrative':
        'Conclua seu primeiro dia de treino qualificado.',
    'badge.first_workout.detail1':
        'Meta: 1 dia qualificado a partir de logs de treino salvos.',
    'badge.first_workout.detail2':
        'Upper alvo: 8 reps no total (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise).',
    'badge.first_workout.detail3': 'Core alvo: 10 reps no total (Sit-up).',
    'badge.first_workout.detail4':
        'Lower alvo: 12 reps no total (Squat / Leg Extension).',
    'badge.prep.name': 'PreparaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de 15 dias',
    'badge.prep.narrative':
        'Construa consistÃƒÆ’Ã‚Âªncia com um ritmo de preparaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de 15 dias.',
    'badge.prep.detail1':
        'PreparaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de 15 dias com ciclo 5 ativos + 2 descansos (dias 6-7 e 13-14 sÃƒÆ’Ã‚Â£o descanso).',
    'badge.prep.detail2':
        'Dias 1-3: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': 'Dias 4-5: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': 'Dias 8-12: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': 'Dia 15: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = sessÃƒÆ’Ã‚Âµes salvas por categoria no dia; dias de descanso nÃƒÆ’Ã‚Â£o somam progresso.',
    'badge.prep.detail8':
        'Se vocÃƒÆ’Ã‚Âª perder um dia ativo obrigatÃƒÆ’Ã‚Â³rio, o progresso do prep ÃƒÆ’Ã‚Â© reiniciado e a sequÃƒÆ’Ã‚Âªncia recomeÃƒÆ’Ã‚Â§a do Dia 1 no prÃƒÆ’Ã‚Â³ximo dia de treino.',
    'badge.bronze.name': 'MÃƒÆ’Ã‚Âªs 1 Bronze',
    'badge.bronze.narrative':
        'MÃƒÆ’Ã‚Âªs de base para consistÃƒÆ’Ã‚Âªncia do programa completo.',
    'badge.bronze.detail1':
        '30 dias ativos qualificados com ciclo 5 ativos + 2 descansos.',
    'badge.bronze.detail2':
        'Upper diÃƒÆ’Ã‚Â¡rio: 18 reps + 3 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise combinados).',
    'badge.bronze.detail3': 'Core diÃƒÆ’Ã‚Â¡rio: 24 reps + 3 sets (Sit-up).',
    'badge.bronze.detail4':
        'Lower diÃƒÆ’Ã‚Â¡rio: 30 reps + 3 sets (Squat / Leg Extension combinados).',
    'badge.bronze.detail5':
        'Reps/sets extras alÃƒÆ’Ã‚Â©m do limite diÃƒÆ’Ã‚Â¡rio nÃƒÆ’Ã‚Â£o contam progresso.',
    'badge.bronze.detail6':
        'Mesmo se vocÃƒÆ’Ã‚Âª perder um dia, nÃƒÆ’Ã‚Â£o precisa recomeÃƒÆ’Ã‚Â§ar do dia 1.',
    'badge.silver.name': 'MÃƒÆ’Ã‚Âªs 2 Prata',
    'badge.silver.narrative':
        'MÃƒÆ’Ã‚Âªs de progressÃƒÆ’Ã‚Â£o com requisitos de maior volume.',
    'badge.silver.detail1':
        '30 dias ativos qualificados com ciclo 5 ativos + 2 descansos.',
    'badge.silver.detail2':
        'Upper diÃƒÆ’Ã‚Â¡rio: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise combinados).',
    'badge.silver.detail3': 'Core diÃƒÆ’Ã‚Â¡rio: 32 reps + 4 sets (Sit-up).',
    'badge.silver.detail4':
        'Lower diÃƒÆ’Ã‚Â¡rio: 40 reps + 4 sets (Squat / Leg Extension combinados).',
    'badge.silver.detail5':
        'Apenas dias ativos contam; dias de descanso sÃƒÆ’Ã‚Â£o ignorados.',
    'badge.silver.detail6':
        'Mesmo se vocÃƒÆ’Ã‚Âª perder um dia, nÃƒÆ’Ã‚Â£o precisa recomeÃƒÆ’Ã‚Â§ar do dia 1.',
    'badge.gold.name': 'MÃƒÆ’Ã‚Âªs 3 Ouro',
    'badge.gold.narrative':
        'MÃƒÆ’Ã‚Âªs de maestria com metas avanÃƒÆ’Ã‚Â§adas de resistÃƒÆ’Ã‚Âªncia.',
    'badge.gold.detail1':
        '30 dias ativos qualificados com ciclo 5 ativos + 2 descansos.',
    'badge.gold.detail2':
        'Upper diÃƒÆ’Ã‚Â¡rio: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise combinados).',
    'badge.gold.detail3': 'Core diÃƒÆ’Ã‚Â¡rio: 40 reps + 4 sets (Sit-up).',
    'badge.gold.detail4':
        'Lower diÃƒÆ’Ã‚Â¡rio: 50 reps + 4 sets (Squat / Leg Extension combinados).',
    'badge.gold.detail5':
        'Progresso usa logs salvos; reps extras nÃƒÆ’Ã‚Â£o dÃƒÆ’Ã‚Â£o crÃƒÆ’Ã‚Â©dito.',
    'badge.gold.detail6':
        'Mesmo se vocÃƒÆ’Ã‚Âª perder um dia, nÃƒÆ’Ã‚Â£o precisa recomeÃƒÆ’Ã‚Â§ar do dia 1.',
    'badge.default.goal': 'Meta: {description}',
    'badge.default.requirement':
        'Requisito: {requirement} dia(s) qualificado(s).',
    'badge.default.status': 'Status atual: {progress}/{requirement}.',
    'badge.poster.badge_label': 'Emblema',
    'badge.poster.user_label': 'Conquistado por',
    'badge.poster.requirements_label': 'Dados qualificados',
    'leaderboard.title': 'Leaderboard',
    'leaderboard.achievements': 'Conquistas',
    'leaderboard.global': 'Global',
    'leaderboard.achievement_progress': 'Progresso de conquistas',
    'leaderboard.personal_bests': 'Melhores marcas',
    'leaderboard.most_reps': 'Mais repetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes',
    'leaderboard.best_accuracy': 'Melhor precisÃƒÆ’Ã‚Â£o',
    'leaderboard.longest_streak': 'Maior sequÃƒÆ’Ã‚Âªncia',
    'leaderboard.days': 'Dias',
    'leaderboard.global_simulated': 'Leaderboard global (simulado)',
    'leaderboard.points': '{score} pts',
    'recordings.tab.recordings': 'Gravar',
    'recordings.tab.profile': 'Perfil',
    'recordings.failed_load': 'Falha ao carregar gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes',
    'recordings.empty': 'Nenhum vÃƒÆ’Ã‚Â­deo gravado ainda',
    'recordings.file_not_found': 'Arquivo de vÃƒÆ’Ã‚Â­deo nÃƒÆ’Ã‚Â£o encontrado',
    'recordings.file_incomplete':
        'Arquivo de gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o incompleto. Grave novamente.',
    'profile.guest_name': 'UsuÃƒÆ’Ã‚Â¡rio',
    'profile.user_name_label': 'Nome de usuÃƒÆ’Ã‚Â¡rio',
    'profile.edit_name': 'Editar',
    'profile.name_hint': 'Digite seu nome',
    'profile.save_name': 'Salvar',
    'profile.photo_title': 'Foto do perfil',
    'profile.photo_subtitle':
        'Adicione uma foto de corpo inteiro para personalizar seu perfil.',
    'profile.photo_add': 'Adicionar foto',
    'profile.photo_change': 'Alterar foto',
    'profile.photo_remove': 'Remover foto',
    'profile.photo_remove_confirm': 'Remover sua foto do perfil?',
    'profile.photo_too_large':
        'A foto ÃƒÆ’Ã‚Â© grande demais. Escolha uma imagem menor.',
    'profile.photo_error':
        'NÃƒÆ’Ã‚Â£o foi possÃƒÆ’Ã‚Â­vel salvar a foto. Tente outra imagem.',
    'profile.photo_badge_notice':
        'Se nenhuma foto de perfil for adicionada, os pÃƒÆ’Ã‚Â´steres de emblema serÃƒÆ’Ã‚Â£o gerados sem sua foto.',
    'profile.exercise_totals_title': 'Totais de exercÃƒÆ’Ã‚Â­cios',
    'profile.exercise_totals_subtitle': 'Da primeira ÃƒÆ’Ã‚Â  ÃƒÆ’Ã‚Âºltima sessÃƒÆ’Ã‚Â£o.',
    'profile.exercise_empty': 'Ainda nÃƒÆ’Ã‚Â£o hÃƒÆ’Ã‚Â¡ dados de exercÃƒÆ’Ã‚Â­cio',
    'profile.badges_title': 'Badges conquistadas',
    'profile.badges_empty': 'Ainda nÃƒÆ’Ã‚Â£o hÃƒÆ’Ã‚Â¡ badges',
    'profile.badge_gallery_saved_note':
        'Quando um emblema ÃƒÆ’Ã‚Â© desbloqueado, seu pÃƒÆ’Ã‚Â´ster ÃƒÆ’Ã‚Â© salvo automaticamente no ÃƒÆ’Ã‚Â¡lbum da galeria: {album}.',
    'iconic.menu.title': 'Programas icÃƒÆ’Ã‚Â´nicos',
    'iconic.menu.subtitle':
        'Escolha um visual premium de pÃƒÆ’Ã‚Â³s-processamento para vÃƒÆ’Ã‚Â­deos gravados. Cada programa foi pensado para parecer distinto, cinematogrÃƒÆ’Ã‚Â¡fico e elegante sem adicionar calor durante a captura ao vivo.',
    'iconic.program.zodiac.eyebrow': 'Assinatura em pÃƒÆ’Ã‚Â³s-processo',
    'iconic.program.zodiac.description':
        'Aplica um overlay luxuoso de zodÃƒÆ’Ã‚Â­aco apÃƒÆ’Ã‚Â³s a gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o. Os 12 signos agora usam paletas, sÃƒÆ’Ã‚Â­mbolos, tons de aura e estilo gravado distintos, com a prÃƒÆ’Ã‚Â©via baseada na direÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de arte de ÃƒÆ’Ã‚Âries.',
    'iconic.program.zodiac.tag.sign_themes': '12 temas dos signos',
    'iconic.program.zodiac.tag.luxury_capsule': 'CÃƒÆ’Ã‚Â¡psula de luxo',
    'iconic.program.zodiac.tag.embossed_coin': 'Moeda em relevo',
    'iconic.program.zodiac.footer':
        'Recomendado para exportaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes icÃƒÆ’Ã‚Â´nicas. A captura ao vivo continua leve para o telefone nÃƒÆ’Ã‚Â£o superaquecer, enquanto o acabamento luxuoso ÃƒÆ’Ã‚Â© adicionado apÃƒÆ’Ã‚Â³s a gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o.',
    'iconic.program.festival.eyebrow': 'CelebraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o cultural',
    'iconic.program.festival.description':
        'Aplica um overlay luxuoso ÃƒÆ’Ã‚Âºnico com base no festival mundial ou evento esportivo mais prÃƒÆ’Ã‚Â³ximo. Cada festival tem sua prÃƒÆ’Ã‚Â³pria paleta, brilho do anel, gradiente da barra de precisÃƒÆ’Ã‚Â£o e identidade visual.',
    'iconic.program.festival.tag.festivals': '70 festivais',
    'iconic.program.festival.tag.date_aware': 'SensÃƒÆ’Ã‚Â­vel ÃƒÆ’Ã‚Â  data',
    'iconic.program.festival.tag.luxury_overlay': 'Overlay de luxo',
    'iconic.program.festival.footer':
        'O tema muda automaticamente para a celebraÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o futura mais prÃƒÆ’Ã‚Â³xima. Grave seu treino e o visual do festival ativo serÃƒÆ’Ã‚Â¡ aplicado durante o pÃƒÆ’Ã‚Â³s-processamento.',
    'iconic.program.studio.eyebrow': 'Totalmente personalizÃƒÆ’Ã‚Â¡vel',
    'iconic.program.studio.description':
        'Use seu prÃƒÆ’Ã‚Â³prio sistema premium de overlay com contador de repetiÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Âµes editÃƒÆ’Ã‚Â¡vel, barra de precisÃƒÆ’Ã‚Â£o, fluxo narrativo, ÃƒÆ’Ã‚Â­cones, paletas de cores e controles de acabamento.',
    'iconic.program.studio.tag.custom_program': 'Programa personalizado',
    'iconic.program.studio.tag.luxury_editor': 'Editor de luxo',
    'iconic.program.studio.tag.premium_control': 'Controle premium',
    'iconic.program.studio.footer':
        'Escolha isto quando quiser seu prÃƒÆ’Ã‚Â³prio overlay luxuoso artesanal em vez de um tratamento fixo de zodÃƒÆ’Ã‚Â­aco ou festival.',
    'iconic.program.studio.action': 'Abrir estÃƒÆ’Ã‚Âºdio',
    'iconic.program.standard.eyebrow': 'PadrÃƒÆ’Ã‚Â£o leve',
    'iconic.program.standard.description':
        'MantÃƒÆ’Ã‚Â©m o overlay simples atual quando vocÃƒÆ’Ã‚Âª nÃƒÆ’Ã‚Â£o quer um visual cinematogrÃƒÆ’Ã‚Â¡fico com marca.',
    'iconic.program.standard.tag.default': 'PadrÃƒÆ’Ã‚Â£o',
    'iconic.program.standard.tag.minimal': 'Minimalista',
    'iconic.program.standard.tag.fast_export': 'ExportaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o rÃƒÆ’Ã‚Â¡pida',
    'iconic.program.standard.footer':
        'Use isto se quiser o estilo de exportaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o atual sem direÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o de arte premium.',
    'iconic.info.title': 'Como funciona',
    'iconic.info.step1': '1. Escolha um programa aqui.',
    'iconic.info.step2': '2. Grave seu treino normalmente.',
    'iconic.info.step3':
        '3. O estilo selecionado ÃƒÆ’Ã‚Â© aplicado somente apÃƒÆ’Ã‚Â³s a gravaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o, durante o pÃƒÆ’Ã‚Â³s-processamento.',
    'iconic.preview.post_process': 'PRÃƒÆ’Ã¢â‚¬Â°VIA DE PÃƒÆ’Ã¢â‚¬Å“S-PROCESSO',
    'iconic.preview.standard.caption':
        'O overlay de exportaÃƒÆ’Ã‚Â§ÃƒÆ’Ã‚Â£o padrÃƒÆ’Ã‚Â£o\nmantÃƒÆ’Ã‚Â©m o visual leve atual.',
    'iconic.preview.editable_luxe': 'LUXO EDITÃƒÆ’Ã‚ÂVEL',
    'camera.overlay.skeleton': 'Esqueleto',
    'camera.overlay.stop': 'Parar',
    'camera.overlay.record': 'Gravar',
    'camera.overlay.complete': 'Concluir',
    'lang.en': 'InglÃƒÆ’Ã‚Âªs',
    'lang.es': 'Espanhol',
    'lang.ja': 'JaponÃƒÆ’Ã‚Âªs',
    'lang.my': 'BirmanÃƒÆ’Ã‚Âªs',
    'lang.hi': 'Hindi',
    'lang.pt': 'PortuguÃƒÆ’Ã‚Âªs',
    'lang.zh': 'ChinÃƒÆ’Ã‚Âªs mandarim',
    'lang.de': 'AlemÃƒÆ’Ã‚Â£o',
  };

  static const Map<String, String> _zhValues = {
    'app.title': 'H&F',
    'nav.exercises': 'ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™',
    'nav.progress': 'ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'nav.recordings': 'ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¥Ã¢â‚¬â„¢Ã…â€™ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ¨Ã‚ÂµÃ¢â‚¬Å¾ÃƒÂ¦Ã¢â‚¬â€œÃ¢â€žÂ¢',
    'common.cancel': 'ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€œÃƒÂ¦Ã‚Â¶Ã‹â€ ',
    'common.retry': 'ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â¢',
    'common.load_exercises': 'ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ¨Ã‚Â½Ã‚Â½ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™',
    'common.clear_data': 'ÃƒÂ¦Ã‚Â¸Ã¢â‚¬Â¦ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®',
    'common.ok': 'ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚Â®Ã…Â¡',
    'common.close': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â³ÃƒÂ©Ã¢â‚¬â€Ã‚Â­',
    'common.error_with_message': 'ÃƒÂ©Ã¢â‚¬ÂÃ¢â€žÂ¢ÃƒÂ¨Ã‚Â¯Ã‚Â¯ÃƒÂ¯Ã‚Â¼Ã…Â¡{message}',
    'premium.badge': 'ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§',
    'premium.menu_only': 'ÃƒÂ¦Ã‚Â­Ã‚Â¤ÃƒÂ¨Ã‚ÂÃ…â€œÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ¤Ã‚Â»Ã¢â‚¬Â¦ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‹â€ Ã‚Â·ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'home.exercises_list': 'ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã‹â€ Ã¢â‚¬â€ÃƒÂ¨Ã‚Â¡Ã‚Â¨',
    'home.exercises_simple_form': 'ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ§Ã‚Â®Ã¢â€šÂ¬ÃƒÂ¦Ã‹Å“Ã¢â‚¬Å“ÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¥Ã…Â Ã‚Â¿',
    'home.no_supported_exercises': 'ÃƒÂ¦Ã‚Â²Ã‚Â¡ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¯ÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™',
    'home.check_exercise_config': 'ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¦Ã‚Â£Ã¢â€šÂ¬ÃƒÂ¦Ã…Â¸Ã‚Â¥ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ©Ã¢â‚¬Â¦Ã‚ÂÃƒÂ§Ã‚Â½Ã‚Â®',
    'home.error_loading_exercise': 'ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ¨Ã‚Â½Ã‚Â½ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ©Ã¢â‚¬ÂÃ¢â€žÂ¢ÃƒÂ¯Ã‚Â¼Ã…Â¡{error}',
    'home.image_reference_count': '{count} ÃƒÂ¥Ã‚Â¼Ã‚Â ÃƒÂ¥Ã‚ÂÃ¢â‚¬Å¡ÃƒÂ¨Ã¢â€šÂ¬Ã†â€™ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â¾',
    'home.today_progress_premium': 'ÃƒÂ¤Ã‚Â»Ã…Â ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'home.today_progress_locked_desc': 'ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¨Ã‚ÂÃ…â€œÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ¤Ã‚Â»Ã¢â‚¬Â¦ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‹â€ Ã‚Â·ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'home.today_progress': 'ÃƒÂ¤Ã‚Â»Ã…Â ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'home.total_reps': 'ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â»ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°',
    'home.workouts': 'ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™',
    'home.calories': 'ÃƒÂ¥Ã‚ÂÃ‚Â¡ÃƒÂ¨Ã‚Â·Ã‚Â¯ÃƒÂ©Ã¢â‚¬Â¡Ã…â€™',
    'home.daily_goal': 'ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…Â¡{current}/{goal}',
    'home.daily_goal_achieved': 'ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¨Ã‚Â¾Ã‚Â¾ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã‚Â',
    'home.progress_premium_title': 'ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½',
    'home.progress_premium_message': 'ÃƒÂ¨Ã‚Â¯Ã‚Â¦ÃƒÂ§Ã‚Â»Ã¢â‚¬Â ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚ÂÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'home.recordings_premium_title': 'ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã†â€™Ã‚ÂÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½',
    'home.recordings_premium_message': 'ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã†â€™Ã‚ÂÃƒÂ¥Ã…Â½Ã¢â‚¬Â ÃƒÂ¥Ã‚ÂÃ‚Â²ÃƒÂ¤Ã‚Â»Ã¢â‚¬Â¦ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‹â€ Ã‚Â·ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'home.simple_form': '{name} ÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¥Ã…Â Ã‚Â¿',
    'home.quick_form_summary': 'ÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¥Ã…Â Ã‚Â¿ÃƒÂ©Ã¢â€šÂ¬Ã…Â¸ÃƒÂ¨Ã‚Â§Ã‹â€ ',
    'home.form_images': 'ÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¥Ã…Â Ã‚Â¿ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â¾ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡',
    'home.exercise_list_notice_title': 'ÃƒÂ¥Ã‚Â¿Ã‚Â«ÃƒÂ©Ã¢â€šÂ¬Ã…Â¸ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ©Ã¢â‚¬Â Ã¢â‚¬â„¢',
    'home.exercise_list_notice_message':
        'ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¦Ã…Â¸Ã‚Â¥ÃƒÂ§Ã…â€œÃ¢â‚¬Â¹ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â ÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â³Ã‚Â¨ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ¯Ã‚Â¼Ã…Â¡situp ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'home.simple_form_notice':
        'ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ¯Ã‚Â¼Ã…Â¡\nÃƒÂ¦Ã‹â€ Ã¢â‚¬ËœÃƒÂ¤Ã‚Â»Ã‚Â¬ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ AI ÃƒÂ¦Ã…â€™Ã¢â‚¬Â°ÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â°ÃƒÂ¦Ã…â€™Ã¢â‚¬Â¡ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€ÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â ÃƒÂ¥Ã‹â€ Ã‚Â«ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ©Ã‚Â¡Ã‚ÂºÃƒÂ§Ã¢â‚¬Â¢Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¥Ã¢â‚¬â„¢Ã…â€™ÃƒÂ¨Ã‚Â¾Ã†â€™ÃƒÂ¥Ã‚Â¥Ã‚Â½ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â½Ã¢â‚¬Â ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ¥Ã‚Â¼Ã‚ÂÃƒÂ¦Ã…Â Ã¢â€šÂ¬ÃƒÂ¦Ã…â€œÃ‚Â¯ÃƒÂ¦Ã…â€™Ã¢â‚¬Â¡ÃƒÂ¥Ã‚Â¯Ã‚Â¼ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¨Ã‚Â®Ã‚Â°ÃƒÂ¤Ã‚Â½Ã‚ÂÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ©Ã‚ÂÃ…Â¾ 100% ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\nÃƒÂ¤Ã‚Â¾Ã‚Â§ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ¨Ã‚Â§Ã¢â‚¬â„¢ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¤Ã‚Â¾Ã‚Â§ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ¤Ã‚Â½Ã‚ÂÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ¨Ã‚Â§Ã¢â‚¬â„¢ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ¤Ã‚Â½Ã‚ÂÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¿Ã¢â€žÂ¢ÃƒÂ¦Ã‚Â Ã‚Â·ÃƒÂ§Ã‚Â»Ã¢â‚¬Å“ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\nÃƒÂ¤Ã‚Â»Ã‚Â¥ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¦Ã†â€™Ã¢â‚¬Â¦ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂµÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¥Ã‚Â¯Ã‚Â¼ÃƒÂ¨Ã¢â‚¬Â¡Ã‚Â´ÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â ÃƒÂ¥Ã‹â€ Ã‚Â«ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¯Ã‚Â¼Ã…Â¡\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¦Ã‚Â²Ã‚Â¡ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â´ÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ§Ã…Â½Ã‚Â°ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ¥Ã¢â‚¬Â Ã¢â‚¬Â¦ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ§Ã¢â‚¬ÂÃ‚Â»ÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã‚Â¤Ã…Â¡ÃƒÂ¤Ã‚ÂºÃ…Â½ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ¦Ã‹â€ Ã‚Â¿ÃƒÂ©Ã¢â‚¬â€Ã‚Â´ÃƒÂ¥Ã‚Â¤Ã‚ÂªÃƒÂ¦Ã…Â¡Ã¢â‚¬â€ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã‚Â¼Ã‚ÂºÃƒÂ§Ã†â€™Ã‹â€ ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ§Ã…â€œÃ‚Â©ÃƒÂ¥Ã¢â‚¬Â¦Ã¢â‚¬Â°/ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã‚Â°Ã¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ¥Ã‚Â°Ã¢â‚¬Â ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¾ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¥Ã‚Â¯Ã‚Â¹ÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¨Ã‚Â¿Ã¢â‚¬Â¡ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ¤Ã‚Â¹Ã…Â¸ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¨Ã‚Â¿Ã¢â‚¬Â¡ÃƒÂ¤Ã‚Â½Ã…Â½ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¤Ã‚Â½Ã‚ÂÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.guide.title': 'ÃƒÂ¥Ã‚Â¿Ã‚Â«ÃƒÂ©Ã¢â€šÂ¬Ã…Â¸ÃƒÂ¦Ã…â€™Ã¢â‚¬Â¡ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€',
    'exercise.guide.step1': 'ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¥Ã‹â€ Ã¢â‚¬ÂºÃƒÂ¥Ã‚Â»Ã‚ÂºÃƒÂ©Ã‚ÂªÃ‚Â¨ÃƒÂ¦Ã…Â¾Ã‚Â¶ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¨Ã‚Â®Ã‚Â°ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ§Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â»ÃƒÂ©Ã‚ÂªÃ‚Â¨ÃƒÂ¦Ã…Â¾Ã‚Â¶ÃƒÂ¦Ã…â€™Ã¢â‚¬Â°ÃƒÂ©Ã¢â‚¬â„¢Ã‚Â®ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.guide.step2': 'ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ§Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â»ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¦Ã…â€™Ã¢â‚¬Â°ÃƒÂ©Ã¢â‚¬â„¢Ã‚Â®ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.guide.step3': 'ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¥Ã‚ÂÃ…â€œÃƒÂ¦Ã‚Â­Ã‚Â¢ÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â»ÃƒÂ¥Ã‚Â±Ã‚ÂÃƒÂ¥Ã‚Â¹Ã¢â‚¬Â¢ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ§Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â»ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¦Ã…â€™Ã¢â‚¬Â°ÃƒÂ©Ã¢â‚¬â„¢Ã‚Â®ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.guide.step4': 'ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ§Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â»ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¦Ã…â€™Ã¢â‚¬Â°ÃƒÂ©Ã¢â‚¬â„¢Ã‚Â®ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂÃƒÂ§Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â»ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¦Ã…â€™Ã¢â‚¬Â°ÃƒÂ©Ã¢â‚¬â„¢Ã‚Â®ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.error.setup_title': 'ÃƒÂ¥Ã‹â€ Ã‚ÂÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ©Ã¢â‚¬ÂÃ¢â€žÂ¢ÃƒÂ¨Ã‚Â¯Ã‚Â¯',
    'exercise.error.setup_message': 'ÃƒÂ¥Ã‹â€ Ã‚ÂÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¨Ã‚Â´Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡{error}',
    'exercise.error.pose_title': 'ÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¥Ã…Â Ã‚Â¿ÃƒÂ¦Ã‚Â£Ã¢â€šÂ¬ÃƒÂ¦Ã‚ÂµÃ¢â‚¬Â¹ÃƒÂ©Ã¢â‚¬ÂÃ¢â€žÂ¢ÃƒÂ¨Ã‚Â¯Ã‚Â¯',
    'exercise.error.pose_message': 'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¦Ã‚Â³Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚ÂÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¥Ã…Â Ã‚Â¿ÃƒÂ¦Ã‚Â£Ã¢â€šÂ¬ÃƒÂ¦Ã‚ÂµÃ¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¨Ã‚Â®Ã‚Â¤ Google Play Services ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.premium.landmarks': 'ÃƒÂ©Ã‚ÂªÃ‚Â¨ÃƒÂ¦Ã…Â¾Ã‚Â¶ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¨Ã‚Â®Ã‚Â°ÃƒÂ¥Ã‚ÂÃ‚Â ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.premium.recording': 'ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¤Ã‚Â»Ã¢â‚¬Â¦ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã‹â€ ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¤Ã‚Â»Ã‚Â¥ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.recording.failed_start': 'ÃƒÂ¥Ã‚Â±Ã‚ÂÃƒÂ¥Ã‚Â¹Ã¢â‚¬Â¢ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¨Ã‚Â´Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡{error}',
    'exercise.recording.permission_denied': 'ÃƒÂ¥Ã‚Â±Ã‚ÂÃƒÂ¥Ã‚Â¹Ã¢â‚¬Â¢/ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¦Ã‚ÂÃ†â€™ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¨Ã‚Â¢Ã‚Â«ÃƒÂ¦Ã¢â‚¬Â¹Ã¢â‚¬â„¢ÃƒÂ§Ã‚Â»Ã‚Â',
    'exercise.recording.failed_save': 'ÃƒÂ¥Ã‚Â±Ã‚ÂÃƒÂ¥Ã‚Â¹Ã¢â‚¬Â¢ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¨Ã‚Â´Ã‚Â¥',
    'exercise.recording.saved_gallery': 'ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¥Ã¢â‚¬Â Ã…â€™ÃƒÂ¯Ã‚Â¼Ã‹â€ {album}ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'exercise.recording.saved_app': 'ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ¯Ã‚Â¼Ã…Â¡{path}',
    'exercise.recording.saved_phone': 'ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Â¹ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã¢â‚¬Å¡Ã‚Â¨',
    'exercise.recording.failed_video': 'ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¨Ã‚Â´Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡{error}',
    'exercise.recording.preparing_luxury_video':
        'ÃƒÂ¦Ã‹â€ Ã¢â‚¬ËœÃƒÂ¤Ã‚Â»Ã‚Â¬ÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¨Ã‚Â´Ã‚Â¨ÃƒÂ¦Ã¢â‚¬Å¾Ã…Â¸ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.recording.keep_screen_open':
        'ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¦Ã…Â¡Ã¢â‚¬Å¡ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¦Ã‚Â­Ã‚Â¤ÃƒÂ©Ã‚Â¡Ã‚ÂµÃƒÂ©Ã‚ÂÃ‚Â¢ÃƒÂ¥Ã‚Â¼Ã¢â€šÂ¬ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.premium.title': 'ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½',
    'exercise.premium.not_now': 'ÃƒÂ¦Ã…Â¡Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¸Ã‚Â',
    'exercise.premium.upgrade': 'ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ§Ã‚ÂºÃ‚Â§',
    'exercise.premium.required_title': 'ÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã‹â€ ',
    'exercise.premium.required_message': 'ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¥Ã¢â‚¬â„¢Ã…â€™ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¨Ã‚Â¿Ã‚Â½ÃƒÂ¨Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚Â»Ã¢â‚¬Â¦ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã‹â€ ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.camera.error_title': 'ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ©Ã¢â‚¬ÂÃ¢â€žÂ¢ÃƒÂ¨Ã‚Â¯Ã‚Â¯',
    'exercise.camera.error_message': 'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¦Ã‚Â³Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚ÂÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ¥Ã…â€™Ã¢â‚¬â€œÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¦Ã‚Â£Ã¢â€šÂ¬ÃƒÂ¦Ã…Â¸Ã‚Â¥ÃƒÂ¦Ã‚ÂÃ†â€™ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'exercise.counting_premium': 'ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'exercise.summary.title': 'ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¯Ã‚Â¼Ã‚Â',
    'exercise.summary.total_reps': 'ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â»ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°',
    'exercise.summary.avg_accuracy': 'ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'exercise.summary.duration': 'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ©Ã¢â‚¬Â¢Ã‚Â¿',
    'exercise.summary.seconds': '{value} ÃƒÂ§Ã‚Â§Ã¢â‚¬â„¢',
    'exercise.summary.best_accuracy': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¤Ã‚Â½Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¢ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'exercise.summary.close': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â³ÃƒÂ©Ã¢â‚¬â€Ã‚Â­',
    'exercise.summary.view_details': 'ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“',
    'exercise.card.type.dynamic': 'ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â',
    'exercise.card.type.static': 'ÃƒÂ©Ã‚ÂÃ¢â€žÂ¢ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â',
    'exercise.card.view.front': 'ÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ©Ã‚ÂÃ‚Â¢',
    'exercise.card.view.side': 'ÃƒÂ¤Ã‚Â¾Ã‚Â§ÃƒÂ©Ã‚ÂÃ‚Â¢',
    'exercise.card.total_reps': 'ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â»ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°',
    'exercise.card.avg_accuracy': 'ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'exercise.card.select': 'ÃƒÂ©Ã¢â€šÂ¬Ã¢â‚¬Â°ÃƒÂ¦Ã¢â‚¬Â¹Ã‚Â©ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™',
    'exercise.time.today': 'ÃƒÂ¤Ã‚Â»Ã…Â ÃƒÂ¥Ã‚Â¤Ã‚Â©',
    'exercise.time.yesterday': 'ÃƒÂ¦Ã‹Å“Ã‚Â¨ÃƒÂ¥Ã‚Â¤Ã‚Â©',
    'exercise.time.days_ago': '{value} ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'exercise.time.weeks_ago': '{value} ÃƒÂ¥Ã¢â‚¬ËœÃ‚Â¨ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'exercise.time.months_ago': '{value} ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'guide.squat.subtitle': 'ÃƒÂ¦Ã…Â Ã‚Â¬ÃƒÂ¨Ã†â€™Ã‚Â¸ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ§Ã¢â‚¬ÂºÃ¢â‚¬â€œÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¨Ã¢â‚¬Å¾Ã…Â¡ÃƒÂ¥Ã‚Â°Ã¢â‚¬â€œÃƒÂ¦Ã¢â‚¬â€œÃ‚Â¹ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.squat.step1': 'ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¨Ã¢â‚¬Å¾Ã…Â¡ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¥Ã‚Â®Ã‚Â½ÃƒÂ§Ã‚Â«Ã¢â€žÂ¢ÃƒÂ§Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¶ÃƒÂ§Ã‚Â´Ã‚Â§ÃƒÂ¦Ã‚Â Ã‚Â¸ÃƒÂ¥Ã‚Â¿Ã†â€™ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.squat.step2': 'ÃƒÂ¨Ã¢â‚¬Å¾Ã…Â¡ÃƒÂ¨Ã‚Â·Ã…Â¸ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ§Ã‚Â¦Ã‚Â»ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¨Ã‚Â¹Ã‚Â²ÃƒÂ¨Ã¢â‚¬Â¡Ã‚Â³ÃƒÂ¥Ã‚Â¤Ã‚Â§ÃƒÂ¨Ã¢â‚¬Â¦Ã‚Â¿ÃƒÂ¦Ã…Â½Ã‚Â¥ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ËœÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.squat.step3': 'ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¨Ã¢â‚¬Å¾Ã…Â¡ÃƒÂ¨Ã‚Â·Ã…Â¸ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ¥Ã…Â Ã¢â‚¬ÂºÃƒÂ§Ã‚Â«Ã¢â€žÂ¢ÃƒÂ¨Ã‚ÂµÃ‚Â·ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ¦Ã‚Â­Ã‚Â»ÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ§Ã¢â‚¬ÂºÃ¢â‚¬â€œÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.pushup.subtitle': 'ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¥Ã‚Â¤Ã‚Â´ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ¨Ã¢â‚¬Å¾Ã…Â¡ÃƒÂ¨Ã‚Â·Ã…Â¸ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ§Ã‚ÂºÃ‚Â¿ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¦Ã…Â½Ã‚Â§ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.pushup.step1': 'ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Â¹ÃƒÂ§Ã¢â‚¬Â¢Ã‚Â¥ÃƒÂ¥Ã‚Â®Ã‚Â½ÃƒÂ¤Ã‚ÂºÃ…Â½ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ¤Ã‚Â½Ã‚ÂÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¦Ã‚ÂÃ‚Â¿ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¯ÃƒÂ¦Ã¢â‚¬â„¢Ã¢â‚¬ËœÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.pushup.step2': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã‹Å“ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ§Ã‚ÂºÃ‚Â¦45ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¥Ã‚Â¼Ã‚Â¯ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â²ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã†â€™Ã‚Â¸ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.pushup.step3': 'ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¦Ã‚Â Ã‚Â¸ÃƒÂ¥Ã‚Â¿Ã†â€™ÃƒÂ§Ã‚Â´Ã‚Â§ÃƒÂ¥Ã‚Â¼Ã‚Â ÃƒÂ¦Ã…Â½Ã‚Â¨ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â¹ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ©Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¦Ã‚Â°Ã‚Â´ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.situp.subtitle': 'ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‚Â Ã‚Â¸ÃƒÂ¥Ã‚Â¿Ã†â€™ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ¥Ã…Â Ã¢â‚¬ÂºÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¨Ã¢â‚¬Å¾Ã¢â‚¬â€œÃƒÂ¥Ã‚Â­Ã‚ÂÃƒÂ¦Ã¢â‚¬Â¹Ã¢â‚¬Â°ÃƒÂ¨Ã‚ÂµÃ‚Â·ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.situp.step1': 'ÃƒÂ¤Ã‚Â»Ã‚Â°ÃƒÂ¥Ã‚ÂÃ‚Â§ÃƒÂ¥Ã‚Â±Ã‹â€ ÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¨Ã¢â‚¬Å¾Ã…Â¡ÃƒÂ¨Ã‚Â¸Ã‚Â©ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.situp.step2': 'ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¶ÃƒÂ§Ã‚Â´Ã‚Â§ÃƒÂ¨Ã¢â‚¬Â¦Ã‚Â¹ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¦Ã…Â Ã‚Â¬ÃƒÂ¨Ã‚ÂµÃ‚Â·ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.situp.step3': 'ÃƒÂ¦Ã…Â½Ã‚Â§ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¾ÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.bicep.subtitle': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã‹Å“ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¨Ã‚Â´Ã‚Â´ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ËœÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ©Ã‚ÂÃ‚Â¿ÃƒÂ¥Ã¢â‚¬Â¦Ã‚ÂÃƒÂ¦Ã¢â‚¬ËœÃ¢â‚¬Â ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.bicep.step1': 'ÃƒÂ§Ã‚Â«Ã¢â€žÂ¢ÃƒÂ§Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¥Ã¢â‚¬Å“Ã¢â‚¬ËœÃƒÂ©Ã¢â‚¬Å“Ã†â€™ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Â¹ÃƒÂ¥Ã‚Â¿Ã†â€™ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.bicep.step2': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‚Â±Ã‹â€ ÃƒÂ¨Ã¢â‚¬Å¡Ã‹Å“ÃƒÂ¥Ã‚Â°Ã¢â‚¬Â ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¥Ã‚ÂÃ‚Â·ÃƒÂ¨Ã‚ÂµÃ‚Â·ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.bicep.step3': 'ÃƒÂ¦Ã¢â‚¬Â¦Ã‚Â¢ÃƒÂ¦Ã¢â‚¬Â¦Ã‚Â¢ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¾ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¤Ã‚Â¼Ã‚Â¸ÃƒÂ¥Ã‚Â±Ã¢â‚¬Â¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.shoulder.subtitle': 'ÃƒÂ¨Ã¢â‚¬Å¡Ã¢â‚¬Â¹ÃƒÂ©Ã‚ÂªÃ‚Â¨ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¶ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¦Ã‚Â Ã‚Â¸ÃƒÂ¥Ã‚Â¿Ã†â€™ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ¥Ã…Â Ã¢â‚¬ÂºÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã…Â¾Ã¢â‚¬Å¡ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ¦Ã…Â½Ã‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.shoulder.step1': 'ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Â¹ÃƒÂ¨Ã¢â‚¬Â¦Ã¢â‚¬Â¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ§Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.shoulder.step2': 'ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ¦Ã…Â½Ã‚Â¨ÃƒÂ¨Ã¢â‚¬Â¡Ã‚Â³ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Â¹ÃƒÂ¨Ã¢â‚¬Â¡Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¼Ã‚Â¸ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.shoulder.step3': 'ÃƒÂ¦Ã…Â½Ã‚Â§ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¾ÃƒÂ¥Ã¢â‚¬ÂºÃ…Â¾ÃƒÂ¨Ã¢â‚¬Å¡Ã‚Â©ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.leg.subtitle': 'ÃƒÂ¦Ã…Â½Ã‚Â§ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¨Ã…â€™Ã†â€™ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ©Ã‚ÂÃ‚Â¿ÃƒÂ¥Ã¢â‚¬Â¦Ã‚ÂÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ§Ã¢â‚¬ÂºÃ¢â‚¬â€œÃƒÂ§Ã…â€™Ã¢â‚¬ÂºÃƒÂ§Ã¢â‚¬Å¾Ã‚Â¶ÃƒÂ¤Ã‚Â¼Ã‚Â¸ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.leg.step1': 'ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã‚Â¥Ã‚Â½ÃƒÂ©Ã‚ÂÃ‚Â ÃƒÂ¨Ã†â€™Ã…â€™ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¯ÃƒÂ¦Ã¢â‚¬â„¢Ã¢â‚¬ËœÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã¢â‚¬Â¦Ã‚Â¿ÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ¤Ã‚ÂºÃ…Â½ÃƒÂ©Ã‚ÂÃ‚Â ÃƒÂ¥Ã…Â¾Ã‚Â«ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.leg.step2': 'ÃƒÂ§Ã‚Â¨Ã‚Â³ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ©Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¼Ã‚Â¸ÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ¦Ã…Â Ã‚Â¬ÃƒÂ¨Ã‚ÂµÃ‚Â·ÃƒÂ©Ã‚ÂÃ‚Â ÃƒÂ¥Ã…Â¾Ã‚Â«ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'guide.leg.step3': 'ÃƒÂ¦Ã¢â‚¬Â¦Ã‚Â¢ÃƒÂ¦Ã¢â‚¬Â¦Ã‚Â¢ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¾ÃƒÂ¨Ã¢â‚¬Â¡Ã‚Â³ÃƒÂ¥Ã‚Â±Ã‹â€ ÃƒÂ¨Ã¢â‚¬Â Ã‚ÂÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¥Ã‚Â¤Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'settings.title': 'ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ§Ã‚Â½Ã‚Â®',
    'settings.premium_features': 'ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½',
    'settings.app_settings': 'ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ§Ã‚Â½Ã‚Â®',
    'settings.profile_name': 'ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ¨Ã‚ÂµÃ¢â‚¬Å¾ÃƒÂ¦Ã¢â‚¬â€œÃ¢â€žÂ¢ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ§Ã‚Â§Ã‚Â°',
    'settings.appearance': 'ÃƒÂ¥Ã‚Â¤Ã¢â‚¬â€œÃƒÂ¨Ã‚Â§Ã¢â‚¬Å¡',
    'settings.data': 'ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®',
    'settings.about': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â³ÃƒÂ¤Ã‚ÂºÃ…Â½',
    'settings.premium_account': 'ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¨Ã‚Â´Ã‚Â¦ÃƒÂ¦Ã‹â€ Ã‚Â·',
    'settings.unlock_all_features': 'ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½',
    'settings.voice_counting': 'ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°',
    'settings.speak_count': 'ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ¦Ã¢â‚¬â„¢Ã‚Â­ÃƒÂ¦Ã…Â Ã‚Â¥ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°',
    'settings.voice_counting_language': 'ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬',
    'settings.upgrade_to_premium': 'ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§',
    'settings.upgrade_subtitle': 'ÃƒÂ¨Ã…Â½Ã‚Â·ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€œÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ§Ã‚Â­Ã¢â‚¬Â°',
    'settings.voice_coach': 'ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¦Ã¢â‚¬Â¢Ã¢â€žÂ¢ÃƒÂ§Ã‚Â»Ã†â€™',
    'settings.voice_feedback': 'ÃƒÂ¨Ã…Â½Ã‚Â·ÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ¥Ã‚Â®Ã…Â¾ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ©Ã‚Â¦Ã‹â€ ',
    'settings.show_landmarks': 'ÃƒÂ¦Ã‹Å“Ã‚Â¾ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ©Ã‚ÂªÃ‚Â¨ÃƒÂ¦Ã…Â¾Ã‚Â¶ÃƒÂ§Ã¢â‚¬Å¡Ã‚Â¹',
    'settings.display_skeleton': 'ÃƒÂ¦Ã‹Å“Ã‚Â¾ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ©Ã‚ÂªÃ‚Â¨ÃƒÂ¦Ã…Â¾Ã‚Â¶ÃƒÂ¥Ã‚ÂÃ‚Â ÃƒÂ¥Ã…Â Ã‚Â ',
    'settings.auto_recording': 'ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶',
    'settings.auto_recording_subtitle': 'ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™',
    'settings.theme': 'ÃƒÂ¤Ã‚Â¸Ã‚Â»ÃƒÂ©Ã‚Â¢Ã‹Å“',
    'settings.language': 'ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬',
    'settings.language_subtitle': 'ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¹ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬',
    'settings.clear_data': 'ÃƒÂ¦Ã‚Â¸Ã¢â‚¬Â¦ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®',
    'settings.clear_data_subtitle': 'ÃƒÂ¥Ã‹â€ Ã‚Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¦Ã¢â‚¬Â°Ã¢â€šÂ¬ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¨Ã‚Â®Ã‚Â°ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢',
    'settings.version': 'ÃƒÂ§Ã¢â‚¬Â°Ã‹â€ ÃƒÂ¦Ã…â€œÃ‚Â¬',
    'settings.privacy_policy': 'ÃƒÂ©Ã…Â¡Ã‚ÂÃƒÂ§Ã‚Â§Ã‚ÂÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¿ÃƒÂ§Ã‚Â­Ã¢â‚¬â€œ',
    'settings.terms': 'ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¦Ã‚Â¬Ã‚Â¾',
    'settings.disclaimer': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚ÂÃƒÂ¨Ã‚Â´Ã‚Â£ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ¦Ã‹Å“Ã…Â½',
    'legal.last_updated': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°: {date}',
    'legal.privacy.content':
        '1) ÃƒÂ¦Ã‹â€ Ã¢â‚¬ËœÃƒÂ¤Ã‚Â»Ã‚Â¬ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Å¾ÃƒÂ§Ã‚ÂÃ¢â‚¬Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®\n'
        'H&F ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¦Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ©Ã¢â‚¬ÂÃ‚Â»ÃƒÂ§Ã¢â‚¬Å¡Ã‚Â¼ÃƒÂ¨Ã‚Â®Ã‚Â°ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã‚Â¥Ã‚Â½ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ¤Ã‚Â»Ã‚Â¥ÃƒÂ¥Ã‚ÂÃ…Â ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ©Ã¢â€šÂ¬Ã¢â‚¬Â°ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ¨Ã‚Â·Ã‚Â¯ÃƒÂ¥Ã‚Â¾Ã¢â‚¬Å¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '2) ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã‹â€ ÃƒÂ¦Ã‚Â¿Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â´Ã‚Â»\n'
        'ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã‹â€ ÃƒÂ¦Ã‚Â¿Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¨Ã¢â‚¬Â¡Ã‚Â³ÃƒÂ¥Ã‚Â°Ã¢â‚¬ËœÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¨Ã‚ÂÃ¢â‚¬ÂÃƒÂ§Ã‚Â½Ã¢â‚¬ËœÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â¿Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¨Ã‚Â¿Ã¢â‚¬Â¡ÃƒÂ§Ã‚Â¨Ã¢â‚¬Â¹ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â®Ã‚Â¸ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚Â¯Ã¢â‚¬Â ÃƒÂ©Ã¢â‚¬â„¢Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â ÃƒÂ¥Ã¢â‚¬Å“Ã‹â€ ÃƒÂ¥Ã‚Â¸Ã…â€™ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ§Ã¢â‚¬Â°Ã‹â€ ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¥Ã¢â‚¬â„¢Ã…â€™ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ‚Â°ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ©Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ¦Ã‹â€ Ã¢â‚¬ËœÃƒÂ¤Ã‚Â»Ã‚Â¬ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â¸ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡ÃƒÂ¥Ã¢â€žÂ¢Ã‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â¿Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¦Ã‚ÂÃ†â€™ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ©Ã‚ÂªÃ…â€™ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¥Ã‚ÂÃ‚Â³ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ§Ã‚Â¦Ã‚Â»ÃƒÂ§Ã‚ÂºÃ‚Â¿ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '3) ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã‚ÂºÃ‚Â¦ÃƒÂ¥Ã¢â‚¬Â¦Ã¢â‚¬Â¹ÃƒÂ©Ã‚Â£Ã…Â½ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ¥Ã…Â Ã¢â‚¬Âº\n'
        'ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¤Ã‚ÂºÃ…Â½ÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¦Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â ÃƒÂ¥Ã‹â€ Ã‚Â«ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã‚Â®Ã†â€™ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ¥Ã…Â Ã¢â‚¬ÂºÃƒÂ¦Ã‚ÂÃ‚Â¥ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚ÂÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¦Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ©Ã‚ÂºÃ‚Â¦ÃƒÂ¥Ã¢â‚¬Â¦Ã¢â‚¬Â¹ÃƒÂ©Ã‚Â£Ã…Â½ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¥Ã‚Â±Ã‚ÂÃƒÂ¥Ã‚Â¹Ã¢â‚¬Â¢ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¦Ã‚ÂÃ†â€™ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¤Ã‚Â»Ã¢â‚¬Â¦ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ§Ã¢â‚¬ÂÃ‚Â³ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ§Ã¢â‚¬Â¢Ã¢â€žÂ¢ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¦Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â¾ÃƒÂ¥Ã‚ÂºÃ¢â‚¬Å“ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '4) ÃƒÂ¦Ã‹â€ Ã¢â‚¬ËœÃƒÂ¤Ã‚Â»Ã‚Â¬ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®\n'
        'ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¤Ã‚ÂºÃ…Â½ÃƒÂ§Ã‚Â»Ã…Â¸ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â¿Ã‚Â½ÃƒÂ¨Ã‚Â¸Ã‚ÂªÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '5) ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â±ÃƒÂ¤Ã‚ÂºÃ‚Â«\n'
        'ÃƒÂ¦Ã‹â€ Ã¢â‚¬ËœÃƒÂ¤Ã‚Â»Ã‚Â¬ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ¥Ã¢â‚¬ÂÃ‚Â®ÃƒÂ¦Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¨Ã‚Â®Ã‚Â¸ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ©Ã‚ÂªÃ…â€™ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ¤Ã‚Â»Ã¢â‚¬Â¦ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¤Ã‚ÂºÃ…Â½ÃƒÂ¦Ã‚Â¿Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…Â Ã‚Â¤ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¨Ã‚Â®Ã‚Â¿ÃƒÂ©Ã¢â‚¬â€Ã‚Â®ÃƒÂ¦Ã‚ÂÃ†â€™ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '6) ÃƒÂ¦Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã…Â½Ã‚Â§ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¦Ã‚ÂÃ†â€™\n'
        'ÃƒÂ¦Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ©Ã…Â¡Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ¦Ã‚Â¸Ã¢â‚¬Â¦ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã‚ÂÃ‚Â¸ÃƒÂ¨Ã‚Â½Ã‚Â½ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â¸Ã¢â‚¬Â¦ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¥Ã‹â€ Ã‚Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ¥Ã…Â½Ã¢â‚¬Â ÃƒÂ¥Ã‚ÂÃ‚Â²ÃƒÂ¨Ã‚Â®Ã‚Â°ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã¢â‚¬â„¢Ã…â€™ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ§Ã…Â Ã‚Â¶ÃƒÂ¦Ã¢â€šÂ¬Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '7) ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§\n'
        'ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â´ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ¦Ã‚Â Ã‚Â¡ÃƒÂ©Ã‚ÂªÃ…â€™ÃƒÂ¥Ã¢â‚¬â„¢Ã…â€™ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ¦Ã‚ÂÃ‚Â¥ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¤Ã‚Â½Ã…Â½ÃƒÂ§Ã‚Â¯Ã‚Â¡ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¹ÃƒÂ©Ã‚Â£Ã…Â½ÃƒÂ©Ã¢â€žÂ¢Ã‚Â©ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â½Ã¢â‚¬Â ÃƒÂ¤Ã‚Â»Ã‚Â»ÃƒÂ¤Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ§Ã‚Â³Ã‚Â»ÃƒÂ§Ã‚Â»Ã…Â¸ÃƒÂ©Ã†â€™Ã‚Â½ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¦Ã‚Â³Ã¢â‚¬Â¢ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'legal.terms.content':
        'ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ H&F ÃƒÂ¥Ã‚ÂÃ‚Â³ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ¦Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ¨Ã‚Â¿Ã¢â€žÂ¢ÃƒÂ¤Ã‚ÂºÃ¢â‚¬ÂºÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¦Ã‚Â¬Ã‚Â¾ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '1) ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨\n'
        'H&F ÃƒÂ¦Ã‹Å“Ã‚Â¯ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â¬Ã‚Â¾ÃƒÂ¥Ã‚ÂÃ‚Â¥ÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ¨Ã‚Â¾Ã¢â‚¬Â¦ÃƒÂ¥Ã…Â Ã‚Â©ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ¥Ã‚Â¯Ã‚Â¹ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¥Ã‚ÂÃ‚Â¥ÃƒÂ¥Ã‚ÂºÃ‚Â·ÃƒÂ¥Ã¢â‚¬Â Ã‚Â³ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ¨Ã‚Â´Ã…Â¸ÃƒÂ¨Ã‚Â´Ã‚Â£ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '2) ÃƒÂ¨Ã‚Â´Ã‚Â¦ÃƒÂ¦Ã‹â€ Ã‚Â·ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¨Ã‚Â®Ã‚Â¸ÃƒÂ¥Ã‚ÂÃ‚Â¯\n'
        'ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã‹â€ ÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¦Ã¢â‚¬Â¢Ã‹â€ ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â¸ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚Â¯Ã¢â‚¬Â ÃƒÂ©Ã¢â‚¬â„¢Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¨Ã‚Â®Ã‚Â¸ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â ÃƒÂ¦Ã‚Â»Ã‚Â¥ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚ÂÃ…Â ÃƒÂ©Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¨Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â§Ã¢â‚¬Å¾ÃƒÂ¨Ã¢â€šÂ¬Ã…â€™ÃƒÂ¨Ã‚Â¢Ã‚Â«ÃƒÂ¥Ã‚Â°Ã‚ÂÃƒÂ§Ã‚Â¦Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '3) ÃƒÂ§Ã‚Â¦Ã‚Â»ÃƒÂ§Ã‚ÂºÃ‚Â¿ÃƒÂ¦Ã‚Â¨Ã‚Â¡ÃƒÂ¥Ã‚Â¼Ã‚Â\n'
        'ÃƒÂ¦Ã‚Â¿Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¦Ã‚Â Ã‚Â¸ÃƒÂ¥Ã‚Â¿Ã†â€™ÃƒÂ¥Ã¢â‚¬â„¢Ã…â€™ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ§Ã‚Â¦Ã‚Â»ÃƒÂ§Ã‚ÂºÃ‚Â¿ÃƒÂ¨Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¨Ã‚Â£Ã¢â‚¬Â¦ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã‚Â¸Ã¢â‚¬Â¦ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¦Ã¢â‚¬Â¢Ã‚ÂÃƒÂ¦Ã¢â‚¬Å¾Ã…Â¸ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â´ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¨Ã‚Â´Ã‚Â¥ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¥Ã¢â‚¬Â Ã‚ÂÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¨Ã‚ÂÃ¢â‚¬ÂÃƒÂ§Ã‚Â½Ã¢â‚¬ËœÃƒÂ¦Ã‚Â¿Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '4) ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¥Ã‹â€ Ã‚Â¶\n'
        'ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¥Ã¢â‚¬Â¹Ã‚Â¿ÃƒÂ§Ã‚Â¯Ã‚Â¡ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¹ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã¢â€šÂ¬Ã¢â‚¬Â ÃƒÂ¥Ã‚ÂÃ¢â‚¬ËœÃƒÂ¥Ã‚Â·Ã‚Â¥ÃƒÂ§Ã‚Â¨Ã¢â‚¬Â¹ÃƒÂ¨Ã‚Â®Ã‚Â¸ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã‚Â°Ã¢â‚¬Â ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¤Ã‚ÂºÃ…Â½ÃƒÂ©Ã‚ÂÃ…Â¾ÃƒÂ¦Ã‚Â³Ã¢â‚¬Â¢ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '5) ÃƒÂ§Ã…Â¸Ã‚Â¥ÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â ÃƒÂ¤Ã‚ÂºÃ‚Â§ÃƒÂ¦Ã‚ÂÃ†â€™\n'
        'ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¨Ã‚Â½Ã‚Â¯ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã¢â‚¬Å“Ã‚ÂÃƒÂ§Ã¢â‚¬Â°Ã…â€™ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¥Ã¢â‚¬Â Ã¢â‚¬Â¦ÃƒÂ¥Ã‚Â®Ã‚Â¹ÃƒÂ¤Ã‚Â»Ã‚ÂÃƒÂ¥Ã‚Â½Ã¢â‚¬â„¢ H&F ÃƒÂ¥Ã‚ÂÃ…Â ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¶ÃƒÂ¨Ã‚Â®Ã‚Â¸ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â¹ÃƒÂ¦Ã¢â‚¬Â°Ã¢â€šÂ¬ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '6) ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¦Ã¢â‚¬Â¹Ã¢â‚¬Â¦ÃƒÂ¤Ã‚Â¿Ã‚Â\n'
        'ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã…â€™Ã¢â‚¬Â°ÃƒÂ¢Ã¢â€šÂ¬Ã…â€œÃƒÂ¥Ã…Â½Ã…Â¸ÃƒÂ¦Ã‚Â Ã‚Â·ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ§Ã‚Â»Ã‚Â­ÃƒÂ¨Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¨Ã‚Â¾Ã‚Â¾ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ§Ã¢â‚¬Â°Ã‚Â¹ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã‚ÂÃ‚Â¥ÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ¦Ã¢â‚¬Â¢Ã‹â€ ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¥Ã¢â€žÂ¢Ã‚Â¨ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â ÃƒÂ¥Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ§Ã‚Â§Ã‚ÂÃƒÂ¥Ã…Â½Ã…Â¸ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â ÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ§Ã…Â½Ã‚Â°ÃƒÂ¥Ã‚Â¤Ã…Â¡ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã‚Â°Ã¢â‚¬ËœÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '7) ÃƒÂ¨Ã‚Â´Ã‚Â£ÃƒÂ¤Ã‚Â»Ã‚Â»ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¥Ã‹â€ Ã‚Â¶\n'
        'H&F ÃƒÂ¥Ã‚Â¯Ã‚Â¹ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¨Ã¢â€šÂ¬Ã…â€™ÃƒÂ©Ã¢â€šÂ¬Ã‚Â ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ©Ã¢â‚¬â€Ã‚Â´ÃƒÂ¦Ã…Â½Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã¢â€žÂ¢Ã¢â‚¬Å¾ÃƒÂ¥Ã‚Â¸Ã‚Â¦ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ¦Ã‚ÂÃ…Â¸ÃƒÂ¥Ã‚Â®Ã‚Â³ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¦Ã¢â‚¬Â°Ã‚Â¿ÃƒÂ¦Ã¢â‚¬Â¹Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â´Ã‚Â£ÃƒÂ¤Ã‚Â»Ã‚Â»ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'legal.disclaimer.content':
        'H&F ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¦Ã‹Å“Ã‚Â¯ÃƒÂ¥Ã…â€™Ã‚Â»ÃƒÂ§Ã¢â‚¬â€œÃ¢â‚¬â€ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¦Ã‚ÂÃ‚ÂÃƒÂ¤Ã‚Â¾Ã¢â‚¬ÂºÃƒÂ¥Ã…â€™Ã‚Â»ÃƒÂ§Ã¢â‚¬â€œÃ¢â‚¬â€ÃƒÂ¥Ã‚Â»Ã‚ÂºÃƒÂ¨Ã‚Â®Ã‚Â®ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â¯Ã…Â ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â­ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¦Ã‚Â²Ã‚Â»ÃƒÂ§Ã¢â‚¬â€œÃ¢â‚¬â€ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '1) ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ©Ã‚Â£Ã…Â½ÃƒÂ©Ã¢â€žÂ¢Ã‚Â©\n'
        'ÃƒÂ¨Ã‚Â¿Ã‚ÂÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€ÃƒÂ¤Ã‚Â¼Ã‚Â¤ÃƒÂ©Ã‚Â£Ã…Â½ÃƒÂ©Ã¢â€žÂ¢Ã‚Â©ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¦Ã¢â‚¬Å¾Ã…Â¸ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ§Ã¢â‚¬â€œÃ‚Â¼ÃƒÂ§Ã¢â‚¬â€Ã¢â‚¬ÂºÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã‚Â¤Ã‚Â´ÃƒÂ¦Ã¢â€žÂ¢Ã¢â‚¬Â¢ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã¢â‚¬ËœÃ‚Â¼ÃƒÂ¥Ã‚ÂÃ‚Â¸ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â°ÃƒÂ©Ã…Â¡Ã‚Â¾ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ©Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ§Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ¥Ã‚ÂÃ‚Â³ÃƒÂ¥Ã‚ÂÃ…â€œÃƒÂ¦Ã‚Â­Ã‚Â¢ÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ¥Ã¢â‚¬â„¢Ã‚Â¨ÃƒÂ¨Ã‚Â¯Ã‚Â¢ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Å“ÃƒÂ¥Ã‚Â®Ã‚Â¶ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '2) AIÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ©Ã‚Â¦Ã‹â€ \n'
        'ÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¦Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â ÃƒÂ¥Ã‹â€ Ã‚Â«ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¥Ã‚Â¤Ã‚ÂÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ§Ã‚Â»Ã…Â¸ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¥Ã‚Â±Ã…Â¾ÃƒÂ¤Ã‚ÂºÃ…Â½ÃƒÂ¤Ã‚Â¼Ã‚Â°ÃƒÂ§Ã‚Â®Ã¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â ÃƒÂ¦Ã¢â‚¬ËœÃ¢â‚¬Å¾ÃƒÂ¥Ã†â€™Ã‚ÂÃƒÂ¨Ã‚Â§Ã¢â‚¬â„¢ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã¢â‚¬Â¦Ã¢â‚¬Â°ÃƒÂ§Ã‚ÂºÃ‚Â¿ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ©Ã‚ÂÃ‚Â®ÃƒÂ¦Ã…â€™Ã‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ§Ã‚Â©Ã‚Â¿ÃƒÂ§Ã‚ÂÃ¢â€šÂ¬ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ©Ã¢â€šÂ¬Ã…Â¸ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¨Ã¢â€šÂ¬Ã…â€™ÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ©Ã¢â‚¬ÂÃ¢â€žÂ¢ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '3) ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ¨Ã†â€™Ã‚Â½\n'
        'ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ¥Ã‚Â¸Ã‚Â¸ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Å“ÃƒÂ¥Ã‚Â¼Ã¢â€šÂ¬ÃƒÂ¦Ã¢â‚¬Â°Ã¢â‚¬Â¹ÃƒÂ¦Ã…â€œÃ‚ÂºÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°/ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¨Ã‚Â¢Ã‚Â«ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ§Ã‚Â¨Ã‚Â³ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ¥Ã‚Â·Ã‚Â¥ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã‚Â§Ã‚Â¿ÃƒÂ¦Ã¢â€šÂ¬Ã‚ÂÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â ÃƒÂ¥Ã‹â€ Ã‚Â«ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ¨Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '4) ÃƒÂ§Ã‚Â´Ã‚Â§ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â¥ÃƒÂ¦Ã†â€™Ã¢â‚¬Â¦ÃƒÂ¥Ã¢â‚¬Â Ã‚Âµ\n'
        'ÃƒÂ§Ã‚Â´Ã‚Â§ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â¥ÃƒÂ¦Ã†â€™Ã¢â‚¬Â¦ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂµÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¤Ã‚Â¾Ã‚ÂÃƒÂ¨Ã‚ÂµÃ¢â‚¬â€œÃƒÂ¦Ã…â€œÃ‚Â¬ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ§Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ¥Ã‚ÂÃ‚Â³ÃƒÂ¨Ã‚ÂÃ¢â‚¬ÂÃƒÂ§Ã‚Â³Ã‚Â»ÃƒÂ¥Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ¦Ã¢â€šÂ¬Ã‚Â¥ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '5) ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‹â€ Ã‚Â·ÃƒÂ¨Ã‚Â´Ã‚Â£ÃƒÂ¤Ã‚Â»Ã‚Â»\n'
        'ÃƒÂ¦Ã¢â‚¬Å¡Ã‚Â¨ÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ§Ã‚Â©Ã‚ÂºÃƒÂ©Ã¢â‚¬â€Ã‚Â´ÃƒÂ¥Ã‚Â®Ã¢â‚¬Â°ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ¨Ã…Â½Ã‚Â·ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€œÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã…â€™Ã‚Â»ÃƒÂ§Ã¢â‚¬â€œÃ¢â‚¬â€ÃƒÂ¦Ã¢â‚¬Â°Ã‚Â¹ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '6) ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¤Ã‚Â»Ã¢â‚¬â€œÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ©Ã…Â¡Ã‚ÂÃƒÂ§Ã‚Â§Ã‚Â\n'
        'ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¥Ã‚Â¾Ã‚ÂÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ©Ã…Â¸Ã‚Â³ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã†â€™Ã‚Â½ÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂºÃƒÂ§Ã…Â½Ã‚Â°ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã¢â‚¬Â°Ã¢â€šÂ¬ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ¥Ã¢â‚¬ËœÃ‹Å“ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\n\n'
        '7) ÃƒÂ§Ã‚Â»Ã¢â‚¬Å“ÃƒÂ¦Ã…Â¾Ã…â€œ\n'
        'ÃƒÂ¥Ã‚ÂÃ‚Â¥ÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ¦Ã¢â‚¬Â¢Ã‹â€ ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â ÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ¨Ã¢â€šÂ¬Ã…â€™ÃƒÂ¥Ã‚Â¼Ã¢â‚¬Å¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡H&F ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ§Ã¢â‚¬Â°Ã‚Â¹ÃƒÂ¥Ã‚Â®Ã…Â¡ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã…Â½Ã‚Â°ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã‚ÂÃ‚Â¥ÃƒÂ¥Ã‚ÂºÃ‚Â·ÃƒÂ§Ã‚Â»Ã¢â‚¬Å“ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'settings.select_theme': 'ÃƒÂ©Ã¢â€šÂ¬Ã¢â‚¬Â°ÃƒÂ¦Ã¢â‚¬Â¹Ã‚Â©ÃƒÂ¤Ã‚Â¸Ã‚Â»ÃƒÂ©Ã‚Â¢Ã‹Å“',
    'settings.select_language': 'ÃƒÂ©Ã¢â€šÂ¬Ã¢â‚¬Â°ÃƒÂ¦Ã¢â‚¬Â¹Ã‚Â©ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬',
    'onboarding.language_title': 'ÃƒÂ©Ã¢â€šÂ¬Ã¢â‚¬Â°ÃƒÂ¦Ã¢â‚¬Â¹Ã‚Â©ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â¯Ã‚Â­ÃƒÂ¨Ã‚Â¨Ã¢â€šÂ¬',
    'onboarding.language_subtitle': 'ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¤Ã‚Â»Ã‚Â¥ÃƒÂ§Ã‚Â¨Ã‚ÂÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'onboarding.name_title': 'ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã‚Â­Ã¢â‚¬â€ÃƒÂ¦Ã‹Å“Ã‚Â¯ÃƒÂ¯Ã‚Â¼Ã…Â¸',
    'onboarding.name_subtitle': 'ÃƒÂ¨Ã‚Â¿Ã¢â€žÂ¢ÃƒÂ¥Ã‚Â°Ã¢â‚¬Â ÃƒÂ¦Ã‹Å“Ã‚Â¾ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ¨Ã‚ÂµÃ¢â‚¬Å¾ÃƒÂ¦Ã¢â‚¬â€œÃ¢â€žÂ¢ÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'onboarding.name_hint': 'ÃƒÂ¨Ã‚Â¾Ã¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã‚Â­Ã¢â‚¬â€',
    'onboarding.name_required': 'ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¨Ã‚Â¾Ã¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã‚Â­Ã¢â‚¬â€',
    'onboarding.disclaimer_title': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚ÂÃƒÂ¨Ã‚Â´Ã‚Â£ÃƒÂ¥Ã‚Â£Ã‚Â°ÃƒÂ¦Ã‹Å“Ã…Â½',
    'onboarding.terms_title': 'ÃƒÂ¦Ã…â€œÃ‚ÂÃƒÂ¥Ã…Â Ã‚Â¡ÃƒÂ¦Ã‚ÂÃ‚Â¡ÃƒÂ¦Ã‚Â¬Ã‚Â¾',
    'onboarding.accept_notice': 'ÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ§Ã‚Â»Ã‚Â§ÃƒÂ§Ã‚Â»Ã‚Â­ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¥Ã‚ÂºÃ¢â‚¬ÂÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'onboarding.accept_checkbox': 'ÃƒÂ¦Ã‹â€ Ã¢â‚¬ËœÃƒÂ¥Ã‚ÂÃ…â€™ÃƒÂ¦Ã¢â‚¬Å¾Ã‚Â',
    'onboarding.continue': 'ÃƒÂ§Ã‚Â»Ã‚Â§ÃƒÂ§Ã‚Â»Ã‚Â­',
    'onboarding.start_app': 'ÃƒÂ¥Ã‚Â¼Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨',
    'settings.clear_all_data': 'ÃƒÂ¦Ã‚Â¸Ã¢â‚¬Â¦ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¦Ã¢â‚¬Â°Ã¢â€šÂ¬ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®',
    'settings.clear_all_data_desc': 'ÃƒÂ¨Ã‚Â¿Ã¢â€žÂ¢ÃƒÂ¥Ã‚Â°Ã¢â‚¬Â ÃƒÂ¥Ã‹â€ Ã‚Â ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã¢â‚¬Â°Ã¢â€šÂ¬ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¨Ã‚Â®Ã‚Â°ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ£Ã¢â€šÂ¬Ã‚ÂÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¥Ã‚Â°Ã‚Â±ÃƒÂ¥Ã¢â‚¬â„¢Ã…â€™ÃƒÂ¨Ã‚Â®Ã‚Â¾ÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¸Ã¢â‚¬ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¦Ã‚Â³Ã¢â‚¬Â¢ÃƒÂ¦Ã¢â‚¬â„¢Ã‚Â¤ÃƒÂ©Ã¢â‚¬ÂÃ¢â€šÂ¬ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'settings.clear_success': 'ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‹â€ Ã‚Â·ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¥Ã…Â Ã…Â¸ÃƒÂ¦Ã‚Â¸Ã¢â‚¬Â¦ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'settings.clear_failed': 'ÃƒÂ¦Ã‚Â¸Ã¢â‚¬Â¦ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¨Ã‚Â´Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡{error}',
    'theme.light': 'ÃƒÂ¦Ã‚ÂµÃ¢â‚¬Â¦ÃƒÂ¨Ã¢â‚¬Â°Ã‚Â²',
    'theme.dark': 'ÃƒÂ¦Ã‚Â·Ã‚Â±ÃƒÂ¨Ã¢â‚¬Â°Ã‚Â²',
    'theme.gold': 'ÃƒÂ©Ã¢â‚¬Â¡Ã¢â‚¬ËœÃƒÂ¨Ã¢â‚¬Â°Ã‚Â²',
    'theme.pink': 'ÃƒÂ§Ã‚Â²Ã¢â‚¬Â°ÃƒÂ¨Ã¢â‚¬Â°Ã‚Â²',
    'progress.title': 'ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¤Ã‚Â¸Ã…Â½ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚Â',
    'progress.overview': 'ÃƒÂ¦Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¨Ã‚Â§Ã‹â€ ',
    'progress.exercises': 'ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™',
    'progress.badges': 'ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ',
    'progress.no_data': 'ÃƒÂ¦Ã…Â¡Ã¢â‚¬Å¡ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®',
    'progress.weekly_summary': 'ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¥Ã¢â‚¬ËœÃ‚Â¨ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â»ÃƒÂ§Ã‚Â»Ã¢â‚¬Å“',
    'progress.streak_days': 'ÃƒÂ¨Ã‚Â¿Ã…Â¾ÃƒÂ§Ã‚Â»Ã‚Â­ {count} ÃƒÂ¥Ã‚Â¤Ã‚Â©',
    'progress.recent_workouts': 'ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ËœÃƒÂ¦Ã…â€œÃ…Â¸ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™',
    'progress.no_workouts': 'ÃƒÂ¦Ã…Â¡Ã¢â‚¬Å¡ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™',
    'progress.workout_summary': '{reps} ÃƒÂ¦Ã‚Â¬Ã‚Â¡ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ {accuracy}%',
    'progress.achievements': 'ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¥Ã‚Â°Ã‚Â±',
    'progress.badges_unlocked': 'ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚Â {unlocked}/{total} ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ',
    'progress.view_all_achievements': 'ÃƒÂ¦Ã…Â¸Ã‚Â¥ÃƒÂ§Ã…â€œÃ¢â‚¬Â¹ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¥Ã‚Â°Ã‚Â±',
    'progress.day.sun': 'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥',
    'progress.day.mon': 'ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬',
    'progress.day.tue': 'ÃƒÂ¤Ã‚ÂºÃ…â€™',
    'progress.day.wed': 'ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â°',
    'progress.day.thu': 'ÃƒÂ¥Ã¢â‚¬ÂºÃ¢â‚¬Âº',
    'progress.day.fri': 'ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â',
    'progress.day.sat': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â­',
    'progress.time.just_now': 'ÃƒÂ¥Ã‹â€ Ã…Â¡ÃƒÂ¥Ã‹â€ Ã…Â¡',
    'progress.time.minutes_ago': '{value} ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ©Ã¢â‚¬â„¢Ã…Â¸ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'progress.time.hours_ago': '{value} ÃƒÂ¥Ã‚Â°Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'progress.time.days_ago': '{value} ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'progress.time.weeks_ago': '{value} ÃƒÂ¥Ã¢â‚¬ËœÃ‚Â¨ÃƒÂ¥Ã¢â‚¬Â°Ã‚Â',
    'progress.analytics_intro_title': 'ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚Â',
    'progress.analytics_intro_line1': 'ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â»ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â° = ÃƒÂ¦Ã‚Â­Ã‚Â¤ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¦Ã¢â‚¬Â°Ã¢â€šÂ¬ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¤Ã‚Â¸Ã‚Â­ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.analytics_intro_line2': 'ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ = ÃƒÂ¦Ã¢â‚¬Â°Ã¢â€šÂ¬ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ¥Ã¢â€šÂ¬Ã‚Â¼ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.analytics_intro_line3': 'ÃƒÂ¨Ã‚Â¶Ã¢â‚¬Â¹ÃƒÂ¥Ã…Â Ã‚Â¿ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â¾ = ÃƒÂ©Ã…Â¡Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ©Ã¢â‚¬â€Ã‚Â´ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â²ÃƒÂ§Ã‚ÂºÃ‚Â¿ÃƒÂ¨Ã‚Â¶Ã…Â ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¨Ã‚Â¶Ã…Â ÃƒÂ¥Ã‚Â¥Ã‚Â½ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.analytics_intro_line4': 'ÃƒÂ¥Ã‚ÂÃ‚ÂªÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚ÂÃƒÂ¦Ã¢â‚¬Â°Ã‚ÂÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.read_exercise_analytics_title': 'ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ©Ã‹Å“Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¯Ã‚Â»ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚Â',
    'progress.read_exercise_analytics_line1': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ = ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ËœÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¨Ã‚Â¯Ã¢â‚¬Å¾ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.read_exercise_analytics_line2': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¤Ã‚Â½Ã‚Â³ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ = ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ¦Ã‚Â­Ã‚Â¢ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ¨Ã‚Â¯Ã¢â‚¬Å¾ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.read_exercise_analytics_line3': 'ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¦Ã…Â¸Ã‚Â±ÃƒÂ§Ã…Â Ã‚Â¶ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â¾ÃƒÂ¦Ã‹Å“Ã‚Â¾ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¿Ã¢â‚¬Ëœ 6 ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã…Â¸Ã‚Â±ÃƒÂ¥Ã‚Â­Ã‚ÂÃƒÂ¨Ã‚Â¶Ã…Â ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¨Ã‚Â¶Ã…Â ÃƒÂ¥Ã‚Â¥Ã‚Â½ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.read_exercise_analytics_line4': 'ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¦Ã…Â¸Ã‚Â±ÃƒÂ¥Ã‚Â­Ã‚ÂÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â¹ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¥Ã‚Â­Ã¢â‚¬â€ÃƒÂ¦Ã‹Å“Ã‚Â¯ÃƒÂ¨Ã‚Â¯Ã‚Â¥ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.latest_accuracy': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'progress.best_accuracy': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¤Ã‚Â½Ã‚Â³ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'progress.trend_vs_previous_session': 'ÃƒÂ¨Ã‚Â¾Ã†â€™ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚Â {sign}{delta}%',
    'progress.last_sessions_accuracy_title': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ËœÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ %ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'progress.reps_short': 'ÃƒÂ¦Ã‚Â¬Ã‚Â¡',
    'progress.chart_accuracy_trend_legend': 'ÃƒÂ¦Ã…Â¸Ã‚Â±ÃƒÂ¥Ã‚Â­Ã‚ÂÃƒÂ¨Ã‚Â¶Ã…Â ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¨Ã‚Â¶Ã…Â ÃƒÂ¥Ã‚Â¥Ã‚Â½ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¦Ã¢â‚¬â€œÃ‚Â¹ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ§Ã‚Â­Ã‚Â¾ÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.total_reps_all_time': 'ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â»ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'progress.avg_accuracy_all_sessions': 'ÃƒÂ¥Ã‚Â¹Ã‚Â³ÃƒÂ¥Ã‚ÂÃ¢â‚¬Â¡ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ©Ã†â€™Ã‚Â¨ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'progress.sessions': 'ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚Â',
    'progress.chart_accuracy_trend': 'ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â¾ÃƒÂ¨Ã‚Â¡Ã‚Â¨ÃƒÂ¦Ã‹Å“Ã‚Â¾ÃƒÂ§Ã‚Â¤Ã‚ÂºÃƒÂ¦Ã…â€™Ã¢â‚¬Â°ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¦Ã…â€œÃ…Â¸ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¨Ã‚Â¶Ã¢â‚¬Â¹ÃƒÂ¥Ã…Â Ã‚Â¿ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'progress.no_sessions': 'ÃƒÂ¨Ã‚Â¿Ã‹Å“ÃƒÂ¦Ã‚Â²Ã‚Â¡ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã‚ÂÃ…Â½ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¦Ã‚Â­Ã‚Â¤ÃƒÂ¦Ã…Â¸Ã‚Â¥ÃƒÂ§Ã…â€œÃ¢â‚¬Â¹ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ÃƒÂ¦Ã…Â¾Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.empty': 'ÃƒÂ¦Ã…Â¡Ã¢â‚¬Å¡ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡\nÃƒÂ¥Ã‚Â¼Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¤Ã‚Â»Ã‚Â¥ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ§Ã‚Â¬Ã‚Â¬ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ©Ã¢â‚¬Â¡Ã…â€™ÃƒÂ§Ã‚Â¨Ã¢â‚¬Â¹ÃƒÂ§Ã‚Â¢Ã¢â‚¬ËœÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.collection': 'ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¦Ã¢â‚¬ÂÃ‚Â¶ÃƒÂ¨Ã¢â‚¬â€Ã‚Â',
    'badges.current_status': 'ÃƒÂ¥Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ§Ã…Â Ã‚Â¶ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â',
    'badges.unlocked_count': 'ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚Â {unlocked}/{total} ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ',
    'badges.tier': 'ÃƒÂ§Ã‚Â­Ã¢â‚¬Â°ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¯Ã‚Â¼Ã…Â¡{tier}',
    'badges.next_target':
        'ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…Â¡{name} ({progress}/{requirement}) - ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â»ÃƒÂ¤Ã‚Â½Ã¢â‚¬Å“ {percent}% ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã‹â€ Ã‚Â',
    'badges.how_it_works': 'ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ§Ã‚Â³Ã‚Â»ÃƒÂ§Ã‚Â»Ã…Â¸ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¤Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¨Ã‚Â¿Ã‚ÂÃƒÂ¤Ã‚Â½Ã…â€œ',
    'badges.guide_1': 'ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ©Ã¢â‚¬Â¡Ã¢â‚¬Â¡ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ 5 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ + 2 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã…Â Ã¢â‚¬Å¡ÃƒÂ¥Ã‚Â¥Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã‚ÂÃ‚ÂªÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.guide_2': 'ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¦Ã‚Â­Ã‚Â£ÃƒÂ¥Ã‚Â¸Ã‚Â¸ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â½Ã¢â‚¬Â ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¥Ã‚Â¢Ã…Â¾ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¥Ã‚Â°Ã¢â‚¬ËœÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.guide_3': 'ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ¯Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¶Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¿Ã¢â‚¬Â¡ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ reps/sets ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¥Ã‚Â¢Ã…Â¾ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.guide_4':
        'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ¥Ã¢â‚¬Å“Ã¢â‚¬ËœÃƒÂ©Ã¢â‚¬Å“Ã†â€™ÃƒÂ¦Ã‹â€ Ã¢â‚¬â€œÃƒÂ¥Ã¢â€žÂ¢Ã‚Â¨ÃƒÂ¦Ã‚Â¢Ã‚Â°ÃƒÂ¯Ã‚Â¼Ã…Â¡ÃƒÂ¤Ã‚Â¹Ã…Â¸ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ©Ã¢â€šÂ¬Ã…Â¡ÃƒÂ¨Ã‚Â¿Ã¢â‚¬Â¡ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â¿ÃƒÂ¤Ã‚Â»Ã‚Â£ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â½Ã…â€œÃƒÂ¨Ã…Â½Ã‚Â·ÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ Upper ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ push-upsÃƒÂ¯Ã‚Â¼Ã…â€™Lower ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ squatsÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.guide_5': 'ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¥Ã…Â¸Ã‚ÂºÃƒÂ¤Ã‚ÂºÃ…Â½ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¥Ã‚Â¿Ã¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ§Ã…â€œÃ…Â¸ÃƒÂ¥Ã‚Â®Ã…Â¾ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®ÃƒÂ¦Ã…Â½Ã‚Â¨ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.unlocked_on': 'ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ¤Ã‚ÂºÃ…Â½ {date}',
    'badges.tap_full_plan': 'ÃƒÂ§Ã¢â‚¬Å¡Ã‚Â¹ÃƒÂ¥Ã¢â‚¬Â¡Ã‚Â»ÃƒÂ¦Ã…Â¸Ã‚Â¥ÃƒÂ§Ã…â€œÃ¢â‚¬Â¹ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â´ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¥Ã‹â€ Ã¢â‚¬â„¢',
    'badges.new_unlock_today': 'ÃƒÂ¤Ã‚Â»Ã…Â ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ¯Ã‚Â¼Ã‚ÂÃƒÂ¥Ã‚ÂÃ…Â¡ÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ¥Ã‚Â¥Ã‚Â½ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.unlocked_banner': 'ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ¯Ã‚Â¼Ã‚ÂÃƒÂ¥Ã‚ÂÃ…Â¡ÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ¥Ã‚Â¾Ã‹â€ ÃƒÂ¥Ã‚Â¥Ã‚Â½ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ§Ã‚Â»Ã‚Â§ÃƒÂ§Ã‚Â»Ã‚Â­ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.poster_saved_note': 'ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¦Ã‚ÂµÃ‚Â·ÃƒÂ¦Ã…Â Ã‚Â¥ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¥Ã¢â‚¬Â Ã…â€™ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Å“ÃƒÂ¨Ã‚Â¾Ã¢â‚¬ËœÃƒÂ¯Ã‚Â¼Ã…Â¡{album}ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.poster_save_failed_note': 'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¦Ã‚Â³Ã¢â‚¬Â¢ÃƒÂ¥Ã‚Â°Ã¢â‚¬Â ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¦Ã‚ÂµÃ‚Â·ÃƒÂ¦Ã…Â Ã‚Â¥ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¥Ã¢â‚¬Â Ã…â€™ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¦Ã‚Â£Ã¢â€šÂ¬ÃƒÂ¦Ã…Â¸Ã‚Â¥ÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡ÃƒÂ¦Ã‚ÂÃ†â€™ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.no_tier': 'ÃƒÂ¥Ã‚Â°Ã…Â¡ÃƒÂ¦Ã…â€œÃ‚ÂªÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ§Ã‚Â­Ã¢â‚¬Â°ÃƒÂ§Ã‚ÂºÃ‚Â§',
    'badges.motivation_unlocked': 'ÃƒÂ¥Ã‚Â¹Ã‚Â²ÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ¥Ã‚Â¥Ã‚Â½ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â­Ã‚Â¤ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ§Ã‚Â¨Ã‚Â³ÃƒÂ¥Ã¢â‚¬ÂºÃ‚ÂºÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ§Ã‚Â»Ã‚Â§ÃƒÂ§Ã‚Â»Ã‚Â­ÃƒÂ¥Ã¢â‚¬Â Ã‚Â²ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ§Ã‚Â­Ã¢â‚¬Â°ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.motivation_almost': 'ÃƒÂ¥Ã‚Â¿Ã‚Â«ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ¤Ã‚ÂºÃ¢â‚¬Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¥Ã¢â‚¬Â Ã‚ÂÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã‹â€ Ã‚Â {remaining} ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¥Ã‚ÂÃ‚Â³ÃƒÂ¥Ã‚ÂÃ‚Â¯ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badges.motivation_keep': 'ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ¨Ã‚Â¿Ã…Â¾ÃƒÂ§Ã‚Â»Ã‚Â­ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ©Ã†â€™Ã‚Â½ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¦Ã…Â½Ã‚Â¨ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¦Ã‚Â­Ã‚Â¤ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'tier.bronze': 'ÃƒÂ©Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ©Ã¢â‚¬Å“Ã…â€œ',
    'tier.silver': 'ÃƒÂ§Ã¢â€žÂ¢Ã‚Â½ÃƒÂ©Ã¢â‚¬Å“Ã‚Â¶',
    'tier.gold': 'ÃƒÂ©Ã‚Â»Ã¢â‚¬Å¾ÃƒÂ©Ã¢â‚¬Â¡Ã¢â‚¬Ëœ',
    'tier.platinum': 'ÃƒÂ§Ã¢â€žÂ¢Ã‚Â½ÃƒÂ©Ã¢â‚¬Â¡Ã¢â‚¬Ëœ',
    'badge.first_workout.name': 'ÃƒÂ§Ã‚Â¬Ã‚Â¬ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â­Ã‚Â¥',
    'badge.first_workout.narrative': 'ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ§Ã‚Â¬Ã‚Â¬ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.first_workout.detail1': 'ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…Â¡ÃƒÂ¦Ã‚ÂÃ‚Â¥ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¥Ã‚Â¿Ã¢â‚¬â€ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ 1 ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.first_workout.detail2':
        'Upper ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…Â¡ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â»ÃƒÂ¨Ã‚Â®Ã‚Â¡ 8 ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã‹â€ Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front RaiseÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.first_workout.detail3': 'Core ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…Â¡ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â»ÃƒÂ¨Ã‚Â®Ã‚Â¡ 10 ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã‹â€ Sit-upÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.first_workout.detail4': 'Lower ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…Â¡ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â»ÃƒÂ¨Ã‚Â®Ã‚Â¡ 12 ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã‹â€ Squat / Leg ExtensionÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.name': '15 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â¡',
    'badge.prep.narrative': 'ÃƒÂ©Ã¢â€šÂ¬Ã…Â¡ÃƒÂ¨Ã‚Â¿Ã¢â‚¬Â¡ 15 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¨Ã…Â Ã¢â‚¬Å¡ÃƒÂ¥Ã‚Â¥Ã‚ÂÃƒÂ¥Ã‚Â»Ã‚ÂºÃƒÂ§Ã‚Â«Ã¢â‚¬Â¹ÃƒÂ¦Ã…â€™Ã‚ÂÃƒÂ§Ã‚Â»Ã‚Â­ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail1': '15 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ¥Ã‚Â¤Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…â€™5 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ + 2 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚Â¾Ã‚ÂªÃƒÂ§Ã…Â½Ã‚Â¯ÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ§Ã‚Â¬Ã‚Â¬ 6-7 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¥Ã¢â‚¬â„¢Ã…â€™ÃƒÂ§Ã‚Â¬Ã‚Â¬ 13-14 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¤Ã‚Â¸Ã‚ÂºÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail2':
        'ÃƒÂ§Ã‚Â¬Ã‚Â¬ 1-3 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¯Ã‚Â¼Ã…Â¡Upper 8 reps x 2 setsÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºCore 10 reps x 2 setsÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºLower 12 reps x 2 setsÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail3': 'ÃƒÂ§Ã‚Â¬Ã‚Â¬ 4-5 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¯Ã‚Â¼Ã…Â¡Upper 10x2ÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºCore 12x2ÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºLower 15x2ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail4': 'ÃƒÂ§Ã‚Â¬Ã‚Â¬ 8-12 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¯Ã‚Â¼Ã…Â¡Upper 12x2ÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºCore 15x2ÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºLower 18x2ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail5': 'ÃƒÂ§Ã‚Â¬Ã‚Â¬ 15 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¯Ã‚Â¼Ã…Â¡Upper 12x3ÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºCore 15x3ÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºLower 18x3ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front RaiseÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºCore = Sit-upÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºLower = Squat / Leg ExtensionÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail7': 'Sets = ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¥Ã¢â‚¬Â Ã¢â‚¬Â¦ÃƒÂ¦Ã…â€™Ã¢â‚¬Â°ÃƒÂ§Ã‚Â±Ã‚Â»ÃƒÂ¥Ã‹â€ Ã‚Â«ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.prep.detail8': 'ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ©Ã¢â‚¬ÂÃ¢â€žÂ¢ÃƒÂ¨Ã‚Â¿Ã¢â‚¬Â¡ÃƒÂ¤Ã‚Â»Ã‚Â»ÃƒÂ¦Ã¢â‚¬Å¾Ã‚ÂÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¥Ã‚Â¿Ã¢â‚¬Â¦ÃƒÂ¥Ã‚ÂÃ…Â¡ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…â€™prep ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ§Ã‚Â½Ã‚Â®ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‚Â¹Ã‚Â¶ÃƒÂ¥Ã…â€œÃ‚Â¨ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Â¹ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¤Ã‚Â»Ã…Â½ÃƒÂ§Ã‚Â¬Ã‚Â¬ 1 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ¥Ã‚Â¼Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.name': 'ÃƒÂ§Ã‚Â¬Ã‚Â¬ 1 ÃƒÂ¦Ã…â€œÃ‹â€  ÃƒÂ©Ã‚ÂÃ¢â‚¬â„¢ÃƒÂ©Ã¢â‚¬Å“Ã…â€œ',
    'badge.bronze.narrative': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¥Ã‹â€ Ã¢â‚¬â„¢ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¨Ã¢â‚¬Â¡Ã‚Â´ÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã…Â¸Ã‚ÂºÃƒÂ§Ã‚Â¡Ã¢â€šÂ¬ÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail1': '5 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ + 2 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚Â¾Ã‚ÂªÃƒÂ§Ã…Â½Ã‚Â¯ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ 30 ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail2':
        'Upper ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡18 reps + 3 setsÃƒÂ¯Ã‚Â¼Ã‹â€ Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail3': 'Core ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡24 reps + 3 setsÃƒÂ¯Ã‚Â¼Ã‹â€ Sit-upÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail4':
        'Lower ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡30 reps + 3 setsÃƒÂ¯Ã‚Â¼Ã‹â€ Squat / Leg Extension ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail5': 'ÃƒÂ¨Ã‚Â¶Ã¢â‚¬Â¦ÃƒÂ¨Ã‚Â¿Ã¢â‚¬Â¡ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¤Ã‚Â¸Ã…Â ÃƒÂ©Ã¢â€žÂ¢Ã‚ÂÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ reps/sets ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.bronze.detail6': 'ÃƒÂ¥Ã‚ÂÃ‚Â³ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ¦Ã‚Â¼Ã‚ÂÃƒÂ¦Ã…Â½Ã¢â‚¬Â°ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¹Ã…Â¸ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¤Ã‚Â»Ã…Â½ÃƒÂ§Ã‚Â¬Ã‚Â¬1ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ¥Ã‚Â¼Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.name': 'ÃƒÂ§Ã‚Â¬Ã‚Â¬ 2 ÃƒÂ¦Ã…â€œÃ‹â€  ÃƒÂ§Ã¢â€žÂ¢Ã‚Â½ÃƒÂ©Ã¢â‚¬Å“Ã‚Â¶',
    'badge.silver.narrative': 'ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ©Ã‹Å“Ã‚Â¶ÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail1': '5 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ + 2 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚Â¾Ã‚ÂªÃƒÂ§Ã…Â½Ã‚Â¯ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ 30 ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail2':
        'Upper ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡24 reps + 4 setsÃƒÂ¯Ã‚Â¼Ã‹â€ Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail3': 'Core ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡32 reps + 4 setsÃƒÂ¯Ã‚Â¼Ã‹â€ Sit-upÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail4':
        'Lower ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡40 reps + 4 setsÃƒÂ¯Ã‚Â¼Ã‹â€ Squat / Leg Extension ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail5': 'ÃƒÂ¥Ã‚ÂÃ‚ÂªÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¥Ã‚Â¿Ã‚Â½ÃƒÂ§Ã¢â‚¬Â¢Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.silver.detail6': 'ÃƒÂ¥Ã‚ÂÃ‚Â³ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ¦Ã‚Â¼Ã‚ÂÃƒÂ¦Ã…Â½Ã¢â‚¬Â°ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¹Ã…Â¸ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¤Ã‚Â»Ã…Â½ÃƒÂ§Ã‚Â¬Ã‚Â¬1ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ¥Ã‚Â¼Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.name': 'ÃƒÂ§Ã‚Â¬Ã‚Â¬ 3 ÃƒÂ¦Ã…â€œÃ‹â€  ÃƒÂ©Ã‚Â»Ã¢â‚¬Å¾ÃƒÂ©Ã¢â‚¬Â¡Ã¢â‚¬Ëœ',
    'badge.gold.narrative': 'ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ§Ã‚ÂºÃ‚Â§ÃƒÂ¨Ã¢â€šÂ¬Ã‚ÂÃƒÂ¥Ã…Â Ã¢â‚¬ÂºÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã‚Â·Ã¢â‚¬Â¦ÃƒÂ¥Ã‚Â³Ã‚Â°ÃƒÂ¦Ã…â€œÃ‹â€ ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail1': '5 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ + 2 ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¤Ã‚Â¼Ã¢â‚¬ËœÃƒÂ¦Ã‚ÂÃ‚Â¯ÃƒÂ¥Ã‚Â¾Ã‚ÂªÃƒÂ§Ã…Â½Ã‚Â¯ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ 30 ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ¦Ã‚Â´Ã‚Â»ÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail2':
        'Upper ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡30 reps + 4 setsÃƒÂ¯Ã‚Â¼Ã‹â€ Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail3': 'Core ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡40 reps + 4 setsÃƒÂ¯Ã‚Â¼Ã‹â€ Sit-upÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail4':
        'Lower ÃƒÂ¦Ã‚Â¯Ã‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¯Ã‚Â¼Ã…Â¡50 reps + 4 setsÃƒÂ¯Ã‚Â¼Ã‹â€ Squat / Leg Extension ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail5': 'ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦ÃƒÂ¥Ã…Â¸Ã‚ÂºÃƒÂ¤Ã‚ÂºÃ…Â½ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¥Ã‚Â¿Ã¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã¢â‚¬ÂºÃƒÂ¨Ã‚Â¶Ã¢â‚¬Â¦ÃƒÂ©Ã‚Â¢Ã‚Â reps ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.gold.detail6': 'ÃƒÂ¥Ã‚ÂÃ‚Â³ÃƒÂ¤Ã‚Â½Ã‚Â¿ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ¦Ã‚Â¼Ã‚ÂÃƒÂ¦Ã…Â½Ã¢â‚¬Â°ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¤Ã‚Â¹Ã…Â¸ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ©Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¤Ã‚Â»Ã…Â½ÃƒÂ§Ã‚Â¬Ã‚Â¬1ÃƒÂ¥Ã‚Â¤Ã‚Â©ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ¥Ã‚Â¼Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â§Ã¢â‚¬Â¹ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.default.goal': 'ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â®ÃƒÂ¦Ã‚Â Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…Â¡{description}',
    'badge.default.requirement': 'ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ¦Ã‚Â±Ã¢â‚¬Å¡ÃƒÂ¯Ã‚Â¼Ã…Â¡{requirement} ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'badge.default.status': 'ÃƒÂ¥Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â°Ã‚ÂÃƒÂ§Ã…Â Ã‚Â¶ÃƒÂ¦Ã¢â€šÂ¬Ã‚ÂÃƒÂ¯Ã‚Â¼Ã…Â¡{progress}/{requirement}.',
    'badge.poster.badge_label': 'ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ',
    'badge.poster.user_label': 'ÃƒÂ¨Ã‚Â¾Ã‚Â¾ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¨Ã¢â€šÂ¬Ã¢â‚¬Â¦',
    'badge.poster.requirements_label': 'ÃƒÂ¥Ã‚ÂÃ‹â€ ÃƒÂ¦Ã‚Â Ã‚Â¼ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®',
    'leaderboard.title': 'ÃƒÂ¦Ã…Â½Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ¦Ã‚Â¦Ã…â€œ',
    'leaderboard.achievements': 'ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¥Ã‚Â°Ã‚Â±',
    'leaderboard.global': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ§Ã‚ÂÃ†â€™',
    'leaderboard.achievement_progress': 'ÃƒÂ¦Ã‹â€ Ã‚ÂÃƒÂ¥Ã‚Â°Ã‚Â±ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ÂºÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'leaderboard.personal_bests': 'ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¤Ã‚Â½Ã‚Â³',
    'leaderboard.most_reps': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¥Ã‚Â¤Ã…Â¡ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°',
    'leaderboard.best_accuracy': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ©Ã‚Â«Ã‹Å“ÃƒÂ¥Ã¢â‚¬Â¡Ã¢â‚¬Â ÃƒÂ§Ã‚Â¡Ã‚Â®ÃƒÂ¥Ã‚ÂºÃ‚Â¦',
    'leaderboard.longest_streak': 'ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ©Ã¢â‚¬Â¢Ã‚Â¿ÃƒÂ¨Ã‚Â¿Ã…Â¾ÃƒÂ§Ã‚Â»Ã‚Â­',
    'leaderboard.days': 'ÃƒÂ¥Ã‚Â¤Ã‚Â©',
    'leaderboard.global_simulated': 'ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ§Ã‚ÂÃ†â€™ÃƒÂ¦Ã…Â½Ã¢â‚¬â„¢ÃƒÂ¨Ã‚Â¡Ã…â€™ÃƒÂ¦Ã‚Â¦Ã…â€œÃƒÂ¯Ã‚Â¼Ã‹â€ ÃƒÂ¦Ã‚Â¨Ã‚Â¡ÃƒÂ¦Ã¢â‚¬Â¹Ã…Â¸ÃƒÂ¯Ã‚Â¼Ã¢â‚¬Â°',
    'leaderboard.points': '{score} ÃƒÂ¥Ã‹â€ Ã¢â‚¬Â ',
    'recordings.tab.recordings': 'ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶',
    'recordings.tab.profile': 'ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ¨Ã‚ÂµÃ¢â‚¬Å¾ÃƒÂ¦Ã¢â‚¬â€œÃ¢â€žÂ¢',
    'recordings.failed_load': 'ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ¨Ã‚Â½Ã‚Â½ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¥Ã‚Â¤Ã‚Â±ÃƒÂ¨Ã‚Â´Ã‚Â¥',
    'recordings.empty': 'ÃƒÂ¦Ã…Â¡Ã¢â‚¬Å¡ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬Ëœ',
    'recordings.file_not_found': 'ÃƒÂ¦Ã…â€œÃ‚ÂªÃƒÂ¦Ã¢â‚¬Â°Ã‚Â¾ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ¨Ã‚Â§Ã¢â‚¬Â ÃƒÂ©Ã‚Â¢Ã¢â‚¬ËœÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶',
    'recordings.file_incomplete': 'ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ¦Ã¢â‚¬â€œÃ¢â‚¬Â¡ÃƒÂ¤Ã‚Â»Ã‚Â¶ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â´ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ©Ã¢â‚¬Â¡Ã‚ÂÃƒÂ¦Ã¢â‚¬â€œÃ‚Â°ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.guest_name': 'ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‹â€ Ã‚Â·',
    'profile.user_name_label': 'ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¨ÃƒÂ¦Ã‹â€ Ã‚Â·ÃƒÂ¥Ã‚ÂÃ‚Â',
    'profile.edit_name': 'ÃƒÂ§Ã‚Â¼Ã¢â‚¬â€œÃƒÂ¨Ã‚Â¾Ã¢â‚¬Ëœ',
    'profile.name_hint': 'ÃƒÂ¨Ã‚Â¾Ã¢â‚¬Å“ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¥ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã‚ÂÃ‚ÂÃƒÂ¥Ã‚Â­Ã¢â‚¬â€',
    'profile.save_name': 'ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“',
    'profile.photo_title': 'ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡',
    'profile.photo_subtitle': 'ÃƒÂ¦Ã‚Â·Ã‚Â»ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¥Ã‚Â¼Ã‚Â ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¨ÃƒÂ¨Ã‚ÂºÃ‚Â«ÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â®Ã‚Â©ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ¤Ã‚Â¸Ã‚Â»ÃƒÂ©Ã‚Â¡Ã‚ÂµÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¦Ã…â€œÃ¢â‚¬Â°ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¦Ã¢â€šÂ¬Ã‚Â§ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.photo_add': 'ÃƒÂ¦Ã‚Â·Ã‚Â»ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡',
    'profile.photo_change': 'ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¦Ã‚ÂÃ‚Â¢ÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡',
    'profile.photo_remove': 'ÃƒÂ§Ã‚Â§Ã‚Â»ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡',
    'profile.photo_remove_confirm': 'ÃƒÂ¨Ã‚Â¦Ã‚ÂÃƒÂ§Ã‚Â§Ã‚Â»ÃƒÂ©Ã¢â€žÂ¢Ã‚Â¤ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡ÃƒÂ¥Ã‚ÂÃ¢â‚¬â€ÃƒÂ¯Ã‚Â¼Ã…Â¸',
    'profile.photo_too_large': 'ÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡ÃƒÂ¥Ã‚Â¤Ã‚ÂªÃƒÂ¥Ã‚Â¤Ã‚Â§ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ©Ã¢â€šÂ¬Ã¢â‚¬Â°ÃƒÂ¦Ã¢â‚¬Â¹Ã‚Â©ÃƒÂ¦Ã¢â‚¬ÂºÃ‚Â´ÃƒÂ¥Ã‚Â°Ã‚ÂÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â¾ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.photo_error': 'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¦Ã‚Â³Ã¢â‚¬Â¢ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¨Ã‚Â¯Ã‚Â·ÃƒÂ¥Ã‚Â°Ã‚ÂÃƒÂ¨Ã‚Â¯Ã¢â‚¬Â¢ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¶ÃƒÂ¤Ã‚Â»Ã¢â‚¬â€œÃƒÂ¥Ã¢â‚¬ÂºÃ‚Â¾ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.photo_badge_notice': 'ÃƒÂ¥Ã‚Â¦Ã¢â‚¬Å¡ÃƒÂ¦Ã…Â¾Ã…â€œÃƒÂ¦Ã…â€œÃ‚ÂªÃƒÂ¦Ã‚Â·Ã‚Â»ÃƒÂ¥Ã…Â Ã‚Â ÃƒÂ¤Ã‚Â¸Ã‚ÂªÃƒÂ¤Ã‚ÂºÃ‚ÂºÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¦Ã‚ÂµÃ‚Â·ÃƒÂ¦Ã…Â Ã‚Â¥ÃƒÂ¥Ã‚Â°Ã¢â‚¬Â ÃƒÂ¤Ã‚Â¸Ã‚ÂÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¥Ã…â€™Ã¢â‚¬Â¦ÃƒÂ¥Ã‚ÂÃ‚Â«ÃƒÂ¤Ã‚Â½Ã‚Â ÃƒÂ§Ã…Â¡Ã¢â‚¬Å¾ÃƒÂ§Ã¢â‚¬Â¦Ã‚Â§ÃƒÂ§Ã¢â‚¬Â°Ã¢â‚¬Â¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.exercise_totals_title': 'ÃƒÂ§Ã‚Â´Ã‚Â¯ÃƒÂ¨Ã‚Â®Ã‚Â¡ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™',
    'profile.exercise_totals_subtitle': 'ÃƒÂ¤Ã‚Â»Ã…Â½ÃƒÂ§Ã‚Â¬Ã‚Â¬ÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ¦Ã…â€œÃ¢â€šÂ¬ÃƒÂ¨Ã‚Â¿Ã¢â‚¬ËœÃƒÂ¤Ã‚Â¸Ã¢â€šÂ¬ÃƒÂ¦Ã‚Â¬Ã‚Â¡ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'profile.exercise_empty': 'ÃƒÂ¦Ã…Â¡Ã¢â‚¬Å¡ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¨Ã‚Â®Ã‚Â­ÃƒÂ§Ã‚Â»Ã†â€™ÃƒÂ¦Ã¢â‚¬Â¢Ã‚Â°ÃƒÂ¦Ã‚ÂÃ‚Â®',
    'profile.badges_title': 'ÃƒÂ¥Ã‚Â·Ã‚Â²ÃƒÂ¨Ã…Â½Ã‚Â·ÃƒÂ¥Ã‚Â¾Ã¢â‚¬â€ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ',
    'profile.badges_empty': 'ÃƒÂ¦Ã…Â¡Ã¢â‚¬Å¡ÃƒÂ¦Ã¢â‚¬â€Ã‚Â ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ',
    'profile.badge_gallery_saved_note':
        'ÃƒÂ¥Ã‚Â½Ã¢â‚¬Å“ÃƒÂ¥Ã‚Â¾Ã‚Â½ÃƒÂ§Ã‚Â«Ã‚Â ÃƒÂ¨Ã‚Â§Ã‚Â£ÃƒÂ©Ã¢â‚¬ÂÃ‚ÂÃƒÂ¦Ã¢â‚¬â€Ã‚Â¶ÃƒÂ¯Ã‚Â¼Ã…â€™ÃƒÂ¥Ã¢â‚¬Â¦Ã‚Â¶ÃƒÂ¦Ã‚ÂµÃ‚Â·ÃƒÂ¦Ã…Â Ã‚Â¥ÃƒÂ¤Ã‚Â¼Ã…Â¡ÃƒÂ¨Ã¢â‚¬Â¡Ã‚ÂªÃƒÂ¥Ã…Â Ã‚Â¨ÃƒÂ¤Ã‚Â¿Ã‚ÂÃƒÂ¥Ã‚Â­Ã‹Å“ÃƒÂ¥Ã‹â€ Ã‚Â°ÃƒÂ§Ã¢â‚¬ÂºÃ‚Â¸ÃƒÂ¥Ã¢â‚¬Â Ã…â€™ÃƒÂ¤Ã‚Â¸Ã¢â‚¬Å“ÃƒÂ¨Ã‚Â¾Ã¢â‚¬ËœÃƒÂ¯Ã‚Â¼Ã…Â¡{album}ÃƒÂ£Ã¢â€šÂ¬Ã¢â‚¬Å¡',
    'iconic.menu.title': 'Ã¦Â â€¡Ã¥Â¿â€”Ã©Â£Å½Ã¦Â Â¼Ã¦â€“Â¹Ã¦Â¡Ë†',
    'iconic.menu.subtitle':
        'Ã¤Â¸ÂºÃ¥Â·Â²Ã¥Â½â€¢Ã¥Ë†Â¶Ã§Å¡â€žÃ¨Â§â€ Ã©Â¢â€˜Ã©â‚¬â€°Ã¦â€¹Â©Ã©Â«ËœÃ§ÂºÂ§Ã¥ÂÅ½Ã¦Å“Å¸Ã©Â£Å½Ã¦Â Â¼Ã£â‚¬â€šÃ¦Â¯ÂÃ¤Â¸ÂªÃ¦â€“Â¹Ã¦Â¡Ë†Ã©Æ’Â½Ã§Â»ÂÃ¨Â¿â€¡Ã¨Â®Â¾Ã¨Â®Â¡Ã¯Â¼Å’Ã¥Å“Â¨Ã§â€ºÂ´Ã¦â€™Â­Ã©â€¡â€¡Ã©â€ºâ€ Ã¤Â¸Â­Ã¤Â¸ÂÃ©Â¢ÂÃ¥Â¤â€“Ã¥Â¢Å¾Ã¥Å Â Ã¥Ââ€˜Ã§Æ’Â­Ã§Å¡â€žÃ¥ÂÅ’Ã¦â€”Â¶Ã¯Â¼Å’Ã¥â€˜Ë†Ã§Å½Â°Ã¥â€¡ÂºÃ©Â²Å“Ã¦ËœÅ½Ã£â‚¬ÂÃ§â€ÂµÃ¥Â½Â±Ã¦â€žÅ¸Ã¥â€™Å’Ã§Â²Â¾Ã¨â€¡Â´Ã¦â€žÅ¸Ã£â‚¬â€š',
    'iconic.program.zodiac.eyebrow': 'Ã¥ÂÅ½Ã¦Å“Å¸Ã§Â­Â¾Ã¥ÂÂÃ©Â£Å½Ã¦Â Â¼',
    'iconic.program.zodiac.description':
        'Ã¥Â½â€¢Ã¥Ë†Â¶Ã¥Â®Å’Ã¦Ë†ÂÃ¥ÂÅ½Ã¥Âºâ€Ã§â€Â¨Ã¥Â¥Â¢Ã¥ÂÅ½Ã¦ËœÅ¸Ã¥ÂºÂ§Ã¥ÂÂ Ã¥Â±â€šÃ£â‚¬â€šÃ§Å½Â°Ã¥Å“Â¨ 12 Ã¤Â¸ÂªÃ¦ËœÅ¸Ã¥ÂºÂ§Ã©Æ’Â½Ã¦â€¹Â¥Ã¦Å“â€°Ã§â€¹Â¬Ã§Â«â€¹Ã§Å¡â€žÃ©â€¦ÂÃ¨â€°Â²Ã£â‚¬ÂÃ§Â¬Â¦Ã¥ÂÂ·Ã£â‚¬ÂÃ¥â€¦â€°Ã¦â„¢â€¢Ã¨â€°Â²Ã¨Â°Æ’Ã¥â€™Å’Ã©â€ºâ€¢Ã¥Ë†Â»Ã©Â£Å½Ã¦Â Â¼Ã¯Â¼Å’Ã©Â¢â€žÃ¨Â§Ë†Ã¤Â»Â¥Ã§â„¢Â½Ã§Â¾Å Ã¥ÂºÂ§Ã§Å¡â€žÃ¨â€°ÂºÃ¦Å“Â¯Ã¦â€“Â¹Ã¥Ââ€˜Ã¤Â¸ÂºÃ¥Å¸ÂºÃ¥â€¡â€ Ã£â‚¬â€š',
    'iconic.program.zodiac.tag.sign_themes': '12 Ã¦ËœÅ¸Ã¥ÂºÂ§Ã¤Â¸Â»Ã©Â¢Ëœ',
    'iconic.program.zodiac.tag.luxury_capsule': 'Ã¥Â¥Â¢Ã¥ÂÅ½Ã©Â£Å½Ã¦Â Â¼',
    'iconic.program.zodiac.tag.embossed_coin': 'Ã¦ÂµÂ®Ã©â€ºâ€¢Ã¥Â¾Â½Ã§Â«Â ',
    'iconic.program.zodiac.footer':
        'Ã©â‚¬â€šÃ¥ÂË†Ã§â€Â¨Ã¤ÂºÅ½Ã¦Â â€¡Ã¥Â¿â€”Ã¦â‚¬Â§Ã¥Â¯Â¼Ã¥â€¡ÂºÃ£â‚¬â€šÃ¥Â®Å¾Ã¦â€”Â¶Ã¦â€¹ÂÃ¦â€˜â€žÃ¤Â¿ÂÃ¦Å’ÂÃ¨Â½Â»Ã©â€¡ÂÃ¯Â¼Å’Ã©ÂÂ¿Ã¥â€¦ÂÃ¦â€°â€¹Ã¦Å“ÂºÃ¨Â¿â€¡Ã§Æ’Â­Ã¯Â¼Å’Ã¨â‚¬Å’Ã¥Â¥Â¢Ã¥ÂÅ½Ã¥Â¤â€žÃ§Ââ€ Ã¤Â¼Å¡Ã¥Å“Â¨Ã¥Â½â€¢Ã¥Ë†Â¶Ã¥ÂÅ½Ã©â‚¬Å¡Ã¨Â¿â€¡Ã¥ÂÅ½Ã¦Å“Å¸Ã¥Å Â Ã¥â€¦Â¥Ã£â‚¬â€š',
    'iconic.program.festival.eyebrow': 'Ã¦â€“â€¡Ã¥Å’â€“Ã¥Âºâ€ Ã¥â€¦Â¸',
    'iconic.program.festival.description':
        'Ã¦Â Â¹Ã¦ÂÂ®Ã¦Å“â‚¬Ã¨Â¿â€˜Ã§Å¡â€žÃ¤Â¸â€“Ã§â€¢Å’Ã¨Å â€šÃ¥Âºâ€ Ã¦Ë†â€“Ã¤Â½â€œÃ¨â€šÂ²Ã¨Âµâ€ºÃ¤Âºâ€¹Ã¥Âºâ€Ã§â€Â¨Ã§â€¹Â¬Ã§â€°Â¹Ã§Å¡â€žÃ¥Â¥Â¢Ã¥ÂÅ½Ã¥ÂÂ Ã¥Â±â€šÃ£â‚¬â€šÃ¦Â¯ÂÃ¤Â¸ÂªÃ¨Å â€šÃ¥Âºâ€ Ã©Æ’Â½Ã¦Å“â€°Ã¨â€¡ÂªÃ¥Â·Â±Ã§Å¡â€žÃ©â€¦ÂÃ¨â€°Â²Ã£â‚¬ÂÃ§Å½Â¯Ã¥Â½Â¢Ã¨Â¾â€°Ã¥â€¦â€°Ã£â‚¬ÂÃ¥â€¡â€ Ã§Â¡Â®Ã¥ÂºÂ¦Ã¦ÂÂ¡Ã¦Â¸ÂÃ¥ÂËœÃ¥â€™Å’Ã¥â€œÂÃ§â€°Å’Ã¦Â Â·Ã¥Â¼ÂÃ£â‚¬â€š',
    'iconic.program.festival.tag.festivals': '70 Ã¤Â¸ÂªÃ¨Å â€šÃ¥Âºâ€ ',
    'iconic.program.festival.tag.date_aware': 'Ã©Å¡ÂÃ¦â€”Â¥Ã¦Å“Å¸Ã¥ÂËœÃ¥Å’â€“',
    'iconic.program.festival.tag.luxury_overlay': 'Ã¥Â¥Â¢Ã¥ÂÅ½Ã¥ÂÂ Ã¥Â±â€š',
    'iconic.program.festival.footer':
        'Ã¤Â¸Â»Ã©Â¢ËœÃ¤Â¼Å¡Ã¨â€¡ÂªÃ¥Å Â¨Ã¥Ë†â€¡Ã¦ÂÂ¢Ã¥Ë†Â°Ã¦Å“â‚¬Ã¨Â¿â€˜Ã¥ÂÂ³Ã¥Â°â€ Ã¥Ë†Â°Ã¦ÂÂ¥Ã§Å¡â€žÃ¥Âºâ€ Ã¥â€¦Â¸Ã£â‚¬â€šÃ¥Â½â€¢Ã¥Ë†Â¶Ã¤Â½Â Ã§Å¡â€žÃ¨Â®Â­Ã§Â»Æ’Ã¥ÂÅ½Ã¯Â¼Å’Ã¥Â½â€œÃ¥â€°ÂÃ¨Å â€šÃ¥Âºâ€ Ã©Â£Å½Ã¦Â Â¼Ã¤Â¼Å¡Ã¥Å“Â¨Ã¥ÂÅ½Ã¦Å“Å¸Ã¥Â¤â€žÃ§Ââ€ Ã¤Â¸Â­Ã¨â€¡ÂªÃ¥Å Â¨Ã¥Âºâ€Ã§â€Â¨Ã£â‚¬â€š',
    'iconic.program.studio.eyebrow': 'Ã¥Â®Å’Ã¥â€¦Â¨Ã¥ÂÂ¯Ã¥Â®Å¡Ã¥Ë†Â¶',
    'iconic.program.studio.description':
        'Ã¤Â½Â¿Ã§â€Â¨Ã¤Â½Â Ã¨â€¡ÂªÃ¥Â·Â±Ã§Å¡â€žÃ©Â«ËœÃ§ÂºÂ§Ã¥ÂÂ Ã¥Â±â€šÃ§Â³Â»Ã§Â»Å¸Ã¯Â¼Å’Ã¥ÂÂ¯Ã§Â¼â€“Ã¨Â¾â€˜Ã¦Â¬Â¡Ã¦â€¢Â°Ã¨Â®Â¡Ã¦â€¢Â°Ã¥â„¢Â¨Ã£â‚¬ÂÃ¥â€¡â€ Ã§Â¡Â®Ã¥ÂºÂ¦Ã¦ÂÂ¡Ã£â‚¬ÂÃ¥Ââ„¢Ã¤Âºâ€¹Ã¦ÂµÂÃ§Â¨â€¹Ã£â‚¬ÂÃ¥â€ºÂ¾Ã¦Â â€¡Ã£â‚¬ÂÃ©â€¦ÂÃ¨â€°Â²Ã¦â€“Â¹Ã¦Â¡Ë†Ã¥â€™Å’Ã¦â€Â¶Ã¥Â°Â¾Ã¦Å½Â§Ã¥Ë†Â¶Ã£â‚¬â€š',
    'iconic.program.studio.tag.custom_program': 'Ã¨â€¡ÂªÃ¥Â®Å¡Ã¤Â¹â€°Ã¦â€“Â¹Ã¦Â¡Ë†',
    'iconic.program.studio.tag.luxury_editor': 'Ã¥Â¥Â¢Ã¥ÂÅ½Ã§Â¼â€“Ã¨Â¾â€˜Ã¥â„¢Â¨',
    'iconic.program.studio.tag.premium_control': 'Ã©Â«ËœÃ§ÂºÂ§Ã¦Å½Â§Ã¥Ë†Â¶',
    'iconic.program.studio.footer':
        'Ã¥Â¦â€šÃ¦Å¾Å“Ã¤Â½Â Ã¦Æ’Â³Ã¨Â¦ÂÃ¨â€¡ÂªÃ¥Â·Â±Ã¦â€°â€¹Ã¥Â·Â¥Ã¦â€°â€œÃ©â‚¬Â Ã§Å¡â€žÃ¥Â¥Â¢Ã¥ÂÅ½Ã¥ÂÂ Ã¥Â±â€šÃ¯Â¼Å’Ã¨â‚¬Å’Ã¤Â¸ÂÃ¦ËœÂ¯Ã¥â€ºÂºÃ¥Â®Å¡Ã§Å¡â€žÃ¦ËœÅ¸Ã¥ÂºÂ§Ã¦Ë†â€“Ã¨Å â€šÃ¥Âºâ€ Ã©Â£Å½Ã¦Â Â¼Ã¯Â¼Å’Ã¥Â°Â±Ã©â‚¬â€°Ã¦â€¹Â©Ã¨Â¿â„¢Ã¤Â¸ÂªÃ£â‚¬â€š',
    'iconic.program.studio.action': 'Ã¦â€°â€œÃ¥Â¼â‚¬Ã¥Â·Â¥Ã¤Â½Å“Ã¥Â®Â¤',
    'iconic.program.standard.eyebrow': 'Ã¨Â½Â»Ã©â€¡ÂÃ©Â»ËœÃ¨Â®Â¤',
    'iconic.program.standard.description':
        'Ã¥Â½â€œÃ¤Â½Â Ã¤Â¸ÂÃ¦Æ’Â³Ã¨Â¦ÂÃ¥â€œÂÃ§â€°Å’Ã¥Å’â€“Ã§â€ÂµÃ¥Â½Â±Ã¦â€žÅ¸Ã©Â£Å½Ã¦Â Â¼Ã¦â€”Â¶Ã¯Â¼Å’Ã¤Â¿ÂÃ§â€¢â„¢Ã¥Â½â€œÃ¥â€°ÂÃ§Â®â‚¬Ã¦Â´ÂÃ§Å¡â€žÃ¥ÂÂ Ã¥Â±â€šÃ¦Â Â·Ã¥Â¼ÂÃ£â‚¬â€š',
    'iconic.program.standard.tag.default': 'Ã©Â»ËœÃ¨Â®Â¤',
    'iconic.program.standard.tag.minimal': 'Ã¦Å¾ÂÃ§Â®â‚¬',
    'iconic.program.standard.tag.fast_export': 'Ã¥Â¿Â«Ã©â‚¬Å¸Ã¥Â¯Â¼Ã¥â€¡Âº',
    'iconic.program.standard.footer':
        'Ã¥Â¦â€šÃ¦Å¾Å“Ã¤Â½Â Ã¦Æ’Â³Ã§Â»Â§Ã§Â»Â­Ã¤Â½Â¿Ã§â€Â¨Ã¥Â½â€œÃ¥â€°ÂÃ¥Â¯Â¼Ã¥â€¡ÂºÃ©Â£Å½Ã¦Â Â¼Ã¨â‚¬Å’Ã¤Â¸ÂÃ©Å“â‚¬Ã¨Â¦ÂÃ©Â«ËœÃ§ÂºÂ§Ã¨â€°ÂºÃ¦Å“Â¯Ã¦Å’â€¡Ã¥Â¯Â¼Ã¯Â¼Å’Ã¥Â°Â±Ã©â‚¬â€°Ã¨Â¿â„¢Ã¤Â¸ÂªÃ£â‚¬â€š',
    'iconic.info.title': 'Ã¤Â½Â¿Ã§â€Â¨Ã¦â€“Â¹Ã¥Â¼Â',
    'iconic.info.step1': '1. Ã¥Å“Â¨Ã¨Â¿â„¢Ã©â€¡Å’Ã©â‚¬â€°Ã¦â€¹Â©Ã¤Â¸â‚¬Ã¤Â¸ÂªÃ¦â€“Â¹Ã¦Â¡Ë†Ã£â‚¬â€š',
    'iconic.info.step2': '2. Ã¥Æ’ÂÃ¥Â¹Â³Ã¥Â¸Â¸Ã¤Â¸â‚¬Ã¦Â Â·Ã¥Â½â€¢Ã¥Ë†Â¶Ã¨Â®Â­Ã§Â»Æ’Ã£â‚¬â€š',
    'iconic.info.step3':
        '3. Ã¦â€°â‚¬Ã©â‚¬â€°Ã©Â£Å½Ã¦Â Â¼Ã¥ÂÂªÃ¤Â¼Å¡Ã¥Å“Â¨Ã¥Â½â€¢Ã¥Ë†Â¶Ã¥Â®Å’Ã¦Ë†ÂÃ¥ÂÅ½Ã§Å¡â€žÃ¥ÂÅ½Ã¦Å“Å¸Ã¥Â¤â€žÃ§Ââ€ Ã¤Â¸Â­Ã¥Âºâ€Ã§â€Â¨Ã£â‚¬â€š',
    'iconic.preview.post_process': 'Ã¥ÂÅ½Ã¦Å“Å¸Ã©Â¢â€žÃ¨Â§Ë†',
    'iconic.preview.standard.caption':
        'Ã©Â»ËœÃ¨Â®Â¤Ã¥Â¯Â¼Ã¥â€¡ÂºÃ¥ÂÂ Ã¥Â±â€š\nÃ¤Â¿ÂÃ§â€¢â„¢Ã¥Â½â€œÃ¥â€°ÂÃ§Å¡â€žÃ¨Â½Â»Ã©â€¡ÂÃ©Â£Å½Ã¦Â Â¼Ã£â‚¬â€š',
    'iconic.preview.editable_luxe': 'Ã¥ÂÂ¯Ã§Â¼â€“Ã¨Â¾â€˜Ã¥Â¥Â¢Ã¥ÂÅ½',
    'camera.overlay.skeleton': 'ÃƒÂ©Ã‚ÂªÃ‚Â¨ÃƒÂ¦Ã…Â¾Ã‚Â¶',
    'camera.overlay.stop': 'ÃƒÂ¥Ã‚ÂÃ…â€œÃƒÂ¦Ã‚Â­Ã‚Â¢',
    'camera.overlay.record': 'ÃƒÂ¥Ã‚Â½Ã¢â‚¬Â¢ÃƒÂ¥Ã‹â€ Ã‚Â¶',
    'camera.overlay.complete': 'ÃƒÂ¥Ã‚Â®Ã…â€™ÃƒÂ¦Ã‹â€ Ã‚Â',
    'lang.en': 'ÃƒÂ¨Ã¢â‚¬Â¹Ã‚Â±ÃƒÂ¨Ã‚Â¯Ã‚Â­',
    'lang.es': 'ÃƒÂ¨Ã‚Â¥Ã‚Â¿ÃƒÂ§Ã‚ÂÃ‚Â­ÃƒÂ§Ã¢â‚¬Â°Ã¢â€žÂ¢ÃƒÂ¨Ã‚Â¯Ã‚Â­',
    'lang.ja': 'ÃƒÂ¦Ã¢â‚¬â€Ã‚Â¥ÃƒÂ¨Ã‚Â¯Ã‚Â­',
    'lang.my': 'ÃƒÂ§Ã‚Â¼Ã¢â‚¬Â¦ÃƒÂ§Ã¢â‚¬ÂÃ‚Â¸ÃƒÂ¨Ã‚Â¯Ã‚Â­',
    'lang.hi': 'ÃƒÂ¥Ã‚ÂÃ‚Â°ÃƒÂ¥Ã…â€œÃ‚Â°ÃƒÂ¨Ã‚Â¯Ã‚Â­',
    'lang.pt': 'ÃƒÂ¨Ã¢â‚¬ËœÃ‚Â¡ÃƒÂ¨Ã‚ÂÃ¢â‚¬Å¾ÃƒÂ§Ã¢â‚¬Â°Ã¢â€žÂ¢ÃƒÂ¨Ã‚Â¯Ã‚Â­',
    'lang.zh': 'ÃƒÂ¦Ã¢â€žÂ¢Ã‚Â®ÃƒÂ©Ã¢â€šÂ¬Ã…Â¡ÃƒÂ¨Ã‚Â¯Ã‚Â',
    'lang.de': 'ÃƒÂ¥Ã‚Â¾Ã‚Â·ÃƒÂ¨Ã‚Â¯Ã‚Â­',
  };

  static const Map<String, String> _deValues = {
    'app.title': 'H&F',
    'nav.exercises': 'ÃƒÆ’Ã…â€œbungen',
    'nav.progress': 'Fortschritt',
    'nav.recordings': 'Aufnehmen und Profil',
    'common.cancel': 'Abbrechen',
    'common.retry': 'Erneut versuchen',
    'common.load_exercises': 'ÃƒÆ’Ã…â€œbungen laden',
    'common.clear_data': 'Daten lÃƒÆ’Ã‚Â¶schen',
    'common.ok': 'OK',
    'common.close': 'SchlieÃƒÆ’Ã…Â¸en',
    'common.error_with_message': 'Fehler: {message}',
    'premium.badge': 'PREMIUM',
    'premium.menu_only': 'Dieses MenÃƒÆ’Ã‚Â¼ ist nur fÃƒÆ’Ã‚Â¼r PremiumÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœNutzer verfÃƒÆ’Ã‚Â¼gbar.',
    'home.exercises_list': 'ÃƒÆ’Ã…â€œbungsliste',
    'home.exercises_simple_form': 'Einfaches ÃƒÆ’Ã…â€œbungsformular',
    'home.no_supported_exercises': 'Keine unterstÃƒÆ’Ã‚Â¼tzten ÃƒÆ’Ã…â€œbungen verfÃƒÆ’Ã‚Â¼gbar',
    'home.check_exercise_config': 'Bitte ÃƒÆ’Ã…â€œbungskonfiguration prÃƒÆ’Ã‚Â¼fen',
    'home.error_loading_exercise': 'Fehler beim Laden der ÃƒÆ’Ã…â€œbung: {error}',
    'home.image_reference_count': '{count} Referenzbild',
    'home.today_progress_premium': 'Heutiger Fortschritt (Premium)',
    'home.today_progress_locked_desc':
        'Daten des FortschrittsmenÃƒÆ’Ã‚Â¼s sind nur fÃƒÆ’Ã‚Â¼r PremiumÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœNutzer verfÃƒÆ’Ã‚Â¼gbar.',
    'home.today_progress': 'Heutiger Fortschritt',
    'home.total_reps': 'Gesamtwiederholungen',
    'home.workouts': 'Workouts',
    'home.calories': 'Kalorien',
    'home.daily_goal': 'Tagesziel: {current}/{goal}',
    'home.daily_goal_achieved': 'Tagesziel erreicht!',
    'home.progress_premium_title': 'Fortschritt ist Premium',
    'home.progress_premium_message':
        'Detaillierte Fortschrittsanalysen sind im Premium freigeschaltet.',
    'home.recordings_premium_title': 'Aufnahmen sind Premium',
    'home.recordings_premium_message':
        'VideoaufnahmenÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœHistorie ist nur im Premium verfÃƒÆ’Ã‚Â¼gbar.',
    'home.simple_form': '{name}-Form',
    'home.quick_form_summary': 'Kurze Formularzusammenfassung',
    'home.form_images': 'Formbilder',
    'home.exercise_list_notice_title': 'Kurzer Hinweis',
    'home.exercise_list_notice_message':
        'Bitte prÃƒÆ’Ã‚Â¼fe jedes ÃƒÆ’Ã…â€œbungsformular, da es Hinweise geben kann. Hinweis: Die situp-ÃƒÆ’Ã…â€œbung hat einen wichtigen Hinweis.',
    'home.simple_form_notice':
        'Hinweis zu Genauigkeitsbalken und ZÃƒÆ’Ã‚Â¤hlung:\nUnsere KI erkennt ÃƒÆ’Ã…â€œbungen, die unseren visuellen LeitfÃƒÆ’Ã‚Â¤den nahekommen. Sie liefert eine flÃƒÆ’Ã‚Â¼ssige ZÃƒÆ’Ã‚Â¤hlung mit guter Genauigkeit, bietet jedoch kein formales TechnikÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœCoaching. Bitte beachte, dass unsere App nicht 100% genau ist.\n\nBei Seitenansicht bitte in der Seitenposition bleiben und bei Frontansicht in der Frontposition bleiben. So sind die Ergebnisse korrekt.\n\nDie Erkennung kann ungenau sein, wenn:\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Dein gesamter KÃƒÆ’Ã‚Â¶rper nicht im Kamerabild zu sehen ist.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Es sind mehr als eine Person in der Kamera zu sehen.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Der Raum zu dunkel ist oder starke Flare/Blendung vorhanden ist.\nÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ Positioniere die Kamera so, dass sie weder zu niedrig noch zu hoch zu deinem KÃƒÆ’Ã‚Â¶rper steht.',
    'exercise.guide.title': 'Kurzanleitung',
    'exercise.guide.step1':
        'Wenn du ein Landmark erstellen mÃƒÆ’Ã‚Â¶chtest, tippe auf den SkelettÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœButton.',
    'exercise.guide.step2':
        'Wenn du ein Video aufnehmen mÃƒÆ’Ã‚Â¶chtest, tippe auf den AufnahmeÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœButton.',
    'exercise.guide.step3':
        'Um die Aufnahme zu stoppen und zu speichern, tippe zweimal auf den Bildschirm oder drÃƒÆ’Ã‚Â¼cke den ZurÃƒÆ’Ã‚Â¼ckÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœButton.',
    'exercise.guide.step4':
        'Wenn du fertig bist, tippe auf den CompleteÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœButton und danach auf Save, um das Training zu speichern.',
    'exercise.error.setup_title': 'SetupÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœFehler',
    'exercise.error.setup_message': 'Initialisierung fehlgeschlagen: {error}',
    'exercise.error.pose_title': 'HaltungsÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœErkennungsfehler',
    'exercise.error.pose_message':
        'HaltungsÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœErkennung konnte nicht gestartet werden. Bitte Google Play Services aktualisieren.',
    'exercise.premium.landmarks': 'LandmarkÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœOverlay ist ein PremiumÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœFeature.',
    'exercise.premium.recording':
        'Videoaufnahme ist in der PremiumÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœVersion verfÃƒÆ’Ã‚Â¼gbar. Upgrade zum Freischalten.',
    'exercise.recording.failed_start':
        'Bildschirmaufnahme fehlgeschlagen: {error}',
    'exercise.recording.permission_denied':
        'Berechtigung fÃƒÆ’Ã‚Â¼r Bildschirm/AudioÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœAufnahme verweigert',
    'exercise.recording.failed_save':
        'Bildschirmaufnahme konnte nicht gespeichert werden',
    'exercise.recording.saved_gallery': 'In Galerie gespeichert ({album})',
    'exercise.recording.saved_app': 'Im AppÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœSpeicher gespeichert: {path}',
    'exercise.recording.saved_phone': 'Video im Telefonspeicher gespeichert',
    'exercise.recording.failed_video': 'Videoaufnahme fehlgeschlagen: {error}',
    'exercise.recording.preparing_luxury_video':
        'Wir bereiten gerade dein hochwertiges Workout-Video vor.',
    'exercise.recording.keep_screen_open':
        'Bitte lass diesen Bildschirm einen Moment geÃƒÆ’Ã‚Â¶ffnet.',
    'exercise.premium.title': 'PremiumÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœFeature',
    'exercise.premium.not_now': 'Nicht jetzt',
    'exercise.premium.upgrade': 'Upgrade',
    'exercise.premium.required_title': 'Premium erforderlich',
    'exercise.premium.required_message':
        'WorkoutÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœSpeichern, ZÃƒÆ’Ã‚Â¤hlen und Fortschritt sind nur in Premium verfÃƒÆ’Ã‚Â¼gbar.',
    'exercise.camera.error_title': 'KameraÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœFehler',
    'exercise.camera.error_message':
        'Kamera konnte nicht initialisiert werden. Berechtigungen prÃƒÆ’Ã‚Â¼fen und erneut versuchen.',
    'exercise.counting_premium': 'ZÃƒÆ’Ã‚Â¤hlen (Premium)',
    'exercise.summary.title': 'Workout abgeschlossen!',
    'exercise.summary.total_reps': 'Gesamtwiederholungen',
    'exercise.summary.avg_accuracy': 'Durchschnittliche Genauigkeit',
    'exercise.summary.duration': 'Dauer',
    'exercise.summary.seconds': '{value} Sekunden',
    'exercise.summary.best_accuracy': 'Beste Wiederholungsgenauigkeit',
    'exercise.summary.close': 'SchlieÃƒÆ’Ã…Â¸en',
    'exercise.summary.view_details': 'Speichern',
    'exercise.card.type.dynamic': 'Dynamisch',
    'exercise.card.type.static': 'Statisch',
    'exercise.card.view.front': 'Frontansicht',
    'exercise.card.view.side': 'Seitenansicht',
    'exercise.card.total_reps': 'Gesamtwiederholungen',
    'exercise.card.avg_accuracy': 'ÃƒÆ’Ã‹Å“ Genauigkeit',
    'exercise.card.select': 'ÃƒÆ’Ã…â€œbung auswÃƒÆ’Ã‚Â¤hlen',
    'exercise.time.today': 'Heute',
    'exercise.time.yesterday': 'Gestern',
    'exercise.time.days_ago': 'vor {value} Tagen',
    'exercise.time.weeks_ago': 'vor {value} Wochen',
    'exercise.time.months_ago': 'vor {value} Monaten',
    'guide.squat.subtitle':
        'Brust hoch, HÃƒÆ’Ã‚Â¼fte nach hinten, Knie ÃƒÆ’Ã‚Â¼ber den Zehen.',
    'guide.squat.step1': 'Schulterbreit stehen und Rumpf anspannen.',
    'guide.squat.step2':
        'Absenken, bis die Oberschenkel fast parallel sind, Fersen bleiben am Boden.',
    'guide.squat.step3':
        'ÃƒÆ’Ã…â€œber die Fersen hochdrÃƒÆ’Ã‚Â¼cken, Knie nicht durchstrecken.',
    'guide.pushup.subtitle':
        'Von Kopf bis Ferse eine Linie halten und jede Wiederholung kontrollieren.',
    'guide.pushup.step1':
        'In hoher Planke starten, HÃƒÆ’Ã‚Â¤nde etwas weiter als schulterbreit.',
    'guide.pushup.step2': 'Brust absenken, Ellbogen ca. 45 Grad beugen.',
    'guide.pushup.step3': 'HochdrÃƒÆ’Ã‚Â¼cken, Rumpf fest und HÃƒÆ’Ã‚Â¼fte stabil.',
    'guide.situp.subtitle':
        'Rumpf kontrolliert bewegen, nicht am Nacken ziehen.',
    'guide.situp.step1': 'Auf den RÃƒÆ’Ã‚Â¼cken legen, Knie beugen, FÃƒÆ’Ã‚Â¼ÃƒÆ’Ã…Â¸e aufstellen.',
    'guide.situp.step2': 'OberkÃƒÆ’Ã‚Â¶rper durch Anspannen der Bauchmuskeln anheben.',
    'guide.situp.step3': 'Langsam kontrolliert absenken.',
    'guide.bicep.subtitle': 'Ellbogen nah am KÃƒÆ’Ã‚Â¶rper, kein Schwung.',
    'guide.bicep.step1':
        'Aufrecht stehen, Hanteln halten, HandflÃƒÆ’Ã‚Â¤chen nach vorn.',
    'guide.bicep.step2':
        'Gewichte durch Beugen der Ellbogen heben, Schultern bleiben ruhig.',
    'guide.bicep.step3':
        'Gewichte langsam absenken bis zur vollstÃƒÆ’Ã‚Â¤ndigen Streckung.',
    'guide.shoulder.subtitle': 'Vertikal drÃƒÆ’Ã‚Â¼cken, Rippen unten, Rumpf aktiv.',
    'guide.shoulder.step1': 'Gewichte auf SchulterhÃƒÆ’Ã‚Â¶he, Handgelenke neutral.',
    'guide.shoulder.step2': 'ÃƒÆ’Ã…â€œber Kopf drÃƒÆ’Ã‚Â¼cken bis die Arme gestreckt sind.',
    'guide.shoulder.step3': 'Kontrolliert zurÃƒÆ’Ã‚Â¼ck auf SchulterhÃƒÆ’Ã‚Â¶he absenken.',
    'guide.leg.subtitle':
        'Kontrollierter Bewegungsbereich, Knie nicht durchschnappen.',
    'guide.leg.step1': 'Sitzen mit RÃƒÆ’Ã‚Â¼ckenstÃƒÆ’Ã‚Â¼tze, Beine unter dem Polster.',
    'guide.leg.step2': 'Knie strecken, Polster anheben, HÃƒÆ’Ã‚Â¼fte stabil.',
    'guide.leg.step3': 'Langsam absenken bis die Knie gebeugt sind.',
    'settings.title': 'Einstellungen',
    'settings.premium_features': 'PremiumÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœFunktionen',
    'settings.app_settings': 'AppÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœEinstellungen',
    'settings.profile_name': 'Profilname',
    'settings.appearance': 'Darstellung',
    'settings.data': 'Daten',
    'settings.about': 'ÃƒÆ’Ã…â€œber',
    'settings.premium_account': 'PremiumÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœKonto',
    'settings.unlock_all_features': 'Alle PremiumÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœFunktionen freischalten',
    'settings.voice_counting': 'SprachzÃƒÆ’Ã‚Â¤hlung',
    'settings.speak_count': 'ZÃƒÆ’Ã‚Â¤hlung wÃƒÆ’Ã‚Â¤hrend der Wiederholungen ansagen',
    'settings.voice_counting_language': 'Sprache der SprachzÃƒÆ’Ã‚Â¤hlung',
    'settings.upgrade_to_premium': 'Auf Premium upgraden',
    'settings.upgrade_subtitle': 'Voice Count, Videoaufnahme und mehr',
    'settings.voice_coach': 'Voice Coach',
    'settings.voice_feedback': 'EchtzeitÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœSprachfeedback',
    'settings.show_landmarks': 'Landmarks anzeigen',
    'settings.display_skeleton': 'SkelettÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœOverlay anzeigen',
    'settings.auto_recording': 'AutoÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœAufnahme',
    'settings.auto_recording_subtitle': 'Workouts automatisch aufnehmen',
    'settings.theme': 'Design',
    'settings.language': 'Sprache',
    'settings.language_subtitle': 'AppÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœSprache ÃƒÆ’Ã‚Â¤ndern',
    'settings.clear_data': 'Daten lÃƒÆ’Ã‚Â¶schen',
    'settings.clear_data_subtitle': 'Gesamten Trainingsverlauf lÃƒÆ’Ã‚Â¶schen',
    'settings.version': 'Version',
    'settings.privacy_policy': 'Datenschutzrichtlinie',
    'settings.terms': 'Nutzungsbedingungen',
    'settings.disclaimer': 'Haftungsausschluss',
    'legal.last_updated': 'Zuletzt aktualisiert: {date}',
    'legal.privacy.content':
        '1) Welche Daten wir verarbeiten\n'
        'H&F speichert Trainingsprotokolle, Abzeichenfortschritt, App-Einstellungen und optional Pfade zu Aufzeichnungsdateien auf Ihrem GerÃƒÆ’Ã‚Â¤t.\n\n'
        '2) Premium-Aktivierung\n'
        'Die Premium-Aktivierung benÃƒÆ’Ã‚Â¶tigt mindestens einmal eine Internetverbindung. WÃƒÆ’Ã‚Â¤hrend der Aktivierung werden LizenzschlÃƒÆ’Ã‚Â¼ssel, GerÃƒÆ’Ã‚Â¤te-Hash, App-Version und Plattform an unseren Lizenzserver gesendet. Nach der Aktivierung wird der Premium-Status lokal validiert und die App kann offline genutzt werden.\n\n'
        '3) Kamera, Mikrofon, Speicher und Rechenleistung\n'
        'Die Kamera wird fÃƒÆ’Ã‚Â¼r die Pose-Erkennung verwendet. Zur Analyse der Pose nutzt die App die Rechenleistung Ihres GerÃƒÆ’Ã‚Â¤ts. Mikrofon- und Bildschirmaufnahme-Berechtigungen werden nur benÃƒÆ’Ã‚Â¶tigt, wenn Sie Aufnahmefunktionen nutzen. Gespeicherte Videos bleiben auf Ihrem GerÃƒÆ’Ã‚Â¤t oder in Ihrer Galerie erhalten.\n\n'
        '4) Wie wir Daten verwenden\n'
        'Daten dienen zum ZÃƒÆ’Ã‚Â¤hlen der Wiederholungen, Berechnen der Genauigkeit, Verfolgen des Fortschritts, Freischalten von Abzeichen und Bereitstellen von Premium-Funktionen.\n\n'
        '5) Weitergabe\n'
        'Wir verkaufen Ihre personenbezogenen Daten nicht. LizenzprÃƒÆ’Ã‚Â¼fdaten werden ausschlieÃƒÆ’Ã…Â¸lich zur Aktivierung und Sicherung des Premium-Zugangs verarbeitet.\n\n'
        '6) Ihre Kontrolle\n'
        'Sie kÃƒÆ’Ã‚Â¶nnen alle Daten lÃƒÆ’Ã‚Â¶schen oder die App jederzeit deinstallieren. Das LÃƒÆ’Ã‚Â¶schen entfernt lokale Verlaufsdaten und gespeicherten Premium-Status.\n\n'
        '7) Sicherheit\n'
        'Die App nutzt IntegritÃƒÆ’Ã‚Â¤tsprÃƒÆ’Ã‚Â¼fungen und sichere lokale Speicherung, um Manipulationen zu erschweren, doch kein System ist vollkommen sicher.',
    'legal.terms.content':
        'Durch die Nutzung von H&F stimmen Sie diesen Bedingungen zu.\n\n'
        '1) Nutzung des Dienstes\n'
        'H&F ist eine Fitness-Support-App. Sie sind selbst fÃƒÆ’Ã‚Â¼r Ihre Sicherheit und Gesundheitsentscheidungen verantwortlich.\n\n'
        '2) Konto und Lizenz\n'
        'Premium erfordert einen gÃƒÆ’Ã‚Â¼ltigen LizenzschlÃƒÆ’Ã‚Â¼ssel. Lizenzen kÃƒÆ’Ã‚Â¶nnen gerÃƒÆ’Ã‚Â¤tebezogen beschrÃƒÆ’Ã‚Â¤nkt und bei Missbrauch, Widerruf oder SicherheitsverstÃƒÆ’Ã‚Â¶ÃƒÆ’Ã…Â¸en gesperrt werden.\n\n'
        '3) Offline-Modus\n'
        'Nach erfolgreicher Aktivierung kÃƒÆ’Ã‚Â¶nnen Basis- und Premium-Funktionen auf demselben GerÃƒÆ’Ã‚Â¤t offline genutzt werden. Eine Neuinstallation, das LÃƒÆ’Ã‚Â¶schen sensibler Daten oder IntegritÃƒÆ’Ã‚Â¤tsfehler kÃƒÆ’Ã‚Â¶nnen eine erneute Online-Aktivierung erfordern.\n\n'
        '4) EinschrÃƒÆ’Ã‚Â¤nkungen\n'
        'Manipulation der Sicherheit, Reverse Engineering der Lizenz oder die Nutzung der App fÃƒÆ’Ã‚Â¼r rechtswidrige AktivitÃƒÆ’Ã‚Â¤ten sind untersagt.\n\n'
        '5) Geistiges Eigentum\n'
        'Software, Markenauftritt und Inhalte der App bleiben Eigentum von H&F und seinen Lizenzgebern.\n\n'
        '6) Keine GewÃƒÆ’Ã‚Â¤hrleistung\n'
        'Die App wird ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾wie besehenÃƒÂ¢Ã¢â€šÂ¬Ã…â€œ bereitgestellt, ohne Garantie fÃƒÆ’Ã‚Â¼r durchgehenden Betrieb oder bestimmte Fitness-Ergebnisse. Der ZÃƒÆ’Ã‚Â¤hler meiner App kann aus verschiedenen GrÃƒÆ’Ã‚Â¼nden zu viel oder zu wenig gezÃƒÆ’Ã‚Â¤hlt haben.\n\n'
        '7) HaftungsbeschrÃƒÆ’Ã‚Â¤nkung\n'
        'H&F haftet nicht fÃƒÆ’Ã‚Â¼r mittelbare, zufÃƒÆ’Ã‚Â¤llige oder FolgeschÃƒÆ’Ã‚Â¤den durch die Nutzung der App.',
    'legal.disclaimer.content':
        'H&F ist kein medizinischer Dienst und bietet keine medizinische Beratung, Diagnose oder Behandlung.\n\n'
        '1) Trainingsrisiko\n'
        'Sport birgt Verletzungsrisiken. Beenden Sie das Training sofort bei Schmerzen, Schwindel, Atemproblemen oder Unwohlsein und konsultieren Sie eine fachkundige Person.\n\n'
        '2) KI-ZÃƒÆ’Ã‚Â¤hlung und Formfeedback\n'
        'Posenerkennung und WiederholungszÃƒÆ’Ã‚Â¤hlung sind SchÃƒÆ’Ã‚Â¤tzungen und kÃƒÆ’Ã‚Â¶nnen durch Kamerawinkel, LichtverhÃƒÆ’Ã‚Â¤ltnisse, Sichtbehinderung, Kleidung oder Bewegungsgeschwindigkeit falsch sein.\n\n'
        '3) Leistung beim Aufzeichnen\n'
        'Die ZÃƒÆ’Ã‚Â¤hlung/SprachzÃƒÆ’Ã‚Â¤hlung ist dafÃƒÆ’Ã‚Â¼r ausgelegt, wÃƒÆ’Ã‚Â¤hrend normaler Workouts mit eingeschaltetem Telefon zuverlÃƒÆ’Ã‚Â¤ssig zu funktionieren. Posenerkennung (ZÃƒÆ’Ã‚Â¤hlung) und Videoaufzeichnung kÃƒÆ’Ã‚Â¶nnen gleichzeitig laufen .\n\n'
        '4) NotfÃƒÆ’Ã‚Â¤lle\n'
        'Verlassen Sie sich in NotfÃƒÆ’Ã‚Â¤llen nicht auf diese App. Kontaktieren Sie stattdessen umgehend lokale Notdienste.\n\n'
        '5) Verantwortung des Nutzers\n'
        'Sie sind fÃƒÆ’Ã‚Â¼r einen sicheren Trainingsbereich, eine korrekte Technik und das Einholen erforderlicher medizinischer Freigaben verantwortlich.\n\n'
        '6) Aufzeichnungen und PrivatsphÃƒÆ’Ã‚Â¤re Dritter\n'
        'Wenn Sie Workouts aufnehmen, holen Sie die Einwilligung aller Personen ein, die im Video oder Audio erscheinen kÃƒÆ’Ã‚Â¶nnten.\n\n'
        '7) Ergebnisse\n'
        'Fitness-Ergebnisse variieren individuell. H&F garantiert keine bestimmten Leistungen oder gesundheitlichen Resultate.',
    'settings.select_theme': 'Design auswÃƒÆ’Ã‚Â¤hlen',
    'settings.select_language': 'Sprache auswÃƒÆ’Ã‚Â¤hlen',
    'onboarding.language_title': 'Sprache auswÃƒÆ’Ã‚Â¤hlen',
    'onboarding.language_subtitle':
        'Du kannst das spÃƒÆ’Ã‚Â¤ter in den Einstellungen ÃƒÆ’Ã‚Â¤ndern.',
    'onboarding.name_title': 'Wie heiÃƒÆ’Ã…Â¸t du?',
    'onboarding.name_subtitle': 'Dieser Name erscheint in deinem Profil.',
    'onboarding.name_hint': 'Name eingeben',
    'onboarding.name_required': 'Bitte deinen Namen eingeben',
    'onboarding.disclaimer_title': 'Haftungsausschluss',
    'onboarding.terms_title': 'Nutzungsbedingungen',
    'onboarding.accept_notice':
        'Stimme zu, um die App weiter zu nutzen.',
    'onboarding.accept_checkbox': 'Ich stimme zu',
    'onboarding.continue': 'Weiter',
    'onboarding.start_app': 'App starten',
    'settings.clear_all_data': 'Alle Daten lÃƒÆ’Ã‚Â¶schen',
    'settings.clear_all_data_desc':
        'Dadurch werden Trainingsverlauf, Erfolge und Einstellungen gelÃƒÆ’Ã‚Â¶scht. Diese Aktion kann nicht rÃƒÆ’Ã‚Â¼ckgÃƒÆ’Ã‚Â¤ngig gemacht werden.',
    'settings.clear_success': 'Alle Benutzerdaten wurden erfolgreich gelÃƒÆ’Ã‚Â¶scht.',
    'settings.clear_failed': 'Daten lÃƒÆ’Ã‚Â¶schen fehlgeschlagen: {error}',
    'theme.light': 'Hell',
    'theme.dark': 'Dunkel',
    'theme.gold': 'Gold',
    'theme.pink': 'Rosa',
    'progress.title': 'Fortschritt & Analyse',
    'progress.overview': 'ÃƒÆ’Ã…â€œbersicht',
    'progress.exercises': 'ÃƒÆ’Ã…â€œbungen',
    'progress.badges': 'Badges',
    'progress.no_data': 'Keine Daten verfÃƒÆ’Ã‚Â¼gbar',
    'progress.weekly_summary': 'WÃƒÆ’Ã‚Â¶chentliche Zusammenfassung',
    'progress.streak_days': '{count} Tage am StÃƒÆ’Ã‚Â¼ck',
    'progress.recent_workouts': 'Letzte Workouts',
    'progress.no_workouts': 'Noch keine Workouts',
    'progress.workout_summary':
        '{reps} Wiederholungen ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â¢ {accuracy}% Genauigkeit',
    'progress.achievements': 'Erfolge',
    'progress.badges_unlocked': '{unlocked}/{total} Badges freigeschaltet',
    'progress.view_all_achievements': 'Alle Erfolge ansehen',
    'progress.day.sun': 'So',
    'progress.day.mon': 'Mo',
    'progress.day.tue': 'Di',
    'progress.day.wed': 'Mi',
    'progress.day.thu': 'Do',
    'progress.day.fri': 'Fr',
    'progress.day.sat': 'Sa',
    'progress.time.just_now': 'Gerade eben',
    'progress.time.minutes_ago': 'vor {value} Min',
    'progress.time.hours_ago': 'vor {value} Std',
    'progress.time.days_ago': 'vor {value} Tg',
    'progress.time.weeks_ago': 'vor {value} Wo',
    'progress.analytics_intro_title': 'ÃƒÆ’Ã…â€œbungsanalyse verstehen',
    'progress.analytics_intro_line1':
        'Gesamtwiederholungen = alle gespeicherten Wiederholungen dieser ÃƒÆ’Ã…â€œbung ÃƒÆ’Ã‚Â¼ber alle Sessions.',
    'progress.analytics_intro_line2':
        'ÃƒÆ’Ã‹Å“ Genauigkeit = durchschnittliche Formgenauigkeit aller gespeicherten Sessions.',
    'progress.analytics_intro_line3':
        'TrendÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœChart = Genauigkeit ÃƒÆ’Ã‚Â¼ber die Zeit (hÃƒÆ’Ã‚Â¶here Linie = bessere Form).',
    'progress.analytics_intro_line4':
        'Analysen aktualisieren sich erst nach dem Speichern einer Session.',
    'progress.read_exercise_analytics_title': 'So liest du Trainingsanalysen',
    'progress.read_exercise_analytics_line1':
        'Neueste Genauigkeit = dein aktuellster Form-Score.',
    'progress.read_exercise_analytics_line2':
        'Beste Genauigkeit = dein bisher hÃƒÆ’Ã‚Â¶chster Score.',
    'progress.read_exercise_analytics_line3':
        'Die Sitzungsbalken zeigen die letzten 6 Sessions. Ein hÃƒÆ’Ã‚Â¶herer Balken bedeutet bessere Genauigkeit.',
    'progress.read_exercise_analytics_line4':
        'Die Zahl unter jedem Balken sind die Wiederholungen dieser Session.',
    'progress.latest_accuracy': 'Neueste Genauigkeit',
    'progress.best_accuracy': 'Beste Genauigkeit',
    'progress.trend_vs_previous_session':
        '{sign}{delta}% gegenÃƒÆ’Ã‚Â¼ber der vorherigen Session',
    'progress.last_sessions_accuracy_title': 'Letzte Sessions (Genauigkeit %)',
    'progress.reps_short': 'Wdh',
    'progress.chart_accuracy_trend_legend':
        'HÃƒÆ’Ã‚Â¶here Balken bedeuten bessere Genauigkeit. Die Beschriftung unten zeigt Wiederholungen je Session.',
    'progress.total_reps_all_time': 'Gesamtwiederholungen (gesamt)',
    'progress.avg_accuracy_all_sessions': 'ÃƒÆ’Ã‹Å“ Genauigkeit (alle Sessions)',
    'progress.sessions': 'Sessions',
    'progress.chart_accuracy_trend':
        'Diagramm zeigt den Genauigkeitstrend nach SessionÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœDatum.',
    'progress.no_sessions':
        'Noch keine Sessions. Speichere ein Workout, um Analysen zu sehen.',
    'badges.empty':
        'Noch keine Badges.\nStarte Workouts, um den ersten Meilenstein freizuschalten.',
    'badges.collection': 'Deine BadgeÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœSammlung',
    'badges.current_status': 'Aktueller BadgeÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœStatus',
    'badges.unlocked_count': '{unlocked}/{total} Badges freigeschaltet',
    'badges.tier': 'Stufe: {tier}',
    'badges.next_target':
        'NÃƒÆ’Ã‚Â¤chstes Ziel: {name} ({progress}/{requirement}) ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“ {percent}% abgeschlossen',
    'badges.how_it_works': 'So funktioniert das BadgeÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœSystem',
    'badges.guide_1':
        'Badges folgen dem Rhythmus 5 Tage aktiv, 2 Tage Pause. Nur aktive Tage zÃƒÆ’Ã‚Â¤hlen.',
    'badges.guide_2':
        'Workouts an Ruhetagen werden gespeichert, ÃƒÆ’Ã‚Â¤ndern aber den BadgeÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœFortschritt nicht.',
    'badges.guide_3':
        'Tagesziele sind gedeckelt: zusÃƒÆ’Ã‚Â¤tzliche Wiederholungen/Sets bringen keinen ExtraÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœFortschritt.',
    'badges.guide_4':
        'Keine Hanteln oder GerÃƒÆ’Ã‚Â¤te nÃƒÆ’Ã‚Â¶tig: Badges sind auch mit Alternativen mÃƒÆ’Ã‚Â¶glich (z. B. push-ups fÃƒÆ’Ã‚Â¼r Upper, squats fÃƒÆ’Ã‚Â¼r Lower).',
    'badges.guide_5':
        'Fortschritt wird aus gespeicherten Logs berechnet; reale Daten steuern die Freischaltungen.',
    'badges.unlocked_on': 'Freigeschaltet am {date}',
    'badges.tap_full_plan': 'Tippen, um den kompletten Plan zu sehen',
    'badges.new_unlock_today': 'Heute freigeschaltet! Gute Arbeit.',
    'badges.unlocked_banner':
        'Freigeschaltet! GroÃƒÆ’Ã…Â¸artige Konstanz. Bleib dran.',
    'badges.poster_saved_note':
        'Das Badge-Poster wurde automatisch im Galerie-Album {album} gespeichert.',
    'badges.poster_save_failed_note':
        'Badge-Poster konnte nicht in der Galerie gespeichert werden. Bitte Foto-Berechtigung prÃƒÆ’Ã‚Â¼fen.',
    'badges.no_tier': 'Noch keine Stufe freigeschaltet',
    'badges.motivation_unlocked':
        'Gut gemacht. Dieses Badge ist sicher; jetzt zur nÃƒÆ’Ã‚Â¤chsten Stufe.',
    'badges.motivation_almost':
        'Fast geschafft. Nur noch {remaining} qualifizierte Tage bis zur Freischaltung.',
    'badges.motivation_keep':
        'Bleib konstant. Jeder qualifizierte Tag bringt dieses Badge voran.',
    'tier.bronze': 'Bronze',
    'tier.silver': 'Silber',
    'tier.gold': 'Gold',
    'tier.platinum': 'Platin',
    'badge.first_workout.name': 'Erste Schritte',
    'badge.first_workout.narrative':
        'SchlieÃƒÆ’Ã…Â¸e deinen ersten qualifizierten WorkoutÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœTag ab.',
    'badge.first_workout.detail1':
        'Ziel: 1 qualifizierter Tag aus gespeicherten WorkoutÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœLogs.',
    'badge.first_workout.detail2':
        'UpperÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœZiel: 8 Wiederholungen gesamt (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise).',
    'badge.first_workout.detail3':
        'CoreÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœZiel: 10 Wiederholungen gesamt (Sit-up).',
    'badge.first_workout.detail4':
        'LowerÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœZiel: 12 Wiederholungen gesamt (Squat / Leg Extension).',
    'badge.prep.name': '15ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœTageÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœVorbereitung',
    'badge.prep.narrative': 'Baue Konstanz mit einem 15ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœTageÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœRhythmus auf.',
    'badge.prep.detail1':
        '15ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœTageÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœVorbereitung mit 5 aktiv + 2 RuheÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœZyklus (Tag 6-7 und Tag 13-14 sind Ruhetage).',
    'badge.prep.detail2':
        'Tage 1-3: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': 'Tage 4-5: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': 'Tage 8-12: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': 'Tag 15: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = gespeicherte Sessions pro Kategorie am Tag; Ruhetage zÃƒÆ’Ã‚Â¤hlen nicht.',
    'badge.prep.detail8':
        'Wenn du einen erforderlichen aktiven Tag verpasst, wird der Prep-Fortschritt zurÃƒÆ’Ã‚Â¼ckgesetzt und der Lauf beginnt am nÃƒÆ’Ã‚Â¤chsten Trainingstag wieder bei Tag 1.',
    'badge.bronze.name': 'Monat 1 Bronze',
    'badge.bronze.narrative': 'Grundlagenmonat fÃƒÆ’Ã‚Â¼r Programmkonsistenz.',
    'badge.bronze.detail1':
        '30 qualifizierte aktive Tage mit 5 aktiv + 2 RuheÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœZyklus.',
    'badge.bronze.detail2':
        'Upper tÃƒÆ’Ã‚Â¤glich: 18 reps + 3 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise kombiniert).',
    'badge.bronze.detail3': 'Core tÃƒÆ’Ã‚Â¤glich: 24 reps + 3 sets (Sit-up).',
    'badge.bronze.detail4':
        'Lower tÃƒÆ’Ã‚Â¤glich: 30 reps + 3 sets (Squat / Leg Extension kombiniert).',
    'badge.bronze.detail5':
        'ZusÃƒÆ’Ã‚Â¤tzliche reps/sets ÃƒÆ’Ã‚Â¼ber dem Tageslimit zÃƒÆ’Ã‚Â¤hlen nicht.',
    'badge.bronze.detail6':
        'Auch wenn du einen Tag verpasst, musst du nicht wieder bei Tag 1 anfangen.',
    'badge.silver.name': 'Monat 2 Silber',
    'badge.silver.narrative': 'Progressionsmonat mit hÃƒÆ’Ã‚Â¶herem Umfang.',
    'badge.silver.detail1':
        '30 qualifizierte aktive Tage mit 5 aktiv + 2 RuheÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœZyklus.',
    'badge.silver.detail2':
        'Upper tÃƒÆ’Ã‚Â¤glich: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise kombiniert).',
    'badge.silver.detail3': 'Core tÃƒÆ’Ã‚Â¤glich: 32 reps + 4 sets (Sit-up).',
    'badge.silver.detail4':
        'Lower tÃƒÆ’Ã‚Â¤glich: 40 reps + 4 sets (Squat / Leg Extension kombiniert).',
    'badge.silver.detail5':
        'Nur aktive Tage zÃƒÆ’Ã‚Â¤hlen; Ruhetage werden ignoriert.',
    'badge.silver.detail6':
        'Auch wenn du einen Tag verpasst, musst du nicht wieder bei Tag 1 anfangen.',
    'badge.gold.name': 'Monat 3 Gold',
    'badge.gold.narrative': 'Meisterschaftsmonat mit hohen Ausdauerzielen.',
    'badge.gold.detail1':
        '30 qualifizierte aktive Tage mit 5 aktiv + 2 RuheÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœZyklus.',
    'badge.gold.detail2':
        'Upper tÃƒÆ’Ã‚Â¤glich: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Lateral Raise / Front Raise kombiniert).',
    'badge.gold.detail3': 'Core tÃƒÆ’Ã‚Â¤glich: 40 reps + 4 sets (Sit-up).',
    'badge.gold.detail4':
        'Lower tÃƒÆ’Ã‚Â¤glich: 50 reps + 4 sets (Squat / Leg Extension kombiniert).',
    'badge.gold.detail5':
        'Fortschritt basiert auf Logs; extra reps zÃƒÆ’Ã‚Â¤hlen nicht.',
    'badge.gold.detail6':
        'Auch wenn du einen Tag verpasst, musst du nicht wieder bei Tag 1 anfangen.',
    'badge.default.goal': 'Ziel: {description}',
    'badge.default.requirement':
        'Anforderung: {requirement} qualifizierte Tage.',
    'badge.default.status': 'Aktueller Stand: {progress}/{requirement}.',
    'badge.poster.badge_label': 'Abzeichen',
    'badge.poster.user_label': 'Erreicht von',
    'badge.poster.requirements_label': 'Qualifizierte Daten',
    'leaderboard.title': 'Leaderboard',
    'leaderboard.achievements': 'Erfolge',
    'leaderboard.global': 'Global',
    'leaderboard.achievement_progress': 'Erfolgsfortschritt',
    'leaderboard.personal_bests': 'PersÃƒÆ’Ã‚Â¶nliche Bestleistungen',
    'leaderboard.most_reps': 'Meiste Wiederholungen',
    'leaderboard.best_accuracy': 'Beste Genauigkeit',
    'leaderboard.longest_streak': 'LÃƒÆ’Ã‚Â¤ngste Serie',
    'leaderboard.days': 'Tage',
    'leaderboard.global_simulated': 'Globales Leaderboard (Simuliert)',
    'leaderboard.points': '{score} Pkt',
    'recordings.tab.recordings': 'Aufnehmen',
    'recordings.tab.profile': 'Profil',
    'recordings.failed_load': 'Aufnahmen konnten nicht geladen werden',
    'recordings.empty': 'Noch keine aufgenommenen Videos',
    'recordings.file_not_found': 'Videodatei nicht gefunden',
    'recordings.file_incomplete':
        'Aufnahmedatei ist unvollstÃƒÆ’Ã‚Â¤ndig. Bitte erneut aufnehmen.',
    'profile.guest_name': 'Benutzer',
    'profile.user_name_label': 'Benutzername',
    'profile.edit_name': 'Bearbeiten',
    'profile.name_hint': 'Name eingeben',
    'profile.save_name': 'Speichern',
    'profile.photo_title': 'Profilfoto',
    'profile.photo_subtitle':
        'FÃƒÆ’Ã‚Â¼ge ein GanzkÃƒÆ’Ã‚Â¶rperfoto hinzu, um dein Profil zu personalisieren.',
    'profile.photo_add': 'Foto hinzufÃƒÆ’Ã‚Â¼gen',
    'profile.photo_change': 'Foto ÃƒÆ’Ã‚Â¤ndern',
    'profile.photo_remove': 'Foto entfernen',
    'profile.photo_remove_confirm': 'Profilfoto entfernen?',
    'profile.photo_too_large':
        'Das Foto ist zu groÃƒÆ’Ã…Â¸. Bitte wÃƒÆ’Ã‚Â¤hle ein kleineres Bild.',
    'profile.photo_error':
        'Foto konnte nicht gespeichert werden. Bitte anderes Bild versuchen.',
    'profile.photo_badge_notice':
        'Wenn kein Profilfoto hinzugefÃƒÆ’Ã‚Â¼gt wurde, enthalten Badge-Poster kein Foto von dir.',
    'profile.exercise_totals_title': 'Gesamte Trainingszahlen',
    'profile.exercise_totals_subtitle': 'Von der ersten bis zur letzten Einheit.',
    'profile.exercise_empty': 'Noch keine Trainingsdaten',
    'profile.badges_title': 'Erhaltene Abzeichen',
    'profile.badges_empty': 'Noch keine Abzeichen',
    'profile.badge_gallery_saved_note':
        'Wenn ein Badge freigeschaltet wird, wird sein Poster automatisch im Galerie-Album {album} gespeichert.',
    'iconic.menu.title': 'Iconic-Programme',
    'iconic.menu.subtitle':
        'WÃƒÆ’Ã‚Â¤hle einen Premium-Post-Process-Look fÃƒÆ’Ã‚Â¼r aufgenommene Videos. Jedes Programm ist darauf ausgelegt, eigenstÃƒÆ’Ã‚Â¤ndig, filmisch und elegant zu wirken, ohne wÃƒÆ’Ã‚Â¤hrend der Live-Aufnahme zusÃƒÆ’Ã‚Â¤tzliche Hitze zu erzeugen.',
    'iconic.program.zodiac.eyebrow': 'Post-Process-Signatur',
    'iconic.program.zodiac.description':
        'Wendet nach der Aufnahme ein luxuriÃƒÆ’Ã‚Â¶ses Sternzeichen-Overlay an. Alle 12 Zeichen nutzen nun eigene Farbpaletten, Symbole, Aura-TÃƒÆ’Ã‚Â¶nungen und Gravurstile, wobei die Vorschau an der Widder-Art-Richtung ausgerichtet ist.',
    'iconic.program.zodiac.tag.sign_themes': '12 Sternzeichen-Themen',
    'iconic.program.zodiac.tag.luxury_capsule': 'Luxus-Kapsel',
    'iconic.program.zodiac.tag.embossed_coin': 'GeprÃƒÆ’Ã‚Â¤gte MÃƒÆ’Ã‚Â¼nze',
    'iconic.program.zodiac.footer':
        'Empfohlen fÃƒÆ’Ã‚Â¼r ikonische Exporte. Die Live-Aufnahme bleibt leichtgewichtig, damit das Telefon nicht ÃƒÆ’Ã‚Â¼berhitzt, und der Luxus-Look wird erst nach der Aufnahme hinzugefÃƒÆ’Ã‚Â¼gt.',
    'iconic.program.festival.eyebrow': 'Kulturelle Feier',
    'iconic.program.festival.description':
        'Wendet ein einzigartiges Luxus-Overlay basierend auf dem nÃƒÆ’Ã‚Â¤chstgelegenen Weltfestival oder Sportereignis an. Jedes Festival hat seine eigene Farbpalette, Ringglut, Verlaufsleiste und Markenoptik.',
    'iconic.program.festival.tag.festivals': '70 Festivals',
    'iconic.program.festival.tag.date_aware': 'DatumsabhÃƒÆ’Ã‚Â¤ngig',
    'iconic.program.festival.tag.luxury_overlay': 'Luxus-Overlay',
    'iconic.program.festival.footer':
        'Das Thema wechselt automatisch zur nÃƒÆ’Ã‚Â¤chstbevorstehenden Feier. Nimm dein Workout auf und der aktive Festival-Look wird wÃƒÆ’Ã‚Â¤hrend der Nachbearbeitung angewendet.',
    'iconic.program.studio.eyebrow': 'Voll anpassbar',
    'iconic.program.studio.description':
        'Nutze dein eigenes Premium-Overlay-System mit bearbeitbarem WiederholungszÃƒÆ’Ã‚Â¤hler, Genauigkeitsleiste, ErzÃƒÆ’Ã‚Â¤hlfluss, Icons, Farbpaletten und Finish-Steuerung.',
    'iconic.program.studio.tag.custom_program': 'Eigenes Programm',
    'iconic.program.studio.tag.luxury_editor': 'Luxus-Editor',
    'iconic.program.studio.tag.premium_control': 'Premium-Steuerung',
    'iconic.program.studio.footer':
        'WÃƒÆ’Ã‚Â¤hle dies, wenn du dein eigenes handgefertigtes Luxus-Overlay statt eines festen Sternzeichen- oder Festival-Looks mÃƒÆ’Ã‚Â¶chtest.',
    'iconic.program.studio.action': 'Studio ÃƒÆ’Ã‚Â¶ffnen',
    'iconic.program.standard.eyebrow': 'Leichtes Standardprofil',
    'iconic.program.standard.description':
        'BehÃƒÆ’Ã‚Â¤lt das aktuelle einfache Overlay bei, wenn du keinen markierten Kino-Look mÃƒÆ’Ã‚Â¶chtest.',
    'iconic.program.standard.tag.default': 'Standard',
    'iconic.program.standard.tag.minimal': 'Minimal',
    'iconic.program.standard.tag.fast_export': 'Schneller Export',
    'iconic.program.standard.footer':
        'Nutze dies, wenn du den bisherigen Exportstil ohne Premium-Art-Direction mÃƒÆ’Ã‚Â¶chtest.',
    'iconic.info.title': 'So funktioniert es',
    'iconic.info.step1': '1. WÃƒÆ’Ã‚Â¤hle hier ein Programm aus.',
    'iconic.info.step2': '2. Nimm dein Workout wie gewohnt auf.',
    'iconic.info.step3':
        '3. Der ausgewÃƒÆ’Ã‚Â¤hlte Stil wird erst nach der Aufnahme wÃƒÆ’Ã‚Â¤hrend der Nachbearbeitung angewendet.',
    'iconic.preview.post_process': 'POST-PROCESS-VORSCHAU',
    'iconic.preview.standard.caption':
        'Das Standard-Export-Overlay\nbehÃƒÆ’Ã‚Â¤lt den aktuellen leichten Look bei.',
    'iconic.preview.editable_luxe': 'EDITIERBARER LUXUS',
    'camera.overlay.skeleton': 'Skelett',
    'camera.overlay.stop': 'Stopp',
    'camera.overlay.record': 'Aufnehmen',
    'camera.overlay.complete': 'AbschlieÃƒÆ’Ã…Â¸en',
    'lang.en': 'Englisch',
    'lang.es': 'Spanisch',
    'lang.ja': 'Japanisch',
    'lang.my': 'Birmanisch',
    'lang.hi': 'Hindi',
    'lang.pt': 'Portugiesisch',
    'lang.zh': 'MandarinÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬ËœChinesisch',
    'lang.de': 'Deutsch',
  };

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': _enValues,
    'es': _esValues,
    'ja': _jaValues,
    'my': _myValues,
    'hi': _hiValues,
    'pt': _ptValues,
    'zh': _zhValues,
    'de': _deValues,
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((item) => item.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

extension AppLocalizationBuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String tr(String key, {Map<String, String> params = const {}}) {
    return l10n.t(key, params: params);
  }
}






