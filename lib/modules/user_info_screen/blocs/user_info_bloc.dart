import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/core/services/user_session.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/blocs/user_info_event.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/blocs/user_info_state.dart';
import 'package:e_commerce_mobile_app/modules/user_info_screen/models/user_info_model.dart';

class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  UserInfoBloc()
    : _model = _createInitialModel(),
      super(UserInfoInitial(_createInitialModel())) {
    on<UpdateUsername>(_onUpdateUsername);
    on<UpdateDateOfBirth>(_onUpdateDateOfBirth);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateProfileImage>(_onUpdateProfileImage);
  }

  static UserInfoModel _createInitialModel() {
    final fullName = UserSession.fullName.trim();
    final fallback = UserSession.phoneNumber.trim();
    final username = fullName.isNotEmpty
        ? fullName
        : (fallback.isNotEmpty ? fallback : 'User');
    return UserInfoModel(username: username);
  }

  UserInfoModel _model;

  Future<void> _emitUpdated(Emitter<UserInfoState> emit) async {
    _model = _model.copyWith();
    emit(UserInfoUpdated(_model));
  }

  Future<void> _onUpdateUsername(
    UpdateUsername event,
    Emitter<UserInfoState> emit,
  ) async {
    _model = _model.copyWith(username: event.username);
    await _emitUpdated(emit);
  }

  Future<void> _onUpdateDateOfBirth(
    UpdateDateOfBirth event,
    Emitter<UserInfoState> emit,
  ) async {
    _model = _model.copyWith(dateOfBirth: event.dateOfBirth);
    await _emitUpdated(emit);
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
    _model = _model.copyWith(profileImagePath: event.profileImagePath);
    await _emitUpdated(emit);
  }
}
