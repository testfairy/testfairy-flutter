library testfairy;

import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'src/network_logging.dart';
import 'src/testfairy_base.dart';

part 'package:testfairy/src/feedback_options.dart';

/// This is the main entry point to TestFairy integration in Flutter.
///
/// An example usage can be found below.
///
/// ```dart
/// HttpOverrides.runWithHttpOverrides(
///      () async {
///        try {
///          // Enables widget error logging
///          FlutterError.onError =
///              (details) => TestFairy.logError(details.exception);
///
///          // Initializes a session
///          await TestFairy.begin(TOKEN);
///
///          // Runs your app
///          runApp(TestfairyExampleApp());
///        } catch (error) {
///
///          // Logs synchronous errors
///          TestFairy.logError(error);
///        }
///      },
///
///      // Logs network events
///      TestFairy.httpOverrides(),
///
///      // Logs asynchronous errors
///      onError: TestFairy.logError,
///
///      // Logs console messages
///      zoneSpecification: new ZoneSpecification(
///        print: (self, parent, zone, message) {
///          TestFairy.log(message);
///        },
///      )
///  );
/// ```
abstract class TestFairy extends TestFairyBase {

  /// Initialize a TestFairy session.
  static Future<void> begin(String appToken) async {
    TestFairyBase.takeScreenshot = TestFairy.takeScreenshot;
    TestFairyBase.prepareTwoWayInvoke();

    await TestFairyBase.channel.invokeMethod('begin', appToken);
  }

  /// Initialize a TestFairy session with fine grained options.
  ///
  /// Specify [options] as a [Map] controlling the current session
  /// "metrics": comma separated string of default metric options such as “cpu,memory,network-requests,shake,video,logs”
  /// "enableCrashReporter": [true] / [false] to enable crash handling. Default is true.
  static Future<void> beginWithOptions(String appToken, Map options) async {
    TestFairyBase.prepareTwoWayInvoke();

    var args = {
      'appToken': appToken,
      'options': options
    };

    await TestFairyBase.channel.invokeMethod('beginWithOptions', args);
  }

