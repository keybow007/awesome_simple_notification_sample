import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(),
      body: Center(
        child: Text(
          "通知を押した時に開く画面",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
