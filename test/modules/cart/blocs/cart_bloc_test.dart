import 'package:e_commerce_mobile_app/core/models/product_item.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_bloc.dart';
import 'package:e_commerce_mobile_app/modules/cart/blocs/cart_event.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _drainEvents() async {
  await Future<void>.delayed(const Duration(milliseconds: 1));
}

void main() {
  const product = ProductModel(
    id: 'product-1',
    name: 'Test Product',
    price: 2.5,
    imageUrl: 'https://example.com/p.png',
  );

  test('keeps cart quantity isolated per branch', () async {
    final bloc = CartBloc();
    addTearDown(bloc.close);

    bloc.add(const ChangeCartBranch('branch-a'));
    bloc.add(const AddToCart(product));
    bloc.add(const AddToCart(product));
    await _drainEvents();

    expect(bloc.state.quantityFor(product.id), 2);
    expect(bloc.state.distinctItemCount, 1);

    bloc.add(const ChangeCartBranch('branch-b'));
    await _drainEvents();

    expect(bloc.state.quantityFor(product.id), 0);
    expect(bloc.state.distinctItemCount, 0);

    bloc.add(const AddToCart(product));
    await _drainEvents();

    expect(bloc.state.quantityFor(product.id), 1);
    expect(bloc.state.distinctItemCount, 1);

    bloc.add(const ChangeCartBranch('branch-a'));
    await _drainEvents();

    expect(bloc.state.quantityFor(product.id), 2);
    expect(bloc.state.distinctItemCount, 1);
  });

  test('clears only the active branch cart', () async {
    final bloc = CartBloc();
    addTearDown(bloc.close);

    bloc.add(const ChangeCartBranch('branch-a'));
    bloc.add(const AddToCart(product));
    await _drainEvents();

    bloc.add(const ChangeCartBranch('branch-b'));
    bloc.add(const AddToCart(product));
    await _drainEvents();

    expect(bloc.state.quantityFor(product.id), 1);

    bloc.add(const ClearCart());
    await _drainEvents();

    expect(bloc.state.quantityFor(product.id), 0);
    expect(bloc.state.distinctItemCount, 0);

    bloc.add(const ChangeCartBranch('branch-a'));
    await _drainEvents();

    expect(bloc.state.quantityFor(product.id), 1);
    expect(bloc.state.distinctItemCount, 1);
  });
}
