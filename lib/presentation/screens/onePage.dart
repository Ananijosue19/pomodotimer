import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class Onepage extends StatelessWidget {
  const Onepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            spacing: 30,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 20,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(onPressed: () {}, child: Text('Focus')),
                  Text('Session'),
                ],
              ),
              CircularCountDownTimer(
                width: 200,
                height: 200,
                duration: 25,
                fillColor: Colors.red,
                ringColor: Colors.green,
                autoStart: true,
                isReverse: true,
              ),
              Row(
                spacing: 18,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(child: Icon(Remix.reset_right_line)),
                  CircleAvatar(child: Icon(Remix.play_fill), radius: 30),
                  CircleAvatar(child: Icon(Remix.arrow_right_s_line)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Twopage extends StatelessWidget {
  const Twopage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ThreePage extends StatelessWidget {
  const ThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
