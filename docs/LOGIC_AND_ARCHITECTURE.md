# شرح منطق وتصميم تطبيق Technica Task

هذا الملف يشرح **كل اللوجيك والهيكلة** في المشروع عشان لو اتسألت عنه في أي مقابلة أو مراجعة تكون جاهز.

---

## 1. نظرة عامة على التطبيق

- **نوع التطبيق:** Flutter – تطبيق متجر منتجات (E-commerce بسيط).
- **الـ API:** Fake Store API (`https://fakestoreapi.com`).
- **الهيكلة:** Clean Architecture مع Feature-based folders.
- **إدارة الحالة:** BLoC/Cubit (flutter_bloc).
- **حقن التبعيات:** GetIt.

---

## 2. البنية (Architecture)

المشروع منظم على **Clean Architecture** بثلاث طبقات أساسية داخل كل feature:

```
lib/
├── core/                    # مشترك بين كل الـ features
│   ├── constants/           # ثوابت (مفاتيح التخزين، وقت الكاش، إلخ)
│   ├── di/                  # Dependency Injection (GetIt)
│   ├── env/                 # بيئة التشغيل (dev / prod)
│   ├── errors/              # استثناءات التطبيق
│   ├── network/             # Dio client
│   └── theme/               # ألوان وثيم
└── features/
    ├── auth/                # تسجيل الدخول والخروج
    ├── cart/                # السلة
    ├── favorites/           # المفضلة
    └── products/            # المنتجات + الشاشات الرئيسية
```

داخل كل feature:

- **domain:** الكيانات (entities)، الـ repository (واجهة)، والـ use cases – **بدون اعتماد على Flutter أو بيانات خارجية**.
- **data:** تنفيذ الـ repository، الـ datasources (remote/local)، والـ models إن وجدت.
- **presentation:** الـ Cubits، الـ states، والـ UI (صفحات وويدجتات).

**ليه كده؟** عشان:
- الـ business logic يبقى في الـ domain ومستقل عن الـ UI والـ data sources.
- يسهل الاختبار (تقدر تعمل mock للـ repository).
- يسهل تغيير مصدر البيانات (API مختلف أو قاعدة بيانات) من غير ما تكسر الـ UI.

---

## 3. تشغيل التطبيق والبيئة (Entry Points & Env)

- **`main.dart`:** يستدعي `AppEnv.init(Flavor.prod)` ثم `bootstrap()`.
- **`main_dev.dart`:** نفس الكلام لكن `Flavor.dev` (اسم التطبيق "Technica Dev" وبانر الديبق يظهر).
- **`main_prod.dart`:** `Flavor.prod` (اسم "Technica Task" وبدون بانر ديبق).

الـ **bootstrap** بيعمل:
1. `initInjection()` – تسجيل كل الـ services والـ repositories والـ use cases والـ Cubits في GetIt.
2. `runApp(TechnicaTaskApp())`.

الـ **base URL** للـ API واحد في dev و prod: `https://fakestoreapi.com` (من `AppEnv` و `AppConstants`).

---

## 4. حقن التبعيات (DI – GetIt)

في `core/di/injection.dart`:

- **Core:** `SharedPreferences`, `FlutterSecureStorage`, `DioClient`, `Dio`, `Connectivity`.
- **Auth:** Remote + Local datasources → `AuthRepositoryImpl` → `LoginUseCase`, `LogoutUseCase`, `CheckAuthUseCase` → `AuthCubit` (factory عشان كل مرة تعمل instance جديدة).
- **Products:** Remote + Local datasources + Connectivity → `ProductsRepositoryImpl` → `GetProductsUseCase` → `ProductsCubit` (factory).
- **Favorites:** Local datasource فقط → Repository → 3 use cases (Get, Toggle, IsFavorite) → `FavoritesCubit` (factory).
- **Cart:** Local datasource فقط → Repository → 4 use cases (Get, Add, Remove, UpdateQuantity) → `CartCubit` (factory).

الـ **Cubits** مسجلة كـ **factory** عشان كل شاشة/ـ BlocProvider تقدر تاخد instance جديدة لو محتاج، والـ repositories و use cases **singleton** عشان حالة واحدة موحدة (مثلاً سلة واحدة في التطبيق كله).

