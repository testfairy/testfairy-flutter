import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:ui';
import 'package:testfairy/testfairy.dart';
import 'package:http/http.dart' as http;

// App Globals
const String APP_TOKEN = 'SDK-gLeZiE9i';

// Test Globals
List<String> logs = [];
Function onNewLog = () {}; // This will be overridden once the app launches

// Test App initializations (You can copy and edit for your own app)
void main() {
  HttpOverrides.global = TestFairy.httpOverrides();

  runZonedGuarded(
    () async {
      try {
        FlutterError.onError =
            (details) => TestFairy.logError(details.exception);

        // Call `await TestFairy.begin()` or any other setup code here.

        runApp(TestfairyExampleApp());
      } catch (error) {
        TestFairy.logError(error);
      }
    },
        (e, s) {
      TestFairy.logError(e);
    },
    zoneSpecification: new ZoneSpecification(
      print: (self, parent, zone, message) {
        TestFairy.log(message);
      },
    )
  );
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
  GlobalKey hideWidgetKey = GlobalKey();

//  GlobalKey hiddenWidgetKey = GlobalKey(debugLabel: 'hideMe');

  @override
  void initState() {
    super.initState();

    TestFairy.hideWidget(hideWidgetKey);

    onNewLog = () => setState(() {});

    print(
        "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
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
                    key: Key('scroller'),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('-'),
                        testing
                            ? Text('Testing ' + testName, key: Key('testing'))
                            : Text('Not testing', key: Key('notTesting')),
                        Text('-'),
                        Text(errorMessage, key: Key('errorMessage')),
                        Text('-'),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: () => setState(() {
                                  errorMessage = "No error yet.";
                                  logs.clear();
                                  print(
                                      "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
                                }),
                            child: Text('Clear Logs')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onCoolButton,
                            child: Text('Cool Button')),
                        Text('-'),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onLifecycleTests,
                            key: Key('lifecycleTests'),
                            child: Text('Lifecycle Tests')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onServerEndpointTest,
                            key: Key('serverEndpointTest'),
                            child: Text('Server Endpoint Test')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onFeedbackTests,
                            key: Key('feedbackTests'),
                            child: Text('Feedback Tests')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onFeedbackShakeTest,
                            key: Key('feedbackShakeTest'),
                            child: Text('Feedback Shake Tests')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onVersionTest,
                            key: Key('versionTest'),
                            child: Text('Version Test')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onSessionUrlTest,
                            key: Key('sessionUrlTest'),
                            child: Text('Session Url Test')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onAddCheckpointTest,
                            key: Key('addCheckpointTest'),
                            child: Text('Add Checkpoint Test')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onAddEventTest,
                            key: Key('addEventTest'),
                            child: Text('Add Event Test')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onIdentityTests,
                            key: Key('identityTests'),
                            child: Text('Identity Tests')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onLogTests,
                            key: Key('logTests'),
                            child: Text('Log Tests')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onDeveloperOptionsTests,
                            key: Key('developerOptionsTests'),
                            child: Text('Developer Options Tests')),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onFeedbackOptionsTest,
                            key: Key('feedbackOptionsTests'),
                            child: Text('Feedback Options Tests')),
                        Text(
                            "HIDE ME FROM SCREENSHOTS",
                            key: hideWidgetKey
                        ),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onTakeScreenshotTests,
                            key: Key("takeScreenshotTests"),
                            child: Text('Take Screenshot Test')
                        ),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onNetworkLogTests,
                            key: Key("networkLogTests"),
                            child: Text('Network Log Tests')
                        ),
                        FlatButton(
                            color: Color.fromRGBO(0, 100, 100, 1.0),
                            textColor: Color.fromRGBO(255, 255, 255, 1.0),
                            onPressed: onDisableAutoUpdateTests,
                            key: Key("disableAutoUpdateTests"),
                            child: Text('Disable Auto Update Tests')
                        ),
                        Column(children: logs.map((l) => new Text(l)).toList())
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

      testName = "";
    });
  }

  // Call this inside a test if an error occurs
  void setError(error) {
    setState(() {
      errorMessage = error.toString();
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

    beginTest("Cool Button");

    try {
      print("A");
      await TestFairy.begin(APP_TOKEN);
      print("B");
      await Future.delayed(const Duration(seconds: 20));
      print("C");
//      await TestFairy.takeScreenshot();
      print("D");
      await Future.delayed(const Duration(seconds: 2));
      print("E");
      await TestFairy.stop();
      print("F");
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  // Tests

  void onLifecycleTests() async {
    if (testing) return;

    beginTest("Lifecycle");

    try {
      print('Calling begin,pause,resume,stop,begin,stop in this order.');

      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.pause();
      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.resume();
      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.beginWithOptions(APP_TOKEN, {'metrics': 'cpu'});
      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onServerEndpointTest() async {
    if (testing) return;

    beginTest("Server Endpoint");

    try {
      print(
          'Setting dummy server endpoint expecting graceful offline sessions.');
      await TestFairy.setServerEndpoint("http://example.com");
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 1));
      await TestFairy.stop();
      await Future.delayed(const Duration(seconds: 1));
      await TestFairy.setServerEndpoint("https://api.TestFairy.com/services/");
      await Future.delayed(const Duration(seconds: 1));
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 1));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onFeedbackTests() async {
    if (testing) return;

    beginTest("Feedbacks");

    try {
      print('Showing feedback form.');
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.sendUserFeedback("Dummy feedback from Flutter");
      await TestFairy.showFeedbackForm();
      await Future.delayed(const Duration(seconds: 10));
      await TestFairy.bringFlutterToFront();
      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onFeedbackShakeTest() async {
    if (testing) return;

    beginTest("Feedback Shake");

    try {
      await TestFairy.enableFeedbackForm("shake");
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));
      print("Listening shakes for 20 seconds. ");
      print(
          "You can either shake your device manually during this time to open the feedback screen and wait for it to close automatically.");
      print("Or, you can skip this test by simply waiting a little more.");
      await Future.delayed(const Duration(seconds: 20));
      print("No longer listening shakes");
      await TestFairy.disableFeedbackForm();
      await TestFairy.bringFlutterToFront();
      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onVersionTest() async {
    if (testing) return;

    beginTest("Version");

    try {
      await TestFairy.begin(APP_TOKEN);
      var version = await TestFairy.getVersion();

      assert(version != null);

      print("SDK Version: " + version);

      assert(version.split(".").length == 3);

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onSessionUrlTest() async {
    if (testing) return;

    beginTest("Session Url");

    try {
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      var url = await TestFairy.getSessionUrl();

      assert(url != null);

      print("Session Url: " + url);

      assert(url.contains("http"));

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onTakeScreenshotTests() async {
    if (testing) return;

    beginTest("Take Screenshot");

    try {
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      await TestFairy.takeScreenshot();

      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onAddCheckpointTest() async {
    if (testing) return;

    beginTest("Add Checkpoint");

    try {
      print('Adding some checkpoints.');
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      await TestFairy.addCheckpoint("Hello-check-1");
      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.addCheckpoint("Hello-check-2");

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onAddEventTest() async {
    if (testing) return;

    beginTest("Add Event");

    try {
      print('Adding some user events.');
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      await TestFairy.addEvent("Hello-event-1");
      await Future.delayed(const Duration(seconds: 2));
      await TestFairy.addEvent("Hello-event-2");

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onIdentityTests() async {
    if (testing) return;

    beginTest("Identity");

    try {
      print(
          'Setting correlation id and identifying multiple times, expecting graceful failures.');
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      await TestFairy.setCorrelationId("1234567flutter");

      await TestFairy.stop();
      await Future.delayed(const Duration(seconds: 1));

      ///

      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      await TestFairy.identify("1234567flutter");

      await TestFairy.stop();
      await Future.delayed(const Duration(seconds: 1));

      ///

      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      await TestFairy.identifyWithTraits(
          "1234567flutter", {'someTrait': 'helloTrait'});

      await TestFairy.stop();
      await Future.delayed(const Duration(seconds: 1));

      ///

      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      await TestFairy.setUserId("user1");
      await TestFairy.setUserId("user2");
      await TestFairy.setUserId("user3");

      await TestFairy.stop();
      await Future.delayed(const Duration(seconds: 1));

      ///
      print('Setting some attributes and a screen name.');
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      await TestFairy.setScreenName('TestfairyExampleApp-ScreenName');
      await TestFairy.setAttribute('dummyAttr', 'dummyValue');

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onLogTests() async {
    if (testing) return;

    beginTest("Log");

    try {
      print('Logging heavily expecting no visible stutter or crash.');
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      for (var i = 0; i < 1000; i++) {
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
    if (testing) return;

    beginTest("Developer Options");

    try {
      print('Testing crash handlers, metrics and max session length.');
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      print('Last session crashed: ' +
          (await TestFairy.didLastSessionCrash()).toString());

      print('Enable/disable crash handler.');
      await TestFairy.enableCrashHandler();
      await TestFairy.disableCrashHandler();

      print('Enable/disable cpu metric.');
      await TestFairy.enableMetric('cpu');
      await TestFairy.disableMetric('cpu');

      await TestFairy.stop();
      await Future.delayed(const Duration(seconds: 1));

      print(
          'Setting up a short unsupported session length, expecting graceful fallback to default.');
      await TestFairy.setMaxSessionLength(3.0);
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 4));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onFeedbackOptionsTest() async {
    if (testing) return;

    beginTest("Feedback Options");

    try {
      print('Testing feedback popup with custom options and callbacks.');
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      await TestFairy.setFeedbackOptions(onFeedbackSent: (fc) {
        print('onFeedbackSent: ' + fc.toString());
      }, onFeedbackCancelled: () {
        print('onFeedbackCancelled');
      }, onFeedbackFailed: (fc) {
        print('onFeedbackFailed: ' + fc.toString());
      });
      await TestFairy.showFeedbackForm();

      print('Showing the feedback form. Enter some feedback and send/cancel.');
      print('Or wait 20 seconds to skip this test.');
      await Future.delayed(const Duration(seconds: 20));

      await TestFairy.bringFlutterToFront();

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onNetworkLogTests() async {
    if (testing) return;

    beginTest("Network Log Test");

    try {
      print('Testing network calls. Attempting GET to example.com');

      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      var response = await http.get('https://example.com/');
      print(response.toString());

      await Future.delayed(const Duration(seconds: 5));
      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

  void onDisableAutoUpdateTests() async {
    if (testing) return;

    beginTest("Disable Auto Update Test");

    try {
      print('Testing disabled auto update sesssion');

      await TestFairy.disableAutoUpdate();
      await TestFairy.begin(APP_TOKEN);
      await Future.delayed(const Duration(seconds: 2));

      var url = await TestFairy.getSessionUrl();

      assert(url != null);

      print("Session Url: " + url);

      assert(url.contains("http"));

      await TestFairy.stop();
    } catch (e) {
      setError(e);
    }

    endTest();
  }

}
