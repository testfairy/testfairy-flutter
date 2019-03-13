import 'dart:async';

import 'package:flutter/services.dart';
//import 'package:simple_permissions/simple_permissions.dart';

class FeedbackOptions {
  String email;
  String text;
  double timestamp;
  int i = 0;
}

class TestFairy {
  // Private internals

  static const MethodChannel _channel =
      const MethodChannel('testfairy');
  static Timer screenshotTimer;

  static Future<dynamic> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'callOnFeedbackSent':
        callOnFeedbackSent(call.arguments);
        break;
      case 'callOnFeedbackCancelled':
        callOnFeedbackCancelled(call.arguments);
        break;
      case 'callOnFeedbackFailed':
        callOnFeedbackFailed(call.arguments);
        break;
      default:
        print('Ignoring invoke from native. This normally shouldn\'t happen.');
    }
  }

  static void prepareTwoWayInvoke() {
    _channel.setMethodCallHandler(methodCallHandler);
  }

  // Public Interface

  static Future<void> begin(String appToken) async {
    await _channel.invokeMethod('begin', appToken);
  }

  static Future<void> beginWithOptions(String appToken, Map options) async {
    var args = {'appToken': appToken, 'options': options};

    await _channel.invokeMethod('beginWithOptions', args);
  }

  static Future<void> setServerEndpoint(String endpoint) async {
    await _channel.invokeMethod('setServerEndpoint', endpoint);
  }

  static Future<String> getVersion() async {
    return await _channel.invokeMethod('getVersion');
  }

  static Future<void> sendUserFeedback(String feedback) async {
    await _channel.invokeMethod('sendUserFeedback', feedback);
  }

  static Future<void> addCheckpoint(String name) async {
    await _channel.invokeMethod('addCheckpoint', name);
  }

  static Future<void> addEvent(String name) async {
    await _channel.invokeMethod('addEvent', name);
  }

  static Future<void> setCorrelationId(String id) async {
    await _channel.invokeMethod('setCorrelationId', id);
  }

  static Future<void> identifyWithTraits(String id, Map traits) async {
    var args = {'id': id, 'traits': traits};

    await _channel.invokeMethod('identifyWithTraits', args);
  }

  static Future<void> identify(String id) async {
    await _channel.invokeMethod('identify', id);
  }

  static Future<void> setUserId(String id) async {
    await _channel.invokeMethod('setUserId', id);
  }

  static Future<void> setAttribute(String key, String value) async {
    var args = {'key': key, 'value': value};

    await _channel.invokeMethod('setAttribute', args);
  }

  static Future<String> getSessionUrl() async {
    return await _channel.invokeMethod('getSessionUrl');
  }

  static Future<void> showFeedbackForm() async {
    await _channel.invokeMethod('showFeedbackForm');
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

  static Future<void> resume() async {
    await _channel.invokeMethod('resume');
  }

  static Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  static Future<void> logError(dynamic error) async {
    await _channel.invokeMethod('logError', error.toString());
  }

  static Future<void> log(String message) async {
    await _channel.invokeMethod('log', message);
  }

  static Future<void> setScreenName(String name) async {
    await _channel.invokeMethod('setScreenName', name);
  }

  static Future<bool> didLastSessionCrash() async {
    return await _channel.invokeMethod('didLastSessionCrash');
  }

  static Future<void> enableCrashHandler() async {
    await _channel.invokeMethod('enableCrashHandler');
  }

  static Future<void> disableCrashHandler() async {
    await _channel.invokeMethod('disableCrashHandler');
  }

  static Future<void> enableMetric(String metric) async {
    await _channel.invokeMethod('enableMetric', metric);
  }

  static Future<void> disableMetric(String metric) async {
    await _channel.invokeMethod('disableMetric', metric);
  }

  // TODO : fix these on Android
//  static Future<void> enableVideo(String policy, String quality, double framesPerSecond) async {
//    var args = {
//      'policy': policy,
//      'quality': quality,
//      'framesPerSecond': framesPerSecond
//    };
//
//    await _channel.invokeMethod('enableVideo', args);
//  }
//
//  static Future<void> disableVideo() async {
//    await _channel.invokeMethod('disableVideo');
//  }

  static Future<void> enableFeedbackForm(String method) async {
    await _channel.invokeMethod('enableFeedbackForm', method);
  }

  static Future<void> disableFeedbackForm() async {
    await _channel.invokeMethod('disableFeedbackForm');
  }

  static Future<void> setMaxSessionLength(double seconds) async {
    await _channel.invokeMethod('setMaxSessionLength', seconds);
  }

  static Future<void> bringFlutterToFront() async {
    await _channel.invokeMethod('bringFlutterToFront');
  }

  // Feedback options callback mechanism

  static void testfairyVoid() {}

  static void testfairyFeedbackOptionsVoid(FeedbackOptions feedbackContent) {}

  static int feedbackOptionsIdCounter = 0;
  static var feedbackOptionsCallbacks = {};

  static Future<void> setFeedbackOptions(
      {String browserUrl,
      bool emailFieldVisible: true,
      bool emailMandatory: false,
      Function(FeedbackOptions) onFeedbackSent: testfairyFeedbackOptionsVoid,
      Function() onFeedbackCancelled: testfairyVoid,
      Function(FeedbackOptions) onFeedbackFailed:
          testfairyFeedbackOptionsVoid}) async {
    prepareTwoWayInvoke();

    var args = {
      'browserUrl': browserUrl,
      'emailFieldVisible': emailFieldVisible,
      'emailMandatory': emailMandatory,
      'callId': feedbackOptionsIdCounter
    };

    feedbackOptionsCallbacks.putIfAbsent(feedbackOptionsIdCounter.toString(),
        () {
      return {
        'onFeedbackSent': onFeedbackSent,
        'onFeedbackCancelled': onFeedbackCancelled,
        'onFeedbackFailed': onFeedbackFailed
      };
    });

    feedbackOptionsIdCounter++;
    await _channel.invokeMethod('setFeedbackOptions', args);
  }

  static void callOnFeedbackSent(Map args) {
    var opts = FeedbackOptions();

    opts.email = args['email'];
    opts.text = args['text'];
    opts.timestamp = args['timestamp'];
    opts.i = args['i'];

    print(args['callId'].toString());

    feedbackOptionsCallbacks[args['callId'].toString()]['onFeedbackSent'](opts);
  }

  static void callOnFeedbackCancelled(int callId) {
    feedbackOptionsCallbacks[callId.toString()]['onFeedbackCancelled']();
  }

  static void callOnFeedbackFailed(Map args) {
    var opts = FeedbackOptions();

    opts.email = args['email'];
    opts.text = args['text'];
    opts.timestamp = args['timestamp'];
    opts.i = args['i'];

    feedbackOptionsCallbacks[args['callId'].toString()]
        ['onFeedbackFailed'](opts);
  }

// Screenshots

//  static Future<void> takeScreenshot() async {
//    await _channel.invokeMethod('takeScreenshot');
////    PermissionStatus res = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
////
////    if (res == PermissionStatus.authorized) {
////      await _channel.invokeMethod('takeScreenshot');
////    } else {
////      print("Storage permission error on takeScreenshot");
////    }
//  }
//
//  static Future<void> startTakingScreenshots() async {
//    stopTakingScreenshots();
//
//    screenshotTimer = Timer.periodic(Duration(seconds: 1), (_) async {
//      await takeScreenshot();
//    });
//  }
//
//  static Future<void> stopTakingScreenshots() async {
//    if (screenshotTimer != null) {
//      screenshotTimer.cancel();
//      screenshotTimer = null;
//    }
//  }

// TODO : implement the integrations below

//  addNetworkEvent
//
//  hideView

}
