import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/app.dart';
import 'package:Cinemate/config/firebase_api.dart';
import 'package:Cinemate/features/auth/presentation/cubits/navbar_cubit.dart';
import 'package:Cinemate/themes/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/home_widget_helper.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission();
  await Supabase.initialize(
    url: 'https://cxapsitiyvbcoxtailjk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4YXBzaXRpeXZiY294dGFpbGprIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5ODkwMTUsImV4cCI6MjA2MzU2NTAxNX0.UMgVPg-BUT6hxFALHJW-fQ7goI0zdCBe8ie33v4SKrY',
  );
  //await WidgetHelper.updateWidgetFromFirebase();
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
