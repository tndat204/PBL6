import React, { useState } from "react";
import { Star, Clock, ThumbsUp, MoreVertical } from "lucide-react";
import { formatDistanceToNow } from "date-fns";
import { vi } from "date-fns/locale";
import { reviewService } from "../services";

function ReviewCard({
  reviewId,
  reviewerInfo,
  rating,
  comment,
  createdAt,
  likeCount: initialLikeCount,
  liked: initialLiked,
  imageUrls
}) {
  const [liked, setLiked] = useState(initialLiked);
  const [likeCount, setLikeCount] = useState(initialLikeCount);

  const handleLike = async () => {
    try {
      if (liked) {
        setLikeCount(likeCount - 1);
      } else {
        setLikeCount(likeCount + 1);
      }
      setLiked(!liked);

      await reviewService.toggleLikeReview(reviewId);
    } catch (error) {
      console.error("Failed to toggle like:", error);
      // Revert state on error
      setLiked(liked);
      setLikeCount(likeCount);
    }
  };

  const formattedDate = createdAt
    ? formatDistanceToNow(new Date(createdAt), { addSuffix: true, locale: vi })
    : "";

  return (
    <div className="bg-white rounded-xl border border-gray-100 p-5 shadow-sm hover:shadow-md transition-shadow">
      <div className="flex justify-between items-start mb-3">
        <div className="flex items-center gap-3">
          {/* Avatar */}
          <div className="w-10 h-10 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
            {reviewerInfo?.reviewerAvatar ? (
              <img
                src={reviewerInfo.reviewerAvatar}
                alt={reviewerInfo.reviewerName}
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-blue-400 to-indigo-500 text-white font-bold text-lg">
                {reviewerInfo?.reviewerName?.charAt(0).toUpperCase() || "U"}
              </div>
            )}
          </div>

          <div>
            <h4 className="font-semibold text-gray-900 text-sm">
              {reviewerInfo?.reviewerName || "Người dùng ẩn danh"}
            </h4>
            <span className="text-xs text-gray-500">{formattedDate}</span>
          </div>
        </div>

        <button className="text-gray-400 hover:text-gray-600">
          <MoreVertical size={16} />
        </button>
      </div>

      <div className="flex items-center mb-3">
        {[...Array(5)].map((_, i) => (
          <Star
            key={i}
            size={16}
            className={`${i < rating ? "text-yellow-400 fill-yellow-400" : "text-gray-200"
              }`}
          />
        ))}
      </div>

      <p className="text-gray-700 text-sm leading-relaxed mb-4">
        {comment}
      </p>

      {imageUrls && imageUrls.length > 0 && (
        <div className="flex flex-wrap gap-2 mb-4">
          {imageUrls.map((url, index) => (
            <div key={index} className="relative w-24 h-24 rounded-lg overflow-hidden border border-gray-100 cursor-pointer hover:opacity-90 transition-opacity">
              <img
                src={url}
                alt={`Review image ${index + 1}`}
                className="w-full h-full object-cover"
                onClick={() => window.open(url, '_blank')}
              />
            </div>
          ))}
        </div>
      )}

      <div className="flex items-center gap-4 pt-3 border-t border-gray-50">
        <button
          onClick={handleLike}
          className={`flex items-center gap-1.5 text-sm font-medium transition-colors ${liked ? "text-blue-600" : "text-gray-500 hover:text-gray-700"
            }`}
        >
          <ThumbsUp size={16} className={liked ? "fill-current" : ""} />
          <span>{likeCount}</span>
        </button>
      </div>
    </div>
  );
}

export default ReviewCard;
