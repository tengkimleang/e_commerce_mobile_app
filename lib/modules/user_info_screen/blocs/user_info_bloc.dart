import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/blocs/user_info_event.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/blocs/user_info_state.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/models/user_info_model.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/repositories/user_info_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  UserInfoBloc({UserInfoRepository? repository})
    : _repository = repository ?? UserInfoRepository(),
      _model = _createInitialModel(),
      super(UserInfoInitial(_createInitialModel())) {
    on<LoadUserInfo>(_onLoadUserInfo);
    on<UpdateUsername>(_onUpdateUsername);
    on<UpdateDateOfBirth>(_onUpdateDateOfBirth);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateProfileImage>(_onUpdateProfileImage);
    on<UpdateAddress>(_onUpdateAddress);
  }

  final UserInfoRepository _repository;
  UserInfoModel _model;

  static UserInfoModel _createInitialModel() {
    final fullName = UserSession.fullName.trim();
    final phone = UserSession.phoneNumber.trim();
    final username = fullName.isNotEmpty
        ? fullName
        : (phone.isNotEmpty ? phone : 'User');
    return UserInfoModel(username: username, phoneNumber: phone);
  }

  Future<void> _emitUpdated(Emitter<UserInfoState> emit) async {
    await _repository.cacheUserInfo(_model);
    emit(UserInfoUpdated(_model));
  }

  Future<void> _onLoadUserInfo(
    LoadUserInfo event,
    Emitter<UserInfoState> emit,
  ) async {
    _model = await _repository.loadUserInfo(
      fallbackLanguageCode: _model.languageCode,
    );
    emit(UserInfoUpdated(_model));
  }

  Future<void> _onUpdateUsername(
    UpdateUsername event,
    Emitter<UserInfoState> emit,
  ) async {
    _model = _model.copyWith(username: event.username.trim());
    await _emitUpdated(emit);
    _model = await _repository.updateProfile(
      current: _model,
      fullName: _model.username,
    );
    emit(UserInfoUpdated(_model));
  }

  Future<void> _onUpdateDateOfBirth(
    UpdateDateOfBirth event,
    Emitter<UserInfoState> emit,
  ) async {
    _model = _model.copyWith(dateOfBirth: event.dateOfBirth);
    await _emitUpdated(emit);
    _model = await _repository.updateProfile(
      current: _model,
      dateOfBirth: _model.dateOfBirth,
    );
    emit(UserInfoUpdated(_model));
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<UserInfoState> emit,
  ) async {
    _model = _model.copyWith(languageCode: event.languageCode);
    await _emitUpdated(emit);
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImage event,
    Emitter<UserInfoState> emit,
  ) async {
    final path = event.profileImagePath?.trim() ?? '';
    if (path.isEmpty) return;

    _model = _model.copyWith(profileImagePath: path);
    await _emitUpdated(emit);
    _model = await _repository.uploadProfileImage(
      current: _model,
      localPath: path,
    );
    emit(UserInfoUpdated(_model));
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<UserInfoState> emit,
  ) async {
    _model = _model.copyWith(address: event.address.trim());
    await _emitUpdated(emit);
    _model = await _repository.updateProfile(
      current: _model,
      address: _model.address,
    );
    emit(UserInfoUpdated(_model));
  }
}
