class ResetPasswordRequest{
  final String newPassword;
  ResetPasswordRequest({required this.newPassword});
  Map<String, dynamic> toJson() => {
    'newPassword': newPassword,
  };  
}