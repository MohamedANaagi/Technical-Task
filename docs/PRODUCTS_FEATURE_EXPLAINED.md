# شرح فيتشر المنتجات (Products) — وحدة وحدة

هذا الملف يشرح **فيتشر الـ Products بالكامل**: المفاهيم المطبقة، اللوجيك، والعلاقة بين الطبقات، عشان لو اتسألت عنه في مقابلة أو مراجعة تكون جاهز.

---

## 1. نظرة عامة على الـ Products

- **الوظيفة:** جلب قائمة المنتجات من الـ API، تخزينها في الكاش (SharedPreferences)، وعرضها مع دعم **الـ pagination** و**البحث** و**العرض أوفلاين** من الكاش.
- **مصدر البيانات:** Fake Store API — GET `/products`.
- **التخزين المحلي:** SharedPreferences — مفتاح `products_cache` مع **انتهاء صلاحية** (24 ساعة) بمفتاح `products_cache_expiry`.
- **الربط مع فيتشرز تانية:** المنتجات تظهر في القائمة؛ من كل منتج تقدر تضيفه للمفضلة (Favorites) أو للسلة (Cart)، وتفتح صفحة التفاصيل.

---

## 2. المفاهيم المطبقة (Concepts)

| المفهوم | التطبيق في Products |
|--------|----------------------|
| **Clean Architecture** | فصل Domain / Data / Presentation داخل `features/products/`. |
| **Repository Pattern** | واجهة `ProductsRepository` في الـ domain؛ التنفيذ `ProductsRepositoryImpl` في الـ data. |
| **Use Case** | `GetProductsUseCase` — عملية واحدة: جلب المنتجات (مع خيار `forceRefresh`). |
| **Data Sources** | Remote (API عبر Dio) + Local (SharedPreferences للكاش). |
| **Cache-Aside** | نقرأ من الـ API؛ لو نجح → نحدّث الكاش. لو فشل أو أوفلاين → نعرض من الكاش إن وُجد. |
| **Offline-First (جزئي)** | لو مفيش نت والكاش موجود → نرجع من الكاش و`fromCache: true`. |
| **Pagination (UI)** | الـ API يرجع كل المنتجات مرة واحدة؛ الـ Cubit يعرض 10 منتجات في الصفحة ويدعم "Load More". |
| **Sealed Classes (States)** | كل حالات الـ Products state (Initial, Loading, Loaded, Empty, Error) كـ sealed مع تمييز أوفلاين في Error و Loaded. |

---

## 3. طبقة الـ Domain (Domain Layer)

الـ domain **مستقل** عن Flutter وعن مصدر البيانات؛ فيه الكيانات، واجهة الـ repository، والـ use case.

### 3.1 الكيان (Entity): `Product` و `ProductRating`

**الملف:** `lib/features/products/domain/entities/product.dart`

- **Product:** يحتوي على: `id`, `title`, `price`, `description`, `category`, `image`, `rating`.
- **ProductRating:** كيان فرعي: `rate` (double), `count` (int).
- استخدام **Equatable** لمقارنة الـ instances (مهم للـ state في الـ Cubit والـ BlocBuilder).

**أسئلة محتملة:**
- ليه الـ entity بدون منطق؟  
  → الـ entity تمثيل للبيانات في الـ domain فقط؛ المنطق في الـ use cases والـ repository.

---

### 3.2 نتيجة الجلب: `GetProductsResult`

**الملف:** `lib/features/products/domain/repositories/products_repository.dart`

```dart
class GetProductsResult {
  const GetProductsResult({required this.products, this.fromCache = false});
  final List<Product> products;
  final bool fromCache;
}
```

- **الدور:** إرجاع القائمة + إشارة إن البيانات من الكاش (عشان الـ UI تعرض "Showing cached data" أو أي سلوك مختلف).
- **ليه مش نرجع `List<Product>` فقط؟**  
  → عشان الـ presentation تعرف هل نعرض تنبيه أوفلاين أو لا بدون ما تكسر الـ domain.

---

### 3.3 واجهة الـ Repository: `ProductsRepository`

**الملف:** `lib/features/products/domain/repositories/products_repository.dart`

```dart
abstract interface class ProductsRepository {
  Future<GetProductsResult> getProducts({bool forceRefresh = false});
}
```

- **الدور:** عقد بين الـ domain ومن ينفّذ المنطق (الـ data layer).
- **`forceRefresh`:** لو `true` ومعناها اتصال → نجلب من الـ API ونحدّث الكاش؛ لو فشل الـ API نرجع من الكاش إن وُجد.

