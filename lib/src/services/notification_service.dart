import 'dart:async';
import 'dart:convert';

import 'package:climapp_cc20262/src/controller/list_city_controller.dart';
import 'package:climapp_cc20262/src/models/weather_forecast_model.dart';
import 'package:climapp_cc20262/src/screens/list_city_screen.dart';
import 'package:climapp_cc20262/src/screens/weather_city_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  static const _channelId = 'climapp_notifications';
  static const _channelName = 'Notificações do Climapp';
  static const _channelDescription = 'Alertas e atualizações do Climapp';

  late final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _initialized = false;
  OverlayEntry? _foregroundPopup;
  Timer? _popupDismissTimer;

  Future<void> showBackgroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'];
    final body = message.notification?.body ?? message.data['body'];
    if ((title is! String || title.isEmpty) &&
        (body is! String || body.isEmpty)) {
      debugPrint(
        'Mensagem FCM de segundo plano sem título ou corpo para exibição.',
      );
      return;
    }

    await _initializeLocalNotifications();
    await _showNotification(
      id: message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch,
      title: title is String && title.isNotEmpty ? title : 'Climapp',
      body: body is String ? body : '',
      payload: jsonEncode(message.data),
    );
  }

  Future<void> initialize() async {
    if (_initialized) return;

    await _initializeLocalNotifications();
    _setupMessageHandlers();
    _initialized = true;

    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      await _onLocalNotificationSelected(
        launchDetails?.notificationResponse?.payload,
      );
    }

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final canReceiveNotifications =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!canReceiveNotifications) {
      debugPrint(
        'Notificações desativadas: autorização '
        '${settings.authorizationStatus}.',
      );
      return;
    }

    try {
      final token = await _fcm.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('Firebase Messaging não retornou um token FCM.');
      } else {
        debugPrint('====================================');
        debugPrint('FCM TOKEN DO DISPOSITIVO: $token');
        debugPrint('====================================');
      }
    } catch (error, stackTrace) {
      debugPrint('Falha ao obter token FCM: $error\n$stackTrace');
    }

    _fcm.onTokenRefresh.listen(
      (_) => debugPrint('Token FCM atualizado.'),
      onError: (Object error) {
        debugPrint('Falha ao atualizar token FCM: $error');
      },
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        unawaited(_onLocalNotificationSelected(response.payload));
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onMessage.listen(
      (message) => unawaited(_showForegroundNotification(message)),
      onError: (Object error) {
        debugPrint('Falha ao receber mensagem FCM: $error');
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleDeepLink,
      onError: (Object error) {
        debugPrint('Falha ao abrir mensagem FCM: $error');
      },
    );

    _fcm
        .getInitialMessage()
        .then((message) {
          if (message != null) _handleDeepLink(message);
        })
        .catchError((Object error) {
          debugPrint('Falha ao consultar mensagem inicial do FCM: $error');
        });
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final dataTitle = message.data['title'];
    final dataBody = message.data['body'];
    final title =
        notification?.title ?? (dataTitle is String ? dataTitle : null);
    final body = notification?.body ?? (dataBody is String ? dataBody : null);

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      debugPrint(
        'Mensagem FCM recebida sem título ou corpo para exibição: '
        '${message.messageId ?? 'sem ID'}.',
      );
      return;
    }

    var overlay = navigatorKey.currentState?.overlay;
    for (var attempt = 0; overlay == null && attempt < 10; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      overlay = navigatorKey.currentState?.overlay;
    }

    if (overlay == null) {
      debugPrint(
        'Não foi possível exibir a notificação no app: '
        'a interface ainda não está pronta.',
      );
      await _showNotification(
        id:
            message.messageId?.hashCode ??
            DateTime.now().millisecondsSinceEpoch,
        title: title ?? 'Climapp',
        body: body ?? '',
        payload: jsonEncode(message.data),
      );
      return;
    }

    _removeForegroundPopup();
    final popup = OverlayEntry(
      builder: (context) => Positioned(
        top: 8,
        left: 12,
        right: 12,
        child: SafeArea(
          bottom: false,
          child: Material(
            color: const Color(0xFF00457D),
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? 'Climapp',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (body != null && body.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar notificação',
                    onPressed: _removeForegroundPopup,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    _foregroundPopup = popup;
    overlay.insert(popup);
    _popupDismissTimer = Timer(const Duration(seconds: 5), () {
      _removeForegroundPopup();
    });
  }

  void _removeForegroundPopup() {
    _popupDismissTimer?.cancel();
    _popupDismissTimer = null;
    _foregroundPopup?.remove();
    _foregroundPopup = null;
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) {
    return _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  Future<void> _onLocalNotificationSelected(String? payload) async {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload);
      if (data is Map<String, dynamic>) {
        _handleDeepLink(RemoteMessage(data: data));
      } else {
        debugPrint('Dados inválidos no payload da notificação.');
      }
    } on FormatException catch (error) {
      debugPrint('Payload de notificação inválido: $error');
    }
  }

  Future<void> _handleDeepLink(RemoteMessage message) async {
    NavigatorState? navigator;
    for (var attempt = 0; attempt < 20; attempt++) {
      navigator = navigatorKey.currentState;
      if (navigator != null) break;
      await Future<void>.delayed(const Duration(milliseconds: 150));
    }

    if (navigator == null || !navigator.mounted) {
      debugPrint('Navegação da notificação não ficou disponível.');
      return;
    }

    final context = navigator.context;
    if (!context.mounted) return;

    final city = message.data['city'];
    if (city is! String || city.trim().isEmpty) {
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const ListCityScreen()),
      );
      return;
    }

    final controller = context.read<ListCityController>();
    for (var attempt = 0; controller.isLoading && attempt < 40; attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    if (!context.mounted || !navigator.mounted) return;

    WeatherForecastModel? matchingCity;
    for (final forecast in controller.allCities) {
      if (forecast.cityName.toLowerCase().contains(city.toLowerCase())) {
        matchingCity = forecast;
        break;
      }
    }

    final forecastToOpen = matchingCity;
    if (forecastToOpen == null) {
      debugPrint(
        'Cidade "$city" da notificação não foi encontrada; '
        'abrindo a lista de cidades.',
      );
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const ListCityScreen()),
      );
      return;
    }

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => WeatherCityScreen(weatherForecastModel: forecastToOpen),
      ),
    );
  }
}
