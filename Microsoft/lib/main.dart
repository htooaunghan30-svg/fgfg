// lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';

import 'core/themes/app_theme.dart';
import 'core/themes/color_scheme.dart';
import 'core/localization/app_localizations.dart';
import 'core/security/app_integrity_service.dart';
import 'data/services/isar_service.dart';
import 'domain/repositories/exercise_repository_impl.dart';
import 'domain/repositories/user_repository_impl.dart';
import 'domain/use_cases/track_exercise.dart';
import 'domain/use_cases/validate_form.dart';
import 'domain/use_cases/calculate_metrics.dart';

import 'presentation/providers/exercise_provider.dart';
import 'presentation/providers/camera_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/onboarding_flow_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }
  runZonedGuarded(
    () => runApp(const AppBootstrap()),
    (error, stack) {
      if (!kReleaseMode) {
        debugPrint('Uncaught error: $error');
      }
    },
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        if (!kReleaseMode) {
          parent.print(zone, line);
        }
      },
    ),
  );
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  _AppDependencies? _dependencies;
  String? _securityBlockReason;
  String? _databaseInitError;
  static const Duration _minSplashDuration = Duration(milliseconds: 700);
  DateTime? _splashStartedAt;

  @override
  void initState() {
    super.initState();
    _splashStartedAt = DateTime.now();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (mounted) {
      setState(() {
        _databaseInitError = null;
      });
    }

    final integrity = await AppIntegrityService.instance.verify();
    if (!integrity.ok && !kDebugMode) {
      if (!mounted) return;
      setState(() {
        _securityBlockReason = integrity.message;
      });
      return;
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    try {
      await IsarService.initialize();
    } catch (e) {
      debugPrint('Error initializing Isar: $e');
      final splashStartedAt = _splashStartedAt ?? DateTime.now();
      final elapsed = DateTime.now().difference(splashStartedAt);
      if (elapsed < _minSplashDuration) {
        await Future.delayed(_minSplashDuration - elapsed);
      }
      if (!mounted) return;
      setState(() {
        _databaseInitError = '$e';
        _dependencies = null;
      });
      return;
    }

    final exerciseRepository = ExerciseRepositoryImpl();
    final userRepository = UserRepositoryImpl();

    final trackExerciseUseCase = TrackExerciseUseCase(exerciseRepository);
    final validateFormUseCase = ValidateFormUseCase();
    final calculateMetricsUseCase = CalculateMetricsUseCase();

    final splashStartedAt = _splashStartedAt ?? DateTime.now();
    final elapsed = DateTime.now().difference(splashStartedAt);
    if (elapsed < _minSplashDuration) {
      await Future.delayed(_minSplashDuration - elapsed);
    }

    if (!mounted) return;
    setState(() {
      _dependencies = _AppDependencies(
        exerciseRepository: exerciseRepository,
        userRepository: userRepository,
        trackExerciseUseCase: trackExerciseUseCase,
        validateFormUseCase: validateFormUseCase,
        calculateMetricsUseCase: calculateMetricsUseCase,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_securityBlockReason != null) {
      return SecurityBlockedApp(reason: _securityBlockReason!);
    }

    final databaseInitError = _databaseInitError;
    if (databaseInitError != null) {
      return StartupRecoveryApp(
        message: databaseInitError,
        onRetry: _initializeApp,
      );
    }

    final deps = _dependencies;
    if (deps == null) {
      return const StartupSplashApp();
    }

    return MultiProvider(
      providers: [
        Provider<ExerciseRepositoryImpl>.value(value: deps.exerciseRepository),
        Provider<UserRepositoryImpl>.value(value: deps.userRepository),
        Provider<TrackExerciseUseCase>.value(value: deps.trackExerciseUseCase),
        Provider<ValidateFormUseCase>.value(value: deps.validateFormUseCase),
        Provider<CalculateMetricsUseCase>.value(
            value: deps.calculateMetricsUseCase),
        ChangeNotifierProvider(
          create: (context) {
            final provider = UserProvider(
              context.read<UserRepositoryImpl>(),
            );
            provider.initialize();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            final provider = ExerciseProvider(
              repository: context.read<ExerciseRepositoryImpl>(),
              trackExerciseUseCase: context.read<TrackExerciseUseCase>(),
              validateFormUseCase: context.read<ValidateFormUseCase>(),
              calculateMetricsUseCase: context.read<CalculateMetricsUseCase>(),
            );
            provider.initialize();
            return provider;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => CameraProvider(),
        ),
      ],
      child: const FitnessApp(),
    );
  }
}

class _AppDependencies {
  final ExerciseRepositoryImpl exerciseRepository;
  final UserRepositoryImpl userRepository;
  final TrackExerciseUseCase trackExerciseUseCase;
  final ValidateFormUseCase validateFormUseCase;
  final CalculateMetricsUseCase calculateMetricsUseCase;

  const _AppDependencies({
    required this.exerciseRepository,
    required this.userRepository,
    required this.trackExerciseUseCase,
    required this.validateFormUseCase,
    required this.calculateMetricsUseCase,
  });
}

class StartupSplashApp extends StatelessWidget {
  const StartupSplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const StartupSplashScreen(),
    );
  }
}

class StartupRecoveryApp extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const StartupRecoveryApp({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StartupRecoveryScreen(
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}

class StartupSplashScreen extends StatelessWidget {
  const StartupSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColorScheme.background,
        child: const Center(
          child: _StartupBrandMark(size: 110),
        ),
      ),
    );
  }
}

