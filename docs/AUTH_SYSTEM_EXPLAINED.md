# شرح نظام المصادقة (Auth) — وحدة وحدة

هذا الملف يشرح **نظام الـ Auth بالكامل** في المشروع؛ كل وحدة (Domain، Data، Presentation) والعلاقة بينها، عشان لو اتسألت عنه في مقابلة أو مراجعة تكون جاهز.

---

## 1. نظرة عامة على الـ Auth

- **الوظيفة:** تسجيل الدخول (Login)، تسجيل الخروج (Logout)، والتحقق من وجود مستخدم مسجل (Check Auth) عند فتح التطبيق.
- **التخزين:** الـ token يُحفظ في **FlutterSecureStorage** بمفتاح `auth_token`.
- **الديمو:** `mohamed` / `0000` — تسجيل دخول ناجح **بدون استدعاء API** (للتجربة السريعة).
- **الـ API الحقيقي:** POST `/auth/login` مع `username` و `password` (Fake Store API).

---

## 2. طبقة الـ Domain (Domain Layer)

الـ domain **مستقل** عن Flutter وعن أي مصدر بيانات؛ فيه فقط الكيانات والواجهات والـ use cases.

### 2.1 الكيان (Entity): `AuthUser`

**الملف:** `lib/features/auth/domain/entities/auth_user.dart`

```dart
class AuthUser extends Equatable {
  const AuthUser({required this.token});
  final String token;
  @override
  List<Object?> get props => [token];
}
```

- **الدور:** يمثّل المستخدم المصادق في التطبيق.
- **البيانات:** حالياً فقط `token` (نوع String).
- **Equatable:** عشان المقارنة بين حالات الـ state (مثلاً لو الـ token اتغير).

**أسئلة محتملة:**  
- ليه الـ entity فيها token فقط؟  
  → لأن الـ API (Fake Store) يرجع token فقط؛ لو عندك اسم أو صورة ممكن تضيفهم لاحقاً.

---

### 2.2 واجهة الـ Repository: `AuthRepository`

**الملف:** `lib/features/auth/domain/repositories/auth_repository.dart`

```dart
abstract interface class AuthRepository {
  Future<AuthUser> login({required String email, required String password});
  Future<void> logout();
  Future<AuthUser?> getStoredAuth();
}
```

- **الدور:** عقد (contract) بين الـ domain وبين من ينفّذ المنطق (الـ data layer).
- **العمليات:**
  - `login`: تسجيل دخول → يرجع `AuthUser` أو يرمي استثناء.
  - `logout`: تسجيل خروج (بدون قيمة مرجعة).
  - `getStoredAuth`: يجيب المستخدم المخزّن محلياً إن وُجد، وإلا `null`.

**أسئلة محتملة:**  
- ليه abstract؟  
  → عشان الـ use cases تعتمد على الواجهة فقط، والتنفيذ الفعلي في الـ data layer (سهل الاختبار والاستبدال).

---

### 2.3 Use Cases (حالات الاستخدام)

كل use case مسؤول عن **عملية واحدة** ويستدعي الـ repository فقط.

#### أ) `LoginUseCase`

**الملف:** `lib/features/auth/domain/usecases/login_usecase.dart`

```dart
class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<AuthUser> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}
```

- **الدور:** تنفيذ عملية تسجيل الدخول عبر الـ repository.
- **الاعتماد:** يعتمد فقط على `AuthRepository` (واجهة من الـ domain).

#### ب) `LogoutUseCase`

**الملف:** `lib/features/auth/domain/usecases/logout_usecase.dart`

```dart
class LogoutUseCase {
  LogoutUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}
```

- **الدور:** تنفيذ تسجيل الخروج (مسح الـ token من التخزين المحلي).

#### ج) `CheckAuthUseCase`

**الملف:** `lib/features/auth/domain/usecases/check_auth_usecase.dart`

