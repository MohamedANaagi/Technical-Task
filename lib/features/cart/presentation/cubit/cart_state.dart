import 'package:equatable/equatable.dart';

sealed class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

final class CartStateInitial extends CartState {
  const CartStateInitial();
}

final class CartStateLoaded extends CartState {
  const CartStateLoaded(this.items);
  final Map<int, int> items; // productId -> quantity
  @override
  List<Object?> get props => [items];
  int get itemCount => items.values.fold(0, (a, b) => a + b);
}
