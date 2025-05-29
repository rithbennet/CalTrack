import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.fontSize = 24,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );

    if (padding != null) {
      return Padding(padding: padding!, child: titleWidget);
    }

    return titleWidget;
  }
}
