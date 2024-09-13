import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationManager {
  //TODO 通知を押下した際にHomeScreenとは別の画面を開きたい場合
  // => チュートリアルではNamedRouteを使っているが、static変数を使うやり方に
  static ReceivedAction? receivedNotification = null;

  static String channelKey = "basic_channel";

  static int id = 1;

  /*
  * TODO:awesome_notificationプラグインの初期化
  *  https://pub.dev/packages/awesome_notifications#-how-to-show-local-notifications
  * */
  Future<void> init() async {
    print("NotificationManager#init");
    /*
    * AwesomeNotifications#initialize
    * https://pub.dev/documentation/awesome_notifications/latest/i_awesome_notifications/IAwesomeNotifications/initialize.html
    * */
    AwesomeNotifications().initialize(
      //android用の通知アイコンの設定要（android/app/src/main/res/drawableフォルダ内に）
      'resource://drawable/app_icon',
      [
        NotificationChannel(
          /*
          * Androidの通知設定方法（Android公式）
          * https://developer.android.com/develop/ui/views/notifications?hl=ja#Templates
          * 通知チャンネル
          * https://developer.android.com/develop/ui/views/notifications?hl=ja#ManageChannels
          * NotificationChannel
          * https://pub.dev/packages/awesome_notifications#-notification-channels
          * https://pub.dev/packages/awesome_notifications#notification-channel-attributes
          * */
          channelKey: channelKey,
          channelName: "Notification",
          channelDescription: "シンプルな通知",
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
    * */
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
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
    print("[通知受診したで〜:onActionReceivedMethod]$receivedAction");
    // Your code goes here

    // 通知押下時にHomeScreenとは別の画面を開きたい場合
    // チュートリアルにはnamedRouteを使う方法が紹介されているが、ちょっとややこしいのでstatic変数を使うやり方にしてみる
    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
    //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
    //iOSの場合はこっちで受けないと駄目みたい（onNotificationDisplayedMethodでは受けてくれない）
    receivedNotification = receivedAction;
  }

  void sendNotification() async {
    //TODO 通知の作成（リンク先の手順7）
    //https://pub.dev/packages/awesome_notifications#-how-to-show-local-notifications
    AwesomeNotifications().createNotification(
      /*
        * NotificationContent
        * https://pub.dev/packages/awesome_notifications#notificationcontent-content-in-push-data---required
        * https://pub.dev/documentation/awesome_notifications/latest/awesome_notifications/NotificationContent-class.html
        * */
      content: NotificationContent(
        //idを変えれば複数のアラームが設定できる！ => 関さんのアプリの場合は不要
        id: 1,
        channelKey: channelKey,
        /*
          * Notification Action Types
          * https://pub.dev/packages/awesome_notifications#-notification-action-types
          * */
        actionType: ActionType.Default,
        title: 'シンプルな通知',
        body: '通知出したで〜',
        /*
          * Notification's Category
          * https://pub.dev/packages/awesome_notifications#-notification-action-types
          * */
        //これがないとAndroidでは通知がステータスバーに表示されないみたい
        category: NotificationCategory.Reminder,
        //category: NotificationCategory.Alarm,
      ),
      /*
      * 一定期間後に通知を出す方法（Scheduling a Notification）
      * https://pub.dev/packages/awesome_notifications#-scheduling-a-notification
      * */
      schedule: NotificationInterval(
        //The amount of seconds between each notification repetition. Must be greater than 0 or 60 if repeating.
        interval: 5,
        repeats: false,
        preciseAlarm: true,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        //TODO[android] これをtrueにしておかないと２回目以降の通知を出してくれない
        //determines whether the notification will be sent even when the device is in a critical situation, such as low battery.
        allowWhileIdle: true,
      ),
    );
  }

  void clearNotification() {
    receivedNotification = null;
  }
}
