import 'package:flutter/material.dart';

class MyBird extends StatefulWidget {
  final double birdY;
  final double birdWidth; // normal double value for width.
  final double birdHeight; // out of 2, 2 being the entire height of the screen
  final String bird;
  const MyBird(
      {super.key,
      required this.birdY,
      required this.birdWidth,
      required this.birdHeight,
      required this.bird});

  @override
  State<MyBird> createState() => _MyBirdState();
}

class _MyBirdState extends State<MyBird> {
  @override
  void didUpdateWidget(MyBird oldWidget) {
    if (oldWidget.bird != widget.bird) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment(0,
            (2 * widget.birdY + widget.birdHeight) / (2 - widget.birdHeight)),
        child: Image.asset(
          widget.bird,
          width: MediaQuery.of(context).size.height * widget.birdWidth / 2,
          height: MediaQuery.of(context).size.height *
              3 /
              4 *
              widget.birdHeight /
              2,
          fit: BoxFit.fill,
        ));
  }
}
