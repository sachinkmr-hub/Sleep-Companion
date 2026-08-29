import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class NeendCompanionApp extends ConsumerWidget {
  const NeendCompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Neend Companion',
      themeMode: ThemeMode.dark, // Dark theme by default (Night theme)
      theme: AppTheme.morningTheme,
      darkTheme: AppTheme.nightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
