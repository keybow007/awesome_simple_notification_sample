import 'package:awesome_simple_notification_sample/model/notification_manager.dart';
import 'package:flutter/foundation.dart';

class ViewModel extends ChangeNotifier {
  final NotificationManager notificationManager;

  ViewModel({required this.notificationManager});


  void initNotificationManager() {
    notificationManager.init();
  }

  void sendBasicNotification() {
    notificationManager.sendBasicNotification();
    notifyListeners();
  }

  void sendFullScreenNotification() {
    notificationManager.sendFullScreenNotification();
    notifyListeners();
  }

  void clearNotification() {
    notificationManager.clearNotification();
    notifyListeners();
  }
}