**أسئلة محتملة:**
- ليه abstract interface؟  
  → عشان الـ use case والـ Cubit يعتمدا على الواجهة فقط؛ التنفيذ في الـ data (سهل الـ mock في الاختبارات).

---

### 3.4 Use Case: `GetProductsUseCase`

**الملف:** `lib/features/products/domain/usecases/get_products_usecase.dart`

```dart
class GetProductsUseCase {
  GetProductsUseCase(this._repository);
  final ProductsRepository _repository;

  Future<GetProductsResult> call({bool forceRefresh = false}) =>
      _repository.getProducts(forceRefresh: forceRefresh);
}
```

- **الدور:** عملية واحدة — استدعاء الـ repository فقط؛ كل قرار "من فين نجيب البيانات" داخل الـ repository.
- الـ Cubit يستدعي الـ use case ولا يتكلم مع الـ repository مباشرة.

---

## 4. طبقة الـ Data (Data Layer)

### 4.1 الـ Model: `ProductModel`

**الملف:** `lib/features/products/data/models/product_model.dart`

- **يرث من `Product`** (الـ entity) ويضيف:
  - `fromJson(Map<String, dynamic>)` لتحويل رد الـ API إلى كائن.
  - `toJson()` لحفظ الكاش في SharedPreferences (كـ JSON).
- الـ API يرجع `rating` كـ object فيه `rate` و `count`؛ لو مش موجود نستخدم قيم افتراضية.

**أسئلة محتملة:**
- ليه الـ Model داخل الـ data ومش الـ domain؟  
  → لأن الـ Model مرتبط بتنسيق الـ API/التخزين؛ الـ domain يبقى فيه الـ Entity فقط.

---

### 4.2 Remote Data Source

**الواجهة:** `ProductsRemoteDataSource` — دالة واحدة: `Future<List<ProductModel>> fetchProducts()`.

**التنفيذ:** `ProductsRemoteDataSourceImpl`:
- يستخدم **Dio** (من الـ DI).
- GET `/products` (الـ base URL من الـ Dio client).
- يحوّل كل عنصر في الـ response إلى `ProductModel.fromJson(...)`.

---

### 4.3 Local Data Source (الكاش)

**الواجهة:** `ProductsLocalDataSource`:
- `cacheProducts(List<ProductModel>)` — حفظ القائمة + وقت انتهاء الصلاحية.
- `getCachedProducts()` — جلب من الكاش؛ لو انتهت الصلاحية يرجع `null`.
- `clearCache()` — مسح المفتاحين (اختياري، للتطوير أو إعدادات).

**التنفيذ:** `ProductsLocalDataSourceImpl`:
- **SharedPreferences**:
  - المفتاح: `AppConstants.productsCacheKey` = `'products_cache'`.
  - مفتاح انتهاء الصلاحية: `AppConstants.cacheExpiryKey` = `'products_cache_expiry'`.
- **مدة الكاش:** `AppConstants.cacheExpiry` = 24 ساعة.
- عند الحفظ: `setString(productsCacheKey, jsonEncode(list))` و `setInt(cacheExpiryKey, expiryTime)`.
- عند القراءة: لو `raw == null` أو `expiry` منتهي → `null`؛ وإلا نُفك الـ JSON ونُرجع `List<ProductModel>`.

**أسئلة محتملة:**
- ليه 24 ساعة؟  
  → توازن بين حداثة البيانات وتقليل استدعاءات الـ API؛ تقدر تغيّرها من `AppConstants`.

---

### 4.4 تنفيذ الـ Repository: `ProductsRepositoryImpl`

**الملف:** `lib/features/products/data/repositories/products_repository_impl.dart`

اللوجيك بالترتيب:

1. **التحقق من الاتصال:** `_hasConnection()` باستخدام **Connectivity** (wifi / mobile / ethernet).

2. **لو `forceRefresh == true` ومعناها اتصال:**
   - نجرب نجلب من الـ API.
   - لو نجح → نحدّث الكاش ونرجع `GetProductsResult(products: products)`.
   - لو فشل → نجرب الكاش؛ لو فيه بيانات نرجعها مع `fromCache: true`، وإلا نُعيد رمي الاستثناء.

