// @dart = 2.18
import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:testfairy_flutter/testfairy_flutter.dart';

// App Globals
const String APP_TOKEN = 'SDK-gLeZiE9i';

// Test Globals
List<String> logs = <String>[];
Function onNewLog = () {}; // This will be overridden once the app launches

// Test App initializations (You can copy and edit for your own app)
void main() {
  HttpOverrides.global = TestFairy.httpOverrides();

  runZonedGuarded(() async {
    try {
      FlutterError.onError = (FlutterErrorDetails? details) =>
          TestFairy.logError(details?.exception ?? 'Unknown error');

      // Call `await TestFairy.begin()` or any other setup code here.
//      await TestFairy.setMaxSessionLength(60);
//      await TestFairy.begin(APP_TOKEN);
//      await TestFairy.installFeedbackHandler(APP_TOKEN);

//      runApp(TestfairyExampleApp());
      runApp(TestFairyGestureDetector(child: TestfairyExampleApp()));
    } catch (error) {
      TestFairy.logError(error);
    }
  }, (Object e, StackTrace s) {
    TestFairy.logError(e);
  }, zoneSpecification: ZoneSpecification(
    print: (Zone self, ZoneDelegate parent, Zone zone, String message) {
      TestFairy.log(message);
    },
  ));
}

///////////////////////////////////////////////////////////////////////////////////////
// Add these lines to ZoneSpecification.print if you want to test this project properly
//parent.print(zone, message);
//logs.add(message);
//onNewLog();
///////////////////////////////////////////////////////////////////////////////////////

// Test App
class TestfairyExampleApp extends StatefulWidget {
  @override
  _TestfairyExampleAppState createState() => _TestfairyExampleAppState();
}

// Test App State
class _TestfairyExampleAppState extends State<TestfairyExampleApp> {
  String errorMessage = 'No error yet.';
  String testName = '';
  bool testing = false;

  GlobalKey hiddenWidgetKey = GlobalKey();
  // GlobalKey hiddenWidgetKey = GlobalKey(debugLabel: 'hideMe');

