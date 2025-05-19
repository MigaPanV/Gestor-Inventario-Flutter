import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, 
    this.onChanged, 
    required this.errorText, 
    this.obscureText = false, 
    required this.labeltext, 
    this.controller,
  });
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String labeltext;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
    
      onChanged: (value) {
        onChanged!(value);
      },
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labeltext,
        errorText: errorText),
    );
  }
}