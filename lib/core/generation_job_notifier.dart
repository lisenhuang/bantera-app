import 'package:flutter/foundation.dart';

class GenerationJobNotifier extends ChangeNotifier {
  GenerationJobNotifier._();

  static final GenerationJobNotifier instance = GenerationJobNotifier._();

  String? _jobId;
  String? _status;

  String? get jobId => _jobId;
  String? get status => _status;
  bool get hasProcessingJob => _jobId != null && _status == 'processing';

  void start(String jobId) {
    if (_jobId == jobId && _status == 'processing') return;
    _jobId = jobId;
    _status = 'processing';
    notifyListeners();
  }

  void updateStatus(String status) {
    if (_jobId == null) return;
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }

  void clear() {
    if (_jobId == null && _status == null) return;
    _jobId = null;
    _status = null;
    notifyListeners();
  }
}
