import 'dart:math';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sc_client/core/utils/form_factor.dart';
import 'package:sc_client/core/utils/list_utils.dart';

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

  static Route route({FundsDisperserPageArgs arguments = const FundsDisperserPageArgs(), String? title}) =>
      CupertinoPageRoute(builder: (_) => FundsDisperserPage(arguments: arguments), title: title, settings: RouteSettings(name: name, arguments: arguments));

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
  late TextEditingController _partyMembersController;
  late TextEditingController _feeController;
  // late TextEditingController _expensesController;
  final _partyMembersKey = GlobalKey<FormFieldState<String>>();
  final _feeKey = GlobalKey<FormFieldState<String>>();
  // final _expensesKey = GlobalKey<FormFieldState<String>>();
  final List<Tuple> _assetList = [];
  final List<Tuple> _expenseList = [];

  final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter(
    decimalDigits: 0,
    symbol: "",
    enableNegative: false,
  );

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

  double _calculatePayout(List<Tuple> assets, int partyMembers, double? fee, double? expenses) {
    double gross = assets.map((e) => e.quantity * e.value).reduceOrDefault((value, element) => value + element, () => 0);

    // if expenses are provided, subtract them from the gross
    if (expenses != null) {
      gross -= expenses;
    }

    // if fee is provided, remove fee rate amount
    if (fee != null) {
      double feeMultiplier = 1 - (fee / 100);
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

  void _partyMembersChanged(String value) {
    if (!(_partyMembersKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _partyMembers = int.tryParse(value.replaceAll(",", "")) ?? 0;
      if (value.isEmpty) {
        _value = 0;
      } else {
        _updateValue(_calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount));
      }
    });
  }

  void _feeChanged(String value) {
    if (!(_feeKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _feePercentage = double.tryParse(value.replaceAll(",", ""));
      _updateValue(_calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount));
    });
  }

  // void _expensesChanged(String value) {
  //   if (!(_expensesKey.currentState?.validate() ?? false)) {
  //     return;
  //   }
  //   setState(() {
  //     _expensesAmount = double.tryParse(value.replaceAll(",", ""));
  //     _updateValue(_calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount));
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (_assetList.isEmpty) {
      _assetList.add(const Tuple(1, 20000, ""));
      _value = _calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount);
    }
    _partyMembersController = TextEditingController(text: _formatter.format(_partyMembers.toString()));
    _feeController = TextEditingController(text: _feePercentage?.toString() ?? "0.5");
    // _expensesController = TextEditingController(text: _formatter.format(_expensesAmount?.toString() ?? "0"));
    _value = _calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount);
  }

  void _onRemoved(int index, Tuple tuple) {
    setState(() {
      _assetList.removeAt(index);
      _value = _calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount);
    });
  }

  void _onChanged(int index, Tuple tuple) {
    setState(() {
      _assetList[index] = tuple;
      _value = _calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount);
    });
  }

  void _onExpenseRemoved(int index, Tuple tuple) {
    setState(() {
      _expenseList.removeAt(index);
      _expensesAmount = _expenseList.map((e) => e.quantity * e.value).reduceOrDefault((value, element) => value + element, () => 0);
      _value = _calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount);
    });
  }

  void _onExpenseChanged(int index, Tuple tuple) {
    setState(() {
      _expenseList[index] = tuple;
      _expensesAmount = _expenseList.map((e) => e.quantity * e.value).reduceOrDefault((value, element) => value + element, () => 0);
      _value = _calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount);
    });
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

  // Widget _getExpensesField() {
  //   return TextFormField(
  //     key: _expensesKey,
  //     controller: _expensesController,
  //     decoration: const InputDecoration(
  //       labelText: "Total Expenses for trip (optional)",
  //       helperText: "Leave blank if not applicable",
  //     ),
  //     style: const TextStyle(fontSize: 20),
  //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //     onChanged: _expensesChanged,
  //     validator: (value) => _parseFloatValidator(value, min: 0, allowEmpty: true),
  //   );
  // }

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
        suffix: Text(
          "aUEC",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        prefix: Text(
          "Payout / member",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.red),
    );
  }

  void _addBox() {
    setState(() {
      _assetList.add(const Tuple(1, 20000, ""));
      _value = _calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount);
    });
  }

  void _addExpenseBox() {
    setState(() {
      _expenseList.add(const Tuple(1, 1000, ""));
      _expensesAmount = _expenseList.map((e) => e.quantity * e.value).reduceOrDefault((value, element) => value + element, () => 0);
      _value = _calculatePayout(_assetList, _partyMembers, _feePercentage, _expensesAmount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _assetList.map((e) {
      final index = _assetList.indexOf(e);
      return _TupleEntry(
        last: index == _assetList.length,
        index: index,
        tuple: e,
        onChanged: _onChanged,
        onRemoved: _onRemoved,
        formatter: _formatter,
      );
    });

    final expenseItems = _expenseList.map((e) {
      final index = _expenseList.indexOf(e);
      return _TupleEntry(
        showQuantity: false,
        last: index == _assetList.length,
        index: index,
        tuple: e,
        onChanged: _onExpenseChanged,
        onRemoved: _onExpenseRemoved,
        formatter: _formatter,
        boxNameLabel: "Name / Category",
        boxValueLabel: "Amount",
      );
    });

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
                "This tool will help you to calculate how much money each party member should receive after a hunt. For use in missions that contain dispensed boxes e.g. Jumptown",
                style: Theme.of(context).textTheme.bodySmall,
              ),

              // divider
              const Divider(),

              // form
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Assets List", style: Theme.of(context).textTheme.titleLarge),

                  // form - box quantity and box value with min value and validator
                  ...items,
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add asset"),
                    onPressed: _addBox,
                  ),

                  const SizedBox(height: 48),

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
                  const SizedBox(height: 48),

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
                  const SizedBox(height: 48),

                  // form - optional expenses
                  Text("Expenses", style: Theme.of(context).textTheme.titleLarge),
                  ...expenseItems,
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add expense"),
                    onPressed: _addExpenseBox,
                  ),

                  const SizedBox(height: 32),
                ],
              ),

              // divider
              const Divider(color: Colors.black26),
              const SizedBox(height: 48),

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
              _PayoutMultiplier(value: _value),

              const SizedBox(height: 16),
              const Divider(color: Colors.black26),
              const SizedBox(height: 8),

              // Calculation
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Calculation", style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text("Gross = Number of Boxes x Box Value", style: Theme.of(context).textTheme.bodySmall),
                  Text("Net = Gross - Expenses", style: Theme.of(context).textTheme.bodySmall),
                  Text("After Tax = Net x Tax Multiplier", style: Theme.of(context).textTheme.bodySmall),
                  Text("Payout / member = After Tax / Number of Party Members", style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PayoutMultiplier extends StatelessWidget {
  final double value;
  final CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter(
    decimalDigits: 0,
    symbol: "",
    enableNegative: false,
  );

  _PayoutMultiplier({Key? key, required this.value}) : super(key: key);

  Widget _getMultiplier(BuildContext context, int index, double value) {
    final amount = _formatter.format((value * index).toStringAsFixed(0));
    return Text(
      "x$index = $amount aUEC",
      style: Theme.of(context).textTheme.bodySmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = List.generate(5, (index) => index + 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        ...list.map((e) => _getMultiplier(context, e, value)),
      ],
    );
  }
}

class Tuple {
  final int quantity;
  final double value;
  final String label;

  const Tuple(this.quantity, this.value, this.label);

  const Tuple.empty()
      : quantity = 0,
        value = 0,
        label = "";

  @override
  String toString() {
    return "Tuple(quantity: $quantity, value: $value, label: $label)";
  }
}

typedef OnTupleChanged = void Function(int index, Tuple tuple);
typedef OnTupleRemoved = void Function(int index, Tuple tuple);

class _TupleEntry extends StatefulWidget {
  final bool showQuantity;
  final bool last;
  final int index;
  final CurrencyTextInputFormatter formatter;
  final OnTupleChanged onChanged;
  final OnTupleRemoved onRemoved;
  final Tuple tuple;

  final String? boxQuantityLabel;
  final String? boxValueLabel;
  final String? boxNameLabel;

  const _TupleEntry({
    Key? key,
    this.last = false,
    this.showQuantity = true,
    required this.index,
    required this.tuple,
    required this.formatter,
    required this.onChanged,
    required this.onRemoved,
    //ignore: unused_element
    this.boxQuantityLabel,
    this.boxValueLabel,
    this.boxNameLabel,
  }) : super(key: key);

  @override
  State<_TupleEntry> createState() => _TupleEntryState();
}

class _TupleEntryState extends State<_TupleEntry> {
  late TextEditingController _boxQuantityController;
  late TextEditingController _boxValueController;

  late TextEditingController _boxLabelController;
  final _boxQuantityKey = GlobalKey<FormFieldState<String>>();
  final _boxValueKey = GlobalKey<FormFieldState<String>>();

  final _boxLabelKey = GlobalKey<FormFieldState<String>>();
  int _boxQuantity = 1;
  double _boxValue = 20000;
  String _boxLabel = "";

  String? _overrideQuantityLabel;
  String? _overrideValueLabel;
  String? _overrideNameLabel;

  bool _showQuantity = true;

  @override
  void initState() {
    super.initState();
    _showQuantity = widget.showQuantity;
    _boxQuantity = widget.tuple.quantity;
    _boxValue = widget.tuple.value;
    _boxLabel = widget.tuple.label;
    _overrideQuantityLabel = widget.boxQuantityLabel;
    _overrideValueLabel = widget.boxValueLabel;
    _overrideNameLabel = widget.boxNameLabel;
    _boxQuantityController = TextEditingController(text: widget.formatter.format(_boxQuantity.toString()));
    _boxValueController = TextEditingController(text: widget.formatter.format(_boxValue.toString()));
    _boxLabelController = TextEditingController(text: _boxLabel);
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

  Widget _getBoxQuantityField() {
    return TextFormField(
      key: _boxQuantityKey,
      controller: _boxQuantityController,
      decoration: InputDecoration(
        labelText: _overrideQuantityLabel ?? "Number of boxes",
        hintText: "120",
      ),
      inputFormatters: [
        widget.formatter,
      ],
      style: const TextStyle(fontSize: 20),
      textInputAction: TextInputAction.next,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => _parseIntValidator(value, min: 0),
      onChanged: _boxQuantityChanged,
    );
  }

  Widget _getBoxValueField() {
    return TextFormField(
      key: _boxValueKey,
      controller: _boxValueController,
      inputFormatters: [
        widget.formatter,
      ],
      decoration: InputDecoration(
        labelText: _overrideValueLabel ?? "Box Value",
        hintText: "20000",
        suffix: const Text("aUEC"),
      ),
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 20),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) => _parseFloatValidator(value, min: 0),
      onChanged: _boxValueChanged,
    );
  }

  Widget _getBoxLabelField({bool last = false}) {
    return TextFormField(
      key: _boxLabelKey,
      controller: _boxLabelController,
      decoration: InputDecoration(
        labelText: _overrideNameLabel ?? "Commodity/Asset Name",
        hintText: "",
      ),
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      style: const TextStyle(fontSize: 20),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        setState(() {
          _boxLabel = value;
        });
      },
    );
  }

  void _boxQuantityChanged(String value) {
    if (!(_boxQuantityKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _boxQuantity = int.tryParse(value.replaceAll(",", "")) ?? 0;
      _onChanged();
    });
  }

  void _onChanged() {
    widget.onChanged(widget.index, Tuple(_boxQuantity, _boxValue, _boxLabel));
  }

  void _boxValueChanged(String value) {
    if (!(_boxValueKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _boxValue = double.tryParse(value.replaceAll(",", "")) ?? 0;
      _onChanged();
    });
  }

  @override
  void didUpdateWidget(_TupleEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tuple != oldWidget.tuple) {
      _boxQuantity = widget.tuple.quantity;
      _boxValue = widget.tuple.value;
      _boxLabel = widget.tuple.label;
      _boxQuantityController.text = widget.formatter.format(_boxQuantity.toString());
      _boxValueController.text = widget.formatter.format(_boxValue.toString());
      _boxLabelController.text = _boxLabel;
      _boxQuantityController.selection = TextSelection.fromPosition(TextPosition(offset: _boxQuantityController.text.length));
      _boxValueController.selection = TextSelection.fromPosition(TextPosition(offset: _boxValueController.text.length));
      _boxLabelController.selection = TextSelection.fromPosition(TextPosition(offset: _boxLabelController.text.length));
      _showQuantity = widget.showQuantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Row(
      children: [
        if(_showQuantity)
          Container(
            constraints: BoxConstraints.tightForFinite(width: max(width * 0.1, 100)),
            child: _getBoxQuantityField(),
          ),
        const SizedBox(width: 16),
        Container(
          constraints: BoxConstraints.tightForFinite(width: max(width * 0.15, 200)),
          child: _getBoxValueField(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _getBoxLabelField(),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              final tuple = Tuple(_boxQuantity, _boxValue, _boxLabel);
              widget.onRemoved(widget.index, tuple);
            },
          ),
        ),
      ],
    );
  }
}