---

## 5. الـ Auth (تسجيل الدخول والخروج)

### 5.1 التدفق من أول فتح التطبيق

1. في `main.dart`: يتم إنشاء `AuthCubit` واستدعاء `checkAuth()`.
2. **AuthCubit.checkAuth():**
   - يبعث `AuthStateLoading`.
   - يستدعي `CheckAuthUseCase` اللي بيستدعي `AuthRepository.getStoredAuth()`.
   - الـ repository بيقرا الـ token من **AuthLocalDataSource** (FlutterSecureStorage).
   - لو في token غير فاضي → `AuthStateAuthenticated(user)`.
   - لو مفيش → `AuthStateUnauthenticated()`.

3. الـ **UI** في `main.dart` بتبني الـ home بناءً على الـ state:
   - `Initial` أو `Loading` → شاشة splash (لوقو + مؤشر تحميل).
   - `Authenticated` → `ProductsShell` (التابات: Store, Favorites, Cart, Profile).
   - `Unauthenticated` أو `Error` → `LoginPage`.

### 5.2 تسجيل الدخول (Login)

1. المستخدم يدخل email/username و password في `LoginForm` ويضغط Sign In.
2. الـ form يعمل validate (الحقول مطلوبة).
3. استدعاء `AuthCubit.login(email, password)`.
4. الـ Cubit يبعث `AuthStateLoading` ثم يستدعي `LoginUseCase`.
5. **AuthRepositoryImpl.login:**
   - التحقق من أن email و password غير فاضيين (وإلا يرمي `AuthException`).
   - استدعاء **AuthRemoteDataSource.login(username, password)**.

6. **AuthRemoteDataSourceImpl:**
   - **ديمو:** لو username = `mohamed` و password = `0000` يرجع فوراً `demo_token_mohamed` **بدون أي استدعاء API** (لتجربة سريعة).
   - غير كده: طلب POST لـ `/auth/login` مع `username` و `password`، والـ response متوقع فيه `token`. لو 401 يرمي `AuthException('Invalid email or password.')`.

7. بعد ما الـ repository ياخد الـ token، بيحفظه عبر **AuthLocalDataSource.saveToken(token)** (FlutterSecureStorage بمفتاح `auth_token`).
8. الـ repository يرجع `AuthUser(token: token)` والـ Cubit يبعث `AuthStateAuthenticated(user)` فينتقل المستخدم للـ ProductsShell.

### 5.3 تسجيل الخروج (Logout)

- من الـ Profile: زر "Sign Out" يفتح dialog تأكيد، وبعد التأكيد يستدعي `AuthCubit.logout()`.
- **AuthCubit.logout():** يستدعي `LogoutUseCase` اللي بيستدعي `AuthRepository.logout()`.
- **AuthRepositoryImpl.logout():** يستدعي `AuthLocalDataSource.clearToken()` فقط (مسح الـ token من Secure Storage).
- بعدين الـ Cubit يبعث `AuthStateUnauthenticated()` فيرجع التطبيق لـ LoginPage.

### 5.4 ملخص Auth

- **Entity:** `AuthUser` فيه `token` فقط.
- **التخزين:** FlutterSecureStorage بمفتاح من `AppConstants.authTokenKey`.
- **الديمو:** mohamed / 0000 بدون API.
- **الـ API الحقيقي:** POST `/auth/login` مع username و password.

---

## 6. المنتجات (Products)

### 6.1 المصادر والكاش

- **Remote:** `ProductsRemoteDataSource` – GET `/products` من Fake Store API، ويرجع `List<ProductModel>`.
- **Local:** `ProductsLocalDataSource` – حفظ واسترجاع قائمة المنتجات في **SharedPreferences**:
  - مفتاح القائمة: `AppConstants.productsCacheKey`.
  - مفتاح انتهاء الصلاحية: `AppConstants.cacheExpiryKey`.
  - مدة الصلاحية: `AppConstants.cacheExpiry` = 24 ساعة.

### 6.2 لوجيك الـ Repository (ProductsRepositoryImpl)

