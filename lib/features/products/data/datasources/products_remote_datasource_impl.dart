import 'package:dio/dio.dart';

import '../models/product_model.dart';
import 'products_remote_datasource.dart';

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  ProductsRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final response = await _dio.get<List<dynamic>>('/products');
    final list = response.data ?? [];
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
