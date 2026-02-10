/// Repository for cart operations (add, remove, get items).
abstract interface class CartRepository {
  Future<Map<int, int>> getCart();
  Future<void> addToCart(int productId, {int quantity = 1});
  Future<void> removeFromCart(int productId);
  Future<void> updateQuantity(int productId, int quantity);
}
