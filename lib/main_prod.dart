import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/env/app_env.dart';
import 'main.dart' as app;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  AppEnv.init(Flavor.prod);
  await app.bootstrap();
}
