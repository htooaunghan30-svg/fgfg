// lib/presentation/screens/home_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/exercise_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/exercise_card.dart';
import 'progress_screen.dart';
import 'video_recordings_screen.dart';
import 'exercise_screen.dart';
import 'iconic_programs_screen.dart';
import 'premium_activation_screen.dart';
import 'legal_document_screen.dart';
import 'workout_overlay_customizer_screen.dart';
import '../../core/constants/exercise_config.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/themes/color_scheme.dart';
import '../../data/models/exercise_model.dart';
import '../../data/services/data_management_service.dart';
import '../../features/gamification/monthly_badge_debug_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // AppBar brand icon (also reused for launcher icon generation).
  static const String _appIconAsset = 'assets/images/appicon.png';
  int _selectedIndex = 0;
  bool _isMonthlyBadgeDebugBusy = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Initialize providers
    final exerciseProvider =
        Provider.of<ExerciseProvider>(context, listen: false);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await exerciseProvider.initialize();
      await userProvider.initialize();
    } catch (e) {
      print('Error initializing data: $e');
    }
  }

  static const List<Widget> _widgetOptions = <Widget>[
    _ExercisesTab(),
    IconicProgramsScreen(),
    _ProgressTab(),
    _VideoRecordingsTab(),
  ];

  void _onItemTapped(int index) {
    final userProvider = context.read<UserProvider>();
    final requiresPremium = index == 2 || index == 3; // Progress + Recordings

    if (requiresPremium && !userProvider.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('premium.menu_only')),
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _openMonthlyBadgeDebugMenu() async {
    final colors = Theme.of(context).colorScheme;
    final scenario = await showModalBottomSheet<MonthlyBadgeDebugScenario>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Badge Sandbox',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Debug only. This clears local workout logs, daily activity, and badge progress, then seeds a synthetic timeline up to the scenario you choose.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: colors.onSurface.withOpacity(0.72),
                ),
              ),
              const SizedBox(height: 16),
              for (final scenario in MonthlyBadgeDebugScenario.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.science_rounded),
                  title: Text('Seed ${scenario.label}'),
                  subtitle: Text(
                    _scenarioDescription(scenario),
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(scenario),
                ),
            ],
          ),
        ),
      ),
    );

    if (scenario != null) {
      await _runMonthlyBadgeDebugScenario(scenario);
    }
  }

  Future<void> _runMonthlyBadgeDebugScenario(
    MonthlyBadgeDebugScenario scenario,
  ) async {
    if (_isMonthlyBadgeDebugBusy) {
      return;
    }

    setState(() {
      _isMonthlyBadgeDebugBusy = true;
    });

    try {
      context.read<UserProvider>().suppressBadgePosterAutoSaveOnce();
      final result = await MonthlyBadgeDebugHelper().seedScenario(scenario);
      await context.read<UserProvider>().loadBadges();
      if (!mounted) {
        return;
      }
      await _showMonthlyBadgeDebugResult(result);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Monthly badge sandbox failed: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isMonthlyBadgeDebugBusy = false;
        });
      }
    }
  }

  Future<void> _showMonthlyBadgeDebugResult(
    MonthlyBadgeDebugResult result,
  ) async {
    final colors = Theme.of(context).colorScheme;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('${result.scenario.label} Seed Complete'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.summary,
                style: TextStyle(
                  height: 1.35,
                  color: colors.onSurface.withOpacity(0.82),
                ),
              ),
              const SizedBox(height: 14),
              for (final badgeId in MonthlyBadgeDebugResult.orderedBadgeIds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildMonthlyBadgeResultRow(
                    badgeId: badgeId,
                    result: result,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBadgeResultRow({
    required String badgeId,
    required MonthlyBadgeDebugResult result,
  }) {
    final badge = result.badge(badgeId);
    final colors = Theme.of(context).colorScheme;
    final isUnlocked = badge?.isUnlocked ?? false;
    final progress =
        badge == null ? '--/--' : '${badge.progress}/${badge.requirement}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _badgeDebugName(badgeId),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0x1A16A34A)
                      : const Color(0x1AE11D48),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isUnlocked ? 'Unlocked' : 'Locked',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isUnlocked
                        ? const Color(0xFF166534)
                        : const Color(0xFFBE123C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Progress: $progress',
            style: TextStyle(
              color: colors.onSurface.withOpacity(0.76),
            ),
          ),
          if ((badge?.unlockedAt.millisecondsSinceEpoch ?? 0) > 0)
            Text(
              'Unlocked at: ${badge!.unlockedAt.toLocal()}',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurface.withOpacity(0.64),
              ),
            ),
        ],
      ),
    );
  }

  String _scenarioDescription(MonthlyBadgeDebugScenario scenario) {
    switch (scenario) {
      case MonthlyBadgeDebugScenario.bronze:
        return 'First workout + full 15-day prep + Bronze month.';
      case MonthlyBadgeDebugScenario.silver:
        return 'Prep + Bronze + Silver monthly progress.';
      case MonthlyBadgeDebugScenario.gold:
        return 'Prep + Bronze + Silver + Gold monthly progress.';
    }
  }

  String _badgeDebugName(String badgeId) {
    switch (badgeId) {
      case 'first_workout':
        return 'First Steps';
      case 'prep_phase_15_v2':
        return 'Prep Phase';
      case 'month_1_bronze':
        return 'Month 1 Bronze';
      case 'month_2_silver':
        return 'Month 2 Silver';
      case 'month_3_gold':
        return 'Month 3 Gold';
      default:
        return badgeId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 12,
        title: _buildBrandTitle(),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.18),
                theme.colorScheme.secondary.withOpacity(0.08),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
        actions: [
          // Premium Badge
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isPremium) {
                return _buildPremiumAppChip(context);
              }
              return const SizedBox();
            },
          ),
          if (kDebugMode)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildActionIconButton(
                context: context,
                icon: _isMonthlyBadgeDebugBusy
                    ? Icons.hourglass_top_rounded
                    : Icons.science_rounded,
                onTap: _openMonthlyBadgeDebugMenu,
              ),
            ),

          // Settings Button
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _buildActionIconButton(
              context: context,
              icon: Icons.tune_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(context, theme),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color shellColor =
        isDark ? const Color(0xFF110D1B) : const Color(0xFFF7F9FC);
    final Color railColor =
        isDark ? const Color(0xFF1D172C) : const Color(0xFFFFFFFF);
    final Color selectedColor = colorScheme.primary;
    final Color unselectedColor =
        colorScheme.onSurface.withOpacity(isDark ? 0.72 : 0.62);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            shellColor.withOpacity(0.0),
            shellColor.withOpacity(isDark ? 0.94 : 0.92),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: railColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: selectedColor.withOpacity(isDark ? 0.18 : 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.24 : 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: railColor,
              elevation: 0,
              iconSize: 23,
              selectedItemColor: selectedColor,
              unselectedItemColor: unselectedColor,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.fitness_center_outlined),
                  activeIcon: const Icon(Icons.fitness_center_rounded),
                  label: context.tr('nav.exercises'),
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_outlined),
                  activeIcon: Icon(Icons.auto_awesome_rounded),
                  label: 'Iconic',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.insights_outlined),
                  activeIcon: const Icon(Icons.insights_rounded),
                  label: context.tr('nav.progress'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.video_collection_outlined),
                  activeIcon: const Icon(Icons.video_collection_rounded),
                  label: context.tr('recordings.tab.recordings'),
                  tooltip: context.tr('nav.recordings'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              _appIconAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFF1F2937),
                child: Center(
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('app.title'),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Premium Fitness System',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.72),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumAppChip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD76A),
              Color(0xFFFFB347),
              Color(0xFFF59E0B),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33F59E0B),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              context.tr('premium.badge'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.68),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
          ),
        ),
      ),
    );
  }
}