```dart
class CheckAuthUseCase {
  CheckAuthUseCase(this._repository);
  final AuthRepository _repository;

  Future<AuthUser?> call() => _repository.getStoredAuth();
}
```

- **الدور:** عند فتح التطبيق نتحقق هل فيه مستخدم مسجّل (token محفوظ) أم لا.

**أسئلة محتملة:**  
- ليه منفصلين (3 use cases)؟  
  → Single Responsibility: كل واحد مسؤول عن فعل واحد؛ يسهل الاختبار والتعديل.

---

## 3. طبقة الـ Data (Data Layer)

هنا **التنفيذ الفعلي**: قراءة/كتابة من الشبكة ومن التخزين المحلي، وتجميعهم في الـ repository.

### 3.1 الـ Data Sources (مصادر البيانات)

#### أ) `AuthLocalDataSource` (واجهة)

**الملف:** `lib/features/auth/data/datasources/auth_local_datasource.dart`

```dart
abstract interface class AuthLocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}
```

- **الدور:** عقد للتخزين المحلي للـ token فقط (حفظ، قراءة، مسح).

#### ب) `AuthLocalDataSourceImpl` (تنفيذ)

**الملف:** `lib/features/auth/data/datasources/auth_local_datasource_impl.dart`

- **الأداة:** `FlutterSecureStorage`.
- **المفتاح:** `AppConstants.authTokenKey` = `'auth_token'`.
- **العمليات:**
  - `saveToken` → `_storage.write(key: authTokenKey, value: token)`
  - `getToken` → `_storage.read(key: authTokenKey)`
  - `clearToken` → `_storage.delete(key: authTokenKey)`

**أسئلة محتملة:**  
- ليه Secure Storage مش SharedPreferences؟  
  → الـ token سري؛ FlutterSecureStorage مشفّر ومناسب للمفاتيح الحساسة.

---

#### ج) `AuthRemoteDataSource` (واجهة)

**الملف:** `lib/features/auth/data/datasources/auth_remote_datasource.dart`

```dart
abstract interface class AuthRemoteDataSource {
  Future<String> login({required String username, required String password});
}
```

- **الدور:** عقد لطلب تسجيل الدخول من الـ API (يرجع token كـ String).

#### د) `AuthRemoteDataSourceImpl` (تنفيذ)

**الملف:** `lib/features/auth/data/datasources/auth_remote_datasource_impl.dart`

- **الديمو:** لو `username == 'mohamed'` و `password == '0000'` → يرجع `'demo_token_mohamed'` **بدون أي HTTP request**.
- **غير الديمو:**
  - POST إلى `/auth/login` مع `{ "username": username, "password": password }`.
  - من الـ response نأخذ `token`؛ لو فاضي أو null → `AuthException('Invalid response from server.')`.
  - لو 401 → `AuthException('Invalid email or password.')`.
- **الأداة:** `Dio` (من حقن التبعيات).

**أسئلة محتملة:**  
- ليه الديمو في الـ remote مش في الـ repository؟  
  → يمكن اعتبار الديمو "استجابة وهمية من السيرفر"؛ عملياً ممكن يوضع في repository أو حتى في use case حسب تفضيل الفريق.

---

### 3.2 الـ Repository التنفيذي: `AuthRepositoryImpl`

**الملف:** `lib/features/auth/data/repositories/auth_repository_impl.dart`

- **الاعتماديات:** `AuthRemoteDataSource` و `AuthLocalDataSource`.

**تنفيذ `login`:**
1. التحقق: لو `email` أو `password` فاضيين → `AuthException('Email and password are required.')`.
2. استدعاء `_remote.login(username: email.trim(), password: password)` → نستلم `token`.
3. حفظ الـ token: `_local.saveToken(token)`.
4. إرجاع `AuthUser(token: token)`.

**تنفيذ `logout`:**  
استدعاء `_local.clearToken()` فقط (لا استدعاء API).

**تنفيذ `getStoredAuth`:**  
1. استدعاء `_local.getToken()`.
2. لو الـ token غير null وغير فاضي → `AuthUser(token: token)`، وإلا `null`.

