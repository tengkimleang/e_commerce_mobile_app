import 'package:equatable/equatable.dart';
import 'package:e_commerce_mobile_app/modules/home/chipmong_supermarket/model/category_model.dart';

abstract class SupermarketCategoryState extends Equatable {
  const SupermarketCategoryState();

  @override
  List<Object?> get props => [];
}

class CategoriesInitial extends SupermarketCategoryState {}

class CategoriesLoading extends SupermarketCategoryState {}

class CategoriesLoaded extends SupermarketCategoryState {
  final List<CategoryModel> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class CategoriesError extends SupermarketCategoryState {
  final String message;
  const CategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
