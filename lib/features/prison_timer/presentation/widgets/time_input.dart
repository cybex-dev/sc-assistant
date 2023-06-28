import 'package:flutter/material.dart';

typedef OnTimeChanged = void Function(Duration duration);

class TimeInput extends StatefulWidget {
  final OnTimeChanged onTimeChanged;
  final Duration? startDuration;
  final bool showLabels;

  const TimeInput({Key? key, this.startDuration, required this.onTimeChanged, this.showLabels = false}) : super(key: key);

  @override
  State<TimeInput> createState() => _TimeInputState();
}

class _TimeInputState extends State<TimeInput> {
  final _formKey = GlobalKey<FormState>();

  final _hoursKey = GlobalKey<FormFieldState<int>>();
  final _minutesKey = GlobalKey<FormFieldState<int>>();
  final _secondsKey = GlobalKey<FormFieldState<int>>();

  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _secondsController;

  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  void onTimeChanged() {
    final duration = Duration(hours: _hours, minutes: _minutes, seconds: _seconds);
    widget.onTimeChanged(duration);
  }

  String? _parseIntValidator(String? value, {int? min, int? max, bool allowEmpty = false}) {
    if (value == null || value.isEmpty) {
      if(allowEmpty) {
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

  Widget _getHoursWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: _IntTextField(
          initialValue: widget.startDuration?.inHours,
          fieldKey: _hoursKey,
          controller: _hoursController,
          showSuffix: widget.showLabels,
          suffixText: "Hours",
          validator: (value) => _parseIntValidator(value, min: 0, allowEmpty: true),
          onChanged: (value) {
            setState(() {
              _hours = int.tryParse(value) ?? 0;
              onTimeChanged();
            });
          },
        ),
      ),
    );
  }

  Widget _getMinutesWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: _IntTextField(
          initialValue: widget.startDuration?.inMinutes.remainder(60),
          fieldKey: _minutesKey,
          controller: _minutesController,
          showSuffix: widget.showLabels,
          suffixText: "Minutes",
          validator: (value) => _parseIntValidator(value, min: 0, max: 59, allowEmpty: true),
          onChanged: (value) {
            setState(() {
              _minutes = int.tryParse(value) ?? 0;
              onTimeChanged();
            });
          },
        ),
      ),
    );
  }

  Widget _getSecondsWidget() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: _IntTextField(
          initialValue: widget.startDuration?.inSeconds.remainder(60),
          controller: _secondsController,
          suffixText: "Seconds",
          showSuffix: widget.showLabels,
          fieldKey: _secondsKey,
          validator: (value) => _parseIntValidator(value, min: 0, max: 59, allowEmpty: true),
          onChanged: (value) {
            setState(() {
              _seconds = int.tryParse(value) ?? 0;
              onTimeChanged();
            });
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if(widget.startDuration != null) {
      _hours = widget.startDuration!.inHours;
      _minutes = widget.startDuration!.inMinutes;
      _seconds = widget.startDuration!.inSeconds;

      _hoursController = TextEditingController(text: _hours.toString());
      _minutesController = TextEditingController(text: _minutes.toString());
      _secondsController = TextEditingController(text: _seconds.toString());
    } else {
      _hoursController = TextEditingController();
      _minutesController = TextEditingController();
      _secondsController = TextEditingController();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getHoursWidget(),
          _getMinutesWidget(),
          _getSecondsWidget(),
        ],
      ),
    );
  }
}

class _IntTextField extends StatelessWidget {
  final int? initialValue;
  final ValueChanged<String>? onChanged;
  final String? suffixText;
  final bool showSuffix;
  final TextEditingController controller;
  final GlobalKey<FormFieldState<int>> fieldKey;
  final FormFieldValidator<String>? validator;

  const _IntTextField({
    Key? key,
    this.initialValue,
    required this.onChanged,
    required this.suffixText,
    this.showSuffix = false,
    required this.controller,
    required this.fieldKey,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      validator: validator,
      initialValue: initialValue?.toString(),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        border: InputBorder.none,
        labelText: showSuffix ? suffixText : null,
        hintText: initialValue == null ? "0" : null,
        alignLabelWithHint: true,
      ),
      textAlign: TextAlign.end,
      keyboardType: TextInputType.number,
      style: Theme.of(context).textTheme.displayMedium,
      onChanged: onChanged,
    );
  }
}
