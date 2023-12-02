import 'package:flutter/material.dart';

import '/core/core.dart';

class MyCoverScreen extends StatelessWidget {
  final bool gameHasStarted;

  const MyCoverScreen({super.key, required this.gameHasStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0, -0.5),
      child: Text(
        gameHasStarted ? '' : 'T A P  T O  P L A Y',
        style: const TextStyle(color: ColorConst.whiteColor, fontSize: 25),
      ),
    );
  }
}
