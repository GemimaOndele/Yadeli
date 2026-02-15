import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';
import 'l10n/app_localizations.dart';
import 'services/profile_service.dart';
import 'services/locale_service.dart';
import 'services/account_service.dart';
import 'src/platform_mapbox.dart';
import 'screens/map_order_screen.dart';
import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}\n${details.stack}');
  };

  await LocaleService.init();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  if (isMapboxSupported) {
    MapboxOptions.setAccessToken(mapboxToken);
  }

  runApp(const MyApp());
}

// Provider pour accéder au ProfileService depuis n'importe où
final profileService = ProfileService();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (_, __) {
        final loc = LocaleService.instance.flutterLocale;
        final contrast = LocaleService.instance.contrast;
        final t = (contrast - 1) * 128;
        return ColorFiltered(
          colorFilter: ColorFilter.matrix([
            contrast, 0, 0, 0, t,
            0, contrast, 0, 0, t,
            0, 0, contrast, 0, t,
            0, 0, 0, 1, 0,
          ]),
          child: MaterialApp(
            key: const ValueKey('yadeli_app'),
            debugShowCheckedModeBanner: false,
            title: 'Yadeli',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            locale: (loc.languageCode == 'ln' || loc.languageCode == 'kg') ? const Locale('fr') : loc,
            supportedLocales: const [
              Locale('fr'),
              Locale('en'),
              Locale('ln'),
              Locale('kg'),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AuthRedirect(),
          ),
        );
      },
    );
  }
}

// 🔹 CE WIDGET DÉCIDE QUELLE PAGE AFFICHER AU DÉMARRAGE
/// Écoute les changements d'auth (connexion, déconnexion, OAuth Google)
class AuthRedirect extends StatelessWidget {
  const AuthRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      initialData: AuthState(AuthChangeEvent.initialSession, Supabase.instance.client.auth.currentSession),
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          return _AuthOrMap(sessionUserId: session.user.id);
        }
        return const AuthScreen();
      },
    );
  }
}

/// Vérifie si le compte est désactivé avant d'afficher MapOrderScreen
class _AuthOrMap extends StatefulWidget {
  final String sessionUserId;

  const _AuthOrMap({required this.sessionUserId});

  @override
  State<_AuthOrMap> createState() => _AuthOrMapState();
}

class _AuthOrMapState extends State<_AuthOrMap> {
  bool _checking = true;
  bool _disabled = false;

  @override
  void initState() {
    super.initState();
    _checkDisabled();
  }

  Future<void> _checkDisabled() async {
    final disabled = await AccountService.isAccountDisabled(widget.sessionUserId);
    if (mounted) {
      if (disabled) {
        Supabase.instance.client.auth.signOut();
        setState(() => _disabled = true);
      } else {
        setState(() => _checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || _disabled) return const AuthScreen();
    return const MapOrderScreen();
  }
}