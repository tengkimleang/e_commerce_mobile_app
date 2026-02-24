import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce_mobile_app/modules/home/controller/supermarket_category_event.dart';
import 'package:e_commerce_mobile_app/modules/home/controller/supermarket_category_state.dart';
import 'package:e_commerce_mobile_app/modules/home/model/category_model.dart';

class SupermarketCategoryBloc extends Bloc<SupermarketCategoryEvent, SupermarketCategoryState> {
  SupermarketCategoryBloc() : super(CategoriesInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<SupermarketCategoryState> emit) async {
    emit(CategoriesLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final categories = <CategoryModel>[
        const CategoryModel(
          id: 'loyalty',
          // title: 'Loyalty',
          // subtitle: 'Member rewards & benefits',
          imageUrl: 'https://wp.sfdcdigital.com/en-us/wp-content/uploads/sites/4/2025/06/customer-loyalty-1680x1120-1.jpg?resize=1024,683',
        ),
        const CategoryModel(
          id: 'partner',
          // title: 'Become Partner',
          
          // subtitle: 'Join our partner program',
          imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZ5i8QBjeV3H4nA5m5T3ILCaeeQYcWN0pg9Q&s',
        ),
      ];
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}