**أسئلة محتملة:**  
- ليه ما نستدعيش API عند الـ logout؟  
  → في هذا التطبيق الـ API لا يطلب إبطال الـ token من السيرفر؛ يكفي مسحه من الجهاز.

---

## 4. طبقة الـ Presentation (واجهة المستخدم)

هنا الـ Cubit (إدارة الحالة) والـ UI (صفحات وويدجتات).

### 4.1 الحالات (States): `AuthState`

**الملف:** `lib/features/auth/presentation/cubit/auth_state.dart`

- **نوع الـ state:** `sealed class AuthState` (كل الحالات معروفة ومحدودة).
- **الحالات:**
  - `AuthStateInitial` — الحالة الابتدائية.
  - `AuthStateLoading` — أثناء التحميل (مثلاً أثناء login أو checkAuth).
  - `AuthStateAuthenticated(user)` — المستخدم مسجّل الدخول (فيه `AuthUser`).
  - `AuthStateUnauthenticated` — لا يوجد مستخدم مسجّل.
  - `AuthStateError(message)` — حدث خطأ (مثلاً بيانات خاطئة).

**أسئلة محتملة:**  
- ليه sealed؟  
  → يسمح بـ exhaustive switch في الـ UI ولا يسمح بحالات غير معرّفة؛ أفضل للـ type safety.

---

### 4.2 الـ Cubit: `AuthCubit`

**الملف:** `lib/features/auth/presentation/cubit/auth_cubit.dart`

- **الاعتماديات:** `LoginUseCase`, `LogoutUseCase`, `CheckAuthUseCase`.
- **الحالة الابتدائية:** `AuthStateInitial`.

**الدوال:**

1. **`checkAuth()`**  
   - يبعث `AuthStateLoading`.  
   - يستدعي `_checkAuth()`.  
   - لو فيه user → `AuthStateAuthenticated(user)`، وإلا `AuthStateUnauthenticated`.

2. **`login(email, password)`**  
   - يبعث `AuthStateLoading`.  
   - يستدعي `_login(email, password)`.  
   - نجاح → `AuthStateAuthenticated(user)`.  
   - لو `AuthException` → `AuthStateError(e.message)`.  
   - أي استثناء تاني → `AuthStateError('Login failed. Please try again.')`.

3. **`logout()`**  
   - يستدعي `_logout()` ثم يبعث `AuthStateUnauthenticated()`.

**أسئلة محتملة:**  
- ليه Cubit مش Bloc؟  
  → Cubit أبسط (استدعاء دوال مباشرة و emit للـ state)؛ الـ Bloc يعتمد على events وربما أوضح عند تعقيد الأحداث.

---

### 4.3 التكامل مع التطبيق (main.dart)

- في `main.dart` يتم إنشاء `AuthCubit` من GetIt واستدعاء `checkAuth()` فوراً:
  - `create: (_) => sl<AuthCubit>()..checkAuth()`
- الـ **home** يتبنى حسب الـ state:
  - `AuthStateInitial` أو `AuthStateLoading` → شاشة **Splash**.
  - `AuthStateAuthenticated` → **ProductsShell** (التابات: Store, Favorites, Cart, Profile).
  - `AuthStateUnauthenticated` أو `AuthStateError` → **LoginPage**.

يعني من أول فتح التطبيق يتم التحقق من الـ token ثم توجيه المستخدم إما للوحة الرئيسية أو لصفحة تسجيل الدخول.

---

### 4.4 الصفحات والويدجتات

#### أ) `LoginPage`

- تعرض واجهة ترحيب + **LoginForm** داخل كارد.
- تستخدم **BlocConsumer** على `AuthCubit`:
  - **listener:** لو الـ state `AuthStateError` → تعرض SnackBar بالرسالة.
  - **builder:** لو `AuthStateLoading` → مؤشر تحميل + "Signing in..."، وإلا تعرض الفورم مع أنيميشن.
