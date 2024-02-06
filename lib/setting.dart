import 'package:flutter/foundation.dart' show ChangeNotifier;

class Setting extends ChangeNotifier {
  Future<void> init() async {
    notifyListeners();
  }
}