class StartupRecoveryScreen extends StatefulWidget {
  final String message;
  final Future<void> Function() onRetry;

  const StartupRecoveryScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  State<StartupRecoveryScreen> createState() => _StartupRecoveryScreenState();
}

class _StartupRecoveryScreenState extends State<StartupRecoveryScreen> {
  bool _retrying = false;

  Future<void> _handleRetry() async {
    if (_retrying) return;
    setState(() {
      _retrying = true;
    });
    try {
      await widget.onRetry();
    } finally {
      if (mounted) {
        setState(() {
          _retrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColorScheme.background,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _StartupBrandMark(size: 96),
                const SizedBox(height: 24),
                Text(
                  'Unable to start the app',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColorScheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Local database setup failed. Your data has not been changed. Try again to continue.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColorScheme.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColorScheme.borderLight.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColorScheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _retrying ? null : _handleRetry,
                    child: Text(_retrying ? 'Retrying...' : 'Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupBrandMark extends StatelessWidget {
  final double size;

  const _StartupBrandMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x556D28D9),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/images/appicon.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final selectedTheme = userProvider.selectedTheme;
        final themeMode =
            selectedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
        final appLocale = Locale(userProvider.appLanguage);
        final theme =
            selectedTheme == 'gold' ? AppTheme.goldTheme
            : selectedTheme == 'pink' ? AppTheme.pinkTheme
            : AppTheme.lightTheme;
        final resolvedTheme = _applyLocaleFontFallback(theme, appLocale);
        final resolvedDarkTheme =
            _applyLocaleFontFallback(AppTheme.darkTheme, appLocale);

        return MaterialApp(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).t('app.title'),
          debugShowCheckedModeBanner: false,
          theme: resolvedTheme,
          darkTheme: resolvedDarkTheme,
          themeMode: themeMode,
          locale: appLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: userProvider.onboardingComplete
              ? const HomeScreen()
              : const OnboardingFlowScreen(),
          builder: (context, child) {
            // Add error handling overlay
            return GestureDetector(
              onTap: () {
                // Hide keyboard when tapping outside
                FocusScope.of(context).unfocus();
              },
              child: _LocaleFontScope(
                locale: appLocale,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}

class _LocaleFontScope extends StatelessWidget {
  final Locale locale;
  final Widget child;

  const _LocaleFontScope({
    required this.locale,
    required this.child,
  });

  static const List<String> _myanmarFontFallback = [
    'Noto Sans Myanmar',
    'Myanmar Text',
    'Pyidaungsu',
    'Padauk',
    'Tharlon',
    'sans-serif',
  ];

  @override
  Widget build(BuildContext context) {
    if (locale.languageCode.toLowerCase() != 'my') {
      return child;
    }

    return DefaultTextStyle.merge(
      style: const TextStyle(
        inherit: true,
        fontFamilyFallback: _myanmarFontFallback,
      ),
      child: child,
    );
  }
}

ThemeData _applyLocaleFontFallback(ThemeData theme, Locale locale) {
  if (locale.languageCode.toLowerCase() != 'my') {
    return theme;
  }

  TextStyle applyFallback(TextStyle? style) {
    return (style ?? const TextStyle()).copyWith(
      fontFamilyFallback: _LocaleFontScope._myanmarFontFallback,
    );
  }

  TextTheme applyTextTheme(TextTheme textTheme) {
    return textTheme.copyWith(
      displayLarge: applyFallback(textTheme.displayLarge),
      displayMedium: applyFallback(textTheme.displayMedium),
      displaySmall: applyFallback(textTheme.displaySmall),
      headlineLarge: applyFallback(textTheme.headlineLarge),
      headlineMedium: applyFallback(textTheme.headlineMedium),
      headlineSmall: applyFallback(textTheme.headlineSmall),
      titleLarge: applyFallback(textTheme.titleLarge),
      titleMedium: applyFallback(textTheme.titleMedium),
      titleSmall: applyFallback(textTheme.titleSmall),
      bodyLarge: applyFallback(textTheme.bodyLarge),
      bodyMedium: applyFallback(textTheme.bodyMedium),
      bodySmall: applyFallback(textTheme.bodySmall),
      labelLarge: applyFallback(textTheme.labelLarge),
      labelMedium: applyFallback(textTheme.labelMedium),
      labelSmall: applyFallback(textTheme.labelSmall),
    );
  }

  return theme.copyWith(
    textTheme: applyTextTheme(theme.textTheme),
    primaryTextTheme: applyTextTheme(theme.primaryTextTheme),
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: applyFallback(theme.appBarTheme.titleTextStyle),
      toolbarTextStyle: applyFallback(theme.appBarTheme.toolbarTextStyle),
    ),
    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
      hintStyle: applyFallback(theme.inputDecorationTheme.hintStyle),
      labelStyle: applyFallback(theme.inputDecorationTheme.labelStyle),
      helperStyle: applyFallback(theme.inputDecorationTheme.helperStyle),
      errorStyle: applyFallback(theme.inputDecorationTheme.errorStyle),
    ),
  );
}

class SecurityBlockedApp extends StatelessWidget {
  final String reason;

  const SecurityBlockedApp({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.security_rounded,
                  size: 72,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Security Verification Failed',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  reason,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