  @override
  void initState() {
    super.initState();

    TestFairy.hideWidget(hiddenWidgetKey);

    onNewLog = () => setState(() {});

    print(
        '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  }

  @override
  Widget build(BuildContext context) {
    // Some debug info and a bunch of buttons, each running a test case.
    return MaterialApp(
        showPerformanceOverlay: true,
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Testfairy Plugin Example App'),
            ),
            body: Center(
                child: SingleChildScrollView(
                    key: const Key('scroller'),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('-'),
                        testing
                            ? Text('Testing ' + testName,
                                key: const Key('testing'))
                            : const Text('Not testing', key: Key('notTesting')),
                        const Text('-'),
                        Text(errorMessage, key: const Key('errorMessage')),
                        const Text('-'),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: () => setState(() {
                                  errorMessage = 'No error yet.';
                                  logs.clear();
                                  print(
                                      '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');

                                  Future<void>.delayed(
                                      const Duration(seconds: 5), () async {
                                    print(await TestFairy.getSessionUrl());
                                  });
                                }),
                            key: const Key('clear_logs'),
                            child: const Text('Clear Logs')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onCoolButton,
                            child: const Text('Cool Button')),
                        const Text('-'),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onLifecycleTests,
                            key: const Key('lifecycleTests'),
                            child: const Text('Lifecycle Tests')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onServerEndpointTest,
                            key: const Key('serverEndpointTest'),
                            child: const Text('Server Endpoint Test')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onFeedbackTests,
                            key: const Key('feedbackTests'),
                            child: const Text('Feedback Tests')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onFeedbackShakeTest,
                            key: const Key('feedbackShakeTest'),
                            child: const Text('Feedback Shake Tests')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onVersionTest,
                            key: const Key('versionTest'),
                            child: const Text('Version Test')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onSessionUrlTest,
                            key: const Key('sessionUrlTest'),
                            child: const Text('Session Url Test')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onAddCheckpointTest,
                            key: const Key('addCheckpointTest'),
                            child: const Text('Add Checkpoint Test')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onAddEventTest,
                            key: const Key('addEventTest'),
                            child: const Text('Add Event Test')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onIdentityTests,
                            key: const Key('identityTests'),
                            child: const Text('Identity Tests')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onLogTests,
                            key: const Key('logTests'),
                            child: const Text('Log Tests')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onDeveloperOptionsTests,
                            key: const Key('developerOptionsTests'),
                            child: const Text('Developer Options Tests')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onFeedbackOptionsTest,
                            key: const Key('feedbackOptionsTests'),
                            child: const Text('Feedback Options Tests')),
                        Text('HIDE ME FROM SCREENSHOTS', key: hiddenWidgetKey),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onNetworkLogTests,
                            key: const Key('networkLogTests'),
                            child: const Text('Network Log Tests')),
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(0, 100, 100, 1.0),
                                primary:
                                    const Color.fromRGBO(255, 255, 255, 1.0)),
                            onPressed: onDisableAutoUpdateTests,
                            key: const Key('disableAutoUpdateTests'),
                            child: const Text('Disable Auto Update Tests')),
                        Column(
                            children: logs.map((String l) => Text(l)).toList())
                      ],
                    )))));
  }

  // Must call this before you begin a test
  void beginTest(String name) {
    setState(() {
      testing = true;
      testName = name;

      print('Testing ' + name);
    });
  }

  // Must call this after you end a test
  void endTest() {
    setState(() {
      testing = false;

      print('Done ' + testName);

      testName = '';
    });
  }

  // Call this inside a test if an error occurs
  void setError(dynamic error) {
    setState(() {
      errorMessage = error != null ? error.toString() : 'Unknown error';
      print(errorMessage);
    });

    void stopSDK() async {
      try {
        await TestFairy.stop();
      } catch (e) {
        print(e);
      }
    }

    stopSDK();
  }

  void onCoolButton() async {
    if (testing) {
      print('already testing');
      return;
    }

    beginTest('Cool Button');

    try {
      print('A');
      await TestFairy.begin(APP_TOKEN);
      print('B');
      await Future<void>.delayed(const Duration(seconds: 20));
      print('C');

      // Test stuff here

      print('D');
      await Future<void>.delayed(const Duration(seconds: 2));
      print('E');
      await TestFairy.stop();
      print('F');
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  // Tests

  void onLifecycleTests() async {
    if (testing) {
      return;
    }

    beginTest('Lifecycle');

    try {
      print('Calling begin,pause,resume,stop,begin,stop in this order.');

      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.pause();
      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.resume();
      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.beginWithOptions(
          APP_TOKEN, <String, dynamic>{'metrics': 'cpu'});
      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onServerEndpointTest() async {
    if (testing) {
      return;
    }

    beginTest('Server Endpoint');

    try {
      print(
          'Setting dummy server endpoint expecting graceful offline sessions.');
      await TestFairy.setServerEndpoint('http://example.com');
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 1));
      await TestFairy.stop();
      await Future<void>.delayed(const Duration(seconds: 1));
      await TestFairy.setServerEndpoint('https://api.TestFairy.com/services/');
      await Future<void>.delayed(const Duration(seconds: 1));
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 1));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onFeedbackTests() async {
    if (testing) {
      return;
    }

    beginTest('Feedbacks');

    try {
      print('Showing feedback form.');
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.sendUserFeedback('Dummy feedback from Flutter');
      await TestFairy.showFeedbackForm();
      await Future<void>.delayed(const Duration(seconds: 10));
      await TestFairy.bringFlutterToFront();
      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onFeedbackShakeTest() async {
    if (testing) {
      return;
    }

    beginTest('Feedback Shake');

    try {
      await TestFairy.enableFeedbackForm('shake');
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));
      print('Listening shakes for 20 seconds. ');
      print(
          'You can either shake your device manually during this time to open the feedback screen and wait for it to close automatically.');
      print('Or, you can skip this test by simply waiting a little more.');
      await Future<void>.delayed(const Duration(seconds: 20));
      print('No longer listening shakes');
      await TestFairy.disableFeedbackForm();
      await TestFairy.bringFlutterToFront();
      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onVersionTest() async {
    if (testing) {
      return;
    }

    beginTest('Version');

    try {
      await TestFairy.begin(APP_TOKEN);
      final String version = await TestFairy.getVersion();

      print('SDK Version: ' + version);

      assert(version.split('.').length == 3);

      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onSessionUrlTest() async {
    if (testing) {
      return;
    }

    beginTest('Session Url');

    try {
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      final String? url = await TestFairy.getSessionUrl();

      assert(url != null);

      print('Session Url: ' + (url ?? 'null'));

      assert(url!.contains('http'));

      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onAddCheckpointTest() async {
    if (testing) {
      return;
    }

    beginTest('Add Checkpoint');

    try {
      print('Adding some checkpoints.');
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      await TestFairy.addCheckpoint('Hello-check-1');
      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.addCheckpoint('Hello-check-2');

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onAddEventTest() async {
    if (testing) {
      return;
    }

    beginTest('Add Event');

    try {
      print('Adding some user events.');
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      await TestFairy.addEvent('Hello-event-1');
      await Future<void>.delayed(const Duration(seconds: 2));
      await TestFairy.addEvent('Hello-event-2');

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onIdentityTests() async {
    if (testing) {
      return;
    }

    beginTest('Identity');

    try {
      print(
          'Setting correlation id and identifying multiple times, expecting graceful failures.');
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      await TestFairy.setCorrelationId('1234567flutter');

      await TestFairy.stop();
      await Future<void>.delayed(const Duration(seconds: 1));

      ///

      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      await TestFairy.identify('1234567flutter');

      await TestFairy.stop();
      await Future<void>.delayed(const Duration(seconds: 1));

      ///

      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      await TestFairy.identifyWithTraits(
          '1234567flutter', <String, dynamic>{'someTrait': 'helloTrait'});

      await TestFairy.stop();
      await Future<void>.delayed(const Duration(seconds: 1));

      ///

      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      await TestFairy.setUserId('user1');
      await TestFairy.setUserId('user2');
      await TestFairy.setUserId('user3');

      await TestFairy.stop();
      await Future<void>.delayed(const Duration(seconds: 1));

      ///
      print('Setting some attributes and a screen name.');
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      await TestFairy.setScreenName('TestfairyExampleApp-ScreenName');
      await TestFairy.setAttribute('dummyAttr', 'dummyValue');

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onLogTests() async {
    if (testing) {
      return;
    }

    beginTest('Log');

    try {
      print('Logging heavily expecting no visible stutter or crash.');
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      for (int i = 0; i < 1000; i++) {
        await TestFairy.log(i.toString());
      }

      print('Logging some dummy error.');

      await TestFairy.logError(AssertionError('No worries'));

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onDeveloperOptionsTests() async {
    if (testing) {
      return;
    }

    beginTest('Developer Options');

    try {
      print('Testing crash handlers, metrics and max session length.');
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      print('Last session crashed: ' +
          (await TestFairy.didLastSessionCrash()).toString());

      print('Enable/disable crash handler.');
      await TestFairy.enableCrashHandler();
      await TestFairy.disableCrashHandler();

      print('Enable/disable cpu metric.');
      await TestFairy.enableMetric('cpu');
      await TestFairy.disableMetric('cpu');

      await TestFairy.stop();
      await Future<void>.delayed(const Duration(seconds: 1));

      print(
          'Setting up a short unsupported session length, expecting graceful fallback to default.');
      await TestFairy.setMaxSessionLength(3.0);
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 4));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onFeedbackOptionsTest() async {
    if (testing) {
      return;
    }

    beginTest('Feedback Options');

    try {
      print('Testing feedback popup with custom options and callbacks.');
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      final List<FeedbackFormField> fields = <FeedbackFormField>[
        StringFeedbackFormField('fullname', 'Your name', ''),
        TextAreaFeedbackFormField('bio', 'Bio', 'Tell us about yourself'),
        SelectFeedbackFormField(
            'country',
            'Country',
            <String, String>{'Turkey': '+90', 'Canada': '+1', 'Israel': '+972'},
            'Canada')
      ];

      await TestFairy.setFeedbackOptions(
          feedbackFormFields: fields,
          onFeedbackSent: (FeedbackContent fc) {
            print('onFeedbackSent: ' + fc.toString());
          },
          onFeedbackCancelled: () {
            print('onFeedbackCancelled');
          },
          onFeedbackFailed: (FeedbackContent fc) {
            print('onFeedbackFailed: ' + fc.toString());
          });
      await TestFairy.showFeedbackForm();

      print('Showing the feedback form. Enter some feedback and send/cancel.');
      print('Or wait 20 seconds to skip this test.');
      await Future<void>.delayed(const Duration(seconds: 20));

      await TestFairy.bringFlutterToFront();

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onNetworkLogTests() async {
    if (testing) {
      return;
    }

    beginTest('Network Log Test');

    try {
      print('Testing network calls. Attempting GET to example.com');

      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      final Uri uri = Uri(path: 'https://example.com/');
      final http.Response response = await http.get(uri);
      print(response.toString());

      await Future<void>.delayed(const Duration(seconds: 5));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onDisableAutoUpdateTests() async {
    if (testing) {
      return;
    }

    beginTest('Disable Auto Update Test');

    try {
      print('Testing disabled auto update sesssion');

      await TestFairy.disableAutoUpdate();
      await TestFairy.begin(APP_TOKEN);
      await Future<void>.delayed(const Duration(seconds: 2));

      final String? url = await TestFairy.getSessionUrl();

      assert(url != null);

      print('Session Url: ' + (url ?? 'null'));

      assert(url!.contains('http'));

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }
}
