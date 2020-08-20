import 'dart:async';
import 'dart:core';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:testfairy/testfairy.dart';

abstract class TestFairyBase {
  // Method Channel Internals

  static const MethodChannel channel = const MethodChannel('testfairy');
  static bool isMethodCallHandlerSet = false;

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

  static List<GlobalKey> hiddenWidgets = [];

  static Future<List<Map<String, int>>> getHiddenRects() async {
    await WidgetsBinding.instance.endOfFrame;

    List<Map<String, int>> rects = [];

    hiddenWidgets.forEach((gk) {
      RenderBox ro = gk.currentContext.findRenderObject();

      var pos = ro.localToGlobal(Offset.zero);
      pos = Offset(pos.dx * ui.window.devicePixelRatio,
          pos.dy * ui.window.devicePixelRatio);
//      print('Position is: ');
//      print(pos.toString());

      var size = gk.currentContext.size;
      size = Size(size.width * ui.window.devicePixelRatio,
          size.height * ui.window.devicePixelRatio);
//      print('Size is: ');
//      print(size.toString());

      rects.add({
        'left': pos.dx.toInt(),
        'top': pos.dy.toInt(),
        'right': pos.dx.toInt() + size.width.toInt(),
        'bottom': pos.dy.toInt() + size.height.toInt()
      });
    });

//    print(rects.toString());

    return Future.value(rects);
  }

  // Feedback options callback mechanism

  static int feedbackOptionsIdCounter = 0;
  static var feedbackOptionsCallbacks = {};

  static void callOnFeedbackSent(Map args) {
    var opts = FeedbackOptions();

    opts.email = args['email'];
    opts.text = args['text'];
    opts.timestamp = args['timestamp'];
    opts.feedbackNo = args['feedbackNo'];

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
    opts.feedbackNo = args['feedbackNo'];

    feedbackOptionsCallbacks[args['callId'].toString()]
        ['onFeedbackFailed'](opts);
  }
}
