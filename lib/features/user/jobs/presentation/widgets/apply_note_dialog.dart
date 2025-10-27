import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

/// 📝 Hộp thoại ghi chú khi ứng tuyển (Sử dụng TextField đơn giản - Đã cải tiến)
Future<String?> showApplyNoteDialog(BuildContext context) async {
  final TextEditingController noteController = TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        // ✅ Đặt màu nền cho dialog để chắc chắn
        backgroundColor: Colors.white,
        title: const Text(
          "Gửi ghi chú ứng tuyển",
          // ✅ Đảm bảo tiêu đề có màu
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: SizedBox(
          // ✅ Chiều cao phù hợp cho TextField
          height: 200,
          width: MediaQuery.of(context).size.width, // Mở rộng
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ghi chú (tuỳ chọn):",
                style: TextStyle(
                  fontSize: 14,
                  // ✅ Đảm bảo label có màu
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: noteController,
                  
                  // ✅ Tự động xử lý xuống hàng '\n' khi nhấn Enter
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  
                  // ✅ Đảm bảo chữ khi gõ có màu đen
                  style: const TextStyle(color: Colors.black),
                  
                  decoration: InputDecoration(
                    hintText: "Ví dụ: Tôi rất quan tâm đến vị trí này...",
                    
                    // ✅ Chữ gợi ý màu xám
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    
                    // ✅ Định nghĩa màu viền
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    // ✅ Viền màu chính khi được focus
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppPallete.primaryColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Trả về null (Hủy)
            child: const Text(
              "Hủy",
              // ✅ Nút hủy có màu
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // ✅ Trả về text. Nếu rỗng thì trả về null
              final text = noteController.text.trim();
              if (text.isEmpty) {
                Navigator.pop(context, null);
              } else {
                // Chuỗi 'text' ở đây đã tự động chứa '\n' nếu người dùng xuống hàng
                Navigator.pop(context, text); 
              }
            },
            child: const Text(
              "Gửi",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}