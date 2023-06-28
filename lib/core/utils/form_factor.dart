import 'package:flutter/material.dart';

enum ScreenType { handset, tablet, desktop }

class ScreenFormFactor {
  static double desktop = 900;
  static double tablet = 750;
  static double handset = 300;

  static ScreenType _getFormFactor(BuildContext context) {
    // Use .shortestSide to detect device type regardless of orientation
    double deviceWidth = MediaQuery.of(context).size.shortestSide;
    if (deviceWidth > ScreenFormFactor.desktop) return ScreenType.desktop;
    if (deviceWidth > ScreenFormFactor.tablet) return ScreenType.tablet;
    return ScreenType.handset;
  }

  static ScreenType of(BuildContext context) {
    return _getFormFactor(context);
  }
}

typedef ScreenBuilder = Widget Function(BuildContext context, BoxConstraints constraints, ScreenType screenType);

class FormFactorBuilder extends StatelessWidget {
  final ScreenBuilder builder;

  const FormFactorBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return builder(context, constraints, ScreenFormFactor.of(context));
    });
  }
}

