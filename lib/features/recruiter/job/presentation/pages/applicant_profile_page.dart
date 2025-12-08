import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/ai_matching/domain/entities/ai_matching_entities.dart';
import 'package:pbl6/features/shared/application/domain/entities/application.dart'; // Import Application entity
import 'package:url_launcher/url_launcher.dart';

import '../../../../user/profile/domain/entities/profile_entity.dart';
import '../../../../user/profile/domain/usecases/get_user_profile_usecase.dart';

class ApplicantProfilePage extends StatefulWidget {
  final Application application; // 💡 Nhận nguyên object Application
  final MatchScore? matchScore;

  const ApplicantProfilePage({
    super.key,
    required this.application,
    this.matchScore,
  });

  @override
  State<ApplicantProfilePage> createState() => _ApplicantProfilePageState();
}

class _ApplicantProfilePageState extends State<ApplicantProfilePage> {
  late final GetUserProfileUseCase _getUserProfileUseCase;
  bool _isLoading = true;
  ProfileEntity? _profile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getUserProfileUseCase = GetIt.I<GetUserProfileUseCase>();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    // Dùng applicantId từ object application để lấy profile chi tiết
    final result = await _getUserProfileUseCase(
        GetUserProfileParams(userId: widget.application.applicantId));

    if (mounted) {
      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (profile) {
          setState(() {
            _isLoading = false;
            _profile = profile;
          });
        },
      );
    }
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở liên kết này')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Thông tin ứng viên",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12), // Line ngăn cách header nhẹ

            // --- 2. BODY CONTENT ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Dù profile chưa load xong hoặc lỗi, ta vẫn hiển thị được Header từ thông tin Application có sẵn
    // Nhưng ở đây logic là load xong profile mới hiện body.
    if (_profile == null) return const Center(child: Text("Không có dữ liệu profile"));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Điểm AI
          if (widget.matchScore != null) ...[
            _buildAiScoreSection(widget.matchScore!),
            const SizedBox(height: 24),
          ],

          // 2. Header Profile (Lấy từ Application Info để đảm bảo có Avatar/Tên/SĐT)
          _buildHeaderSection(),
          const SizedBox(height: 20),

          // 3. Liên kết (Filled Buttons)
          _buildLinksSection(),

          const SizedBox(height: 24),
          const Divider(thickness: 1, color: Colors.black), // 💡 Divider màu đen
          const SizedBox(height: 24),

          // 4. Giới thiệu
          if (_profile!.summary != null && _profile!.summary!.isNotEmpty) ...[
            const Text(
              "Giới thiệu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Text(
              _profile!.summary!,
              style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1, color: Colors.black), // 💡 Divider màu đen
            const SizedBox(height: 24),
          ],

          // 5. Kỹ năng (List View từng dòng)
          if (_profile!.skills.isNotEmpty) ...[
            const Text(
              "Kỹ năng chuyên môn",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            ..._profile!.skills.map((skill) => _buildSkillRow(skill)),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  // --- WIDGET CON: KỸ NĂNG THEO DÒNG ---
  Widget _buildSkillRow(UserSkillEntity skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Icon chấm tròn phân loại skill chính
          Icon(
            skill.isPrimary ? Icons.star_rounded : Icons.circle,
            size: 16,
            color: skill.isPrimary ? AppPallete.primaryColor : Colors.grey,
          ),
          const SizedBox(width: 12),
          
          // Tên kỹ năng
          Expanded(
            child: Text(
              skill.skill.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: skill.isPrimary ? AppPallete.primaryColor : Colors.black87,
              ),
            ),
          ),

          // Level và Năm kinh nghiệm
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  skill.level,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${skill.experienceYears} năm kinh nghiệm",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON: HEADER (Dùng dữ liệu từ Application) ---
  Widget _buildHeaderSection() {
    final info = widget.application.applicantInfo;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: info.avatarUrl.isNotEmpty
              ? NetworkImage(info.avatarUrl)
              : null,
          child: info.avatarUrl.isEmpty
              ? const Icon(Icons.person, size: 40, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.fullName, // 💡 Hiển thị tên từ Application
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              
              // Email
              _buildIconText(Icons.email_outlined, info.email),
              const SizedBox(height: 4),
              
              // Phone
              _buildIconText(Icons.phone_outlined, info.phone),
              const SizedBox(height: 4),
              
              // Address
              _buildIconText(Icons.location_on_outlined, info.address),
              
              // Headline & Salary từ Profile (nếu có)
              if (_profile?.headline != null) ...[
                const SizedBox(height: 8),
                Text(
                  _profile!.headline!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // --- WIDGET CON: LINKS (FILLED BACKGROUND) ---
  Widget _buildLinksSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Nút Tải CV
        if (_profile!.cvFile != null && _profile!.cvFile!.isNotEmpty)
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(_profile!.cvFile),
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text("Tải CV"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        
        // LinkedIn (Filled Blue)
        if (_profile!.linkedinUrl != null && _profile!.linkedinUrl!.isNotEmpty)
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(_profile!.linkedinUrl),
              icon: const Icon(Icons.link, size: 18),
              label: const Text("LinkedIn"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077B5), // 💡 Màu nền xanh đặc
                foregroundColor: Colors.white,            // Chữ trắng
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          
        // Portfolio (Filled Black)
        if (_profile!.portfolioUrl != null && _profile!.portfolioUrl!.isNotEmpty)
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(_profile!.portfolioUrl),
              icon: const Icon(Icons.language, size: 18),
              label: const Text("Portfolio"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87, // 💡 Màu nền đen đặc
                foregroundColor: Colors.white,   // Chữ trắng
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
      ],
    );
  }

  // --- WIDGET CON: AI SCORE ---
  Widget _buildAiScoreSection(MatchScore score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPallete.primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppPallete.primaryColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppPallete.primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Đánh giá phù hợp bởi AI", 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppPallete.primaryColor)
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppPallete.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${score.totalScore.toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sử dụng Divider màu đen nhạt trong box điểm số
          const Divider(color: Colors.black12, height: 20),
          _buildScoreRow("Kỹ năng chuyên môn", score.technicalSkills),
          _buildScoreRow("Kinh nghiệm", score.experience),
          _buildScoreRow("Kỹ năng mềm", score.softSkills),
          _buildScoreRow("Học vấn", score.education),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double value) {
    // ... (Giữ nguyên logic hiển thị thanh progress bar)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value / 100,
                    backgroundColor: Colors.grey.shade100,
                    color: _getScoreColor(value),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                child: Text(
                  "${value.toInt()}", 
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), 
                  textAlign: TextAlign.end
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}