// file: features/shared/auth/presentation/widgets/custom_elevated_button.dart

import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

class CustomElevatedButton extends StatefulWidget {
  final String text;
  // 💡 Change to Function()? to allow null for disabled state
  final Function()? onPressed;
  // 💡 Add isLoading parameter
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    // 💡 Initialize isLoading (default to false)
    this.isLoading = false,
  });

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                // 💡 Use grey gradient if disabled or loading
                gradient: LinearGradient(
                  colors: widget.onPressed == null || widget.isLoading
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : AppPallete.primaryGradient,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.onPressed == null || widget.isLoading
                        ? Colors.grey.withOpacity(0.2)
                        : AppPallete.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                // 💡 Disable button if onPressed is null OR isLoading is true
                onPressed: (widget.onPressed == null || widget.isLoading)
                    ? null
                    : () {
                        _controller.forward().then((_) {
                          _controller.reverse();
                          // 💡 Call the function directly
                          widget.onPressed!();
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  // 💡 Ensure disabled state uses the container's background
                  disabledBackgroundColor: Colors.transparent,
                ),
                // 💡 Conditionally show Indicator or Text
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}