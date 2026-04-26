import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:eko_app/interfaces/notification_helper.dart';
import 'package:eko_app/providers/theme_provider.dart';
import 'package:eko_app/utilities/logo_service.dart';
import 'package:eko_app/utilities/provider_debugger.dart';
import 'package:eko_app/utilities/shared_pref_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:eko_app/localization/generated/app_localizations.dart';
import 'package:eko_app/widgets/scaffolds/check_version.dart';
import 'utilities/router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eko_app/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> _checkFirstInstall() async {
  if (!PrefsService.notFirstInstall) {
    if (FirebaseAuth.instance.currentUser != null) {
      FirebaseAuth.instance.signOut();
    }
    PrefsService.notFirstInstall = true;
  }
}

Future<void> _initSupabase() async {
  final url = const String.fromEnvironment('SUPABASE_URL');
  final key = const String.fromEnvironment('SUPABASE_KEY');
  if (url.isEmpty || key.isEmpty) {
    throw StateError('SUPABASE not defined');
  }
  await Supabase.initialize(url: url, anonKey: key);
}

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  //init
  await Future.wait([
    PrefsService.init(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    _initSupabase(),
  ]);
  // setupLocator();
  //protected/dependent services
  await Future.wait([
    _checkFirstInstall(),
    LogoService.init(),
    NotificationHelper.setupNotifications(),
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true),
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final List<ProviderObserver>? observers =
      kDebugMode ? [ProviderDebuggerObserver()] : null;
  runApp(ProviderScope(observers: observers, child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(colorThemeProvider);

    return OverlaySupport(
      child: MaterialApp.router(
        title: 'Eko',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: theme,
          useMaterial3: true,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('es'), // Spanish
        ],
        builder: (context, child) => CheckVersion(child: child),
        routerConfig: ref.watch(goRouterProvider),
      ),
    );
  }
}
