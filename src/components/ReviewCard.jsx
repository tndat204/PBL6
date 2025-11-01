import React, { useState } from "react";
import { Star, Clock, Reply } from "lucide-react";

function ReviewCard({ name, rating, content, dateTime }) {
  const [isReplying, setIsReplying] = useState(false);
  const [replyText, setReplyText] = useState("");
  const [replies, setReplies] = useState([]);

  const handleReplySubmit = () => {
    if (replyText.trim() === "") return;
    const newReply = {
      id: replies.length + 1,
      text: replyText,
      dateTime: new Date().toLocaleString(),
    };
    setReplies([...replies, newReply]);
    setReplyText("");
    setIsReplying(false);
  };

  return (
    <div className="bg-white rounded-lg shadow-md p-4 flex flex-col justify-between h-full relative">
      {/* Header */}
      <div className="flex items-start gap-3">
        {/* Avatar */}
        <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center">
          <span className="text-gray-500 text-sm font-semibold">
            {name.charAt(0).toUpperCase()}
          </span>
        </div>

        <div className="flex flex-col flex-1">
          {/* Tên và sao */}
          <div className="flex items-center gap-2">
            <h3 className="font-semibold text-gray-800">{name}</h3>
            <div className="flex items-center text-yellow-400">
              {[...Array(5)].map((_, i) => (
                <Star
                  key={i}
                  size={14}
                  fill={i < rating ? "currentColor" : "none"}
                  stroke="currentColor"
                />
              ))}
            </div>
          </div>

          {/* Nội dung */}
          <p className="text-gray-700 mt-2 text-sm leading-relaxed">
            {content}
          </p>

          {/* Footer */}
          <div className="flex justify-between items-center mt-3 text-xs text-gray-500">
            <div className="flex items-center gap-1">
              <Clock size={12} />
              <span>{dateTime}</span>
            </div>
            <button
              onClick={() => setIsReplying(!isReplying)}
              className="flex items-center gap-1 text-gray-600 hover:text-blue-500 transition text-sm font-medium"
            >
              <Reply size={14} />
              <span>Phản hồi</span>
            </button>
          </div>

          {/* Form phản hồi */}
          {isReplying && (
            <div className="mt-3 border-t border-gray-200 pt-3">
              <textarea
                value={replyText}
                onChange={(e) => setReplyText(e.target.value)}
                placeholder="Viết phản hồi của bạn..."
                className="w-full p-2 border border-gray-300 rounded-lg text-sm resize-none focus:outline-none focus:ring-1 focus:ring-sea-100"
                rows="2"
              />
              <div className="flex justify-end gap-2 mt-2">
                <button
                  onClick={() => setIsReplying(false)}
                  className="text-gray-500 text-sm hover:underline"
                >
                  Hủy
                </button>
                <button
                  onClick={handleReplySubmit}
                  className="bg-sea-400 text-white px-3 py-1 rounded-sm text-sm hover:bg-sea-300"
                >
                  Gửi
                </button>
              </div>
            </div>
          )}

          {/* Danh sách phản hồi */}
          {replies.length > 0 && (
            <div className="mt-4 space-y-2">
              {replies.map((r) => (
                <div
                  key={r.id}
                  className="ml-8 bg-gray-50 border border-gray-200 rounded-lg p-2 text-sm"
                >
                  <p className="text-gray-700">{r.text}</p>
                  <span className="text-xs text-gray-400">{r.dateTime}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default ReviewCard;
