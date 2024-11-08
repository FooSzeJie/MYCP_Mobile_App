import 'package:flutter/material.dart';
import 'dart:async';

class TimerControlWidget extends StatefulWidget {
  final int initialTimeInSeconds;
  final Future<void> Function() onExtend;
  final Future<void> Function() onTerminate;

  const TimerControlWidget({
    Key? key,
    required this.initialTimeInSeconds,
    required this.onExtend,
    required this.onTerminate,
  }) : super(key: key);

  @override
  _TimerControlWidgetState createState() => _TimerControlWidgetState();
}

class _TimerControlWidgetState extends State<TimerControlWidget> {
  late int remainingTime;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.initialTimeInSeconds;
    startCountdown();
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        countdownTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time Remaining',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                formatTime(remainingTime),
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await widget.onExtend(); // Uncomment this line to trigger the onExtend callback
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green[400],
                ),
                child: Text(
                  "Extend",
                  style: TextStyle(fontSize: 20),
                ),
              ),

              SizedBox(width: 10),

              ElevatedButton(
                onPressed: () async {
                  await widget.onTerminate(); // Ensure onTerminate is triggered correctly
                  countdownTimer?.cancel();
                  setState(() {
                    remainingTime = 0; // Reset time to zero on termination
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red[400],
                ),
                child: Text(
                  "Terminate",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
