const Input = ({ type, placeholder, className, value, onChange }) => {
  return (
    <input
      type={type}
      placeholder={placeholder}
      value={value}
      onChange={onChange}
      className={`border p-2 rounded-md ${className}`}
    />
  );
};

export default Input;
