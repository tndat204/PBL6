class SendOTPRequest {
final String email;
SendOTPRequest({required this.email});
Map<String, dynamic> toJson() => {
'email': email,
};
}