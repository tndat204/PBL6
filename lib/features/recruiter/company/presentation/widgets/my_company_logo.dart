import 'package:flutter/material.dart';

class MyCompanyLogo extends StatelessWidget {
  final String logoUrl;
  final VoidCallback onTap;

  const MyCompanyLogo({
    super.key,
    required this.logoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = logoUrl.isNotEmpty ? logoUrl : null;

    ImageProvider? backgroundImage;
    if (url != null) {
      backgroundImage = NetworkImage(url);
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? Icon(
                    Icons.business_rounded,
                    size: 50,
                    color: Colors.grey.shade700,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black87,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
