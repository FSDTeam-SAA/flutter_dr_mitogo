import 'dart:async';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxBool _showTimedWidget = false.obs;
  RxBool get showTimedWidget => _showTimedWidget;
  Timer? _timer;
  final RxBool isPostSaved = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      _showTimedWidget.value = true;
      Future.delayed(Duration(seconds: 10), () {
        _showTimedWidget.value = false;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void clean() {
    _timer?.cancel();
  }
}
