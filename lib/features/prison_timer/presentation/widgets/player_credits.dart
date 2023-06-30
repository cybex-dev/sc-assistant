import 'package:flutter/material.dart';
import 'package:sc_client/core/utils/launch_utils.dart';

class PlayerCredits extends StatelessWidget {
  final String name;
  final String url;

  const PlayerCredits({Key? key, required this.name, required this.url}) : super(key: key);

  const PlayerCredits.rsi({Key? key, required String name, required String handle})
      : this(name: name, url: "https://robertsspaceindustries.com/citizens/$handle", key: key);

  const PlayerCredits.github({Key? key, required String name, required String username})
      : this(name: name, url: "https://github.com/$username", key: key);

  @override
  Widget build(BuildContext context) {
    assert(name.isNotEmpty, "Name cannot be empty");
    assert(Uri.tryParse(url) == null, "Url cannot be empty or invalid");

    final uri = Uri.parse(url);

    return Row(
      children: [
        const Text("Inspired by:"),
        const SizedBox(width: 2),
        TextButton.icon(
          onPressed: () => openUriOrFail(context, uri),
          icon: const Icon(Icons.open_in_new),
          label: const Text("UberTrooper"),
        ),
      ],
    );
  }
}