- يستخدم **Connectivity** عشان يعرف هل فيه نت ولا لا.
- **لو المستخدم طلب forceRefresh وفيه نت:** يجيب من الـ API، يحفظ في الكاش، ويرجع النتيجة. لو الـ API فشل يرجع من الكاش لو موجود.
- **لو فيه نت (بدون forceRefresh أو معاه):** يجيب من الـ API، يحفظ في الكاش، ويرجع. لو الـ API فشل يرجع من الكاش لو موجود، وإلا يرمي الاستثناء المناسب (ServerException, OfflineException, TimeoutException).
- **لو مفيش نت:** يرجع من الكاش فقط. لو مفيش كاش أو منتهي يرمي `OfflineException('No internet. Cached data unavailable.')`.

النتيجة نوعها `GetProductsResult(products, fromCache: bool)` عشان الـ UI تعرف تعرض "Showing cached data" لو لزم.

### 6.3 ProductsCubit

- **loadProducts(forceRefresh: false/true):** يستدعي `GetProductsUseCase` ويرتب الـ state:
  - Loading → ثم إما Loaded أو Error أو Empty.
  - في حالة الخطأ يفرق بين OfflineException و ServerException و TimeoutException ويبعث `ProductsStateError(message, isOffline)`.
- **Pagination (وهمية من القائمة الكاملة):** كل المنتجات بتتحمل مرة واحدة وتتخزن في `_allProducts`. الـ state بيحتوي على "صفحة" من المنتجات فقط: حجم الصفحة من `AppConstants.productsPageSize` (10). عند استدعاء **loadMore()** يزيد `_page` ويبعث قائمة أطول (sublist من _allProducts). لو مفيش عناصر زيادة مفيش "Load more".
- **allProducts:** getter يرجع كل المنتجات (للفلترة في البحث وفي شاشات Favorites/Cart).

### 6.4 الشاشات والـ UI

- **ProductsListPage:** تعرض قائمة المنتجات مع:
  - **بحث:** على `title` و `category` من `allProducts` (بحث محلي).
  - **سحب للتحديث:** يستدعي `loadProducts(forceRefresh: true)`.
  - **تحميل المزيد:** عند الوصول لآخر عنصر في الـ grid يستدعي `loadMore()`.
  - كل عنصر: صورة، عنوان، سعر، تقييم، زر "Add to Cart"، وزر قلب للمفضلة (من FavoritesCubit).
  - الضغط على المنتج يفتح **ProductDetailPage**.

- **ProductDetailPage:** تفاصيل منتج واحد (صورة، وصف، سعر، تقييم، زر إضافة للمفضلة، زر Add to Cart). بيانات المنتج جاية من الـ widget (من القائمة أو من الشاشات التانية).

- **CartPage و FavoritesPage:** بيحتاجوا قائمة المنتجات عشان يعرضوا التفاصيل؛ لذلك بيستخدموا `BlocProvider` لـ ProductsCubit ويستدعوا `loadProducts()` لو محتاجين، وبعدين يقرؤوا `allProducts` ويلاقوا المنتج من الـ id (Cart: من `CartStateLoaded.items` كـ Map productId → quantity، Favorites: من `FavoritesStateLoaded.ids` كـ Set).

---

## 7. المفضلة (Favorites)

- **التخزين:** محلي فقط – **SharedPreferences** بمفتاح `AppConstants.favoritesKey`. القيمة عبارة عن JSON لـ list من الـ product ids.
- **FavoritesLocalDataSourceImpl:** يقرأ/يكتب الـ list ويحولها لـ `Set<int>` (الـ ids).
- **FavoritesRepositoryImpl:** يوفر `getFavoriteIds()`, `toggleFavorite(id)`, `isFavorite(id)`. الـ toggle يتحقق من الحالة الحالية ثم إما add أو remove.
- **FavoritesCubit:** عند فتح التطبيق (من main) بيتم استدعاء `loadFavorites()` وقراءة الـ ids وإرسال `FavoritesStateLoaded(ids)`. عند الضغط على القلب في أي مكان بيتم استدعاء `toggleFavorite(productId)` ثم إعادة تحميل الـ ids وإرسال الـ state الجديد.
- في **ProductDetailPage** عند الفتح يتم استدعاء `isFavorite(product.id)` عشان يعرض حالة القلب صح (وبعد الضغط يتم تحديث الـ state من الـ BlocBuilder).

