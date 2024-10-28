import 'dart:io';

import 'package:awesome_simple_notification_sample/model/notification_manager.dart';
import 'package:awesome_simple_notification_sample/view/second_screen.dart';
import 'package:awesome_simple_notification_sample/view_model/view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print("[resumed]アプリがフォアグラウンドになったで〜");
      //アプリ開いている時はresumedでないと通知開いたこと検知できないので
      _openSecondScreenWhenNotificationReceived();
    }
  }

  @override
  Widget build(BuildContext context) {
    print("[HomeScreen#build]");
    //TODO 通知を押下した際に別の画面を開きたい場合
    _openSecondScreenWhenNotificationReceived();

    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _sendBasicNotification(),
            child: Text("５秒後に普通の通知を出すで〜"),
          ),
          if (Platform.isAndroid)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () => _sendFullScreenNotification(),
                child: Text("５秒後に全画面インテント出すで〜"),
              ),
            ),
        ],
      )),
    );
  }

  void _sendBasicNotification() {
    final vm = context.read<ViewModel>();
    vm.sendBasicNotification();
  }

  void _sendFullScreenNotification() {
    final vm = context.read<ViewModel>();
    vm.sendFullScreenNotification();
  }

  //TODO 通知を押下した際に別の画面を開きたい場合
  void _openSecondScreenWhenNotificationReceived() {
    print("[HomeScreen#_openSecondScreenWhenNotificationReceived]");
    final receivedNotification = NotificationManager.receivedNotificationAction;
    if (receivedNotification == null) return;
    //buildメソッド回っている途中なので、
    if (receivedNotification.channelKey == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecondScreen(
          notificationChannelKey: receivedNotification.channelKey!,
        ),
      ),
    );
    //通知を開いたらValueNotifierをクリア
    final vm = context.read<ViewModel>();
    vm.clearNotification();
  }
}
