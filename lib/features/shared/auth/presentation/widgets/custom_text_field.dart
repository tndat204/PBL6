// file: features/shared/auth/presentation/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ THÊM IMPORT NÀY
import 'package:pbl6/core/theme/app_pallete.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters; // ✅ THÊM DÒNG NÀY

  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.obscureText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.inputFormatters, // ✅ THÊM DÒNG NÀY
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPallete.inputBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? AppPallete.primaryColor.withOpacity(0.1)
                : AppPallete.borderColor.withOpacity(0.1),
            blurRadius: _isFocused ? 12 : 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: TextFormField(
          controller: widget.controller,
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters, // ✅ THÊM DÒNG NÀY
          style: TextStyle(
            color: AppPallete.textColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: _isFocused ? AppPallete.primaryColor : AppPallete.mutedTextColor,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.icon,
                color: _isFocused ? AppPallete.primaryColor : AppPallete.mutedTextColor,
                size: 22,
              ),
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: _isFocused ? AppPallete.primaryColor : AppPallete.mutedTextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppPallete.borderColor,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppPallete.borderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppPallete.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            filled: true,
            fillColor: AppPallete.inputBackgroundColor,
          ),
          validator: widget.validator,
        ),
      ),
    );
  }
}