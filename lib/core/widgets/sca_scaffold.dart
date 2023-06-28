import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sc_client/core/widgets/dialogs.dart';
import 'package:sc_client/core/widgets/sca_drawer.dart';
import 'package:sc_client/features/funds_disperser/presentation/pages/funds_disperser_page.dart';
import 'package:sc_client/features/prison_timer/presentation/pages/prison_timer_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const/urls.dart';
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
          ListTile(
            title: const Text("Prison Timer"),
            trailing: const Icon(Icons.whatshot),
            onTap: () {
              Navigator.of(context).pop();
              context.go(PrisonTimerPage.name);
            },
          ),
          const Spacer(),
          const _VersionBuilder(),
        ],
        footer: const Padding(
          padding: EdgeInsets.all(8.0),
          child: _FooterBuilder(),
        ),
      ),
      body: body,
    );
  }
}

class _FooterBuilder extends StatelessWidget {
  const _FooterBuilder({Key? key}): super(key: key);

  void openLinkOrFail(BuildContext context, String link) {
    final uri = Uri.parse(link);
    canLaunchUrl(uri).then((value) => launchUrl(uri)).catchError((err) {
      showPopup(
        context: context,
        title: "Error",
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Unfortunately, I could not open the link for you. Please visit:"),
            InkWell(
              onTap: () {
                launchUrl(Uri.parse(github));
              },
              child: Text(
                github,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ],
        ),
      );
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => openLinkOrFail(context, github),
          child: const Text("Suggestion? Bug? Click here!"),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(
              child: _VersionBuilder(),
            ),
            IconButton(
              onPressed: () => openLinkOrFail(context, githubIssues),
              icon: Image.asset(
                "assets/images/github.png",
                height: 24.0,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
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
