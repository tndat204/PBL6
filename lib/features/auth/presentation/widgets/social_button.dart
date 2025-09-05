import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

class SocialButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final String? imagePath;
  final VoidCallback onPressed;
  final Color iconColor;

  const SocialButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.imagePath,
    this.iconColor = AppPallete.primaryColor,
  });

  @override
  State<SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<SocialButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
      height: 56, // Consistent height with primary button
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: AppPallete.whiteColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppPallete.borderColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppPallete.borderColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  _controller.forward().then((_) {
                    _controller.reverse();
                    widget.onPressed();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: widget.imagePath != null
                    ? Container(
                        padding: const EdgeInsets.all(2),
                        child: Image.asset(
                          widget.imagePath!,
                          height: 24,
                          width: 24,
                        ),
                      )
                    : Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 24,
                      ),
                label: Text(
                  widget.text,
                  style: TextStyle(
                    color: AppPallete.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