3. **لو فيه اتصال (بدون forceRefresh أو بعد فشل forceRefresh):**
   - نجرب نجلب من الـ API.
   - لو نجح → نحدّث الكاش ونرجع النتيجة.
   - لو فشل → نرجع من الكاش إن وُجد مع `fromCache: true`.
   - لو مفيش كاش: نرمي الاستثناء المناسب (`ServerException`, `OfflineException`, `TimeoutException` أو `ServerException` عام).

4. **لو مفيش اتصال:**
   - نجلب من الكاش فقط.
   - لو فيه بيانات → `GetProductsResult(products: cached, fromCache: true)`.
   - لو مفيش → نرمي `OfflineException('No internet. Cached data unavailable.')`.

**ملخص القرارات:**
- الاتصال موجود → نحاول API أولاً؛ عند الفشل نلجأ للكاش.
- الاتصال غير موجود → كاش فقط؛ لو فاضي نرمي أوفلاين.

---

## 5. طبقة الـ Presentation

### 5.1 الحالات (States) — Sealed Class

**الملف:** `lib/features/products/presentation/cubit/products_state.dart`

| State | متى تُستخدم |
|-------|-------------|
| `ProductsStateInitial` | قبل أي تحميل. |
| `ProductsStateLoading` | أثناء جلب المنتجات. |
| `ProductsStateLoaded` | نجاح — تحتوي `products`, `hasMore`, `isOffline`. |
| `ProductsStateEmpty` | التحميل نجح لكن القائمة فاضية. |
| `ProductsStateError` | فشل — تحتوي `message` و `isOffline` (للتمييز بين خطأ شبكة وخطأ سيرفر). |

استخدام **sealed** يسمح للـ compiler يتحقق إن كل الحالات متغطاة في الـ `BlocBuilder` (pattern matching).

---

### 5.2 الـ Cubit: `ProductsCubit`

**الملف:** `lib/features/products/presentation/cubit/products_cubit.dart`

**التبعيات:** `GetProductsUseCase`, `Connectivity` (ممكن استخدامها لاحقاً في الـ UI؛ حالياً قرار الاتصال في الـ repository).

**البيانات الداخلية:**
- `_allProducts`: كل المنتجات المُحمّلة (من API أو كاش).
- `_page`: رقم الصفحة الحالية للـ pagination (0-based).

**الدوال:**

1. **`loadProducts({bool forceRefresh = false})`**
   - لو الحالة Loading وبدون forceRefresh → ما نعمل شيء (تجنب التحميل المزدوج).
   - نُصدّر `ProductsStateLoading`.
   - نستدعي الـ use case ثم:
     - نجاح → نحدّث `_allProducts`, نُصفّر `_page`, ونُصدّر الصفحة الأولى عبر `_emitPage(result.fromCache)`.
     - فشل → نُصدّر `ProductsStateError` مع التمييز بين أوفلاين وسيرفر/تايم أوت.

2. **`loadMore()`**
   - تعمل فقط لو الحالة `ProductsStateLoaded`.
   - نزيد `_page` ثم نُصدّر الصفحة الجديدة (عدد العناصر = `(_page + 1) * productsPageSize`، والحد 10 من `AppConstants.productsPageSize`).
   - لو مفيش عناصر زيادة نوقف الـ "Load More".

3. **`_emitPage([bool isOffline])`**
   - تحسب نهاية الصفحة: `end = (_page + 1) * pageSize`.
   - تأخذ من `_allProducts` من 0 إلى end.
   - لو القائمة فاضية → `ProductsStateEmpty`؛ وإلا `ProductsStateLoaded` مع `hasMore` و `isOffline`.

**ملاحظة:** الـ API يرجع كل المنتجات مرة واحدة؛ الـ pagination **عرض فقط** (في الذاكرة) لتحسين الـ UX وتقليل عدد العناصر في الـ Grid مرة واحدة.

**`allProducts` getter:** يُستخدم في صفحة القائمة للبحث — نفلتر من `_allProducts` حسب نص البحث (title/category) والنتيجة المعروضة من الـ state الحالية.

---

### 5.3 الصفحات (Pages)

- **ProductsShell:** يلف الـ MainShell (الشريط السفلي: Discover, Favorites, Cart, Profile).
- **ProductsListPage:**
  - توفر `ProductsCubit` وتستدعي `loadProducts()` عند البناء.
  - شريط بحث (TextField) — الفلترة في الـ UI من `context.read<ProductsCubit>().allProducts` حسب الـ query.
  - زر Refresh → `loadProducts(forceRefresh: true)`.
  - حسب الـ state: Loading (شيمر)، Error (رسالة + زر Try Again)، Empty، Loaded (شبكة منتجات + Load More عند الوصول لآخر عنصر).
  - عند Loaded: إن كانت البيانات من الكاش نعرض بانر "Showing cached data".
  - كل عنصر: صورة، عنوان، سعر، تقييم، زر "Add to Cart"، قلب للمفضلة، والضغط يفتح `ProductDetailPage`.
