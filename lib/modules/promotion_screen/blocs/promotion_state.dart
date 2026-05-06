import 'package:equatable/equatable.dart';
import 'package:e_commerce_mobile_app/modules/home_screen/model/category_model.dart';

abstract class PromotionState extends Equatable {
  const PromotionState();

  @override
  List<Object?> get props => [];
}

class PromotionInitial extends PromotionState {}

class PromotionLoading extends PromotionState {}

class PromotionLoaded extends PromotionState {
  final List<CategoryModel> sections;
  const PromotionLoaded(this.sections);

  @override
  List<Object?> get props => [sections];
}

class PromotionError extends PromotionState {
  final String message;
  const PromotionError(this.message);

  @override
  List<Object?> get props => [message];
}
