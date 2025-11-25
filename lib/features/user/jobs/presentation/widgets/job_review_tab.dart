import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/auth/presentation/widgets/custom_text_field.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';
import 'package:pbl6/features/shared/review/domain/entities/review_paginated_response.dart';
import 'package:pbl6/features/shared/review/domain/usecases/create_report_usecase.dart';
import 'package:pbl6/features/shared/review/domain/usecases/create_review_usecase.dart';
import 'package:pbl6/features/shared/review/domain/usecases/delete_review_usecase.dart';
import 'package:pbl6/features/shared/review/domain/usecases/get_company_reviews_usecase.dart';
import 'package:pbl6/features/shared/review/domain/usecases/toggle_like_review_usecase.dart';
import 'package:pbl6/features/shared/review/domain/usecases/update_review_usecase.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/create_review_dialog.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/report_review_modal.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/review_list_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum cho bộ lọc Sort
enum ReviewSortType { newest, highest, lowest }

class JobReviewTab extends StatefulWidget {
  final String companyId;

  const JobReviewTab({super.key, required this.companyId});

  @override
  State<JobReviewTab> createState() => _JobReviewTabState();
}

class _JobReviewTabState extends State<JobReviewTab> {
  // UseCases
  late final GetCompanyReviewsUseCase _getCompanyReviewsUseCase;
  late final CreateReviewUseCase _createReviewUseCase;
  late final ToggleLikeReviewUseCase _toggleLikeReviewUseCase;
  late final UpdateReviewUseCase _updateReviewUseCase;
  late final DeleteReviewUseCase _deleteReviewUseCase;
  late final CreateReportUseCase _createReportUseCase;

  // State
  String _currentUserId = '';
  bool _isLoading = true;
  String? _errorMessage;
  ReviewPaginatedResponse _reviewData = ReviewPaginatedResponse.empty();
  final List<Review> _reviews = [];
  List<Review> _filteredReviews = [];

  // State Paging
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasNextPage = true;

  // State Filter/Search
  final TextEditingController _searchController = TextEditingController();
  ReviewSortType _sortType = ReviewSortType.newest;

  // State Rating Summary
  double _averageRating = 0.0;
  Map<int, double> _ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

