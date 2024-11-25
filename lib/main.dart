import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignalPage(),
    );
  }
}

class SignalPage extends StatefulWidget {
  @override
  _SignalPageState createState() => _SignalPageState();
}

class _SignalPageState extends State<SignalPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int _remainingTimeInSeconds = 7200; // 2 hours in seconds
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _schedulePeriodicSignal();
    _startCountdownTimer();
  }

  // Инициализация уведомлений
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Планирование сигнала каждые 2 часа
  Future<void> _schedulePeriodicSignal() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'periodic_signal',
      'Periodic Signal',
      channelDescription: 'Plays a signal every 2 hours',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    Timer.periodic(const Duration(hours: 2), (timer) async {
      // Запуск сигнала
      await _playSound();

      // Отправка уведомления
      await _notificationsPlugin.show(
        0,
        'Напоминание',
        'Сработал сигнал!',
        platformChannelSpecifics,
      );
    });
  }

  // Проигрывание звука
  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('audio/signal.mp3'));
    await Future.delayed(
        const Duration(seconds: 15)); // Звук проигрывается 10 секунд
    await _audioPlayer.stop();
  }

  // Таймер для отсчета времени до следующего сигнала
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeInSeconds > 0) {
        setState(() {
          _remainingTimeInSeconds--;
        });
      } else {
        _remainingTimeInSeconds = 7200; // сброс на 2 часа
      }
    });
  }

  // Отображение оставшегося времени
  String get _formattedTime {
    int hours = _remainingTimeInSeconds ~/ 3600;
    int minutes = (_remainingTimeInSeconds % 3600) ~/ 60;
    int seconds = _remainingTimeInSeconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Periodic Signal App'),
      ),
      body: Stack(
        children: [
          // Фоновое изображение
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Контент поверх фона
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Приложение работает в фоне, сигнал каждые 2 часа',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'До следующего сигнала: $_formattedTime',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }
}