---

## 8. السلة (Cart)

- **التخزين:** محلي فقط – **SharedPreferences** بمفتاح `AppConstants.cartKey`. القيمة عبارة عن JSON لـ Map من productId (كـ string) إلى quantity (number).
- **CartLocalDataSourceImpl:** يقرأ الـ map، يعدلها (add / remove / update quantity)، ويكتبها تاني. لو الـ quantity بتصبح 0 أو أقل بيشيل المنتج من السلة.
- **CartRepositoryImpl:** مجرد wrapper على الـ datasource (getCart, addToCart, removeFromCart, updateQuantity).
- **CartCubit:** عند فتح التطبيق بيتم استدعاء `loadCart()` وإرسال `CartStateLoaded(items)`. أي عملية (add, remove, updateQuantity) بتنفذ ثم تستدعي getCart وتبعث الـ state الجديد.
- **CartStateLoaded:** فيه `items` (Map<int, int>) و getter `itemCount` (مجموع الكميات). الـ itemCount ده اللي بيظهر في الـ badge على تاب السلة في الـ bottom nav.
- في **CartPage:** القائمة مبنية من `items.entries` ومع كل entry نلاقي الـ Product من `ProductsCubit.allProducts` حسب الـ id. كل عنصر فيه: صورة، عنوان، تحكم في الكمية (+/-)، وسعر (price * quantity). السوايب لليسار بيشيل من السلة. الـ "Total" محسوب من مجموع (price * quantity) لكل المنتجات في السلة. زر "Checkout" حالياً يعرض SnackBar "Checkout coming soon!".

---

## 9. الشبكة والأخطاء (Network & Errors)

- **DioClient:** إعداد Dio مع baseUrl من الـ env، و timeouts من `AppConstants` (connect/receive 15 ثانية). فيه interceptor يحول أخطاء Dio لاستثناءات التطبيق:
  - connection/send/receive timeout → `TimeoutException`.
  - connection error → `OfflineException`.
  - غيرها (مع status من الـ response إن وجد) → `ServerException`.
- **استثناءات التطبيق** في `core/errors/app_exceptions.dart`: `AppException`, `ServerException`, `TimeoutException`, `OfflineException`, `AuthException`, `CacheException`. الـ UI (مثلاً Products) بتتعامل معهم وتفرق بين offline وغيره (رسالة + أيقونة + زر Try Again).

---

## 10. الثيم والألوان

- **AppTheme:** ثيم فاتح وغامق (Material 3)، مع دعم `ThemeMode.system`.
- **AppColors:** ألوان ثابتة زي الـ primary gradient، لون التقييم، لون المفضلة، لون الـ shimmer، إلخ. مستخدمة في الـ bottom nav، البطاقات، والأزرار.

---

## 11. ملخص سريع لو اتسألت

- **الهيكلة:** Clean Architecture، domain / data / presentation، مع features منفصلة (auth, products, cart, favorites).
- **الدخول:** token في FlutterSecureStorage؛ لو موجود المستخدم يعتبر مسجل دخول ويفتح ProductsShell، وإلا Login. الديمو mohamed/0000 بدون API.
- **المنتجات:** من Fake Store API مع كاش 24 ساعة في SharedPreferences، و fallback للكاش لو مفيش نت أو الـ API فشل. Pagination وهمية من القائمة الكاملة (10 عناصر في الصفحة).
- **المفضلة:** Set من الـ product ids في SharedPreferences؛ toggle من الـ UI يحدث الـ state فوراً.
- **السلة:** Map من productId إلى quantity في SharedPreferences؛ add/remove/update quantity، والـ badge على تاب السلة يعكس المجموع الكلي للكميات.
- **إدارة الحالة:** Cubit لكل feature؛ الـ Cubits اللي محتاجين يبقوا فوق الشجرة (Auth, Favorites, Cart) موجودين في main.dart، و ProductsCubit بيتم توفيره في الشاشات اللي محتاجاه (قائمة المنتجات، السلة، المفضلة).
- **الاعتماديات:** GetIt للـ DI؛ Dio للشبكة؛ SharedPreferences للكاش والمفضلة والسلة؛ FlutterSecureStorage للـ token؛ connectivity_plus للتحقق من الاتصال؛ flutter_bloc و equatable للـ state.

