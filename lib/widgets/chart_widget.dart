import 'package:flutter/material.dart';

class ChartWidget extends StatefulWidget {
  final List<int> data;
  final Color color;

  const ChartWidget({
    super.key,
    required this.data,
    required this.color,
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: widget.data.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              final maxValue = widget.data.reduce((a, b) => a > b ? a : b);
              final normalizedHeight = (value / maxValue * 100).clamp(20.0, 100.0);
              final animatedHeight = normalizedHeight * _animation.value;
              
              return AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 100)),
                width: 24,
                height: animatedHeight,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      widget.color,
                      widget.color.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}