import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _sirenTimer;

  Future<void> initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );
    await _localNotifications.initialize(initSettings);

    const AndroidNotificationChannel normalChannel = AndroidNotificationChannel(
      'normal_alerts',
      'Normal Alerts',
      importance: Importance.high,
    );
    const AndroidNotificationChannel emergencyChannel = AndroidNotificationChannel(
      'emergency_alerts',
      'Emergency Broadcasts',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('emergency_alarm'),
      enableVibration: true,
    );

    final androidPlatform = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlatform?.createNotificationChannel(normalChannel);
    await androidPlatform?.createNotificationChannel(emergencyChannel);
  }

  Future<void> showForegroundNotification(RemoteMessage message) async {
    final isEmergency = _isEmergency(message);
    final title = message.notification?.title ?? 'New Announcement';
    final body = message.notification?.body ?? '';
    final channelId = isEmergency ? 'emergency_alerts' : 'normal_alerts';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      isEmergency ? 'Emergency Broadcasts' : 'Normal Alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: isEmergency ? const RawResourceAndroidNotificationSound('emergency_alarm') : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: isEmergency ? 'emergency_alarm.wav' : null,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      title,
      body,
      details,
    );

    if (isEmergency) {
      final sirenUrl = message.data['sirenUrl']?.toString();
      if (sirenUrl != null && sirenUrl.isNotEmpty) {
        await playSirenFromUrl(sirenUrl);
      }
    }
  }

  Future<void> playSirenFromUrl(String url) async {
    try {
      _sirenTimer?.cancel();
      await _audioPlayer.setSourceUrl(url);
      await _audioPlayer.resume();

      _sirenTimer = Timer(const Duration(seconds: 15), () {
        _audioPlayer.stop();
      });
    } catch (_) {}
  }

  bool _isEmergency(RemoteMessage message) {
    final raw = message.data['isEmergency'];
    if (raw == true) return true;
    if (raw is String && raw.toLowerCase() == 'true') return true;
    if (message.data['type']?.toString() == 'EMERGENCY_BROADCAST') return true;
    return false;
  }
}
