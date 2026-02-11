import 'package:equatable/equatable.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AuthUser — كيان المستخدم المصادق (Domain Entity)
// ═══════════════════════════════════════════════════════════════════════════════
//
// العلاقات:
//   • يُستخدم في: AuthRepository (كقيمة مرجعة)، AuthState (AuthStateAuthenticated)،
//     Use Cases، AuthRepositoryImpl.
//   • جزء من طبقة Domain — مستقل عن Flutter وعن أي مصدر بيانات.
//
// الدور: يمثّل المستخدم المسجّل دخوله في التطبيق. حالياً يحتوي على الـ token فقط
//        (لأن Fake Store API يرجع token فقط؛ يمكن لاحقاً إضافة اسم، صورة، إلخ).
//
// Equatable: يُستخدم لمقارنة الحالات في الـ state (مثلاً عند تغيير الـ token)
//            عشان الـ Cubit/Bloc يعرف لو الـ state اتغير فعلاً.
// ═══════════════════════════════════════════════════════════════════════════════

class AuthUser extends Equatable {
  const AuthUser({required this.token});

  /// توكن المصادقة — يُحفظ في FlutterSecureStorage ويُرسل مع الطلبات للمصادقة.
  final String token;

  @override
  List<Object?> get props => [token];
}
