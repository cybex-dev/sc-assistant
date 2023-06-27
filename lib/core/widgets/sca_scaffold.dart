import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sc_client/core/widgets/sca_drawer.dart';
import 'package:sc_client/features/funds_disperser/presentation/pages/funds_disperser_page.dart';

import 'sca_appbar.dart';

class SCAScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const SCAScaffold({
    Key? key,
    required this.title,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: SCAAppbar(
        title: title,
      ),
      drawer: SCADrawer(
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        items: [
          ListTile(
            title: const Text("Funds dispersion"),
            onTap: () {
              context.goNamed(FundsDisperserPage.name);
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
