// file: features/shared/user/presentation/widgets/my_info_avatar.dart

import 'package:flutter/material.dart';
// Remove the ApiConstants import if it's not used elsewhere in this file
// import 'package:pbl6/core/constants/api_constants.dart';

class MyInfoAvatar extends StatelessWidget {
  final String avatarUrl;
  final VoidCallback onTap;

  const MyInfoAvatar({super.key, required this.avatarUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // ✅ SIMPLIFIED LOGIC: Use avatarUrl directly if not empty
    final url = avatarUrl.isNotEmpty ? avatarUrl : null;

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 55,
        backgroundColor: Colors.grey.shade300,
        // Use NetworkImage directly with the potentially null 'url'
        backgroundImage: url != null
            ? NetworkImage(url)
            : const AssetImage('assets/images/avatar.png') as ImageProvider,
        child: Align(
          alignment: Alignment.bottomRight,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black87,
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}