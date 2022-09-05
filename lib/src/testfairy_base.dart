// @dart = 2.12
import 'dart:core';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../testfairy_flutter.dart';

abstract class TestFairyBase {
  // Method Channel Internals

  static const MethodChannel channel = MethodChannel('testfairy');
  static bool isMethodCallHandlerSet = false;

  static Future<dynamic> methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'callOnFeedbackSent':
        callOnFeedbackSent(call.arguments as Map<String, dynamic>);
        break;
      case 'callOnFeedbackCancelled':
        callOnFeedbackCancelled(call.arguments as int);
        break;
      case 'callOnFeedbackFailed':
        callOnFeedbackFailed(call.arguments as Map<String, dynamic>);
        break;
      case 'getHiddenRects':
        return await getHiddenRects();
      default:
        print(
            'TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
    }
  }

  static void prepareTwoWayInvoke() {
    if (!isMethodCallHandlerSet) {
      WidgetsFlutterBinding.ensureInitialized();
      channel.setMethodCallHandler(methodCallHandler);
      isMethodCallHandlerSet = true;
    }
  }

  // Screenshot Utils

  static List<GlobalKey> hiddenWidgets = <GlobalKey>[];

  static Map<String, int> getRect(GlobalKey gk) {
    final RenderBox hiddenRenderBox =
        gk.currentContext!.findRenderObject() as RenderBox;

    Offset pos = hiddenRenderBox.localToGlobal(Offset.zero);
    pos = Offset(pos.dx * ui.window.devicePixelRatio,
        pos.dy * ui.window.devicePixelRatio);
    //      print('Position is: ');
    //      print(pos.toString());

    Size size = gk.currentContext!.size!;
    size = Size(size.width * ui.window.devicePixelRatio,
        size.height * ui.window.devicePixelRatio);
    //      print('Size is: ');
    //      print(size.toString());

    final int topPadding = ui.window.padding.top > 0 && Platform.isAndroid
        ? (ui.window.padding.top + kTextTabBarHeight).toInt()
        : 0;

    return <String, int>{
      'left': pos.dx.toInt(),
      'top': pos.dy.toInt() + topPadding,
      'right': pos.dx.toInt() + size.width.toInt(),
      'bottom': pos.dy.toInt() + size.height.toInt() + topPadding
    };
  }

  static Future<List<Map<String, int>>> getHiddenRects() async {
    await WidgetsBinding.instance.endOfFrame;

    final List<Map<String, int>> rects =
        hiddenWidgets.map(getRect).toList(growable: false);
//    print(rects.toString());

    return Future<List<Map<String, int>>>.value(rects);
  }

  // Feedback options callback mechanism

  static int feedbackOptionsIdCounter = 0;
  static Map<String, dynamic> feedbackOptionsCallbacks = <String, dynamic>{};

  static void callOnFeedbackSent(Map<String, dynamic> args) {
    final FeedbackContent opts = FeedbackContent(
        args['email'] as String,
        args['text'] as String,
        args['timestamp'] as double,
        args['feedbackNo'] as int);

//    print(args['callId'].toString());

    feedbackOptionsCallbacks[args['callId'].toString()]['onFeedbackSent'](opts);
  }

  static void callOnFeedbackCancelled(int callId) {
    feedbackOptionsCallbacks[callId.toString()]['onFeedbackCancelled']();
  }

  static void callOnFeedbackFailed(Map<String, dynamic> args) {
    final FeedbackContent opts = FeedbackContent(
        args['email'] as String,
        args['text'] as String,
        args['timestamp'] as double,
        args['feedbackNo'] as int);

    feedbackOptionsCallbacks[args['callId'].toString()]
        ['onFeedbackFailed'](opts);
  }
}
