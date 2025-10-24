// file: features/shared/profile/presentation/providers/profile_provider.dart

import 'package:flutter/material.dart';
import 'package:pbl6/core/usecase/usecase.dart';
import 'package:pbl6/features/user/profile/domain/entities/profile_entity.dart';
import 'package:pbl6/features/user/profile/domain/usecases/get_my_profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetMyProfileUseCase getMyProfileUseCase;
  // Giả định các UseCase khác được inject qua GetIt
  // final UpdateProfileUseCase updateProfileUseCase;
  // final UploadCVUseCase uploadCVUseCase;

  ProfileProvider({required this.getMyProfileUseCase});

  ProfileEntity? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileEntity? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getMyProfileUseCase(NoParams());

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (profileEntity) {
        _profile = profileEntity;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // Phương thức update trạng thái cục bộ sau khi gọi API update thành công
  void updateProfileLocally(ProfileEntity newProfile) {
    _profile = newProfile;
    notifyListeners();
  }
}