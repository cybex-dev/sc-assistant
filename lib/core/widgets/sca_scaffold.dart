import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
        title: Text("SC Assistant", style: Theme.of(context).textTheme.bodyLarge),
        items: [
          const ListTile(
            title: Text("Party Creator"),
            // subtitle: Text("Create a new party"),
            subtitle: Text("Coming Soon"),
            enabled: false,
          ),
          const ListTile(
            title: Text("Mission Planner"),
            // subtitle: Text("Invite friends to your mission"),
            subtitle: Text("Coming Soon"),
            enabled: false,
          ),
          ListTile(
            title: const Text("Party Payouts"),
            onTap: () {
              Navigator.of(context).pop();
              context.go(FundsDisperserPage.name);
            },
          ),
          const Spacer(),
          const _VersionBuilder(),
        ],
      ),
      body: body,
    );
  }
}

class _VersionBuilder extends StatelessWidget {
  const _VersionBuilder({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo?>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          PackageInfo packageInfo = snapshot.data!;
          return Column(
            children: [Text("SC Assistant", style: Theme.of(context).textTheme.bodyLarge), Text("Version ${packageInfo.version}")],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
