import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soon/pages/home_page.dart';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: child,
            ),
          ),
        );
      },
      routes: [
        GoRoute(
          path: "/",
          builder: (context, state) {
            return HomePage();
          },
        ),
        GoRoute(
          path: "/auth",
          builder: (context, state) {
            return SignInScreen(
              actions: [
                AuthStateChangeAction<SignedIn>((context, state) {
                  context.go('/');
                }),
                AuthStateChangeAction<UserCreated>((context, state) {
                  context.go('/');
                }),
              ],
            );
          },
        ),
      ],
    ),
  ],
);
