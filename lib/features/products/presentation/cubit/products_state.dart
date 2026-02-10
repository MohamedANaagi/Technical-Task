import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object?> get props => [];
}

final class ProductsStateInitial extends ProductsState {
  const ProductsStateInitial();
}

final class ProductsStateLoading extends ProductsState {
  const ProductsStateLoading();
}

final class ProductsStateLoaded extends ProductsState {
  const ProductsStateLoaded({
    required this.products,
    required this.hasMore,
    this.isOffline = false,
  });
  final List<Product> products;
  final bool hasMore;
  final bool isOffline;
  @override
  List<Object?> get props => [products, hasMore, isOffline];
}

final class ProductsStateEmpty extends ProductsState {
  const ProductsStateEmpty();
}

final class ProductsStateError extends ProductsState {
  const ProductsStateError(this.message, {this.isOffline = false});
  final String message;
  final bool isOffline;
  @override
  List<Object?> get props => [message, isOffline];
}
