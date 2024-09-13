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
  bool isWaitingNotification = false;

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
        child: (!isWaitingNotification)
            ? ElevatedButton(
                onPressed: () => _sendNotification(),
                child: Text("５秒後にローカル通知を出すで〜"),
              )
            : Text("通知来るの待ってるねん"),
      ),
    );
  }

  void _sendNotification() {
    final vm = context.read<ViewModel>();
    vm.sendNotification();
    setState(() {
      this.isWaitingNotification = true;
    });
  }

  //TODO 通知を押下した際に別の画面を開きたい場合
  void _openSecondScreenWhenNotificationReceived() {
    print("[HomeScreen#_openSecondScreenWhenNotificationReceived]");
    if ((NotificationManager.receivedNotification?.channelKey !=
        NotificationManager.channelKey)) return;
    setState(() {
      this.isWaitingNotification = false;
    });
    //buildメソッド回っている途中なので、
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondScreen()),
    );
    //通知を開いたらValueNotifierをクリア
    final vm = context.read<ViewModel>();
    vm.clearNotification();
  }
}
