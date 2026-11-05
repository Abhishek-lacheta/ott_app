import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'app/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark status and navigation bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize service locator & dependencies
  await ServiceLocator.init();

  runApp(const ShortVideoApp());
}
