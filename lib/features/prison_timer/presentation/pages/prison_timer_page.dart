import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:sc_client/core/utils/form_factor.dart';
import 'package:sc_client/features/prison_timer/presentation/widgets/time_input.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/sca_scaffold.dart';

class PrisonTimerPageArgs {
  const PrisonTimerPageArgs();
}

class PrisonTimerPage extends StatelessWidget {
  static const String name = "/tools/prison-timer";

  static GoRoute goRoute({PrisonTimerPageArgs arguments = const PrisonTimerPageArgs(), String? title}) =>
      GoRoute(name: title, path: name, builder: (context, state) => PrisonTimerPage(arguments: arguments));

  static Route route({PrisonTimerPageArgs arguments = const PrisonTimerPageArgs(), String? title}) => CupertinoPageRoute(
      builder: (_) => PrisonTimerPage(arguments: arguments), title: title, settings: RouteSettings(name: name, arguments: arguments));

  static Page page({PrisonTimerPageArgs arguments = const PrisonTimerPageArgs(), String? title}) =>
      CupertinoPage(child: const PrisonTimerPage(arguments: PrisonTimerPageArgs()), title: title, name: name, arguments: arguments);

  final PrisonTimerPageArgs arguments;

  const PrisonTimerPage({Key? key, required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SCAScaffold(
      title: "Prison Time Calculator",
      body: Stack(
        children: [
          const _BackgroundImage(),
          Padding(
            padding: const EdgeInsets.all(4.0).copyWith(top: 16.0),
            child: _Page(),
          ),
        ],
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
      "https://media.starcitizen.tools/c/cc/Klescher_Rehabilitation_Facility_Aberdeen.png",
      fit: BoxFit.cover,
      height: MediaQuery.of(context).size.height,
      opacity: const AlwaysStoppedAnimation(0.8),
    );
  }
}

class _Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0).copyWith(top: 24.0),
        child: const _Content(),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({Key? key}) : super(key: key);

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  int _merits = 0;
  late TextEditingController _meritController;

  void _onTimeInputChanged(Duration duration) {
    setState(() {
      _merits = duration.inSeconds;
      _meritController.text = _merits.toString();
    });
  }

  String? _parseIntValidator(String? value, {int? min, int? max, bool allowEmpty = false}) {
    if (value == null || value.isEmpty) {
      if (allowEmpty) {
        return null;
      }
      return "*";
    }
    int? newValue = int.tryParse(value.replaceAll(",", ""));
    if (newValue == null) {
      return "*";
    }
    if (min != null && newValue < min) {
      return "$min - $max";
    } else if (max != null && newValue > max) {
      return "$min - $max";
    }
    return null;
  }

  Widget _getMeritsField() {
    return TextFormField(
      controller: _meritController,
      textAlign: TextAlign.end,
      textAlignVertical: TextAlignVertical.bottom,
      onChanged: (value) {
        setState(() {
          _merits = int.tryParse(value) ?? 0;
        });
      },
      validator: (value) => _parseIntValidator(value, min: 0, allowEmpty: true),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
        suffix: Text(
          "merits",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        prefix: Text(
          "Merits required",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.red),
    );
  }

  @override
  void initState() {
    super.initState();
    _meritController = TextEditingController(text: _merits.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FormFactorBuilder(
      builder: (context, constraints, screenType) {
        bool preferVertical = screenType == ScreenType.handset;

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Prison Time Calculator",
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                "The time you have to spend in prison - prison time in seconds is 1:1 with required merits. i.e. 1 second in prison = 1 merit required",
                style: Theme.of(context).textTheme.bodySmall,
              ),

              Row(
                children: [
                  const Text("Inspired by:"),
                  const SizedBox(width: 2),
                  TextButton.icon(
                    onPressed: () => launchUrl(Uri.parse("https://robertsspaceindustries.com/citizens/SavageRogue")),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text("UberTrooper"),
                  ),
                ],
              ),

              // divider
              const Divider(),

              Row(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: TimeInput(
                      onTimeChanged: _onTimeInputChanged,
                      showLabels: true,
                    ),
                  ),
                ],
              ),
              Text(
                "* investigation required into CS vs time in prison",
                style: Theme.of(context).textTheme.bodySmall,
              ),

              // divider
              const Divider(color: Colors.black26),
              const SizedBox(height: 16),

              // calculation value
              preferVertical
                  ? Column(
                      children: [
                        _getMeritsField(),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _getMeritsField(),
                        ),
                        const Spacer(),
                      ],
                    ),

              const SizedBox(height: 16),
              const Divider(color: Colors.black26),

              const SizedBox(height: 16),
              // Container with left border
              _SuggestionContainer(
                title: "Commodity Mining/Collection",
                items: [
                  _Suggestion(label: "Hadanite", merits: 460, requiredMerits: _merits),
                  _Suggestion(label: "Dolovine", merits: 250, requiredMerits: _merits),
                  _Suggestion(label: "Aphorite", merits: 60, requiredMerits: _merits),
                ],
              ),

              const SizedBox(height: 16),
              _SuggestionContainer(
                title: "Inmate Maintenance Opportunities",
                items: [
                  _Suggestion(label: "Depth 1-5", unit: "repair", merits: 5000, requiredMerits: _merits),
                  _Suggestion(label: "Depth 6-10", unit: "repair", merits: 10000, requiredMerits: _merits),
                  _Suggestion(label: "Depth 11-15", unit: "repair", merits: 15000, requiredMerits: _merits),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuggestionContainer extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SuggestionContainer({Key? key, required this.title, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }
}

class _Suggestion extends StatelessWidget {
  final int requiredMerits;
  final int merits;
  final String? unit;
  final String label;

  const _Suggestion({
    Key? key,
    this.unit,
    required this.label,
    required this.merits,
    required this.requiredMerits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final requiredUnits = (requiredMerits / merits).ceil().toStringAsFixed(0);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 6),
        Text(
          "($merits / ${unit ?? "unit"})",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          requiredUnits,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}
