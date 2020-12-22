import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// ignore: avoid_relative_lib_imports
import '../lib/main.dart' as app;

void main() {
  group('Testfairy Plugin Tests', () {
    Finder findByValueKey(String keyName) {
      final ValueKey<String> key = ValueKey<String>(keyName);
      return find.byKey(key);
    }

    final Finder errorTextFinder = findByValueKey('errorMessage');
    final Finder testingFinder = findByValueKey('testing');
    final Finder scrollerFinder = findByValueKey('scroller');

    setUpAll(() async {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    });

    // Helper test builder:
    // 1. Scrolls and finds a button that runs a test case.
    // 2. Before waiting the test to complete, allows you to inject additional logic.
    // 3. Waits for test completion.
    // 4. Asserts failure if error is found.
    void testfairyTest(
        String testName, Finder testButtonFinder, Function testCaseFunction,
        {bool scroll = true}) {
      testWidgets(testName, (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        if (scroll) {
          await tester.scrollUntilVisible(testButtonFinder, 40,
              scrollable: scrollerFinder,
              maxScrolls: 100,
              duration: const Duration(seconds: 10));
        }

        await tester.tap(testButtonFinder);

        await testCaseFunction();

        bool testingFinderStillFinds = tester.any(testingFinder);
        for (int i = 0; i < 10; i++) {
          testingFinderStillFinds = tester.any(testingFinder);

          if (!testingFinderStillFinds) {
            break;
          }

          await Future<void>.delayed(const Duration(seconds: 1));
        }

        expect(testingFinderStillFinds, false);

        tester.element(errorTextFinder);

        final String x =
            (errorTextFinder.evaluate().single.widget as Text).data ??
                'No error yet';
        print('$testName: $x');

        expect(x, 'No error yet.');
      });
    }

    // Helper test builder:
    // 1. Scrolls and finds a button that runs a test case.
    // 2. Waits for test completion.
    // 3. Asserts failure if error is found.
    void testfairyTestSimple(String testName, Finder testButtonFinder,
        {bool scroll = true}) {
      testfairyTest(testName, testButtonFinder, () async {}, scroll: scroll);
    }

    // Test cases (implement a button that starts the test on ui, find and tap it with a finder)
    testfairyTestSimple('Lifecycle Test', findByValueKey('lifecycleTests'),
        scroll: false);
    testfairyTestSimple(
        'Server Endpoint Test', findByValueKey('serverEndpointTest'));
    testfairyTestSimple('Feedback Tests', findByValueKey('feedbackTests'));
    testfairyTestSimple(
        'Feedback Shake Test', findByValueKey('feedbackShakeTest'));
    testfairyTestSimple('Version Test', findByValueKey('versionTest'));
    testfairyTestSimple('Session Url Test', findByValueKey('sessionUrlTest'));
    testfairyTestSimple(
        'Add Checkpoint Test', findByValueKey('addCheckpointTest'));
    testfairyTestSimple('Add Event Test', findByValueKey('addEventTest'));
    testfairyTestSimple('Identity Tests', findByValueKey('identityTests'));
    testfairyTestSimple('Log Tests', findByValueKey('logTests'));
    testfairyTestSimple(
        'Developer Options Tests', findByValueKey('developerOptionsTests'));
    testfairyTestSimple('Network Log Tests', findByValueKey('networkLogTests'));
    testfairyTestSimple(
        'Disable Auto Update Tests', findByValueKey('disableAutoUpdateTests'));
//    testfairyTestSimple('Feedback Options Tests', findByValueKey('feedbackOptionsTests'));
  });
}
