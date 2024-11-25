import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioVisualizer extends StatefulWidget {
  final bool isActive;
  final int volume;
  final Color color;
  final double height;
  final int barsCount;

  const AudioVisualizer({
    Key? key,
    required this.isActive,
    required this.volume,
    this.color = Colors.blue,
    this.height = 100,
    this.barsCount = 40,
  }) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    _barHeights.addAll(List.generate(
      widget.barsCount,
      (index) => 0.1,
    ));

    _controller.repeat();
  }

  List<double> _calculateBarHeights(double animationValue) {
    if (!widget.isActive || widget.volume <= 0) {
      return List.generate(widget.barsCount, (index) => 0.1);
    }

    final volumeScale = 0.1 + (widget.volume / 100.0) * 0.9;
    return List.generate(widget.barsCount, (i) {
      // 使用正弦函数创建基础波形
      double baseHeight = math.sin(i / 5 + animationValue * math.pi * 2) * 0.5;

      // 根据音量调整波形高度
      double targetHeight = 0.1 + baseHeight * volumeScale;

      // 确保高度在合理范围内
      return math.max(0.1, math.min(1.0, targetHeight));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final heights = _calculateBarHeights(_controller.value);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(
                widget.barsCount,
                (index) => _buildBar(heights[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 3,
      height: widget.height * height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1.5),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            widget.color.withOpacity(0.3),
            widget.color.withOpacity(0.7),
            widget.color,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
