import 'package:flutter/material.dart';

import '/core/core.dart';

class GameDashboard extends StatelessWidget {
  const GameDashboard({
    super.key,
    required this.score,
    required this.best,
  });

  final int score;
  final int best;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: ColorConst.dashboardColor,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                        color: ColorConst.whiteColor, fontSize: 35),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'S C O R E',
                    style:
                        TextStyle(color: ColorConst.whiteColor, fontSize: 20),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$best',
                    style: const TextStyle(
                        color: ColorConst.whiteColor, fontSize: 35),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    'B E S T',
                    style:
                        TextStyle(color: ColorConst.whiteColor, fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