---

## 12. ملفات الـ \*Impl – وظيفتها وإيه الفرق عن الملفات بدون Impl

في المشروع فيه نوعان من الملفات المتعلقة بالـ data والـ repositories:

- **الواجهة (Interface / Abstract class):** ملف **بدون** `Impl` – بيحدد **ماذا** نعمل (الـ contract)، بدون تفاصيل التنفيذ.
- **التنفيذ (Implementation):** ملف **\*_impl.dart** – بيحدد **كيف** ننفذ (Dio، SharedPreferences، إلخ).

### ليه نفصل الواجهة عن التنفيذ؟

1. **الـ domain يعتمد على واجهة فقط:** الـ use cases والـ repository في الـ domain يتعاملون مع `AuthRepository` و `ProductsRepository` كواجهات. مفيش استيراد لـ `AuthRepositoryImpl` في الـ domain. كده الـ business logic معزول عن تفاصيل الـ API أو التخزين.
2. **الاختبار (Unit Test):** في التست بنعمل **Mock** للواجهة (مثلاً `MockAuthRemoteDataSource`) ونحقنها في الـ Repository أو الـ Cubit. لو كان الكود معتمد على الـ Impl مباشرة كان هيحتاج شبكة حقيقية أو SharedPreferences حقيقية في كل test.
3. **استبدال التنفيذ:** تقدر تعمل مثلاً `AuthRemoteDataSourceImplV2` أو `AuthRemoteDataSourceFake` وتسجّلها في GetIt بدون ما تغيّر أي حاجة في الـ domain أو الـ UI.

### قائمة ملفات الـ Impl في المشروع ووظيفة كل واحد

| الملف | الواجهة اللي ينفذها | الوظيفة |
|--------|----------------------|---------|
| **AuthRemoteDataSourceImpl** | AuthRemoteDataSource | يستدعي POST `/auth/login` عبر Dio، أو يرجع token ديمو لمستخدم mohamed/0000. |
| **AuthLocalDataSourceImpl** | AuthLocalDataSource | حفظ/قراءة/مسح الـ token من FlutterSecureStorage. |
| **AuthRepositoryImpl** | AuthRepository | ينسق بين Remote و Local: login يطلب من Remote ثم يحفظ في Local، logout و getStoredAuth من Local فقط. |
| **ProductsRemoteDataSourceImpl** | ProductsRemoteDataSource | GET `/products` من الـ API ويرجع `List<ProductModel>`. |
| **ProductsLocalDataSourceImpl** | ProductsLocalDataSource | حفظ واسترجاع قائمة المنتجات في SharedPreferences مع وقت انتهاء كاش 24 ساعة. |
| **ProductsRepositoryImpl** | ProductsRepository | يتحقق من Connectivity، يجيب من Remote أو من الكاش، ويحدد متى يرمي OfflineException. |
| **FavoritesLocalDataSourceImpl** | FavoritesLocalDataSource | حفظ واسترجاع Set من product ids في SharedPreferences. |
| **FavoritesRepositoryImpl** | FavoritesRepository | getFavoriteIds، toggle (add/remove)، isFavorite – كلها من الـ Local. |
| **CartLocalDataSourceImpl** | CartLocalDataSource | حفظ واسترجاع Map&lt;productId, quantity&gt; في SharedPreferences. |
| **CartRepositoryImpl** | CartRepository | getCart، addToCart، removeFromCart، updateQuantity – كلها delegate للـ Local. |

الـ **DI (injection.dart)** بيستورد الـ Impl ويسجّل الواجهة في GetIt مع صناعة الـ Impl، فمثلاً: `sl<AuthRepository>()` يرجع instance من `AuthRepositoryImpl` لكن الكود يعامله كـ `AuthRepository` فقط.

---

## 13. ملف الـ Env (app_env.dart) – شرح واستخدام

الملف: **`lib/core/env/app_env.dart`**.

### وظيفته

يحدد **بيئة تشغيل التطبيق** حسب الـ **flavor** (dev أو prod) بدون الحاجة لملفات env منفصلة أو متغيرات بيئة معقدة. كل الإعدادات المهمة للتطبيق (اسم التطبيق، الـ base URL، ظهور بانر الديبق) تكون في مكان واحد وتتغير حسب نقطة الدخول.

