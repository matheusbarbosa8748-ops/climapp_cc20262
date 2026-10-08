import 'dart:async';

import 'package:climapp_cc20262/src/controller/list_city_controller.dart';
import 'package:climapp_cc20262/src/screens/location_screen.dart';
import 'package:climapp_cc20262/src/services/device_info_service.dart';
import 'package:climapp_cc20262/src/services/location_service.dart';
import 'package:climapp_cc20262/src/services/notification_service.dart';
import 'package:climapp_cc20262/src/services/weather_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (message.notification == null) {
      await NotificationService().showBackgroundNotification(message);
    }
  } catch (error, stackTrace) {
    debugPrint(
      'Falha ao processar notificação em segundo plano: '
      '$error\n$stackTrace',
    );
  }
  debugPrint("Background Handler ID: ${message.messageId}");
}

Future<void> _initializeNotifications(NotificationService service) async {
  try {
    await service.initialize();
  } catch (error, stackTrace) {
    debugPrint('Falha ao inicializar notificações: $error\n$stackTrace');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    firebaseInitialized = true;
  } catch (error, stackTrace) {
    debugPrint(
      'Firebase indisponível; o Climapp será iniciado sem push: '
      '$error\n$stackTrace',
    );
  }

  runApp(const MyApp());
  if (firebaseInitialized) {
    unawaited(_initializeNotifications(NotificationService()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();

    return MultiProvider(
      providers: [
        Provider<WeatherService>(create: (_) => WeatherService()),
        Provider<LocationService>.value(value: locationService),
        Provider<DeviceInfoService>(create: (_) => DeviceInfoService()),
        ChangeNotifierProvider(
          create: (context) => ListCityController(
            weatherService: context.read<WeatherService>(),
            deviceInfoService: context.read<DeviceInfoService>(),
          )..loadCities(),
        ),
      ],
      child: MaterialApp(
        title: 'Climapp',
        navigatorKey: NotificationService().navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          textTheme: GoogleFonts.montserratTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: LocationScreen(locationService: locationService),
      ),
    );
  }
}
