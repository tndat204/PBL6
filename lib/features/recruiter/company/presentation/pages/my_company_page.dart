import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/usecase/usecase.dart';
import 'package:pbl6/features/recruiter/company/presentation/widgets/my_company_logo.dart';
import 'package:pbl6/features/recruiter/company/presentation/widgets/my_company_tab_info.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/get_my_company_usecase.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/update_company_detail_usecase.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/update_company_logo_usecase.dart';
// 💡 Sửa đường dẫn import

import 'package:pbl6/features/shared/company/domain/entities/company.dart';

class MyCompanyPage extends StatefulWidget {
  const MyCompanyPage({super.key});

  @override
  State<MyCompanyPage> createState() => _MyCompanyPageState();
}

// 💡 Bỏ SingleTickerProviderStateMixin
class _MyCompanyPageState extends State<MyCompanyPage> {
  // --- UseCases ---
  late final GetMyCompanyUseCase _getMyCompanyUseCase;
  late final UpdateCompanyDetailsUseCase _updateCompanyDetailsUseCase;
  late final UpdateCompanyLogoUseCase _updateCompanyLogoUseCase;

  // --- State ---
  Company? _company;
  bool _isLoading = true;
  // 💡 Bỏ TabController
  // late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _getMyCompanyUseCase = GetIt.I<GetMyCompanyUseCase>();
    _updateCompanyDetailsUseCase = GetIt.I<UpdateCompanyDetailsUseCase>();
    _updateCompanyLogoUseCase = GetIt.I<UpdateCompanyLogoUseCase>();

    // 💡 Bỏ TabController
    // _tabController = TabController(length: 2, vsync: this);
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    try {
      final company = await _getMyCompanyUseCase(NoParams());
      if (mounted) {
        setState(() => _company = company);
      }
    } catch (e) {
      if (mounted) {
        MotionToast.error(
          description: Text('Không thể tải thông tin công ty: $e'),
        ).show(context);
        if (context.canPop()) context.pop();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadLogo() async {
    if (_company == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final path = image.path;
      final response = await _updateCompanyLogoUseCase(
        UpdateCompanyLogoParams(companyId: _company!.id, filePath: path),
      );

      final uploadedUrl = response.result;

      MotionToast.success(
        description: const Text("Cập nhật logo thành công"),
        toastAlignment: Alignment.topLeft,
        animationType: AnimationType.slideInFromLeft,
      ).show(context);

      setState(() {
        _company = _company?.copyWith(logoUrl: uploadedUrl);
      });
    } catch (e) {
      MotionToast.error(
        description: Text('Upload logo thất bại: $e'),
      ).show(context);
    }
  }

  Future<void> _handleSave(Company updatedCompanyData) async {
    try {
      final updatedCompany = await _updateCompanyDetailsUseCase(
        UpdateCompanyDetailsParams(
          id: _company!.id,
          company: updatedCompanyData,
        ),
      );

      setState(() {
        _company = updatedCompany;
      });

      MotionToast.success(
        description: const Text("Cập nhật thông tin thành công"),
        toastAlignment: Alignment.topLeft,
        animationType: AnimationType.slideInFromLeft,
      ).show(context);
    } catch (e) {
      MotionToast.error(description: Text('Lỗi cập nhật: $e')).show(context);
    }
  }

  @override
  void dispose() {
    // 💡 Bỏ dispose TabController
    // _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: _isLoading || _company == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // --- Header ---
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 48),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Thông tin công ty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Spacer
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- Logo Công ty ---
                  MyCompanyLogo(
                    logoUrl: _company?.logoUrl ?? '',
                    onTap: _pickAndUploadLogo,
                  ),

                  const SizedBox(height: 20),

                  // --- Bỏ Tab bar ---
                  // Container(...)

                  // --- Nội dung Form (thay thế TabBarView) ---
                  Expanded(
                    child: MyCompanyTabInfo(
                      // 💡 Hiển thị trực tiếp form
                      company: _company!,
                      onSave: _handleSave,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
