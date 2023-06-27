import 'package:flutter/material.dart';

class SCADrawer extends StatelessWidget {
  final Widget title;
  final List<Widget> items;
  final Widget? footer;

  const SCADrawer({Key? key, required this.title, required this.items, this.footer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: title,
          ),
          ...items,
          const Spacer(),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}
