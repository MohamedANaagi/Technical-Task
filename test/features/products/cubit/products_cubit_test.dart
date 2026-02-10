import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:technica_task/core/errors/app_exceptions.dart';
import 'package:technica_task/features/products/domain/entities/product.dart';
import 'package:technica_task/features/products/domain/repositories/products_repository.dart';
import 'package:technica_task/features/products/domain/usecases/get_products_usecase.dart';
import 'package:technica_task/features/products/presentation/cubit/products_cubit.dart';
import 'package:technica_task/features/products/presentation/cubit/products_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockGetProductsUseCase mockGetProducts;
  late MockConnectivity mockConnectivity;

  final product = Product(
    id: 1,
    title: 'Test',
    price: 9.99,
    description: 'Desc',
    category: 'cat',
    image: 'https://example.com/img.png',
    rating: const ProductRating(rate: 4.5, count: 100),
  );

  setUp(() {
    mockGetProducts = MockGetProductsUseCase();
    mockConnectivity = MockConnectivity();
  });

  group('ProductsCubit', () {
    test('initial state is ProductsStateInitial', () {
      final cubit = ProductsCubit(mockGetProducts, mockConnectivity);
      expect(cubit.state, const ProductsStateInitial());
      cubit.close();
    });

    blocTest<ProductsCubit, ProductsState>(
      'loadProducts emits Loaded when success',
      build: () {
        when(() => mockGetProducts(forceRefresh: false)).thenAnswer(
          (_) async => GetProductsResult(products: [product], fromCache: false),
        );
        return ProductsCubit(mockGetProducts, mockConnectivity);
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const ProductsStateLoading(),
        isA<ProductsStateLoaded>()
            .having((s) => s.products.length, 'products.length', 1)
            .having((s) => s.products.first.id, 'products.first.id', 1),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'loadProducts emits Error on OfflineException',
      build: () {
        when(
          () => mockGetProducts(forceRefresh: false),
        ).thenThrow(const OfflineException('No internet'));
        return ProductsCubit(mockGetProducts, mockConnectivity);
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const ProductsStateLoading(),
        isA<ProductsStateError>()
            .having((s) => s.message, 'message', 'No internet')
            .having((s) => s.isOffline, 'isOffline', true),
      ],
    );

    blocTest<ProductsCubit, ProductsState>(
      'loadProducts emits Error on ServerException',
      build: () {
        when(
          () => mockGetProducts(forceRefresh: false),
        ).thenThrow(const ServerException('Server error'));
        return ProductsCubit(mockGetProducts, mockConnectivity);
      },
      act: (cubit) => cubit.loadProducts(),
      expect: () => [
        const ProductsStateLoading(),
        isA<ProductsStateError>()
            .having((s) => s.message, 'message', 'Server error')
            .having((s) => s.isOffline, 'isOffline', false),
      ],
    );
  });
}
