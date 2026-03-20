import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soon/router.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(clientId: "edulounge-6b112.firebasestorage.app"),
  ]);
  runApp(ProviderScope(child: SoonApp()));
}

class SoonApp extends StatefulWidget {
  const SoonApp({super.key});

  @override
  State<SoonApp> createState() => _SoonAppState();
}

class _SoonAppState extends State<SoonApp> {
  final activeRouter = router;
  late final StreamSubscription<User?> _authSub;

  @override
  void initState() {
    super.initState();

    _authSub = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        activeRouter.go("/auth");
      }
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
    );
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: [
        FirebaseUILocalizations.withDefaultOverrides(const DeLocalizations()),

        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,

        FirebaseUILocalizations.delegate,
      ],
      routerConfig: activeRouter,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        textTheme: ThemeData.light().textTheme.copyWith(
          bodyMedium: const TextStyle(fontSize: 17),
        ),
      ),
    );
  }
}
