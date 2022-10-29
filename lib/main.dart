import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:near_you/screens/home_screen.dart';
import 'package:near_you/screens/role_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/getting_started_screen.dart';
import './screens/login_screen.dart';
import './screens/signup_screen.dart';
import 'Constants.dart';

Future<void> firebaseCustomPushMessage(RemoteMessage message) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  MyApp.userName = pref.getString(PREF_USER_NAME);
  MyApp.dateNextSurvey = pref.getString(PREF_NEXT_SURVEY_DATE);

  String title = message.data[PUSH_PARAM_TITLE];
  String finalTitle = MyApp.userName != null
      ? title.replaceAll(PUSH_REPLACE_PACIENTE, MyApp.userName!)
      : title;

  finalTitle = MyApp.userName != null
      ? finalTitle.replaceAll(PUSH_REPLACE_MEDICO, MyApp.userName!)
      : finalTitle;

  String? type = message.data[PUSH_PARAM_TYPE];
  if (MyApp.dateNextSurvey != null &&
      type != null &&
      type == PUSH_PARAM_TYPE_SURVEY) {
    DateTime dateNextSurvey =
        DateFormat('dd-MM-yyyy').parse(MyApp.dateNextSurvey!);
    if (DateTime.now().isBefore(dateNextSurvey)) {
      return; // No have been passed 7 days
    }
  }

  AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: 1,
          channelKey: 'basic',
          title: finalTitle,
          body: message.data[PUSH_PARAM_BODY],
          //bigPicture: message.data["image"],
          notificationLayout: NotificationLayout.Default,
          payload: {
        PUSH_PARAM_UNSUBSCRIBE: message.data[PUSH_PARAM_UNSUBSCRIBE] ?? ""
      }));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences pref = await SharedPreferences.getInstance();
  bool showIntroSlide = !pref.containsKey(SHOW_INTRO_SLIDE);
  pref.setString(SHOW_INTRO_SLIDE, SHOW_INTRO_SLIDE);
  MyApp.userName = pref.getString(PREF_USER_NAME);
  MyApp.dateNextSurvey = pref.getString(PREF_NEXT_SURVEY_DATE);

  AwesomeNotifications()
      .actionStream
      .listen((ReceivedNotification receivedNotification) {
    String? consumedTopic =
        receivedNotification.payload![PUSH_PARAM_UNSUBSCRIBE];
    if (consumedTopic != null) {
      FirebaseMessaging.instance.unsubscribeFromTopic(consumedTopic);
    }
  });
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelGroupKey: 'basic_test',
      channelKey: 'basic',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      channelShowBadge: true,
      importance: NotificationImportance.High,
    )
  ]);
  // subscribe firebase message on topic
  if (MyApp.dateNextSurvey != null) {
    FirebaseMessaging.instance.subscribeToTopic(MyApp.dateNextSurvey!);
  }
  FirebaseMessaging.instance.subscribeToTopic(PUSH_TOPIC_ALL);
  FirebaseMessaging.onBackgroundMessage(firebaseCustomPushMessage);
  FirebaseMessaging.onMessage.listen(firebaseCustomPushMessage);

  runApp(MyApp(showIntroSlide));
}

class MyApp extends StatelessWidget {
  final bool showIntro;
  static String? userName;
  static String? dateNextSurvey;

  const MyApp(this.showIntro, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Near you',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: getHome(showIntro),
      routes: {
        HomeScreen.routeName: (ctx) => HomeScreen(),
        GettingStartedScreen.routeName: (ctx) => GettingStartedScreen(),
        LoginScreen.routeName: (ctx) => const LoginScreen(),
        SignupScreen.routeName: (ctx) => SignupScreen(),
        RoleSelectionScreen.routeName: (ctx) => RoleSelectionScreen(),
      },
    );
  }

  getHome(bool showIntro) {
    if (showIntro) {
      return GettingStartedScreen();
    } else if (FirebaseAuth.instance.currentUser == null) {
      return const LoginScreen();
    }
    return HomeScreen();
  }
}
