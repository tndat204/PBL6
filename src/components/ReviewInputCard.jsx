import React, { useState, useRef } from 'react';
import { Star, Image as ImageIcon, X, Loader2, Send } from 'lucide-react';

const ReviewInputCard = ({ onSubmit, onCancel, loading, userAvatar, userName }) => {
    const [rating, setRating] = useState(0);
    const [hoverRating, setHoverRating] = useState(0);
    const [title, setTitle] = useState('');
    const [comment, setComment] = useState('');
    const [images, setImages] = useState([]);
    const [previewUrls, setPreviewUrls] = useState([]);
    const fileInputRef = useRef(null);

    const handleImageChange = (e) => {
        const files = Array.from(e.target.files);
        if (files.length + images.length > 5) {
            alert('Bạn chỉ được tải lên tối đa 5 ảnh');
            return;
        }

        const newImages = [...images, ...files];
        setImages(newImages);

        const newPreviewUrls = files.map(file => URL.createObjectURL(file));
        setPreviewUrls([...previewUrls, ...newPreviewUrls]);
    };

    const removeImage = (index) => {
        const newImages = images.filter((_, i) => i !== index);
        setImages(newImages);

        const newPreviewUrls = previewUrls.filter((_, i) => i !== index);
        URL.revokeObjectURL(previewUrls[index]);
        setPreviewUrls(newPreviewUrls);
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (rating === 0) {
            alert('Vui lòng chọn số sao đánh giá');
            return;
        }
        onSubmit({ rating, title, comment, images });
    };

    return (
        <div className="bg-white rounded-xl border border-blue-100 p-5 shadow-sm mb-6 animate-fade-in ring-2 ring-blue-50">
            <form onSubmit={handleSubmit}>
                <div className="flex gap-4">
                    {/* Avatar */}
                    <div className="w-10 h-10 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
                        {userAvatar ? (
                            <img src={userAvatar} alt={userName} className="w-full h-full object-cover" />
                        ) : (
                            <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-blue-400 to-indigo-500 text-white font-bold text-lg">
                                {userName?.charAt(0).toUpperCase() || "B"}
                            </div>
                        )}
                    </div>

                    <div className="flex-1">
                        {/* Header: Name & Rating */}
                        <div className="flex flex-col sm:flex-row sm:items-center gap-2 sm:gap-4 mb-3">
                            <h4 className="font-semibold text-gray-900 text-sm">
                                {userName || "Bạn"}
                            </h4>

                            <div className="flex items-center gap-1">
                                {[1, 2, 3, 4, 5].map((star) => (
                                    <button
                                        key={star}
                                        type="button"
                                        onClick={() => setRating(star)}
                                        onMouseEnter={() => setHoverRating(star)}
                                        onMouseLeave={() => setHoverRating(0)}
                                        className="focus:outline-none transition-transform hover:scale-110"
                                    >
                                        <Star
                                            size={18}
                                            className={`${star <= (hoverRating || rating)
                                                    ? "fill-yellow-400 text-yellow-400"
                                                    : "text-gray-300"
                                                } transition-colors`}
                                        />
                                    </button>
                                ))}
                                <span className="text-xs font-medium text-yellow-600 ml-2">
                                    {hoverRating > 0 ? (
                                        ["Rất tệ", "Tệ", "Bình thường", "Tốt", "Tuyệt vời"][hoverRating - 1]
                                    ) : rating > 0 ? (
                                        ["Rất tệ", "Tệ", "Bình thường", "Tốt", "Tuyệt vời"][rating - 1]
                                    ) : "Chọn đánh giá"}
                                </span>
                            </div>
                        </div>

                        {/* Inputs */}
                        <div className="space-y-3">
                            <input
                                type="text"
                                value={title}
                                onChange={(e) => setTitle(e.target.value)}
                                placeholder="Tiêu đề (tùy chọn)"
                                className="w-full text-sm font-medium text-gray-900 placeholder-gray-400 border-none p-0 focus:ring-0 bg-transparent"
                            />

                            <textarea
                                value={comment}
                                onChange={(e) => setComment(e.target.value)}
                                placeholder="Chia sẻ trải nghiệm của bạn về công ty này..."
                                className="w-full text-sm text-gray-700 placeholder-gray-400 border-none p-0 focus:ring-0 bg-transparent resize-none min-h-[80px]"
                                required
                            />

                            {/* Image Previews */}
                            {previewUrls.length > 0 && (
                                <div className="flex flex-wrap gap-2 mt-2">
                                    {previewUrls.map((url, index) => (
                                        <div key={index} className="relative w-16 h-16 rounded-lg overflow-hidden border border-gray-200 group">
                                            <img src={url} alt="Preview" className="w-full h-full object-cover" />
                                            <button
                                                type="button"
                                                onClick={() => removeImage(index)}
                                                className="absolute top-0.5 right-0.5 bg-black/50 text-white rounded-full p-0.5 opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-500"
                                            >
                                                <X size={10} />
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Footer Actions */}
                        <div className="flex items-center justify-between pt-3 mt-2 border-t border-gray-100">
                            <div className="flex items-center gap-2">
                                <button
                                    type="button"
                                    onClick={() => fileInputRef.current?.click()}
                                    className="text-gray-400 hover:text-blue-500 transition-colors p-1.5 rounded-full hover:bg-blue-50"
                                    title="Thêm ảnh"
                                >
                                    <ImageIcon size={18} />
                                </button>
                                <input
                                    type="file"
                                    ref={fileInputRef}
                                    accept="image/*"
                                    multiple
                                    onChange={handleImageChange}
                                    className="hidden"
                                />
                            </div>

                            <div className="flex items-center gap-2">
                                <button
                                    type="button"
                                    onClick={onCancel}
                                    className="px-3 py-1.5 text-sm font-medium text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
                                >
                                    Hủy
                                </button>
                                <button
                                    type="submit"
                                    disabled={loading || rating === 0 || !comment.trim()}
                                    className="flex items-center gap-1.5 px-4 py-1.5 bg-blue-600 text-white text-sm font-medium rounded-lg hover:bg-blue-700 transition-colors shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    {loading ? <Loader2 size={16} className="animate-spin" /> : <Send size={16} />}
                                    Gửi
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    );
};

export default ReviewInputCard;
