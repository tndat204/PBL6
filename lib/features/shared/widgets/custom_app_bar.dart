import 'package:awesome_dialog/awesome_dialog.dart'; // THÊM
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart'; // THÊM
import 'package:go_router/go_router.dart';
import 'package:pbl6/features/shared/auth/domain/usecases/logout_usecase.dart'; // THÊM
import 'package:pbl6/routes/route_names.dart'; // THÊM
import 'package:provider/provider.dart';

import '../user/presentation/providers/user_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // const CustomAppBar({super.key}); // Bỏ `const` để dùng hàm
  CustomAppBar({super.key}); // Bỏ `const`

  // TẠO HÀM XỬ LÝ LOGOUT
  Future<void> _handleLogout(BuildContext context) async {
    // Lấy UseCase và Provider TRƯỚC khi hiển thị dialog
    // Dùng context.read vì đang ở trong callback
    final logoutUseCase = GetIt.I<LogoutUseCase>();
    final userProvider = context.read<UserProvider>();

    AwesomeDialog(
      context: context,
      dialogType:
          DialogType.noHeader, // Ẩn icon cảnh báo mặc định (màu vàng chói)
      animType: AnimType.scale,
      dialogBackgroundColor: Colors.white, // Nền trắng nhẹ, dễ nhìn hơn
      borderSide: BorderSide(color: Colors.red.shade300, width: 1.2),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade600,
            size: 50,
          ),
          const SizedBox(height: 12),
          Text(
            'Đăng xuất',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog
                },
                child: const Text('Hủy bỏ'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await logoutUseCase();
                  userProvider.clearUser();
                  if (context.mounted) {
                    context.go(RouteNames.LOGIN);
                  }
                },
                child: const Text('Đồng ý'),
              ),
            ],
          ),
        ],
      ),
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    // Directly watch the provider
    final effectiveUser = context.watch<UserProvider>().user;

    // Show a basic AppBar while user is loading (or handle null differently)
    if (effectiveUser == null) {
      // You could return an empty AppBar or a placeholder
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 80,
        title: const Text('Đang tải...'), // Or keep it blank
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 30),
            onPressed: () {},
          ),
          // THÊM NÚT LOGOUT (disabled khi chưa load xong)
          IconButton(
            icon: Icon(
              Icons.logout_outlined,
              size: 30,
              color: Colors.grey.shade400,
            ),
            onPressed: null, // Vô hiệu hóa
          ),
          const SizedBox(width: 8), // Thêm padding
        ],
      );
    }

    // ✅ SIMPLIFIED URL LOGIC (as done previously)
    final avatarUrl = effectiveUser.avatarUrl.isNotEmpty
        ? effectiveUser.avatarUrl
        : null;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      title: GestureDetector(
        onTap: () => context.push('/user/my-info'),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : const AssetImage('assets/images/avatar.png')
                        as ImageProvider,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                Text(
                  effectiveUser.fullName.isNotEmpty
                      ? effectiveUser.fullName
                      : 'Người dùng', // Fallback name
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 30),
          onPressed: () {
            // TODO: Điều hướng đến trang thông báo
          },
          tooltip: 'Thông báo',
        ),
        // THÊM NÚT LOGOUT MỚI
        IconButton(
          icon: Icon(Icons.logout_outlined, size: 30),
          onPressed: () => _handleLogout(context), // Gọi hàm xử lý
          tooltip: 'Đăng xuất',
        ),
        const SizedBox(width: 8), // Thêm padding
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
