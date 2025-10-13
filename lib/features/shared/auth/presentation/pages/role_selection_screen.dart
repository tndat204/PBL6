import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/routes/route_names.dart';

import '../widgets/custom_elevated_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Chào bạn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Italianno',
                    fontSize: 46,
                    color: AppPallete.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Để tối ưu trải nghiệm của bạn với IT Job Hunt,\nvui lòng lựa chọn nhóm phù hợp nhất với bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppPallete.textColor,
                  ),
                ),
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/recruiter.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  child: CustomElevatedButton(
                    text: 'Tôi là nhà tuyển dụng',
                    onPressed: () {
                     context.push(RouteNames.RECRUITER_SIGNUP); 
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/student.png',
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  child: CustomElevatedButton(
                    text: 'Tôi là ứng viên',
                    onPressed: () {
                      context.push(RouteNames.SIGNUP); 
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
