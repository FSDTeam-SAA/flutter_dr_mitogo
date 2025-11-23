// lib/app/controller/home_scroll_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScrollController extends GetxController {
  final ScrollController scrollController = ScrollController();

  GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void jumpToTop() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  /// THIS IS THE KEY METHOD
  Future<void> triggerRefresh() async {
    if (scrollController.hasClients) {
      await scrollController.animateTo(
        -120, // Go above top to trigger RefreshIndicator
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );

      refreshIndicatorKey?.currentState?.show();
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
