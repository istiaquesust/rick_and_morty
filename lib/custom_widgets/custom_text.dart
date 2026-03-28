import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rick_and_morty/util/constants.dart';

class CustomText extends StatelessWidget {
  final String? text;
  final Color? color;
  final TextAlign? textAlign;
  final double? fontSize;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextOverflow? overflow;
  const CustomText({
    super.key,
    required this.text,
    this.color,
    this.textAlign,
    this.fontSize,
    this.fontWeight,
    this.maxLines,
    this.overflow,
  });

  @override
  Text build(BuildContext context) {
    return Text(
      text!,
      style: GoogleFonts.luckiestGuy( // <--- Change the font family here
      color: color ?? color5,
      fontSize: fontSize ?? 14, // Simplified null check
      fontWeight: fontWeight ?? FontWeight.normal,
      letterSpacing: 1.2, // Bouncy fonts look better with a little space
    ),
      textAlign: textAlign ?? TextAlign.left,
      overflow: overflow ?? TextOverflow.ellipsis,
      maxLines: maxLines,
    );
  }
}
