import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/app.dart';
import 'package:Cinemate/config/firebase_api.dart';
import 'package:Cinemate/config/firebase_options.dart';
import 'package:Cinemate/features/auth/presentation/cubits/navbar_cubit.dart';
import 'package:Cinemate/themes/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/home_widget_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await WidgetHelper.updateWidgetFromFirebase();
 /* final prefs = await SharedPreferences.getInstance();
  final enabled = prefs.getBool('notifications_enabled') ?? true;
  if (enabled) {
    await FirebaseApi().initNotifications();
  }*/

  //runApp(const MyApp());
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, 
      builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => NavBarCubit()),
      ],
      child: MyApp(),
    ), // Wrap your app
    ),
  );
}
