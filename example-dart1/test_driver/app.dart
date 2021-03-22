import 'package:flutter_driver/driver_extension.dart';
// ignore: avoid_relative_lib_imports
import '../lib/main.dart' as app;

void main() {
  // This line enables the extension
  enableFlutterDriverExtension();

  print('Driver extension enabled!');

  app.main();
}
