import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  const _App({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SC Assistant',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: createMaterialColor(brandDarkBlueColor),
        dividerTheme: const DividerThemeData(
          thickness: 2,
        ),
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)
      ),
      routerConfig: router,
    );
  }
}