### المكونات

1. **`enum Flavor { dev, prod }`**  
   يحدد البيئتين المدعومتين.

2. **`AppEnvConfig`**  
   كلاس فيه إعدادات البيئة:
   - `flavor`: dev أو prod
   - `baseUrl`: عنوان الـ API (حالياً نفس الرابط في dev و prod)
   - `appName`: اسم التطبيق اللي يظهر للمستخدم
   - `showDebugBanner`: هل يظهر شريط "DEBUG" في الزاوية

   وقيم ثابتة جاهزة:
   - `AppEnvConfig.dev`: Technica Dev، بانر الديبق يظهر
   - `AppEnvConfig.prod`: Technica Task، بدون بانر

   و getters: `isDev`, `isProd`.

3. **`AppEnv`**  
   كلاس ثابت (abstract final) بيحمل الإعداد الحالي:
   - `AppEnv.current` → يرجع الـ `AppEnvConfig` الحالي
   - `AppEnv.init(Flavor flavor)` → يحدد الإعداد حسب الـ flavor (يُستدعى مرة واحدة من `main` أو `main_dev` أو `main_prod`)

### أين يُستدعى؟

- **`main.dart`:** `AppEnv.init(Flavor.prod)` ثم `bootstrap()`
- **`main_dev.dart`:** `AppEnv.init(Flavor.dev)` ثم `app.bootstrap()`
- **`main_prod.dart`:** `AppEnv.init(Flavor.prod)` ثم `app.bootstrap()`

بعدها في التطبيق أي مكان تحتاج فيه الإعدادات تستخدم:

- `AppEnv.current.appName` → اسم التطبيق
- `AppEnv.current.baseUrl` → للـ DioClient في الـ DI
- `AppEnv.current.showDebugBanner` → في `MaterialApp(debugShowCheckedModeBanner: ...)`
- `AppEnv.current.isDev` / `AppEnv.current.isProd` → لو حابب تفرق سلوك (مثلاً logging أكثر في dev)

### تلخيص

- **Env = إعدادات حسب البيئة (dev/prod).**
- **يُضبط مرة واحدة في بداية main حسب الـ entry point.**
- **استخدامه في أي مكان:** `AppEnv.current.*`

---

## 14. الـ Unit Tests – كيف نستخدمها وشرح الأمثلة

المشروع يستخدم **flutter_test** و **mocktail** و **bloc_test** لاختبار الـ repositories والـ Cubits بدون شبكة أو تخزين حقيقي.

### هيكل مجلد التست

```
test/
├── features/
│   ├── auth/
│   │   ├── cubit/         → auth_cubit_test.dart
│   │   └── repository/    → auth_repository_impl_test.dart
│   ├── cart/              → cart_cubit_test.dart
│   ├── favorites/
│   │   ├── cubit/         → favorites_cubit_test.dart
│   │   └── repository/    → favorites_repository_impl_test.dart
│   └── products/
│       └── cubit/         → products_cubit_test.dart
└── widget_test.dart
```

### الفكرة العامة

- **Repository tests:** نختبر الـ **Impl** (مثلاً `AuthRepositoryImpl`) مع **Mock** للـ datasources. نتحقق أن الـ repository يستدعي الـ remote/local بالمعاملات الصحيحة، وأنه يرجع النتيجة الصحيحة أو يرمي الاستثناء المناسب.
- **Cubit tests:** نختبر الـ **Cubit** مع **Mock** للـ use cases. نتحقق أن استدعاء دالة (مثل `login` أو `loadProducts`) يسبب الـ states المتوقعة بالترتيب (مثلاً Loading ثم Loaded أو Error).

بهذا الشكل الـ **Unit Test** يكون سريع ولا يعتمد على شبكة أو قاعدة أو واجهة مستخدم.

### الأدوات

- **mocktail:** لإنشاء **Mock** لكلاس أو واجهة. الـ mock لا ينفذ الكود الحقيقي؛ أنت تحدد السلوك بـ `when(...).thenAnswer(...)` وتتحقق بالاستدعاءات بـ `verify(...).called(n)`.
- **bloc_test:** لاختبار الـ Cubit/Bloc: تعطي له الـ `build` (صناعة الـ Cubit مع mocks)، والـ `act` (استدعاء الدالة)، والـ `expect` (قائمة الـ states المتوقعة بالترتيب).

