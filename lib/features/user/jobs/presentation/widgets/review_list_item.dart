import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';

class ReviewListItem extends StatelessWidget {
  final Review review;
  final String currentUserId;
  final VoidCallback onLikePressed;
  final Function(Review) onEditPressed;
  final Function(Review) onDeletePressed;

  const ReviewListItem({
    super.key,
    required this.review,
    required this.currentUserId,
    required this.onLikePressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  String _timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = review.reviewerInfo;
    final bool isOwner =
        (currentUserId.isNotEmpty && info.reviewerId == currentUserId);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 12),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHover = false;

          return MouseRegion(
            onEnter: (_) => setState(() => isHover = true),
            onExit: (_) => setState(() => isHover = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isHover ? 0.12 : 0.05),
                    blurRadius: isHover ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.grey.withOpacity(0.12),
                highlightColor: Colors.transparent,
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================== HEADER ===================
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: info.reviewerAvatar.isNotEmpty
                              ? NetworkImage(info.reviewerAvatar)
                              : null,
                          child: info.reviewerAvatar.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info.reviewerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _timeAgo(review.createdAt),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'edit') onEditPressed(review);
                            if (value == 'delete') onDeletePressed(review);
                          },
                          itemBuilder: (BuildContext context) {
                            if (isOwner) {
                              return [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Chỉnh sửa'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Xóa',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ];
                            } else {
                              return [
                                const PopupMenuItem(
                                  value: 'report',
                                  child: Text("Báo cáo"),
                                ),
                              ];
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // =================== RATING ===================
                    RatingBarIndicator(
                      rating: review.rating,
                      itemBuilder: (context, index) =>
                          const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 20,
                    ),

                    const SizedBox(height: 10),

                    // =================== TITLE ===================
                    Text(
                      review.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    // =================== COMMENT ===================
                    if (review.comment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        review.comment,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],

                    // =================== IMAGES ===================
                    if (review.imageUrls.isNotEmpty)
                      _buildImageGrid(review.imageUrls),

                    // =================== LIKE BUTTON ===================
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              review.liked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: review.liked
                                  ? const Color.fromARGB(200, 244, 67, 54)
                                  : Colors.grey,
                              size: 22,
                            ),
                            onPressed: onLikePressed,
                          ),
                          if (review.likeCount > 0)
                            Text(
                              review.likeCount.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =================== IMAGE GRID ===================
  Widget _buildImageGrid(List<String> imageUrls) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrls[index],
                width: 110,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
