import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Testfairy Plugin Tests', () {
    var cleanUp = () {};
    var drive = () async {
      var error = new StateError("FlutterDriver is not ready yet!");
      throw error;

      return await FlutterDriver
          .connect(); // Here for type inference (dart1-dart2 compatible syntax hack)
    };

    final timeout = Duration(seconds: 120);
    final errorTextFinder = find.byValueKey('errorMessage');
    final testingFinder = find.byValueKey('testing');
    final scrollerFinder = find.byValueKey('scroller');

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      print("3 !");
      FlutterDriver driver = await FlutterDriver.connect();
      print("2 !");
      await driver.waitUntilFirstFrameRasterized();
      print("1 !");

      cleanUp = () {
        driver.close();

        cleanUp = () {};

        drive = () async {
          var error = new StateError("FlutterDriver is released!");
          throw error;

          return await FlutterDriver
              .connect(); // Here for type inference (dart1-dart2 compatible syntax hack)
        };
      };

      drive = () async {
        return driver;
      };
    });

    // Close the connection to the driver after the tests have completed
    tearDownAll(() async {
      cleanUp();
    });

    // Helper test builder:
    // 1. Scrolls and finds a button that runs a test case.
    // 2. Before waiting the test to complete, allows you to inject additional logic.
    // 3. Waits for test completion.
    // 4. Asserts failure if error is found.
    void testfairyTest(String testName, SerializableFinder testButtonFinder,
        Function testCaseFunction,
        {bool scroll = true}) {
      test(testName, () async {
        final driver = await drive();

        if (scroll) {
          await driver.scrollUntilVisible(scrollerFinder, testButtonFinder,
              alignment: 0.5, timeout: Duration(seconds: 10));
        }

        await driver.tap(testButtonFinder, timeout: timeout);

        await testCaseFunction();

        await driver.waitForAbsent(testingFinder, timeout: timeout);
        var x = await driver.getText(errorTextFinder);
        print("$testName: $x");

        expect(x, 'No error yet.');
      });
    }

    // Helper test builder:
    // 1. Scrolls and finds a button that runs a test case.
    // 2. Waits for test completion.
    // 3. Asserts failure if error is found.
    void testfairyTestSimple(
        String testName, SerializableFinder testButtonFinder,
        {bool scroll = true}) {
      testfairyTest(testName, testButtonFinder, () async {}, scroll: scroll);
    }

    // Test cases (implement a button that starts the test on ui, find and tap it with a finder)
    testfairyTestSimple('Lifecycle Test', find.byValueKey('lifecycleTests'),
        scroll: false);
    testfairyTestSimple(
        'Server Endpoint Test', find.byValueKey('serverEndpointTest'));
    testfairyTestSimple('Feedback Tests', find.byValueKey('feedbackTests'));
    testfairyTestSimple(
        'Feedback Shake Test', find.byValueKey('feedbackShakeTest'));
    testfairyTestSimple('Version Test', find.byValueKey('versionTest'));
    testfairyTestSimple('Session Url Test', find.byValueKey('sessionUrlTest'));
    testfairyTestSimple(
        'Add Checkpoint Test', find.byValueKey('addCheckpointTest'));
    testfairyTestSimple('Add Event Test', find.byValueKey('addEventTest'));
    testfairyTestSimple('Identity Tests', find.byValueKey('identityTests'));
    testfairyTestSimple('Log Tests', find.byValueKey('logTests'));
    testfairyTestSimple(
        'Developer Options Tests', find.byValueKey('developerOptionsTests'));
    testfairyTestSimple(
        'Network Log Tests', find.byValueKey('networkLogTests'));
    testfairyTestSimple(
        'Disable Auto Update Tests', find.byValueKey('disableAutoUpdateTests'));
//    testfairyTestSimple('Feedback Options Tests', find.byValueKey('feedbackOptionsTests'));
  });
}
