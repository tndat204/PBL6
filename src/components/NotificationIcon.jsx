const NotificationIcon = () => {
  return (
    <div className="relative">
      <img src="/path/to/bell-icon.svg" alt="Notifications" />
      <span className="absolute top-0 right-0 bg-red-500 text-white text-xs rounded-full w-4 h-4 flex items-center justify-center">3</span>
    </div>
  );
};

export default NotificationIcon;
