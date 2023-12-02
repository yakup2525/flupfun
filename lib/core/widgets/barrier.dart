import 'package:flutter/material.dart';

import '/core/core.dart';

class MyBarrier extends StatelessWidget {
  final double barrierWidth; // out of 2, where 2 is the width of the screen
  final double barrierHeight; // proportion of the screenheight
  final double barrierX;
  final bool isThisBottomBarrier;

  const MyBarrier(
      {super.key,
      required this.barrierHeight,
      required this.barrierWidth,
      required this.isThisBottomBarrier,
      required this.barrierX});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment((2 * barrierX + barrierWidth) / (2 - barrierWidth),
          isThisBottomBarrier ? 1 : -1),
      child: Container(
        color: ColorConst.barrierColor,
        width: MediaQuery.of(context).size.width * barrierWidth / 2,
        height: MediaQuery.of(context).size.height * 3 / 4 * barrierHeight / 2,
      ),
    );
  }
}
