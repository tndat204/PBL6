import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { EnvelopeIcon, LockClosedIcon, EyeIcon, EyeSlashIcon, ArrowLeftIcon } from '@heroicons/react/24/outline';
import OTPInput from '../components/OTPInput';
import Button from '../components/Button';
import { authService } from '../services';

export default function ForgotPassword() {
  const navigate = useNavigate();
  const [step, setStep] = useState(1); // 1: Email, 2: OTP, 3: Password
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [timer, setTimer] = useState(0);
  const [resetToken, setResetToken] = useState(''); // Token from OTP verification

  // Timer countdown
  useEffect(() => {
    if (step === 2 && timer > 0) {
      const interval = setInterval(() => {
        setTimer((prev) => prev - 1);
      }, 1000);
      return () => clearInterval(interval);
    }
  }, [step, timer]);

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const validateEmail = (email) => {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  };

  const handleSendOTP = async () => {
    if (!validateEmail(email)) {
      setError('Email không hợp lệ');
      return;
    }

    setLoading(true);
    setError('');

    try {
      await authService.sendPasswordResetOTP(email);
      setStep(2);
      setTimer(60); // 1 minute
      setOtp('');
    } catch (error) {
      setError(error.message || 'Không thể gửi OTP. Vui lòng thử lại');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOTP = async () => {
    if (otp.length !== 6) {
      setError('Vui lòng nhập đủ 6 số');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const response = await authService.verifyOTP(email, otp);
      // Save token from response
      if (response.result) {
        setResetToken(response.result);
      }
      setStep(3);
    } catch (error) {
      setError(error.message ||'Mã OTP không đúng hoặc đã hết hạn');
    } finally {
      setLoading(false);
    }
  };

  const handleResetPassword = async () => {
    if (newPassword.length < 6) {
      setError('Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    if (newPassword !== confirmPassword) {
      setError('Mật khẩu xác nhận không khớp');
      return;
    }

    setLoading(true);
    setError('');

    try {
      await authService.resetPassword(newPassword, resetToken);
      setResetToken(''); // Clear token for security
      alert('Đặt lại mật khẩu thành công!');
      navigate('/login');
    } catch (error) {
      setError(error.message || 'Không thể đặt lại mật khẩu. Vui lòng thử lại');
    } finally {
      setLoading(false);
    }
  };

  const handleResendOTP = () => {
    setOtp('');
    setError('');
    handleSendOTP();
  };

  const handleBack = () => {
    if (step === 2) {
      setStep(1);
      setOtp('');
      setTimer(0);
    } else if (step === 3) {
      setStep(2);
      setNewPassword('');
      setConfirmPassword('');
    }
    setError('');
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-green-50 to-cyan-50">
      <div className="bg-white shadow-lg rounded-2xl w-full max-w-md p-8">
        {/* Header */}
        <div className="text-center mb-6">
          <h2 className="text-2xl font-bold text-gray-800 mb-2">
            {step === 1 && 'Quên mật khẩu'}
            {step === 2 && 'Xác thực OTP'}
            {step === 3 && 'Đặt lại mật khẩu'}
          </h2>
          <p className="text-gray-500 text-sm">
            {step === 1 && 'Nhập email để nhận mã OTP'}
            {step === 2 && `Mã OTP đã được gửi đến ${email}`}
            {step === 3 && 'Nhập mật khẩu mới của bạn'}
          </p>
        </div>

        {/* Step Indicator */}
        <div className="flex justify-center mb-6">
          <div className="flex items-center gap-2">
            {[1, 2, 3].map((s) => (
              <div key={s} className="flex items-center">
                <div
                  className={`w-8 h-8 rounded-full flex items-center justify-center text-sm font-semibold ${
                    step >= s
                      ? 'bg-sea-400 text-white'
                      : 'bg-gray-200 text-gray-400'
                  }`}
                >
                  {s}
                </div>
                {s < 3 && (
                  <div
                    className={`w-12 h-1 ${
                      step > s ? 'bg-sea-400' : 'bg-gray-200'
                    }`}
                  />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Error Message */}
        {error && (
          <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-600 text-sm">
            {error}
          </div>
        )}

        {/* STEP 1: Email Input */}
        {step === 1 && (
          <div className="space-y-4">
            <div className="relative">
              <EnvelopeIcon className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
              <input
                type="email"
                placeholder="Nhập email của bạn"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-sea-400 focus:outline-none"
                onKeyPress={(e) => e.key === 'Enter' && handleSendOTP()}
              />
            </div>

            <Button
              onClick={handleSendOTP}
              disabled={loading}
              className="from-sea-400 to-sea-300 bg-gradient-to-l"
            >
              {loading ? 'Đang gửi...' : 'Gửi mã OTP'}
            </Button>

            <button
              onClick={() => navigate('/login')}
              className="w-full flex items-center justify-center gap-2 text-gray-600 hover:text-gray-800 transition"
            >
              <ArrowLeftIcon className="w-4 h-4" />
              Quay lại đăng nhập
            </button>
          </div>
        )}

        {/* STEP 2: OTP Verification */}
        {step === 2 && (
          <div className="space-y-4">
            <OTPInput
              length={6}
              value={otp}
              onChange={setOtp}
              disabled={loading}
            />

            <div className="text-center">
              <p className="text-sm text-gray-600">
                Thời gian còn lại:{' '}
                <span className="font-semibold text-sea-400">
                  {formatTime(timer)}
                </span>
              </p>
            </div>

            <Button
              onClick={handleVerifyOTP}
              disabled={loading || otp.length !== 6}
              className="from-sea-400 to-sea-300 bg-gradient-to-l"
            >
              {loading ? 'Đang xác thực...' : 'Xác nhận'}
            </Button>

            <div className="flex gap-2">
              <button
                onClick={handleBack}
                className="flex-1 py-2 border border-gray-300 rounded-lg text-gray-600 hover:bg-gray-50 transition"
              >
                ← Thay đổi email
              </button>
              <button
                onClick={handleResendOTP}
                disabled={timer > 0 || loading}
                className="flex-1 py-2 border border-sea-400 text-sea-400 rounded-lg hover:bg-sea-50 transition disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Gửi lại mã
              </button>
            </div>
          </div>
        )}

        {/* STEP 3: New Password */}
        {step === 3 && (
          <div className="space-y-4">
            <div className="relative">
              <LockClosedIcon className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
              <input
                type={showPassword ? 'text' : 'password'}
                placeholder="Mật khẩu mới"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                className="w-full pl-10 pr-10 py-2 border rounded-lg focus:ring-2 focus:ring-sea-400 focus:outline-none"
              />
              <button
                type="button"
                className="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? (
                  <EyeSlashIcon className="w-5 h-5" />
                ) : (
                  <EyeIcon className="w-5 h-5" />
                )}
              </button>
            </div>

            <div className="relative">
              <LockClosedIcon className="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
              <input
                type="password"
                placeholder="Xác nhận mật khẩu"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-sea-400 focus:outline-none"
                onKeyPress={(e) => e.key === 'Enter' && handleResetPassword()}
              />
            </div>

            <Button
              onClick={handleResetPassword}
              disabled={loading}
              className="from-sea-400 to-sea-300 bg-gradient-to-l"
            >
              {loading ? 'Đang xử lý...' : 'Đặt lại mật khẩu'}
            </Button>

            <button
              onClick={handleBack}
              className="w-full py-2 border border-gray-300 rounded-lg text-gray-600 hover:bg-gray-50 transition"
            >
              ← Quay lại
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
