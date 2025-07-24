import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _initializeFirebaseMessaging() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      final token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    showLocalNotification(
      title: message.notification?.title ?? 'Blockradar Pulse',
      body: message.notification?.body ?? 'New notification',
      payload: message.data.toString(),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    // Handle notification tap when app is in background
    print('Message clicked: ${message.data}');
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle local notification tap
    print('Local notification tapped: ${response.payload}');
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'blockradar_pulse_channel',
      'Blockradar Pulse Notifications',
      channelDescription: 'Notifications for Blockradar Pulse app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showTransactionNotification({
    required String type,
    required String amount,
    required String token,
    required String status,
  }) async {
    final title = status == 'confirmed'
        ? '✅ Transaction Confirmed'
        : status == 'failed'
        ? '❌ Transaction Failed'
        : '⏳ Transaction Pending';

    final body = '$type of $amount $token';

    await showLocalNotification(
      title: title,
      body: body,
      payload: 'transaction:$type:$status',
    );
  }

  Future<void> showSweepFailedNotification({
    required String amount,
    required String token,
    required String reason,
  }) async {
    await showLocalNotification(
      title: '🚨 Sweep Failed',
      body: 'Failed to sweep $amount $token: $reason',
      payload: 'sweep:failed',
    );
  }

  Future<void> showApiStatusNotification({
    required String service,
    required String status,
  }) async {
    final title = status == 'healthy'
        ? '✅ Service Restored'
        : '⚠️ Service Issue';

    await showLocalNotification(
      title: title,
      body: '$service is now $status',
      payload: 'api_status:$service:$status',
    );
  }

  Future<String?> getFirebaseToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
