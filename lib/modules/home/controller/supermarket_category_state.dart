import 'package:e_commerce_mobile_app/modules/home/model/category_model.dart';

abstract class SupermarketCategoryState {
  const SupermarketCategoryState();
}

class CategoriesInitial extends SupermarketCategoryState {}

class CategoriesLoading extends SupermarketCategoryState {}

class CategoriesLoaded extends SupermarketCategoryState {
  final List<CategoryModel> categories;

  const CategoriesLoaded(this.categories);
}

class CategoriesError extends SupermarketCategoryState {
  final String message;
  const CategoriesError(this.message);
}
