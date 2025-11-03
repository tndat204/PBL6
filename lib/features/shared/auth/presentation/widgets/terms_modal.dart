import 'package:flutter/material.dart';

class TermsModal {
static void show(BuildContext context) {
showDialog(
context: context,
builder: (context) {
return AlertDialog(
title: const Text(
"Điều khoản sử dụng",
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 20,
),
textAlign: TextAlign.center,
),
content: SizedBox(
width: double.maxFinite,
child: Scrollbar(
child: ListView(
shrinkWrap: true,
children: [
_buildSection("1. Chấp nhận điều khoản",
"Bằng cách truy cập hoặc sử dụng Dịch vụ, bạn đồng ý bị ràng buộc bởi các Điều khoản này. Nếu không đồng ý, bạn không được phép truy cập Dịch vụ."),
_buildSection("2. Quyền riêng tư",
"Việc sử dụng Dịch vụ tuân theo Chính sách quyền riêng tư, mô tả cách chúng tôi thu thập, sử dụng và bảo vệ thông tin của bạn."),
_buildSection("3. Nội dung",
"Dịch vụ cho phép bạn đăng, lưu trữ, chia sẻ thông tin, văn bản, đồ họa, video hoặc tài liệu khác. Bạn chịu trách nhiệm về Nội dung mà bạn đăng."),
_buildSection("4. Chấm dứt",
"Chúng tôi có thể chấm dứt hoặc đình chỉ quyền truy cập ngay lập tức mà không cần thông báo trước nếu bạn vi phạm Điều khoản."),
_buildSection("5. Thay đổi",
"Chúng tôi có quyền sửa đổi hoặc thay thế các Điều khoản bất cứ lúc nào. Việc tiếp tục sử dụng Dịch vụ đồng nghĩa bạn chấp nhận các thay đổi."),
],
),
),
),
actions: [
TextButton(
onPressed: () => Navigator.of(context).pop(),
child: const Text(
"Đã hiểu",
style: TextStyle(fontWeight: FontWeight.bold),
),
),
],
);
},
);
}

static Widget _buildSection(String title, String content) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8.0),
child: RichText(
text: TextSpan(
style: const TextStyle(
fontSize: 14,
height: 1.5,
color: Colors.black87,
),
children: [
TextSpan(
text: "$title\n",
style: const TextStyle(
fontWeight: FontWeight.bold,
),
),
TextSpan(text: content),
],
),
),
);
}
}
