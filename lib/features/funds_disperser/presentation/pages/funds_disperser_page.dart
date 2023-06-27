import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sc_client/core/const/colors.dart';

import '../../../../core/widgets/sca_scaffold.dart';

/// TODO
/// - Store payouts per mission / total
/// - remember names & payouts
/// - remember last mission
/// - remember last payout
/// - remember last party members
/// - remember last fee
/// - remember last box quantity
/// - remember last box value
/// - remember last box total
/// - suggest locations
/// - autofill amounts
class FundsDisperserPageArgs {
  const FundsDisperserPageArgs();
}

class FundsDisperserPage extends StatelessWidget {
  static const String name = "/party-payouts";

  static GoRoute goRoute({FundsDisperserPageArgs arguments = const FundsDisperserPageArgs(), String? title}) =>
      GoRoute(name: title, path: name, builder: (context, state) => FundsDisperserPage(arguments: arguments));

  static Route route({FundsDisperserPageArgs arguments = const FundsDisperserPageArgs(), String? title}) => CupertinoPageRoute(
      builder: (_) => FundsDisperserPage(arguments: arguments), title: title, settings: RouteSettings(name: name, arguments: arguments));

  static Page page({FundsDisperserPageArgs arguments = const FundsDisperserPageArgs(), String? title}) =>
      CupertinoPage(child: const FundsDisperserPage(arguments: FundsDisperserPageArgs()), title: title, name: name, arguments: arguments);

  final FundsDisperserPageArgs arguments;

  const FundsDisperserPage({Key? key, required this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SCAScaffold(
        title: "Funds disperser",
        body: Stack(
          children: [
            const _BackgroundImage(),
            Padding(
              padding: const EdgeInsets.all(4.0).copyWith(top: 16.0),
              child: _Page(),
            ),
          ],
        ));
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

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      "https://media.robertsspaceindustries.com/92g1tur3p2ov2/source.jpg",
      fit: BoxFit.cover,
      height: MediaQuery.of(context).size.height,
      opacity: const AlwaysStoppedAnimation(0.4),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({super.key});

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _boxQuantityController;
  late TextEditingController _boxValueController;
  late TextEditingController _partyMembersController;
  late TextEditingController _feeController;
  final _boxQuantityKey = GlobalKey<FormFieldState<String>>();
  final _boxValueKey = GlobalKey<FormFieldState<String>>();
  final _partyMembersKey = GlobalKey<FormFieldState<String>>();
  final _feeKey = GlobalKey<FormFieldState<String>>();

  final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter(
    decimalDigits: 0,
    symbol: "",
    enableNegative: false,
  );

  int _boxQuantity = 1;
  double _boxValue = 20000;
  int _partyMembers = 2;
  double? _feePercentage = 0.5;

  double _value = 0;

  String? _parseFloatValidator(String? value, {double? min, double? max, bool allowEmpty = false}) {
    if (value == null || value.isEmpty) {
      if (allowEmpty) {
        return null;
      }
      return "Please enter an amount";
    }
    double? _value = double.tryParse(value.replaceAll(",", ""));
    if (_value == null) {
      return "Please enter a valid number";
    }
    if (_value < (min ?? double.negativeInfinity)) {
      return "Please enter a value between ${min ?? double.negativeInfinity} and ${max ?? double.infinity}";
    } else if (_value > (max ?? double.infinity)) {
      return "Please enter a value between ${min ?? double.negativeInfinity} and ${max ?? double.infinity}";
    }
    return null;
  }

  String? _parseIntValidator(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return "Please enter an amount";
    }
    int? _value = int.tryParse(value.replaceAll(",", ""));
    if (_value == null) {
      return "Please enter a valid number";
    }
    if (min != null && _value < min) {
      return "Please enter a value greater than $min";
    } else if (max != null && _value > max) {
      return "Please enter a value less than $max";
    }
    return null;
  }

  double _calculatePayout(int boxCount, double boxValue, int partyMembers, double? fee) {
    return boxCount * boxValue * (1 - ((fee ?? 0) / 100)) / partyMembers;
  }

  void _updateValue(double newValue) {
    setState(() {
      _value = newValue;
    });
  }

  void _boxQuantityChanged(String value) {
    if (!(_boxQuantityKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _boxQuantity = int.tryParse(value.replaceAll(",", "")) ?? 0;
      if (value.isEmpty) {
        _value = 0;
      } else {
        _updateValue(_calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage));
      }
    });
  }

