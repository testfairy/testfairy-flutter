import 'dart:async';
import 'dart:core';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:testfairy/testfairy.dart';

class Screenshot {
  int width;
  int height;
  Uint8List pixels;

  Screenshot(this.width, this.height, this.pixels);
}

abstract class TestFairyBase {

  // Method Channel Internals

  static const MethodChannel channel = const MethodChannel('testfairy');
  static bool isMethodCallHandlerSet = false;
  static Function takeScreenshot;

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
      case 'takeScreenshot':
        if (takeScreenshot != null) takeScreenshot();
        break;
      default:
        print('TestFairy: Ignoring invoke from native. This normally shouldn\'t happen.');
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

  static List<Map<String, int>> getHiddenRects() {
    List<Map<String, int>> rects = [];

    hiddenWidgets.forEach((gk) {
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

  static Future<Screenshot> createSingleScreenShot() async {
    var ps = WidgetsBinding.instance.window.physicalSize;
    double width = ps.width;
    double height = ps.height;

    await WidgetsBinding.instance.endOfFrame;

    var rects = getHiddenRects();

    var renderObject = WidgetsBinding.instance.renderViewElement.findRenderObject();
    if (renderObject.owner != null) {
        renderObject.owner
          ..flushLayout()
          ..flushCompositingBits()
          ..flushPaint();
    }

    var screenshot = await WidgetInspectorService.instance.screenshot(
        renderObject,
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

            try {
              byteData.setUint8((fixedJ * width.toInt()) + fixedI, 0);
              byteData.setUint8((fixedJ * width.toInt()) + fixedI + 1, 0);
              byteData.setUint8((fixedJ * width.toInt()) + fixedI + 2, 0);
              byteData.setUint8((fixedJ * width.toInt()) + fixedI + 3, 255);
            } catch (e) {
              // Ignore out of bounds
            }
          }
        }
      }
    });

    return Future.value(
        new Screenshot(width.toInt(), height.toInt(), byteData.buffer.asUint8List())
    );
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