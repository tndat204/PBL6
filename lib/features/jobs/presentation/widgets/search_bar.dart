import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final VoidCallback? onFilterPressed;

  const CustomSearchBar({
    Key? key,
    this.onSearchChanged,
    this.onFilterPressed,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 👇 Khi người dùng bấm ra ngoài, TextField sẽ mất focus
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: _isFocused
                        ? AppPallete.primaryColor
                        : AppPallete.borderColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    // 👇 Hiệu ứng glow khi focus
                    if (_isFocused)
                      BoxShadow(
                        color: AppPallete.primaryColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: TextField(
                  focusNode: _focusNode,
                  onChanged: widget.onSearchChanged,
                  style: const TextStyle(
                    color: AppPallete.textColor,
                    fontSize: 15,
                  ),
                  cursorColor: AppPallete.primaryColor,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 22,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppPallete.borderColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.tune_rounded, color: Colors.grey.shade700),
                onPressed: widget.onFilterPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
