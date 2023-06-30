import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:sc_client/core/utils/form_factor.dart';

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
  static const String name = "/tools/party-payouts";

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
      ),
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

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({Key? key}) : super(key: key);

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
  const _Content({Key? key}) : super(key: key);

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _boxQuantityController;
  late TextEditingController _boxValueController;
  late TextEditingController _partyMembersController;
  late TextEditingController _feeController;
  late TextEditingController _expensesController;
  final _boxQuantityKey = GlobalKey<FormFieldState<String>>();
  final _boxValueKey = GlobalKey<FormFieldState<String>>();
  final _partyMembersKey = GlobalKey<FormFieldState<String>>();
  final _feeKey = GlobalKey<FormFieldState<String>>();
  final _expensesKey = GlobalKey<FormFieldState<String>>();

  final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter(
    decimalDigits: 0,
    symbol: "",
    enableNegative: false,
  );

  int _boxQuantity = 1;
  double _boxValue = 20000;
  int _partyMembers = 2;
  double? _feePercentage = 0.5;
  double? _expensesAmount = 0.0;

  double _value = 0;

  String? _parseFloatValidator(String? value, {double? min, double? max, bool allowEmpty = false}) {
    if (value == null || value.isEmpty) {
      if (allowEmpty) {
        return null;
      }
      return "Please enter an amount";
    }
    double? newValue = double.tryParse(value.replaceAll(",", ""));
    if (newValue == null) {
      return "Please enter a valid number";
    }
    if (newValue < (min ?? double.negativeInfinity)) {
      return "Please enter a value between ${min ?? double.negativeInfinity} and ${max ?? double.infinity}";
    } else if (newValue > (max ?? double.infinity)) {
      return "Please enter a value between ${min ?? double.negativeInfinity} and ${max ?? double.infinity}";
    }
    return null;
  }

  String? _parseIntValidator(String? value, {int? min, int? max}) {
    if (value == null || value.isEmpty) {
      return "Please enter an amount";
    }
    int? newValue = int.tryParse(value.replaceAll(",", ""));
    if (newValue == null) {
      return "Please enter a valid number";
    }
    if (min != null && newValue < min) {
      return "Please enter a value greater than $min";
    } else if (max != null && newValue > max) {
      return "Please enter a value less than $max";
    }
    return null;
  }

  double _calculatePayout(int boxCount, double boxValue, int partyMembers, double? fee, double? expenses) {
    double gross = boxCount * boxValue;

    // if expenses are provided, subtract them from the gross
    if (expenses != null) {
      gross -= expenses;
    }

    // if fee is provided, remove fee rate amount
    if (fee != null) {
      double feeMultiplier = 1 - ((fee ?? 0) / 100);
      gross *= feeMultiplier;
    }

    // divide by party members
    return gross / partyMembers;
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
        _updateValue(_calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage, _expensesAmount));
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
        _updateValue(_calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage, _expensesAmount));
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
        _updateValue(_calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage, _expensesAmount));
      }
    });
  }

  void _feeChanged(String value) {
    if (!(_feeKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _feePercentage = double.tryParse(value.replaceAll(",", ""));
      _updateValue(_calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage, _expensesAmount));
    });
  }

  void _expensesChanged(String value) {
    if (!(_expensesKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _expensesAmount = double.tryParse(value.replaceAll(",", ""));
      _updateValue(_calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage, _expensesAmount));
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
    _expensesController = TextEditingController(text: _formatter.format(_expensesAmount?.toString() ?? "0"));
    _value = _calculatePayout(_boxQuantity, _boxValue, _partyMembers, _feePercentage, _expensesAmount);
  }

  Widget _getBoxQuantityField() {
    return TextFormField(
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
    );
  }

  Widget _getBoxValueField() {
    return TextFormField(
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
    );
  }

  Widget _getPartyMembersField() {
    return TextFormField(
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
    );
  }

  Widget _getFeeField() {
    return TextFormField(
      key: _feeKey,
      controller: _feeController,
      decoration: const InputDecoration(
        labelText: "Tax percentage / payout fee amount per transaction (optional)",
        helperText: "Leave blank if not applicable",
      ),
      style: const TextStyle(fontSize: 20),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: _feeChanged,
      validator: (value) => _parseFloatValidator(value, min: 0, max: 100, allowEmpty: true),
    );
  }

  Widget _getExpensesField() {
    return TextFormField(
      key: _expensesKey,
      controller: _expensesController,
      decoration: const InputDecoration(
        labelText: "Total Expenses for trip (optional)",
        helperText: "Leave blank if not applicable",
      ),
      style: const TextStyle(fontSize: 20),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: _expensesChanged,
      validator: (value) => _parseFloatValidator(value, min: 0, allowEmpty: true),
    );
  }

  Widget _getPayoutField() {
    return TextFormField(
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
        suffix: Text("aUEC", style: Theme.of(context).textTheme.bodySmall,),
        prefix: Text(
          "Payout / member",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormFactorBuilder(
      builder: (context, _, screenType) {
        bool preferVertical = screenType == ScreenType.handset;

        return SingleChildScrollView(
          child: Column(
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
                    preferVertical
                        ? Column(
                            children: [
                              _getBoxQuantityField(),
                              const SizedBox(height: 16),
                              _getBoxValueField(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _getBoxQuantityField(),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _getBoxValueField(),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),

                    // form - number of party members
                    preferVertical
                        ? Column(
                            children: [
                              _getPartyMembersField(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _getPartyMembersField(),
                              ),
                              const Spacer(),
                            ],
                          ),
                    const SizedBox(height: 16),

                    // form - optional tax percentage / payout fee amount
                    preferVertical
                        ? Column(
                            children: [
                              _getFeeField(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _getFeeField()),
                              const Spacer(),
                            ],
                          ),
                    const SizedBox(height: 16),

                    const Divider(color: Colors.black26),

                    // form - optional expenses
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Expenses", style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),

                    preferVertical
                        ? Column(
                            children: [
                              _getExpensesField(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _getExpensesField()),
                              const Spacer(),
                            ],
                          ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // divider
              const Divider(color: Colors.black26),
              const SizedBox(height: 16),

              // calculation value
              preferVertical
                  ? Column(
                      children: [
                        _getPayoutField(),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _getPayoutField(),
                        ),
                        const Spacer(),
                      ],
                    ),

              const SizedBox(height: 16),
              const Divider(color: Colors.black26),
            ],
          ),
        );
      },
    );
  }
}
