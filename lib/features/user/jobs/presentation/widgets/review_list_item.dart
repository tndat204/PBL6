import 'package:flutter/material.dart';
import 'package:pbl6/features/shared/review/domain/entities/review.dart';

class ReviewListItem extends StatelessWidget {
  final Review review;
  final VoidCallback onLikePressed;

  const ReviewListItem({
    super.key,
    required this.review,
    required this.onLikePressed,
  });

  // Hàm tính thời gian tương đối
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Avatar, Tên, Thời gian)
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
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _timeAgo(review.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. Rating Stars
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 3. Title và Comment
          Text(
            review.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],

          // 4. Images (Nếu có)
          if (review.imageUrls.isNotEmpty) _buildImageGrid(review.imageUrls),

          // 5. Nút Like
          Row(
            children: [
              IconButton(
                icon: Icon(
                  review.liked
                      ? Icons.thumb_up_alt
                      : Icons.thumb_up_alt_outlined,
                  color: review.liked
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed: onLikePressed,
              ),
              if (review.likeCount > 0) Text(review.likeCount.toString()),
            ],
          ),
        ],
      ),
    );
  }

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
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrls[index],
                width: 100,
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