- **ملاحظة:** الـ AuthCubit يأتي من الـ BlocProvider في `main.dart` (لا تُغلف الـ LoginPage بـ BlocProvider جديد للـ Auth).

#### ب) `LoginForm`

- حقول: Email/Username و Password (مع إخفاء/إظهار كلمة المرور).
- التحقق: الحقول مطلوبة (required).
- عند الضغط على Sign In: يتحقق من الـ form ثم يستدعي `context.read<AuthCubit>().login(email, password)`.

#### ج) `ProfilePage`

- تعرض بيانات المستخدم (Welcome Back! أو Guest) وإعدادات (مثل Dark Mode).
- زر **Sign Out** يفتح حوار تأكيد؛ عند التأكيد يستدعي `context.read<AuthCubit>().logout()`.
- بعد الـ logout يصبح الـ state `Unauthenticated` فيتم توجيه المستخدم تلقائياً إلى `LoginPage` (من الـ BlocBuilder في main).

---

## 5. حقن التبعيات (DI — GetIt)

**الملف:** `lib/core/di/injection.dart`

- **AuthRemoteDataSource** → singleton → `AuthRemoteDataSourceImpl(Dio)`.
- **AuthLocalDataSource** → singleton → `AuthLocalDataSourceImpl(FlutterSecureStorage)`.
- **AuthRepository** → singleton → `AuthRepositoryImpl(remote, local)`.
- **LoginUseCase**, **LogoutUseCase**, **CheckAuthUseCase** → singleton لكل واحد.
- **AuthCubit** → **factory** (كل مرة يُطلب فيها AuthCubit نأخذ instance جديدة؛ في الواقع في التطبيق الحالي يُنشأ مرة واحدة في main ثم يُستخدم في كل الشاشات).

---

## 6. تدفق البيانات (ملخص سريع)

### فتح التطبيق
1. `main` → إنشاء `AuthCubit` واستدعاء `checkAuth()`.
2. `AuthCubit` → `AuthStateLoading` ثم `CheckAuthUseCase` → `AuthRepository.getStoredAuth()` → `AuthLocalDataSource.getToken()`.
3. لو فيه token → `AuthStateAuthenticated` → ProductsShell.  
   لو لا → `AuthStateUnauthenticated` → LoginPage.

### تسجيل الدخول
1. المستخدم يملأ الحقول ويضغط Sign In.
2. `AuthCubit.login()` → `AuthStateLoading` → `LoginUseCase` → `AuthRepositoryImpl.login()`:
   - التحقق من الحقول ثم `AuthRemoteDataSource.login()` (ديمو أو API).
   - ثم `AuthLocalDataSource.saveToken(token)` ثم إرجاع `AuthUser`.
3. `AuthCubit` يبعث `AuthStateAuthenticated` → الانتقال إلى ProductsShell.

### تسجيل الخروج
1. من Profile → Sign Out → تأكيد.
2. `AuthCubit.logout()` → `LogoutUseCase` → `AuthRepository.logout()` → `AuthLocalDataSource.clearToken()`.
3. `AuthCubit` يبعث `AuthStateUnauthenticated` → الانتقال إلى LoginPage.

---

## 7. الاستثناءات (AuthException)

- معرّفة في `core/errors/app_exceptions.dart` كـ `AuthException extends AppException`.
- تُرمى من:
  - **AuthRepositoryImpl:** "Email and password are required."
  - **AuthRemoteDataSourceImpl:** "Invalid response from server." أو "Invalid email or password."
- الـ **AuthCubit** يلتقط `AuthException` ويعرض الرسالة في الـ state كـ `AuthStateError(message)`، والـ LoginPage تعرضها في SnackBar.

---

هذا الملف يغطي نظام الـ Auth من الـ Entity حتى الـ UI والـ DI؛ يمكنك استخدامه كمرجع عند الإجابة على أسئلة المقابلة أو المراجعة.
