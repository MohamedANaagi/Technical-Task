import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:technica_task/features/cart/domain/usecases/cart_usecases.dart';
import 'package:technica_task/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:technica_task/features/cart/presentation/cubit/cart_state.dart';

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}

class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}

class MockUpdateCartQuantityUseCase extends Mock
    implements UpdateCartQuantityUseCase {}

void main() {
  late MockGetCartUseCase mockGetCart;
  late MockAddToCartUseCase mockAddToCart;
  late MockRemoveFromCartUseCase mockRemoveFromCart;
  late MockUpdateCartQuantityUseCase mockUpdateQuantity;

  setUp(() {
    mockGetCart = MockGetCartUseCase();
    mockAddToCart = MockAddToCartUseCase();
    mockRemoveFromCart = MockRemoveFromCartUseCase();
    mockUpdateQuantity = MockUpdateCartQuantityUseCase();
  });

  group('CartCubit', () {
    test('initial state is CartStateInitial', () {
      final cubit = CartCubit(
        mockGetCart,
        mockAddToCart,
        mockRemoveFromCart,
        mockUpdateQuantity,
      );
      expect(cubit.state, const CartStateInitial());
      cubit.close();
    });

    blocTest(
      'loadCart emits Loaded with items',
      build: () {
        when(() => mockGetCart()).thenAnswer((_) async => {1: 2, 3: 1});
        return CartCubit(
          mockGetCart,
          mockAddToCart,
          mockRemoveFromCart,
          mockUpdateQuantity,
        );
      },
      act: (cubit) => cubit.loadCart(),
      expect: () => [
        CartStateLoaded({1: 2, 3: 1}),
      ],
    );

    blocTest(
      'addToCart emits Loaded with updated items',
      build: () {
        when(() => mockAddToCart(5, quantity: 1)).thenAnswer((_) async => {});
        when(() => mockGetCart()).thenAnswer((_) async => {5: 1});
        return CartCubit(
          mockGetCart,
          mockAddToCart,
          mockRemoveFromCart,
          mockUpdateQuantity,
        );
      },
      act: (cubit) => cubit.addToCart(5),
      expect: () => [
        CartStateLoaded({5: 1}),
      ],
    );

    blocTest(
      'removeFromCart emits Loaded without item',
      build: () {
        when(() => mockRemoveFromCart(1)).thenAnswer((_) async => {});
        when(() => mockGetCart()).thenAnswer((_) async => <int, int>{});
        return CartCubit(
          mockGetCart,
          mockAddToCart,
          mockRemoveFromCart,
          mockUpdateQuantity,
        );
      },
      act: (cubit) => cubit.removeFromCart(1),
      expect: () => [CartStateLoaded({})],
    );
  });
}
