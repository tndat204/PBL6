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
      className={`w-full bg-gradient-to-r bg-sea-400 text-white font-semibold py-2 rounded-lg hover:opacity-90 transition hover: cursor-pointer ${className}`}
    >
      {children}
    </button>
  );
}