  @override
  void initState() {
    super.initState();
    _getCompanyReviewsUseCase = GetIt.I<GetCompanyReviewsUseCase>();
    _createReviewUseCase = GetIt.I<CreateReviewUseCase>();
    _toggleLikeReviewUseCase = GetIt.I<ToggleLikeReviewUseCase>();
    _updateReviewUseCase = GetIt.I<UpdateReviewUseCase>();
    _deleteReviewUseCase = GetIt.I<DeleteReviewUseCase>();
    _searchController.addListener(_onSearchChanged);

    _loadCurrentUser().then((_) => _loadReviews());
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('user_id') ?? '';
    });
  }

  void _calculateRatingMetrics() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      _ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      return;
    }

    double totalRating = 0;
    Map<int, int> counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (final review in _reviews) {
      totalRating += review.rating;
      int star = review.rating.round();
      if (counts.containsKey(star)) {
        counts[star] = counts[star]! + 1;
      }
    }

    _averageRating = totalRating / _reviews.length;

    _ratingDistribution = {
      5: counts[5]! / _reviews.length,
      4: counts[4]! / _reviews.length,
      3: counts[3]! / _reviews.length,
      2: counts[2]! / _reviews.length,
      1: counts[1]! / _reviews.length,
    };
  }

  Future<void> _loadReviews({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _reviews.clear();
      _hasNextPage = true;
    }

    if (_isLoadingMore || !_hasNextPage) return;

    if (mounted) {
      setState(() {
        if (refresh) _isLoading = true;
        _isLoadingMore = true;
        _errorMessage = null;
      });
    }

    try {
      final data = await _getCompanyReviewsUseCase(
        GetCompanyReviewsParams(
          companyId: widget.companyId,
          page: _currentPage,
          size: 10,
        ),
      );

      // Chuẩn hóa reviewerInfo ngay khi load API
      final fixedReviews = data.content.map((review) {
        final info = review.reviewerInfo;
        final fixedInfo = info.reviewerName.isEmpty
            ? info.copyWith(reviewerName: 'N/A')
            : info;
        return review.copyWith(reviewerInfo: fixedInfo);
      }).toList();

      if (mounted) {
        setState(() {
          _reviews.addAll(fixedReviews);
          _reviewData = data;
          _currentPage++;
          _hasNextPage = !data.last;
          _calculateRatingMetrics();
          _onSearchChanged(); // Lọc theo search hiện tại
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi tải đánh giá: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredReviews = List.from(_reviews);
      } else {
        _filteredReviews = _reviews.where((review) {
          return review.title.toLowerCase().contains(query) ||
              review.comment.toLowerCase().contains(query);
        }).toList();
      }
      _sortReviews();
    });
  }

  Future<void> _showCreateReviewDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CreateReviewDialog(existingReview: null),
    );

    if (result == null || !mounted) return;

    try {
      final newReview = await _createReviewUseCase(
        CreateReviewParams(
          companyId: widget.companyId,
          title: result['title'],
          comment: result['comment'],
          rating: result['rating'],
          images: result['images'],
        ),
      );

      MotionToast.success(
        description: const Text("Đăng đánh giá thành công!"),
      ).show(context);
      if (mounted) {
        setState(() {
          _reviews.insert(0, newReview);
          _onSearchChanged();
          _calculateRatingMetrics();
        });
      }
    } catch (e) {
      MotionToast.error(description: Text("Lỗi: $e")).show(context);
    }
  }

  Future<void> _handleEditReview(Review review) async {
    // Gọi dialog có truyền review -> Chế độ edit
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CreateReviewDialog(existingReview: review),
    );

    if (result == null || !mounted) return;

    try {
      // Gọi UseCase Update
      final updatedReview = await _updateReviewUseCase(
        UpdateReviewParams(
          reviewId: review.reviewId,
          title: result['title'],
          comment: result['comment'],
          rating: result['rating'],
          newImages: result['images'], // List<File>
        ),
      );

      MotionToast.success(
        description: const Text("Cập nhật thành công!"),
      ).show(context);

      // Cập nhật UI
      if (mounted) {
        setState(() {
          final index = _reviews.indexWhere(
            (r) => r.reviewId == review.reviewId,
          );
          if (index != -1) {
            _reviews[index] = updatedReview;
            _onSearchChanged();
            _calculateRatingMetrics();
          }
        });
      }
    } catch (e) {
      MotionToast.error(description: Text("Lỗi cập nhật: $e")).show(context);
    }
  }

  Future<void> _handleDeleteReview(Review review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final response = await _deleteReviewUseCase(review.reviewId);

      if (response.code == 200) {
        // Giả sử 200 là thành công
        MotionToast.success(
          description: const Text("Đã xóa đánh giá"),
        ).show(context);
        if (mounted) {
          setState(() {
            _reviews.removeWhere((r) => r.reviewId == review.reviewId);
            _onSearchChanged();
            _calculateRatingMetrics();
          });
        }
      } else {
        MotionToast.error(
          description: Text("Lỗi: ${response.message}"),
        ).show(context);
      }
    } catch (e) {
      MotionToast.error(description: Text("Lỗi xóa: $e")).show(context);
    }
  }

  Future<void> _handleReportReview(
    String reviewId,
    String reason,
    String description,
  ) async {
    try {
      // Gọi API
      await _createReportUseCase(
        CreateReportParams(
          reviewId: reviewId,
          reason: reason,
          description: description,
        ),
      );

      if (!mounted) return;
      MotionToast.success(
        description: const Text("Báo cáo đánh giá thành công!"),
        toastAlignment: Alignment.topLeft,
        animationType: AnimationType.slideInFromLeft,
      ).show(context);

      // await _loadReviews(refresh: true);
    } on DioException catch (e) {
      if (!mounted) return;

      String displayError = "Có lỗi xảy ra";

      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;

        if (data is Map<String, dynamic>) {
          if (data['message'] != null) {
            displayError = data['message'].toString();
          } else if (data['error'] != null) {
            displayError = data['error'].toString();
          }
        } else {
          displayError = data.toString();
        }
      } else if (e.error != null) {
        displayError = e.error.toString();
      } else if (e.message != null) {
        displayError = e.message!;
      }

      MotionToast.warning(
        title: const Text("Thông báo"),
        description: Text(displayError),
        toastAlignment: Alignment.topLeft,
        animationType: AnimationType.slideInFromLeft,
      ).show(context);
    } catch (e) {
      if (!mounted) return;
      MotionToast.error(description: Text("Lỗi hệ thống: $e")).show(context);
    }
  }

  Future<void> _toggleLike(String reviewId) async {
    try {
      final updatedReview = await _toggleLikeReviewUseCase(reviewId);

      final index = _reviews.indexWhere((r) => r.reviewId == reviewId);
      if (index != -1 && mounted) {
        setState(() {
          _reviews[index] = updatedReview;
          _onSearchChanged(); // đảm bảo filteredReviews cũng update
        });
      }
    } catch (e) {
      MotionToast.error(description: Text('Lỗi: $e')).show(context);
    }
  }

  void _sortReviews() {
    switch (_sortType) {
      case ReviewSortType.newest:
        _filteredReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ReviewSortType.highest:
        _filteredReviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ReviewSortType.lowest:
        _filteredReviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => _loadReviews(refresh: true),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRatingSummary(),
                const SizedBox(height: 16),
                _buildCreateButton(),
                const SizedBox(height: 24),
                _buildSearchBox(),
                const SizedBox(height: 16),
                _buildSortDropdown(),
                const Divider(height: 32),
                _buildReviewList(),
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showCreateReviewDialog,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Viết bài đánh giá'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPallete.primaryColor,
          side: const BorderSide(color: AppPallete.borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return CustomTextField(
      label: "Tìm bài đánh giá...",
      icon: Icons.search,
      obscureText: false,
      controller: _searchController,
      onTap: () {},
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        Column(
          children: [
            Text(
              _averageRating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < _averageRating.round()
                      ? Icons.star
                      : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
            Text(
              '${_reviewData.totalElements} bài viết',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              _buildRatingBar('5', _ratingDistribution[5]!),
              _buildRatingBar('4', _ratingDistribution[4]!),
              _buildRatingBar('3', _ratingDistribution[3]!),
              _buildRatingBar('2', _ratingDistribution[2]!),
              _buildRatingBar('1', _ratingDistribution[1]!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(String label, double percent) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey.shade300,
            color: Colors.amber,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ReviewSortType>(
          value: _sortType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          items: const [
            DropdownMenuItem(
              value: ReviewSortType.newest,
              child: Text("Phù hợp nhất (Mới nhất)"),
            ),
            DropdownMenuItem(
              value: ReviewSortType.highest,
              child: Text("Xếp hạng cao nhất"),
            ),
            DropdownMenuItem(
              value: ReviewSortType.lowest,
              child: Text("Xếp hạng thấp nhất"),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _sortType = value);
              _onSearchChanged();
            }
          },
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_filteredReviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            "Chưa có đánh giá nào.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredReviews.length + 1,
      itemBuilder: (context, index) {
        if (index == _filteredReviews.length) {
          if (_hasNextPage) {
            _loadReviews();
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox.shrink();
        }

        final review = _filteredReviews[index];
        return ReviewListItem(
          review: review,
          onLikePressed: () => _toggleLike(review.reviewId),
          currentUserId: _currentUserId,
          onEditPressed: _handleEditReview,
          onDeletePressed: _handleDeleteReview,
          onReportPressed: (review) {
            showDialog(
              context: context,
              builder: (_) => ReportReviewModal(
                onSubmit: (reason, description) {
                  _handleReportReview(review.reviewId, reason, description);
                },
              ),
            );
          },
        );
      },
    );
  }
}
