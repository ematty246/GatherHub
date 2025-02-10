import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final TextStyle? textStyle;
  final FocusNode? focusNode;
  final TextStyle hintStyle;
  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.focusNode,
    this.textStyle,
    required this.hintStyle,
    required InputDecoration decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscureText,
        style: textStyle ?? const TextStyle(color: Colors.black),
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.orange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          fillColor: Colors.white.withOpacity(0.1),
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
