import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../env/app_env.dart';
import '../network/dio_client.dart';
import '../theme/theme_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/products/data/datasources/products_remote_datasource.dart';
import '../../features/products/data/datasources/products_remote_datasource_impl.dart';
import '../../features/products/data/datasources/products_local_datasource.dart';
import '../../features/products/data/datasources/products_local_datasource_impl.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/repositories/products_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../../features/favorites/data/datasources/favorites_local_datasource.dart';
import '../../features/favorites/data/datasources/favorites_local_datasource_impl.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/favorites_usecases.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/datasources/cart_local_datasource_impl.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/cart_usecases.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initInjection() async {
  // Core
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  sl.registerLazySingleton<DioClient>(
    () => DioClient(baseUrl: AppEnv.current.baseUrl),
  );
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl()));

  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<CheckAuthUseCase>(() => CheckAuthUseCase(sl()));
  sl.registerFactory<AuthCubit>(() => AuthCubit(sl(), sl(), sl()));

  // Products
  sl.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProductsLocalDataSource>(
    () => ProductsLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProductsRepository>(
    () => ProductsRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<GetProductsUseCase>(() => GetProductsUseCase(sl()));
  sl.registerFactory<ProductsCubit>(() => ProductsCubit(sl(), sl()));

  // Favorites
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<GetFavoritesIdsUseCase>(
    () => GetFavoritesIdsUseCase(sl()),
  );
  sl.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(sl()),
  );
  sl.registerLazySingleton<IsFavoriteUseCase>(() => IsFavoriteUseCase(sl()));
  sl.registerFactory<FavoritesCubit>(() => FavoritesCubit(sl(), sl(), sl()));

  // Cart
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(sl()));
  sl.registerLazySingleton<GetCartUseCase>(() => GetCartUseCase(sl()));
  sl.registerLazySingleton<AddToCartUseCase>(() => AddToCartUseCase(sl()));
  sl.registerLazySingleton<RemoveFromCartUseCase>(
    () => RemoveFromCartUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateCartQuantityUseCase>(
    () => UpdateCartQuantityUseCase(sl()),
  );
  sl.registerFactory<CartCubit>(() => CartCubit(sl(), sl(), sl(), sl()));
}
