import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:motion_toast/motion_toast.dart';
// Core & Entities
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';
import 'package:pbl6/features/ai_matching/domain/usecases/match_multiple_cvs_usecase.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/get_applications_for_job_usecase.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/update_application_status_usecase.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
// Import UseCase lấy Job (Cần cái này để lấy jdUrl)
import 'package:pbl6/features/shared/job/domain/usecases/get_job_details_usecase.dart';

// Widgets
import 'ai_filter_bottom_sheet.dart';
import 'applicant_card.dart';
import 'status_filter_bar.dart';

class RecruiterJobApplicantsTab extends StatefulWidget {
  final String jobId;
  // Xóa biến jdFilePath thừa
  const RecruiterJobApplicantsTab({super.key, required this.jobId});

  @override
  State<RecruiterJobApplicantsTab> createState() => _RecruiterJobApplicantsTabState();
}

class _RecruiterJobApplicantsTabState extends State<RecruiterJobApplicantsTab> {
  // --- Dependencies ---
  late final GetApplicationsForJobUsecase _getApplicationsForJobUsecase;
  late final UpdateApplicationStatusUsecase _updateApplicationStatusUsecase;
  late final MatchMultipleCvsUseCase _matchMultipleCvsUseCase;
  // Khai báo nullable để tránh lỗi nếu chưa đăng ký Dependency
  GetJobDetailsUseCase? _getJobDetailsUseCase; 

  // --- State ---
  bool _isLoading = true;
  bool _isAiAnalyzing = false;
  String? _errorMessage;
  
  List<Application> _allApplicants = [];
  Job? _jobData; // Biến lưu thông tin Job để lấy URL

  // Filters
  ApplicationStatus? _selectedStatusFilter;
  bool _isAiFilterActive = false;
  Map<String, MatchScore> _aiMatchResults = {}; 
  int _topKOption = 0;

  @override
  void initState() {
    super.initState();
    _getApplicationsForJobUsecase = GetIt.I<GetApplicationsForJobUsecase>();
    _updateApplicationStatusUsecase = GetIt.I<UpdateApplicationStatusUsecase>();
    _matchMultipleCvsUseCase = GetIt.I<MatchMultipleCvsUseCase>();
    
    // Kiểm tra an toàn xem UseCase này đã được đăng ký chưa
    if (GetIt.I.isRegistered<GetJobDetailsUseCase>()) {
      _getJobDetailsUseCase = GetIt.I<GetJobDetailsUseCase>();
    }

    _loadData();
  }

