import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '/ui/ui.dart';
import '../../services/monetization_service.dart';
import '../settings/settings_page.dart';
import '/core/core.dart';

//
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Timer? _gameTimer;
  Timer? _pointTimer;
  bool _paused = false;
  bool _dead = false;
  bool _restarting = false;
  // bird variables
  static double birdY = 0;
  double initialPos = birdY;
  double height = 0;
  double time = 0;
  double gravity = -3; // how strong the gravity is
  double velocity = 2.5; // how strong the jump is
  double birdWidth = 0.1; // out of 2, 2 being the entire width of the screen
  double birdHeight = 0.1; // out of 2, 2 being the entire height of the screen
  int score = 0;
  int best = 0;
  // game settings
  bool gameHasStarted = false;
  bool scorePermission = false;
  // barrier variables
  static List<double> barrierX = [2, 2 + 1.5];
  static double barrierWidth = 0.5; // out of 2
  List<List<double>> barrierHeight = [
    // out of 2, where 2 is the entire height of the screen
    // [topHeight, bottomHeight]
    [0.6, 0.4],
    [0.4, 0.6],
  ];
  final player = AudioPlayer();
  final player2 = AudioPlayer();

  final player3 = AudioPlayer();
  final playerPoint = AudioPlayer();
  final playerDeath = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    readScore();
  }

  final String boxName = 'scores';

  Future<void> saveScore(int score) async {
    final box = await Hive.openBox<int>(boxName);
    await box.put('score', score);
  }

  Future<void> readScore() async {
    final box = await Hive.openBox<int>(boxName);
    best = box.get('score', defaultValue: 0) ?? 0;
    if (mounted) setState(() {});
  }

  void startGame() {
    if (_restarting || MonetizationService.instance.fullscreen) return;
    player.play(AssetSource('sound/jump.mp3'));

    gameHasStarted = true;
    scorePermission = true;
    _gameTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!mounted || _paused) return;
      // a real physical jump is the same as an upside down parabola
      // so this is a simple quadratic equation
      height = gravity * time * time + velocity * time;

      setState(() {
        birdY = initialPos - height;
      });

      // check if bird is dead
      if (birdIsDead()) {
        timer.cancel();
        _dead = true;
        scorePermission = false;
        _pointTimer?.cancel();
        MonetizationService.instance.completedRound();
        _showDialog();
        return;
      }

      // keep the map moving (move barriers)
      moveMap();

      // keep the time going!
      time += 0.01;
    });
  }

  void moveMap() {
    for (int i = 0; i < barrierX.length; i++) {
      // keep barriers moving
      setState(() {
        barrierX[i] -= 0.005;
      });

      // if barrier exits the left part of the screen, keep it looping
      if (barrierX[i] < -1.5) {
        barrierX[i] += 3;
      }
    }
  }

  Future<void> resetGame() async {
    if (_restarting) return;
    _restarting = true;
    await MonetizationService.instance.betweenRounds();
    if (!mounted) return;
    Navigator.pop(context);
    _restarting = false;
    _dead = false;
    isScoreUpped = false;
    setState(() {
      score = 0;
      birdY = 0;
      gameHasStarted = false;
      time = 0;
      initialPos = birdY;
      barrierX = [2, 2 + 1.5];
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: ColorConst.dialogColor,
            title: const Center(
              child: Text(
                "G A M E  O V E R",
                style: TextStyle(color: ColorConst.whiteColor),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    color: ColorConst.whiteColor,
                    child: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(color: ColorConst.blackColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void jump() async {
    await playJump();

    if (!mounted || _paused || _dead) return;
    setState(() {
      time = 0;
      initialPos = birdY;
    });
  }

  Future<void> playJump() async {
    if (player.state == PlayerState.playing) {
      player2.play(AssetSource('sound/jump.mp3'));
    } else if (player2.state == PlayerState.playing) {
      player3.play(AssetSource('sound/jump.mp3'));
    } else {
      player.play(AssetSource('sound/jump.mp3'));
    }
  }

  bool isScoreUpped = false;
  bool birdIsDead() {
    // check if the bird is hitting the top or the bottom of the screen
    if (birdY < -1 || birdY > 1) {
      playerDeath.play(AssetSource('sound/sfx_hit.wav'), volume: 0.1);

      return true;
    }

    // hits barriers
    // checks if bird is within x coordinates and y coordinates of barriers
    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= birdWidth &&
          barrierX[i] + barrierWidth >= -birdWidth &&
          (birdY <= -1 + barrierHeight[i][0] ||
              birdY + birdHeight >= 1 - barrierHeight[i][1])) {
        scorePermission = false;
        playerDeath.play(AssetSource('sound/sfx_hit.wav'), volume: 0.1);

        return true;
      }
    }
    if (!isScoreUpped) {
      for (int i = 0; i < barrierX.length; i++) {
        if (barrierX[i] <= birdWidth &&
            barrierX[i] + barrierWidth >= -birdWidth) {
          isScoreUpped = true;

          _pointTimer = Timer(const Duration(milliseconds: 1800), () {
            if (mounted && !_paused && scorePermission != false) {
              score++;
              playerPoint.play(AssetSource('sound/sfx_point.wav'), volume: 0.1);

              if (score >= best) {
                best = score;
                saveScore(best);
              }
            }

            isScoreUpped = false;
          });
        }
      }
    }

    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _paused = state != AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameTimer?.cancel();
    _pointTimer?.cancel();
    for (final audio in [player, player2, player3, playerPoint, playerDeath]) {
      audio.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameHasStarted ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: ColorConst.skyColor,
                child: Center(
                  child: Stack(
                    children: [
                      // bird
                      MyBird(
                        birdY: birdY,
                        birdWidth: birdWidth,
                        birdHeight: birdHeight,
                        bird: !_dead
                            ? ImageConstant.bird
                            : ImageConstant.birdCrash,
                      ),

                      // tap to play
                      MyCoverScreen(gameHasStarted: gameHasStarted),

                      // Top barrier 0
                      MyBarrier(
                        barrierX: barrierX[0],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[0][0],
                        isThisBottomBarrier: false,
                      ),

                      // Bottom barrier 0
                      MyBarrier(
                        barrierX: barrierX[0],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[0][1],
                        isThisBottomBarrier: true,
                      ),

                      // Top barrier 1
                      MyBarrier(
                        barrierX: barrierX[1],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[1][0],
                        isThisBottomBarrier: false,
                      ),

                      // Bottom barrier 1
                      MyBarrier(
                        barrierX: barrierX[1],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[1][1],
                        isThisBottomBarrier: true,
                      ),
                      if (!gameHasStarted)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: SafeArea(
                            child: IconButton(
                              tooltip: 'Settings',
                              icon: const Icon(Icons.settings),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SettingsPage(),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            GameDashboard(score: score, best: best),
          ],
        ),
      ),
    );
  }
}
