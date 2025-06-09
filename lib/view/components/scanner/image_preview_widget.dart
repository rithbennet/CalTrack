import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewWidget extends StatelessWidget {
  final File image;
  final double? height;
  final EdgeInsets? margin;

  const ImagePreviewWidget({
    super.key,
    required this.image,
    this.height = 200,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      margin: margin ?? const EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
      ),
    );
  }
}
