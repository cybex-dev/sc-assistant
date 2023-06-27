import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sc_client/features/funds_disperser/presentation/pages/funds_disperser_page.dart';

import '../const/colors.dart';
import '../router/sc_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const _App();
  }
}

class _App extends StatelessWidget {
  const _App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(
        primarySwatch: createMaterialColor(brandDarkBlueColor),
        dividerTheme: const DividerThemeData(
          thickness: 2,
        ),
      ),
      routerConfig: router,
    );
  }
}