  void _boxValueChanged(String value) {
    if (!(_boxValueKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _boxValue = double.tryParse(value.replaceAll(",", "")) ?? 0;
      if (value.isEmpty) {
        _value = 0;
      } else {
        _updateValue(_calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage));
      }
    });
  }

  void _partyMembersChanged(String value) {
    if (!(_partyMembersKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _partyMembers = int.tryParse(value.replaceAll(",", "")) ?? 0;
      if (value.isEmpty) {
        _value = 0;
      } else {
        _updateValue(_calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage));
      }
    });
  }

  void _feeChanged(String value) {
    if (!(_feeKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _feePercentage = double.tryParse(value.replaceAll(",", ""));
      _updateValue(_calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _boxQuantityController = TextEditingController(text: _formatter.format(_boxQuantity.toString()));
    _boxValueController = TextEditingController(text: _formatter.format(_boxValue.toString()));
    _partyMembersController = TextEditingController(text: _formatter.format(_partyMembers.toString()));
    _feeController = TextEditingController(text: _formatter.format(_feePercentage?.toString() ?? "0.5"));
    _value = _calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // title
        Text("Party Funds Disperser", style: Theme.of(context).textTheme.headlineMedium),

        const SizedBox(
          height: 4,
        ),

        // description
        Text(
          "This tool will help you to calculate how much money each party member should receive after a hunt.",
          style: Theme.of(context).textTheme.bodySmall,
        ),

        // divider
        const Divider(),

        // form
        Form(
          key: _formKey,
          child: Column(
            children: [
              // form - box quantity and box value with min value and validator
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: _boxQuantityKey,
                      controller: _boxQuantityController,
                      decoration: const InputDecoration(
                        labelText: "Number of boxes",
                        hintText: "120",
                      ),
                      inputFormatters: [
                        _formatter,
                      ],
                      style: const TextStyle(fontSize: 20),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => _parseIntValidator(value, min: 1),
                      onChanged: _boxQuantityChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      key: _boxValueKey,
                      controller: _boxValueController,
                      inputFormatters: [
                        _formatter,
                      ],
                      decoration: const InputDecoration(
                        labelText: "Box Value",
                        hintText: "20000",
                        suffix: Text("aUEC"),
                      ),
                      style: const TextStyle(fontSize: 20),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => _parseFloatValidator(value, min: 0),
                      onChanged: _boxValueChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // form - number of party members
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: _partyMembersKey,
                      controller: _partyMembersController,
                      inputFormatters: [
                        _formatter,
                      ],
                      decoration: const InputDecoration(
                        labelText: "Number of members in party",
                      ),
                      style: const TextStyle(fontSize: 20),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => _parseIntValidator(value, min: 1),
                      onChanged: _partyMembersChanged,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),

              // form - optional tax percentage / payout fee amount
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                        key: _feeKey,
                        controller: _feeController,
                        decoration: const InputDecoration(
                          labelText: "Tax percentage / payout fee amount per transaction (optional)",
                          helperText: "Leave blank if not applicable",
                        ),
                        style: const TextStyle(fontSize: 20),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: _feeChanged,
                        validator: (value) => _parseFloatValidator(value, min: 0, max: 100, allowEmpty: true)),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // divider
        const Divider(
          color: Colors.black26,
        ),
        const SizedBox(
          height: 16,
        ),

        // calculation value
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: TextEditingController(text: _value.toStringAsFixed(0)),
                textAlign: TextAlign.end,
                readOnly: true,
                textAlignVertical: TextAlignVertical.bottom,
                inputFormatters: [
                  _formatter,
                ],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  suffix: Text("aUEC", style: Theme.of(context).textTheme.bodySmall),
                  prefix: Text(
                    "Each party member should receive ",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.red),
              ),
            ),
            const Spacer(),
          ],
        ),

        const SizedBox(
          height: 16,
        ),
        const Divider(color: Colors.black26),
      ],
    );
  }
}