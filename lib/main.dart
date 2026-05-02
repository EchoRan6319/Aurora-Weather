import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/aurora_palette.dart';
import 'core/constants/app_constants.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/city_provider.dart';
import 'providers/scheduled_broadcast_provider.dart';
import 'services/qweather_service.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';
import 'services/scheduled_broadcast_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConstants.initialize();

  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // CI can inject API keys via --dart-define or environment variables.
  }

  await notificationServiceProvider.initialize();
  await notificationServiceProvider.createNotificationChannel();

  await scheduledBroadcastServiceProvider.initialize();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleBroadcasts();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleBroadcasts();
    }
  }

  Future<void> _scheduleBroadcasts() async {
    final settings = ref.read(scheduledBroadcastProvider);
    scheduledBroadcastServiceProvider.updateWeatherService(
      ref.read(qweatherServiceProvider),
    );
    scheduledBroadcastServiceProvider.updateCityRepository(
      ref.read(cityRepositoryProvider),
    );
    await scheduledBroadcastServiceProvider.scheduleBroadcasts(settings);
  }

  Locale? _resolveAppLocale(AppLanguage language) {
    switch (language) {
      case AppLanguage.zhCN:
        return const Locale('zh', 'CN');
      case AppLanguage.enUS:
        return const Locale('en', 'US');
      case AppLanguage.system:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeSettings = ref.watch(themeProvider);
    final appSettings = ref.watch(settingsProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final appLocale = _resolveAppLocale(appSettings.appLanguage);

    ref.listen<ScheduledBroadcastSettings>(scheduledBroadcastProvider, (
      previous,
      next,
    ) {
      if (previous != next) {
        scheduledBroadcastServiceProvider.scheduleBroadcasts(next);
      }
    });

    final seedColor = themeSettings.seedColor;
    final ColorScheme lightColorScheme;
    final ColorScheme darkColorScheme;

    if (seedColor != null) {
      lightColorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      );
      darkColorScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      );
    } else {
      lightColorScheme = AuroraPalette.lightColorScheme();
      darkColorScheme = AuroraPalette.darkColorScheme();
    }

    final finalDarkColorScheme = themeSettings.useAmoledBlack
        ? AuroraPalette.amoledBlackColorScheme()
        : darkColorScheme;

    return MaterialApp(
      title: AppLocalizations.tr('轻氧天气'),
      debugShowCheckedModeBanner: false,
      locale: appLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          AppLocalizations.updateCurrentLocale(
            const Locale('zh', 'CN'),
          );
          return const Locale('zh', 'CN');
        }
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            AppLocalizations.updateCurrentLocale(supportedLocale);
            return supportedLocale;
          }
        }
        AppLocalizations.updateCurrentLocale(const Locale('zh', 'CN'));
        return const Locale('zh', 'CN');
      },
      theme: AppTheme.createTheme(colorScheme: lightColorScheme),
      darkTheme: AppTheme.createTheme(
        colorScheme: finalDarkColorScheme,
        isAmoledBlack: themeSettings.useAmoledBlack,
      ),
      themeMode: themeNotifier.flutterThemeMode,
      builder: (context, child) {
        AppLocalizations.updateCurrentLocale(
          Localizations.localeOf(context),
        );
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final overlayStyle =
            (isDark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark)
                .copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarDividerColor: Colors.transparent,
                  systemNavigationBarContrastEnforced: false,
                );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: child!,
        );
      },
      home: const MainScreen(),
    );
  }
}
