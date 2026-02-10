# Technica Task – Flutter E-Commerce App

تطبيق Flutter متكامل لعرض المنتجات وشرائها، مبني بمعمارية Clean Architecture مع إدارة الحالة بـ Cubit، دعم Offline، وتصميم Material 3 عصري.

---

## المحتويات

- [المميزات](#المميزات)
- [المعمارية (Architecture)](#المعمارية-architecture)
- [هيكل المشروع](#هيكل-المشروع)
- [إدارة الحالة (State Management)](#إدارة-الحالة-state-management)
- [التقنيات المستخدمة (Tech Stack)](#التقنيات-المستخدمة-tech-stack)
- [التصميم والواجهة (UI/UX)](#التصميم-والواجهة-uiux)
- [نظام الـ Flavors](#نظام-الـ-flavors)
- [طريقة التشغيل](#طريقة-التشغيل)
- [بيانات الديمو](#بيانات-الديمو)
- [الاختبارات (Testing)](#الاختبارات-testing)
- [التعامل مع الأخطاء (Error Handling)](#التعامل-مع-الأخطاء-error-handling)

---

## المميزات

### تسجيل الدخول (Authentication)
- تسجيل دخول بـ اسم المستخدم وكلمة المرور عبر [Fake Store API](https://fakestoreapi.com)
- حساب ديمو محلي (`mohamed` / `0000`) يعمل بدون API
- حفظ التوكن بشكل آمن باستخدام `flutter_secure_storage`
- تسجيل دخول تلقائي عند فتح التطبيق (إذا كان التوكن محفوظ)
- تسجيل خروج مع حوار تأكيد

### المنتجات (Products)
- عرض قائمة المنتجات من [Fake Store API](https://fakestoreapi.com/products) في شبكة (Grid)
- صور المنتجات مع تخزين مؤقت (cached_network_image)
- بحث فوري بالاسم أو التصنيف
- تحميل تدريجي (Pagination / Lazy Loading)
- سحب لتحديث البيانات (Pull-to-Refresh)
- حالات عرض: تحميل (Shimmer)، فارغ، خطأ، بدون اتصال

### تفاصيل المنتج (Product Detail)
- شاشة تفاصيل كاملة مع صورة كبيرة قابلة للتوسع (SliverAppBar)
- Hero Animation للصورة عند الانتقال
- عرض السعر والتقييم والوصف
- شريط سفلي ثابت مع زر "أضف للسلة"

### المفضلة (Favorites)
- إضافة/إزالة من المفضلة بضغطة واحدة مع أنيميشن
- حفظ محلي دائم (SharedPreferences)
- صفحة مفضلة مع سحب لحذف (Swipe to Remove)

### السلة (Cart)
- إضافة منتجات للسلة من أي مكان
- تحكم بالكمية (+/-)
- سحب لحذف (Swipe to Delete)
- شريط سفلي يعرض المجموع الكلي مع زر Checkout
- Badge على أيقونة السلة يعرض عدد العناصر

### دعم Offline
- تخزين مؤقت لقائمة المنتجات مع صلاحية (24 ساعة)
- عند عدم الاتصال: يعرض البيانات المحفوظة مع بانر "Showing cached data"
- معالجة أخطاء الشبكة بشكل واضح

---

## المعمارية (Architecture)

المشروع مبني بـ **Clean Architecture** بتقسيم حسب الميزات (Feature-based):

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                   │
│          (Pages, Widgets, Cubits/States)             │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                       │
│         (Entities, Repository Interfaces,            │
│                   Use Cases)                          │
├─────────────────────────────────────────────────────┤
│                     Data Layer                        │
│   (Repository Impl, Remote/Local Data Sources,       │
│                    Models)                            │
└─────────────────────────────────────────────────────┘
```

### كيف تعمل الطبقات معاً؟

```
UI (Widget) → Cubit → UseCase → Repository (interface) → DataSource
                                      ↑
                              Repository (implementation)
                              ├── RemoteDataSource (Dio/API)
                              └── LocalDataSource (SharedPreferences/SecureStorage)
```

**ليه Clean Architecture؟**
- **فصل المسؤوليات**: كل طبقة ليها وظيفة واحدة واضحة
- **سهولة الاختبار**: ممكن تعمل Mock لأي طبقة بسهولة
- **قابلية التغيير**: تقدر تغير الـ API أو الـ Database من غير ما تأثر على الـ UI
- **Repository Pattern**: كل الوصول للبيانات يمر من خلال Repository — الـ Domain لا يعرف مصدر البيانات

---

## هيكل المشروع

```
lib/
├── core/                              # الكود المشترك
│   ├── constants/
│   │   └── app_constants.dart         # ثوابت التطبيق (keys, timeouts, page size)
│   ├── di/
│   │   └── injection.dart             # Dependency Injection (GetIt)
│   ├── env/
│   │   └── app_env.dart               # إعدادات Flavors (dev/prod)
│   ├── errors/
│   │   └── app_exceptions.dart        # أنواع الأخطاء (Server, Auth, Offline, Cache, Timeout)
│   ├── network/
│   │   └── dio_client.dart            # Dio client مركزي (timeouts, headers, error mapping)
│   └── theme/
│       ├── app_colors.dart            # ألوان التطبيق + Gradients
│       └── app_theme.dart             # Light/Dark themes (Material 3 + Google Fonts)
│
├── features/
│   ├── auth/                          # ── ميزة تسجيل الدخول ──
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart       # Interface
│   │   │   │   ├── auth_remote_datasource_impl.dart  # تنفيذ (Dio + Demo login)
│   │   │   │   ├── auth_local_datasource.dart        # Interface
│   │   │   │   └── auth_local_datasource_impl.dart   # تنفيذ (SecureStorage)
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart         # تنفيذ Repository
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── auth_user.dart                    # Entity: AuthUser(token)
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart              # Interface
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart                # تسجيل الدخول
│   │   │       ├── logout_usecase.dart               # تسجيل الخروج
│   │   │       └── check_auth_usecase.dart           # فحص التوكن المحفوظ
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart                   # إدارة حالة المصادقة
│   │       │   └── auth_state.dart                   # الحالات: Initial, Loading, Authenticated, Unauthenticated, Error
│   │       ├── pages/
│   │       │   ├── login_page.dart                   # شاشة تسجيل الدخول
│   │       │   └── profile_page.dart                 # شاشة البروفايل والإعدادات
│   │       └── widgets/
│   │           └── login_form.dart                   # فورم تسجيل الدخول
│   │
│   ├── products/                      # ── ميزة المنتجات ──
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── products_remote_datasource.dart
│   │   │   │   ├── products_remote_datasource_impl.dart  # جلب من API
│   │   │   │   ├── products_local_datasource.dart
│   │   │   │   └── products_local_datasource_impl.dart   # Cache محلي
│   │   │   ├── models/
│   │   │   │   └── product_model.dart                    # Model: JSON ↔ Entity
│   │   │   └── repositories/
│   │   │       └── products_repository_impl.dart         # Cache-first strategy
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── product.dart                          # Entity: Product + ProductRating
│   │   │   ├── repositories/
│   │   │   │   └── products_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_products_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── products_cubit.dart                   # تحميل + Pagination
│   │       │   └── products_state.dart                   # الحالات: Loading, Loaded, Empty, Error
│   │       └── pages/
│   │           ├── products_list_page.dart                # شبكة المنتجات + بحث
│   │           ├── product_detail_page.dart               # تفاصيل المنتج
│   │           ├── cart_page.dart                         # صفحة السلة
│   │           ├── favorites_page.dart                    # صفحة المفضلة
│   │           ├── main_shell.dart                        # Bottom Nav Bar + Tab Management
│   │           └── products_shell.dart                    # Wrapper
│   │
│   ├── favorites/                     # ── ميزة المفضلة ──
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── favorites_local_datasource.dart
│   │   │   │   └── favorites_local_datasource_impl.dart  # SharedPreferences
│   │   │   └── repositories/
│   │   │       └── favorites_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── favorites_repository.dart
│   │   │   └── usecases/
│   │   │       └── favorites_usecases.dart               # GetIds, Toggle, IsFavorite
│   │   └── presentation/
│   │       └── cubit/
│   │           ├── favorites_cubit.dart
│   │           └── favorites_state.dart
│   │
│   └── cart/                          # ── ميزة السلة ──
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── cart_local_datasource.dart
│       │   │   └── cart_local_datasource_impl.dart       # SharedPreferences
│       │   └── repositories/
│       │       └── cart_repository_impl.dart
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── cart_repository.dart
│       │   └── usecases/
│       │       └── cart_usecases.dart                    # Get, Add, Remove, UpdateQty
│       └── presentation/
│           └── cubit/
│               ├── cart_cubit.dart
│               └── cart_state.dart                       # items: Map<productId, quantity>
│
├── main.dart                          # نقطة الدخول الافتراضية (prod)
├── main_dev.dart                      # نقطة الدخول لـ dev flavor
└── main_prod.dart                     # نقطة الدخول لـ prod flavor
```

---

## إدارة الحالة (State Management)

التطبيق يستخدم **Cubit** من مكتبة `flutter_bloc` لإدارة كل الحالات:

### AuthCubit
| الحالة | الوصف |
|--------|-------|
| `AuthStateInitial` | الحالة الابتدائية |
| `AuthStateLoading` | جاري تسجيل الدخول أو فحص التوكن |
| `AuthStateAuthenticated(user)` | المستخدم مسجل دخول (يحمل AuthUser) |
| `AuthStateUnauthenticated` | لم يسجل دخول / تم تسجيل الخروج |
| `AuthStateError(message)` | خطأ في تسجيل الدخول |

### ProductsCubit
| الحالة | الوصف |
|--------|-------|
| `ProductsStateInitial` | الحالة الابتدائية |
| `ProductsStateLoading` | جاري تحميل المنتجات |
| `ProductsStateLoaded(products, hasMore, isOffline)` | تم التحميل (مع دعم Pagination و Offline) |
| `ProductsStateEmpty` | لا توجد منتجات |
| `ProductsStateError(message, isOffline)` | خطأ (مع تحديد إذا كان بسبب عدم الاتصال) |

### FavoritesCubit
| الحالة | الوصف |
|--------|-------|
| `FavoritesStateInitial` | الحالة الابتدائية |
| `FavoritesStateLoaded(ids)` | مجموعة IDs المنتجات المفضلة |

### CartCubit
| الحالة | الوصف |
|--------|-------|
| `CartStateInitial` | الحالة الابتدائية |
| `CartStateLoaded(items)` | عناصر السلة: `Map<productId, quantity>` |

**قواعد مهمة:**
- الـ Cubits تستدعي Use Cases فقط (لا تعرف مصدر البيانات)
- لا يوجد Business Logic في الـ Widgets
- `BlocBuilder` مستخدم بشكل محدد لتجنب إعادة البناء غير الضرورية

---

## التقنيات المستخدمة (Tech Stack)

| المكتبة | الاستخدام | الإصدار |
|---------|-----------|---------|
| `flutter_bloc` | إدارة الحالة (Cubit) | ^8.1.6 |
| `equatable` | مقارنة الكائنات (States & Entities) | ^2.0.5 |
| `dio` | HTTP Client مع error mapping | ^5.7.0 |
| `get_it` | Dependency Injection | ^8.0.2 |
| `flutter_secure_storage` | حفظ التوكن بشكل آمن | ^9.2.2 |
| `shared_preferences` | حفظ المفضلة والسلة والـ Cache | ^2.3.3 |
| `connectivity_plus` | فحص حالة الاتصال | ^6.0.5 |
| `cached_network_image` | تخزين الصور مؤقتاً | ^3.4.1 |
| `google_fonts` | خط Inter العصري | ^8.0.1 |

### مكتبات الاختبار

| المكتبة | الاستخدام | الإصدار |
|---------|-----------|---------|
| `flutter_test` | اختبارات Widget | SDK |
| `bloc_test` | اختبار Cubits | ^9.1.7 |
| `mocktail` | إنشاء Mocks | ^1.0.4 |
| `flutter_lints` | Lint rules | ^6.0.0 |

---

## التصميم والواجهة (UI/UX)

### نظام الثيم
- **Material 3** مفعّل مع `ColorScheme.fromSeed`
- دعم **Light / Dark mode** (يتبع إعدادات النظام تلقائياً)
- خط **Google Fonts (Inter)** لطباعة عصرية ونظيفة
- لون أساسي: `#6C5CE7` (Indigo-Violet)

### عناصر التصميم
| العنصر | التفاصيل |
|--------|----------|
| **Bottom Nav Bar** | عائم (floating) مع glassmorphism blur + أنيميشن مخصصة (scale, pill indicator, icon morph) |
| **بطاقات المنتجات** | ظلال ناعمة، صور بخلفية مميزة، زر إضافة للسلة، أنيميشن القلب |
| **شاشة التفاصيل** | SliverAppBar قابل للتوسع، Hero animation، شريط سفلي ثابت |
| **السلة** | Swipe-to-delete، شريط Total، أزرار كمية مصممة |
| **المفضلة** | Swipe-to-remove، بطاقات بظلال ناعمة |
| **البروفايل** | تصميم Settings-style مع أقسام مجمعة وأيقونات ملونة |
| **تسجيل الدخول** | Glassmorphic card، لوجو متحرك، Fade+Slide entrance animation |
| **Splash** | شاشة بداية بلوجو التطبيق |
| **Shimmer Loading** | تأثير pulse أثناء تحميل المنتجات |

### الأنيميشن
- **Hero Transitions**: صور المنتجات بين القائمة والتفاصيل
- **Scale Animation**: ضغط على أيقونات الـ Bottom Nav
- **Pill Indicator**: مؤشر متحرك فوق التاب المختار
- **Animated Heart**: أيقونة المفضلة تتحول بـ Scale Transition
- **Page Transitions**: iOS-style (Cupertino) على كل المنصات
- **Fade + Slide**: شاشة تسجيل الدخول

---

## نظام الـ Flavors

الـ Flavors تسمح بتشغيل نفس التطبيق بإعدادات مختلفة بدون تعديل الكود:

| Flavor | اسم التطبيق | شريط Debug | Base URL |
|--------|-------------|------------|----------|
| **dev** | Technica Dev | يظهر | `https://fakestoreapi.com` |
| **prod** | Technica Task | مخفي | `https://fakestoreapi.com` |

### ملفات الـ Flavors

| الملف | الوظيفة |
|-------|---------|
| `lib/main.dart` | نقطة الدخول الافتراضية (prod) |
| `lib/main_dev.dart` | يشغّل التطبيق بفلافور **dev** |
| `lib/main_prod.dart` | يشغّل التطبيق بفلافور **prod** |
| `lib/core/env/app_env.dart` | تعريف الإعدادات لكل flavor |

### تغيير إعدادات الـ Flavor

كل الإعدادات في ملف واحد `lib/core/env/app_env.dart`:

```dart
static const dev = AppEnvConfig(
  flavor: Flavor.dev,
  baseUrl: 'https://staging-api.example.com',  // سيرفر التطوير
  appName: 'Technica Dev',
  showDebugBanner: true,
);

static const prod = AppEnvConfig(
  flavor: Flavor.prod,
  baseUrl: 'https://api.example.com',          // سيرفر الإنتاج
  appName: 'Technica Task',
  showDebugBanner: false,
);
```

الـ DI (في `injection.dart`) يقرأ `AppEnv.current.baseUrl` ويمرّره لـ `DioClient` تلقائياً.

---

## طريقة التشغيل

### المتطلبات
- Flutter SDK 3.10.8+
- Dart SDK 3.10.8+

### الخطوات

```bash
# 1. استنساخ المشروع
git clone <repo-url>
cd technica_task

# 2. تحميل المكتبات
flutter pub get

# 3. تشغيل التطبيق
flutter run                              # prod (افتراضي)
flutter run -t lib/main_dev.dart         # dev flavor
flutter run -t lib/main_prod.dart        # prod flavor

# 4. تشغيل الاختبارات
flutter test
```

---

## بيانات الديمو

### حساب ديمو محلي (يعمل بدون إنترنت)
| الحقل | القيمة |
|-------|--------|
| اسم المستخدم | `mohamed` |
| كلمة المرور | `0000` |

### حساب Fake Store API
| الحقل | القيمة |
|-------|--------|
| اسم المستخدم | `mor_2314` |
| كلمة المرور | `83r5^_` |

> الحساب المحلي يُنشئ توكن وهمي ويسجل الدخول مباشرة بدون استدعاء API.

---

## الاختبارات (Testing)

المشروع يحتوي على **29 اختبار** تغطي الـ Cubits والـ Repositories:

```
test/
├── features/
│   ├── auth/
│   │   ├── cubit/
│   │   │   └── auth_cubit_test.dart              # اختبارات AuthCubit
│   │   └── repository/
│   │       └── auth_repository_impl_test.dart     # اختبارات AuthRepository
│   ├── cart/
│   │   └── cubit/
│   │       └── cart_cubit_test.dart               # اختبارات CartCubit
│   ├── favorites/
│   │   ├── cubit/
│   │   │   └── favorites_cubit_test.dart          # اختبارات FavoritesCubit
│   │   └── repository/
│   │       └── favorites_repository_impl_test.dart # اختبارات FavoritesRepository
│   └── products/
│       └── cubit/
│           └── products_cubit_test.dart           # اختبارات ProductsCubit
└── widget_test.dart
```

**تشغيل الاختبارات:**

```bash
flutter test              # كل الاختبارات
flutter test test/features/auth/   # اختبارات المصادقة فقط
```

---

## التعامل مع الأخطاء (Error Handling)

التطبيق يستخدم نظام أخطاء مخصص (Custom Exceptions):

| نوع الخطأ | الاستخدام |
|-----------|-----------|
| `ServerException` | أخطاء السيرفر أو الشبكة |
| `AuthException` | فشل تسجيل الدخول (بيانات خاطئة) |
| `OfflineException` | لا يوجد اتصال بالإنترنت |
| `TimeoutException` | انتهاء مهلة الاتصال |
| `CacheException` | بيانات الـ Cache غير صالحة أو مفقودة |

### تدفق الأخطاء

```
API Error → DioClient (error mapping) → Repository → UseCase → Cubit → UI (SnackBar / Error State)
```

- الـ `DioClient` يحوّل أخطاء Dio إلى `AppException`
- الـ Cubit يلتقط الأخطاء ويصدر State مناسبة
- الـ UI يعرض رسالة واضحة مع زر إعادة المحاولة

---

## Dependency Injection

التطبيق يستخدم **GetIt** لحقن التبعيات. كل التسجيلات في ملف واحد `lib/core/di/injection.dart`:

```
Core (SharedPreferences, SecureStorage, DioClient, Connectivity)
  ↓
DataSources (Remote + Local)
  ↓
Repositories
  ↓
UseCases
  ↓
Cubits
```

- **LazySingleton**: للمكونات المشتركة (Repositories, DataSources, UseCases)
- **Factory**: للـ Cubits (نسخة جديدة كل مرة)

---

**Submission**: Flutter Developer – Technical Task  
**Architecture**: Feature-based Clean Architecture with Repository Pattern  
**State Management**: Cubit (flutter_bloc)  
**Tests**: 29 unit tests passing
