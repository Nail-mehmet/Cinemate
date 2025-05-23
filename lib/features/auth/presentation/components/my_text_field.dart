import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool enabled;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
      
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
        
          enabledBorder:  OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(12)
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(12)
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          fillColor: Theme.of(context).colorScheme.tertiary,
          filled: true,
          enabled: enabled,
          
        ),
        
      ),
    );
  }
}