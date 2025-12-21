import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import MainLayout from "../layouts/MainLayout";
import JobList from "../components/JobList";
import ReviewList from "../components/ReviewList";
import ReviewInputCard from "../components/ReviewInputCard";
import { AiFillTwitterCircle, AiFillFacebook, AiFillInstagram } from "react-icons/ai";
import { companyService, reviewService, jobService } from "../services";
import { Star, PenSquare } from "lucide-react";

function CompanyProfile() {
  const { id } = useParams();
  const [company, setCompany] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Jobs state
  const [jobs, setJobs] = useState([]);
  const [showAllJobs, setShowAllJobs] = useState(false);

  // Review state
  const [reviews, setReviews] = useState([]);
  const [reviewStats, setReviewStats] = useState({
    averageRating: 0,
    totalReviews: 0,
    ratingCounts: { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 }
  });

  // Review Input State
  const [isWritingReview, setIsWritingReview] = useState(false);
  const [isSubmittingReview, setIsSubmittingReview] = useState(false);

  const fetchCompanyData = async () => {
    try {
      setLoading(true);
      // Fetch company info
      const companyData = await companyService.getCompanyById(id);
      setCompany(companyData);

      // Fetch jobs
      const jobsData = await jobService.getActiveJobsByCompany(id);
      if (jobsData && jobsData.content) {
        setJobs(jobsData.content);
      } else if (Array.isArray(jobsData)) {
        setJobs(jobsData);
      }

      // Fetch reviews
      const reviewsData = await reviewService.getCompanyReviews(id);
      if (reviewsData && reviewsData.content) {
        setReviews(reviewsData.content);

        // Calculate stats locally since API might not provide them directly yet
        // In a real scenario, API should provide summary stats
        const total = reviewsData.totalElements || reviewsData.content.length;
        if (total > 0) {
          const sum = reviewsData.content.reduce((acc, r) => acc + r.rating, 0);
          const avg = sum / total;

          const counts = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
          reviewsData.content.forEach(r => {
            const rRounded = Math.round(r.rating);
            if (counts[rRounded] !== undefined) counts[rRounded]++;
          });

          setReviewStats({
            averageRating: avg.toFixed(1),
            totalReviews: total,
            ratingCounts: counts
          });
        }
      }
    } catch (err) {
      console.error("Error fetching data:", err);
      setError("Không thể tải thông tin công ty.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (id) {
      fetchCompanyData();
    }
  }, [id]);

  const handleCreateReview = async (reviewData) => {
    try {
      setIsSubmittingReview(true);
      await reviewService.createReview({
        ...reviewData,
        companyId: id
      });

      // Refresh data after successful review
      await fetchCompanyData();
      setIsWritingReview(false);
      // TODO: Show success toast
    } catch (error) {
      console.error("Failed to create review:", error);
      // TODO: Show error toast
    } finally {
      setIsSubmittingReview(false);
    }
  };

  if (loading) {
    return (
      <MainLayout showBanner={true}>
        <div className="max-w-7xl mx-auto py-10 text-center text-gray-600">
          Đang tải thông tin công ty...
        </div>
      </MainLayout>
    );
  }

  if (error || !company) {
    return (
      <MainLayout showBanner={true}>
        <div className="max-w-7xl mx-auto py-10 text-center text-red-500">
          {error || "Không tìm thấy công ty."}
        </div>
      </MainLayout>
    );
  }



  return (
    <MainLayout showBanner={true}>
      {/* Header info */}
      <div className="flex items-center gap-4 mt-[-120px] relative z-30 bg-white p-5 rounded-xl shadow-md max-w-7xl mx-auto">
        <img
          src={company.logoUrl || "/images/cmc.png"}
          alt="Company logo"
          className="w-20 h-20 rounded-md border border-gray-300 bg-white p-2 object-contain"
        />
        <div>
          <h2 className="text-2xl font-semibold text-gray-800">{company.name}</h2>
          <p className="text-gray-500">{company.address || "Chưa cập nhật địa chỉ"}</p>
        </div>
      </div>
      <div className="flex flex-col lg:flex-row gap-8 z-20 mt-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Left main content */}

        <div className="flex-1">
          {/* Company Story / Description */}
          <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-8">
            <h3 className="text-xl font-bold text-gray-900 mb-4">Giới thiệu công ty</h3>
            <p className="text-gray-600 leading-relaxed whitespace-pre-line">
              {company.description || "Chưa có mô tả về công ty này."}
            </p>
          </div>

          {/* Job posts */}
          <div className="mb-8">
            <h3 className="text-xl font-bold text-gray-900 mb-4">Việc làm đang tuyển</h3>
            {jobs.length > 0 ? (
              <div className="grid gap-6">
                <JobList jobs={showAllJobs ? jobs : jobs.slice(0, 3)} columns={1} />

                {jobs.length > 3 && (
                  <div className="text-center mt-2">
                    <button
                      onClick={() => setShowAllJobs(!showAllJobs)}
                      className="text-blue-600 font-medium hover:text-blue-700 hover:underline transition-all"
                    >
                      {showAllJobs ? "Thu gọn" : `Xem thêm ${jobs.length - 3} việc làm khác`}
                    </button>
                  </div>
                )}
              </div>
            ) : (
              <div className="bg-white rounded-xl p-8 text-center border border-gray-100">
                <p className="text-gray-500">Hiện chưa có tin tuyển dụng nào.</p>
              </div>
            )}
          </div>

          {/* Comments section */}
          <div>
            <div className="flex justify-between items-center mb-6">
              <h3 className="text-xl font-bold text-gray-900">Đánh giá từ nhân viên</h3>
              {!isWritingReview && (
                <button
                  onClick={() => setIsWritingReview(true)}
                  className="flex items-center gap-1.5 px-3 py-1.5 bg-white text-gray-700 border border-gray-200 rounded-lg text-sm font-medium hover:bg-gray-50 hover:text-gray-900 hover:border-gray-300 transition-all shadow-sm"
                >
                  <PenSquare size={16} />
                  Viết đánh giá
                </button>
              )}
            </div>

            {/* Review Input Card */}
            {isWritingReview && (
              <ReviewInputCard
                onSubmit={handleCreateReview}
                onCancel={() => setIsWritingReview(false)}
                loading={isSubmittingReview}
                // TODO: Pass actual user info
                userName="Bạn"
              />
            )}

            {/* Rating Summary Card */}
            <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-8">
              <div className="flex flex-col md:flex-row items-center gap-8">
                {/* Average Score */}
                <div className="text-center md:text-left">
                  <div className="text-5xl font-bold text-gray-900 mb-2">{reviewStats.averageRating}</div>
                  <div className="flex items-center justify-center md:justify-start gap-1 mb-2">
                    {[...Array(5)].map((_, i) => (
                      <Star
                        key={i}
                        size={20}
                        className={i < Math.round(reviewStats.averageRating) ? "text-yellow-400 fill-yellow-400" : "text-gray-200"}
                      />
                    ))}
                  </div>
                  <p className="text-gray-500 text-sm">{reviewStats.totalReviews} đánh giá</p>
                </div>

                {/* Progress Bars */}
                <div className="flex-1 w-full">
                  {[5, 4, 3, 2, 1].map((star) => (
                    <div key={star} className="flex items-center gap-3 mb-2">
                      <span className="text-sm font-medium text-gray-600 w-3">{star}</span>
                      <div className="flex-1 h-2 bg-gray-100 rounded-full overflow-hidden">
                        <div
                          className="h-full bg-yellow-400 rounded-full"
                          style={{
                            width: `${reviewStats.totalReviews ? (reviewStats.ratingCounts[star] / reviewStats.totalReviews) * 100 : 0}%`
                          }}
                        ></div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>

            {/* Review List */}
            <div className="flex justify-between items-center mb-4">
              <h4 className="font-semibold text-gray-800">Danh sách đánh giá</h4>
              <select className="bg-white border border-gray-200 text-gray-700 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2">
                <option>Mới nhất</option>
                <option>Cũ nhất</option>
                <option>Điểm cao nhất</option>
              </select>
            </div>

            {reviews.length > 0 ? (
              <ReviewList items={reviews} columns={1} />
            ) : (
              <div className="text-center py-10 bg-gray-50 rounded-xl border border-dashed border-gray-200">
                <p className="text-gray-500">Chưa có đánh giá nào cho công ty này.</p>
              </div>
            )}
          </div>
        </div>

        {/* Right Sidebar */}
        <div className="w-full lg:w-1/3 bg-white p-6 rounded-xl shadow-sm border border-gray-100 lg:sticky lg:top-24 h-fit self-start">
          <h3 className="text-lg font-bold text-gray-900 mb-6">Thông tin liên hệ</h3>
          <ul className="text-sm text-gray-600 space-y-4">
            <li className="flex justify-between border-b border-gray-100 pb-3">
              <span className="text-gray-500">Mã số thuế</span>
              <span className="font-medium text-gray-900">{company.taxCode || "N/A"}</span>
            </li>
            <li className="flex justify-between border-b border-gray-100 pb-3">
              <span className="text-gray-500">Email</span>
              <span className="font-medium text-gray-900">{company.email || "N/A"}</span>
            </li>
            <li className="flex justify-between border-b border-gray-100 pb-3">
              <span className="text-gray-500">Điện thoại</span>
              <span className="font-medium text-gray-900">{company.phone || "N/A"}</span>
            </li>
            {company.website && (
              <li className="flex justify-between border-b border-gray-100 pb-3">
                <span className="text-gray-500">Website</span>
                <a
                  href={company.website.startsWith('http') ? company.website : `https://${company.website}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="font-medium text-blue-600 hover:underline truncate max-w-[180px]"
                >
                  {company.website}
                </a>
              </li>
            )}
          </ul>

          {/* Social links */}
          <div className="mt-8">
            <h4 className="text-gray-900 font-semibold text-sm mb-4">Mạng xã hội</h4>
            <div className="flex gap-4">
              <a href="#" className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-gray-400 hover:bg-blue-50 hover:text-blue-500 transition-all">
                <AiFillFacebook size={20} />
              </a>
              <a href="#" className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-gray-400 hover:bg-blue-50 hover:text-blue-400 transition-all">
                <AiFillTwitterCircle size={20} />
              </a>
              <a href="#" className="w-10 h-10 rounded-full bg-gray-50 flex items-center justify-center text-gray-400 hover:bg-pink-50 hover:text-pink-500 transition-all">
                <AiFillInstagram size={20} />
              </a>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
}

export default CompanyProfile;
