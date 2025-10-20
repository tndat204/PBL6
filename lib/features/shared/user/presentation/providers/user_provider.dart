import 'package:flutter/material.dart';

import '../../../../user/jobs/domain/entities/user.dart';


class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void updateAvatar(String avatarUrl) {
    if (_user != null) {
      _user = _user!.copyWith(avatarUrl: avatarUrl);
      notifyListeners();
    }
  }

  void updateInfo(Map<String, dynamic> newData) {
    if (_user != null) {
      _user = _user!.copyWith(
        fullName: newData['fullName'] ?? _user!.fullName,
        phone: newData['phone'] ?? _user!.phone,
        address: newData['address'] ?? _user!.address,
      );
      notifyListeners();
    }
  }
}
