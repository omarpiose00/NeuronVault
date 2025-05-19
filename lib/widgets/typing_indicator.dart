// lib/widgets/typing_indicator.dart (aggiornato)
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final Color dotColor;
  final String text;

  const TypingIndicator({
    super.key,
    this.dotColor = Colors.grey,
    this.text = "Sta scrivendo",
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _animControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _animControllers = List.generate(
      3,
          (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + (index * 100)),
      ),
    );

    _animations = _animControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );
    }).toList();

    // Inizia le animazioni in sequenza
    for (var i = 0; i < _animControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _animControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.dotColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.text,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: widget.dotColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(
            3,
                (index) => AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 6 + (_animations[index].value * 6),
                  width: 6 + (_animations[index].value * 6),
                  decoration: BoxDecoration(
                    color: widget.dotColor.withOpacity(0.3 + (_animations[index].value * 0.7)),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: widget.dotColor.withOpacity(0.2 * _animations[index].value),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}