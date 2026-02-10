import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit(this._getProducts, this._connectivity)
    : super(const ProductsStateInitial());

  final GetProductsUseCase _getProducts;
  final Connectivity _connectivity;

  List<Product> _allProducts = [];
  int _page = 0;

  /// All products loaded from API/cache (for filtering e.g. favorites).
  List<Product> get allProducts => List.unmodifiable(_allProducts);

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (state is ProductsStateLoading && !forceRefresh) return;
    emit(const ProductsStateLoading());
    try {
      final result = await _getProducts(forceRefresh: forceRefresh);
      _allProducts = result.products;
      _page = 0;
      _emitPage(result.fromCache);
    } on OfflineException catch (e) {
      emit(ProductsStateError(e.message, isOffline: true));
    } on ServerException catch (e) {
      emit(ProductsStateError(e.message, isOffline: false));
    } on TimeoutException catch (e) {
      emit(ProductsStateError(e.message, isOffline: false));
    } catch (e) {
      emit(ProductsStateError('Failed to load products.', isOffline: false));
    }
  }

  void loadMore() {
    if (state is! ProductsStateLoaded) return;
    final current = state as ProductsStateLoaded;
    final nextCount = (_page + 1) * AppConstants.productsPageSize;
    if (nextCount >= _allProducts.length) return;
    _page++;
    _emitPage(current.isOffline);
  }

  void _emitPage([bool isOffline = false]) {
    final end = (_page + 1) * AppConstants.productsPageSize;
    final list = _allProducts.length <= end
        ? _allProducts
        : _allProducts.sublist(0, end);
    final hasMore = _allProducts.length > list.length;
    if (list.isEmpty) {
      emit(const ProductsStateEmpty());
    } else {
      emit(
        ProductsStateLoaded(
          products: list,
          hasMore: hasMore,
          isOffline: isOffline,
        ),
      );
    }
  }
}
