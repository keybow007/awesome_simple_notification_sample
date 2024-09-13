import 'package:awesome_simple_notification_sample/model/notification_manager.dart';
import 'package:flutter/foundation.dart';

class ViewModel extends ChangeNotifier {
  final NotificationManager notificationManager;


  ViewModel({required this.notificationManager});

  void initNotificationManager() {
    notificationManager.init();
  }

  void sendNotification() {
    notificationManager.sendNotification();
  }

  void clearNotification() {
    notificationManager.clearNotification();
  }


}