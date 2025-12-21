import React, { useState } from 'react';
import { Star, X, Upload, Image as ImageIcon, Loader2 } from 'lucide-react';

const CreateReviewModal = ({ isOpen, onClose, onSubmit, loading }) => {
    const [rating, setRating] = useState(0);
    const [hoverRating, setHoverRating] = useState(0);
    const [title, setTitle] = useState('');
    const [comment, setComment] = useState('');
    const [images, setImages] = useState([]);
    const [previewUrls, setPreviewUrls] = useState([]);

    if (!isOpen) return null;

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
        // Revoke old url to avoid memory leak
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
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-fade-in">
            <div className="bg-white rounded-2xl w-full max-w-lg shadow-2xl overflow-hidden animate-scale-in">
                {/* Header */}
                <div className="flex justify-between items-center p-6 border-b border-gray-100">
                    <h2 className="text-xl font-bold text-gray-900">Viết đánh giá</h2>
                    <button
                        onClick={onClose}
                        className="text-gray-400 hover:text-gray-600 transition-colors p-1 rounded-full hover:bg-gray-100"
                    >
                        <X size={24} />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-6 space-y-6">
                    {/* Rating */}
                    <div className="flex flex-col items-center gap-2">
                        <label className="text-sm font-medium text-gray-700">Bạn đánh giá công ty thế nào?</label>
                        <div className="flex gap-2">
                            {[1, 2, 3, 4, 5].map((star) => (
                                <button
                                    key={star}
                                    type="button"
                                    onClick={() => setRating(star)}
                                    onMouseEnter={() => setHoverRating(star)}
                                    onMouseLeave={() => setHoverRating(0)}
                                    className="transition-transform hover:scale-110 focus:outline-none"
                                >
                                    <Star
                                        size={32}
                                        className={`${star <= (hoverRating || rating)
                                                ? "fill-yellow-400 text-yellow-400"
                                                : "text-gray-300"
                                            } transition-colors`}
                                    />
                                </button>
                            ))}
                        </div>
                        <span className="text-sm font-medium text-yellow-500 h-5">
                            {hoverRating > 0 ? (
                                ["Rất tệ", "Tệ", "Bình thường", "Tốt", "Tuyệt vời"][hoverRating - 1]
                            ) : rating > 0 ? (
                                ["Rất tệ", "Tệ", "Bình thường", "Tốt", "Tuyệt vời"][rating - 1]
                            ) : ""}
                        </span>
                    </div>

                    {/* Title */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Tiêu đề</label>
                        <input
                            type="text"
                            value={title}
                            onChange={(e) => setTitle(e.target.value)}
                            placeholder="Tóm tắt trải nghiệm của bạn"
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all"
                            required
                        />
                    </div>

                    {/* Comment */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Nội dung chi tiết</label>
                        <textarea
                            value={comment}
                            onChange={(e) => setComment(e.target.value)}
                            placeholder="Chia sẻ chi tiết về trải nghiệm làm việc, văn hóa, chế độ đãi ngộ..."
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all min-h-[120px] resize-none"
                            required
                        />
                    </div>

                    {/* Image Upload */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Thêm ảnh (Tối đa 5)</label>
                        <div className="flex flex-wrap gap-3">
                            {previewUrls.map((url, index) => (
                                <div key={index} className="relative w-20 h-20 rounded-lg overflow-hidden border border-gray-200 group">
                                    <img src={url} alt="Preview" className="w-full h-full object-cover" />
                                    <button
                                        type="button"
                                        onClick={() => removeImage(index)}
                                        className="absolute top-1 right-1 bg-black/50 text-white rounded-full p-0.5 opacity-0 group-hover:opacity-100 transition-opacity hover:bg-red-500"
                                    >
                                        <X size={12} />
                                    </button>
                                </div>
                            ))}

                            {images.length < 5 && (
                                <label className="w-20 h-20 flex flex-col items-center justify-center border-2 border-dashed border-gray-300 rounded-lg cursor-pointer hover:border-blue-500 hover:bg-blue-50 transition-all text-gray-400 hover:text-blue-500">
                                    <ImageIcon size={24} />
                                    <span className="text-xs mt-1">Thêm ảnh</span>
                                    <input
                                        type="file"
                                        accept="image/*"
                                        multiple
                                        onChange={handleImageChange}
                                        className="hidden"
                                    />
                                </label>
                            )}
                        </div>
                    </div>

                    {/* Actions */}
                    <div className="flex gap-3 pt-2">
                        <button
                            type="button"
                            onClick={onClose}
                            className="flex-1 px-4 py-2.5 border border-gray-300 text-gray-700 font-medium rounded-xl hover:bg-gray-50 transition-colors"
                        >
                            Hủy
                        </button>
                        <button
                            type="submit"
                            disabled={loading}
                            className="flex-1 px-4 py-2.5 bg-blue-600 text-white font-medium rounded-xl hover:bg-blue-700 transition-colors shadow-lg shadow-blue-600/20 disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                        >
                            {loading ? (
                                <>
                                    <Loader2 size={20} className="animate-spin" />
                                    Đang gửi...
                                </>
                            ) : (
                                'Gửi đánh giá'
                            )}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default CreateReviewModal;
