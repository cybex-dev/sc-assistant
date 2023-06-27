import 'package:flutter/material.dart';

class SCATextButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final double? width;
  final double? height;

  const SCATextButton({super.key, required this.onTap, required this.child, this.width, this.height});

  factory SCATextButton.text({
    required VoidCallback onTap,
    required String text,
    TextStyle? style,
    double? width,
    double? height,
  }) {
    return SCATextButton(
      onTap: onTap,
      height: height,
      width: width,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  factory SCATextButton.icon({
    required VoidCallback onTap,
    required Widget icon,
    required Widget label,
    double? width,
    double? height,
  }) {
    return SCATextButton(
      onTap: onTap,
      height: height,
      width: width,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          label,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: SizedBox(
        height: height,
        width: width,
        child: child,
      ),
    );
  }
}