class _SettingsTitleBar extends StatelessWidget {
  final String title;
  final bool isPremium;

  const _SettingsTitleBar({
    required this.title,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8B5CF6),
                Color(0xFF06B6D4),
              ],
            ),
          ),
          child: const Icon(
            Icons.tune_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
        if (isPremium)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: AppColorScheme.premiumGradient,
              ),
            ),
            child: const Icon(
              Icons.star_rounded,
              size: 14,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}

class _ExercisesTab extends StatefulWidget {
  const _ExercisesTab();

  @override
  State<_ExercisesTab> createState() => __ExercisesTabState();
}

class __ExercisesTabState extends State<_ExercisesTab>
    with SingleTickerProviderStateMixin {
  static const String _exerciseListNoticePrefsKey =
      'exercise_list_notice_shown';
  late final TabController _tabController;
  static const List<String> _supportedExerciseIds = [
    'squat',
    'pushup',
    'situp',
    'bicep_curl',
    'shoulder_press',
    'bench_press',
    'lateral_raise',
    'front_raise',
    'leg_extension',
  ];

  static const List<_ExerciseSimpleFormGuide> _simpleFormGuides = [
    _ExerciseSimpleFormGuide(
      id: 'squat',
      title: 'Squat',
      imagePaths: [
        'assets/images/body_weight_squat.png',
        'assets/images/sumo_squat.png',
      ],
    ),
    _ExerciseSimpleFormGuide(
      id: 'pushup',
      title: 'Push Up',
      imagePaths: ['assets/images/push_up.png'],
    ),
    _ExerciseSimpleFormGuide(
      id: 'situp',
      title: 'Sit Up',
      imagePaths: ['assets/images/situp.png'],
    ),
    _ExerciseSimpleFormGuide(
      id: 'bicep_curl',
      title: 'Bicep Curl',
      imagePaths: ['assets/images/bicep_curl.png'],
    ),
    _ExerciseSimpleFormGuide(
      id: 'shoulder_press',
      title: 'Shoulder Press',
      imagePaths: ['assets/images/shoulderpress.png'],
    ),
    _ExerciseSimpleFormGuide(
      id: 'front_raise',
      title: 'Front Raise',
      imagePaths: ['assets/images/lateral_raise.png'],
    ),
    _ExerciseSimpleFormGuide(
      id: 'leg_extension',
      title: 'Leg Extension',
      imagePaths: ['assets/images/leg_extension.png'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleTabChange());
    _loadData();
  }

  Future<void> _loadData() async {
    final exerciseProvider = Provider.of<ExerciseProvider>(
      context,
      listen: false,
    );

    if (exerciseProvider.exercises.isEmpty) {
      await exerciseProvider.initialize();
    }
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    if (_tabController.index == 0) {
      _maybeShowExerciseListNotice();
    }
  }

  Future<void> _maybeShowExerciseListNotice() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_exerciseListNoticePrefsKey) == true) {
      return;
    }
    await prefs.setBool(_exerciseListNoticePrefsKey, true);
    if (!mounted) return;

    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colors = theme.colorScheme;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.t('home.exercise_list_notice_title'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.t('home.exercise_list_notice_message'),
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('common.close')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final exerciseProvider = Provider.of<ExerciseProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final supportedExercises = _supportedExerciseIds
        .map(exerciseProvider.getExerciseById)
        .whereType<ExerciseModel>()
        .toList();

    if (exerciseProvider.isLoading && exerciseProvider.exercises.isEmpty) {
      return Center(
        child: Image.asset(
          'assets/images/appicon.png',
          width: 56,
          height: 56,
        ),
      );
    }

    if (exerciseProvider.error != null && exerciseProvider.exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.t(
                'common.error_with_message',
                params: {'message': '${exerciseProvider.error}'},
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => exerciseProvider.initialize(),
              child: Text(l10n.t('common.retry')),
            ),
          ],
        ),
      );
    }

    if (supportedExercises.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            l10n.t('home.no_supported_exercises'),
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('home.check_exercise_config'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => exerciseProvider.initialize(),
            child: Text(l10n.t('common.load_exercises')),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildDailyStatsCard(context, exerciseProvider, userProvider),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            tabs: [
              Tab(text: l10n.t('home.exercises_list')),
              Tab(text: l10n.t('home.exercises_simple_form')),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ExerciseGrid(
                exercises: supportedExercises,
                favoriteExercises: userProvider.favoriteExercises,
                onExerciseTap: _openExerciseScreen,
                onFavoriteToggle: userProvider.toggleFavoriteExercise,
              ),
              _buildSimpleFormTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openExerciseScreen(String exerciseId) async {
    try {
      final config = ExerciseConfig.getExerciseById(exerciseId);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExerciseScreen(
            exerciseId: exerciseId,
            exerciseConfig: config,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('home.error_loading_exercise', params: {'error': '$e'}),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSimpleFormTab(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      itemCount: _simpleFormGuides.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final guide = _simpleFormGuides[index];
        return Material(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _ExerciseSimpleFormDetailScreen(guide: guide),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: Image.asset(
                        guide.imagePaths.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child:
                                const Icon(Icons.image_not_supported, size: 28),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyStatsCard(
    BuildContext context,
    ExerciseProvider provider,
    UserProvider userProvider,
  ) {
    final l10n = context.l10n;
    if (!userProvider.isPremium) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.t('home.today_progress_premium'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.t('home.today_progress_locked_desc'),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final totalReps = provider.todayTotalReps;
    final workoutCount = provider.todayWorkoutCount;
    final calories = provider.todayEstimatedCalories;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.t('home.today_progress'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    provider.initialize();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  totalReps.toString(),
                  l10n.t('home.total_reps'),
                  Icons.repeat,
                  Colors.blue,
                ),
                _buildStatItem(
                  workoutCount.toString(),
                  l10n.t('home.workouts'),
                  Icons.fitness_center,
                  Colors.green,
                ),
                _buildStatItem(
                  calories.toStringAsFixed(1),
                  l10n.t('home.calories'),
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  int _getCurrentBadgeDailyTargetReps(UserProvider userProvider) {
    const prepBadgeId = 'prep_phase_15_v2';
    const monthBadgeOrder = [
      'month_1_bronze',
      'month_2_silver',
      'month_3_gold',
    ];

    const prepDayTargets = {
      1: 37,
      2: 37,
      3: 37,
      4: 53,
      5: 53,
      6: 53,
      7: 0,
      8: 74,
      9: 74,
      10: 74,
      11: 74,
      12: 74,
      13: 74,
      14: 0,
      15: 75,
    };

    const monthlyTargets = {
      'month_1_bronze': 111,
      'month_2_silver': 188,
      'month_3_gold': 260,
    };

    final badgesById = {
      for (final badge in userProvider.badges) badge.badgeId: badge,
    };

    final prepBadge = badgesById[prepBadgeId];
    if (prepBadge == null) {
      return userProvider.dailyGoal;
    }

    if (!prepBadge.isUnlocked) {
      final dayNumber = (prepBadge.progress + 1).clamp(1, 15);
      return prepDayTargets[dayNumber] ?? userProvider.dailyGoal;
    }

    for (final badgeId in monthBadgeOrder) {
      final badge = badgesById[badgeId];
      if (badge != null && !badge.isUnlocked) {
        return monthlyTargets[badgeId] ?? userProvider.dailyGoal;
      }
    }

    return monthlyTargets['month_3_gold'] ?? userProvider.dailyGoal;
  }

  Widget _buildDailyGoalProgress(int currentReps, int dailyGoal) {
    final percentage =
        dailyGoal > 0 ? (currentReps / dailyGoal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr(
                'home.daily_goal',
                params: {'current': '$currentReps', 'goal': '$dailyGoal'},
              ),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    percentage >= 1.0 ? Colors.green : AppColorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey[200],
          color: percentage >= 1.0 ? Colors.green : AppColorScheme.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        if (percentage >= 1.0)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              context.tr('home.daily_goal_achieved'),
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class _ExerciseSimpleFormGuide {
  final String id;
  final String title;
  final List<String> imagePaths;

  const _ExerciseSimpleFormGuide({
    required this.id,
    required this.title,
    required this.imagePaths,
  });
}

class _ExerciseSimpleFormDetailScreen extends StatelessWidget {
  final _ExerciseSimpleFormGuide guide;
  const _ExerciseSimpleFormDetailScreen({required this.guide});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('home.simple_form', params: {'name': guide.title})),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.t('home.simple_form_notice'),
                    style: const TextStyle(height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            guide.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (guide.id == 'situp') ...[
            Text(
              l10n.t('home.situp_notice'),
              style: const TextStyle(height: 1.4),
            ),
            const SizedBox(height: 12),
          ],
          ...guide.imagePaths.map(
            (path) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 34),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    if (!userProvider.isPremium) {
      return _PremiumLockedView(
        icon: Icons.timeline,
        title: context.tr('home.progress_premium_title'),
        message: context.tr('home.progress_premium_message'),
      );
    }
    return const ProgressScreen();
  }
}

class _VideoRecordingsTab extends StatelessWidget {
  const _VideoRecordingsTab();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    if (!userProvider.isPremium) {
      return _PremiumLockedView(
        icon: Icons.video_library_outlined,
        title: context.tr('home.recordings_premium_title'),
        message: context.tr('home.recordings_premium_message'),
      );
    }
    return const VideoRecordingsScreen();
  }
}

class _PremiumLockedView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _PremiumLockedView({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// SettingsScreen remains the same...
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _voiceCountingLanguages = {
    'en-US': 'English',
    'es-ES': 'Spanish',
    'pt-BR': 'Portuguese',
    'zh-CN': 'Mandarin Chinese',
    'hi-IN': 'Hindi',
    'ja-JP': 'Japanese',
    'de-DE': 'German',
    'ko-KR': 'Korean',
    'my-MM': 'Burmese',
    'fi-FI': 'Finnish',
    'th-TH': 'Thai',
  };

  static const List<String> _appLanguages = [
    'en',
    'es',
    'ja',
    'my',
    'hi',
    'pt',
    'zh',
    'de',
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: _SettingsTitleBar(
          title: l10n.t('settings.title'),
          isPremium: userProvider.isPremium,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.14),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          // Premium Section
          _buildSettingsSection(
            l10n.t('settings.premium_features'),
            [
              ListTile(
                title: Text(l10n.t('settings.premium_account')),
                subtitle: Text(l10n.t('settings.unlock_all_features')),
                trailing: Icon(
                  userProvider.isPremium
                      ? Icons.verified_rounded
                      : Icons.lock_outline_rounded,
                  color: userProvider.isPremium ? Colors.green : null,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PremiumActivationScreen(),
                    ),
                  );
                },
              ),
              SwitchListTile(
                title: Text(l10n.t('settings.voice_counting')),
                subtitle: Text(l10n.t('settings.speak_count')),
                value: userProvider.voiceCountingEnabled,
                onChanged: userProvider.isPremium
                    ? (value) => userProvider.toggleVoiceCounting()
                    : null,
              ),
              ListTile(
                title: Text(l10n.t('settings.voice_counting_language')),
                subtitle: Text(
                  _voiceCountingLanguageLabel(
                    userProvider.voiceCountingLanguage,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                enabled: userProvider.isPremium,
                onTap: userProvider.isPremium
                    ? () => _showVoiceCountingLanguageDialog(
                          context,
                          userProvider,
                        )
                    : null,
              ),
              ListTile(
                title: const Text('Luxury Overlay Studio'),
                subtitle: Text(
                  userProvider.isPremium
                      ? 'Customize the post-process rep counter and accuracy bar.'
                      : 'Premium unlocks the fully customizable video overlay.',
                ),
                trailing: const Icon(Icons.auto_awesome_rounded),
                enabled: userProvider.isPremium,
                onTap: userProvider.isPremium
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const WorkoutOverlayCustomizerScreen(),
                          ),
                        );
                      }
                    : null,
              ),
              if (!userProvider.isPremium)
                ListTile(
                  title: Text(l10n.t('settings.upgrade_to_premium')),
                  subtitle: Text(l10n.t('settings.upgrade_subtitle')),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PremiumActivationScreen(),
                      ),
                    );
                  },
                ),
            ],
          ),

          // App Settings
          _buildSettingsSection(
            l10n.t('settings.app_settings'),
            [
              ListTile(
                title: Text(l10n.t('settings.profile_name')),
                subtitle: Text(
                  userProvider.userName.trim().isEmpty
                      ? l10n.t('profile.guest_name')
                      : userProvider.userName.trim(),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showProfileNameDialog(context, userProvider),
              ),
            ],
          ),

          // Theme Settings
          _buildSettingsSection(
            l10n.t('settings.appearance'),
            [
              ListTile(
                title: Text(l10n.t('settings.theme')),
                subtitle:
                    Text(_themeLabel(context, userProvider.selectedTheme)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showThemeDialog(context, userProvider);
                },
              ),
              ListTile(
                title: Text(l10n.t('settings.language')),
                subtitle:
                    Text(_appLanguageLabel(context, userProvider.appLanguage)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showAppLanguageDialog(context, userProvider);
                },
              ),
            ],
          ),

          // Data Management
          _buildSettingsSection(
            l10n.t('settings.data'),
            [
              ListTile(
                title: Text(l10n.t('settings.clear_data')),
                subtitle: Text(l10n.t('settings.clear_data_subtitle')),
                trailing: const Icon(Icons.delete),
                onTap: () {
                  _showClearDataDialog(context);
                },
              ),
            ],
          ),

          // About
          _buildSettingsSection(
            l10n.t('settings.about'),
            [
              ListTile(
                title: Text(l10n.t('settings.version')),
                subtitle: const Text('1.0.0 (2025.1.0)'),
              ),
              ListTile(
                title: Text(l10n.t('settings.privacy_policy')),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LegalDocumentScreen(
                        type: LegalDocumentType.privacyPolicy,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.t('settings.terms')),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LegalDocumentScreen(
                        type: LegalDocumentType.termsOfService,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.t('settings.disclaimer')),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LegalDocumentScreen(
                        type: LegalDocumentType.disclaimer,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings.select_theme')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(context.tr('theme.light')),
              trailing: userProvider.selectedTheme == 'light'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                userProvider.setTheme('light');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(context.tr('theme.dark')),
              trailing: userProvider.selectedTheme == 'dark'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                userProvider.setTheme('dark');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(context.tr('theme.gold')),
              trailing: userProvider.selectedTheme == 'gold'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                userProvider.setTheme('gold');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(context.tr('theme.pink')),
              trailing: userProvider.selectedTheme == 'pink'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                userProvider.setTheme('pink');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _voiceCountingLanguageLabel(String languageCode) {
    return _voiceCountingLanguages[languageCode] ?? 'English';
  }

  String _appLanguageLabel(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'es':
        return context.tr('lang.es');
      case 'ja':
        return context.tr('lang.ja');
      case 'my':
        return context.tr('lang.my');
      case 'hi':
        return context.tr('lang.hi');
      case 'pt':
        return context.tr('lang.pt');
      case 'zh':
        return context.tr('lang.zh');
      case 'de':
        return context.tr('lang.de');
      case 'en':
      default:
        return context.tr('lang.en');
    }
  }

  void _showAppLanguageDialog(
    BuildContext context,
    UserProvider userProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings.select_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _appLanguages.map((code) {
            final isSelected = userProvider.appLanguage == code;
            return ListTile(
              title: Text(_appLanguageLabel(context, code)),
              trailing: isSelected ? const Icon(Icons.check) : null,
              onTap: () {
                userProvider.setAppLanguage(code);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showProfileNameDialog(
    BuildContext context,
    UserProvider userProvider,
  ) {
    final l10n = context.l10n;
    final controller = TextEditingController(text: userProvider.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.t('profile.user_name_label')),
        content: TextField(
          controller: controller,
          maxLength: 40,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'[\n\r]')),
          ],
          decoration: InputDecoration(
            hintText: l10n.t('profile.name_hint'),
          ),
          onSubmitted: (_) => Navigator.pop(context, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.t('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l10n.t('profile.save_name')),
          ),
        ],
      ),
    ).then((value) {
      final name = (value ?? '').toString().trim();
      if (name.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.t('onboarding.name_required')),
            ),
          );
        }
        return;
      }
      userProvider.setUserName(name);
    });
  }

  void _showVoiceCountingLanguageDialog(
    BuildContext context,
    UserProvider userProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings.voice_counting_language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _voiceCountingLanguages.entries.map((entry) {
            final isSelected = userProvider.voiceCountingLanguage == entry.key;
            return ListTile(
              title: Text(entry.value),
              trailing: isSelected ? const Icon(Icons.check) : null,
              onTap: () {
                userProvider.setVoiceCountingLanguage(entry.key);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _themeLabel(BuildContext context, String value) {
    switch (value) {
      case 'light':
        return context.tr('theme.light');
      case 'dark':
        return context.tr('theme.dark');
      case 'gold':
        return context.tr('theme.gold');
      case 'pink':
        return context.tr('theme.pink');
      default:
        return context.tr('theme.dark');
    }
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('settings.clear_all_data')),
        content: Text(
          context.tr('settings.clear_all_data_desc'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _clearUserData(context);
            },
            child: Text(
              context.tr('common.clear_data'),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearUserData(BuildContext context) async {
    try {
      await DataManagementService.clearUserData();

      if (!context.mounted) {
        return;
      }

      final exerciseProvider = Provider.of<ExerciseProvider>(
        context,
        listen: false,
      );
      final userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );

      await exerciseProvider.initialize();
      await userProvider.initialize();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('settings.clear_success')),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('settings.clear_failed', params: {'error': '$e'}),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
