import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

/// 📝 Hộp thoại tích hợp Ghi chú và Tải CV
/// Trả về Map<String, String?>? { 'notes': string, 'filePath': string? }
Future<Map<String, String>?> showApplyNoteDialog(BuildContext context) async {
  final TextEditingController noteController = TextEditingController();
  
  // State cục bộ cho Dialog
  String? cvFilePath;
  bool isFilePicked = false;
  String? cvFileName;

  Future<void> pickCV(StateSetter setDialogState) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    final fileName = result.files.single.name;
    final file = File(filePath);

    // Kiểm tra kích thước file (Tối đa 5MB)
    final fileSize = await file.length();
    if (fileSize > 5 * 1024 * 1024) {
      MotionToast.error(
        description: const Text('Kích thước file vượt quá 5MB.'),
      ).show(context);
      return;
    }

    setDialogState(() {
      cvFilePath = filePath;
      cvFileName = fileName;
      isFilePicked = true;
    });
    
    MotionToast.info(
      description: Text('Đã chọn file: $fileName'),
      toastAlignment: Alignment.topCenter,
    ).show(context);
  }

  return showDialog<Map<String, String>?>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            title: const Text(
              "Gửi ứng tuyển & CV",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView( 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- 1. Tải CV ---
                    const Text(
                      "File CV (PDF, tùy chọn):",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    
                    // Khung thông tin file hiện tại
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isFilePicked ? AppPallete.primaryColor : Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isFilePicked ? Icons.description_outlined : Icons.upload_file,
                            color: isFilePicked ? AppPallete.primaryColor : Colors.grey,
                            size: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isFilePicked ? cvFileName! : 'Chưa có file nào được chọn',
                              style: TextStyle(
                                color: isFilePicked ? Colors.black87 : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isFilePicked)
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setDialogState(() {
                                  cvFilePath = null;
                                  cvFileName = null;
                                  isFilePicked = false;
                                });
                              },
                            )
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Nút hành động chọn file (Giao diện ProfileCVTab)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => pickCV(setDialogState),
                        icon: const Icon(Icons.upload_file_rounded),
                        label: Text(
                          isFilePicked ? 'Cập nhật/Chọn lại CV' : 'Chọn CV từ thiết bị',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppPallete.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Hỗ trợ: PDF (Tối đa 5MB)', 
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),

                    // --- 2. Ghi chú ---
                    const Text(
                      "Ghi chú (tuỳ chọn):",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    
                    SizedBox(
                      height: 120,
                      child: TextField(
                        controller: noteController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "Ví dụ: Tôi rất quan tâm đến vị trí này...",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppPallete.primaryColor, width: 2.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Trả về null (Hủy)
                child: const Text("Hủy", style: TextStyle(color: Colors.black54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                 
                    // Trả về Map chứa notes và filePath (có thể null)
                    Navigator.pop(context, {
                      'notes': noteController.text.trim(),
                      'filePath': cvFilePath ?? '', // Trả về chuỗi rỗng nếu null
                    });
                },
                child: const Text("Gửi ứng tuyển", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    },
  );
}