import 'package:awesome_simple_notification_sample/model/notification_manager.dart';
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  final String notificationChannelKey;

  const SecondScreen({
    super.key,
    required this.notificationChannelKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(),
      body: Center(
        child: Text(
          "通知を押したで〜\n${NotificationManager.channelMaps[notificationChannelKey]}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
