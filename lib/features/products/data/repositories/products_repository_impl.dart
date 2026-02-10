import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/errors/app_exceptions.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_datasource.dart';
import '../datasources/products_remote_datasource.dart';
import '../models/product_model.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remote, this._local, this._connectivity);
  final ProductsRemoteDataSource _remote;
  final ProductsLocalDataSource _local;
  final Connectivity _connectivity;

  @override
  Future<GetProductsResult> getProducts({bool forceRefresh = false}) async {
    final hasConnection = await _hasConnection();
    if (forceRefresh && hasConnection) {
      try {
        final products = await _remote.fetchProducts();
        await _local.cacheProducts(products);
        return GetProductsResult(products: products);
      } catch (e) {
        final cached = await _local.getCachedProducts();
        if (cached != null && cached.isNotEmpty) {
          return GetProductsResult(products: cached, fromCache: true);
        }
        rethrow;
      }
    }
    if (hasConnection) {
      try {
        final products = await _remote.fetchProducts();
        await _local.cacheProducts(products);
        return GetProductsResult(products: products);
      } catch (e) {
        final cached = await _local.getCachedProducts();
        if (cached != null && cached.isNotEmpty) {
          return GetProductsResult(products: cached, fromCache: true);
        }
        if (e is ServerException) rethrow;
        if (e is OfflineException) rethrow;
        if (e is TimeoutException) rethrow;
        throw ServerException(e.toString());
      }
    }
    final cached = await _local.getCachedProducts();
    if (cached != null && cached.isNotEmpty) {
      return GetProductsResult(products: cached, fromCache: true);
    }
    throw const OfflineException('No internet. Cached data unavailable.');
  }

  Future<bool> _hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }
}
