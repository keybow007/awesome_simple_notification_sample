import 'package:awesome_simple_notification_sample/model/notification_manager.dart';
import 'package:awesome_simple_notification_sample/view/home_screen.dart';
import 'package:awesome_simple_notification_sample/view_model/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (_) => NotificationManager(),
        ),
        ChangeNotifierProvider(
          create: (context) => ViewModel(
            notificationManager: context.read<NotificationManager>(),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    Future(() {
      //TODO 通知の初期化（通知送信ボタン押す前にやっておく必要あり）
      if (NotificationManager.receivedNotification != null) return;
      final vm = context.read<ViewModel>();
      vm.initNotificationManager();
    });

    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
