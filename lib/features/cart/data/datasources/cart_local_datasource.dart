abstract interface class CartLocalDataSource {
  Future<Map<int, int>> getCart();
  Future<void> addToCart(int productId, {int quantity = 1});
  Future<void> removeFromCart(int productId);
  Future<void> updateQuantity(int productId, int quantity);
}
