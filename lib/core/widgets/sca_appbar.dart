import 'package:flutter/material.dart';

import '../const/colors.dart';

class SCAAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const SCAAppbar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      bottom: const _AppBarGoldenLine(),
      toolbarHeight: kToolbarHeight * 2,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarGoldenLine extends StatelessWidget implements PreferredSizeWidget {
  const _AppBarGoldenLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: const BoxDecoration(color: brandGoldColor),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(2);
}