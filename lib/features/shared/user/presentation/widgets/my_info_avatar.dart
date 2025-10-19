import 'package:flutter/material.dart';
import 'package:pbl6/core/constants/api_constants.dart';

class MyInfoAvatar extends StatelessWidget {
  final String avatarUrl;
  final VoidCallback onTap;

  const MyInfoAvatar({super.key, required this.avatarUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl.isNotEmpty
        ? (avatarUrl.startsWith('http')
            ? avatarUrl
            : '${ApiConstants.baseUrl}$avatarUrl')
        : null;

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 55,
        backgroundColor: Colors.grey.shade300,
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
