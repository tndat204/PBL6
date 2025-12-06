import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:motion_toast/motion_toast.dart';
// Import các Entity và UseCase của bạn
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';
import 'package:pbl6/features/ai_matching/domain/usecases/match_multiple_cvs_usecase.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/get_applications_for_job_usecase.dart';
import 'package:pbl6/features/recruiter/job/domain/usecases/update_application_status_usecase.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart';
import 'package:pbl6/features/shared/job/domain/entities/job.dart';
import 'package:pbl6/features/shared/job/domain/usecases/get_job_details_usecase.dart';

import 'ai_filter_bottom_sheet.dart';
import 'applicant_card.dart';
import 'status_filter_bar.dart';

class RecruiterJobApplicantsTab extends StatefulWidget {
  final String jobId;

  const RecruiterJobApplicantsTab({super.key, required this.jobId});

  @override
  State<RecruiterJobApplicantsTab> createState() => _RecruiterJobApplicantsTabState();
}

class _RecruiterJobApplicantsTabState extends State<RecruiterJobApplicantsTab> {
  // --- Dependencies ---
  late final GetApplicationsForJobUsecase _getApplicationsForJobUsecase;
  late final UpdateApplicationStatusUsecase _updateApplicationStatusUsecase;
  late final MatchMultipleCvsUseCase _matchMultipleCvsUseCase;
  late final GetJobDetailsUseCase _getJobDetailsUseCase; 

  // --- State ---
  bool _isLoading = true;
  bool _isAiAnalyzing = false;
  String? _errorMessage;

  // Data
  List<Application> _allApplicants = [];
  Job? _jobData; // Lưu job để lấy jdFile url

  // Filter & AI Result
  ApplicationStatus? _selectedStatusFilter;
  bool _isAiFilterActive = false;
  
  // Map lưu kết quả điểm số: Key = Application ID, Value = MatchScore
  Map<String, MatchScore> _aiMatchResults = {}; 
  int _topKOption = 0;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dependencies
    _getApplicationsForJobUsecase = GetIt.I<GetApplicationsForJobUsecase>();
    _updateApplicationStatusUsecase = GetIt.I<UpdateApplicationStatusUsecase>();
    _matchMultipleCvsUseCase = GetIt.I<MatchMultipleCvsUseCase>();
    _getJobDetailsUseCase = GetIt.I<GetJobDetailsUseCase>();

