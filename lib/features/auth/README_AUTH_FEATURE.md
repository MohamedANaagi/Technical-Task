# فيتشر Auth — خريطة الملفات والعلاقات

## هيكل المجلدات

```
auth/
├── domain/                    # منطق الأعمال (مستقل عن Flutter ومصادر البيانات)
│   ├── entities/
│   │   └── auth_user.dart     # كيان المستخدم (token)
│   ├── repositories/
│   │   └── auth_repository.dart   # واجهة المستودع
│   └── usecases/
│       ├── login_usecase.dart
│       ├── logout_usecase.dart
│       └── check_auth_usecase.dart
├── data/                      # التنفيذ الفعلي (API + تخزين محلي)
│   ├── datasources/
│   │   ├── auth_local_datasource.dart (+ _impl)   # FlutterSecureStorage
│   │   └── auth_remote_datasource.dart (+ _impl)  # Dio /auth/login
│   └── repositories/
│       └── auth_repository_impl.dart   # يجمع remote + local
└── presentation/
    ├── cubit/
    │   ├── auth_state.dart    # الحالات (Initial, Loading, Authenticated, ...)
    │   └── auth_cubit.dart    # checkAuth, login, logout
    ├── pages/
    │   ├── login_page.dart
    │   └── profile_page.dart
    └── widgets/
        └── login_form.dart
```

## تدفق البيانات (من الواجهة للبيانات)

- **فتح التطبيق:**  
  `main` → `AuthCubit.checkAuth()` → `CheckAuthUseCase` → `AuthRepository.getStoredAuth()` → `AuthLocalDataSource.getToken()`  
  → إن وُجد token: `AuthStateAuthenticated` → ProductsShell.  
  → وإلا: `AuthStateUnauthenticated` → LoginPage.

- **تسجيل الدخول:**  
  `LoginForm` → `AuthCubit.login()` → `LoginUseCase` → `AuthRepositoryImpl.login()`  
  → `AuthRemoteDataSource.login()` (ديمو mohamed/0000 أو API)  
  → `AuthLocalDataSource.saveToken(token)` → `AuthUser`  
  → `AuthStateAuthenticated` → ProductsShell.

- **تسجيل الخروج:**  
  `ProfilePage` (Sign Out + تأكيد) → `AuthCubit.logout()` → `LogoutUseCase` → `AuthRepository.logout()`  
  → `AuthLocalDataSource.clearToken()`  
  → `AuthStateUnauthenticated` → LoginPage.

## حقن التبعيات (GetIt)

- `AuthRemoteDataSource` → `AuthRemoteDataSourceImpl(Dio)`
- `AuthLocalDataSource` → `AuthLocalDataSourceImpl(FlutterSecureStorage)`
- `AuthRepository` → `AuthRepositoryImpl(remote, local)`
- `LoginUseCase`, `LogoutUseCase`, `CheckAuthUseCase` → كل واحد يعتمد على `AuthRepository`
- `AuthCubit` → factory يعتمد على الثلاثة use cases (يُنشأ في main ويُستدعى عليه `checkAuth()`).

## ملاحظات

- الديمو: `mohamed` / `0000` — تسجيل ناجح بدون API (في `AuthRemoteDataSourceImpl`).
- الـ token يُحفظ في FlutterSecureStorage بمفتاح `auth_token` (من `AppConstants`).
- الاستثناءات: `AuthException` من `core/errors`؛ الـ Cubit يعرضها في `AuthStateError` والـ LoginPage في SnackBar.
