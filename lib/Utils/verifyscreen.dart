import 'package:flutter/material.dart';
import 'dart:math';
import 'package:lottie/lottie.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Bubble> _bubbles;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();

    _bubbles = List.generate(15, (index) => Bubble());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBubble(Bubble bubble) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final animationValue = (_controller.value + bubble.offset) % 1.0;
        final dy = bubble.dy + sin(animationValue * 2 * pi) * 50;
        return Positioned(
          left: bubble.dx,
          top: dy,
          child: Opacity(
            opacity: 0.3,
            child: ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                colors: [Colors.deepOrange, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(rect),
              child: Container(
                width: bubble.size,
                height: bubble.size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // this gets masked by shader
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bubbles background
        ..._bubbles.map(_buildBubble),

        // Main UI
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Verification Required',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'You are not a verified user.\nPlease contact your company to verify your identity.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    Lottie.asset("assets/Icons/not_verified.json"),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Model class for individual bubble
class Bubble {
  final double dx;
  final double dy;
  final double size;
  final double offset;

  Bubble()
      : dx = Random().nextDouble() * 400,
        dy = Random().nextDouble() * 800,
        size = Random().nextDouble() * 40 + 20,
        offset = Random().nextDouble();
}
