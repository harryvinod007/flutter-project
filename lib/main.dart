import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core package
import 'firebase_options.dart'; // Import the generated Firebase configuration file
import 'home_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import the notifications package
import 'package:firebase_messaging/firebase_messaging.dart';

// Create an instance of FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  // Ensure that widget binding is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('Foreground Notification: ${message.notification!.title}');
    }
  });
  // Initialize Firebase with the configuration for the current platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await requestNotificationPermissions();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initializeNotifications();

  // Run the app
  runApp(SentinelApp());
}

// Initialize notifications
Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings androidInitializationSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // Use your app icon

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidInitializationSettings,
  );

  // Initialize the plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This will run when a message is received in the background
  print("Background message: ${message.messageId}");
}
class SentinelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentinel',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: HomePage(), // Set the initial screen of your app
    );
  }
}
Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted notification permissions.');
  } else {
    print('User declined or has not granted permissions.');
  }
}