  // --- 1. Data Loading (Tách biệt để an toàn) ---
  Future<void> _loadData() async {
    if (mounted) setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // BƯỚC 1: Lấy danh sách ứng viên (QUAN TRỌNG NHẤT)
      final applicants = await _getApplicationsForJobUsecase(widget.jobId);
      
      if (mounted) {
        setState(() {
          _allApplicants = applicants;
          // Reset bộ lọc
          _isAiFilterActive = false;
          _aiMatchResults.clear();
        });
      }

      // BƯỚC 2: Lấy thông tin Job (Phụ - để dùng AI)
      // Đặt trong try-catch riêng để nếu lỗi cũng không ảnh hưởng list ứng viên
      if (_getJobDetailsUseCase != null) {
        try {
          final job = await _getJobDetailsUseCase!(widget.jobId);
          if (mounted) {
            setState(() {
              _jobData = job;
            });
          }
        } catch (e) {
          debugPrint("⚠️ Lỗi lấy Job Detail (AI sẽ không dùng được): $e");
        }
      }

    } catch (e) {
      // Chỉ hiện lỗi nếu không tải được danh sách ứng viên
      if (mounted) setState(() => _errorMessage = 'Lỗi tải danh sách: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. AI Matching Logic (Dùng URL) ---
  Future<void> _runAiMatching(MatchWeights weights, int topK) async {
    // 1. Kiểm tra CV
    final cvUrls = _allApplicants
        .map((app) => app.cvFileUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    if (cvUrls.isEmpty) {
      MotionToast.warning(description: const Text("Không có CV nào để phân tích")).show(context);
      return;
    }

    // 2. Kiểm tra JD URL
    if (_jobData == null || _jobData!.jdFile.isEmpty) {
       MotionToast.error(description: const Text("Công việc này chưa có file mô tả (JD URL).")).show(context);
       return;
    }

    setState(() => _isAiAnalyzing = true);

    try {
      // 3. Gửi thẳng URL đi
      final params = MatchMultipleCvsParams(
        jdFilePath: _jobData!.jdFile!, // URL từ API
        cvFilePaths: cvUrls,
        weights: weights,
      );

      final AiMatchResponse response = await _matchMultipleCvsUseCase(params);
      final newResults = <String, MatchScore>{};

      // Mapping logic
      for (var result in response.results) {
        try {
          final matchingApp = _allApplicants.firstWhere(
            (app) {
               final decodedUrl = Uri.decodeFull(app.cvFileUrl);
               return decodedUrl.contains(result.cvFilename) || result.cvFilename.contains(decodedUrl);
            },
          );
          newResults[matchingApp.id] = result.matchScore;
        } catch (e) {
          debugPrint("Mapping error: $e");
        }
      }

      setState(() {
        _aiMatchResults = newResults;
        _isAiFilterActive = true;
        _topKOption = topK;
        _isAiAnalyzing = false;
      });
      MotionToast.success(description: const Text("Phân tích hoàn tất!")).show(context);
    } catch (e) {
      setState(() => _isAiAnalyzing = false);
      MotionToast.error(description: Text("Lỗi AI: $e")).show(context);
    }
  }

  // --- 3. Update Status ---
  Future<void> _updateStatus(String appId, ApplicationStatus newStatus) async {
    try {
      await _updateApplicationStatusUsecase(applicationId: appId, newStatus: newStatus);
      if (mounted) {
        MotionToast.success(description: const Text('Cập nhật thành công')).show(context);
        // Chỉ reload lại danh sách ứng viên cho nhanh
        final apps = await _getApplicationsForJobUsecase(widget.jobId);
        setState(() {
          _allApplicants = apps;
        });
      }
    } catch (e) {
      if (mounted) MotionToast.error(description: Text('Lỗi: $e')).show(context);
    }
  }

  // --- 4. Filter Logic ---
  List<Application> get _filteredApplicants {
    List<Application> temp = List.from(_allApplicants);

    if (_selectedStatusFilter != null) {
      temp = temp.where((app) => app.status == _selectedStatusFilter).toList();
    }

    if (_isAiFilterActive) {
      temp = temp.where((app) => _aiMatchResults.containsKey(app.id)).toList();
      temp.sort((a, b) {
        final scoreA = _aiMatchResults[a.id]?.totalScore ?? 0.0;
        final scoreB = _aiMatchResults[b.id]?.totalScore ?? 0.0;
        return scoreB.compareTo(scoreA);
      });
      if (_topKOption > 0 && temp.length > _topKOption) {
        temp = temp.sublist(0, _topKOption);
      }
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            StatusFilterBar(
              selectedStatus: _selectedStatusFilter,
              onStatusChanged: (val) => setState(() => _selectedStatusFilter = val),
              isAiFilterActive: _isAiFilterActive,
              topKOption: _topKOption,
              onAiFilterPressed: () {
                // Kiểm tra xem đã load được Job chưa
                if (_jobData == null) {
                  MotionToast.warning(description: const Text("Đang tải thông tin công việc hoặc không tìm thấy...")).show(context);
                  // Thử load lại Job nếu lần đầu thất bại
                  if (_getJobDetailsUseCase != null) {
                    _getJobDetailsUseCase!(widget.jobId).then((value) {
                        setState(() => _jobData = value);
                        MotionToast.success(description: const Text("Đã tải xong thông tin, hãy thử lại!")).show(context);
                    });
                  }
                  return;
                }

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (context) => AiFilterBottomSheet(onApply: _runAiMatching),
                );
              },
              onClearAiFilter: () {
                setState(() {
                  _isAiFilterActive = false;
                  _aiMatchResults.clear();
                });
              },
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _filteredApplicants.isEmpty
                  ? Center(
                      child: Text(
                        _isAiFilterActive 
                            ? 'Không tìm thấy ứng viên phù hợp tiêu chí AI.'
                            : 'Chưa có ứng viên.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: _filteredApplicants.length,
                      itemBuilder: (context, index) {
                        final app = _filteredApplicants[index];
                        return ApplicantCard(
                          application: app,
                          onStatusUpdate: _updateStatus,
                          onRefresh: () => _loadData(),
                          matchScore: _isAiFilterActive ? _aiMatchResults[app.id] : null,
                        );
                      },
                    ),
            ),
          ],
        ),

        if (_isAiAnalyzing)
          Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}