### مثال من المشروع – AuthRepositoryImpl

```dart
// Mock للواجهات (مش الـ Impl)
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

setUp(() {
  mockRemote = MockAuthRemoteDataSource();
  mockLocal = MockAuthLocalDataSource();
  repository = AuthRepositoryImpl(mockRemote, mockLocal);
});

// اختبار: login ناجح يحفظ التوكن ويرجع AuthUser
test('returns AuthUser and saves token on success', () async {
  when(() => mockRemote.login(username: 'user', password: 'pass'))
      .thenAnswer((_) async => 'token123');
  when(() => mockLocal.saveToken(any())).thenAnswer((_) async => {});

  final result = await repository.login(email: 'user', password: 'pass');

  expect(result.token, 'token123');
  verify(() => mockRemote.login(username: 'user', password: 'pass')).called(1);
  verify(() => mockLocal.saveToken('token123')).called(1);
});

// اختبار: email فاضي يرمي AuthException ولا يستدعي الـ API
test('throws AuthException when email is empty', () async {
  await expectLater(
    repository.login(email: '  ', password: 'pass'),
    throwsA(isA<AuthException>()),
  );
  verifyNever(() => mockRemote.login(...));
});
```

- **when:** يحدد لو استُدعي الـ mock بكذا معامل، يرجع كذا (أو يرمي استثناء).
- **verify / verifyNever:** يتأكد أن الاستدعاء حصل أو ما حصلش.

### مثال من المشروع – AuthCubit (bloc_test)

```dart
class MockLoginUseCase extends Mock implements LoginUseCase {}
// ... MockLogoutUseCase, MockCheckAuthUseCase

blocTest<AuthCubit, AuthState>(
  'checkAuth emits Authenticated when user exists',
  build: () {
    when(() => mockCheckAuth()).thenAnswer((_) async => user);
    return AuthCubit(mockLogin, mockLogout, mockCheckAuth);
  },
  act: (cubit) => cubit.checkAuth(),
  expect: () => [const AuthStateLoading(), AuthStateAuthenticated(user)],
);

blocTest<AuthCubit, AuthState>(
  'login emits AuthStateError on AuthException',
  build: () {
    when(() => mockLogin(email: 'bad@test.com', password: 'wrong'))
        .thenThrow(const AuthException('Invalid credentials'));
    return AuthCubit(mockLogin, mockLogout, mockCheckAuth);
  },
  act: (cubit) => cubit.login(email: 'bad@test.com', password: 'wrong'),
  expect: () => [
    const AuthStateLoading(),
    const AuthStateError('Invalid credentials'),
  ],
);
```

- **build:** ينشئ الـ Cubit مع mocks ومعاملات الـ when.
- **act:** يشغّل الدالة اللي نختبرها.
- **expect:** قائمة الـ states بالترتيب اللي المفروض الـ Cubit يبعثها.

### تشغيل التستات

من جذر المشروع:

```bash
flutter test
```

لتشغيل ملف معين:

```bash
flutter test test/features/auth/cubit/auth_cubit_test.dart
```

أو من Cursor/VS Code: تشغيل التست من الـ Run فوق الـ `main()` أو الـ `group`.

### ملخص Unit Test في المشروع

| ما نختبره | الأدوات | الهدف |
|-----------|---------|--------|
| **Repository Impl** | mocktail (mock datasources) | التأكد من تنسيق الاستدعاءات والنتائج والاستثناءات. |
| **Cubit** | mocktail + bloc_test (mock use cases) | التأكد من تسلسل الـ states (Loading → Loaded/Error). |
| **لا نختبر** في هذه التستات | — | الـ Impl الفعلي للـ datasources (Dio، SharedPreferences) أو الـ UI؛ تلك تحتاج integration/widget tests. |

لو حابب نعمّل نسخة إنجليزي أو نضيف قسم "أسئلة متوقعة وأجوبتها" نقدر نكمّل في نفس الملف أو في ملف تاني.
