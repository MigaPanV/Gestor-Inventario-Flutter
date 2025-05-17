import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({super.key, 
    required this.onChanged, 
    required this.errorText, 
    this.obscureText = false, required this.labeltext,
  });
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String labeltext;

  @override
  Widget build(BuildContext context) {
    return TextField(
    
      onChanged: (value) {
        onChanged!(value);
      },
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labeltext,
        errorText: errorText),
    );
  }
}