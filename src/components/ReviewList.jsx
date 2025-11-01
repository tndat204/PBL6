import ReviewCard from "./ReviewCard";

function ReviewList({ items = reviews, columns = 1 }) {
  // Chọn class cột tương ứng
  const columnClass = {
    1: "grid-cols-1",
    2: "grid-cols-2",
    3: "grid-cols-3",
    4: "grid-cols-4",
  }[columns] || "grid-cols-1";

  return (
    <div className={`grid ${columnClass} gap-6`}>
      {items.map((review) => (
        <ReviewCard key={review.id} {...review} />
      ))}
    </div>
  );
}

export default ReviewList;