export default function Button({
  children,
  type = "button",
  onClick,
  className = "",
}) {
  return (
    <button
      type={type}
      onClick={onClick}
      className={`w-full bg-gradient-to-r from-emerald-400 to-teal-500 text-white font-semibold py-2 rounded-lg hover:opacity-90 transition hover:bg-gray-100 cursor-pointer ${className}`}
    >
      {children}
    </button>
  );
}
