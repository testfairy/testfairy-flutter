// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Testfairy Plugin Tests', () {
    Null Function() cleanUp = () {};
    Future<FlutterDriver> Function() drive = () async {
      final StateError error = StateError('FlutterDriver is not ready yet!');
      throw error;
    };

    const Duration timeout = Duration(seconds: 120);
    final SerializableFinder errorTextFinder = find.byValueKey('errorMessage');
    final SerializableFinder testingFinder = find.byValueKey('testing');
    final SerializableFinder scrollerFinder = find.byValueKey('scroller');

    // Connect to the Flutter driver before running any tests
    setUpAll(() async {
      print('3 !');
      final FlutterDriver driver = await FlutterDriver.connect();
      print('2 !');
      await driver.waitUntilFirstFrameRasterized();
      print('1 !');

      cleanUp = () {
        driver.close();

        cleanUp = () {};

        drive = () async {
          final StateError error = StateError('FlutterDriver is released!');
          throw error;
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
        final FlutterDriver driver = await drive();

        if (scroll) {
          await driver.scrollUntilVisible(scrollerFinder, testButtonFinder,
              alignment: 0.5, timeout: const Duration(seconds: 10));
        }

        await driver.tap(testButtonFinder, timeout: timeout);

        await testCaseFunction();

        await driver.waitForAbsent(testingFinder, timeout: timeout);
        final String x = await driver.getText(errorTextFinder);
        print('$testName: $x');

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
