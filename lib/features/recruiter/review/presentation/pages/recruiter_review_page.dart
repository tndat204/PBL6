import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:pbl6/core/theme/app_pallete.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';
import 'package:pbl6/features/shared/review/domain/entities/review_paginated_response.dart';
import 'package:pbl6/features/shared/review/domain/usecases/get_company_reviews_usecase.dart';
import 'package:pbl6/features/shared/review/domain/usecases/toggle_like_review_usecase.dart';
import 'package:pbl6/features/shared/widgets/custom_app_bar.dart';
import 'package:pbl6/features/user/jobs/presentation/widgets/review_list_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum cho Sort
enum ReviewSortType { newest, highest, lowest }

class RecruiterReviewPage extends StatefulWidget {
  const RecruiterReviewPage({super.key});

  @override
  State<RecruiterReviewPage> createState() => _RecruiterReviewPageState();
}

class _RecruiterReviewPageState extends State<RecruiterReviewPage> {
  late final GetCompanyReviewsUseCase _getCompanyReviewsUseCase;
  late final ToggleLikeReviewUseCase _toggleLikeReviewUseCase;

  String? _companyId;
  String _currentUserId = '';

  bool _isLoading = true;
  String? _errorMessage;
  ReviewPaginatedResponse _reviewData = ReviewPaginatedResponse.empty();
  final List<Review> _reviews = [];

  // Không dùng search nữa → luôn dùng reviews
  List<Review> get _filteredReviews => _reviews;

  int _currentPage = 0;

  ReviewSortType _sortType = ReviewSortType.newest;

  double _averageRating = 0.0;
  Map<int, double> _ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

  @override
  void initState() {
    super.initState();
    _getCompanyReviewsUseCase = GetIt.I<GetCompanyReviewsUseCase>();
    _toggleLikeReviewUseCase = GetIt.I<ToggleLikeReviewUseCase>();
    _loadCompanyIdAndData();
  }

  Future<void> _loadCompanyIdAndData() async {
    final prefs = await SharedPreferences.getInstance();
    final cId = prefs.getString('company_id');
    final uId = prefs.getString('user_id') ?? '';

    if (mounted) {
      setState(() {
        _companyId = cId;
        _currentUserId = uId;
      });
    }

    if (_companyId != null && _companyId!.isNotEmpty) {
      _loadReviews(refresh: true);
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Không tìm thấy thông tin công ty.";
        });
      }
    }
  }

  Future<void> _loadReviews({bool refresh = false}) async {
    if (_companyId == null) return;

    if (refresh) {
      _currentPage = 0;
      _reviews.clear();
    }

    if (mounted) {
      setState(() {
        if (refresh) _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final data = await _getCompanyReviewsUseCase(
        GetCompanyReviewsParams(
          companyId: _companyId!,
          page: _currentPage,
          size: 100,
        ),
      );

      final fixedReviews = data.content.map((review) {
        final info = review.reviewerInfo;
        final fixedInfo = info.reviewerName.isEmpty
            ? info.copyWith(reviewerName: 'Ẩn danh')
            : info;
        return review.copyWith(reviewerInfo: fixedInfo);
      }).toList();

      if (mounted) {
        setState(() {
          _reviews.addAll(fixedReviews);
          _reviewData = data;
          _calculateRatingMetrics();
          _sortReviews();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi tải đánh giá: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLike(String id) async {
    try {
      final updatedReview = await _toggleLikeReviewUseCase(id);
      final index = _reviews.indexWhere((r) => r.reviewId == id);
      if (index != -1 && mounted) {
        setState(() {
          _reviews[index] = updatedReview;
          _sortReviews();
        });
      }
    } catch (e) {
      MotionToast.error(description: Text('Lỗi Like: $e')).show(context);
    }
  }

  void _calculateRatingMetrics() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      _ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      return;
    }

    double total = 0;
    final count = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

    for (var r in _reviews) {
      total += r.rating;
      count[r.rating.round()] = count[r.rating.round()]! + 1;
    }

    _averageRating = total / _reviews.length;

    _ratingDistribution = {
      5: count[5]! / _reviews.length,
      4: count[4]! / _reviews.length,
      3: count[3]! / _reviews.length,
      2: count[2]! / _reviews.length,
      1: count[1]! / _reviews.length,
    };
  }

  void _sortReviews() {
    switch (_sortType) {
      case ReviewSortType.newest:
        _reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ReviewSortType.highest:
        _reviews.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ReviewSortType.lowest:
        _reviews.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppPallete.mainGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _loadReviews(refresh: true),
            color: AppPallete.primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: false,
                  floating: true,
                  backgroundColor: Colors.transparent,
                  toolbarHeight: 0,
                  expandedHeight: 180,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomAppBar(),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Đánh giá của ứng viên',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 40,
                                  color: AppPallete.textColor,
                                  height: 1.3,
                                  fontFamily: 'Italianno',
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // MAIN BODY
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        if (!_isLoading && _reviews.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _buildRatingSummary(),
                          ),

                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Danh sách đánh giá",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              _buildSortDropdown(),
                            ],
                          ),
                        ),

                        
                        const SizedBox(height: 16),

                        _buildReviewListBody(),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewListBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text(_errorMessage!)),
      );
    }
    if (_reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text("Chưa có đánh giá nào.", style: TextStyle(color: Colors.grey))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final review = _reviews[index];
        return Column(
          children: [
            ReviewListItem(
              review: review,
              currentUserId: _currentUserId,
              onLikePressed: () => _toggleLike(review.reviewId),
              onEditPressed: (r) {},
              onDeletePressed: (r) {},
            ),
          
          ],
        );
      },
    );
  }

 Widget _buildSortDropdown() {
  return PopupMenuButton<ReviewSortType>(
    onSelected: (value) {
      setState(() => _sortType = value);
      _sortReviews();
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    offset: const Offset(0, 10),
    elevation: 6,
    color: Colors.white,
    itemBuilder: (context) => [
      _buildPopupItem("Mới nhất", ReviewSortType.newest),
      _buildPopupItem("Cao nhất", ReviewSortType.highest),
      _buildPopupItem("Thấp nhất", ReviewSortType.lowest),
    ],
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            _sortType == ReviewSortType.newest
                ? "Mới nhất"
                : _sortType == ReviewSortType.highest
                    ? "Cao nhất"
                    : "Thấp nhất",
            style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        ],
      ),
    ),
  );
}
PopupMenuItem<ReviewSortType> _buildPopupItem(
    String text, ReviewSortType type) {
  return PopupMenuItem(
    value: type,
    child: Row(
      children: [
        Icon(
          _sortType == type ? Icons.check : null,
          color: AppPallete.primaryColor,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    ),
  );
}
  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppPallete.primaryColor),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(i < _averageRating.round() ? Icons.star : Icons.star_border,
                      color: Colors.amber, size: 16),
                ),
              ),
              Text('${_reviewData.totalElements} đánh giá',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _buildBar('5', _ratingDistribution[5]!),
                _buildBar('4', _ratingDistribution[4]!),
                _buildBar('3', _ratingDistribution[3]!),
                _buildBar('2', _ratingDistribution[2]!),
                _buildBar('1', _ratingDistribution[1]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double percent) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            color: Colors.amber,
            backgroundColor: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    );
  }
}
