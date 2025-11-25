import React, { useEffect } from 'react';
import { CheckCircle, XCircle, AlertCircle, Info, X } from 'lucide-react';

const Toast = ({ message, type = 'info', onClose, duration = 3000 }) => {
    useEffect(() => {
        if (duration) {
            const timer = setTimeout(() => {
                onClose();
            }, duration);
            return () => clearTimeout(timer);
        }
    }, [duration, onClose]);

    const icons = {
        success: <CheckCircle className="w-5 h-5 text-green-500" />,
        error: <XCircle className="w-5 h-5 text-red-500" />,
        warning: <AlertCircle className="w-5 h-5 text-yellow-500" />,
        info: <Info className="w-5 h-5 text-blue-500" />
    };

    const styles = {
        success: 'bg-green-50 border-green-200 text-green-800',
        error: 'bg-red-50 border-red-200 text-red-800',
        warning: 'bg-yellow-50 border-yellow-200 text-yellow-800',
        info: 'bg-blue-50 border-blue-200 text-blue-800'
    };

    return (
        <div className={`fixed top-4 right-4 z-[60] flex items-center gap-3 px-4 py-3 rounded-lg shadow-lg border animate-slide-in ${styles[type] || styles.info}`}>
            {icons[type] || icons.info}
            <p className="text-sm font-medium">{message}</p>
            <button
                onClick={onClose}
                className="p-1 hover:bg-black/5 rounded-full transition-colors"
            >
                <X size={16} />
            </button>
        </div>
    );
};

export default Toast;
