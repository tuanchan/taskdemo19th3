import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const BlurredContainer({
    Key? key,
    required this.child,
    this.blur = 10.0,
    this.color,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withOpacity(0.1),
            borderRadius: borderRadius ?? BorderRadius.circular(0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