- **ProductDetailPage:**
  - تستقبل `Product` (من الـ entity).
  - تعرض الصورة (Hero)، الفئة، العنوان، السعر، التقييم، الوصف.
  - أزرار: إضافة للمفضلة، إضافة للسلة (مع SnackBar).

---

## 6. Dependency Injection (GetIt)

**الملف:** `lib/core/di/injection.dart`

- `ProductsRemoteDataSource` → `ProductsRemoteDataSourceImpl(Dio)` — Singleton.
- `ProductsLocalDataSource` → `ProductsLocalDataSourceImpl(SharedPreferences)` — Singleton.
- `ProductsRepository` → `ProductsRepositoryImpl(remote, local, Connectivity)` — Singleton.
- `GetProductsUseCase` → يعتمد على `ProductsRepository` — Singleton.
- `ProductsCubit` → `ProductsCubit(GetProductsUseCase, Connectivity)` — **Factory** (كل مرة صفحة القائمة تحتاج cubit جديد).

**ليه ProductsCubit Factory؟**  
→ لأن الـ Cubit مربوط بحياة الـ ProductsListPage (BlocProvider داخل الصفحة)；لو استخدمنا Singleton هيبقى state قديم لو المستخدم رجع للصفحة تاني.

---

## 7. تدفق البيانات (Data Flow) — ملخص

1. المستخدم يفتح شاشة Discover → `ProductsListPage` تنشئ `ProductsCubit` وتستدعي `loadProducts()`.
2. الـ Cubit يُصدّر Loading ثم يستدعي `GetProductsUseCase()`.
3. الـ Use Case يستدعي `ProductsRepository.getProducts()`.
4. الـ Repository يتحقق من الاتصال؛ يقرر يجيب من API أو من الكاش حسب اللوجيك فوق.
5. النتيجة ترجع كـ `GetProductsResult` (قائمة + fromCache).
6. الـ Cubit يحدّث `_allProducts` ويُصدّر `ProductsStateLoaded` للصفحة الأولى (10 عناصر).
7. الـ UI تعرض الـ Grid؛ عند الوصول لآخر عنصر تستدعي `loadMore()` فتُصدّر نفس الـ state مع 10 عناصر زيادة.
8. البحث: من الـ UI فقط — نفلتر `allProducts` حسب النص ونعرض النتيجة؛ مفيش استدعاء API جديد.

---

## 8. أسئلة محتملة في المقابلة

- **ليه الـ pagination في الـ UI والـ API يرجع كل المنتجات؟**  
  → Fake Store API ما يدعمش pagination؛ فجرّبنا نحدّ من العناصر المعروضة في الشاشة (10 ثم Load More) عشان الأداء والـ UX. في تطبيق حقيقي ممكن الـ API يدعم offset/limit.

- **إيه الفرق بين `fromCache` و `isOffline` في الـ state؟**  
  → `fromCache` من الـ repository (البيانات جت من الكاش). الـ Cubit يحوّلها لـ `isOffline` في الـ `ProductsStateLoaded` عشان الـ UI تعرف تعرض "Showing cached data".

- **لو الكاش انتهت صلاحيته والمستخدم أوفلاين؟**  
  → `getCachedProducts()` ترجع `null`؛ الـ repository يرمي `OfflineException` والـ Cubit يُصدّر `ProductsStateError(message, isOffline: true)`.

- **ليه مفيش Use Case للـ loadMore؟**  
  → الـ loadMore بيانياً فقط على البيانات المُحمّلة في الذاكرة؛ مفيش استدعاء repository، فمحتاجش use case.

- **إيه دور Connectivity في الـ Cubit؟**  
  → حالياً الـ repository هو اللي يستخدمه؛ الـ Cubit ممكن يستخدمه لو حابب تعرض حالة الشبكة في الـ UI قبل ما المستخدم يعمل refresh.

لو حابب نضيف قسم للـ Tests أو نربط الـ Products بـ Favorites/Cart بالتفصيل في نفس الملف، نقدر نكمّل في نفس الـ doc.
