// file: features/shared/auth/presentation/widgets/custom_dropdown_field.dart

import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

class CustomDropdownField<T> extends StatefulWidget {
  final String label;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final String? hint;
  final String? semanticsLabel; // 💡 THÊM MỚI

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.hint,
    this.semanticsLabel, // 💡 THÊM MỚI
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    // 💡 BỌC BẰNG SEMANTICS
    return Semantics(
      label: widget.semanticsLabel ?? widget.label,
      child: Container(
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
          child: DropdownButtonFormField<T>(
            key: ValueKey(widget.semanticsLabel), // 💡 Thêm key
            value: widget.value,
            onChanged: widget.enabled ? widget.onChanged : null,
            validator: widget.validator,
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down,
              color: _isFocused
                  ? AppPallete.primaryColor
                  : AppPallete.mutedTextColor,
            ),
            dropdownColor: AppPallete.inputBackgroundColor,
            style: TextStyle(
              color: AppPallete.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              labelText: (_isFocused || widget.value != null)
                  ? widget.label
                  : null, 
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppPallete.mutedTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              labelStyle: TextStyle(
                color: _isFocused
                    ? AppPallete.primaryColor
                    : AppPallete.mutedTextColor,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  color: _isFocused
                      ? AppPallete.primaryColor
                      : AppPallete.mutedTextColor,
                  size: 22,
                ),
              ),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              filled: true,
              fillColor: AppPallete.inputBackgroundColor,
            ),
            hint: widget.hint != null
                ? Text(
                    widget.hint!,
                    style: TextStyle(
                      color: AppPallete.mutedTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
            items: widget.items,
          ),
        ),
      ),
    );
  }
}