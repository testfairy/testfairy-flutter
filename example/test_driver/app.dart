import 'package:flutter_driver/driver_extension.dart';
import '../lib/main.dart' as app;

void main() {
  // This line enables the extension
  enableFlutterDriverExtension();

  print("Driver extension enabled!");

  app.main();
}
