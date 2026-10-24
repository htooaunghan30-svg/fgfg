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
    String text = languageValues[key] ?? _localizedValues['en']![key] ?? key;
    params.forEach((placeholder, value) {
      text = text.replaceAll('{$placeholder}', value);
    });
    return text;
  }

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
        'Accuracy Bar and Counting Note:\nOur AI is designed to recognize exercises that closely follow our visual guides. It provides a smooth counting experience with good accuracy, though it does not provide formal technical coaching. Do not forget that our app does not have 100% accuracy.\n\nFor the side view exercise, stay in the side view position, and for the front view exercise, stay in the front view position. That way, the results will be correct.\n\nTracking may be inaccurate if:\n• Your entire body is not visible in the camera frame.\n• There is more than one person in the camera frame.\n• The room is too dark or has strong lens flares/glare.\n• Place the camera in a position that is not too low or too high from your body.',
    'home.situp_notice':
        'Notice 1. Once you have your camera set up and chosen a spot where you will do the situp exercise, first sit still for 2 seconds and then do the exercise.\n2. After you finish your situp exercise, sit for at least 2 seconds and then go to the camera.',
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
        'Counting/voice counting is designed to work well during normal workouts while the phone is on. Pose detection (counting) and video recording can run together and typically work well for about 5–15 minutes. Longer continuous use may increase device heat and battery drain, and accuracy may drop.\n\n'
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
    'progress.workout_summary': '{reps} reps • {accuracy}% accuracy',
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
        'Upper target: 8 reps total (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise).',
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
        'Upper = Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = saved sessions per category in a day; rest-day workouts do not add progress.',
    'badge.prep.detail8':
        'If you miss a required active day, prep progress resets and the run restarts from Day 1 on your next workout day.',
    'badge.bronze.name': 'Month 1 Bronze',
    'badge.bronze.narrative': 'Foundation month for full-program consistency.',
    'badge.bronze.detail1':
        '30 qualified active days with a 5 active + 2 rest cycle.',
    'badge.bronze.detail2':
        'Upper daily: 18 reps + 3 sets (combined across Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise).',
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
        'Upper daily: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise combined).',
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
        'Upper daily: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise combined).',
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
    'premium.badge': 'PREMIUM',
    'premium.menu_only':
        'Este menú está disponible solo para usuarios Premium.',
    'home.exercises_list': 'Lista de ejercicios',
    'home.exercises_simple_form': 'Formulario simple de ejercicio',
    'home.no_supported_exercises': 'No hay ejercicios compatibles disponibles',
    'home.check_exercise_config': 'Revisa la configuración de ejercicios',
    'home.error_loading_exercise': 'Error al cargar el ejercicio: {error}',
    'home.image_reference_count': '{count} referencia de imagen',
    'home.today_progress_premium': 'Progreso de hoy (Premium)',
    'home.today_progress_locked_desc':
        'Los datos del menú progresivo están disponibles para usuarios Premium.',
    'home.today_progress': 'Progreso de hoy',
    'home.total_reps': 'Repeticiones totales',
    'home.workouts': 'Entrenamientos',
    'home.calories': 'Calorías',
    'home.daily_goal': 'Meta diaria: {current}/{goal}',
    'home.daily_goal_achieved': '¡Meta diaria lograda!',
    'home.progress_premium_title': 'El progreso es Premium',
    'home.progress_premium_message':
        'Las analíticas detalladas de progreso están desbloqueadas en Premium.',
    'home.recordings_premium_title': 'Las grabaciones son Premium',
    'home.recordings_premium_message':
        'El historial de grabación de video está disponible solo en Premium.',
    'home.simple_form': 'Formulario de {name}',
    'home.quick_form_summary': 'Resumen rápido del formulario',
    'home.form_images': 'Imágenes de la forma',
    'home.exercise_list_notice_title': 'Recordatorio rápido',
    'home.exercise_list_notice_message':
        'Revisa cada formulario de ejercicio porque puede haber avisos. Nota: el ejercicio situp tiene un aviso importante.',
    'home.simple_form_notice':
        'Nota sobre la barra de precisión y el conteo:\nNuestra IA está diseñada para reconocer ejercicios que siguen de cerca nuestras guías visuales. Ofrece un conteo fluido con buena precisión, aunque no proporciona asesoría técnica formal. No olvides que nuestra app no tiene 100% de precisión.\n\nPara el ejercicio en vista lateral, mantente en posición lateral, y para el ejercicio en vista frontal, mantente en posición frontal. Así los resultados serán correctos.\n\nEl seguimiento puede ser inexacto si:\n• Tu cuerpo completo no está visible en el encuadre de la cámara.\n• Hay más de una persona en la cámara.\n• La habitación está muy oscura o tiene destellos/reflejos fuertes.\n• Coloca la cámara en una posición que no esté demasiado baja ni demasiado alta respecto a tu cuerpo.',
    'home.situp_notice':
        'Aviso 1. Después de colocar la cámara y elegir el lugar donde harás el situp, siéntate quieto(a) 2 segundos y luego realiza el ejercicio.\n2. Después de terminar el ejercicio situp, siéntate al menos 2 segundos y luego ve a la cámara.',
    'exercise.guide.title': 'Guía rápida',
    'exercise.guide.step1':
        'Si quieres crear un landmark, pulsa el botón de esqueleto.',
    'exercise.guide.step2':
        'Si quieres grabar un video, pulsa el botón de grabar.',
    'exercise.guide.step3':
        'Si quieres detener y guardar la grabación, toca dos veces la pantalla o pulsa el botón de atrás.',
    'exercise.guide.step4':
        'Cuando termines el ejercicio, pulsa el botón de completar y luego pulsa Guardar para guardar el ejercicio.',
    'exercise.error.setup_title': 'Error de configuración',
    'exercise.error.setup_message': 'No se pudo iniciar: {error}',
    'exercise.error.pose_title': 'Error de detección de pose',
    'exercise.error.pose_message':
        'No se pudo iniciar la detección de pose. Asegúrate de que Google Play Services esté actualizado.',
    'exercise.premium.landmarks':
        'La superposición de landmarks es una función Premium.',
    'exercise.premium.recording':
        'La grabación de video está disponible en la versión Premium. Actualiza para desbloquear esta función.',
    'exercise.recording.failed_start': 'No se pudo grabar la pantalla: {error}',
    'exercise.recording.permission_denied':
        'Permiso denegado para grabación de pantalla/audio',
    'exercise.recording.failed_save':
        'No se pudo guardar la grabación de pantalla',
    'exercise.recording.saved_gallery': 'Guardado en la galería ({album})',
    'exercise.recording.saved_app':
        'Guardado en el almacenamiento de la app: {path}',
    'exercise.recording.saved_phone':
        'Video guardado en el almacenamiento del teléfono',
    'exercise.recording.failed_video': 'No se pudo grabar el video: {error}',
    'exercise.recording.preparing_luxury_video':
        'Estamos preparando tu video de entrenamiento de lujo para ti.',
    'exercise.recording.keep_screen_open':
        'Mantén esta pantalla abierta por un momento.',
    'exercise.premium.title': 'Función Premium',
    'exercise.premium.not_now': 'Ahora no',
    'exercise.premium.upgrade': 'Actualizar',
    'exercise.premium.required_title': 'Premium requerido',
    'exercise.premium.required_message':
        'Guardar entrenamiento, conteo y seguimiento de progreso están disponibles solo en Premium.',
    'exercise.camera.error_title': 'Error de cámara',
    'exercise.camera.error_message':
        'No se pudo iniciar la cámara. Revisa permisos e inténtalo de nuevo.',
    'exercise.counting_premium': 'Conteo (Premium)',
    'exercise.summary.title': '¡Entrenamiento completado!',
    'exercise.summary.total_reps': 'Repeticiones totales',
    'exercise.summary.avg_accuracy': 'Precisión promedio',
    'exercise.summary.duration': 'Duración',
    'exercise.summary.seconds': '{value} segundos',
    'exercise.summary.best_accuracy': 'Mejor precisión por repetición',
    'exercise.summary.close': 'Cerrar',
    'exercise.summary.view_details': 'Guardar',
    'exercise.card.type.dynamic': 'Dinámico',
    'exercise.card.type.static': 'Estático',
    'exercise.card.view.front': 'Vista frontal',
    'exercise.card.view.side': 'Vista lateral',
    'exercise.card.total_reps': 'Repeticiones totales',
    'exercise.card.avg_accuracy': 'Precisión prom.',
    'exercise.card.select': 'Seleccionar ejercicio',
    'exercise.time.today': 'Hoy',
    'exercise.time.yesterday': 'Ayer',
    'exercise.time.days_ago': 'hace {value} días',
    'exercise.time.weeks_ago': 'hace {value} semanas',
    'exercise.time.months_ago': 'hace {value} meses',
    'guide.squat.subtitle':
        'Mantén el pecho arriba, caderas atrás y rodillas alineadas con los pies.',
    'guide.squat.step1':
        'Párate con los pies al ancho de los hombros y activa el core.',
    'guide.squat.step2':
        'Baja hasta que los muslos estén casi paralelos manteniendo los talones apoyados.',
    'guide.squat.step3':
        'Empuja con los talones para subir sin bloquear las rodillas.',
    'guide.pushup.subtitle':
        'Mantén una línea recta de la cabeza a los talones y controla cada repetición.',
    'guide.pushup.step1':
        'Comienza en plancha alta con manos un poco más anchas que los hombros.',
    'guide.pushup.step2':
        'Baja el pecho flexionando los codos a unos 45 grados.',
    'guide.pushup.step3':
        'Empuja hacia arriba manteniendo el core firme y las caderas niveladas.',
    'guide.situp.subtitle':
        'Usa un movimiento controlado del core en lugar de tirar del cuello.',
    'guide.situp.step1':
        'Acuéstate boca arriba con rodillas flexionadas y pies apoyados.',
    'guide.situp.step2': 'Eleva el torso contrayendo el abdomen.',
    'guide.situp.step3':
        'Baja lentamente con control antes de la siguiente repetición.',
    'guide.bicep.subtitle':
        'Mantén los codos cerca del cuerpo y evita balancearte.',
    'guide.bicep.step1': 'Párate erguido con mancuernas y palmas al frente.',
    'guide.bicep.step2':
        'Flexiona los codos para subir las pesas sin mover los hombros.',
    'guide.bicep.step3':
        'Baja las pesas lentamente hasta la extensión completa.',
    'guide.shoulder.subtitle':
        'Empuja verticalmente manteniendo las costillas abajo y el core activo.',
    'guide.shoulder.step1':
        'Empieza con las pesas a la altura de los hombros y muñecas neutras.',
    'guide.shoulder.step2':
        'Empuja hacia arriba hasta extender los brazos sobre la cabeza.',
    'guide.shoulder.step3': 'Baja con control hasta la altura de los hombros.',
    'guide.leg.subtitle':
        'Muévete en un rango controlado y evita golpear las rodillas.',
    'guide.leg.step1':
        'Siéntate con la espalda apoyada y las piernas bajo la almohadilla.',
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
    'settings.upgrade_subtitle': 'Obtén conteo de voz, grabación de video y más',
    'settings.voice_coach': 'Coach de voz',
    'settings.voice_feedback': 'Recibe feedback de voz en tiempo real',
    'settings.show_landmarks': 'Mostrar landmarks',
    'settings.display_skeleton': 'Mostrar superposición del esqueleto',
    'settings.auto_recording': 'Grabación automática',
    'settings.auto_recording_subtitle': 'Grabar entrenamientos automáticamente',
    'settings.theme': 'Tema',
    'settings.language': 'Idioma',
    'settings.language_subtitle': 'Cambiar idioma de la app',
    'settings.clear_data': 'Borrar datos',
    'settings.clear_data_subtitle':
        'Eliminar todo el historial de entrenamientos',
    'settings.version': 'Versión',
    'settings.privacy_policy': 'Política de privacidad',
    'settings.terms': 'Términos de servicio',
    'settings.disclaimer': 'Descargo de responsabilidad',
    'legal.last_updated': 'Última actualización: {date}',
    'legal.privacy.content':
        '1) Datos que procesamos\n'
        'H&F almacena registros de entrenamiento, progreso de insignias, preferencias de la app y rutas opcionales de archivos de grabación en tu dispositivo.\n\n'
        '2) Activación Premium\n'
        'La activación Premium necesita internet al menos una vez. Durante la activación, clave de licencia, hash del identificador del dispositivo, versión de la app y plataforma se envían a nuestro servidor de licencias. Después de la activación, la elegibilidad Premium se valida localmente y la app puede usarse sin conexión.\n\n'
        '3) Cámara, micrófono, almacenamiento y potencia de procesamiento\n'
        'La cámara se usa para la detección de postura. Usa la potencia de procesamiento de tu dispositivo para analizar la postura. Los permisos de micrófono y grabación de pantalla se usan solo cuando activas las funciones de grabación. Los videos guardados permanecen en tu dispositivo o galería.\n\n'
        '4) Cómo usamos los datos\n'
        'Los datos se usan para contar repeticiones, calcular precisión, registrar progreso, desbloquear insignias y ofrecer funciones Premium.\n\n'
        '5) Compartir\n'
        'No vendemos tus datos personales. Los datos de verificación de licencia se procesan solo para activar y proteger el acceso Premium.\n\n'
        '6) Tu control\n'
        'Puedes borrar todo o desinstalar la app en cualquier momento. Borrar datos elimina el historial local y el estado Premium almacenado.\n\n'
        '7) Seguridad\n'
        'La app usa verificaciones de integridad y almacenamiento local seguro para reducir riesgos de manipulación, pero ningún sistema es completamente seguro.',
    'legal.terms.content':
        'Al usar H&F aceptas estos Términos.\n\n'
        '1) Uso del servicio\n'
        'H&F es una app de apoyo fitness. Eres responsable de tu seguridad y decisiones de salud.\n\n'
        '2) Cuenta y licencia\n'
        'Premium requiere una clave de licencia válida. Las licencias pueden limitarse por dispositivo y bloquearse por abuso, revocación o violaciones de seguridad.\n\n'
        '3) Modo sin conexión\n'
        'Tras una activación exitosa, las funciones básicas y Premium pueden ejecutarse sin internet en el mismo dispositivo. Reinstalar, borrar datos sensibles o fallas de integridad pueden requerir activación en línea otra vez.\n\n'
        '4) Restricciones\n'
        'No manipules la seguridad, intentes ingeniería inversa de licencias ni uses la app para actividades ilegales.\n\n'
        '5) Propiedad intelectual\n'
        'El software, la marca y el contenido de la app siguen siendo propiedad de H&F y sus licenciantes.\n\n'
        '6) Sin garantía\n'
        'La app se ofrece "tal cual" sin garantías de operación ininterrumpida ni resultados fitness específicos. El contador de mi app puede haber contado de más o de menos por diversos motivos.\n\n'
        '7) Limitación de responsabilidad\n'
        'H&F no es responsable por daños indirectos, incidentales o consecuentes por el uso de la app.',
    'legal.disclaimer.content':
        'H&F no es un servicio médico y no ofrece asesoramiento, diagnóstico ni tratamiento médico.\n\n'
        '1) Riesgo del entrenamiento\n'
        'El ejercicio presenta riesgo de lesiones. Detente de inmediato si sientes dolor, mareo, dificultad para respirar o malestar y consulta a un profesional calificado.\n\n'
        '2) Conteo de IA y retroalimentación de forma\n'
        'La detección de postura y el conteo son estimaciones y pueden fallar por ángulo de cámara, iluminación, oclusión, ropa o velocidad del movimiento.\n\n'
        '3) Rendimiento durante la grabación\n'
        'El conteo/voz está diseñado para funcionar bien durante entrenamientos normales con el teléfono encendido. La detección de postura (conteo) y la grabación de video pueden ejecutarse a la vez y, por lo general, funcionan bien durante unos 5–15 minutos. Un uso continuo más largo puede aumentar el calentamiento del dispositivo y el consumo de batería, y la precisión puede disminuir.\n\n'
        '4) Situaciones de emergencia\n'
        'No confíes en esta app para emergencias. Contacta a los servicios de emergencia locales de inmediato cuando sea necesario.\n\n'
        '5) Responsabilidad del usuario\n'
        'Eres responsable de un espacio de entrenamiento seguro, técnica adecuada y obtener cualquier autorización médica antes de entrenar.\n\n'
        '6) Grabaciones y privacidad de terceros\n'
        'Si grabas entrenamientos, debes obtener el consentimiento de quienes puedan aparecer en video o audio.\n\n'
        '7) Resultados\n'
        'Los resultados fitness varían por persona. H&F no garantiza rendimientos o resultados de salud específicos.',
    'settings.select_theme': 'Seleccionar tema',
    'settings.select_language': 'Seleccionar idioma',
    'onboarding.language_title': 'Elige tu idioma',
    'onboarding.language_subtitle':
        'Puedes cambiarlo más tarde en Ajustes.',
    'onboarding.name_title': '¿Cuál es tu nombre?',
    'onboarding.name_subtitle': 'Esto aparecerá en tu perfil.',
    'onboarding.name_hint': 'Escribe tu nombre',
    'onboarding.name_required': 'Por favor, escribe tu nombre',
    'onboarding.disclaimer_title': 'Aviso',
    'onboarding.terms_title': 'Términos de servicio',
    'onboarding.accept_notice':
        'Acepta para continuar usando la app.',
    'onboarding.accept_checkbox': 'Acepto',
    'onboarding.continue': 'Continuar',
    'onboarding.start_app': 'Iniciar app',
    'settings.clear_all_data': 'Borrar todos los datos',
    'settings.clear_all_data_desc':
        'Esto eliminará todo tu historial de entrenamientos, logros y ajustes. Esta acción no se puede deshacer.',
    'settings.clear_success':
        'Todos los datos del usuario se borraron correctamente.',
    'settings.clear_failed': 'Error al borrar datos: {error}',
    'theme.light': 'Claro',
    'theme.dark': 'Oscuro',
    'theme.gold': 'Dorado',
    'theme.pink': 'Rosa',
    'progress.title': 'Progreso y analíticas',
    'progress.overview': 'Resumen',
    'progress.exercises': 'Ejercicios',
    'progress.badges': 'Insignias',
    'progress.no_data': 'No hay datos disponibles',
    'progress.weekly_summary': 'Resumen semanal',
    'progress.streak_days': 'racha de {count} días',
    'progress.recent_workouts': 'Entrenamientos recientes',
    'progress.no_workouts': 'Aún no hay entrenamientos',
    'progress.workout_summary':
        '{reps} repeticiones • {accuracy}% de precisión',
    'progress.achievements': 'Logros',
    'progress.badges_unlocked': '{unlocked}/{total} insignias desbloqueadas',
    'progress.view_all_achievements': 'Ver todos los logros',
    'progress.day.sun': 'Dom',
    'progress.day.mon': 'Lun',
    'progress.day.tue': 'Mar',
    'progress.day.wed': 'Mié',
    'progress.day.thu': 'Jue',
    'progress.day.fri': 'Vie',
    'progress.day.sat': 'Sáb',
    'progress.time.just_now': 'Ahora mismo',
    'progress.time.minutes_ago': 'hace {value}m',
    'progress.time.hours_ago': 'hace {value}h',
    'progress.time.days_ago': 'hace {value}d',
    'progress.time.weeks_ago': 'hace {value}s',
    'progress.analytics_intro_title':
        'Cómo entender las analíticas de ejercicio',
    'progress.analytics_intro_line1':
        'Repeticiones totales = todas las repeticiones guardadas de este ejercicio en todas las sesiones.',
    'progress.analytics_intro_line2':
        'Precisión prom. = precisión promedio de la forma en todas las sesiones guardadas.',
    'progress.analytics_intro_line3':
        'Gráfico de tendencia = precisión a lo largo del tiempo (una línea más alta significa mejor forma).',
    'progress.analytics_intro_line4':
        'Las analíticas se actualizan solo después de guardar una sesión de entrenamiento.',
    'progress.read_exercise_analytics_title':
        'Cómo leer las analíticas de ejercicio',
    'progress.read_exercise_analytics_line1':
        'Precisión más reciente = tu puntuación de forma más reciente.',
    'progress.read_exercise_analytics_line2':
        'Mejor precisión = tu puntuación más alta hasta ahora.',
    'progress.read_exercise_analytics_line3':
        'Las barras de sesiones muestran las últimas 6 sesiones. Una barra más alta significa mejor precisión.',
    'progress.read_exercise_analytics_line4':
        'El número debajo de cada barra son las repeticiones de esa sesión.',
    'progress.latest_accuracy': 'Precisión más reciente',
    'progress.best_accuracy': 'Mejor precisión',
    'progress.trend_vs_previous_session':
        '{sign}{delta}% vs la sesión anterior',
    'progress.last_sessions_accuracy_title': 'Últimas sesiones (precisión %)',
    'progress.reps_short': 'reps',
    'progress.chart_accuracy_trend_legend':
        'Las barras más altas indican mejor precisión. Las etiquetas debajo son reps por sesión.',
    'progress.total_reps_all_time': 'Repeticiones totales (histórico)',
    'progress.avg_accuracy_all_sessions':
        'Precisión prom. (todas las sesiones)',
    'progress.sessions': 'Sesiones',
    'progress.chart_accuracy_trend':
        'El gráfico muestra la tendencia de precisión por fecha de sesión.',
    'progress.no_sessions':
        'Aún no hay sesiones. Guarda un entrenamiento para ver analíticas aquí.',
    'badges.empty':
        'Aún no hay insignias.\nEmpieza a entrenar para desbloquear tu primer hito.',
    'badges.collection': 'Tu colección de insignias',
    'badges.current_status': 'Estado actual de insignias',
    'badges.unlocked_count': '{unlocked}/{total} insignias desbloqueadas',
    'badges.tier': 'Nivel: {tier}',
    'badges.next_target':
        'Siguiente objetivo: {name} ({progress}/{requirement}) - {percent}% completado',
    'badges.how_it_works': 'Cómo funciona este sistema de insignias',
    'badges.guide_1':
        'Las insignias usan un ritmo de 5 días activos y 2 días de descanso. Solo los días activos cuentan para el progreso.',
    'badges.guide_2':
        'Los entrenamientos en día de descanso se guardan normalmente pero no suman ni restan progreso de insignias.',
    'badges.guide_3':
        'Las metas diarias tienen límite: hacer repeticiones/series extra no da crédito adicional.',
    'badges.guide_4':
        'No se necesitan mancuernas ni máquinas: también puedes ganar insignias usando alternativas (p. ej., push-ups para Upper, squats para Lower).',
    'badges.guide_5':
        'El progreso se calcula desde los registros guardados; los datos reales impulsan los desbloqueos.',
    'badges.unlocked_on': 'Desbloqueado el {date}',
    'badges.tap_full_plan': 'Toca para ver el plan completo',
    'badges.new_unlock_today': '¡Desbloqueado hoy! Buen trabajo.',
    'badges.unlocked_banner':
        '¡Desbloqueado! Excelente constancia. Mantén este ritmo.',
    'badges.poster_saved_note':
        'El póster de la insignia se guardó automáticamente en la galería: {album}.',
    'badges.poster_save_failed_note':
        'No se pudo guardar el póster en la galería. Revisa el permiso de fotos.',
    'badges.no_tier': 'Aún no hay nivel desbloqueado',
    'badges.motivation_unlocked':
        'Buen trabajo. Esta insignia ya está asegurada; ahora ve por el siguiente nivel.',
    'badges.motivation_almost':
        'Casi listo. Solo faltan {remaining} día(s) calificado(s) para desbloquear esta insignia.',
    'badges.motivation_keep':
        'Sé constante. Cada día calificado impulsa esta insignia.',
    'tier.bronze': 'Bronce',
    'tier.silver': 'Plata',
    'tier.gold': 'Oro',
    'tier.platinum': 'Platino',
    'badge.first_workout.name': 'Primeros pasos',
    'badge.first_workout.narrative':
        'Completa tu primer día de entrenamiento calificado.',
    'badge.first_workout.detail1':
        'Meta: 1 día calificado de registros de entrenamiento guardados.',
    'badge.first_workout.detail2':
        'Objetivo Upper: 8 repeticiones en total (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise).',
    'badge.first_workout.detail3':
        'Objetivo Core: 10 repeticiones en total (Sit-up).',
    'badge.first_workout.detail4':
        'Objetivo Lower: 12 repeticiones en total (Squat / Leg Extension).',
    'badge.prep.name': 'Preparación de 15 días',
    'badge.prep.narrative':
        'Construye constancia con un ritmo de preparación de 15 días.',
    'badge.prep.detail1':
        'Preparación de 15 días con ciclo de 5 días activos + 2 días de descanso (los días 6-7 y 13-14 son descanso).',
    'badge.prep.detail2':
        'Días 1-3: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': 'Días 4-5: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': 'Días 8-12: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': 'Día 15: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = sesiones guardadas por categoría en un día; los días de descanso no suman progreso.',
    'badge.prep.detail8':
        'Si faltas a un día activo obligatorio, el progreso del prep se reinicia y la racha vuelve a Día 1 en tu próximo día de entrenamiento.',
    'badge.bronze.name': 'Mes 1 Bronce',
    'badge.bronze.narrative':
        'Mes base para constancia en el programa completo.',
    'badge.bronze.detail1':
        '30 días activos calificados con un ciclo de 5 activos + 2 descanso.',
    'badge.bronze.detail2':
        'Upper diario: 18 reps + 3 sets (combinadas en Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise).',
    'badge.bronze.detail3': 'Core diario: 24 reps + 3 sets (Sit-up).',
    'badge.bronze.detail4':
        'Lower diario: 30 reps + 3 sets (combinadas en Squat / Leg Extension).',
    'badge.bronze.detail5':
        'Reps/sets extra más allá del límite diario no suman progreso.',
    'badge.bronze.detail6':
        'Incluso si pierdes un día, no tienes que volver a empezar desde el día uno.',
    'badge.silver.name': 'Mes 2 Plata',
    'badge.silver.narrative':
        'Mes de progresión con requisitos de mayor volumen.',
    'badge.silver.detail1':
        '30 días activos calificados con un ciclo de 5 activos + 2 descanso.',
    'badge.silver.detail2':
        'Upper diario: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise combinadas).',
    'badge.silver.detail3': 'Core diario: 32 reps + 4 sets (Sit-up).',
    'badge.silver.detail4':
        'Lower diario: 40 reps + 4 sets (Squat / Leg Extension combinadas).',
    'badge.silver.detail5':
        'Solo los días activos cuentan; los días de descanso se ignoran.',
    'badge.silver.detail6':
        'Incluso si pierdes un día, no tienes que volver a empezar desde el día uno.',
    'badge.gold.name': 'Mes 3 Oro',
    'badge.gold.narrative':
        'Mes de maestría con objetivos avanzados de resistencia.',
    'badge.gold.detail1':
        '30 días activos calificados con un ciclo de 5 activos + 2 descanso.',
    'badge.gold.detail2':
        'Upper diario: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise combinadas).',
    'badge.gold.detail3': 'Core diario: 40 reps + 4 sets (Sit-up).',
    'badge.gold.detail4':
        'Lower diario: 50 reps + 4 sets (Squat / Leg Extension combinadas).',
    'badge.gold.detail5':
        'El progreso usa registros guardados; reps extra no suman crédito.',
    'badge.gold.detail6':
        'Incluso si pierdes un día, no tienes que volver a empezar desde el día uno.',
    'badge.default.goal': 'Meta: {description}',
    'badge.default.requirement':
        'Requisito: {requirement} día(s) calificado(s).',
    'badge.default.status': 'Estado actual: {progress}/{requirement}.',
    'badge.poster.badge_label': 'Insignia',
    'badge.poster.user_label': 'Logrado por',
    'badge.poster.requirements_label': 'Datos calificados',
    'leaderboard.title': 'Clasificación',
    'leaderboard.achievements': 'Logros',
    'leaderboard.global': 'Global',
    'leaderboard.achievement_progress': 'Progreso de logros',
    'leaderboard.personal_bests': 'Mejores marcas',
    'leaderboard.most_reps': 'Más repeticiones',
    'leaderboard.best_accuracy': 'Mejor precisión',
    'leaderboard.longest_streak': 'Racha más larga',
    'leaderboard.days': 'Días',
    'leaderboard.global_simulated': 'Clasificación global (simulada)',
    'leaderboard.points': '{score} pts',
    'recordings.tab.recordings': 'Grabar',
    'recordings.tab.profile': 'Perfil',
    'recordings.failed_load': 'No se pudieron cargar las grabaciones',
    'recordings.empty': 'Aún no hay videos grabados',
    'recordings.file_not_found': 'Archivo de video no encontrado',
    'recordings.file_incomplete':
        'El archivo de grabación está incompleto. Graba de nuevo.',
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
    'profile.photo_remove_confirm': '¿Eliminar tu foto de perfil?',
    'profile.photo_too_large':
        'La foto es demasiado grande. Elige una imagen más pequeña.',
    'profile.photo_error':
        'No se pudo guardar la foto. Inténtalo con otra imagen.',
    'profile.photo_badge_notice':
        'Si no agregas una foto de perfil, los pósteres de insignias se crearán sin tu foto.',
    'profile.exercise_totals_title': 'Totales de ejercicios',
    'profile.exercise_totals_subtitle': 'Desde tu primera hasta tu última sesión.',
    'profile.exercise_empty': 'Aún no hay datos de ejercicio',
    'profile.badges_title': 'Badges obtenidas',
    'profile.badges_empty': 'Aún no hay badges',
    'profile.badge_gallery_saved_note':
        'Cuando desbloqueas una insignia, su póster se guarda automáticamente en la galería: {album}.',
    'camera.overlay.skeleton': 'Esqueleto',
    'camera.overlay.stop': 'Detener',
    'camera.overlay.record': 'Grabar',
    'camera.overlay.complete': 'Completar',
    'lang.en': 'Inglés',
    'lang.es': 'Español',
    'lang.ja': 'Japonés',
    'lang.my': 'Birmano',
    'lang.hi': 'Hindi',
    'lang.pt': 'Portugués',
    'lang.zh': 'Chino mandarín',
    'lang.de': 'Alemán',
  };

  static const Map<String, String> _jaValues = {
    'app.title': 'H&F',
    'nav.exercises': 'エクササイズ',
    'nav.progress': '進捗',
    'nav.recordings': '録画とプロフィール',
    'common.cancel': 'キャンセル',
    'common.retry': '再試行',
    'common.load_exercises': 'エクササイズを読み込む',
    'common.clear_data': 'データを削除',
    'common.ok': 'OK',
    'common.close': '閉じる',
    'common.error_with_message': 'エラー: {message}',
    'premium.badge': 'プレミアム',
    'premium.menu_only': 'このメニューはプレミアムユーザーのみ利用できます。',
    'home.exercises_list': 'エクササイズ一覧',
    'home.exercises_simple_form': '簡易フォーム',
    'home.no_supported_exercises': '対応するエクササイズがありません',
    'home.check_exercise_config': 'エクササイズ設定を確認してください',
    'home.error_loading_exercise': 'エクササイズの読み込みに失敗しました: {error}',
    'home.image_reference_count': '参考画像 {count} 枚',
    'home.today_progress_premium': '今日の進捗（プレミアム）',
    'home.today_progress_locked_desc': '進捗メニューの詳細データはプレミアムで利用できます。',
    'home.today_progress': '今日の進捗',
    'home.total_reps': '総回数',
    'home.workouts': 'ワークアウト',
    'home.calories': 'カロリー',
    'home.daily_goal': '1日の目標: {current}/{goal}',
    'home.daily_goal_achieved': '1日の目標を達成！',
    'home.progress_premium_title': '進捗はプレミアム機能',
    'home.progress_premium_message': '詳細な進捗分析はプレミアムで解除されます。',
    'home.recordings_premium_title': '録画はプレミアム機能',
    'home.recordings_premium_message': '録画履歴はプレミアムのみ利用可能です。',
    'home.simple_form': '{name} フォーム',
    'home.quick_form_summary': 'フォームの簡易概要',
    'home.form_images': 'フォーム画像',
    'home.exercise_list_notice_title': 'クイックリマインダー',
    'home.exercise_list_notice_message':
        '各エクササイズのフォームには注意事項がある場合があります。確認してください。注記: situp エクササイズには重要な注意事項があります。',
    'home.simple_form_notice':
        '精度バーとカウントの注意:\n本AIはガイドに近い動きを認識するよう設計されています。スムーズにカウントできますが、正式な技術指導ではありません。アプリの精度が100%ではない点もご了承ください。\n\n横向きの種目は横向き、正面の種目は正面を保ってください。そうすると結果が正確になります。\n\n次の場合、計測が不正確になることがあります:\n• 体全体がカメラ枠に入っていない\n• カメラに複数人が映っている。\n• 部屋が暗すぎる、または強いフレア/反射がある\n• カメラは体に対して低すぎず高すぎない位置に置いてください。',
    'home.situp_notice':
        '注意 1. カメラを設置し、situp を行う場所を決めたら、まず2秒静止してから始めてください。\n2. situp を終えたら、少なくとも2秒座ってからカメラのところへ行ってください。',
    'exercise.guide.title': 'クイックガイド',
    'exercise.guide.step1': 'ランドマークを作成したい場合は、スケルトンボタンを押してください。',
    'exercise.guide.step2': '動画を録画したい場合は、録画ボタンを押してください。',
    'exercise.guide.step3': '録画を停止して保存するには、画面をダブルタップするか戻るボタンを押してください。',
    'exercise.guide.step4': '運動が終わったら完了ボタンを押し、もう一度保存ボタンを押して保存してください。',
    'exercise.error.setup_title': 'セットアップエラー',
    'exercise.error.setup_message': '初期化に失敗しました: {error}',
    'exercise.error.pose_title': '姿勢検出エラー',
    'exercise.error.pose_message':
        '姿勢検出を初期化できませんでした。Google Play Services が最新か確認してください。',
    'exercise.premium.landmarks': 'ランドマーク表示はプレミアム機能です。',
    'exercise.premium.recording': '動画録画はプレミアム版で利用できます。アップグレードして解除してください。',
    'exercise.recording.failed_start': '画面録画に失敗しました: {error}',
    'exercise.recording.permission_denied': '画面/音声録画の権限が拒否されました',
    'exercise.recording.failed_save': '画面録画の保存に失敗しました',
    'exercise.recording.saved_gallery': 'ギャラリーに保存しました（{album}）',
    'exercise.recording.saved_app': 'アプリ内ストレージに保存しました: {path}',
    'exercise.recording.saved_phone': '動画を端末ストレージに保存しました',
    'exercise.recording.failed_video': '動画の録画に失敗しました: {error}',
    'exercise.recording.preparing_luxury_video':
        '高級感のあるワークアウト動画を準備しています。',
    'exercise.recording.keep_screen_open':
        'この画面をしばらく開いたままにしてください。',
    'exercise.premium.title': 'プレミアム機能',
    'exercise.premium.not_now': '今はしない',
    'exercise.premium.upgrade': 'アップグレード',
    'exercise.premium.required_title': 'プレミアムが必要です',
    'exercise.premium.required_message': 'ワークアウトの保存、カウント、進捗追跡はプレミアムのみ利用できます。',
    'exercise.camera.error_title': 'カメラエラー',
    'exercise.camera.error_message': 'カメラを初期化できません。権限を確認して再試行してください。',
    'exercise.counting_premium': 'カウント（プレミアム）',
    'exercise.summary.title': 'ワークアウト完了！',
    'exercise.summary.total_reps': '合計回数',
    'exercise.summary.avg_accuracy': '平均精度',
    'exercise.summary.duration': '時間',
    'exercise.summary.seconds': '{value} 秒',
    'exercise.summary.best_accuracy': '最高精度（1回）',
    'exercise.summary.close': '閉じる',
    'exercise.summary.view_details': '保存',
    'exercise.card.type.dynamic': 'ダイナミック',
    'exercise.card.type.static': 'スタティック',
    'exercise.card.view.front': '正面',
    'exercise.card.view.side': '横',
    'exercise.card.total_reps': '合計回数',
    'exercise.card.avg_accuracy': '平均精度',
    'exercise.card.select': 'エクササイズを選択',
    'exercise.time.today': '今日',
    'exercise.time.yesterday': '昨日',
    'exercise.time.days_ago': '{value}日前',
    'exercise.time.weeks_ago': '{value}週間前',
    'exercise.time.months_ago': '{value}か月前',
    'guide.squat.subtitle': '胸を起こし、股関節を後ろに引き、膝はつま先の方向に。',
    'guide.squat.step1': '足を肩幅に開き、体幹を締める。',
    'guide.squat.step2': 'かかとを浮かせず、太ももがほぼ平行になるまで下ろす。',
    'guide.squat.step3': 'かかとで押して立ち上がり、膝をロックしない。',
    'guide.pushup.subtitle': '頭からかかとまで一直線を保ち、1回ずつコントロール。',
    'guide.pushup.step1': '両手を肩幅より少し広くしてハイプランクから開始。',
    'guide.pushup.step2': '肘を約45度に曲げて胸を下ろす。',
    'guide.pushup.step3': '体幹を締め、腰を水平に保ったまま押し上げる。',
    'guide.situp.subtitle': '首で引かず、体幹でコントロール。',
    'guide.situp.step1': '仰向けで膝を曲げ、足を床につける。',
    'guide.situp.step2': '腹筋を締めて上体を起こす。',
    'guide.situp.step3': 'ゆっくり戻して次の回に備える。',
    'guide.bicep.subtitle': '肘を体側に固定し、反動を使わない。',
    'guide.bicep.step1': 'ダンベルを持ち、手のひらを前にして直立。',
    'guide.bicep.step2': '肩を動かさず肘を曲げて持ち上げる。',
    'guide.bicep.step3': 'ゆっくり下ろして伸ばす。',
    'guide.shoulder.subtitle': '肋骨を下げて体幹を締め、真上に押す。',
    'guide.shoulder.step1': '肩の高さで構え、手首はニュートラル。',
    'guide.shoulder.step2': '頭上まで押し上げる。',
    'guide.shoulder.step3': '肩の高さまでコントロールして下ろす。',
    'guide.leg.subtitle': '可動域をコントロールし、膝を勢いで伸ばさない。',
    'guide.leg.step1': '背中を支え、脚をパッドの下に置いて座る。',
    'guide.leg.step2': '股関節を安定させて膝を伸ばしパッドを上げる。',
    'guide.leg.step3': '膝を曲げながらゆっくり下ろす。',
    'settings.title': '設定',
    'settings.premium_features': 'プレミアム機能',
    'settings.app_settings': 'アプリ設定',
    'settings.profile_name': 'プロフィール名',
    'settings.appearance': '外観',
    'settings.data': 'データ',
    'settings.about': 'このアプリについて',
    'settings.premium_account': 'プレミアムアカウント',
    'settings.unlock_all_features': 'すべてのプレミアム機能を解除',
    'settings.voice_counting': '音声カウント',
    'settings.speak_count': '回数を音声で読み上げる',
    'settings.voice_counting_language': '音声カウント言語',
    'settings.upgrade_to_premium': 'プレミアムにアップグレード',
    'settings.upgrade_subtitle': '音声カウント、動画録画などが利用可能',
    'settings.voice_coach': '音声コーチ',
    'settings.voice_feedback': 'リアルタイムの音声フィードバック',
    'settings.show_landmarks': 'ランドマーク表示',
    'settings.display_skeleton': 'スケルトン表示',
    'settings.auto_recording': '自動録画',
    'settings.auto_recording_subtitle': 'ワークアウトを自動で録画',
    'settings.theme': 'テーマ',
    'settings.language': '言語',
    'settings.language_subtitle': 'アプリの言語を変更',
    'settings.clear_data': 'データを削除',
    'settings.clear_data_subtitle': 'すべてのワークアウト履歴を削除',
    'settings.version': 'バージョン',
    'settings.privacy_policy': 'プライバシーポリシー',
    'settings.terms': '利用規約',
    'settings.disclaimer': '免責事項',
    'legal.last_updated': '最終更新日: {date}',
    'legal.privacy.content':
        '1) 収集するデータ\n'
        'H&Fはワークアウトログ、バッジ進捗、アプリ設定、および任意の録画ファイルパスを端末に保存します。\n\n'
        '2) プレミアムの有効化\n'
        'プレミアムの有効化には少なくとも一度インターネット接続が必要です。有効化時にライセンスキー、端末識別子のハッシュ、アプリバージョン、プラットフォームをライセンスサーバーへ送信します。有効化後はプレミアム権利が端末内で検証され、オフラインでも使用できます。\n\n'
        '3) カメラ・マイク・ストレージ・処理能力\n'
        'カメラはポーズ検出に使用します。ポーズの解析には端末の処理能力を使用します。マイクや画面録画の権限は録画機能を使う場合のみ必要です。保存された動画は端末やギャラリーに残ります。\n\n'
        '4) データの利用目的\n'
        'データは回数のカウント、精度計算、進捗の追跡、バッジのロック解除、およびプレミアム機能提供に使われます。\n\n'
        '5) 共有\n'
        '個人データを販売することはありません。ライセンス認証データはプレミアムアクセスの有効化と保護のためにのみ処理します。\n\n'
        '6) ユーザーの管理\n'
        'いつでも全データの削除、アプリのアンインストールが可能です。データ削除はローカル履歴と保存されたプレミアム状態を消去します。\n\n'
        '7) セキュリティ\n'
        '改ざんのリスクを減らすために整合性チェックと安全なローカル保存を使用していますが、完全に安全なシステムは存在しません。',
    'legal.terms.content':
        'H&Fを利用することで、これらの利用規約に同意したものとみなされます。\n\n'
        '1) サービスの利用\n'
        'H&Fはフィットネス支援アプリです。ご自身の安全と健康上の判断に責任を持ってください。\n\n'
        '2) アカウントとライセンス\n'
        'プレミアムには有効なライセンスキーが必要です。ライセンスは端末ごとに制限され、乱用、取り消し、セキュリティ侵害でブロックされることがあります。\n\n'
        '3) オフラインモード\n'
        '有効化が成功すると、同じ端末上で基本機能とプレミアム機能をオフラインで利用できます。再インストール、機密データの消去、整合性チェックの失敗などで再びオンライン有効化が必要になる場合があります。\n\n'
        '4) 制限事項\n'
        'セキュリティの改ざん、ライセンスのリバースエンジニアリング、違法活動への利用は禁止です。\n\n'
        '5) 知的財産\n'
        'アプリのソフトウェア、ブランディング、コンテンツはH&Fおよびそのライセンサーの財産です。\n\n'
        '6) 保証の否認\n'
        'アプリは「現状のまま」で提供されており、継続的な稼働や特定のフィットネス成果を保証するものではありません。本アプリのカウンターは、さまざまな理由により多く数えたり少なく数えたりする場合があります。\n\n'
        '7) 責任の制限\n'
        'H&Fはアプリ利用による間接的、偶発的、結果的損害について責任を負いません。',
    'legal.disclaimer.content':
        'H&Fは医療サービスではなく、医療助言、診断、治療を提供しません。\n\n'
        '1) トレーニングリスク\n'
        '運動には怪我のリスクがあります。痛み、めまい、呼吸困難、不快感を感じたら直ちに中止し、資格のある専門家に相談してください。\n\n'
        '2) AIによるカウントとフォームフィードバック\n'
        'ポーズ検出と回数カウントは推定値であり、カメラの角度、照明、遮蔽、衣服、動作速度によって誤ることがあります。\n\n'
        '3) 録画時の性能\n'
        '通常のトレーニングでスマホを起動したままカウント/音声カウントが動作するよう設計されています。ポーズ検出（カウント）と動画録画は同時に動作でき、通常は約5〜15分は問題なく動作します。長時間連続で使用すると、端末の発熱や電池消費が増え、精度が低下する可能性があります。\n\n'
        '4) 緊急時\n'
        '緊急時にこのアプリに頼らないでください。必要に応じて速やかに地域の緊急サービスへ連絡してください。\n\n'
        '5) ユーザーの責任\n'
        '安全なトレーニング空間、適切なフォーム、必要な医療的承認を得ることはユーザーの責任です。\n\n'
        '6) 録画や他者のプライバシー\n'
        'トレーニングを録画する場合、映像や音声に写る可能性のある人々の同意を得てください。\n\n'
        '7) 結果\n'
        '運動結果は人によって異なります。H&Fは特定の成果や健康上の結果を保証しません。',
    'settings.select_theme': 'テーマを選択',
    'settings.select_language': '言語を選択',
    'onboarding.language_title': '言語を選択',
    'onboarding.language_subtitle': '後で設定から変更できます。',
    'onboarding.name_title': 'お名前は？',
    'onboarding.name_subtitle': 'プロフィールに表示されます。',
    'onboarding.name_hint': '名前を入力',
    'onboarding.name_required': '名前を入力してください',
    'onboarding.disclaimer_title': '免責事項',
    'onboarding.terms_title': '利用規約',
    'onboarding.accept_notice': '同意してアプリを続けてください。',
    'onboarding.accept_checkbox': '同意します',
    'onboarding.continue': '続行',
    'onboarding.start_app': 'アプリを開始',
    'settings.clear_all_data': 'すべてのデータを削除',
    'settings.clear_all_data_desc': 'ワークアウト履歴、実績、設定をすべて削除します。この操作は元に戻せません。',
    'settings.clear_success': 'ユーザーデータをすべて削除しました。',
    'settings.clear_failed': 'データ削除に失敗しました: {error}',
    'theme.light': 'ライト',
    'theme.dark': 'ダーク',
    'theme.gold': 'ゴールド',
    'theme.pink': 'ピンク',
    'progress.title': '進捗と分析',
    'progress.overview': '概要',
    'progress.exercises': 'エクササイズ',
    'progress.badges': 'バッジ',
    'progress.no_data': 'データがありません',
    'progress.weekly_summary': '週間サマリー',
    'progress.streak_days': '{count}日連続',
    'progress.recent_workouts': '最近のワークアウト',
    'progress.no_workouts': 'まだワークアウトがありません',
    'progress.workout_summary': '{reps}回 • 精度{accuracy}%',
    'progress.achievements': '実績',
    'progress.badges_unlocked': '{unlocked}/{total}個のバッジを解除',
    'progress.view_all_achievements': 'すべての実績を見る',
    'progress.day.sun': '日',
    'progress.day.mon': '月',
    'progress.day.tue': '火',
    'progress.day.wed': '水',
    'progress.day.thu': '木',
    'progress.day.fri': '金',
    'progress.day.sat': '土',
    'progress.time.just_now': 'たった今',
    'progress.time.minutes_ago': '{value}分前',
    'progress.time.hours_ago': '{value}時間前',
    'progress.time.days_ago': '{value}日前',
    'progress.time.weeks_ago': '{value}週間前',
    'progress.analytics_intro_title': 'エクササイズ分析の見方',
    'progress.analytics_intro_line1': '総回数 = すべてのセッションで保存されたこの種目の回数合計。',
    'progress.analytics_intro_line2': '平均精度 = 保存された全セッションのフォーム精度の平均。',
    'progress.analytics_intro_line3': 'トレンドチャート = 時間経過の精度（高いほどフォームが良い）。',
    'progress.analytics_intro_line4': '分析はワークアウトを保存した後にのみ更新されます。',
    'progress.read_exercise_analytics_title': 'エクササイズ分析の見方',
    'progress.read_exercise_analytics_line1': '最新の精度 = 直近セッションのフォームスコア。',
    'progress.read_exercise_analytics_line2': '最高精度 = これまでで最も高いスコア。',
    'progress.read_exercise_analytics_line3':
        'セッションバーは直近6回分を表示します。バーが高いほど精度が高いです。',
    'progress.read_exercise_analytics_line4': '各バーの下の数字はそのセッションの回数です。',
    'progress.latest_accuracy': '最新精度',
    'progress.best_accuracy': '最高精度',
    'progress.trend_vs_previous_session': '{sign}{delta}%（前回セッション比）',
    'progress.last_sessions_accuracy_title': '直近セッション（精度%）',
    'progress.reps_short': '回',
    'progress.chart_accuracy_trend_legend': 'バーが高いほど精度が高いです。下のラベルは各セッションの回数です。',
    'progress.total_reps_all_time': '総回数（全期間）',
    'progress.avg_accuracy_all_sessions': '平均精度（全セッション）',
    'progress.sessions': 'セッション',
    'progress.chart_accuracy_trend': 'チャートはセッション日ごとの精度推移を示します。',
    'progress.no_sessions': 'まだセッションがありません。ワークアウトを保存するとここに表示されます。',
    'badges.empty': 'バッジがありません。\nワークアウトを始めて最初のマイルストーンを解除しましょう。',
    'badges.collection': 'バッジコレクション',
    'badges.current_status': '現在のバッジ状況',
    'badges.unlocked_count': '{unlocked}/{total}個のバッジを解除',
    'badges.tier': 'ティア: {tier}',
    'badges.next_target':
        '次の目標: {name} ({progress}/{requirement}) - 全体 {percent}% 完了',
    'badges.how_it_works': 'バッジシステムの仕組み',
    'badges.guide_1': 'バッジは5日活動・2日休息のリズムです。進捗に数えられるのは活動日だけです。',
    'badges.guide_2': '休息日のワークアウトは保存されますが、バッジ進捗には加算も減算もされません。',
    'badges.guide_3': '1日の目標は上限あり。上限を超える回数/セットは追加の進捗になりません。',
    'badges.guide_4':
        'ダンベルやマシンがなくてもOK。代替でバッジを獲得できます（Upper は push-ups、Lower は squats など）。',
    'badges.guide_5': '進捗は保存されたログから計算され、実際のデータが解除に反映されます。',
    'badges.unlocked_on': '{date} に解除',
    'badges.tap_full_plan': 'タップして全プランを見る',
    'badges.new_unlock_today': '本日解除！おめでとう。',
    'badges.unlocked_banner': '解除！優れた継続です。勢いを保ちましょう。',
    'badges.poster_saved_note':
        'バッジポスターはギャラリーのアルバム {album} に自動保存されました。',
    'badges.poster_save_failed_note':
        'バッジポスターをギャラリーに保存できませんでした。写真権限を確認してください。',
    'badges.no_tier': 'まだティアが解除されていません',
    'badges.motivation_unlocked': 'よくやりました。次のティアを目指しましょう。',
    'badges.motivation_almost': 'もう少し。あと {remaining} 日で解除できます。',
    'badges.motivation_keep': '継続が大切です。毎日の積み重ねが進捗になります。',
    'tier.bronze': 'ブロンズ',
    'tier.silver': 'シルバー',
    'tier.gold': 'ゴールド',
    'tier.platinum': 'プラチナ',
    'badge.first_workout.name': 'ファーストステップ',
    'badge.first_workout.narrative': '最初の条件付きワークアウト日を完了する。',
    'badge.first_workout.detail1': '目標: 保存されたワークアウトログから条件付き1日。',
    'badge.first_workout.detail2':
        'Upper 目標: 合計8回 (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise)。',
    'badge.first_workout.detail3': 'Core 目標: 合計10回 (Sit-up)。',
    'badge.first_workout.detail4': 'Lower 目標: 合計12回 (Squat / Leg Extension)。',
    'badge.prep.name': '15日準備',
    'badge.prep.narrative': '15日間の準備リズムで継続力をつける。',
    'badge.prep.detail1': '5日活動 + 2日休息の15日サイクル（6-7日目と13-14日目が休息）。',
    'badge.prep.detail2':
        '1-3日: Upper 8回x2セット; Core 10回x2セット; Lower 12回x2セット。',
    'badge.prep.detail3': '4-5日: Upper 10x2; Core 12x2; Lower 15x2。',
    'badge.prep.detail4': '8-12日: Upper 12x2; Core 15x2; Lower 18x2。',
    'badge.prep.detail5': '15日目: Upper 12x3; Core 15x3; Lower 18x3。',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7': 'セット = 1日のカテゴリー別保存セッション数。休息日は進捗に加算されません。',
    'badge.prep.detail8':
        '必須の活動日を1日でも逃すと、prep進捗はリセットされ、次のワークアウト日からDay 1として再開されます。',
    'badge.bronze.name': '1か月目 ブロンズ',
    'badge.bronze.narrative': '全プログラムの基礎となる1か月。',
    'badge.bronze.detail1': '5日活動 + 2日休息サイクルで条件付き30日。',
    'badge.bronze.detail2':
        'Upper: 30回 + 3セット（Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise 合算）。',
    'badge.bronze.detail3': 'Core: 36回 + 3セット（Sit-up）。',
    'badge.bronze.detail4': 'Lower: 45回 + 3セット（Squat / Leg Extension 合算）。',
    'badge.bronze.detail5': '上限を超える回数/セットは進捗に加算されません。',
    'badge.bronze.detail6': '1日逃しても、1日目からやり直す必要はありません。',
    'badge.silver.name': '2か月目 シルバー',
    'badge.silver.narrative': 'より高いボリュームを求める進行月。',
    'badge.silver.detail1': '5日活動 + 2日休息サイクルで条件付き30日。',
    'badge.silver.detail2':
        'Upper: 48回 + 4セット（Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise 合算）。',
    'badge.silver.detail3': 'Core: 60回 + 4セット（Sit-up）。',
    'badge.silver.detail4': 'Lower: 80回 + 4セット（Squat / Leg Extension 合算）。',
    'badge.silver.detail5': '進捗に数えられるのは活動日のみ。休息日は無視されます。',
    'badge.silver.detail6': '1日逃しても、1日目からやり直す必要はありません。',
    'badge.gold.name': '3か月目 ゴールド',
    'badge.gold.narrative': '上級持久力の達成月。',
    'badge.gold.detail1': '5日活動 + 2日休息サイクルで条件付き30日。',
    'badge.gold.detail2':
        'Upper: 60回 + 4セット（Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise 合算）。',
    'badge.gold.detail3': 'Core: 100回 + 4セット（Sit-up）。',
    'badge.gold.detail4': 'Lower: 100回 + 4セット（Squat / Leg Extension 合算）。',
    'badge.gold.detail5': '進捗は保存ログから計算され、上限超過は加算されません。',
    'badge.gold.detail6': '1日逃しても、1日目からやり直す必要はありません。',
    'badge.default.goal': '目標: {description}',
    'badge.default.requirement': '要件: 条件付き {requirement} 日。',
    'badge.default.status': '現在: {progress}/{requirement}.',
    'badge.poster.badge_label': 'バッジ',
    'badge.poster.user_label': '達成者',
    'badge.poster.requirements_label': '適格データ',
    'leaderboard.title': 'ランキング',
    'leaderboard.achievements': '実績',
    'leaderboard.global': 'グローバル',
    'leaderboard.achievement_progress': '実績の進捗',
    'leaderboard.personal_bests': '自己ベスト',
    'leaderboard.most_reps': '最多回数',
    'leaderboard.best_accuracy': '最高精度',
    'leaderboard.longest_streak': '最長連続',
    'leaderboard.days': '日',
    'leaderboard.global_simulated': 'グローバルランキング（シミュレーション）',
    'leaderboard.points': '{score} pt',
    'recordings.tab.recordings': '録画',
    'recordings.tab.profile': 'プロフィール',
    'recordings.failed_load': '録画を読み込めませんでした',
    'recordings.empty': 'まだ録画動画はありません',
    'recordings.file_not_found': '動画ファイルが見つかりません',
    'recordings.file_incomplete': '録画ファイルが不完全です。もう一度録画してください。',
    'profile.guest_name': 'ユーザー',
    'profile.user_name_label': 'ユーザー名',
    'profile.edit_name': '編集',
    'profile.name_hint': '名前を入力',
    'profile.save_name': '保存',
    'profile.photo_title': 'プロフィール写真',
    'profile.photo_subtitle': '全身が写る写真を追加してプロフィールをカスタマイズしましょう。',
    'profile.photo_add': '写真を追加',
    'profile.photo_change': '写真を変更',
    'profile.photo_remove': '写真を削除',
    'profile.photo_remove_confirm': 'プロフィール写真を削除しますか？',
    'profile.photo_too_large': '写真の容量が大きすぎます。小さい画像を選んでください。',
    'profile.photo_error': '写真を保存できませんでした。別の画像を試してください。',
    'profile.photo_badge_notice':
        'プロフィール写真が未設定の場合、バッジポスターには写真が入りません。',
    'profile.exercise_totals_title': '累計トレーニング',
    'profile.exercise_totals_subtitle': '最初のトレーニングから最新まで。',
    'profile.exercise_empty': 'まだ運動データがありません',
    'profile.badges_title': '獲得バッジ',
    'profile.badges_empty': 'まだバッジがありません',
    'profile.badge_gallery_saved_note':
        'バッジを解除すると、ポスターはギャラリーのアルバム {album} に自動保存されます。',
    'camera.overlay.skeleton': 'スケルトン',
    'camera.overlay.stop': '停止',
    'camera.overlay.record': '録画',
    'camera.overlay.complete': '完了',
    'lang.en': '英語',
    'lang.es': 'スペイン語',
    'lang.ja': '日本語',
    'lang.my': 'ビルマ語',
    'lang.hi': 'ヒンディー語',
    'lang.pt': 'ポルトガル語',
    'lang.zh': '中国語（標準）',
    'lang.de': 'ドイツ語',
  };

  static const Map<String, String> _myValues = {
    'app.title': 'H&F',
    'nav.exercises': 'လေ့ကျင့်ခန်းများ',
    'nav.progress': 'တိုးတက်မှု',
    'nav.recordings': 'မှတ်တမ်းနှင့် ပရိုဖိုင်',
    'common.cancel': 'ပယ်ဖျက်',
    'common.retry': 'ပြန်ကြိုးစား',
    'common.load_exercises': 'လေ့ကျင့်ခန်းများ ပြန်တင်',
    'common.clear_data': 'ဒေတာဖျက်',
    'common.ok': 'OK',
    'common.close': 'ပိတ်',
    'common.error_with_message': 'အမှား: {message}',
    'premium.badge': 'ပရီမီယမ်',
    'premium.menu_only': 'ဤမီနူးကို ပရီမီယမ်အသုံးပြုသူများသာ အသုံးပြုနိုင်သည်။',
    'home.exercises_list': 'လေ့ကျင့်ခန်းစာရင်း',
    'home.exercises_simple_form': 'လေ့ကျင့်ခန်းပုံစံ',
    'home.no_supported_exercises': 'ထောက်ပံ့ထားသော လေ့ကျင့်ခန်းများ မရှိပါ',
    'home.check_exercise_config': 'လေ့ကျင့်ခန်း ဆက်တင်ကို စစ်ဆေးပါ',
    'home.error_loading_exercise':
        'လေ့ကျင့်ခန်းကို လုပ်ဆောင်ရာတွင် အမှား: {error}',
    'home.image_reference_count': 'ပုံညွှန်း {count} ပုံ',
    'home.today_progress_premium': 'ဒီနေ့ တိုးတက်မှု (Premium)',
    'home.today_progress_locked_desc':
        'တိုးတက်မှု မီနူးဒေတာများကို Premium အသုံးပြုသူများသာ ရနိုင်သည်။',
    'home.today_progress': 'ဒီနေ့ တိုးတက်မှု',
    'home.total_reps': 'လေ့ကျင့်ခန်းအချက်ရေ',
    'home.workouts': 'လေ့ကျင့်မှုများ',
    'home.calories': 'ကယ်လိုရီ',
    'home.daily_goal': 'နေ့စဉ်ရည်မှန်းချက်: {current}/{goal}',
    'home.daily_goal_achieved': 'နေ့စဉ်ရည်မှန်းချက် ပြည့်ပြီး!',
    'home.progress_premium_title': 'တိုးတက်မှုသည် Premium တွင်သာရနိုင်သည်.',
    'home.progress_premium_message':
        'အသေးစိတ်တိုးတက်မှုစာရင်းများကို Premium တွင်သာ ရနိုင်သည်။',
    'home.recordings_premium_title': 'Recording သည် Premiumတွင်သာရနိုင်သည်.',
    'home.recordings_premium_message':
        'ဗီဒီယိုမှတ်တမ်းသမိုင်းကို Premium တွင်သာ ရနိုင်သည်။',
    'home.simple_form': '{name} ပုံစံ',
    'home.quick_form_summary': 'ပုံစံ အကျဉ်းချုပ်',
    'home.form_images': 'ပုံစံပုံများ',
    'home.exercise_list_notice_title': 'အမြန်သတိပေးချက်',
    'home.exercise_list_notice_message':
        'လေ့ကျင့်ခန်းပုံစံတိုင်းတွင် သတိပြုချက်များ ရှိနိုင်တာကြောင့် သေချာစစ်ဆေးပါ။ Note- situp exercise မှာ အရေးကြီးတဲ့ သတိပြုချက်ရှိပါတယ်။',
    'home.simple_form_notice':
        'တိကျမှုဘားနှင့် ကောင့်ရေတွက်မှု သတိပေးချက်:\nကျွန်ုပ်တို့ AI သည် လမ်းညွှန်ပုံများနှင့် ကိုက်ညီသော လေ့ကျင့်ခန်းများကို မှတ်မိရန် ဒီဇိုင်းထားသည်။ ကောင့်ရေတွက်မှု ချောမွေ့ပြီး တိကျမှုကောင်းသော်လည်း နည်းပညာပိုင်း ကိုချ်အဖြစ် မဟုတ်ပါ။ အက်ပ်၏ တိကျမှုသည် 100% မဟုတ်ကြောင်းလည်း မှတ်သားပါ။\n\nSide view လေ့ကျင့်ခန်းများအတွက် ဘေးဘက်အနေအထားကို ထိန်းထားပါ၊ Front view လေ့ကျင့်ခန်းများအတွက် အရှေ့ဘက်အနေအထားကို ထိန်းထားပါ။ အဲဒီလို လုပ်လျှင် ရလဒ်မှန်ကန်ပါလိမ့်မည်။\n\nအောက်ပါအခြေအနေများတွင် တိကျမှု မဖြစ်နိုင်ပါ:\n• ခန္ဓာကိုယ်တစ်ခုလုံး ကင်မရာအတွင်း မပါဝင်ပါက\n• ကင်မရာထဲမှာ လူတစ်ယောက်ထက်ပိုရှိနေပါက။\n• အခန်းအလင်းမမှန်ကန်ခြင်း သို့မဟုတ် ပြင်းထန်တဲ့ အလင်းပြန်မှု/မီးတောက်ရှိပါက\n• ကင်မရာကို ကိုယ်ခန္ဓာထက် အရမ်းလည်းနိမ့်၊ အရမ်းလည်းမမြင့်သော အနေအထားတွင်ထားပါ။',
    'home.situp_notice':
        'သတိ 1. ကင်မရာကို တပ်ပြီး situp လေ့ကျင့်ခန်းလုပ်မယ့် နေရာကို ရွေးပြီးပါက 2 စက္ကန့် အနေအထားတည်ငြိမ်ပြီးနောက် စတင်လုပ်ပါ။\n2. situp လေ့ကျင့်ခန်း ပြီးသွားတဲ့အပြီး 2 စက္ကန့် အနည်းဆုံး ထိုင်ပြီးနောက် ကင်မရာရှိရာကို သွားပါ။',
    'exercise.guide.title': 'အမြန်လမ်းညွှန်',
    'exercise.guide.step1':
        'Landmark ဖန်တီးလိုလျှင် skeleton ခလုတ်ကို နှိပ်ပါ။',
    'exercise.guide.step2':
        'ဗီဒီယိုမှတ်တမ်းလုပ်လိုလျှင် record ခလုတ်ကို နှိပ်ပါ။',
    'exercise.guide.step3':
        'Recording ကိုရပ်ပြီး သိမ်းလိုလျှင် စကရင်ကို double tap လုပ်ပါ သို့မဟုတ် back ခလုတ်ကို နှိပ်ပါ။',
    'exercise.guide.step4':
        'လေ့ကျင့်ခန်းပြီးပါက complete ခလုတ်ကို နှိပ်ပြီး Save ခလုတ်ကို ထပ်နှိပ်၍ သိမ်းပါ။',
    'exercise.error.setup_title': 'စတင်မှု အမှား',
    'exercise.error.setup_message': 'စတင်ရန် မအောင်မြင်ပါ: {error}',
    'exercise.error.pose_title': 'Pose Detection အမှား',
    'exercise.error.pose_message':
        'Pose detection service မရပါက Google Play Services ကို နောက်ဆုံးဗားရှင်းဖြစ်မဖြစ် စစ်ဆေးပါ။',
    'exercise.premium.landmarks':
        'Landmark overlay သည် Premium လုပ်ဆောင်ချက် ဖြစ်သည်။',
    'exercise.premium.recording':
        'ဗီဒီယို Recording ကို Premium များတွင်သာ ရနိုင်သည်။ Upgrade လုပ်ပါ။',
    'exercise.recording.failed_start': 'စကရင် Recording မစတင်နိုင်ပါ: {error}',
    'exercise.recording.permission_denied':
        'စကရင်/အသံ Recording ခွင့်ပြုချက် ငြင်းပယ်ထားသည်',
    'exercise.recording.failed_save': 'စကရင် Recording ကို မသိမ်းနိုင်ပါ',
    'exercise.recording.saved_gallery': 'Gallery တွင် သိမ်းပြီး ({album})',
    'exercise.recording.saved_app': 'App storage တွင် သိမ်းပြီး: {path}',
    'exercise.recording.saved_phone': 'ဖုန်းသိုလှောင်မှုတွင် ဗီဒီယို သိမ်းပြီး',
    'exercise.recording.failed_video':
        'ဗီဒီယို Recording မအောင်မြင်ပါ: {error}',
    'exercise.recording.preparing_luxury_video':
        'သင့်အတွက် luxury workout video ကို ပြင်ဆင်နေပါတယ်။',
    'exercise.recording.keep_screen_open':
        'ကျေးဇူးပြု၍ ဒီ screen ကို ခဏဖွင့်ထားပေးပါ။',
    'exercise.premium.title': 'Premium လုပ်ဆောင်ချက်',
    'exercise.premium.not_now': 'မဟုတ်သေး',
    'exercise.premium.upgrade': 'Upgrade',
    'exercise.premium.required_title': 'Premium လိုအပ်သည်',
    'exercise.premium.required_message':
        'လေ့ကျင့်မှု သိမ်းဆည်းခြင်း၊ ကောင့်ရေတွက်ခြင်းနှင့် တိုးတက်မှုကို Premium တွင်သာ ရနိုင်သည်။',
    'exercise.camera.error_title': 'ကင်မရာ အမှား',
    'exercise.camera.error_message':
        'ကင်မရာကို စတင်မရပါ။ ခွင့်ပြုချက် စစ်ပြီး ပြန်ကြိုးစားပါ။',
    'exercise.counting_premium': 'ကောင့် (Premium)',
    'exercise.summary.title': 'လေ့ကျင့်မှု ပြီးဆုံးပြီ!',
    'exercise.summary.total_reps': 'လေ့ကျင့်ခန်းအချက်ရေ စုစုပေါင်း',
    'exercise.summary.avg_accuracy': 'ပျမ်းမျှ တိကျမှု',
    'exercise.summary.duration': 'ကြာချိန်',
    'exercise.summary.seconds': '{value} စက္ကန့်',
    'exercise.summary.best_accuracy': 'အကောင်းဆုံး တိကျမှု',
    'exercise.summary.close': 'ပိတ်',
    'exercise.summary.view_details': 'သိမ်းမယ်',
    'exercise.card.type.dynamic': 'Dynamic',
    'exercise.card.type.static': 'Static',
    'exercise.card.view.front': 'ရှေ့မြင်ကွင်း',
    'exercise.card.view.side': 'ဘေးမြင်ကွင်း',
    'exercise.card.total_reps': 'စုစုပေါင်း လေ့ကျင့်ခန်းအချက်ရေ',
    'exercise.card.avg_accuracy': 'ပျမ်းမျှ တိကျမှု',
    'exercise.card.select': 'လေ့ကျင့်ခန်းရွေးပါ',
    'exercise.time.today': 'ယနေ့',
    'exercise.time.yesterday': 'မနေ့က',
    'exercise.time.days_ago': '{value} ရက်အရင်',
    'exercise.time.weeks_ago': '{value} ပတ်အရင်',
    'exercise.time.months_ago': '{value} လအရင်',
    'guide.squat.subtitle':
        'ရင်ခွင်ကို ထောင်ထားပြီး တင်ပါးနောက်ဖက်ရွှေ့ကာ မိုက်ခုံးကို ခြေဖျားအောက်ပေါ်တန်းတည်ထားပါ။',
    'guide.squat.step1':
        'ခြေတံခွန်ကို လက်ခုံအကွာအဝေးနဲ့ ရပ်ပြီး အစာခန္ဓာကို တင်းထားပါ။',
    'guide.squat.step2':
        'ခြေခလုတ်ကို မမြှောက်ပဲ တင်ပါးကို အောက်သို့ ချပြီး ခြေထောက်သားများ အစွန်းအနားနီးပါး အဆင့်အထိ ချပါ။',
    'guide.squat.step3':
        'ခြေခလုတ်ဖြင့် တွန်း၍ မိုက်ခုံးကို လော့ခ်မလုပ်ဘဲ ထပြန်ပါ။',
    'guide.pushup.subtitle':
        'ဉီးမှ ခြေဖျားအထိ တန်းတစ်ကြောင်းလိုထားပြီး ပြန်လုပ်မှုတိုင်းကို ထိန်းချုပ်ပါ။',
    'guide.pushup.step1':
        'လက်များကို လက်ခုံထက် အနည်းငယ်ကျယ်စွာထားပြီး high plank နဲ့ စတင်ပါ။',
    'guide.pushup.step2': 'လက်ခုံကို 45 ဒီဂရီခန့် ချိုး၍ ရင်ဘတ်ကို အောက်ချပါ။',
    'guide.pushup.step3':
        'အစာခန္ဓာကို တင်းထားပြီး တင်ပါးကို တန်းတည်းထားကာ အပေါ်သို့ တွန်းတင်ပါ။',
    'guide.situp.subtitle':
        'လည်ပင်းကို မဆွဲဘဲ ခန္ဓာဗဟိုကို ထိန်းချုပ်အသုံးပြုပါ။',
    'guide.situp.step1':
        'နောက်ကျောပေါ်အိပ်၍ ဒူးကို ခေါက်ပြီး ခြေဖဝါးကို မြေပြင်ပေါ်ထားပါ။',
    'guide.situp.step2':
        'ဝမ်းဗိုက်ကို တင်းတင်ပြီး ကိုယ်ခန္ဓာကို အပေါ်သို့ ထမ်းပါ။',
    'guide.situp.step3': 'နောက်ဆုံးပြန်ချပြီး နောက်တစ်ကြိမ်အတွက် ထိန်းချုပ်ပါ။',
    'guide.bicep.subtitle':
        'တံတောင်ကို ကိုယ်နားမှာထားပြီး လှုပ်ယမ်းခြင်းကို ရှောင်ပါ။',
    'guide.bicep.step1':
        'ဒမ်ဘဲလ်ကို ကိုင်ပြီး လက်ဖဝါးကို ရှေ့သို့ မျက်နှာမူကာ ရပ်ပါ။',
    'guide.bicep.step2': 'ပခုံးမလှုပ်ဘဲ တံတောင်ချိုး၍ အလေးချိန်ကို မြှောက်ပါ။',
    'guide.bicep.step3': 'အလေးချိန်ကို အပြည့်တန်အောင် တဖြည်းဖြည်း ပြန်ချပါ။',
    'guide.shoulder.subtitle':
        'အူခေါင်းကို ချထားပြီး ခန္ဓာဗဟိုကို တင်းထားကာ အပေါ်သို့ တန်းတန်းတင်ပါ။',
    'guide.shoulder.step1': 'ပခုံးအမြင့်မှာ စတင်ပြီး လက်မောင်းကို တန်းထားပါ။',
    'guide.shoulder.step2': 'ခေါင်းအပေါ်သို့ လက်များတန်းတန်းတင်ပါ။',
    'guide.shoulder.step3': 'ပခုံးအမြင့်သို့ ထိန်းချုပ်ကာ ပြန်ချပါ။',
    'guide.leg.subtitle':
        'လှုပ်ရှားမှုအကွာအဝေးကို ထိန်းချုပ်ပြီး ဒူးကို တင်းတိတ်မလုပ်ပါနှင့်။',
    'guide.leg.step1':
        'ကျောကို ထောက်ထားပြီး ခြေထောက်များကို ပတ်ထိုးကူညီမှုအောက်မှာ ထားပါ။',
    'guide.leg.step2':
        'တင်ပါးကို တည်ငြိမ်ထားကာ ဒူးကို တိုးချ၍ ပတ်ထိုးကူညီမှုကို မြှောက်ပါ။',
    'guide.leg.step3':
        'ဒူးကို ခေါက်ပြီး တဖြည်းဖြည်း ပြန်ချပါ၊ ထို့နောက် ပြန်လုပ်ပါ။',
    'settings.title': 'ဆက်တင်',
    'settings.premium_features': 'Premium လုပ်ဆောင်ချက်များ',
    'settings.app_settings': 'အက်ပ်ဆက်တင်',
    'settings.profile_name': 'ပရိုဖိုင် နာမည်',
    'settings.appearance': 'ပုံပန်းသဏ္ဌာန်',
    'settings.data': 'ဒေတာ',
    'settings.about': 'အကြောင်း',
    'settings.premium_account': 'Premium အကောင့်',
    'settings.unlock_all_features': 'Premium လုပ်ဆောင်ချက်များအားလုံး ဖွင့်ပါ',
    'settings.voice_counting': 'အသံဖြင့် ကောင့်',
    'settings.speak_count': 'ပြန်လုပ်မှုအခါတိုင်း ကောင့်ကို အသံဖြင့်ပြော',
    'settings.voice_counting_language': 'အသံကောင့် ဘာသာ',
    'settings.upgrade_to_premium': 'Premium သို့ တင်မြှင့်',
    'settings.upgrade_subtitle':
        'အသံကောင့်၊ ဗီဒီယိုမှတ်တမ်း နှင့် အခြား အင်္ဂါရပ်များ ရယူပါ',
    'settings.voice_coach': 'Voice Coach',
    'settings.voice_feedback': 'အချိန်နှင့်တပြေးညီ အသံဖျော်ဖြေရေး',
    'settings.show_landmarks': 'Landmarks ပြ',
    'settings.display_skeleton': 'Skeleton overlay ပြ',
    'settings.auto_recording': 'အလိုအလျောက် Recording',
    'settings.auto_recording_subtitle':
        'လေ့ကျင့်မှုကို အလိုအလျောက် Recording လုပ်',
    'settings.theme': 'Theme',
    'settings.language': 'ဘာသာ',
    'settings.language_subtitle': 'အက်ပ် ဘာသာ ပြောင်း',
    'settings.clear_data': 'ဒေတာ ဖျက်',
    'settings.clear_data_subtitle': 'လေ့ကျင့်မှုသမိုင်းအားလုံး ဖျက်',
    'settings.version': 'ဗားရှင်း',
    'settings.privacy_policy': 'ကိုယ်ရေးအချက်အလက် မူဝါဒ',
    'settings.terms': 'သုံးစွဲမှုစည်းမျဉ်းများ',
    'settings.disclaimer': 'တာဝန်မခံချက်',
    'legal.last_updated': 'နောက်ဆုံးပြင်ဆင်သည့်ရက်: {date}',
    'legal.privacy.content':
        '1) ကျွန်ုပ်တို့လုပ်ဆောင်သောဒေတာများ\n'
        'H&F သည် လေ့ကျင့်ခန်းမှတ်တမ်းများ၊ ဘတ်ဂျ်တိုးတက်မှု၊ အက်ပ်ရွေးချယ်မှုများနှင့် တစ်ချို့သော မှတ်တမ်းဖိုင်လမ်းကြောင်းများကို သင့်စက်၌ သိမ်းဆည်းထားသည်။\n\n'
        '2) ပရီမီယမ်ဖွင့်လှစ်ခြင်း\n'
        'ပရီမီယမ်ကို တစ်ကြိမ်သာအနည်းဆုံး အင်တာနက်လိုအပ်သည်။ လုပ်ဆောင်ရာတွင် လိုင်စင် ကီး၊ စက်နဲ့ သတ်မှတ်ချက် hash၊ အက်ပ်ဗားရှင်းနဲ့ ပလက်ဖောင်းကို ကျွန်ုပ်တိုဆာဗာသို့ ပို့ပေးသည်။ ဖွင့်လှစ်ပြီးနောက် ပရီမီယမ်ခွင့်ကို မိမိစက်အတွင်းသာစစ်ဆေးပြီး အော့ဖ်လိုင်းအသုံးပြုနိုင်သည်။\n\n'
        '3) ကင်မရာ၊ မိုက်ကရိုဖုံး၊ သိုလှောင်မှုနှင့် လုပ်ဆောင်နိုင်စွမ်း\n'
        'ကင်မရာကို အနေအထားဖော်ထုတ်ရန် အသုံးပြုသည်။ အနေအထားကို ခွဲခြမ်းစိတ်ဖြာရန် သင့်စက်၏ လုပ်ဆောင်နိုင်စွမ်းကို အသုံးပြုသည်။ မိုက်ကရိုဖုံးနဲ့ မျက်နှာပြင် မှတ်တမ်းခွင့်ပြုချက်များကို မှတ်တမ်းအင်္ဂါရပ်အသုံးပြုသည့်အခါသာ လိုအပ်သည်။ သိမ်းထားသော ဗီဒီယိုများသည် သင်၏စက် သို့မဟုတ် ဂယ်လရီ၌ စုံလင်နေပါသည်။\n\n'
        '4) ဒေတာကို မည်သို့ အသုံးပြုသနည်း\n'
        'ဒေတာကို အလှည့်အပြောင်းများတွက်ရန်၊ တိကျမှုကိုတွက်ရန်၊ တိုးတက်မှုကို ချိန်ဆွဲရန်၊ ဘတ်ဂျ်ဖွင့်ရန်နှင့် ပရီမီယမ်စနစ်များပေးရန် အသုံးပြုသည်။\n\n'
        '5) မျှဝေခြင်း\n'
        'သင်၏ကိုယ်ရေးကိုယ်တာဒေတာကို ရောင်းချခြင်း မရှိပါ။ လိုင်စင်ပြန်လည်စစ်ဆေးမှုဒေတာကို ပရီမီယမ်ရယူခြင်းနှင့် ကာကွယ်ရန်သာ ပြုလုပ်သည်။\n\n'
        '6) သင်၏ထိန်းချုပ်မှု\n'
        'သင်သည် အချိန်မရွေး ဒေတာအားလုံး ဖျက်ပစ် သို့မဟုတ် အက်ပ်ဖယ်ရှားနိုင်ပါသည်။ ဒေတာဖျက်ခြင်းသည် ဖုန်းတွင်းသိမ်းထားသော ကျွန်တော်တို့app နှင့်ဆိုင်သောမှတ်တမ်းများနှင့် သိမ်းဆည်းထားသော ပရီမီယမ်အခြေအနေကို ဖျက်သိမ်းပါသည်။\n\n'
        '7) လုံခြုံရေး\n'
        'အက်ပ်သည် မတရားဖျက်မှုများကို လျှော့ချရန် အပြည့်အဝစစ်ဆေးမှုနှင့် လုံခြုံသော စက်တွင်းသိမ်းဆည်းမှုကိုအသုံးပြုသည်၊ သို့သော် ဘယ်စနစ်မှလည်း အပြည့်အဝလုံခြုံမှုမရှိနိုင်ပါ။',
    'legal.terms.content':
        'H&F ကို အသုံးပြုခြင်းအားဖြင့် ဤစည်းမျဉ်းများကို သင်လက်ခံပါသည်။\n\n'
        '1) ဝန်ဆောင်မှုအသုံးပြုခြင်း\n'
        'H&F သည် ကျန်းမာရေးအထောက်အကူဖြစ်သည့် အက်ပ်ဖြစ်သည်။ သင်သည် သင့်လုံခြုံမှုနှင့် ကျန်းမာရေးဆိုင်ရာဆုံးဖြတ်ချက်များအတွက် တာဝန်ယူရပါမည်။\n\n'
        '2) အကောင့်နှင့် လိုင်စင်\n'
        'ပရီမီယမ်အတွက် တရားဝင် လိုင်စင်ကီးလိုအပ်သည်။ လိုင်စင်များကို စက်အလိုက် ကန့်သတ်ထားပြီး၊ စက်တစ်လုံးထက်ပိုတဲ့သုံးစွဲမှု၊ စီစစ်မှု ငြင်းချခြင်း၊ သို့မဟုတ် လုံခြုံရေးဖောက်ထွင်းမှုပြုလုပ်မိခြင်းကြောင့် ရုပ်သိမ်းခံရနိုင်သည်။\n\n'
        '3) အော့ဖ်လိုင်းနည်း\n'
        'အောင်မြင်စွာဖွင့်လှစ်ပြီးနောက် အခြေခံလုပ်ဆောင်ချက်များနှင့် ပရီမီယမ်လုပ်ဆောင်ချက်များကို တစ်ခုတည်းသော စက်မှ အော့ဖ်လိုင်းဖြင့် အသုံးပြုနိုင်သည်။ ထပ်မံတပ်ဆင်ခြင်း၊ ကိုယ်ရေးကိုယ်တာဒေတာ ဖျက်ခြင်း သို့မဟုတ် လုံခြုံရေးစစ်ဆေးမှု မအောင်မြင်မှုများကြောင့် ထပ်မံအွန်လိုင်းဖွင့်လှစ်ရန် လိုအပ်နိုင်သည်။\n\n'
        '4) ကန့်သတ်ချက်များ\n'
        'လုံခြုံရေးကို လှည့်လည်ပြောင်းလဲခြင်း၊ လိုင်စင် ပြုလုပ်ခြင်းကိုနောက်ကြောင်းပြန်လိုက်၍ ဖော်ထုတ်ခြင်း သို့မဟုတ် တရားမဝင် လုပ်ငန်းများအတွက် အသုံးပြုခြင်း မပြုရ။\n\n'
        '5) မူပိုင်ခွင့်\n'
        'အက်ပ်ဆော့ဖ်ဝဲ၊ ဘရန်းနဲ့ အကြောင်းအရာများသည် H&F နှင့် ထိုလိုင်စင်ရှင်များ၏ ပိုင်ဆိုင်မှုဖြစ်သည်။\n\n'

        '6) အာမခံ မရှိခြင်း\n'
        'အက်ပ်ကို "လက်ရှိအခြေအနေဖြင့်" ပေးသည်၊ ချွတ်ယွင်းမှုလုံးဝမရှိဟုအာမမခံပါ. သတ်မှတ်ထားသော ကျန်းမာရေးရလဒ်ကို မသေချာနိုင်ပါ။ အကြောင်းအမျိုးမျိုးကြောင့် အက်ပ်ကောင်တာသည် ပိုတွက်မိခြင်း သို့မဟုတ် လျော့တွက်မိခြင်း ဖြစ်နိုင်ပါသည်။\n\n'
        '7) တာဝန်ကန့်သတ်ခြင်း\n'
        'H&F သည် အက်ပ်ကို အသုံးပြုသောကြောင့် ဖြစ်ပေါ်လာသည့် အလယ်အလတ်၊ ချို့ယွင်းမှု သို့မဟုတ် အကျိုးသက်ရောက်မှု ပျက်ကွက်မှုများအတွက် တာဝန်မယူပါ။',
    'legal.disclaimer.content':
        'H&F သည် ဆေးဘက်ဆိုင်ရာ ဝန်ဆောင်မှု မဟုတ်သဖြင့် ဆေးဘက်ဆိုင်ရာ အကြံပြုချက်၊ ရာဂါသိခြင်း သို့မဟုတ် ကုသမှု မပေးပါ။\n\n'
        '1) လေ့ကျင့်မှု ဒဏ်ရာအန္တရာယ်\n'
        'လေ့ကျင့်မှုတွင် ထိခိုက်ဒဏ်ရာရနိုင်ချေ ရှိသည်။ နာကျင်မှု၊ မူးဝါးမှု၊ အသက်ရှုပြဿနာ သို့မဟုတ် မမျှော်လင့်ရသည့် ခံစားချက်တွေ့ရပါက ချက်ချင်းရပ်လိုက်ပါ၊ အရည်အချင်းရှိပညာရှင်တစ်ဦးအား တိုင်ပင်ပါ။\n\n'
        '2) AI ကိန်းဂဏန်းနှင့် ရှေ့စွာပြန်လည်သုံးသပ်မှု\n'
        'အနေအထားပြန်လည်သိရှိခြင်းနှင့် အလှည့်အပြောင်းအရေအတွက် တစ်ခုချင်းစီသည် အတတ်နိုင်ဆုံးကောင်းမွန်စွာတွက်ချက်ခန့်မှန်းထားတာဖြစ်ပြီး ကင်မရာ ထောင့်ခြား၊ မီးရောင်ခြည်၊ အတားအဆီး၊ အ၀တ်အစား သို့မဟုတ် လှုပ်ရှားမှု အရှိန်ကြောင့် အမှား ဖြစ်နိုင်သည်။\n\n'
        '3) မှတ်တမ်းတင်မှုနှင့် စွမ်းဆောင်ရည်\n'
        'ဖုန်းဖွင့်ပြီး လေ့ကျင့်ခန်းလုပ်ရာမှာ counting/voice counting ကို ကောင်းကောင်းလုပ်နိုင်အောင် ဖန်တီးထားပါတယ်။ Pose detection (counting) နဲ့ video recording ကို တပြိုင်တည်းလုပ်နိုင်အောင်လည်း စနစ်တကျ ပြုလုပ်ထားပါတယ်။ သို့သော်ပုံမှန်အသုံးပြုမှု(လေ့ကျင့်ခန်းလုပ်ရင်း ရေတွက်ခြင်း)မှာ ကောင်းမွန်စွာ လုပ်ဆောင်နိုင်သော်လည်း အဲ့ထက်ပိုပြီးpose detection(counting)+video recording ကို ဆက်တိုက် ၅–၁၅ မိနစ်ခန့်ထက်ကျော်ပြီး အသုံးပြုပါက ဖုန်းအပူတက်ခြင်း၊ ဘတ်ထရီကုန်မြန်ခြင်းနှင့် တိကျမှုကျခြင်း ဖြစ်နိုင်ပါသည်။\n\n'
        '4) အရေးပေါ် အခြေအနေများ\n'
        'အရေးပေါ် အခြေအနေများအတွက် ဤအက်ပ်ကို မပြုလုပ်ထားပါ။ လိုအပ်လျှင် ဒေသခံ အရေးပေါ် ဝန်ဆောင်မှုများကို ချက်ချင်းဆက်သွယ်ပါ။\n\n'
        '5) အသုံးပြုသူ၏ တာဝန်\n'
        'လုံခြုံသော လေ့ကျင့်ခန်းတည်နေရာ၊ မှန်ကန်သော နည်းလမ်းနှင့် လိုအပ်သည့် ဆေးဘက်ဆိုင်ရာ ကိစ္စရပ်များ ရယူခြင်းသည် အသုံးပြုသူ၏ တာဝန်ဖြစ်သည်။\n\n'
        '6) မှတ်တမ်းတင်ခြင်းနှင့် တခြားသူများ၏ ကိုယ်ရေးအချက်အလက်\n'
        'သင်သည် အလေ့အကျင့်များကို မှတ်တမ်းတင်သောအခါ ဗီဒီယို သို့မဟုတ် အသံထဲတွင် လာရောက်နိုင်သူများအား ခွင့်ပြုချက် ရယူထားရပါမည်။\n\n'
        '7) ရလဒ်များ\n'
        'ကျန်းမာရေးရလဒ်များသည် တစ်ဦးချင်းစီ အလိုက် မတူညီကြပါ။ H&F သည် သတ်မှတ်ထားသော စွမ်းဆောင်ရည် သို့မဟုတ် ကျန်းမာရေးရလဒ်များကို အာမခံ မလုပ်ပါ။',
    'legal.accepted_notice': '{date} တွင် သဘောတူပြီးပြီ။',
    'settings.select_theme': 'Theme ရွေး',
    'settings.select_language': 'ဘာသာ ရွေး',
    'onboarding.language_title': 'ဘာသာ ရွေးချယ်ပါ',
    'onboarding.language_subtitle': 'နောက်မှ Settings မှာ ပြောင်းလဲနိုင်ပါတယ်။',
    'onboarding.name_title': 'နာမည် ဘာလဲ?',
    'onboarding.name_subtitle': 'ဒီနာမည်ကို ပရိုဖိုင်မှာ ပြပါမယ်။',
    'onboarding.name_hint': 'နာမည် ရိုက်ထည့်ပါ',
    'onboarding.name_required': 'နာမည် ရိုက်ထည့်ပါ',
    'onboarding.disclaimer_title': 'သတိပေးချက်',
    'onboarding.terms_title': 'အသုံးပြုမှု စည်းကမ်းချက်များ',
    'onboarding.accept_notice':
        'အက်ပ်ကို ဆက်လက်အသုံးပြုရန် သဘောတူရန်လိုပါသည်။',
    'onboarding.accept_checkbox': 'သဘောတူပါသည်',
    'onboarding.continue': 'ဆက်လက်',
    'onboarding.start_app': 'အက်ပ်စတင်ရန်',
    'settings.clear_all_data': 'ဒေတာအားလုံး ဖျက်',
    'settings.clear_all_data_desc':
        'သင့်လေ့ကျင့်မှုသမိုင်း၊ အောင်မြင်မှုများနှင့် ဆက်တင်များအားလုံး ဖျက်မည်ဖြစ်ပြီး ပြန်မရနိုင်ပါ။',
    'settings.clear_success': 'အသုံးပြုသူဒေတာအားလုံး ဖျက်ပြီးပြီ။',
    'settings.clear_failed': 'ဒေတာ ဖျက်မအောင်မြင်: {error}',
    'theme.light': 'အလင်း',
    'theme.dark': 'မှောင်',
    'theme.gold': 'ရွှေရောင်',
    'theme.pink': 'ပန်းရောင်',
    'progress.title': 'တိုးတက်မှုနှင့် ခွဲခြမ်းသုံးသပ်ချက်',
    'progress.overview': 'အကျဉ်းချုပ်',
    'progress.exercises': 'လေ့ကျင့်ခန်းများ',
    'progress.badges': 'အမှတ်တံဆိပ်များ',
    'progress.no_data': 'ဒေတာ မရှိပါ',
    'progress.weekly_summary': 'အပတ်စဉ် အကျဉ်းချုပ်',
    'progress.streak_days': '{count} ရက်ဆက်',
    'progress.recent_workouts': 'မကြာသေးမီ လေ့ကျင့်မှုများ',
    'progress.no_workouts': 'လေ့ကျင့်မှု မရှိသေးပါ',
    'progress.workout_summary': '{reps} reps • တိကျမှု {accuracy}%',
    'progress.achievements': 'အောင်မြင်မှုများ',
    'progress.badges_unlocked': '{unlocked}/{total} အမှတ်တံဆိပ်များ ဖွင့်ပြီး',
    'progress.view_all_achievements': 'အောင်မြင်မှုအားလုံး ကြည့်ရန်',
    'progress.day.sun': 'တနင်္ဂနွေ',
    'progress.day.mon': 'တနင်္လာ',
    'progress.day.tue': 'အင်္ဂါ',
    'progress.day.wed': 'ဗုဒ္ဓဟူး',
    'progress.day.thu': 'ကြာသပတေး',
    'progress.day.fri': 'သောကြာ',
    'progress.day.sat': 'စနေ',
    'progress.time.just_now': 'အခုလေးတင်',
    'progress.time.minutes_ago': '{value} မိနစ်က',
    'progress.time.hours_ago': '{value} နာရီက',
    'progress.time.days_ago': '{value} ရက်က',
    'progress.time.weeks_ago': '{value} ပတ်က',
    'progress.analytics_intro_title':
        'လေ့ကျင့်ခန်း အချက်အလက်များကို ဘယ်လိုနားလည်မလဲ',
    'progress.analytics_intro_line1':
        'စုစုပေါင်း Reps = ဒီလေ့ကျင့်ခန်းအတွက် သိမ်းထားသော session အားလုံးထဲက လေ့ကျင့်ခန်းအချက်ရေ စုစုပေါင်း။',
    'progress.analytics_intro_line2':
        'ပျမ်းမျှ တိကျမှု = သိမ်းထားသော session အားလုံး၏ ပုံစံတိကျမှု ပျမ်းမျှ။',
    'progress.analytics_intro_line3':
        'Trend chart = အချိန်တစ်လျှောက် တိကျမှု (လိုင်းမြင့်လျှင် ပုံစံကောင်းသည်)။',
    'progress.analytics_intro_line4':
        'Analytics သည် workout session ကို save လုပ်ပြီးမှသာ update ဖြစ်သည်။',
    'progress.read_exercise_analytics_title':
        'လေ့ကျင့်ခန်း ခွဲခြမ်းသုံးသပ်ချက်ကို ဘယ်လိုဖတ်မလဲ',
    'progress.read_exercise_analytics_line1':
        'နောက်ဆုံး တိကျမှု = မကြာသေးမီ session ရဲ့ form score။',
    'progress.read_exercise_analytics_line2':
        'အကောင်းဆုံး တိကျမှု = ယခုအချိန်ထိ အမြင့်ဆုံး score။',
    'progress.read_exercise_analytics_line3':
        'Session bar များက နောက်ဆုံး 6 sessions ကို ပြသည်။ Bar မြင့်လေလေ တိကျမှုကောင်းလေလေ။',
    'progress.read_exercise_analytics_line4':
        'Bar တစ်ခုစီအောက်က ကိန်းဂဏန်းက အဲဒီ session ရဲ့ reps အရေအတွက် ဖြစ်သည်။',
    'progress.latest_accuracy': 'နောက်ဆုံး တိကျမှု',
    'progress.best_accuracy': 'အကောင်းဆုံး တိကျမှု',
    'progress.trend_vs_previous_session':
        'ယခင် session နှင့် နှိုင်းယှဉ် {sign}{delta}%',
    'progress.last_sessions_accuracy_title': 'နောက်ဆုံး Sessions (တိကျမှု %)',
    'progress.reps_short': 'reps',
    'progress.chart_accuracy_trend_legend':
        'Bar မြင့်လေလေ တိကျမှုကောင်းလေလေ။ အောက်က label က session တစ်ခုချင်းစီရဲ့ reps ဖြစ်သည်။',
    'progress.total_reps_all_time': 'စုစုပေါင်း Reps (စလုပ်ချိန်မှယခုအထိ)',
    'progress.avg_accuracy_all_sessions': 'ပျမ်းမျှ တိကျမှု (sessions အားလုံး)',
    'progress.sessions': 'Sessions',
    'progress.chart_accuracy_trend':
        'Chart သည် session နေ့ရက်အလိုက် တိကျမှု လမ်းကြောင်းပြသည်။',
    'progress.no_sessions':
        'Session မရှိသေးပါ။ Workout ကို save လုပ်ပြီးမှ analytics ကို မြင်နိုင်သည်။',
    'badges.empty':
        'အမှတ်တံဆိပ် မရှိသေးပါ။\nလေ့ကျင့်မှုစတင်ပြီး ပထမမိုင်လ်စတိုင်းကို ဖွင့်ပါ။',
    'badges.collection': 'သင့် အမှတ်တံဆိပ်စုစည်းမှု',
    'badges.current_status': 'လက်ရှိ အမှတ်တံဆိပ် အခြေအနေ',
    'badges.unlocked_count': '{unlocked}/{total} အမှတ်တံဆိပ်များ ဖွင့်ပြီး',
    'badges.tier': 'အဆင့်: {tier}',
    'badges.next_target':
        'နောက်ထပ်ရည်မှန်းချက်: {name} ({progress}/{requirement}) - စုစုပေါင်း {percent}% ပြီး',
    'badges.how_it_works': 'ဒီအမှတ်တံဆိပ်စနစ် ဘယ်လိုအလုပ်လုပ်လဲ',
    'badges.guide_1':
        'အမှတ်တံဆိပ်များသည် 5 ရက် လှုပ်ရှား + 2 ရက် နား စနစ်ဖြစ်သည်။ လှုပ်ရှားရက်များသာ တိုးတက်မှုတွက်ပါ။',
    'badges.guide_2':
        'နားရက်တွင် လေ့ကျင့်မှုကို သာမန်အတိုင်း သိမ်းထားသော်လည်း တိုးတက်မှုမတိုး/မလျော့ပါ။',
    'badges.guide_3':
        'နေ့စဉ်ရည်မှန်းချက်တွင် အကန့်အသတ်ရှိသည်။ အကန့်အသတ်ကျော်တဲ့ Reps/sets တွေလုပ်ရင်လည်းအမှတ်တံဆိပ်ပိုမပေးပါ.။',
    'badges.guide_4':
        'ဒမ်ဘဲလ်/စက် မလိုပါ။ အစားထိုးလုပ်ဆောင်ချက်ဖြင့်လည်းအလေးတုံးတွေ/စက်တွေမလိုဘဲ အမှတ်တံဆိပ်ရနိုင်သည် (Upper အတွက် push-ups, Lower အတွက် squats စသည်)။',
    'badges.guide_5':
        'တိုးတက်မှုကို သိမ်းထားသော workout logs မှတွက်သည်။ အမှန်တကယ်လုပ်ဆောင်ထားသောဒေတာဖြင့်သာအမှတ်တံဆိပ်ကို ဖွင့်လှစ်သည်။',
    'badges.unlocked_on': '{date} တွင် ဖွင့်ပြီး',
    'badges.tap_full_plan': 'အစီအစဉ်အပြည့် ကြည့်ရန် ထိပါ',
    'badges.new_unlock_today': 'ဒီနေ့ ဖွင့်ပြီး! ကောင်းပါတယ်။',
    'badges.unlocked_banner':
        'ဖွင့်ပြီး! တည်မြဲမှု အလွန်ကောင်းပါတယ်။ ဆက်ပြီး ထိန်းပါ။',
    'badges.poster_saved_note':
        'Badge ပိုစတာကို gallery album {album} ထဲသို့ အလိုအလျောက် သိမ်းပြီးပါပြီ။',
    'badges.poster_save_failed_note':
        'Badge ပိုစတာကို gallery ထဲ မသိမ်းနိုင်ပါ။ Photo permission ကို စစ်ပါ။',
    'badges.no_tier': 'အဆင့် မဖွင့်ရသေးပါ',
    'badges.motivation_unlocked':
        'ကောင်းပါတယ်။ ဒီအမှတ်တံဆိပ်ကို ရပြီးနောက် နောက်အဆင့်ကို ပြန်တိုးပါ။',
    'badges.motivation_almost':
        'နီးပြီ။ နောက်ထပ် {remaining} ရက် အရည်အချင်းရရှိရင် ဖွင့်နိုင်ပါသည်။',
    'badges.motivation_keep':
        'တည်ငြိမ်ထားပါ။ အရည်အချင်းရက်တိုင်းက တိုးတက်မှုကို တက်စေသည်။',
    'tier.bronze': 'ကြေး',
    'tier.silver': 'ငွေ',
    'tier.gold': 'ရွှေ',
    'tier.platinum': 'ပလက်တီနမ်',
    'badge.first_workout.name': 'ပထမအဆင့်များ',
    'badge.first_workout.narrative':
        'အရည်အချင်းရရှိရန် ပထမနေ့လေ့ကျင့်မှုကို ပြီးအောင်လုပ်ပါ။',
    'badge.first_workout.detail1':
        'ရည်မှန်းချက်:  1 ရက်အတွင်းအောက်ပါသတ်မှတ်ထားတဲ့အတိုင်းပီးအောင်လုပ်ပါ။',
    'badge.first_workout.detail2':
        'Upper ရည်မှန်းချက်: စုစုပေါင်း 8 reps (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise)।',
    'badge.first_workout.detail3':
        'Core ရည်မှန်းချက်: စုစုပေါင်း 10 reps (Sit-up)।',
    'badge.first_workout.detail4':
        'Lower ရည်မှန်းချက်: စုစုပေါင်း 12 reps (Squat / Leg Extension)(တစ်ခုမဟုတ်တစ်ခု)।',
    'badge.prep.name': '15-ရက် ပြင်ဆင်မှု',
    'badge.prep.narrative': '15-ရက် ပြင်ဆင်မှု စနစ်ဖြင့် တည်မြဲမှု တည်ဆောက်ပါ။',
    'badge.prep.detail1':
        '5 ရက် လှုပ်ရှား + 2 ရက် နား စက်ဝန်းဖြင့် 15 ရက် ပြင်ဆင်မှု (6-7 ရက်နှင့် 13-14 ရက်သည် နားရက်)။',
    'badge.prep.detail2':
        '1-3 ရက်: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': '4-5 ရက်: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': '8-12 ရက်: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': '15 ရက်: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = တစ်ရက်အတွင်း အမျိုးအစားအလိုက် သိမ်းထားသော sessions အရေအတွက်။ နားရက်များသည် တိုးတက်မှုမတက်ပါ။',
    'badge.prep.detail8':
        'လှုပ်ရှားရက် (workout day) တစ်ရက်ပျက်သွားရင် prep progress ကို reset လုပ်ပြီး နောက်တစ်ကြိမ် လေ့ကျင့်တဲ့နေ့က Day 1 အဖြစ် ပြန်စပါမယ်။',
    'badge.bronze.name': 'လ 1 ကြေး',
    'badge.bronze.narrative': 'အပြည့်အစုံ စနစ်အတွက် အခြေခံလ။',
    'badge.bronze.detail1':
        '5 လှုပ်ရှား + 2 နား စက်ဝန်းဖြင့် အရည်အချင်းရက် 30 ရက်။',
    'badge.bronze.detail2':
        'Upper နေ့စဉ်: 18 reps + 3 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise ပေါင်းစည်း)။',
    'badge.bronze.detail3': 'Core နေ့စဉ်: 24 reps + 3 sets (Sit-up)။',
    'badge.bronze.detail4':
        'Lower နေ့စဉ်: 30 reps + 3 sets (Squat / Leg Extension ပေါင်းစည်း)။',
    'badge.bronze.detail5': 'နေ့စဉ် အကန့်အသတ်ကျော် Reps/Sets မပါဝင်ပါ။',
    'badge.bronze.detail6':
        'တစ်ရက်ပျက်ကွက်သွားရင်တောင် Day 1 ကနေ အစပြန်စရာမလိုပါ။',
    'badge.silver.name': 'လ 2 ငွေ',
    'badge.silver.narrative': 'ပိုမိုမြင့်မားတဲ့ ပမာဏလိုအပ်သည့် တိုးတက်မှုလ။',
    'badge.silver.detail1':
        '5 လှုပ်ရှား + 2 နား စက်ဝန်းဖြင့် အရည်အချင်းရက် 30 ရက်။',
    'badge.silver.detail2':
        'Upper နေ့စဉ်: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise ပေါင်းစည်း)။',
    'badge.silver.detail3': 'Core နေ့စဉ်: 32 reps + 4 sets (Sit-up)။',
    'badge.silver.detail4':
        'Lower နေ့စဉ်: 40 reps + 4 sets (Squat / Leg Extension ပေါင်းစည်း)။',
    'badge.silver.detail5':
        'လှုပ်ရှားရက်များသာ တိုးတက်မှုတွက်ပါတယ်။ နားရက်ကို မတွက်ပါ။',
    'badge.silver.detail6':
        'တစ်ရက်ပျက်ကွက်သွားရင်တောင် Day 1 ကနေ အစကပြန်စစရာမလိုပါ။',
    'badge.gold.name': 'လ 3 ရွှေ',
    'badge.gold.narrative': 'ကြံ့ခိုင်သက်သာမှုမြင့် တက်စေသော လ။',
    'badge.gold.detail1':
        '5 လှုပ်ရှား + 2 နား စက်ဝန်းဖြင့် အရည်အချင်းရက် 30 ရက်।',
    'badge.gold.detail2':
        'Upper နေ့စဉ်: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise ပေါင်းစည်း)။',
    'badge.gold.detail3': 'Core နေ့စဉ်: 40 reps + 4 sets (Sit-up)။',
    'badge.gold.detail4':
        'Lower နေ့စဉ်: 50 reps + 4 sets (Squat / Leg Extension ပေါင်းစည်း)။',
    'badge.gold.detail5':
        'တိုးတက်မှုကို သိမ်းထားသော logs ဖြင့်တွက်ပြီး အကန့်အသတ်ကျော် Reps မတွက်ပါ။',
    'badge.gold.detail6':
        'တစ်ရက်ပျက်ကွက်သွားရင်တောင် Day 1 ကနေ အစပြန်စရာမလိုပါ။',
    'badge.default.goal': 'ရည်မှန်းချက်: {description}',
    'badge.default.requirement': 'လိုအပ်ချက်: အရည်အချင်းရက် {requirement} ရက်။',
    'badge.default.status': 'လက်ရှိ: {progress}/{requirement}.',
    'badge.poster.badge_label': 'Badge',
    'badge.poster.user_label': 'ရရှိသူ',
    'badge.poster.requirements_label': 'အရည်အချင်း ဒေတာ',
    'leaderboard.title': 'Leaderboard',
    'leaderboard.achievements': 'အောင်မြင်မှုများ',
    'leaderboard.global': 'ကမ္ဘာလုံးဆိုင်ရာ',
    'leaderboard.achievement_progress': 'အောင်မြင်မှု တိုးတက်မှု',
    'leaderboard.personal_bests': 'ကိုယ်ရေးအကောင်းဆုံး',
    'leaderboard.most_reps': 'Reps အများဆုံး',
    'leaderboard.best_accuracy': 'အကောင်းဆုံး တိကျမှု',
    'leaderboard.longest_streak': 'အရှည်ဆုံး ဆက်တိုက်',
    'leaderboard.days': 'ရက်',
    'leaderboard.global_simulated': 'ကမ္ဘာလုံးဆိုင်ရာ Leaderboard (စမ်းသပ်)',
    'leaderboard.points': '{score} မှတ်',
    'recordings.tab.recordings': 'မှတ်တမ်း',
    'recordings.tab.profile': 'ပရိုဖိုင်',
    'recordings.failed_load': 'Recording မတင်နိုင်ပါ',
    'recordings.empty': 'သိမ်းထားသော ဗီဒီယိုမရှိပါ',
    'recordings.file_not_found': 'ဗီဒီယိုဖိုင် မတွေ့ပါ',
    'recordings.file_incomplete': 'Recording ဖိုင် မပြည့်စုံပါ။ ပြန်မှတ်ပါ။',
    'profile.guest_name': 'အသုံးပြုသူ',
    'profile.user_name_label': 'အသုံးပြုသူ နာမည်',
    'profile.edit_name': 'ပြင်မည်',
    'profile.name_hint': 'နာမည် ရိုက်ထည့်ပါ',
    'profile.save_name': 'သိမ်းမည်',
    'profile.photo_title': 'ပရိုဖိုင် ဓာတ်ပုံ',
    'profile.photo_subtitle':
        'ကိုယ်လုံးပြည့်ပုံကိုထည့်ပြီး ပရိုဖိုင်ကို ကိုယ်ပိုင်အောင်လုပ်ပါ။',
    'profile.photo_add': 'ဓာတ်ပုံ ထည့်မည်',
    'profile.photo_change': 'ဓာတ်ပုံ ပြောင်းမည်',
    'profile.photo_remove': 'ဓာတ်ပုံ ဖယ်မည်',
    'profile.photo_remove_confirm': 'ပရိုဖိုင် ဓာတ်ပုံကို ဖယ်ရှားမလား?',
    'profile.photo_too_large':
        'ဓာတ်ပုံ အရွယ်အစားကြီးနေပါတယ်။ ပိုသေးတဲ့ပုံကိုရွေးပါ။',
    'profile.photo_error':
        'ဓာတ်ပုံကို သိမ်းမရပါ။ အခြားပုံနဲ့ ပြန်ကြိုးစားပါ။',
    'profile.photo_badge_notice':
        'ပရိုဖိုင်ဓာတ်ပုံ မထည့်ထားသေးလျှင် badge ပိုစတာတွင် သင့်ဓာတ်ပုံ မပါဝင်ပါ။',
    'profile.exercise_totals_title': 'စုစုပေါင်း လေ့ကျင့်ခန်းများ',
    'profile.exercise_totals_subtitle': 'စတင်သည့်နေ့မှ နောက်ဆုံးအထိ။',
    'profile.exercise_empty': 'လေ့ကျင့်ခန်းဒေတာ မရှိသေးပါ',
    'profile.badges_title': 'ရရှိထားသော Badge များ',
    'profile.badges_empty': 'Badge မရှိသေးပါ',
    'profile.badge_gallery_saved_note':
        'Badge ဖွင့်လှစ်တိုင်း ပိုစတာကို gallery album {album} ထဲ အလိုအလျောက် သိမ်းထားပါမည်။',
    'camera.overlay.skeleton': 'အရိုးပုံ',
    'camera.overlay.stop': 'ရပ်',
    'camera.overlay.record': 'မှတ်တမ်း',
    'camera.overlay.complete': 'ပြီးဆုံး',
    'lang.en': 'အင်္ဂလိပ်',
    'lang.es': 'စပိန်',
    'lang.ja': 'ဂျပန်',
    'lang.my': 'ဗမာ',
    'lang.hi': 'ဟိန္ဒီ',
    'lang.pt': 'ပေါ်တူဂီ',
    'lang.zh': 'မန်ဒရင်း တရုတ်',
    'lang.de': 'ဂျာမန်',
  };

  static const Map<String, String> _hiValues = {
    'app.title': 'H&F',
    'nav.exercises': 'व्यायाम',
    'nav.progress': 'प्रगति',
    'nav.recordings': 'रिकॉर्ड और प्रोफ़ाइल',
    'common.cancel': 'रद्द करें',
    'common.retry': 'पुनः प्रयास करें',
    'common.load_exercises': 'व्यायाम लोड करें',
    'common.clear_data': 'डेटा साफ़ करें',
    'common.ok': 'OK',
    'common.close': 'बंद करें',
    'common.error_with_message': 'त्रुटि: {message}',
    'premium.badge': 'प्रीमियम',
    'premium.menu_only': 'यह मेनू केवल प्रीमियम उपयोगकर्ताओं के लिए उपलब्ध है।',
    'home.exercises_list': 'व्यायाम सूची',
    'home.exercises_simple_form': 'सरल व्यायाम फ़ॉर्म',
    'home.no_supported_exercises': 'समर्थित व्यायाम उपलब्ध नहीं हैं',
    'home.check_exercise_config': 'कृपया व्यायाम कॉन्फ़िगरेशन जाँचें',
    'home.error_loading_exercise': 'व्यायाम लोड करने में त्रुटि: {error}',
    'home.image_reference_count': '{count} संदर्भ चित्र',
    'home.today_progress_premium': 'आज की प्रगति (प्रीमियम)',
    'home.today_progress_locked_desc':
        'प्रोग्रेस मेन्यू का डेटा केवल प्रीमियम उपयोगकर्ताओं के लिए है।',
    'home.today_progress': 'आज की प्रगति',
    'home.total_reps': 'कुल रिप्स',
    'home.workouts': 'वर्कआउट्स',
    'home.calories': 'कैलोरी',
    'home.daily_goal': 'दैनिक लक्ष्य: {current}/{goal}',
    'home.daily_goal_achieved': 'दैनिक लक्ष्य पूरा हुआ!',
    'home.progress_premium_title': 'प्रगति प्रीमियम है',
    'home.progress_premium_message':
        'विस्तृत प्रगति विश्लेषण प्रीमियम में उपलब्ध है।',
    'home.recordings_premium_title': 'रिकॉर्डिंग्स प्रीमियम हैं',
    'home.recordings_premium_message':
        'वीडियो रिकॉर्डिंग इतिहास केवल प्रीमियम में उपलब्ध है।',
    'home.simple_form': '{name} फ़ॉर्म',
    'home.quick_form_summary': 'फ़ॉर्म का त्वरित सारांश',
    'home.form_images': 'फ़ॉर्म चित्र',
    'home.exercise_list_notice_title': 'त्वरित याद दिलाना',
    'home.exercise_list_notice_message':
        'हर exercise form में नोटिस हो सकते हैं, कृपया जाँचें। नोट: situp exercise में एक महत्वपूर्ण नोटिस है।',
    'home.simple_form_notice':
        'सटीकता बार और काउंटिंग नोट:\nहमारी AI आपके विज़ुअल गाइड के अनुसार व्यायाम पहचानने के लिए बनाई गई है। यह स्मूद काउंटिंग देती है, लेकिन औपचारिक तकनीकी कोचिंग नहीं देती। कृपया याद रखें कि हमारी ऐप 100% सटीक नहीं है।\n\nसाइड व्यू वाले व्यायाम के लिए साइड पोज़िशन में रहें, और फ्रंट व्यू वाले व्यायाम के लिए फ्रंट पोज़िशन में रहें। इससे परिणाम सही होंगे।\n\nनिम्न स्थितियों में ट्रैकिंग गलत हो सकती है:\n• आपका पूरा शरीर कैमरा फ्रेम में दिखाई नहीं देता।\n• कैमरे में एक से अधिक लोग हैं।\n• कमरा बहुत अंधेरा हो या तेज़ फ्लेयर/ग्लेयर हो।\n• कैमरा को अपने शरीर के मुकाबले बहुत नीचे या बहुत ऊपर न रखें।',
    'home.situp_notice':
        'नोटिस 1. कैमरा सेट करने और situp करने की जगह चुनने के बाद, पहले 2 सेकंड तक स्थिर रहें और फिर व्यायाम करें।\n2. situp व्यायाम खत्म करने के बाद, कम से कम 2 सेकंड बैठें और फिर कैमरा के पास जाएँ।',
    'exercise.guide.title': 'क्विक गाइड',
    'exercise.guide.step1':
        'यदि आप लैंडमार्क बनाना चाहते हैं, तो स्केलेटन बटन दबाएँ।',
    'exercise.guide.step2':
        'यदि आप वीडियो रिकॉर्ड करना चाहते हैं, तो रिकॉर्ड बटन दबाएँ।',
    'exercise.guide.step3':
        'रिकॉर्डिंग रोकने और सेव करने के लिए स्क्रीन को डबल टैप करें या बैक बटन दबाएँ।',
    'exercise.guide.step4':
        'व्यायाम पूरा होने पर Complete बटन दबाएँ और फिर Save बटन दबाकर सेव करें।',
    'exercise.error.setup_title': 'सेटअप त्रुटि',
    'exercise.error.setup_message': 'आरंभ नहीं हो सका: {error}',
    'exercise.error.pose_title': 'पोज़ डिटेक्शन त्रुटि',
    'exercise.error.pose_message':
        'पोज़ डिटेक्शन शुरू नहीं हो सका। कृपया Google Play Services अपडेट है या नहीं देखें।',
    'exercise.premium.landmarks': 'लैंडमार्क ओवरले प्रीमियम फीचर है।',
    'exercise.premium.recording':
        'वीडियो रिकॉर्डिंग प्रीमियम संस्करण में उपलब्ध है। अनलॉक करने के लिए अपग्रेड करें।',
    'exercise.recording.failed_start':
        'स्क्रीन रिकॉर्डिंग शुरू नहीं हो सकी: {error}',
    'exercise.recording.permission_denied':
        'स्क्रीन/ऑडियो रिकॉर्डिंग की अनुमति अस्वीकृत',
    'exercise.recording.failed_save': 'स्क्रीन रिकॉर्डिंग सेव नहीं हो सकी',
    'exercise.recording.saved_gallery': 'गैलरी में सेव किया गया ({album})',
    'exercise.recording.saved_app': 'ऐप स्टोरेज में सेव किया गया: {path}',
    'exercise.recording.saved_phone': 'वीडियो फोन स्टोरेज में सेव किया गया',
    'exercise.recording.failed_video': 'वीडियो रिकॉर्डिंग विफल: {error}',
    'exercise.recording.preparing_luxury_video':
        'हम आपके लिए आपका लग्ज़री वर्कआउट वीडियो तैयार कर रहे हैं।',
    'exercise.recording.keep_screen_open':
        'कृपया इस स्क्रीन को थोड़ी देर खुला रखें।',
    'exercise.premium.title': 'प्रीमियम फीचर',
    'exercise.premium.not_now': 'अभी नहीं',
    'exercise.premium.upgrade': 'अपग्रेड',
    'exercise.premium.required_title': 'प्रीमियम आवश्यक',
    'exercise.premium.required_message':
        'वर्कआउट सेव, काउंटिंग और प्रोग्रेस ट्रैकिंग केवल प्रीमियम में उपलब्ध है।',
    'exercise.camera.error_title': 'कैमरा त्रुटि',
    'exercise.camera.error_message':
        'कैमरा शुरू नहीं हो सका। अनुमतियाँ जाँचें और फिर से प्रयास करें।',
    'exercise.counting_premium': 'काउंटिंग (प्रीमियम)',
    'exercise.summary.title': 'वर्कआउट पूरा!',
    'exercise.summary.total_reps': 'कुल रिप्स',
    'exercise.summary.avg_accuracy': 'औसत सटीकता',
    'exercise.summary.duration': 'अवधि',
    'exercise.summary.seconds': '{value} सेकंड',
    'exercise.summary.best_accuracy': 'सबसे अच्छी रिप सटीकता',
    'exercise.summary.close': 'बंद करें',
    'exercise.summary.view_details': 'सेव',
    'exercise.card.type.dynamic': 'डायनामिक',
    'exercise.card.type.static': 'स्टैटिक',
    'exercise.card.view.front': 'फ्रंट व्यू',
    'exercise.card.view.side': 'साइड व्यू',
    'exercise.card.total_reps': 'कुल रिप्स',
    'exercise.card.avg_accuracy': 'औसत सटीकता',
    'exercise.card.select': 'व्यायाम चुनें',
    'exercise.time.today': 'आज',
    'exercise.time.yesterday': 'कल',
    'exercise.time.days_ago': '{value} दिन पहले',
    'exercise.time.weeks_ago': '{value} सप्ताह पहले',
    'exercise.time.months_ago': '{value} महीने पहले',
    'guide.squat.subtitle':
        'छाती ऊपर रखें, कूल्हे पीछे रखें और घुटने पैर की उंगलियों की दिशा में रहें।',
    'guide.squat.step1': 'कंधे की चौड़ाई पर खड़े हों और कोर टाइट करें।',
    'guide.squat.step2':
        'एड़ियाँ जमीन पर रखते हुए जाँघें लगभग समानांतर तक नीचे जाएँ।',
    'guide.squat.step3': 'एड़ियों से दबाकर ऊपर उठें और घुटने लॉक न करें।',
    'guide.pushup.subtitle':
        'सिर से एड़ी तक सीधी लाइन रखें और हर रिप नियंत्रित करें।',
    'guide.pushup.step1':
        'हाथों को कंधों से थोड़ा चौड़ा रखकर हाई प्लैंक से शुरू करें।',
    'guide.pushup.step2':
        'कुहनियों को लगभग 45 डिग्री पर मोड़कर छाती नीचे करें।',
    'guide.pushup.step3': 'कोर टाइट रखकर ऊपर पुश करें।',
    'guide.situp.subtitle': 'गर्दन खींचने के बजाय कोर से नियंत्रित करें।',
    'guide.situp.step1': 'पीठ के बल लेटें, घुटने मुड़े हों और पैर जमीन पर हों।',
    'guide.situp.step2': 'एब्स टाइट करके धड़ ऊपर उठाएँ।',
    'guide.situp.step3': 'धीरे-धीरे नियंत्रित रूप से नीचे जाएँ।',
    'guide.bicep.subtitle': 'कोहनियाँ शरीर के पास रखें और झूलने से बचें।',
    'guide.bicep.step1': 'डम्बल पकड़ें, हथेलियाँ आगे, सीधे खड़े हों।',
    'guide.bicep.step2': 'कंधे हिलाए बिना कोहनियाँ मोड़कर वजन ऊपर करें।',
    'guide.bicep.step3': 'धीरे-धीरे नीचे लाएँ।',
    'guide.shoulder.subtitle':
        'पसली नीचे रखें, कोर टाइट रखें और सीधा ऊपर प्रेस करें।',
    'guide.shoulder.step1': 'वजन कंधे की ऊँचाई पर, कलाई न्यूट्रल रखें।',
    'guide.shoulder.step2': 'बाहों को सिर के ऊपर तक प्रेस करें।',
    'guide.shoulder.step3': 'कंट्रोल से कंधे की ऊँचाई तक वापस लाएँ।',
    'guide.leg.subtitle':
        'कंट्रोल्ड रेंज में चलें और घुटने झटके से न सीधा करें।',
    'guide.leg.step1': 'पीठ सपोर्ट के साथ बैठें और पैर पैड के नीचे रखें।',
    'guide.leg.step2': 'कूल्हे स्थिर रखते हुए घुटने सीधा करके पैड उठाएँ।',
    'guide.leg.step3': 'धीरे से नीचे लाएँ और दोहराएँ।',
    'settings.title': 'सेटिंग्स',
    'settings.premium_features': 'प्रीमियम फीचर्स',
    'settings.app_settings': 'ऐप सेटिंग्स',
    'settings.profile_name': 'प्रोफ़ाइल नाम',
    'settings.appearance': 'लुक',
    'settings.data': 'डेटा',
    'settings.about': 'परिचय',
    'settings.premium_account': 'प्रीमियम अकाउंट',
    'settings.unlock_all_features': 'सभी प्रीमियम फीचर्स अनलॉक करें',
    'settings.voice_counting': 'वॉइस काउंटिंग',
    'settings.speak_count': 'रिप्स के दौरान काउंट बोलें',
    'settings.voice_counting_language': 'वॉइस काउंटिंग भाषा',
    'settings.upgrade_to_premium': 'प्रीमियम में अपग्रेड',
    'settings.upgrade_subtitle': 'वॉइस काउंट, वीडियो रिकॉर्डिंग और अधिक पाएं',
    'settings.voice_coach': 'वॉइस कोच',
    'settings.voice_feedback': 'रीयल-टाइम वॉइस फीडबैक',
    'settings.show_landmarks': 'लैंडमार्क दिखाएँ',
    'settings.display_skeleton': 'स्केलेटन ओवरले दिखाएँ',
    'settings.auto_recording': 'ऑटो रिकॉर्डिंग',
    'settings.auto_recording_subtitle': 'वर्कआउट्स को अपने आप रिकॉर्ड करें',
    'settings.theme': 'थीम',
    'settings.language': 'भाषा',
    'settings.language_subtitle': 'ऐप की भाषा बदलें',
    'settings.clear_data': 'डेटा साफ़ करें',
    'settings.clear_data_subtitle': 'सारा वर्कआउट इतिहास हटाएँ',
    'settings.version': 'वर्ज़न',
    'settings.privacy_policy': 'प्राइवेसी पॉलिसी',
    'settings.terms': 'सेवा की शर्तें',
    'settings.disclaimer': 'अस्वीकरण',
    'legal.last_updated': 'अंतिम अपडेट: {date}',
    'legal.privacy.content':
        '1) हम कौन सा डेटा संसाधित करते हैं\n'
        'H&F आपके डिवाइस पर वर्कआउट लॉग, बैज प्रगति, ऐप प्राथमिकताएं, और वैकल्पिक रिकॉर्डिंग फ़ाइल पथ संग्रहीत करता है।\n\n'
        '2) प्रीमियम सक्रियण\n'
        'प्रीमियम सक्रिय करने के लिए कम से कम एक बार इंटरनेट की आवश्यकता होती है। सक्रियण के दौरान लाइसेंस कुंजी, डिवाइस पहचान हैश, ऐप संस्करण और प्लेटफ़ॉर्म को हमारे लाइसेंस सर्वर पर भेजा जाता है। सक्रियण के बाद, प्रीमियम अधिकार स्थानीय रूप से सत्यापित किया जाता है और ऐप ऑफ़लाइन काम कर सकती है।\n\n'
        '3) कैमरा, माइक्रोफ़ोन, स्टोरेज और प्रोसेसिंग पावर\n'
        'पोस डिटेक्शन के लिए कैमरा उपयोग होता है। पोज़ का विश्लेषण करने के लिए यह आपके डिवाइस की प्रोसेसिंग पावर का उपयोग करती है। माइक्रोफोन और स्क्रीन रिकॉर्डिंग अनुमति केवल तभी जरूरत होती है जब आप रिकॉर्डिंग फीचर का उपयोग करते हैं। सेव किए गए वीडियो आपके डिवाइस या गैलरी में रहते हैं।\n\n'
        '4) हम डेटा का कैसे उपयोग करते हैं\n'
        'डेटा का उपयोग रेप्स गिनने, सटीकता का हिसाब लगाने, प्रगति ट्रैक करने, बैज अनलॉक करने और प्रीमियम फीचर्स देने के लिए किया जाता है।\n\n'
        '5) साझा करना\n'
        'हम आपका निजी डेटा नहीं बेचते। लाइसेंस सत्यापन डेटा केवल प्रीमियम एक्सेस सक्रिय करने और सुरक्षित रखने के लिए संसाधित किया जाता है।\n\n'
        '6) आपका नियंत्रण\n'
        'आप किसी भी समय सभी डेटा मिटा सकते हैं या ऐप अनइंस्टॉल कर सकते हैं। डेटा मिटाने से स्थानीय इतिहास और संग्रहीत प्रीमियम स्थिति हट जाती है।\n\n'
        '7) सुरक्षा\n'
        'ऐप गड़बड़ी के जोखिम कम करने के लिए इंटीग्रिटी चेक और सुरक्षित लोकल स्टोरेज का उपयोग करती है, लेकिन कोई भी सिस्टम पूर्ण रूप से सुरक्षित नहीं होता।',
    'legal.terms.content':
        'H&F का उपयोग करके आप इन शर्तों से सहमत होते हैं।\n\n'
        '1) सेवा का उपयोग\n'
        'H&F एक फिटनेस सपोर्ट ऐप है। आपकी अपनी सुरक्षा और स्वास्थ्य निर्णयों की जिम्मेदारी आप पर है।\n\n'
        '2) खाता और लाइसेंस\n'
        'प्रीमियम के लिए एक मान्य लाइसेंस कुंजी आवश्यक है। लाइसेंस डिवाइस द्वारा सीमित हो सकते हैं और दुरुपयोग, निरस्तीकरण, या सुरक्षा उल्लंघनों के कारण ब्लॉक किए जा सकते हैं।\n\n'
        '3) ऑफ़लाइन मोड\n'
        'सफल सक्रियण के बाद मूल और प्रीमियम सुविधाएं उसी डिवाइस पर ऑफ़लाइन चल सकती हैं। पुनर्स्थापन, संवेदनशील डेटा को साफ़ करना या इंटीग्रिटी विफलता फिर से ऑनलाइन सक्रियण मांग सकती है।\n\n'
        '4) प्रतिबंध\n'
        'सिक्योरिटी को छेड़छाड़ न करें, लाइसेंस का रिवर्स इंजीनियर न करें, या ऐप का उपयोग अवैध गतिविधियों के लिए न करें।\n\n'
        '5) बौद्धिक संपदा\n'
        'ऐप सॉफ्टवेयर, ब्रांडिंग और सामग्री H&F और इसके लाइसेंसदाताओं की संपत्ति बनी रहती है।\n\n'
        '6) कोई वारंटी नहीं\n'
        'ऐप को \"जैसी है\" प्रदान किया जाता है, बिना लगातार काम करने या किसी विशिष्ट फिटनेस परिणाम की गारंटी के। विभिन्न कारणों से मेरे ऐप का काउंटर ज़्यादा या कम गिन सकता है।\n\n'
        '7) देयता की सीमा\n'
        'H&F ऐप के उपयोग से होने वाले अप्रत्यक्ष, आकस्मिक, या परिणामी नुकसान के लिए जिम्मेदार नहीं है।',
    'legal.disclaimer.content':
        'H&F कोई चिकित्सा सेवा नहीं है और चिकित्सा सलाह, निदान, या उपचार प्रदान नहीं करता।\n\n'
        '1) प्रशिक्षण जोखिम\n'
        'व्यायाम में चोट का खतरा होता है। यदि आपको दर्द, चक्कर, सांस लेने में दिक्कत या असुविधा महसूस हो तो तुरंत रुकें और किसी योग्य पेशेवर से सलाह लें।\n\n'
        '2) एआई गणना और फॉर्म फीडबैक\n'
        'पोज़ डिटेक्शन और रेप काउंटिंग अनुमान हैं और कैमरा कोण, प्रकाश व्यवस्था, अवरोध, पोशाक, या गति के कारण गलत हो सकते हैं।\n\n'
        '3) रिकॉर्डिंग के दौरान प्रदर्शन\n'
        'फोन चालू रखकर सामान्य वर्कआउट में काउंटिंग/वॉइस काउंटिंग को ठीक से काम करने के लिए डिज़ाइन किया गया है। पोज़ डिटेक्शन (काउंटिंग) और वीडियो रिकॉर्डिंग साथ‑साथ चल सकती हैं और आम तौर पर 5–15 मिनट तक ठीक से काम करती हैं। अधिक समय तक लगातार उपयोग से डिवाइस गर्म हो सकता है, बैटरी तेजी से खत्म हो सकती है और सटीकता घट सकती है।\n\n'
        '4) आकस्मिक स्थितियाँ\n'
        'आपात स्थिति में इस ऐप पर भरोसा न करें। आवश्यकता पड़ने पर तुरंत स्थानीय आपातकालीन सेवाओं से संपर्क करें।\n\n'
        '5) उपयोगकर्ता की जिम्मेदारी\n'
        'सुरक्षित वर्कआउट स्थान, उचित तकनीक और किसी भी आवश्यक चिकित्सा अनुमति को प्राप्त करना उपयोगकर्ता की जिम्मेदारी है।\n\n'
        '6) रिकॉर्डिंग और दूसरों की गोपनीयता\n'
        'यदि आप वर्कआउट रिकॉर्ड करते हैं, तो किसी भी व्यक्ति की सहमति लें जो वीडियो या ऑडियो में दिख सकता है।\n\n'
        '7) परिणाम\n'
        'फिटनेस के परिणाम व्यक्ति पर निर्भर करते हैं। H&F किसी विशेष प्रदर्शन या स्वास्थ्य परिणाम की गारंटी नहीं देता।',
    'settings.select_theme': 'थीम चुनें',
    'settings.select_language': 'भाषा चुनें',
    'onboarding.language_title': 'अपनी भाषा चुनें',
    'onboarding.language_subtitle': 'आप बाद में सेटिंग्स में बदल सकते हैं।',
    'onboarding.name_title': 'आपका नाम क्या है?',
    'onboarding.name_subtitle': 'यह आपके प्रोफ़ाइल पर दिखेगा।',
    'onboarding.name_hint': 'अपना नाम दर्ज करें',
    'onboarding.name_required': 'कृपया अपना नाम दर्ज करें',
    'onboarding.disclaimer_title': 'अस्वीकरण',
    'onboarding.terms_title': 'सेवा की शर्तें',
    'onboarding.accept_notice':
        'ऐप का उपयोग जारी रखने के लिए सहमत हों।',
    'onboarding.accept_checkbox': 'मैं सहमत हूँ',
    'onboarding.continue': 'जारी रखें',
    'onboarding.start_app': 'ऐप शुरू करें',
    'settings.clear_all_data': 'सारा डेटा साफ़ करें',
    'settings.clear_all_data_desc':
        'यह आपका सारा वर्कआउट इतिहास, उपलब्धियाँ और सेटिंग्स हटा देगा। यह कार्रवाई वापस नहीं होगी।',
    'settings.clear_success': 'सारा उपयोगकर्ता डेटा सफलतापूर्वक साफ़ किया गया।',
    'settings.clear_failed': 'डेटा साफ़ करने में विफल: {error}',
    'theme.light': 'लाइट',
    'theme.dark': 'डार्क',
    'theme.gold': 'गोल्ड',
    'theme.pink': 'गुलाबी',
    'progress.title': 'प्रगति और विश्लेषण',
    'progress.overview': 'अवलोकन',
    'progress.exercises': 'व्यायाम',
    'progress.badges': 'बैज',
    'progress.no_data': 'डेटा उपलब्ध नहीं',
    'progress.weekly_summary': 'साप्ताहिक सारांश',
    'progress.streak_days': '{count} दिन की स्ट्रीक',
    'progress.recent_workouts': 'हाल के वर्कआउट',
    'progress.no_workouts': 'अभी तक कोई वर्कआउट नहीं',
    'progress.workout_summary': '{reps} रिप्स • {accuracy}% सटीकता',
    'progress.achievements': 'उपलब्धियाँ',
    'progress.badges_unlocked': '{unlocked}/{total} बैज अनलॉक',
    'progress.view_all_achievements': 'सभी उपलब्धियाँ देखें',
    'progress.day.sun': 'रवि',
    'progress.day.mon': 'सोम',
    'progress.day.tue': 'मंगल',
    'progress.day.wed': 'बुध',
    'progress.day.thu': 'गुरु',
    'progress.day.fri': 'शुक्र',
    'progress.day.sat': 'शनि',
    'progress.time.just_now': 'अभी अभी',
    'progress.time.minutes_ago': '{value}m पहले',
    'progress.time.hours_ago': '{value}h पहले',
    'progress.time.days_ago': '{value}d पहले',
    'progress.time.weeks_ago': '{value}w पहले',
    'progress.analytics_intro_title': 'व्यायाम विश्लेषण कैसे समझें',
    'progress.analytics_intro_line1':
        'कुल रिप्स = इस व्यायाम के सभी सत्रों में सेव किए गए कुल रिप्स।',
    'progress.analytics_intro_line2':
        'औसत सटीकता = सभी सेव सत्रों का औसत फॉर्म सटीकता।',
    'progress.analytics_intro_line3':
        'ट्रेंड चार्ट = समय के साथ सटीकता (ऊँची लाइन बेहतर फॉर्म दिखाती है)।',
    'progress.analytics_intro_line4':
        'विश्लेषण केवल तब अपडेट होता है जब आप वर्कआउट सत्र सेव करते हैं।',
    'progress.read_exercise_analytics_title': 'व्यायाम विश्लेषण कैसे पढ़ें',
    'progress.read_exercise_analytics_line1':
        'नवीनतम सटीकता = आपकी सबसे हाल की फॉर्म स्कोर।',
    'progress.read_exercise_analytics_line2':
        'सर्वश्रेष्ठ सटीकता = अब तक का आपका सबसे ऊँचा स्कोर।',
    'progress.read_exercise_analytics_line3':
        'सेशन बार पिछली 6 सेशन्स दिखाते हैं। बार जितना ऊँचा, सटीकता उतनी बेहतर।',
    'progress.read_exercise_analytics_line4':
        'हर बार के नीचे की संख्या उस सेशन के रेप्स है।',
    'progress.latest_accuracy': 'नवीनतम सटीकता',
    'progress.best_accuracy': 'सर्वश्रेष्ठ सटीकता',
    'progress.trend_vs_previous_session':
        'पिछले सत्र की तुलना में {sign}{delta}%',
    'progress.last_sessions_accuracy_title': 'पिछले सत्र (सटीकता %)',
    'progress.reps_short': 'रिप्स',
    'progress.chart_accuracy_trend_legend':
        'ऊँचे बार बेहतर सटीकता दिखाते हैं। नीचे के लेबल प्रत्येक सत्र के रिप्स हैं।',
    'progress.total_reps_all_time': 'कुल रिप्स (सभी समय)',
    'progress.avg_accuracy_all_sessions': 'औसत सटीकता (सभी सत्र)',
    'progress.sessions': 'सत्र',
    'progress.chart_accuracy_trend':
        'चार्ट सत्र तिथि के अनुसार सटीकता ट्रेंड दिखाता है।',
    'progress.no_sessions':
        'अभी तक कोई सत्र नहीं। वर्कआउट सेव करें ताकि यहाँ विश्लेषण दिखे।',
    'badges.empty':
        'अभी तक कोई बैज नहीं।\nवर्कआउट शुरू करें और पहला माइलस्टोन अनलॉक करें।',
    'badges.collection': 'आपका बैज संग्रह',
    'badges.current_status': 'वर्तमान बैज स्थिति',
    'badges.unlocked_count': '{unlocked}/{total} बैज अनलॉक',
    'badges.tier': 'टियर: {tier}',
    'badges.next_target':
        'अगला लक्ष्य: {name} ({progress}/{requirement}) - कुल {percent}% पूरा',
    'badges.how_it_works': 'यह बैज सिस्टम कैसे काम करता है',
    'badges.guide_1':
        'बैज 5 दिन सक्रिय + 2 दिन आराम के रिद्म पर चलते हैं। केवल सक्रिय दिन गिने जाते हैं।',
    'badges.guide_2':
        'आराम के दिन के वर्कआउट सेव होते हैं लेकिन बैज प्रगति नहीं बदलते।',
    'badges.guide_3':
        'दैनिक लक्ष्य सीमित हैं; सीमा से अधिक रिप्स/सेट्स अतिरिक्त क्रेडिट नहीं देते।',
    'badges.guide_4':
        'डम्बल या मशीन की जरूरत नहीं: आप विकल्पों से भी बैज कमा सकते हैं (Upper के लिए push-ups, Lower के लिए squats)।',
    'badges.guide_5':
        'प्रगति सेव किए गए वर्कआउट लॉग से गणना होती है; वास्तविक डेटा अनलॉक तय करता है।',
    'badges.unlocked_on': '{date} पर अनलॉक',
    'badges.tap_full_plan': 'पूरा प्लान देखने के लिए टैप करें',
    'badges.new_unlock_today': 'आज अनलॉक हुआ! बढ़िया काम।',
    'badges.unlocked_banner':
        'अनलॉक हो गया! शानदार नियमितता। इसी तरह जारी रखें।',
    'badges.poster_saved_note':
        'बैज पोस्टर अपने आप गैलरी एल्बम {album} में सेव हो गया है।',
    'badges.poster_save_failed_note':
        'बैज पोस्टर गैलरी में सेव नहीं हो सका। फोटो अनुमति जांचें।',
    'badges.no_tier': 'अभी कोई टियर अनलॉक नहीं',
    'badges.motivation_unlocked':
        'अच्छा काम। यह बैज सुरक्षित है; अब अगले टियर की तरफ बढ़ें।',
    'badges.motivation_almost':
        'लगभग हो गया। इस बैज को अनलॉक करने के लिए {remaining} और योग्य दिन चाहिए।',
    'badges.motivation_keep':
        'नियमित रहें। हर योग्य दिन इस बैज को आगे बढ़ाता है।',
    'tier.bronze': 'ब्रॉन्ज',
    'tier.silver': 'सिल्वर',
    'tier.gold': 'गोल्ड',
    'tier.platinum': 'प्लैटिनम',
    'badge.first_workout.name': 'पहले कदम',
    'badge.first_workout.narrative': 'अपना पहला योग्य वर्कआउट दिन पूरा करें।',
    'badge.first_workout.detail1':
        'लक्ष्य: सेव किए गए वर्कआउट लॉग से 1 योग्य दिन।',
    'badge.first_workout.detail2':
        'Upper लक्ष्य: कुल 8 रिप्स (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise).',
    'badge.first_workout.detail3': 'Core लक्ष्य: कुल 10 रिप्स (Sit-up).',
    'badge.first_workout.detail4':
        'Lower लक्ष्य: कुल 12 रिप्स (Squat / Leg Extension).',
    'badge.prep.name': '15-दिन तैयारी',
    'badge.prep.narrative': '15-दिन की तैयारी रिद्म से निरंतरता बनाएं।',
    'badge.prep.detail1':
        '5 सक्रिय दिन + 2 आराम दिन चक्र के साथ 15-दिन तैयारी (दिन 6-7 और दिन 13-14 आराम).',
    'badge.prep.detail2':
        'दिन 1-3: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': 'दिन 4-5: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': 'दिन 8-12: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': 'दिन 15: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = एक दिन में श्रेणी के अनुसार सेव किए गए सत्र; आराम के दिन प्रगति में नहीं जुड़ते।',
    'badge.prep.detail8':
        'यदि कोई आवश्यक सक्रिय दिन छूट जाता है, तो prep प्रगति रीसेट हो जाती है और अगला वर्कआउट दिन फिर से Day 1 से शुरू होता है।',
    'badge.bronze.name': 'माह 1 ब्रॉन्ज',
    'badge.bronze.narrative': 'पूरे प्रोग्राम के लिए आधार महीना।',
    'badge.bronze.detail1':
        '5 सक्रिय + 2 आराम चक्र के साथ 30 योग्य सक्रिय दिन।',
    'badge.bronze.detail2':
        'Upper दैनिक: 18 reps + 3 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise संयुक्त).',
    'badge.bronze.detail3': 'Core दैनिक: 24 reps + 3 sets (Sit-up).',
    'badge.bronze.detail4':
        'Lower दैनिक: 30 reps + 3 sets (Squat / Leg Extension संयुक्त).',
    'badge.bronze.detail5':
        'दैनिक सीमा से अधिक रिप्स/सेट्स प्रगति में नहीं गिने जाते।',
    'badge.bronze.detail6':
        'अगर एक दिन छूट भी जाए, तो आपको पहले दिन से फिर शुरू नहीं करना पड़ेगा।',
    'badge.silver.name': 'माह 2 सिल्वर',
    'badge.silver.narrative': 'अधिक मात्रा आवश्यकताओं वाला प्रगति महीना।',
    'badge.silver.detail1':
        '5 सक्रिय + 2 आराम चक्र के साथ 30 योग्य सक्रिय दिन।',
    'badge.silver.detail2':
        'Upper दैनिक: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise संयुक्त).',
    'badge.silver.detail3': 'Core दैनिक: 32 reps + 4 sets (Sit-up).',
    'badge.silver.detail4':
        'Lower दैनिक: 40 reps + 4 sets (Squat / Leg Extension संयुक्त).',
    'badge.silver.detail5':
        'केवल सक्रिय दिन गिने जाते हैं; आराम दिन अनदेखे होते हैं।',
    'badge.silver.detail6':
        'अगर एक दिन छूट भी जाए, तो आपको पहले दिन से फिर शुरू नहीं करना पड़ेगा।',
    'badge.gold.name': 'माह 3 गोल्ड',
    'badge.gold.narrative': 'उच्च सहनशक्ति लक्ष्यों वाला माह।',
    'badge.gold.detail1': '5 सक्रिय + 2 आराम चक्र के साथ 30 योग्य सक्रिय दिन।',
    'badge.gold.detail2':
        'Upper दैनिक: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise संयुक्त).',
    'badge.gold.detail3': 'Core दैनिक: 40 reps + 4 sets (Sit-up).',
    'badge.gold.detail4':
        'Lower दैनिक: 50 reps + 4 sets (Squat / Leg Extension संयुक्त).',
    'badge.gold.detail5':
        'प्रगति सेव लॉग पर आधारित है; अतिरिक्त रिप्स क्रेडिट नहीं देते।',
    'badge.gold.detail6':
        'अगर एक दिन छूट भी जाए, तो आपको पहले दिन से फिर शुरू नहीं करना पड़ेगा।',
    'badge.default.goal': 'लक्ष्य: {description}',
    'badge.default.requirement': 'आवश्यकता: {requirement} योग्य दिन।',
    'badge.default.status': 'वर्तमान स्थिति: {progress}/{requirement}.',
    'badge.poster.badge_label': 'बैज',
    'badge.poster.user_label': 'प्राप्तकर्ता',
    'badge.poster.requirements_label': 'योग्य डेटा',
    'leaderboard.title': 'लीडरबोर्ड',
    'leaderboard.achievements': 'उपलब्धियाँ',
    'leaderboard.global': 'ग्लोबल',
    'leaderboard.achievement_progress': 'उपलब्धि प्रगति',
    'leaderboard.personal_bests': 'पर्सनल बेस्ट',
    'leaderboard.most_reps': 'सबसे अधिक रिप्स',
    'leaderboard.best_accuracy': 'सर्वोत्तम सटीकता',
    'leaderboard.longest_streak': 'सबसे लंबी स्ट्रीक',
    'leaderboard.days': 'दिन',
    'leaderboard.global_simulated': 'ग्लोबल लीडरबोर्ड (सिमुलेटेड)',
    'leaderboard.points': '{score} अंक',
    'recordings.tab.recordings': 'रिकॉर्ड',
    'recordings.tab.profile': 'प्रोफ़ाइल',
    'recordings.failed_load': 'रिकॉर्डिंग्स लोड नहीं हो सकीं',
    'recordings.empty': 'कोई रिकॉर्ड किया गया वीडियो नहीं',
    'recordings.file_not_found': 'वीडियो फ़ाइल नहीं मिली',
    'recordings.file_incomplete':
        'रिकॉर्डिंग फ़ाइल अधूरी है। कृपया फिर से रिकॉर्ड करें।',
    'profile.guest_name': 'उपयोगकर्ता',
    'profile.user_name_label': 'उपयोगकर्ता नाम',
    'profile.edit_name': 'संपादित करें',
    'profile.name_hint': 'अपना नाम दर्ज करें',
    'profile.save_name': 'सहेजें',
    'profile.photo_title': 'प्रोफ़ाइल फ़ोटो',
    'profile.photo_subtitle':
        'प्रोफ़ाइल को व्यक्तिगत बनाने के लिए पूरी बॉडी वाली फ़ोटो जोड़ें।',
    'profile.photo_add': 'फ़ोटो जोड़ें',
    'profile.photo_change': 'फ़ोटो बदलें',
    'profile.photo_remove': 'फ़ोटो हटाएँ',
    'profile.photo_remove_confirm': 'अपनी प्रोफ़ाइल फ़ोटो हटाएँ?',
    'profile.photo_too_large':
        'फ़ोटो बहुत बड़ी है। कृपया छोटी छवि चुनें।',
    'profile.photo_error':
        'फ़ोटो सहेजी नहीं जा सकी। दूसरी छवि से प्रयास करें।',
    'profile.photo_badge_notice':
        'अगर प्रोफ़ाइल फोटो नहीं जोड़ी गई, तो बैज पोस्टर में आपकी फोटो शामिल नहीं होगी।',
    'profile.exercise_totals_title': 'कुल व्यायाम आँकड़े',
    'profile.exercise_totals_subtitle': 'पहली से आख़िरी कसरत तक।',
    'profile.exercise_empty': 'अभी कोई व्यायाम डेटा नहीं',
    'profile.badges_title': 'प्राप्त बैज',
    'profile.badges_empty': 'अभी कोई बैज नहीं',
    'profile.badge_gallery_saved_note':
        'जब भी बैज अनलॉक होगा, उसका पोस्टर गैलरी एल्बम {album} में अपने आप सेव होगा।',
    'camera.overlay.skeleton': 'कंकाल',
    'camera.overlay.stop': 'रोकें',
    'camera.overlay.record': 'रिकॉर्ड',
    'camera.overlay.complete': 'पूरा करें',
    'lang.en': 'अंग्रेज़ी',
    'lang.es': 'स्पेनिश',
    'lang.ja': 'जापानी',
    'lang.my': 'बर्मी',
    'lang.hi': 'हिंदी',
    'lang.pt': 'पुर्तगाली',
    'lang.zh': 'मंदारिन चीनी',
    'lang.de': 'जर्मन',
  };

  static const Map<String, String> _ptValues = {
    'app.title': 'H&F',
    'nav.exercises': 'Exercícios',
    'nav.progress': 'Progresso',
    'nav.recordings': 'Gravar e perfil',
    'common.cancel': 'Cancelar',
    'common.retry': 'Tentar novamente',
    'common.load_exercises': 'Carregar exercícios',
    'common.clear_data': 'Limpar dados',
    'common.ok': 'OK',
    'common.close': 'Fechar',
    'common.error_with_message': 'Erro: {message}',
    'premium.badge': 'PREMIUM',
    'premium.menu_only':
        'Este menu está disponível apenas para usuários Premium.',
    'home.exercises_list': 'Lista de exercícios',
    'home.exercises_simple_form': 'Formulário simples de exercício',
    'home.no_supported_exercises': 'Nenhum exercício compatível disponível',
    'home.check_exercise_config': 'Verifique a configuração de exercícios',
    'home.error_loading_exercise': 'Erro ao carregar exercício: {error}',
    'home.image_reference_count': '{count} imagem de referência',
    'home.today_progress_premium': 'Progresso de hoje (Premium)',
    'home.today_progress_locked_desc':
        'Os dados do menu de progresso estão disponíveis apenas para usuários Premium.',
    'home.today_progress': 'Progresso de hoje',
    'home.total_reps': 'Repetições totais',
    'home.workouts': 'Treinos',
    'home.calories': 'Calorias',
    'home.daily_goal': 'Meta diária: {current}/{goal}',
    'home.daily_goal_achieved': 'Meta diária alcançada!',
    'home.progress_premium_title': 'Progresso é Premium',
    'home.progress_premium_message':
        'Análises detalhadas de progresso são desbloqueadas no Premium.',
    'home.recordings_premium_title': 'Gravações são Premium',
    'home.recordings_premium_message':
        'O histórico de gravações está disponível apenas no Premium.',
    'home.simple_form': 'Formulário de {name}',
    'home.quick_form_summary': 'Resumo rápido do formulário',
    'home.form_images': 'Imagens do formulário',
    'home.exercise_list_notice_title': 'Lembrete rápido',
    'home.exercise_list_notice_message':
        'Revise cada formulário de exercício, pois pode haver avisos. Nota: o exercício situp tem um aviso importante.',
    'home.simple_form_notice':
        'Aviso sobre barra de precisão e contagem:\nNossa IA foi projetada para reconhecer exercícios que sigam de perto nossos guias visuais. Ela oferece contagem suave com boa precisão, mas não fornece coaching técnico formal. Lembre-se de que nosso app não tem 100% de precisão.\n\nPara exercícios de visão lateral, permaneça na posição lateral, e para exercícios de visão frontal, permaneça na posição frontal. Assim os resultados serão corretos.\n\nA medição pode ser imprecisa se:\n• Seu corpo inteiro não estiver visível no enquadramento da câmera.\n• Há mais de uma pessoa na câmera.\n• O ambiente estiver muito escuro ou com reflexos/flare fortes.\n• Posicione a câmera em um local que não fique muito baixo nem muito alto em relação ao seu corpo.',
    'home.situp_notice':
        'Aviso 1. Depois de ajustar a câmera e escolher o local do situp, fique parado por 2 segundos e então faça o exercício.\n2. Depois de terminar o exercício situp, sente-se por pelo menos 2 segundos e então vá até a câmera.',
    'exercise.guide.title': 'Guia rápido',
    'exercise.guide.step1':
        'Se quiser criar um landmark, toque no botão de esqueleto.',
    'exercise.guide.step2':
        'Se quiser gravar um vídeo, toque no botão de gravar.',
    'exercise.guide.step3':
        'Para parar e salvar a gravação, dê dois toques na tela ou toque no botão voltar.',
    'exercise.guide.step4':
        'Quando terminar o exercício, toque no botão concluir e depois toque em Salvar para salvar o exercício.',
    'exercise.error.setup_title': 'Erro de configuração',
    'exercise.error.setup_message': 'Falha ao iniciar: {error}',
    'exercise.error.pose_title': 'Erro de detecção de pose',
    'exercise.error.pose_message':
        'Não foi possível iniciar a detecção de pose. Verifique se o Google Play Services está atualizado.',
    'exercise.premium.landmarks':
        'A sobreposição de landmarks é um recurso Premium.',
    'exercise.premium.recording':
        'A gravação de vídeo está disponível na versão Premium. Faça upgrade para desbloquear.',
    'exercise.recording.failed_start': 'Falha ao gravar a tela: {error}',
    'exercise.recording.permission_denied':
        'Permissão negada para gravação de tela/áudio',
    'exercise.recording.failed_save': 'Falha ao salvar a gravação de tela',
    'exercise.recording.saved_gallery': 'Salvo na galeria ({album})',
    'exercise.recording.saved_app': 'Salvo no armazenamento do app: {path}',
    'exercise.recording.saved_phone':
        'Vídeo salvo no armazenamento do telefone',
    'exercise.recording.failed_video': 'Falha ao gravar vídeo: {error}',
    'exercise.recording.preparing_luxury_video':
        'Estamos preparando seu vídeo de treino premium para você.',
    'exercise.recording.keep_screen_open':
        'Mantenha esta tela aberta por um momento.',
    'exercise.premium.title': 'Recurso Premium',
    'exercise.premium.not_now': 'Agora não',
    'exercise.premium.upgrade': 'Upgrade',
    'exercise.premium.required_title': 'Premium necessário',
    'exercise.premium.required_message':
        'Salvar treino, contagem e acompanhamento de progresso estão disponíveis apenas no Premium.',
    'exercise.camera.error_title': 'Erro de câmera',
    'exercise.camera.error_message':
        'Não foi possível iniciar a câmera. Verifique permissões e tente novamente.',
    'exercise.counting_premium': 'Contagem (Premium)',
    'exercise.summary.title': 'Treino concluído!',
    'exercise.summary.total_reps': 'Repetições totais',
    'exercise.summary.avg_accuracy': 'Precisão média',
    'exercise.summary.duration': 'Duração',
    'exercise.summary.seconds': '{value} segundos',
    'exercise.summary.best_accuracy': 'Melhor precisão por repetição',
    'exercise.summary.close': 'Fechar',
    'exercise.summary.view_details': 'Salvar',
    'exercise.card.type.dynamic': 'Dinâmico',
    'exercise.card.type.static': 'Estático',
    'exercise.card.view.front': 'Visão frontal',
    'exercise.card.view.side': 'Visão lateral',
    'exercise.card.total_reps': 'Repetições totais',
    'exercise.card.avg_accuracy': 'Precisão méd.',
    'exercise.card.select': 'Selecionar exercício',
    'exercise.time.today': 'Hoje',
    'exercise.time.yesterday': 'Ontem',
    'exercise.time.days_ago': 'há {value} dias',
    'exercise.time.weeks_ago': 'há {value} semanas',
    'exercise.time.months_ago': 'há {value} meses',
    'guide.squat.subtitle':
        'Mantenha o peito erguido, quadris para trás e joelhos alinhados aos pés.',
    'guide.squat.step1': 'Fique na largura dos ombros e contraia o core.',
    'guide.squat.step2':
        'Desça até as coxas ficarem quase paralelas, mantendo os calcanhares no chão.',
    'guide.squat.step3':
        'Empurre pelos calcanhares para subir sem travar os joelhos.',
    'guide.pushup.subtitle':
        'Mantenha uma linha reta da cabeça aos calcanhares e controle cada repetição.',
    'guide.pushup.step1':
        'Comece em prancha alta com as mãos um pouco mais largas que os ombros.',
    'guide.pushup.step2':
        'Desça o peito flexionando os cotovelos em cerca de 45 graus.',
    'guide.pushup.step3':
        'Empurre para cima mantendo o core firme e o quadril nivelado.',
    'guide.situp.subtitle':
        'Use o core de forma controlada em vez de puxar o pescoço.',
    'guide.situp.step1':
        'Deite de costas com joelhos flexionados e pés apoiados.',
    'guide.situp.step2': 'Eleve o tronco contraindo o abdômen.',
    'guide.situp.step3':
        'Desça devagar com controle antes da próxima repetição.',
    'guide.bicep.subtitle':
        'Mantenha os cotovelos próximos ao corpo e evite balanço.',
    'guide.bicep.step1':
        'Fique ereto com halteres e palmas voltadas para frente.',
    'guide.bicep.step2':
        'Flexione os cotovelos para subir os pesos sem mover os ombros.',
    'guide.bicep.step3': 'Desça os pesos lentamente até a extensão total.',
    'guide.shoulder.subtitle':
        'Pressione na vertical mantendo as costelas baixas e o core ativo.',
    'guide.shoulder.step1':
        'Comece com os pesos na altura dos ombros e punhos neutros.',
    'guide.shoulder.step2': 'Pressione até estender os braços acima da cabeça.',
    'guide.shoulder.step3': 'Desça com controle até a altura dos ombros.',
    'guide.leg.subtitle':
        'Movimente-se com controle e evite estender o joelho com impacto.',
    'guide.leg.step1':
        'Sente-se com as costas apoiadas e as pernas sob o apoio.',
    'guide.leg.step2':
        'Estenda os joelhos para levantar o apoio mantendo os quadris estáveis.',
    'guide.leg.step3': 'Desça lentamente até dobrar os joelhos e repita.',
    'settings.title': 'Configurações',
    'settings.premium_features': 'Recursos Premium',
    'settings.app_settings': 'Configurações do app',
    'settings.profile_name': 'Nome do perfil',
    'settings.appearance': 'Aparência',
    'settings.data': 'Dados',
    'settings.about': 'Sobre',
    'settings.premium_account': 'Conta Premium',
    'settings.unlock_all_features': 'Desbloquear todos os recursos Premium',
    'settings.voice_counting': 'Contagem por voz',
    'settings.speak_count': 'Falar a contagem durante as repetições',
    'settings.voice_counting_language': 'Idioma da contagem por voz',
    'settings.upgrade_to_premium': 'Upgrade para Premium',
    'settings.upgrade_subtitle': 'Tenha contagem de voz, gravação de vídeo e mais',
    'settings.voice_coach': 'Voice Coach',
    'settings.voice_feedback': 'Receba feedback por voz em tempo real',
    'settings.show_landmarks': 'Mostrar landmarks',
    'settings.display_skeleton': 'Exibir sobreposição do esqueleto',
    'settings.auto_recording': 'Gravação automática',
    'settings.auto_recording_subtitle': 'Gravar treinos automaticamente',
    'settings.theme': 'Tema',
    'settings.language': 'Idioma',
    'settings.language_subtitle': 'Alterar idioma do app',
    'settings.clear_data': 'Limpar dados',
    'settings.clear_data_subtitle': 'Excluir todo o histórico de treinos',
    'settings.version': 'Versão',
    'settings.privacy_policy': 'Política de privacidade',
    'settings.terms': 'Termos de serviço',
    'settings.disclaimer': 'Isenção de responsabilidade',
    'legal.last_updated': 'Última atualização: {date}',
    'legal.privacy.content':
        '1) Dados que processamos\n'
        'O H&F armazena registros de treino, progresso de conquistas, preferências do app e caminhos de arquivos de gravação opcionais no seu dispositivo.\n\n'
        '2) Ativação Premium\n'
        'A ativação Premium requer internet ao menos uma vez. Durante a ativação, chave de licença, hash do identificador do dispositivo, versão do app e plataforma são enviados ao servidor de licenças. Após a ativação, o direito Premium é validado localmente e o app pode ser usado offline.\n\n'
        '3) Câmera, microfone, armazenamento e poder de processamento\n'
        'A câmera é usada para detecção de postura. Ela usa o poder de processamento do seu dispositivo para analisar a postura. As permissões de microfone e gravação de tela são solicitadas apenas quando você usa os recursos de gravação. Vídeos salvos permanecem no dispositivo ou galeria.\n\n'
        '4) Como usamos os dados\n'
        'Os dados são usados para contar repetições, calcular precisão, acompanhar progresso, desbloquear conquistas e fornecer recursos Premium.\n\n'
        '5) Compartilhamento\n'
        'Não vendemos seus dados pessoais. Os dados de verificação de licença são processados apenas para ativar e proteger o acesso Premium.\n\n'
        '6) Seu controle\n'
        'Você pode apagar tudo ou desinstalar o app a qualquer momento. Apagar dados remove histórico local e o estado Premium armazenado.\n\n'
        '7) Segurança\n'
        'O app usa checagens de integridade e armazenamento local seguro para reduzir riscos de violação, mas nenhum sistema é completamente seguro.',
    'legal.terms.content':
        'Ao usar o H&F, você concorda com estes Termos.\n\n'
        '1) Uso do serviço\n'
        'O H&F é um aplicativo de apoio fitness. Você é responsável pela sua segurança e decisões de saúde.\n\n'
        '2) Conta e licença\n'
        'O Premium requer uma chave de licença válida. As licenças podem ser limitadas por dispositivo e bloqueadas por abuso, revogação ou violações de segurança.\n\n'
        '3) Modo offline\n'
        'Após ativação bem-sucedida, recursos principais e Premium podem rodar offline no mesmo dispositivo. Reinstalar, apagar dados sensíveis ou falhas de integridade podem exigir ativação online novamente.\n\n'
        '4) Restrições\n'
        'Não tente violar a segurança, fazer engenharia reversa da licença ou usar o app para atividades ilegais.\n\n'
        '5) Propriedade intelectual\n'
        'O software, a marca e o conteúdo do app permanecem propriedade do H&F e seus licenciadores.\n\n'
        '6) Sem garantia\n'
        'O app é fornecido "como está", sem garantias de operação contínua ou resultados fitness específicos. O contador do meu app pode ter contado a mais ou a menos por vários motivos.\n\n'
        '7) Limitação de responsabilidade\n'
        'O H&F não se responsabiliza por danos indiretos, incidentais ou consequentes decorrentes do uso do app.',
    'legal.disclaimer.content':
        'O H&F não é um serviço médico e não fornece aconselhamento médico, diagnóstico ou tratamento.\n\n'
        '1) Risco de treino\n'
        'Exercícios apresentam risco de lesões. Pare imediatamente se sentir dor, tontura, dificuldade para respirar ou desconforto, e consulte um profissional qualificado.\n\n'
        '2) Contagem e feedback de IA\n'
        'Detecção de postura e contagem de repetições são estimativas e podem estar erradas por causa do ângulo da câmera, iluminação, oclusão, roupas ou velocidade do movimento.\n\n'
        '3) Desempenho durante gravação\n'
        'A contagem/contagem por voz foi projetada para funcionar bem em treinos normais com o telefone ligado. A detecção de postura (contagem) e a gravação de vídeo podem rodar juntas e normalmente funcionam bem por cerca de 5–15 minutos. Uso contínuo mais longo pode aumentar o aquecimento do dispositivo e o consumo de bateria, e a precisão pode diminuir.\n\n'
        '4) Situações de emergência\n'
        'Não dependa deste app para emergências. Contate os serviços de emergência locais imediatamente quando necessário.\n\n'
        '5) Responsabilidade do usuário\n'
        'Você é responsável por um espaço de treino seguro, técnica adequada e obter qualquer liberação médica necessária antes de treinar.\n\n'
        '6) Gravação e privacidade de terceiros\n'
        'Se gravar treinos, obtenha consentimento de qualquer pessoa que possa aparecer no vídeo ou áudio.\n\n'
        '7) Resultados\n'
        'Os resultados fitness variam por pessoa. O H&F não garante desempenho específico ou resultados de saúde.',
    'settings.select_theme': 'Selecionar tema',
    'settings.select_language': 'Selecionar idioma',
    'onboarding.language_title': 'Escolha seu idioma',
    'onboarding.language_subtitle':
        'Você pode alterar depois nas Configurações.',
    'onboarding.name_title': 'Qual é o seu nome?',
    'onboarding.name_subtitle': 'Isso aparecerá no seu perfil.',
    'onboarding.name_hint': 'Digite seu nome',
    'onboarding.name_required': 'Por favor, digite seu nome',
    'onboarding.disclaimer_title': 'Aviso',
    'onboarding.terms_title': 'Termos de serviço',
    'onboarding.accept_notice':
        'Concorde para continuar usando o app.',
    'onboarding.accept_checkbox': 'Concordo',
    'onboarding.continue': 'Continuar',
    'onboarding.start_app': 'Iniciar app',
    'settings.clear_all_data': 'Limpar todos os dados',
    'settings.clear_all_data_desc':
        'Isso excluirá todo o histórico de treinos, conquistas e configurações. Esta ação não pode ser desfeita.',
    'settings.clear_success':
        'Todos os dados do usuário foram limpos com sucesso.',
    'settings.clear_failed': 'Falha ao limpar dados: {error}',
    'theme.light': 'Claro',
    'theme.dark': 'Escuro',
    'theme.gold': 'Dourado',
    'theme.pink': 'Rosa',
    'progress.title': 'Progresso e análise',
    'progress.overview': 'Visão geral',
    'progress.exercises': 'Exercícios',
    'progress.badges': 'Emblemas',
    'progress.no_data': 'Nenhum dado disponível',
    'progress.weekly_summary': 'Resumo semanal',
    'progress.streak_days': '{count} dias de sequência',
    'progress.recent_workouts': 'Treinos recentes',
    'progress.no_workouts': 'Nenhum treino ainda',
    'progress.workout_summary': '{reps} reps • {accuracy}% de precisão',
    'progress.achievements': 'Conquistas',
    'progress.badges_unlocked': '{unlocked}/{total} emblemas desbloqueados',
    'progress.view_all_achievements': 'Ver todas as conquistas',
    'progress.day.sun': 'Dom',
    'progress.day.mon': 'Seg',
    'progress.day.tue': 'Ter',
    'progress.day.wed': 'Qua',
    'progress.day.thu': 'Qui',
    'progress.day.fri': 'Sex',
    'progress.day.sat': 'Sáb',
    'progress.time.just_now': 'Agora mesmo',
    'progress.time.minutes_ago': '{value}m atrás',
    'progress.time.hours_ago': '{value}h atrás',
    'progress.time.days_ago': '{value}d atrás',
    'progress.time.weeks_ago': '{value}s atrás',
    'progress.analytics_intro_title': 'Entendendo as análises de exercício',
    'progress.analytics_intro_line1':
        'Repetições totais = todas as reps salvas deste exercício em todas as sessões.',
    'progress.analytics_intro_line2':
        'Precisão média = média de precisão de forma de todas as sessões salvas.',
    'progress.analytics_intro_line3':
        'Gráfico de tendência = precisão ao longo do tempo (linha mais alta = melhor forma).',
    'progress.analytics_intro_line4':
        'As análises só atualizam após salvar uma sessão de treino.',
    'progress.read_exercise_analytics_title':
        'Como ler as análises de exercício',
    'progress.read_exercise_analytics_line1':
        'Precisão mais recente = sua pontuação de forma mais recente.',
    'progress.read_exercise_analytics_line2':
        'Melhor precisão = sua maior pontuação até agora.',
    'progress.read_exercise_analytics_line3':
        'As barras de sessão mostram as últimas 6 sessões. Barra mais alta significa melhor precisão.',
    'progress.read_exercise_analytics_line4':
        'O número abaixo de cada barra é o total de repetições daquela sessão.',
    'progress.latest_accuracy': 'Precisão mais recente',
    'progress.best_accuracy': 'Melhor precisão',
    'progress.trend_vs_previous_session': '{sign}{delta}% vs sessão anterior',
    'progress.last_sessions_accuracy_title': 'Últimas sessões (Precisão %)',
    'progress.reps_short': 'reps',
    'progress.chart_accuracy_trend_legend':
        'Barras mais altas indicam melhor precisão. Os rótulos abaixo são reps por sessão.',
    'progress.total_reps_all_time': 'Repetições totais (geral)',
    'progress.avg_accuracy_all_sessions': 'Precisão média (todas as sessões)',
    'progress.sessions': 'Sessões',
    'progress.chart_accuracy_trend':
        'O gráfico mostra a tendência de precisão por data de sessão.',
    'progress.no_sessions':
        'Nenhuma sessão ainda. Salve um treino para ver as análises aqui.',
    'badges.empty':
        'Nenhum emblema ainda.\nComece a treinar para desbloquear seu primeiro marco.',
    'badges.collection': 'Sua coleção de emblemas',
    'badges.current_status': 'Status atual do emblema',
    'badges.unlocked_count': '{unlocked}/{total} emblemas desbloqueados',
    'badges.tier': 'Nível: {tier}',
    'badges.next_target':
        'Próximo alvo: {name} ({progress}/{requirement}) - {percent}% concluído',
    'badges.how_it_works': 'Como este sistema de emblemas funciona',
    'badges.guide_1':
        'Os emblemas usam ritmo de 5 dias ativos e 2 dias de descanso. Apenas dias ativos contam para o progresso.',
    'badges.guide_2':
        'Treinos em dia de descanso são salvos normalmente, mas não somam nem subtraem progresso.',
    'badges.guide_3':
        'Metas diárias têm limite: reps/sets extra não dão crédito adicional.',
    'badges.guide_4':
        'Não precisa de halteres ou máquinas: você ainda pode ganhar emblemas com alternativas (ex.: push-ups para Upper, squats para Lower).',
    'badges.guide_5':
        'O progresso é calculado a partir dos logs salvos; dados reais determinam os desbloqueios.',
    'badges.unlocked_on': 'Desbloqueado em {date}',
    'badges.tap_full_plan': 'Toque para ver o plano completo',
    'badges.new_unlock_today': 'Desbloqueado hoje! Ótimo trabalho.',
    'badges.unlocked_banner':
        'Desbloqueado! Excelente consistência. Mantenha o ritmo.',
    'badges.poster_saved_note':
        'O pôster do emblema foi salvo automaticamente no álbum da galeria: {album}.',
    'badges.poster_save_failed_note':
        'Não foi possível salvar o pôster na galeria. Verifique a permissão de fotos.',
    'badges.no_tier': 'Nenhum nível desbloqueado ainda',
    'badges.motivation_unlocked':
        'Bom trabalho. Este emblema está garantido; agora avance para o próximo nível.',
    'badges.motivation_almost':
        'Quase lá. Faltam apenas {remaining} dia(s) qualificado(s).',
    'badges.motivation_keep':
        'Mantenha a consistência. Cada dia qualificado avança este emblema.',
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
        'Upper alvo: 8 reps no total (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise).',
    'badge.first_workout.detail3': 'Core alvo: 10 reps no total (Sit-up).',
    'badge.first_workout.detail4':
        'Lower alvo: 12 reps no total (Squat / Leg Extension).',
    'badge.prep.name': 'Preparação de 15 dias',
    'badge.prep.narrative':
        'Construa consistência com um ritmo de preparação de 15 dias.',
    'badge.prep.detail1':
        'Preparação de 15 dias com ciclo 5 ativos + 2 descansos (dias 6-7 e 13-14 são descanso).',
    'badge.prep.detail2':
        'Dias 1-3: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': 'Dias 4-5: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': 'Dias 8-12: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': 'Dia 15: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = sessões salvas por categoria no dia; dias de descanso não somam progresso.',
    'badge.prep.detail8':
        'Se você perder um dia ativo obrigatório, o progresso do prep é reiniciado e a sequência recomeça do Dia 1 no próximo dia de treino.',
    'badge.bronze.name': 'Mês 1 Bronze',
    'badge.bronze.narrative':
        'Mês de base para consistência do programa completo.',
    'badge.bronze.detail1':
        '30 dias ativos qualificados com ciclo 5 ativos + 2 descansos.',
    'badge.bronze.detail2':
        'Upper diário: 18 reps + 3 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise combinados).',
    'badge.bronze.detail3': 'Core diário: 24 reps + 3 sets (Sit-up).',
    'badge.bronze.detail4':
        'Lower diário: 30 reps + 3 sets (Squat / Leg Extension combinados).',
    'badge.bronze.detail5':
        'Reps/sets extras além do limite diário não contam progresso.',
    'badge.bronze.detail6':
        'Mesmo se você perder um dia, não precisa recomeçar do dia 1.',
    'badge.silver.name': 'Mês 2 Prata',
    'badge.silver.narrative':
        'Mês de progressão com requisitos de maior volume.',
    'badge.silver.detail1':
        '30 dias ativos qualificados com ciclo 5 ativos + 2 descansos.',
    'badge.silver.detail2':
        'Upper diário: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise combinados).',
    'badge.silver.detail3': 'Core diário: 32 reps + 4 sets (Sit-up).',
    'badge.silver.detail4':
        'Lower diário: 40 reps + 4 sets (Squat / Leg Extension combinados).',
    'badge.silver.detail5':
        'Apenas dias ativos contam; dias de descanso são ignorados.',
    'badge.silver.detail6':
        'Mesmo se você perder um dia, não precisa recomeçar do dia 1.',
    'badge.gold.name': 'Mês 3 Ouro',
    'badge.gold.narrative':
        'Mês de maestria com metas avançadas de resistência.',
    'badge.gold.detail1':
        '30 dias ativos qualificados com ciclo 5 ativos + 2 descansos.',
    'badge.gold.detail2':
        'Upper diário: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise combinados).',
    'badge.gold.detail3': 'Core diário: 40 reps + 4 sets (Sit-up).',
    'badge.gold.detail4':
        'Lower diário: 50 reps + 4 sets (Squat / Leg Extension combinados).',
    'badge.gold.detail5':
        'Progresso usa logs salvos; reps extras não dão crédito.',
    'badge.gold.detail6':
        'Mesmo se você perder um dia, não precisa recomeçar do dia 1.',
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
    'leaderboard.most_reps': 'Mais repetições',
    'leaderboard.best_accuracy': 'Melhor precisão',
    'leaderboard.longest_streak': 'Maior sequência',
    'leaderboard.days': 'Dias',
    'leaderboard.global_simulated': 'Leaderboard global (simulado)',
    'leaderboard.points': '{score} pts',
    'recordings.tab.recordings': 'Gravar',
    'recordings.tab.profile': 'Perfil',
    'recordings.failed_load': 'Falha ao carregar gravações',
    'recordings.empty': 'Nenhum vídeo gravado ainda',
    'recordings.file_not_found': 'Arquivo de vídeo não encontrado',
    'recordings.file_incomplete':
        'Arquivo de gravação incompleto. Grave novamente.',
    'profile.guest_name': 'Usuário',
    'profile.user_name_label': 'Nome de usuário',
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
        'A foto é grande demais. Escolha uma imagem menor.',
    'profile.photo_error':
        'Não foi possível salvar a foto. Tente outra imagem.',
    'profile.photo_badge_notice':
        'Se nenhuma foto de perfil for adicionada, os pôsteres de emblema serão gerados sem sua foto.',
    'profile.exercise_totals_title': 'Totais de exercícios',
    'profile.exercise_totals_subtitle': 'Da primeira à última sessão.',
    'profile.exercise_empty': 'Ainda não há dados de exercício',
    'profile.badges_title': 'Badges conquistadas',
    'profile.badges_empty': 'Ainda não há badges',
    'profile.badge_gallery_saved_note':
        'Quando um emblema é desbloqueado, seu pôster é salvo automaticamente no álbum da galeria: {album}.',
    'camera.overlay.skeleton': 'Esqueleto',
    'camera.overlay.stop': 'Parar',
    'camera.overlay.record': 'Gravar',
    'camera.overlay.complete': 'Concluir',
    'lang.en': 'Inglês',
    'lang.es': 'Espanhol',
    'lang.ja': 'Japonês',
    'lang.my': 'Birmanês',
    'lang.hi': 'Hindi',
    'lang.pt': 'Português',
    'lang.zh': 'Chinês mandarim',
    'lang.de': 'Alemão',
  };

  static const Map<String, String> _zhValues = {
    'app.title': 'H&F',
    'nav.exercises': '训练',
    'nav.progress': '进度',
    'nav.recordings': '录制和个人资料',
    'common.cancel': '取消',
    'common.retry': '重试',
    'common.load_exercises': '加载训练',
    'common.clear_data': '清除数据',
    'common.ok': '确定',
    'common.close': '关闭',
    'common.error_with_message': '错误：{message}',
    'premium.badge': '高级',
    'premium.menu_only': '此菜单仅限高级用户使用。',
    'home.exercises_list': '训练列表',
    'home.exercises_simple_form': '训练简易姿势',
    'home.no_supported_exercises': '没有可用的支持训练',
    'home.check_exercise_config': '请检查训练配置',
    'home.error_loading_exercise': '加载训练出错：{error}',
    'home.image_reference_count': '{count} 张参考图',
    'home.today_progress_premium': '今日进度（高级）',
    'home.today_progress_locked_desc': '进度菜单数据仅高级用户可用。',
    'home.today_progress': '今日进度',
    'home.total_reps': '总次数',
    'home.workouts': '训练',
    'home.calories': '卡路里',
    'home.daily_goal': '每日目标：{current}/{goal}',
    'home.daily_goal_achieved': '已达成每日目标！',
    'home.progress_premium_title': '进度为高级功能',
    'home.progress_premium_message': '详细进度分析在高级中解锁。',
    'home.recordings_premium_title': '录像为高级功能',
    'home.recordings_premium_message': '录像历史仅高级用户可用。',
    'home.simple_form': '{name} 姿势',
    'home.quick_form_summary': '姿势速览',
    'home.form_images': '姿势图片',
    'home.exercise_list_notice_title': '快速提醒',
    'home.exercise_list_notice_message':
        '请查看每个训练动作的表单，因为可能会有提示。注意：situp 训练有重要提示。',
    'home.simple_form_notice':
        '准确度条与计数提示：\n我们的 AI 按照视觉指南识别动作，可提供顺畅计数和较好准确度，但不提供正式技术指导。请记住，本应用并非 100% 准确。\n\n侧面视角的训练请保持侧面位置，正面视角的训练请保持正面位置，这样结果会更准确。\n\n以下情况可能导致识别不准确：\n• 身体没有完整出现在相机画面内。\n• 相机画面中有多于一人。\n• 房间太暗或有强烈的眩光/反射。\n• 将相机放在相对身体不过高也不过低的位置。',
    'home.situp_notice':
        '提示 1. 相机就位并选择好 situp 位置后，请先静止 2 秒再开始训练。\n2. 完成 situp 训练后，请至少坐 2 秒，然后走到相机前。',
    'exercise.guide.title': '快速指南',
    'exercise.guide.step1': '如果要创建骨架标记，请点击骨架按钮。',
    'exercise.guide.step2': '如果要录制视频，请点击录制按钮。',
    'exercise.guide.step3': '要停止并保存录制，请双击屏幕或点击返回按钮。',
    'exercise.guide.step4': '完成训练后点击完成按钮，再点击保存按钮保存训练。',
    'exercise.error.setup_title': '初始化错误',
    'exercise.error.setup_message': '初始化失败：{error}',
    'exercise.error.pose_title': '姿势检测错误',
    'exercise.error.pose_message': '无法初始化姿势检测。请确认 Google Play Services 已更新。',
    'exercise.premium.landmarks': '骨架标记叠加为高级功能。',
    'exercise.premium.recording': '视频录制仅在高级版提供。升级以解锁。',
    'exercise.recording.failed_start': '屏幕录制失败：{error}',
    'exercise.recording.permission_denied': '屏幕/音频录制权限被拒绝',
    'exercise.recording.failed_save': '屏幕录制保存失败',
    'exercise.recording.saved_gallery': '已保存到相册（{album}）',
    'exercise.recording.saved_app': '已保存到应用存储：{path}',
    'exercise.recording.saved_phone': '视频已保存到手机存储',
    'exercise.recording.failed_video': '视频录制失败：{error}',
    'exercise.recording.preparing_luxury_video':
        '我们正在为你准备高级质感的训练视频。',
    'exercise.recording.keep_screen_open':
        '请暂时保持此页面开启。',
    'exercise.premium.title': '高级功能',
    'exercise.premium.not_now': '暂不',
    'exercise.premium.upgrade': '升级',
    'exercise.premium.required_title': '需要高级版',
    'exercise.premium.required_message': '保存训练、计数和进度追踪仅在高级版提供。',
    'exercise.camera.error_title': '相机错误',
    'exercise.camera.error_message': '无法初始化相机。请检查权限并重试。',
    'exercise.counting_premium': '计数（高级）',
    'exercise.summary.title': '训练完成！',
    'exercise.summary.total_reps': '总次数',
    'exercise.summary.avg_accuracy': '平均准确度',
    'exercise.summary.duration': '时长',
    'exercise.summary.seconds': '{value} 秒',
    'exercise.summary.best_accuracy': '最佳单次准确度',
    'exercise.summary.close': '关闭',
    'exercise.summary.view_details': '保存',
    'exercise.card.type.dynamic': '动态',
    'exercise.card.type.static': '静态',
    'exercise.card.view.front': '正面',
    'exercise.card.view.side': '侧面',
    'exercise.card.total_reps': '总次数',
    'exercise.card.avg_accuracy': '平均准确度',
    'exercise.card.select': '选择训练',
    'exercise.time.today': '今天',
    'exercise.time.yesterday': '昨天',
    'exercise.time.days_ago': '{value} 天前',
    'exercise.time.weeks_ago': '{value} 周前',
    'exercise.time.months_ago': '{value} 个月前',
    'guide.squat.subtitle': '抬胸、髋部后坐，膝盖朝脚尖方向。',
    'guide.squat.step1': '双脚与肩同宽站立，收紧核心。',
    'guide.squat.step2': '脚跟不离地，下蹲至大腿接近平行。',
    'guide.squat.step3': '用脚跟发力站起，不要锁死膝盖。',
    'guide.pushup.subtitle': '保持头到脚跟一条直线，控制每一次。',
    'guide.pushup.step1': '双手略宽于肩，进入高位平板支撑。',
    'guide.pushup.step2': '肘部约45度弯曲，胸部下降。',
    'guide.pushup.step3': '保持核心紧张推回上方，髋部保持水平。',
    'guide.situp.subtitle': '用核心发力，不要用脖子拉起。',
    'guide.situp.step1': '仰卧屈膝，双脚踩地。',
    'guide.situp.step2': '收紧腹部抬起上身。',
    'guide.situp.step3': '控制下放后再进行下一次。',
    'guide.bicep.subtitle': '肘部贴近身体，避免摆动。',
    'guide.bicep.step1': '站立持哑铃，手心向前。',
    'guide.bicep.step2': '肩部不动，屈肘将重量卷起。',
    'guide.bicep.step3': '慢慢下放到完全伸展。',
    'guide.shoulder.subtitle': '肋骨下收，核心发力，垂直上推。',
    'guide.shoulder.step1': '重量在肩高，手腕保持中立。',
    'guide.shoulder.step2': '向上推至手臂伸直。',
    'guide.shoulder.step3': '控制下放回肩高。',
    'guide.leg.subtitle': '控制动作范围，避免膝盖猛然伸直。',
    'guide.leg.step1': '坐好靠背支撑，腿置于靠垫下。',
    'guide.leg.step2': '稳定髋部，伸膝抬起靠垫。',
    'guide.leg.step3': '慢慢下放至屈膝后重复。',
    'settings.title': '设置',
    'settings.premium_features': '高级功能',
    'settings.app_settings': '应用设置',
    'settings.profile_name': '个人资料名称',
    'settings.appearance': '外观',
    'settings.data': '数据',
    'settings.about': '关于',
    'settings.premium_account': '高级账户',
    'settings.unlock_all_features': '解锁全部高级功能',
    'settings.voice_counting': '语音计数',
    'settings.speak_count': '在动作时播报次数',
    'settings.voice_counting_language': '语音计数语言',
    'settings.upgrade_to_premium': '升级到高级',
    'settings.upgrade_subtitle': '获取语音计数、视频录制等',
    'settings.voice_coach': '语音教练',
    'settings.voice_feedback': '获得实时语音反馈',
    'settings.show_landmarks': '显示骨架点',
    'settings.display_skeleton': '显示骨架叠加',
    'settings.auto_recording': '自动录制',
    'settings.auto_recording_subtitle': '自动录制训练',
    'settings.theme': '主题',
    'settings.language': '语言',
    'settings.language_subtitle': '更改应用语言',
    'settings.clear_data': '清除数据',
    'settings.clear_data_subtitle': '删除所有训练记录',
    'settings.version': '版本',
    'settings.privacy_policy': '隐私政策',
    'settings.terms': '服务条款',
    'settings.disclaimer': '免责声明',
    'legal.last_updated': '最后更新: {date}',
    'legal.privacy.content':
        '1) 我们处理的数据\n'
        'H&F 会在您的设备上保存锻炼记录、徽章进度、应用偏好设置以及可选的录制文件路径。\n\n'
        '2) 高级版激活\n'
        '高级版激活至少需要联网一次。激活过程中，许可密钥、设备标识哈希、应用版本和平台会发送到我们的许可服务器。激活后，高级功能权限会在本地验证，应用即可离线使用。\n\n'
        '3) 相机、麦克风、存储与算力\n'
        '相机用于姿态识别。它会使用您的设备算力来分析姿态。麦克风与屏幕录制权限仅在使用录制功能时申请。保存的视频会存留在您的设备或图库中。\n\n'
        '4) 我们如何使用数据\n'
        '数据用于统计动作次数、计算准确性、追踪进度、解锁徽章并提供高级功能。\n\n'
        '5) 共享\n'
        '我们不出售您的个人数据。许可验证数据仅用于激活并保护高级访问权限。\n\n'
        '6) 您的控制权\n'
        '您可随时清除全部数据或卸载应用。清除数据会删除本地历史记录和已保存的高级状态。\n\n'
        '7) 安全性\n'
        '应用使用完整性校验和安全的本地存储来降低篡改风险，但任何系统都无法完全安全。',
    'legal.terms.content':
        '使用 H&F 即表示您同意这些条款。\n\n'
        '1) 服务使用\n'
        'H&F 是一款健身辅助应用。您需对自身的安全与健康决定负责。\n\n'
        '2) 账户与许可\n'
        '高级版需要有效的许可密钥。许可可能受设备限制，并可能因滥用、吊销或安全违规而被封禁。\n\n'
        '3) 离线模式\n'
        '激活成功后，核心和高级功能可在同一设备上离线运行。重新安装、清除敏感数据或完整性失败可能需要再次联网激活。\n\n'
        '4) 限制\n'
        '请勿篡改安全机制、逆向工程许可或将应用用于非法活动。\n\n'
        '5) 知识产权\n'
        '应用软件、品牌与内容仍归 H&F 及其许可方所有。\n\n'
        '6) 无担保\n'
        '应用按“原样”提供，不保证持续运行或能达到特定的健身效果。本应用的计数器可能因各种原因出现多计或少计。\n\n'
        '7) 责任限制\n'
        'H&F 对因使用应用而造成的间接、附带或后果性损害不承担责任。',
    'legal.disclaimer.content':
        'H&F 不是医疗服务，不提供医疗建议、诊断或治疗。\n\n'
        '1) 训练风险\n'
        '运动存在受伤风险。如感到疼痛、头晕、呼吸困难或不适，请立即停止并咨询合格专家。\n\n'
        '2) AI计数与动作反馈\n'
        '姿态识别与重复次数统计属于估算，可能因摄像角度、光线、遮挡、穿着或动作速度而出错。\n\n'
        '3) 录制时的性能\n'
        '在正常训练时打开手机，本应用的计数/语音计数被设计为可稳定工作。姿态识别（计数）与视频录制可同时运行，通常可良好运行约 5–15 分钟。更长时间的连续使用可能导致设备发热、耗电加快，且准确度可能下降。\n\n'
        '4) 紧急情况\n'
        '紧急情况下不要依赖本应用。需要时请立即联系当地应急服务。\n\n'
        '5) 用户责任\n'
        '您需确保训练空间安全、动作正确，并在训练前获取必要的医疗批准。\n\n'
        '6) 录制与他人隐私\n'
        '如果录制训练，请征得视频或音频中可能出现的所有人员同意。\n\n'
        '7) 结果\n'
        '健身效果因人而异。H&F 不保证特定表现或健康结果。',
    'settings.select_theme': '选择主题',
    'settings.select_language': '选择语言',
    'onboarding.language_title': '选择你的语言',
    'onboarding.language_subtitle': '你可以稍后在设置中更改。',
    'onboarding.name_title': '你的名字是？',
    'onboarding.name_subtitle': '这将显示在你的个人资料中。',
    'onboarding.name_hint': '输入你的名字',
    'onboarding.name_required': '请输入你的名字',
    'onboarding.disclaimer_title': '免责声明',
    'onboarding.terms_title': '服务条款',
    'onboarding.accept_notice': '同意后继续使用应用。',
    'onboarding.accept_checkbox': '我同意',
    'onboarding.continue': '继续',
    'onboarding.start_app': '开始使用',
    'settings.clear_all_data': '清除所有数据',
    'settings.clear_all_data_desc': '这将删除你的所有训练记录、成就和设置，且无法撤销。',
    'settings.clear_success': '用户数据已成功清除。',
    'settings.clear_failed': '清除数据失败：{error}',
    'theme.light': '浅色',
    'theme.dark': '深色',
    'theme.gold': '金色',
    'theme.pink': '粉色',
    'progress.title': '进度与分析',
    'progress.overview': '概览',
    'progress.exercises': '训练',
    'progress.badges': '徽章',
    'progress.no_data': '暂无数据',
    'progress.weekly_summary': '每周总结',
    'progress.streak_days': '连续 {count} 天',
    'progress.recent_workouts': '近期训练',
    'progress.no_workouts': '暂无训练',
    'progress.workout_summary': '{reps} 次 • 准确度 {accuracy}%',
    'progress.achievements': '成就',
    'progress.badges_unlocked': '已解锁 {unlocked}/{total} 徽章',
    'progress.view_all_achievements': '查看全部成就',
    'progress.day.sun': '日',
    'progress.day.mon': '一',
    'progress.day.tue': '二',
    'progress.day.wed': '三',
    'progress.day.thu': '四',
    'progress.day.fri': '五',
    'progress.day.sat': '六',
    'progress.time.just_now': '刚刚',
    'progress.time.minutes_ago': '{value} 分钟前',
    'progress.time.hours_ago': '{value} 小时前',
    'progress.time.days_ago': '{value} 天前',
    'progress.time.weeks_ago': '{value} 周前',
    'progress.analytics_intro_title': '了解训练分析',
    'progress.analytics_intro_line1': '总次数 = 此训练在所有会话中保存的全部次数。',
    'progress.analytics_intro_line2': '平均准确度 = 所有已保存会话的动作准确度平均值。',
    'progress.analytics_intro_line3': '趋势图 = 随时间的准确度（曲线越高表示动作越好）。',
    'progress.analytics_intro_line4': '只有在保存训练会话后分析才会更新。',
    'progress.read_exercise_analytics_title': '如何阅读训练分析',
    'progress.read_exercise_analytics_line1': '最新准确度 = 你最近一次的动作评分。',
    'progress.read_exercise_analytics_line2': '最佳准确度 = 你目前为止的最高评分。',
    'progress.read_exercise_analytics_line3': '会话柱状图显示最近 6 次会话。柱子越高表示准确度越好。',
    'progress.read_exercise_analytics_line4': '每个柱子下方的数字是该次会话的次数。',
    'progress.latest_accuracy': '最新准确度',
    'progress.best_accuracy': '最佳准确度',
    'progress.trend_vs_previous_session': '较上一会话 {sign}{delta}%',
    'progress.last_sessions_accuracy_title': '最近会话（准确度 %）',
    'progress.reps_short': '次',
    'progress.chart_accuracy_trend_legend': '柱子越高表示准确度越好。下方标签为每次会话的次数。',
    'progress.total_reps_all_time': '总次数（全部）',
    'progress.avg_accuracy_all_sessions': '平均准确度（全部会话）',
    'progress.sessions': '会话',
    'progress.chart_accuracy_trend': '图表显示按会话日期的准确度趋势。',
    'progress.no_sessions': '还没有会话。保存训练后可在此查看分析。',
    'badges.empty': '暂无徽章。\n开始训练以解锁第一个里程碑。',
    'badges.collection': '你的徽章收藏',
    'badges.current_status': '当前徽章状态',
    'badges.unlocked_count': '已解锁 {unlocked}/{total} 徽章',
    'badges.tier': '等级：{tier}',
    'badges.next_target':
        '下一个目标：{name} ({progress}/{requirement}) - 总体 {percent}% 完成',
    'badges.how_it_works': '徽章系统如何运作',
    'badges.guide_1': '徽章采用 5 天训练 + 2 天休息的节奏。只有活动日计入进度。',
    'badges.guide_2': '休息日的训练会正常保存，但不会增加或减少徽章进度。',
    'badges.guide_3': '每日目标有上限：超过上限的 reps/sets 不会增加徽章进度。',
    'badges.guide_4':
        '无需哑铃或器械：也可通过替代动作获得徽章（如 Upper 用 push-ups，Lower 用 squats）。',
    'badges.guide_5': '进度基于已保存的训练日志，真实数据推动解锁。',
    'badges.unlocked_on': '解锁于 {date}',
    'badges.tap_full_plan': '点击查看完整计划',
    'badges.new_unlock_today': '今天解锁！做得好。',
    'badges.unlocked_banner': '已解锁！坚持得很好，继续保持。',
    'badges.poster_saved_note': '徽章海报已自动保存到相册专辑：{album}。',
    'badges.poster_save_failed_note': '无法将徽章海报保存到相册，请检查照片权限。',
    'badges.no_tier': '尚未解锁等级',
    'badges.motivation_unlocked': '干得好。此徽章已稳固，继续冲下一个等级。',
    'badges.motivation_almost': '快到了。再完成 {remaining} 个合格天即可解锁。',
    'badges.motivation_keep': '保持连续性。每个合格日都会推进此徽章。',
    'tier.bronze': '青铜',
    'tier.silver': '白银',
    'tier.gold': '黄金',
    'tier.platinum': '白金',
    'badge.first_workout.name': '第一步',
    'badge.first_workout.narrative': '完成第一个合格的训练日。',
    'badge.first_workout.detail1': '目标：来自已保存训练日志的 1 个合格日。',
    'badge.first_workout.detail2':
        'Upper 目标：总计 8 次（Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise）。',
    'badge.first_workout.detail3': 'Core 目标：总计 10 次（Sit-up）。',
    'badge.first_workout.detail4': 'Lower 目标：总计 12 次（Squat / Leg Extension）。',
    'badge.prep.name': '15 天准备',
    'badge.prep.narrative': '通过 15 天节奏建立持续性。',
    'badge.prep.detail1': '15 天准备，5 天训练 + 2 天休息循环（第 6-7 天和第 13-14 天为休息）。',
    'badge.prep.detail2':
        '第 1-3 天：Upper 8 reps x 2 sets；Core 10 reps x 2 sets；Lower 12 reps x 2 sets。',
    'badge.prep.detail3': '第 4-5 天：Upper 10x2；Core 12x2；Lower 15x2。',
    'badge.prep.detail4': '第 8-12 天：Upper 12x2；Core 15x2；Lower 18x2。',
    'badge.prep.detail5': '第 15 天：Upper 12x3；Core 15x3；Lower 18x3。',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise；Core = Sit-up；Lower = Squat / Leg Extension。',
    'badge.prep.detail7': 'Sets = 一天内按类别保存的会话数量；休息日不计入进度。',
    'badge.prep.detail8': '如果错过任意一个必做的活动日，prep 进度会重置，并在下一个训练日从第 1 天重新开始。',
    'badge.bronze.name': '第 1 月 青铜',
    'badge.bronze.narrative': '全计划一致性的基础月。',
    'badge.bronze.detail1': '5 天训练 + 2 天休息循环的 30 个合格活动日。',
    'badge.bronze.detail2':
        'Upper 每日：18 reps + 3 sets（Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise 合计）。',
    'badge.bronze.detail3': 'Core 每日：24 reps + 3 sets（Sit-up）。',
    'badge.bronze.detail4':
        'Lower 每日：30 reps + 3 sets（Squat / Leg Extension 合计）。',
    'badge.bronze.detail5': '超过每日上限的 reps/sets 不计入进度。',
    'badge.bronze.detail6': '即使你漏掉一天，也不需要从第1天重新开始。',
    'badge.silver.name': '第 2 月 白银',
    'badge.silver.narrative': '更高训练量的进阶月。',
    'badge.silver.detail1': '5 天训练 + 2 天休息循环的 30 个合格活动日。',
    'badge.silver.detail2':
        'Upper 每日：24 reps + 4 sets（Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise 合计）。',
    'badge.silver.detail3': 'Core 每日：32 reps + 4 sets（Sit-up）。',
    'badge.silver.detail4':
        'Lower 每日：40 reps + 4 sets（Squat / Leg Extension 合计）。',
    'badge.silver.detail5': '只有活动日计入进度；休息日忽略。',
    'badge.silver.detail6': '即使你漏掉一天，也不需要从第1天重新开始。',
    'badge.gold.name': '第 3 月 黄金',
    'badge.gold.narrative': '高级耐力目标的巅峰月。',
    'badge.gold.detail1': '5 天训练 + 2 天休息循环的 30 个合格活动日。',
    'badge.gold.detail2':
        'Upper 每日：30 reps + 4 sets（Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise 合计）。',
    'badge.gold.detail3': 'Core 每日：40 reps + 4 sets（Sit-up）。',
    'badge.gold.detail4':
        'Lower 每日：50 reps + 4 sets（Squat / Leg Extension 合计）。',
    'badge.gold.detail5': '进度基于已保存日志；超额 reps 不计入。',
    'badge.gold.detail6': '即使你漏掉一天，也不需要从第1天重新开始。',
    'badge.default.goal': '目标：{description}',
    'badge.default.requirement': '要求：{requirement} 个合格日。',
    'badge.default.status': '当前状态：{progress}/{requirement}.',
    'badge.poster.badge_label': '徽章',
    'badge.poster.user_label': '达成者',
    'badge.poster.requirements_label': '合格数据',
    'leaderboard.title': '排行榜',
    'leaderboard.achievements': '成就',
    'leaderboard.global': '全球',
    'leaderboard.achievement_progress': '成就进度',
    'leaderboard.personal_bests': '个人最佳',
    'leaderboard.most_reps': '最多次数',
    'leaderboard.best_accuracy': '最高准确度',
    'leaderboard.longest_streak': '最长连续',
    'leaderboard.days': '天',
    'leaderboard.global_simulated': '全球排行榜（模拟）',
    'leaderboard.points': '{score} 分',
    'recordings.tab.recordings': '录制',
    'recordings.tab.profile': '个人资料',
    'recordings.failed_load': '加载录制失败',
    'recordings.empty': '暂无录制视频',
    'recordings.file_not_found': '未找到视频文件',
    'recordings.file_incomplete': '录制文件不完整。请重新录制。',
    'profile.guest_name': '用户',
    'profile.user_name_label': '用户名',
    'profile.edit_name': '编辑',
    'profile.name_hint': '输入你的名字',
    'profile.save_name': '保存',
    'profile.photo_title': '个人照片',
    'profile.photo_subtitle': '添加一张全身照，让你的个人主页更有个性。',
    'profile.photo_add': '添加照片',
    'profile.photo_change': '更换照片',
    'profile.photo_remove': '移除照片',
    'profile.photo_remove_confirm': '要移除你的个人照片吗？',
    'profile.photo_too_large': '照片太大，请选择更小的图片。',
    'profile.photo_error': '无法保存照片，请尝试其他图片。',
    'profile.photo_badge_notice': '如果未添加个人照片，徽章海报将不会包含你的照片。',
    'profile.exercise_totals_title': '累计训练',
    'profile.exercise_totals_subtitle': '从第一次训练到最近一次。',
    'profile.exercise_empty': '暂无训练数据',
    'profile.badges_title': '已获得徽章',
    'profile.badges_empty': '暂无徽章',
    'profile.badge_gallery_saved_note':
        '当徽章解锁时，其海报会自动保存到相册专辑：{album}。',
    'camera.overlay.skeleton': '骨架',
    'camera.overlay.stop': '停止',
    'camera.overlay.record': '录制',
    'camera.overlay.complete': '完成',
    'lang.en': '英语',
    'lang.es': '西班牙语',
    'lang.ja': '日语',
    'lang.my': '缅甸语',
    'lang.hi': '印地语',
    'lang.pt': '葡萄牙语',
    'lang.zh': '普通话',
    'lang.de': '德语',
  };

  static const Map<String, String> _deValues = {
    'app.title': 'H&F',
    'nav.exercises': 'Übungen',
    'nav.progress': 'Fortschritt',
    'nav.recordings': 'Aufnehmen und Profil',
    'common.cancel': 'Abbrechen',
    'common.retry': 'Erneut versuchen',
    'common.load_exercises': 'Übungen laden',
    'common.clear_data': 'Daten löschen',
    'common.ok': 'OK',
    'common.close': 'Schließen',
    'common.error_with_message': 'Fehler: {message}',
    'premium.badge': 'PREMIUM',
    'premium.menu_only': 'Dieses Menü ist nur für Premium‑Nutzer verfügbar.',
    'home.exercises_list': 'Übungsliste',
    'home.exercises_simple_form': 'Einfaches Übungsformular',
    'home.no_supported_exercises': 'Keine unterstützten Übungen verfügbar',
    'home.check_exercise_config': 'Bitte Übungskonfiguration prüfen',
    'home.error_loading_exercise': 'Fehler beim Laden der Übung: {error}',
    'home.image_reference_count': '{count} Referenzbild',
    'home.today_progress_premium': 'Heutiger Fortschritt (Premium)',
    'home.today_progress_locked_desc':
        'Daten des Fortschrittsmenüs sind nur für Premium‑Nutzer verfügbar.',
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
        'Videoaufnahmen‑Historie ist nur im Premium verfügbar.',
    'home.simple_form': '{name}-Form',
    'home.quick_form_summary': 'Kurze Formularzusammenfassung',
    'home.form_images': 'Formbilder',
    'home.exercise_list_notice_title': 'Kurzer Hinweis',
    'home.exercise_list_notice_message':
        'Bitte prüfe jedes Übungsformular, da es Hinweise geben kann. Hinweis: Die situp-Übung hat einen wichtigen Hinweis.',
    'home.simple_form_notice':
        'Hinweis zu Genauigkeitsbalken und Zählung:\nUnsere KI erkennt Übungen, die unseren visuellen Leitfäden nahekommen. Sie liefert eine flüssige Zählung mit guter Genauigkeit, bietet jedoch kein formales Technik‑Coaching. Bitte beachte, dass unsere App nicht 100% genau ist.\n\nBei Seitenansicht bitte in der Seitenposition bleiben und bei Frontansicht in der Frontposition bleiben. So sind die Ergebnisse korrekt.\n\nDie Erkennung kann ungenau sein, wenn:\n• Dein gesamter Körper nicht im Kamerabild zu sehen ist.\n• Es sind mehr als eine Person in der Kamera zu sehen.\n• Der Raum zu dunkel ist oder starke Flare/Blendung vorhanden ist.\n• Positioniere die Kamera so, dass sie weder zu niedrig noch zu hoch zu deinem Körper steht.',
    'home.situp_notice':
        'Hinweis 1. Nachdem die Kamera eingerichtet ist und der Platz für situp gewählt wurde, bitte zuerst 2 Sekunden still bleiben und dann beginnen.\n2. Nach dem situp-Training bitte mindestens 2 Sekunden sitzen und dann zur Kamera gehen.',
    'exercise.guide.title': 'Kurzanleitung',
    'exercise.guide.step1':
        'Wenn du ein Landmark erstellen möchtest, tippe auf den Skelett‑Button.',
    'exercise.guide.step2':
        'Wenn du ein Video aufnehmen möchtest, tippe auf den Aufnahme‑Button.',
    'exercise.guide.step3':
        'Um die Aufnahme zu stoppen und zu speichern, tippe zweimal auf den Bildschirm oder drücke den Zurück‑Button.',
    'exercise.guide.step4':
        'Wenn du fertig bist, tippe auf den Complete‑Button und danach auf Save, um das Training zu speichern.',
    'exercise.error.setup_title': 'Setup‑Fehler',
    'exercise.error.setup_message': 'Initialisierung fehlgeschlagen: {error}',
    'exercise.error.pose_title': 'Haltungs‑Erkennungsfehler',
    'exercise.error.pose_message':
        'Haltungs‑Erkennung konnte nicht gestartet werden. Bitte Google Play Services aktualisieren.',
    'exercise.premium.landmarks': 'Landmark‑Overlay ist ein Premium‑Feature.',
    'exercise.premium.recording':
        'Videoaufnahme ist in der Premium‑Version verfügbar. Upgrade zum Freischalten.',
    'exercise.recording.failed_start':
        'Bildschirmaufnahme fehlgeschlagen: {error}',
    'exercise.recording.permission_denied':
        'Berechtigung für Bildschirm/Audio‑Aufnahme verweigert',
    'exercise.recording.failed_save':
        'Bildschirmaufnahme konnte nicht gespeichert werden',
    'exercise.recording.saved_gallery': 'In Galerie gespeichert ({album})',
    'exercise.recording.saved_app': 'Im App‑Speicher gespeichert: {path}',
    'exercise.recording.saved_phone': 'Video im Telefonspeicher gespeichert',
    'exercise.recording.failed_video': 'Videoaufnahme fehlgeschlagen: {error}',
    'exercise.recording.preparing_luxury_video':
        'Wir bereiten gerade dein hochwertiges Workout-Video vor.',
    'exercise.recording.keep_screen_open':
        'Bitte lass diesen Bildschirm einen Moment geöffnet.',
    'exercise.premium.title': 'Premium‑Feature',
    'exercise.premium.not_now': 'Nicht jetzt',
    'exercise.premium.upgrade': 'Upgrade',
    'exercise.premium.required_title': 'Premium erforderlich',
    'exercise.premium.required_message':
        'Workout‑Speichern, Zählen und Fortschritt sind nur in Premium verfügbar.',
    'exercise.camera.error_title': 'Kamera‑Fehler',
    'exercise.camera.error_message':
        'Kamera konnte nicht initialisiert werden. Berechtigungen prüfen und erneut versuchen.',
    'exercise.counting_premium': 'Zählen (Premium)',
    'exercise.summary.title': 'Workout abgeschlossen!',
    'exercise.summary.total_reps': 'Gesamtwiederholungen',
    'exercise.summary.avg_accuracy': 'Durchschnittliche Genauigkeit',
    'exercise.summary.duration': 'Dauer',
    'exercise.summary.seconds': '{value} Sekunden',
    'exercise.summary.best_accuracy': 'Beste Wiederholungsgenauigkeit',
    'exercise.summary.close': 'Schließen',
    'exercise.summary.view_details': 'Speichern',
    'exercise.card.type.dynamic': 'Dynamisch',
    'exercise.card.type.static': 'Statisch',
    'exercise.card.view.front': 'Frontansicht',
    'exercise.card.view.side': 'Seitenansicht',
    'exercise.card.total_reps': 'Gesamtwiederholungen',
    'exercise.card.avg_accuracy': 'Ø Genauigkeit',
    'exercise.card.select': 'Übung auswählen',
    'exercise.time.today': 'Heute',
    'exercise.time.yesterday': 'Gestern',
    'exercise.time.days_ago': 'vor {value} Tagen',
    'exercise.time.weeks_ago': 'vor {value} Wochen',
    'exercise.time.months_ago': 'vor {value} Monaten',
    'guide.squat.subtitle':
        'Brust hoch, Hüfte nach hinten, Knie über den Zehen.',
    'guide.squat.step1': 'Schulterbreit stehen und Rumpf anspannen.',
    'guide.squat.step2':
        'Absenken, bis die Oberschenkel fast parallel sind, Fersen bleiben am Boden.',
    'guide.squat.step3':
        'Über die Fersen hochdrücken, Knie nicht durchstrecken.',
    'guide.pushup.subtitle':
        'Von Kopf bis Ferse eine Linie halten und jede Wiederholung kontrollieren.',
    'guide.pushup.step1':
        'In hoher Planke starten, Hände etwas weiter als schulterbreit.',
    'guide.pushup.step2': 'Brust absenken, Ellbogen ca. 45 Grad beugen.',
    'guide.pushup.step3': 'Hochdrücken, Rumpf fest und Hüfte stabil.',
    'guide.situp.subtitle':
        'Rumpf kontrolliert bewegen, nicht am Nacken ziehen.',
    'guide.situp.step1': 'Auf den Rücken legen, Knie beugen, Füße aufstellen.',
    'guide.situp.step2': 'Oberkörper durch Anspannen der Bauchmuskeln anheben.',
    'guide.situp.step3': 'Langsam kontrolliert absenken.',
    'guide.bicep.subtitle': 'Ellbogen nah am Körper, kein Schwung.',
    'guide.bicep.step1':
        'Aufrecht stehen, Hanteln halten, Handflächen nach vorn.',
    'guide.bicep.step2':
        'Gewichte durch Beugen der Ellbogen heben, Schultern bleiben ruhig.',
    'guide.bicep.step3':
        'Gewichte langsam absenken bis zur vollständigen Streckung.',
    'guide.shoulder.subtitle': 'Vertikal drücken, Rippen unten, Rumpf aktiv.',
    'guide.shoulder.step1': 'Gewichte auf Schulterhöhe, Handgelenke neutral.',
    'guide.shoulder.step2': 'Über Kopf drücken bis die Arme gestreckt sind.',
    'guide.shoulder.step3': 'Kontrolliert zurück auf Schulterhöhe absenken.',
    'guide.leg.subtitle':
        'Kontrollierter Bewegungsbereich, Knie nicht durchschnappen.',
    'guide.leg.step1': 'Sitzen mit Rückenstütze, Beine unter dem Polster.',
    'guide.leg.step2': 'Knie strecken, Polster anheben, Hüfte stabil.',
    'guide.leg.step3': 'Langsam absenken bis die Knie gebeugt sind.',
    'settings.title': 'Einstellungen',
    'settings.premium_features': 'Premium‑Funktionen',
    'settings.app_settings': 'App‑Einstellungen',
    'settings.profile_name': 'Profilname',
    'settings.appearance': 'Darstellung',
    'settings.data': 'Daten',
    'settings.about': 'Über',
    'settings.premium_account': 'Premium‑Konto',
    'settings.unlock_all_features': 'Alle Premium‑Funktionen freischalten',
    'settings.voice_counting': 'Sprachzählung',
    'settings.speak_count': 'Zählung während der Wiederholungen ansagen',
    'settings.voice_counting_language': 'Sprache der Sprachzählung',
    'settings.upgrade_to_premium': 'Auf Premium upgraden',
    'settings.upgrade_subtitle': 'Voice Count, Videoaufnahme und mehr',
    'settings.voice_coach': 'Voice Coach',
    'settings.voice_feedback': 'Echtzeit‑Sprachfeedback',
    'settings.show_landmarks': 'Landmarks anzeigen',
    'settings.display_skeleton': 'Skelett‑Overlay anzeigen',
    'settings.auto_recording': 'Auto‑Aufnahme',
    'settings.auto_recording_subtitle': 'Workouts automatisch aufnehmen',
    'settings.theme': 'Design',
    'settings.language': 'Sprache',
    'settings.language_subtitle': 'App‑Sprache ändern',
    'settings.clear_data': 'Daten löschen',
    'settings.clear_data_subtitle': 'Gesamten Trainingsverlauf löschen',
    'settings.version': 'Version',
    'settings.privacy_policy': 'Datenschutzrichtlinie',
    'settings.terms': 'Nutzungsbedingungen',
    'settings.disclaimer': 'Haftungsausschluss',
    'legal.last_updated': 'Zuletzt aktualisiert: {date}',
    'legal.privacy.content':
        '1) Welche Daten wir verarbeiten\n'
        'H&F speichert Trainingsprotokolle, Abzeichenfortschritt, App-Einstellungen und optional Pfade zu Aufzeichnungsdateien auf Ihrem Gerät.\n\n'
        '2) Premium-Aktivierung\n'
        'Die Premium-Aktivierung benötigt mindestens einmal eine Internetverbindung. Während der Aktivierung werden Lizenzschlüssel, Geräte-Hash, App-Version und Plattform an unseren Lizenzserver gesendet. Nach der Aktivierung wird der Premium-Status lokal validiert und die App kann offline genutzt werden.\n\n'
        '3) Kamera, Mikrofon, Speicher und Rechenleistung\n'
        'Die Kamera wird für die Pose-Erkennung verwendet. Zur Analyse der Pose nutzt die App die Rechenleistung Ihres Geräts. Mikrofon- und Bildschirmaufnahme-Berechtigungen werden nur benötigt, wenn Sie Aufnahmefunktionen nutzen. Gespeicherte Videos bleiben auf Ihrem Gerät oder in Ihrer Galerie erhalten.\n\n'
        '4) Wie wir Daten verwenden\n'
        'Daten dienen zum Zählen der Wiederholungen, Berechnen der Genauigkeit, Verfolgen des Fortschritts, Freischalten von Abzeichen und Bereitstellen von Premium-Funktionen.\n\n'
        '5) Weitergabe\n'
        'Wir verkaufen Ihre personenbezogenen Daten nicht. Lizenzprüfdaten werden ausschließlich zur Aktivierung und Sicherung des Premium-Zugangs verarbeitet.\n\n'
        '6) Ihre Kontrolle\n'
        'Sie können alle Daten löschen oder die App jederzeit deinstallieren. Das Löschen entfernt lokale Verlaufsdaten und gespeicherten Premium-Status.\n\n'
        '7) Sicherheit\n'
        'Die App nutzt Integritätsprüfungen und sichere lokale Speicherung, um Manipulationen zu erschweren, doch kein System ist vollkommen sicher.',
    'legal.terms.content':
        'Durch die Nutzung von H&F stimmen Sie diesen Bedingungen zu.\n\n'
        '1) Nutzung des Dienstes\n'
        'H&F ist eine Fitness-Support-App. Sie sind selbst für Ihre Sicherheit und Gesundheitsentscheidungen verantwortlich.\n\n'
        '2) Konto und Lizenz\n'
        'Premium erfordert einen gültigen Lizenzschlüssel. Lizenzen können gerätebezogen beschränkt und bei Missbrauch, Widerruf oder Sicherheitsverstößen gesperrt werden.\n\n'
        '3) Offline-Modus\n'
        'Nach erfolgreicher Aktivierung können Basis- und Premium-Funktionen auf demselben Gerät offline genutzt werden. Eine Neuinstallation, das Löschen sensibler Daten oder Integritätsfehler können eine erneute Online-Aktivierung erfordern.\n\n'
        '4) Einschränkungen\n'
        'Manipulation der Sicherheit, Reverse Engineering der Lizenz oder die Nutzung der App für rechtswidrige Aktivitäten sind untersagt.\n\n'
        '5) Geistiges Eigentum\n'
        'Software, Markenauftritt und Inhalte der App bleiben Eigentum von H&F und seinen Lizenzgebern.\n\n'
        '6) Keine Gewährleistung\n'
        'Die App wird „wie besehen“ bereitgestellt, ohne Garantie für durchgehenden Betrieb oder bestimmte Fitness-Ergebnisse. Der Zähler meiner App kann aus verschiedenen Gründen zu viel oder zu wenig gezählt haben.\n\n'
        '7) Haftungsbeschränkung\n'
        'H&F haftet nicht für mittelbare, zufällige oder Folgeschäden durch die Nutzung der App.',
    'legal.disclaimer.content':
        'H&F ist kein medizinischer Dienst und bietet keine medizinische Beratung, Diagnose oder Behandlung.\n\n'
        '1) Trainingsrisiko\n'
        'Sport birgt Verletzungsrisiken. Beenden Sie das Training sofort bei Schmerzen, Schwindel, Atemproblemen oder Unwohlsein und konsultieren Sie eine fachkundige Person.\n\n'
        '2) KI-Zählung und Formfeedback\n'
        'Posenerkennung und Wiederholungszählung sind Schätzungen und können durch Kamerawinkel, Lichtverhältnisse, Sichtbehinderung, Kleidung oder Bewegungsgeschwindigkeit falsch sein.\n\n'
        '3) Leistung beim Aufzeichnen\n'
        'Die Zählung/Sprachzählung ist dafür ausgelegt, während normaler Workouts mit eingeschaltetem Telefon zuverlässig zu funktionieren. Posenerkennung (Zählung) und Videoaufzeichnung können gleichzeitig laufen und funktionieren in der Regel etwa 5–15 Minuten gut. Längere, durchgehende Nutzung kann zu stärkerer Erwärmung, höherem Akkuverbrauch und geringerer Genauigkeit führen.\n\n'
        '4) Notfälle\n'
        'Verlassen Sie sich in Notfällen nicht auf diese App. Kontaktieren Sie stattdessen umgehend lokale Notdienste.\n\n'
        '5) Verantwortung des Nutzers\n'
        'Sie sind für einen sicheren Trainingsbereich, eine korrekte Technik und das Einholen erforderlicher medizinischer Freigaben verantwortlich.\n\n'
        '6) Aufzeichnungen und Privatsphäre Dritter\n'
        'Wenn Sie Workouts aufnehmen, holen Sie die Einwilligung aller Personen ein, die im Video oder Audio erscheinen könnten.\n\n'
        '7) Ergebnisse\n'
        'Fitness-Ergebnisse variieren individuell. H&F garantiert keine bestimmten Leistungen oder gesundheitlichen Resultate.',
    'settings.select_theme': 'Design auswählen',
    'settings.select_language': 'Sprache auswählen',
    'onboarding.language_title': 'Sprache auswählen',
    'onboarding.language_subtitle':
        'Du kannst das später in den Einstellungen ändern.',
    'onboarding.name_title': 'Wie heißt du?',
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
    'settings.clear_all_data': 'Alle Daten löschen',
    'settings.clear_all_data_desc':
        'Dadurch werden Trainingsverlauf, Erfolge und Einstellungen gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.',
    'settings.clear_success': 'Alle Benutzerdaten wurden erfolgreich gelöscht.',
    'settings.clear_failed': 'Daten löschen fehlgeschlagen: {error}',
    'theme.light': 'Hell',
    'theme.dark': 'Dunkel',
    'theme.gold': 'Gold',
    'theme.pink': 'Rosa',
    'progress.title': 'Fortschritt & Analyse',
    'progress.overview': 'Übersicht',
    'progress.exercises': 'Übungen',
    'progress.badges': 'Badges',
    'progress.no_data': 'Keine Daten verfügbar',
    'progress.weekly_summary': 'Wöchentliche Zusammenfassung',
    'progress.streak_days': '{count} Tage am Stück',
    'progress.recent_workouts': 'Letzte Workouts',
    'progress.no_workouts': 'Noch keine Workouts',
    'progress.workout_summary':
        '{reps} Wiederholungen • {accuracy}% Genauigkeit',
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
    'progress.analytics_intro_title': 'Übungsanalyse verstehen',
    'progress.analytics_intro_line1':
        'Gesamtwiederholungen = alle gespeicherten Wiederholungen dieser Übung über alle Sessions.',
    'progress.analytics_intro_line2':
        'Ø Genauigkeit = durchschnittliche Formgenauigkeit aller gespeicherten Sessions.',
    'progress.analytics_intro_line3':
        'Trend‑Chart = Genauigkeit über die Zeit (höhere Linie = bessere Form).',
    'progress.analytics_intro_line4':
        'Analysen aktualisieren sich erst nach dem Speichern einer Session.',
    'progress.read_exercise_analytics_title': 'So liest du Trainingsanalysen',
    'progress.read_exercise_analytics_line1':
        'Neueste Genauigkeit = dein aktuellster Form-Score.',
    'progress.read_exercise_analytics_line2':
        'Beste Genauigkeit = dein bisher höchster Score.',
    'progress.read_exercise_analytics_line3':
        'Die Sitzungsbalken zeigen die letzten 6 Sessions. Ein höherer Balken bedeutet bessere Genauigkeit.',
    'progress.read_exercise_analytics_line4':
        'Die Zahl unter jedem Balken sind die Wiederholungen dieser Session.',
    'progress.latest_accuracy': 'Neueste Genauigkeit',
    'progress.best_accuracy': 'Beste Genauigkeit',
    'progress.trend_vs_previous_session':
        '{sign}{delta}% gegenüber der vorherigen Session',
    'progress.last_sessions_accuracy_title': 'Letzte Sessions (Genauigkeit %)',
    'progress.reps_short': 'Wdh',
    'progress.chart_accuracy_trend_legend':
        'Höhere Balken bedeuten bessere Genauigkeit. Die Beschriftung unten zeigt Wiederholungen je Session.',
    'progress.total_reps_all_time': 'Gesamtwiederholungen (gesamt)',
    'progress.avg_accuracy_all_sessions': 'Ø Genauigkeit (alle Sessions)',
    'progress.sessions': 'Sessions',
    'progress.chart_accuracy_trend':
        'Diagramm zeigt den Genauigkeitstrend nach Session‑Datum.',
    'progress.no_sessions':
        'Noch keine Sessions. Speichere ein Workout, um Analysen zu sehen.',
    'badges.empty':
        'Noch keine Badges.\nStarte Workouts, um den ersten Meilenstein freizuschalten.',
    'badges.collection': 'Deine Badge‑Sammlung',
    'badges.current_status': 'Aktueller Badge‑Status',
    'badges.unlocked_count': '{unlocked}/{total} Badges freigeschaltet',
    'badges.tier': 'Stufe: {tier}',
    'badges.next_target':
        'Nächstes Ziel: {name} ({progress}/{requirement}) – {percent}% abgeschlossen',
    'badges.how_it_works': 'So funktioniert das Badge‑System',
    'badges.guide_1':
        'Badges folgen dem Rhythmus 5 Tage aktiv, 2 Tage Pause. Nur aktive Tage zählen.',
    'badges.guide_2':
        'Workouts an Ruhetagen werden gespeichert, ändern aber den Badge‑Fortschritt nicht.',
    'badges.guide_3':
        'Tagesziele sind gedeckelt: zusätzliche Wiederholungen/Sets bringen keinen Extra‑Fortschritt.',
    'badges.guide_4':
        'Keine Hanteln oder Geräte nötig: Badges sind auch mit Alternativen möglich (z. B. push-ups für Upper, squats für Lower).',
    'badges.guide_5':
        'Fortschritt wird aus gespeicherten Logs berechnet; reale Daten steuern die Freischaltungen.',
    'badges.unlocked_on': 'Freigeschaltet am {date}',
    'badges.tap_full_plan': 'Tippen, um den kompletten Plan zu sehen',
    'badges.new_unlock_today': 'Heute freigeschaltet! Gute Arbeit.',
    'badges.unlocked_banner':
        'Freigeschaltet! Großartige Konstanz. Bleib dran.',
    'badges.poster_saved_note':
        'Das Badge-Poster wurde automatisch im Galerie-Album {album} gespeichert.',
    'badges.poster_save_failed_note':
        'Badge-Poster konnte nicht in der Galerie gespeichert werden. Bitte Foto-Berechtigung prüfen.',
    'badges.no_tier': 'Noch keine Stufe freigeschaltet',
    'badges.motivation_unlocked':
        'Gut gemacht. Dieses Badge ist sicher; jetzt zur nächsten Stufe.',
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
        'Schließe deinen ersten qualifizierten Workout‑Tag ab.',
    'badge.first_workout.detail1':
        'Ziel: 1 qualifizierter Tag aus gespeicherten Workout‑Logs.',
    'badge.first_workout.detail2':
        'Upper‑Ziel: 8 Wiederholungen gesamt (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise).',
    'badge.first_workout.detail3':
        'Core‑Ziel: 10 Wiederholungen gesamt (Sit-up).',
    'badge.first_workout.detail4':
        'Lower‑Ziel: 12 Wiederholungen gesamt (Squat / Leg Extension).',
    'badge.prep.name': '15‑Tage‑Vorbereitung',
    'badge.prep.narrative': 'Baue Konstanz mit einem 15‑Tage‑Rhythmus auf.',
    'badge.prep.detail1':
        '15‑Tage‑Vorbereitung mit 5 aktiv + 2 Ruhe‑Zyklus (Tag 6-7 und Tag 13-14 sind Ruhetage).',
    'badge.prep.detail2':
        'Tage 1-3: Upper 8 reps x 2 sets; Core 10 reps x 2 sets; Lower 12 reps x 2 sets.',
    'badge.prep.detail3': 'Tage 4-5: Upper 10x2; Core 12x2; Lower 15x2.',
    'badge.prep.detail4': 'Tage 8-12: Upper 12x2; Core 15x2; Lower 18x2.',
    'badge.prep.detail5': 'Tag 15: Upper 12x3; Core 15x3; Lower 18x3.',
    'badge.prep.detail6':
        'Upper = Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise; Core = Sit-up; Lower = Squat / Leg Extension.',
    'badge.prep.detail7':
        'Sets = gespeicherte Sessions pro Kategorie am Tag; Ruhetage zählen nicht.',
    'badge.prep.detail8':
        'Wenn du einen erforderlichen aktiven Tag verpasst, wird der Prep-Fortschritt zurückgesetzt und der Lauf beginnt am nächsten Trainingstag wieder bei Tag 1.',
    'badge.bronze.name': 'Monat 1 Bronze',
    'badge.bronze.narrative': 'Grundlagenmonat für Programmkonsistenz.',
    'badge.bronze.detail1':
        '30 qualifizierte aktive Tage mit 5 aktiv + 2 Ruhe‑Zyklus.',
    'badge.bronze.detail2':
        'Upper täglich: 18 reps + 3 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise kombiniert).',
    'badge.bronze.detail3': 'Core täglich: 24 reps + 3 sets (Sit-up).',
    'badge.bronze.detail4':
        'Lower täglich: 30 reps + 3 sets (Squat / Leg Extension kombiniert).',
    'badge.bronze.detail5':
        'Zusätzliche reps/sets über dem Tageslimit zählen nicht.',
    'badge.bronze.detail6':
        'Auch wenn du einen Tag verpasst, musst du nicht wieder bei Tag 1 anfangen.',
    'badge.silver.name': 'Monat 2 Silber',
    'badge.silver.narrative': 'Progressionsmonat mit höherem Umfang.',
    'badge.silver.detail1':
        '30 qualifizierte aktive Tage mit 5 aktiv + 2 Ruhe‑Zyklus.',
    'badge.silver.detail2':
        'Upper täglich: 24 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise kombiniert).',
    'badge.silver.detail3': 'Core täglich: 32 reps + 4 sets (Sit-up).',
    'badge.silver.detail4':
        'Lower täglich: 40 reps + 4 sets (Squat / Leg Extension kombiniert).',
    'badge.silver.detail5':
        'Nur aktive Tage zählen; Ruhetage werden ignoriert.',
    'badge.silver.detail6':
        'Auch wenn du einen Tag verpasst, musst du nicht wieder bei Tag 1 anfangen.',
    'badge.gold.name': 'Monat 3 Gold',
    'badge.gold.narrative': 'Meisterschaftsmonat mit hohen Ausdauerzielen.',
    'badge.gold.detail1':
        '30 qualifizierte aktive Tage mit 5 aktiv + 2 Ruhe‑Zyklus.',
    'badge.gold.detail2':
        'Upper täglich: 30 reps + 4 sets (Push-up / Shoulder Press / Bicep Curl / Bench Press / Lateral Raise / Front Raise kombiniert).',
    'badge.gold.detail3': 'Core täglich: 40 reps + 4 sets (Sit-up).',
    'badge.gold.detail4':
        'Lower täglich: 50 reps + 4 sets (Squat / Leg Extension kombiniert).',
    'badge.gold.detail5':
        'Fortschritt basiert auf Logs; extra reps zählen nicht.',
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
    'leaderboard.personal_bests': 'Persönliche Bestleistungen',
    'leaderboard.most_reps': 'Meiste Wiederholungen',
    'leaderboard.best_accuracy': 'Beste Genauigkeit',
    'leaderboard.longest_streak': 'Längste Serie',
    'leaderboard.days': 'Tage',
    'leaderboard.global_simulated': 'Globales Leaderboard (Simuliert)',
    'leaderboard.points': '{score} Pkt',
    'recordings.tab.recordings': 'Aufnehmen',
    'recordings.tab.profile': 'Profil',
    'recordings.failed_load': 'Aufnahmen konnten nicht geladen werden',
    'recordings.empty': 'Noch keine aufgenommenen Videos',
    'recordings.file_not_found': 'Videodatei nicht gefunden',
    'recordings.file_incomplete':
        'Aufnahmedatei ist unvollständig. Bitte erneut aufnehmen.',
    'profile.guest_name': 'Benutzer',
    'profile.user_name_label': 'Benutzername',
    'profile.edit_name': 'Bearbeiten',
    'profile.name_hint': 'Name eingeben',
    'profile.save_name': 'Speichern',
    'profile.photo_title': 'Profilfoto',
    'profile.photo_subtitle':
        'Füge ein Ganzkörperfoto hinzu, um dein Profil zu personalisieren.',
    'profile.photo_add': 'Foto hinzufügen',
    'profile.photo_change': 'Foto ändern',
    'profile.photo_remove': 'Foto entfernen',
    'profile.photo_remove_confirm': 'Profilfoto entfernen?',
    'profile.photo_too_large':
        'Das Foto ist zu groß. Bitte wähle ein kleineres Bild.',
    'profile.photo_error':
        'Foto konnte nicht gespeichert werden. Bitte anderes Bild versuchen.',
    'profile.photo_badge_notice':
        'Wenn kein Profilfoto hinzugefügt wurde, enthalten Badge-Poster kein Foto von dir.',
    'profile.exercise_totals_title': 'Gesamte Trainingszahlen',
    'profile.exercise_totals_subtitle': 'Von der ersten bis zur letzten Einheit.',
    'profile.exercise_empty': 'Noch keine Trainingsdaten',
    'profile.badges_title': 'Erhaltene Abzeichen',
    'profile.badges_empty': 'Noch keine Abzeichen',
    'profile.badge_gallery_saved_note':
        'Wenn ein Badge freigeschaltet wird, wird sein Poster automatisch im Galerie-Album {album} gespeichert.',
    'camera.overlay.skeleton': 'Skelett',
    'camera.overlay.stop': 'Stopp',
    'camera.overlay.record': 'Aufnehmen',
    'camera.overlay.complete': 'Abschließen',
    'lang.en': 'Englisch',
    'lang.es': 'Spanisch',
    'lang.ja': 'Japanisch',
    'lang.my': 'Birmanisch',
    'lang.hi': 'Hindi',
    'lang.pt': 'Portugiesisch',
    'lang.zh': 'Mandarin‑Chinesisch',
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
