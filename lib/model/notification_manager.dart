import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationManager {

  //TODO 通知を押下した際にHomeScreenとは別の画面を開きたい場合
  // => チュートリアルではNamedRouteを使っているが、static変数を使うやり方に

  static ReceivedNotification? receivedNotificationAction = null;

  static const String channelKeyBasic = "basic";
  static const String channelKeyFullScreen = "full_screen";

  //key: channelKey / value: channelName
  static Map<String, String> channelMaps = {
    channelKeyBasic: "Basic",
    channelKeyFullScreen: "Full Screen",
  };

  /*
  * NotificationContent
  * https://pub.dev/packages/awesome_notifications#notificationcontent-content-in-push-data---required
  * https://pub.dev/documentation/awesome_notifications/latest/awesome_notifications/NotificationContent-class.html
  *
  * Notification Action Types
  * https://pub.dev/packages/awesome_notifications#-notification-action-types
  *
  * Notification's Category
  * https://pub.dev/packages/awesome_notifications#-notification-action-types
  * */
  final notificationContentBasic = NotificationContent(
    //idを変えれば複数のアラームが設定できる
    id: 1,
    channelKey: channelKeyBasic,
    actionType: ActionType.Default,
    title: 'シンプルな通知',
    body: '普通の通知出したで〜',
    category: NotificationCategory.Alarm,
  );

  final notificationContentFullScreen = NotificationContent(
    fullScreenIntent: true,
    //公式のサンプル見たら、これをtrueにしてた => マニフェストファイルで「WAKE_LOCK」パーミッション設定要
    // => これをtrueにすると、通知イベント発生時にアプリが自動で開くようだ
    //https://pub.dev/packages/awesome_notifications#-wake-up-screen-notifications
    wakeUpScreen: true,
    //idを変えれば複数のアラームが設定できる
    id: 2,
    channelKey: channelKeyFullScreen,
    actionType: ActionType.Default,
    title: '全画面通知',
    body: '全画面通知出したで〜',
    category: NotificationCategory.Alarm,
  );

  /*
  * NotificationSchedule
  * https://pub.dev/packages/awesome_notifications#-scheduling-a-notification
  * https://pub.dev/packages/awesome_notifications#schedules
  * */
  NotificationSchedule? schedule;

  /*
  * TODO:awesome_notificationプラグインの初期化
  *  https://pub.dev/packages/awesome_notifications#-how-to-show-local-notifications
  * */
  Future<void> init() async {
    print("NotificationManager#init");
    /*
    * AwesomeNotifications#initialize
    * https://pub.dev/documentation/awesome_notifications/latest/i_awesome_notifications/IAwesomeNotifications/initialize.html
    *
    * Androidの通知設定方法（Android公式）
    * https://developer.android.com/develop/ui/views/notifications?hl=ja#Templates
    * 通知チャンネル
    * https://developer.android.com/develop/ui/views/notifications?hl=ja#ManageChannels
    * NotificationChannel
    * https://pub.dev/packages/awesome_notifications#-notification-channels
    * https://pub.dev/packages/awesome_notifications#notification-channel-attributes
    * */
    AwesomeNotifications().initialize(
      //android用の通知アイコンの設定要（android/app/src/main/res/drawableフォルダ内に）
      'resource://drawable/app_icon',
      [
        //普通の通知
        NotificationChannel(
          channelKey: channelKeyBasic,
          channelName: channelMaps[channelKeyBasic],
          channelDescription: "シンプルな通知",
          importance: NotificationImportance.Max,
        ),
        //全画面インテント（Full Screen Notifications (only for Android)）
        //https://pub.dev/packages/awesome_notifications#-full-screen-notifications-only-for-android
        //https://source.android.com/docs/core/permissions/fsi-limits?hl=ja
        NotificationChannel(
          channelKey: channelKeyFullScreen,
          channelName: channelMaps[channelKeyFullScreen],
          channelDescription: "全画面通知（Androidのみ）",
          importance: NotificationImportance.Max,
        ),
      ],
      //The optional debug parameter enables verbose logging in Awesome Notifications.
      debug: true,
    );

    /*
    * TODO:通知リスナーの設定（staticメソッドにする必要あり：リンク先の手順4）
    *  https://pub.dev/packages/awesome_notifications#-how-to-show-local-notifications
    *  => onActionReceivedMethodのみ必須
    *   https://pub.dev/packages/awesome_notifications#-notification-events
    *   （注）WakeLockの仕組みを使って通知表示と同時にアプリを自動で開きたい場合はonNotificationDisplayedMethod設定要
    * */
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    );

    /*
    * TODO: 通知の許可がない場合は許可をもらう（リンク先の手順6）
    * https://pub.dev/packages/awesome_notifications#-how-to-show-local-notifications
    * */
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        //  => 本当はちゃんとこんな感じで実装したほうがいい
        //  https://pub.dev/packages/awesome_notifications#-requesting-permissions
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    schedule = NotificationInterval(
      //The amount of seconds between each notification repetition. Must be greater than 0 or 60 if repeating.
      interval: Duration(seconds: 5),
      repeats: false,
      preciseAlarm: true,
      timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
      //[android] これをtrueにしておかないとステータスバーにちゃんと通知が出てくれないみたい
      //determines whether the notification will be sent even when the device is in a critical situation, such as low battery.
      //https://pub.dev/documentation/awesome_notifications/latest/awesome_notifications/NotificationSchedule/allowWhileIdle.html
      allowWhileIdle: true,
    );
  }

  /*
  * TODO:通知リスナーの設定（staticメソッドにする必要あり：リンク先の手順5）
  *  https://pub.dev/packages/awesome_notifications#-how-to-show-local-notifications
  *  => onActionReceivedMethodのみ必須
  *   https://pub.dev/packages/awesome_notifications#-notification-events
  * */
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print("[通知をユーザーがクリックしたで〜:onActionReceivedMethod]$receivedAction");

    // 通知押下時にHomeScreenとは別の画面を開きたい場合
    // チュートリアルにはnamedRouteを使う方法が紹介されているが、ちょっとややこしいのでstatic変数を使うやり方にしてみる
    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
    //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
    //iOSの場合はこっちで受けないと駄目みたい（onNotificationDisplayedMethodでは受けてくれない）
    receivedNotificationAction = receivedAction;
  }

  /// Use this method to detect every time that a new notification is displayed
  /// Fires when a notification is displayed on system status bar
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    /*
    * 通知がステータスバーに表示されてもこのコールバック呼ばれない（Android・iOSともに）？？
    * */
    print("[通知が表示されたで〜:onActionReceivedMethod]$receivedNotification");
    receivedNotificationAction = receivedNotification;
  }

  void sendBasicNotification() async {
    //通知の作成（リンク先の手順7）
    //https://pub.dev/packages/awesome_notifications#-how-to-show-local-notifications
    AwesomeNotifications().createNotification(
      content: notificationContentBasic,
      schedule: schedule,
    );
  }

  void sendFullScreenNotification() {
    AwesomeNotifications().createNotification(
      content: notificationContentFullScreen,
      schedule: schedule,
    );
  }

  void clearNotification() {
    receivedNotificationAction = null;
  }
}
