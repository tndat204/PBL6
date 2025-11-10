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
  final String? semanticsLabel;

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
    this.semanticsLabel,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel ?? widget.label,
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: DropdownButtonFormField<T?>(
          key: ValueKey(widget.semanticsLabel),
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
            // SỬA: Luôn hiển thị label, nó sẽ tự động nổi lên
            labelText: widget.label,
            // SỬA: Xóa hintText khỏi InputDecoration,
            // vì ta đã dùng hint ở ngoài
            hintText: null,
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
            // ✅ Đảm bảo style lỗi đồng nhất
            errorStyle: TextStyle(
              color: Colors.red[700],
              fontSize: 13, // Kích thước nhỏ hơn
              fontWeight: FontWeight.w500,
              height: 1.2, // Khoảng cách dòng
            ),
            errorMaxLines: 1, // Chỉ cho phép 1 dòng lỗi
          ),
          // SỬA: Đây là hint chính để hiển thị khi value=null
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
    );
  }
}