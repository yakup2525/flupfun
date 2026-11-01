import 'package:flutter/material.dart';

class MyCoverScreen extends StatelessWidget {
  final bool gameHasStarted;
  const MyCoverScreen({super.key, required this.gameHasStarted});
  @override
  Widget build(BuildContext context) {
    if (gameHasStarted) return const SizedBox.shrink();
    return const Align(
      alignment: Alignment(0, -0.65),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'FLUP FUN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 34,
              letterSpacing: 4,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Find your flight rhythm',
            style: TextStyle(color: Color(0xFF9DF1DE), fontSize: 17),
          ),
          SizedBox(height: 24),
          Text(
            'Tap to fly',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }
}