    _loadData();
  }

  // --- 1. Load Data (Job & Applicants) ---
  Future<void> _loadData() async {
    if (mounted) setState(() { _isLoading = true; _errorMessage = null; });

    try {
      // Chạy song song 2 luồng: Lấy Job (để có JD) và Lấy danh sách Ứng viên
      final results = await Future.wait([
        _getJobDetailsUseCase(widget.jobId),
        _getApplicationsForJobUsecase(widget.jobId),
      ]);

      final job = results[0] as Job;
      final applicants = results[1] as List<Application>;

      if (mounted) {
        setState(() {
          _jobData = job;
          _allApplicants = applicants;
          // Reset filters khi reload
          _isAiFilterActive = false;
          _aiMatchResults.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi tải dữ liệu: $e';
        });
      }
      debugPrint("Error loading data: $e");
    }
  }

  // --- 2. AI Matching Logic (Core) ---
  Future<void> _runAiMatching(MatchWeights weights, int topK) async {
    // A. Kiểm tra dữ liệu đầu vào
    if (_jobData == null || _jobData!.jdFile.isEmpty) {
      MotionToast.error(
        title: const Text("Thiếu JD"),
        description: const Text("Công việc này chưa có file mô tả (JD URL)."),
      ).show(context);
      return;
    }

    // Lọc ra danh sách URL của các CV (bỏ qua những cái rỗng)
    final cvUrls = _allApplicants
        .map((app) => app.cvFileUrl)
        .where((url) => url.isNotEmpty)
        .toList();

    if (cvUrls.isEmpty) {
      MotionToast.warning(
        title: const Text("Trống"),
        description: const Text("Không có CV nào để phân tích."),
      ).show(context);
      return;
    }

    setState(() => _isAiAnalyzing = true);

    try {
      // B. Gọi API Match
      final params = MatchMultipleCvsParams(
        jdUrl: _jobData!.jdFile, // Lấy URL từ Job
        cvUrls: cvUrls,          // List URL từ Applications
        weights: weights,
      );

      final AiMatchResponse response = await _matchMultipleCvsUseCase(params);

      // C. Map kết quả từ API về Application ID
      final newResults = <String, MatchScore>{};

      for (var result in response.results) {
        try {
          // Tìm ứng viên có cvFileUrl khớp với cv_url trả về từ API
          // Lưu ý: So sánh chuỗi URL đôi khi cần decode để tránh lỗi %20
          final matchingApp = _allApplicants.firstWhere(
            (app) {
               // Cách 1: So sánh chính xác
               if (app.cvFileUrl == result.cvUrl) return true;
               
               // Cách 2: So sánh tương đối (nếu server trả về link đã encode/decode khác client)
               final appUrlDecoded = Uri.decodeFull(app.cvFileUrl);
               final resUrlDecoded = Uri.decodeFull(result.cvUrl);
               return appUrlDecoded == resUrlDecoded;
            },
            orElse: () => _allApplicants.first, // Fallback (không nên xảy ra)
          );
          
          // Lưu điểm số vào Map với Key là ApplicationID
          if (matchingApp.cvFileUrl == result.cvUrl || Uri.decodeFull(matchingApp.cvFileUrl) == Uri.decodeFull(result.cvUrl)) {
             newResults[matchingApp.id] = result.matchScore;
          }
        } catch (e) {
          debugPrint("Không tìm thấy ứng viên khớp với kết quả: ${result.cvUrl}");
        }
      }

      // D. Cập nhật UI
      setState(() {
        _aiMatchResults = newResults;
        _isAiFilterActive = true;
        _topKOption = topK;
        _isAiAnalyzing = false;
      });

      MotionToast.success(
        title: const Text("Hoàn tất"),
        description: Text("Đã phân tích ${response.results.length} hồ sơ."),
      ).show(context);

    } catch (e) {
      setState(() => _isAiAnalyzing = false);
      MotionToast.error(
        title: const Text("Lỗi AI"),
        description: Text(e.toString()),
      ).show(context);
    }
  }

  // --- 3. Update Status ---
  Future<void> _updateStatus(String appId, ApplicationStatus newStatus) async {
    try {
      await _updateApplicationStatusUsecase(applicationId: appId, newStatus: newStatus);
      if (mounted) {
        MotionToast.success(description: const Text('Cập nhật trạng thái thành công')).show(context);
        // Reload lại list sau khi update (để UI đồng bộ)
        final apps = await _getApplicationsForJobUsecase(widget.jobId);
        setState(() {
          _allApplicants = apps;
        });
      }
    } catch (e) {
      if (mounted) MotionToast.error(description: Text('Lỗi: $e')).show(context);
    }
  }

  // --- 4. Filtering & Sorting Logic ---
  List<Application> get _filteredApplicants {
    List<Application> temp = List.from(_allApplicants);

    // 1. Lọc theo Status (nếu user chọn trên thanh filter)
    if (_selectedStatusFilter != null) {
      temp = temp.where((app) => app.status == _selectedStatusFilter).toList();
    }

    // 2. Nếu đang dùng AI Filter
    if (_isAiFilterActive) {
      // Chỉ lấy những người có điểm số (những người có trong map _aiMatchResults)
      temp = temp.where((app) => _aiMatchResults.containsKey(app.id)).toList();

      // Sắp xếp: Điểm cao lên đầu (Descending)
      temp.sort((a, b) {
        final scoreA = _aiMatchResults[a.id]?.totalScore ?? 0.0;
        final scoreB = _aiMatchResults[b.id]?.totalScore ?? 0.0;
        return scoreB.compareTo(scoreA); // B so sánh A -> Giảm dần
      });

      // Lấy Top K (nếu user chọn limit)
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
            
            // --- THANH FILTER ---
            StatusFilterBar(
              selectedStatus: _selectedStatusFilter,
              onStatusChanged: (val) => setState(() => _selectedStatusFilter = val),
              isAiFilterActive: _isAiFilterActive,
              topKOption: _topKOption,
              onAiFilterPressed: () {
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

            // --- DANH SÁCH ỨNG VIÊN ---
            Expanded(
              child: _filteredApplicants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 10),
                          Text(
                            _isAiFilterActive 
                                ? 'Không tìm thấy ứng viên phù hợp tiêu chí AI.'
                                : 'Chưa có ứng viên nào.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: _filteredApplicants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final app = _filteredApplicants[index];
                        // Lấy điểm số nếu AI đang active
                        final scoreObj = _isAiFilterActive ? _aiMatchResults[app.id] : null;

                        return ApplicantCard(
                          application: app,
                          onStatusUpdate: _updateStatus,
                          onRefresh: () {}, // Không cần reload toàn bộ ở đây
                          matchScore: scoreObj, // Truyền điểm số vào Card để hiển thị
                        );
                      },
                    ),
            ),
          ],
        ),

        // --- LOADING OVERLAY (KHI AI ĐANG CHẠY) ---
        if (_isAiAnalyzing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "AI đang đọc & chấm điểm hồ sơ...",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}