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
  static const Duration _minSplashDuration = Duration(milliseconds: 700);
  DateTime? _splashStartedAt;

  @override
  void initState() {
    super.initState();
    _splashStartedAt = DateTime.now();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
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
        final theme =
            selectedTheme == 'gold' ? AppTheme.goldTheme
            : selectedTheme == 'pink' ? AppTheme.pinkTheme
            : AppTheme.lightTheme;

        return MaterialApp(
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).t('app.title'),
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: Locale(userProvider.appLanguage),
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
              child: child,
            );
          },
        );
      },
    );
  }
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