  /// Override the server endpoint address for using with on-premise installations
  /// and private cloud configuration.
  ///
  /// Please contact support for more information about these products.
  static Future<void> setServerEndpoint(String endpoint) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('setServerEndpoint', endpoint);
  }

  /// Returns SDK version (x.x.x)
  static Future<String> getVersion() async {
    TestFairyBase.prepareTwoWayInvoke();
    return await TestFairyBase.channel.invokeMethod('getVersion');
  }

  /// Send a feedback on behalf of the user.
  ///
  /// Call when using a in-house feedback screen with a custom design and feel.
  /// Feedback will be associated with the current session.
  static Future<void> sendUserFeedback(String feedback) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('sendUserFeedback', feedback);
  }

  /// Deprecated backward compatibility wrapper for [addEvent].
  /// Use [addEvent] unless really necessary.
  static Future<void> addCheckpoint(String name) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('addCheckpoint', name);
  }

  /// Marks an event in session. Use this text to tag a session with an event name.
  ///
  /// Later, you can filter sessions for users passed through this checkpoint,
  /// to better understand what your users experienced.
  static Future<void> addEvent(String name) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('addEvent', name);
  }

  /// Deprecated backward compability wrapper for [setUserId].
  /// Use [setUserId] unless really necessary.
  ///
  /// Sets a correlation identifier for this session. This value can be looked up via web dashboard.
  /// For example, setting correlation to the value of the user-id after they logged in.
  /// Can be called only once per session. Subsequent calls will be ignored.
  static Future<void> setCorrelationId(String id) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('setCorrelationId', id);
  }

  /// Deprecated backward compability wrapper for [setUserId] and [setAttribute].
  /// Use those unless really necessary.
  ///
  /// Sets a correlation identifier for this session. This value can be looked up via web dashboard.
  /// For example, setting correlation to the value of the user-id after they logged in.
  /// Can be called only once per session. Subsequent calls will be ignored.
  static Future<void> identifyWithTraits(String id, Map traits) async {
    var args = {'id': id, 'traits': traits};

    await TestFairyBase.channel.invokeMethod('identifyWithTraits', args);
  }

  /// Deprecated backward compability wrapper for [setUserId].
  /// Use [setUserId] unless really necessary.
  ///
  /// Sets a correlation identifier for this session. This value can be looked up via web dashboard.
  /// For example, setting correlation to the value of the user-id after they logged in.
  /// Can be called only once per session. Subsequent calls will be ignored.
  static Future<void> identify(String id) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('identify', id);
  }

  /// Use this to tell TestFairy who the user is.
  ///	It will help you to search the specific user in the TestFairy dashboard.
  ///
  /// We recommend passing values such as email, phone number, or user id that your app may use.
  static Future<void> setUserId(String id) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('setUserId', id);
  }

  /// Records an attribute that will be added to the session.
  ///
  /// NOTE: The SDK limits you to storing 64 attribute keys. Adding more than 64 will fail and return false.
  static Future<void> setAttribute(String key, String value) async {
    TestFairyBase.prepareTwoWayInvoke();

    var args = {
      'key': key,
      'value': value
    };

    await TestFairyBase.channel.invokeMethod('setAttribute', args);
  }

  /// Returns the address of the recorded session on TestFairy’s developer portal.
  /// Will return null if recording not yet started.
  static Future<String> getSessionUrl() async {
    TestFairyBase.prepareTwoWayInvoke();
    return await TestFairyBase.channel.invokeMethod('getSessionUrl');
  }

  /// Displays the feedback activity or view controller depending on your platform.
  /// Must be called after begin.
  ///
  /// Allows users to provide feedback about the current session.
  /// All feedbacks will appear in your build report page, and in the recorded session page.
  static Future<void> showFeedbackForm() async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('showFeedbackForm');
  }

  /// Stops the current session recording. Unlike 'pause', when
  /// calling 'resume', a new session will be created and will be
  /// linked to the previous recording. Useful if you want short
  /// session recordings of specific use-cases of the app. Hidden
  /// views and user identity will be applied to the new session
  /// as well, if started.
  static Future<void> stop() async {
    TestFairyBase.prepareTwoWayInvoke();
    TestFairyBase.takeScreenshot = null;

    await TestFairyBase.channel.invokeMethod('stop');
  }

  /// Resumes the recording of the current session.
  ///
  /// This method resumes a session after it was paused. Has no effect if already resumed.
  static Future<void> resume() async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('resume');
  }

  /// Pauses the current session.
  ///
  /// This method stops recoding of the current session until resume has been called.
  /// Has no effect if already paused.
  static Future<void> pause() async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('pause');
  }

  /// Send a VERBOSE [Error] or [Exception] to TestFairy.
  static Future<void> logError(dynamic error) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('logError', error.toString());
  }

  /// Send a VERBOSE log message  to TestFairy.
  static Future<void> log(String message) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('log', message);
  }

  /// Set a custom name for the current screen. Useful for applications that don't use more than one
  ///	activity or view controller.
  ///
  ///	This name is displayed for a given screenshot, and will override the name of the current screen.
  static Future<void> setScreenName(String name) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('setScreenName', name);
  }

  /// Indicates in runtime whether your last session was crashed.
  static Future<bool> didLastSessionCrash() async {
    TestFairyBase.prepareTwoWayInvoke();
    return await TestFairyBase.channel.invokeMethod('didLastSessionCrash');
  }

  /// Enables the ability to capture crashes.
  /// Must be called before begin.
  ///
  /// TestFairy crash handler is installed by default. Once installed
  /// it cannot be uninstalled.
  static Future<void> enableCrashHandler() async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('enableCrashHandler');
  }

  /// Disables the ability to capture crashes.
  /// Must be called before begin.
  ///
  /// TestFairy crash handler is installed by default. Once installed
  /// it cannot be uninstalled.
  static Future<void> disableCrashHandler() async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('disableCrashHandler');
  }

  /// Enables recording of a metric regardless of build settings.
  /// Must be called be before begin.
  ///
  /// Valid values include "cpu", "memory", "logcat", "battery", "network-requests"
  ///	A metric cannot be enabled and disabled at the same time, therefore
  /// if a metric is also disabled, the last call to enable to disable wins.
  static Future<void> enableMetric(String metric) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('enableMetric', metric);
  }

  /// Disables recording of a metric regardless of build settings.
  /// Must be called be before begin.
  ///
  /// Valid values include “cpu”, “memory”, “logcat”, “battery”, “network-requests”
  /// A metric cannot be enabled and disabled at the same time, therefore
  /// if a metric is also disabled, the last call to enable to disable wins.
  static Future<void> disableMetric(String metric) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('disableMetric', metric);
  }

  /// Enables the ability to capture video recording regardless of build settings.
  ///
  /// Valid values for policy include “always” and “wifi”.
  /// Valid values for quality include “high”, “low”, “medium”.
  /// Values for fps must be between 0.1 and 2.0. Value will be rounded to the nearest frame.
  static Future<void> enableVideo(String policy, String quality, double framesPerSecond) async {
    TestFairyBase.prepareTwoWayInvoke();

    var args = {
      'policy': policy,
      'quality': quality,
      'framesPerSecond': framesPerSecond
    };

    await TestFairyBase.channel.invokeMethod('enableVideo', args);
  }

  /// Disables the ability to capture video recording.
  /// Must be called before begin.
  static Future<void> disableVideo() async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('disableVideo');
  }

  /// Enables the ability to present the feedback form based on the method given.
  /// Must be called before begin.
  ///
  /// Valid values include “shake”, “screenshot” or “shake|screenshot”.
  /// If an unrecognized method is passed, the value defined in the build
  /// settings will be used.
  static Future<void> enableFeedbackForm(String method) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('enableFeedbackForm', method);
  }

  /// Disables the ability to present users with feedback when devices is shaken,
  /// or if a screenshot is taken.
  /// Must be called before begin.
  static Future<void> disableFeedbackForm() async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('disableFeedbackForm');
  }

  /// Sets the maximum recording time.
  /// Must be called before begin.
  ///
  /// Minimum value is 60 seconds, else the value defined in the build settings will be used.
  /// The maximum value is the lowest value between this value and the value defined in the build settings.
  /// Time is rounded to the nearest minute.
  static Future<void> setMaxSessionLength(double seconds) async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('setMaxSessionLength', seconds);
  }

  /// Hides a specific view from appearing in the video generated.
  ///
  /// Provide the same [GlobalKey] you specify in your widget's [key] attribute.
  static void hideWidget(GlobalKey widgetKey) {
    TestFairyBase.prepareTwoWayInvoke();

    TestFairyBase.hiddenWidgets.add(widgetKey);
  }

  /// Takes a screenshot and sends it to TestFairy.
  /// Must be called after begin.
  static Future<void> takeScreenshot() async {
    TestFairyBase.prepareTwoWayInvoke();

    var screenshot = await TestFairyBase.createSingleScreenShot();

    TestFairyBase.prepareTwoWayInvoke();

    var args = {
      'pixels': screenshot.pixels,
      'width': screenshot.width,
      'height': screenshot.height
    };

    await TestFairyBase.channel.invokeMethod('sendScreenshot', args);
  }

  /// Call this function to log your network events.
  /// See [httpOverrides] to automatically do this for all your http calls.
  static Future<void> addNetworkEvent(
      String uri,
      String method,
      int code,
      int startTimeMillis,
      int endTimeMillis,
      int requestSize,
      int responseSize,
      String errorMessage
      ) async {
    TestFairyBase.prepareTwoWayInvoke();

    var args = {
      'uri': uri,
      'method': method,
      'code': code,
      'startTimeMillis': startTimeMillis,
      'endTimeMillis': endTimeMillis,
      'requestSize': requestSize,
      'responseSize': responseSize,
      'errorMessage': errorMessage,
    };

    await TestFairyBase.channel.invokeMethod('addNetworkEvent', args);
  }

  /// Brings Flutter activity or view controller to front.
  /// Can be used for testing native plugins.
  static Future<void> bringFlutterToFront() async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('bringFlutterToFront');
  }

  /// Customizes the feedback form.
  static Future<void> setFeedbackOptions({
      String browserUrl,
      bool emailFieldVisible: true,
      bool emailMandatory: false,
      Function(FeedbackOptions) onFeedbackSent: EmptyFeedbackOptionsFunction,
      Function() onFeedbackCancelled: EmptyFunction,
      Function(FeedbackOptions) onFeedbackFailed:
      EmptyFeedbackOptionsFunction
  }) async { // TODO : implement this on iOS
    TestFairyBase.prepareTwoWayInvoke();

    var args = {
      'browserUrl': browserUrl,
      'emailFieldVisible': emailFieldVisible,
      'emailMandatory': emailMandatory,
      'callId': TestFairyBase.feedbackOptionsIdCounter
    };

    var ifAbsent = () {
      return {
        'onFeedbackSent': onFeedbackSent,
        'onFeedbackCancelled': onFeedbackCancelled,
        'onFeedbackFailed': onFeedbackFailed
      };
    };

    TestFairyBase.feedbackOptionsCallbacks.putIfAbsent(
      TestFairyBase.feedbackOptionsIdCounter.toString(),
      ifAbsent
    );

    TestFairyBase.feedbackOptionsIdCounter++;

    await TestFairyBase.channel.invokeMethod('setFeedbackOptions', args);
  }

  /// Disables auto update prompts for current session.
  static Future<void> disableAutoUpdate() async {
    TestFairyBase.prepareTwoWayInvoke();
    await TestFairyBase.channel.invokeMethod('disableAutoUpdate');
  }

  /// Creates necessary overrides to be used with [HttpOverrides.runWithHttpOverrides].
  /// Use this if you need to log all your http requests by default.
  ///
  /// An example usage can be found below.
  ///
  /// ```dart
  /// HttpOverrides.runWithHttpOverrides(
  ///      () async {
  ///          // Call `await TestFairy.begin()` or any other setup code here.
  ///
  ///          runApp(ExampleApp());
  ///      },
  ///      TestFairy.httpOverrides()
  ///  );
  /// ```
  static HttpOverrides httpOverrides() {
    TestFairyBase.prepareTwoWayInvoke();
    return new TestFairyHttpOverrides();
  }
}
