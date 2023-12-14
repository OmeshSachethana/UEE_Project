// timer.dart
import 'dart:async';

class AuctionTimer {
  Duration remainingTime = Duration.zero;
  Timer? _timer;
  bool _timerStarted = false;
  StreamController<Duration> timerStreamController =
      StreamController<Duration>();

  AuctionTimer();

  void startTimer(int timerSeconds, Function setState, bool mounted) {
    DateTime endTime = DateTime.now().add(Duration(seconds: timerSeconds));

    if (endTime.isAfter(DateTime.now()) && mounted) {
      remainingTime = endTime.difference(DateTime.now());
      timerStreamController.add(remainingTime);
    }

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (endTime.isAfter(DateTime.now()) && mounted) {
        setState(() {
          remainingTime = endTime.difference(DateTime.now());
          timerStreamController.add(remainingTime);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void dispose() {
    _timer?.cancel(); // Cancel the timer if it's not null
    timerStreamController.close(); // Close the stream controller
  }
}
