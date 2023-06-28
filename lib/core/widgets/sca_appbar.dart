import 'package:flutter/material.dart';

import '../const/colors.dart';

class SCAAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SCAAppbar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        const ElevatedButton(onPressed: null, child: Text("Sign In")),
        const SizedBox(
          height: kToolbarHeight * 0.75,
          child: VerticalDivider(),
        ),
        ElevatedButton(onPressed: null, style: ElevatedButton.styleFrom(backgroundColor: brandGoldColor), child: const Text("Register")),
      ],
      bottom: const _AppBarGoldenLine(),
      toolbarHeight: kToolbarHeight * 2,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarGoldenLine extends StatelessWidget implements PreferredSizeWidget {
  const _AppBarGoldenLine({Key? key}): super(key: key);

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
