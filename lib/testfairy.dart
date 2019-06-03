import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
  static bool isMethodCallHandlerSet = false;
  static List<GlobalKey> _hiddenWidgets = [];

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
      case 'getHiddenRects':
        return getHiddenRects();
      case 'lock':
        return lock();
      case 'unlock':
        return unlock();
      case 'takeScreenshot':
        takeScreenshot();
        break;
      default:
        print('TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
    }
  }

  static void prepareTwoWayInvoke() {
    if (!isMethodCallHandlerSet) {
      _channel.setMethodCallHandler(methodCallHandler);
      isMethodCallHandlerSet = true;
    }
  }

  static void lock() {
    GestureBinding.instance.lockEvents((){ return Future.value(null); });
    RendererBinding.instance.lockEvents((){ return Future.value(null); });
    PaintingBinding.instance.lockEvents((){ return Future.value(null); });
    SchedulerBinding.instance.lockEvents((){ return Future.value(null); });
    ServicesBinding.instance.lockEvents((){ return Future.value(null); });
    WidgetsBinding.instance.lockEvents((){ return Future.value(null); });
  }

  static void unlock() {
    GestureBinding.instance.unlocked();
    RendererBinding.instance.unlocked();
    PaintingBinding.instance.unlocked();
    SchedulerBinding.instance.unlocked();
    ServicesBinding.instance.unlocked();
    WidgetsBinding.instance.unlocked();
  }

  static List<Map<String, int>> getHiddenRects() {
    List<Map<String, int>> rects = [];

    _hiddenWidgets.forEach((gk) {
      RenderBox ro = gk.currentContext.findRenderObject();

      var pos = ro.localToGlobal(Offset.zero);
      pos = Offset(pos.dx * ui.window.devicePixelRatio, pos.dy * ui.window.devicePixelRatio);
//      print('Position is: ');
//      print(pos.toString());

      var size = gk.currentContext.size;
      size = Size(size.width * ui.window.devicePixelRatio, size.height * ui.window.devicePixelRatio);
//      print('Size is: ');
//      print(size.toString());

      rects.add({
        'x': pos.dx.toInt(),
        'y': pos.dy.toInt(),
        'w': size.width.toInt(),
        'h': size.height.toInt()
      });
    });

    return rects;
  }

  static Future<void> takeScreenshot() async {
    var ps = WidgetsBinding.instance.window.physicalSize;
    double width = ps.width;
    double height = ps.height;

    await WidgetsBinding.instance.endOfFrame;

    var rects = getHiddenRects();

    var screenshot = await WidgetInspectorService.instance.screenshot(
        WidgetsBinding.instance.renderViewElement.findRenderObject(),
        width: width,
        height: height
    );

    ByteData byteData = await screenshot.toByteData(format: ui.ImageByteFormat.rawRgba);

    rects.forEach((r) {
      var x = r['x'];
      var y = r['y'];
      var w = r['w'];
      var h = r['h'];

//      print("Hidden Rect: " + r.toString());

      if(w > 0 && h > 0) {
        for (var i = x; i < x + w; i++) {
          for (var j = y; j < y + h; j++) {
            var fixedI = math.min(math.max(0, i), width).toInt() * 4;
            var fixedJ = math.min(math.max(0, j), height).toInt() * 4;

            byteData.setUint8((fixedJ * width.toInt()) + fixedI, 0);
            byteData.setUint8((fixedJ * width.toInt()) + fixedI + 1, 0);
            byteData.setUint8((fixedJ * width.toInt()) + fixedI + 2, 0);
            byteData.setUint8((fixedJ * width.toInt()) + fixedI + 3, 0);
          }
        }
      }
    });

    prepareTwoWayInvoke();

    var args = {
      'pixels': byteData.buffer.asUint8List(),
      'width': width.toInt(),
      'height': height.toInt()
    };

    await _channel.invokeMethod('sendScreenshot', args);
  }

  // Public Interface

  static Future<void> begin(String appToken) async {
    prepareTwoWayInvoke();

    await _channel.invokeMethod('begin', appToken);
  }

  static Future<void> beginWithOptions(String appToken, Map options) async {
    prepareTwoWayInvoke();

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

  static Future<void> enableVideo(String policy, String quality, double framesPerSecond) async {
    var args = {
      'policy': policy,
      'quality': quality,
      'framesPerSecond': framesPerSecond
    };

    await _channel.invokeMethod('enableVideo', args);
  }

  static Future<void> disableVideo() async {
    await _channel.invokeMethod('disableVideo');
  }

  static Future<void> enableFeedbackForm(String method) async {
    await _channel.invokeMethod('enableFeedbackForm', method);
  }

  static Future<void> disableFeedbackForm() async {
    await _channel.invokeMethod('disableFeedbackForm');
  }

  static Future<void> setMaxSessionLength(double seconds) async {
    await _channel.invokeMethod('setMaxSessionLength', seconds);
  }

  static void hideWidget(GlobalKey widgetKey) {
    _hiddenWidgets.add(widgetKey);
  }

  static Future<void> bringFlutterToFront() async {
    await _channel.invokeMethod('bringFlutterToFront');
  }

  // Feedback options callback mechanism

  static void testfairyVoid() {}

  static void testfairyFeedbackOptionsVoid(FeedbackOptions feedbackContent) {}

  static int feedbackOptionsIdCounter = 0;
  static var feedbackOptionsCallbacks = {};

  // TODO : implement this on iOS
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

//    print(args['callId'].toString());

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

// TODO : implement the integrations below on both platform
//  addNetworkEvent
////////////////////////////////////////////////////////////

}