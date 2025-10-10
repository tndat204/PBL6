class VerifyOTPRequest{
  final String email;
  final String otp;
  VerifyOTPRequest({required this.email, required this.otp});
  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
  };
}