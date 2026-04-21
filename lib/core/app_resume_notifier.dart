import 'package:flutter/foundation.dart';

class AppResumeNotifier extends ChangeNotifier {
  AppResumeNotifier._();

  static final AppResumeNotifier instance = AppResumeNotifier._();

  int _resumeTick = 0;

  int get resumeTick => _resumeTick;

  void notifyResumed() {
    _resumeTick += 1;
    notifyListeners();
  }
}
