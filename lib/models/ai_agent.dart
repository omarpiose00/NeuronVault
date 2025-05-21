// lib/models/ai_agent.dart - Versione migliorata con icone animate

import 'package:flutter/material.dart';
import 'dart:math' as math;

enum AiAgent { claude, gpt, deepseek, gemini, mistral }

String agentName(AiAgent agent) {
  switch (agent) {
    case AiAgent.claude:
      return 'Claude';
    case AiAgent.gpt:
      return 'GPT-4';
    case AiAgent.deepseek:
      return 'DeepSeek';
    case AiAgent.gemini:
      return 'Gemini';
    case AiAgent.mistral:
      return 'Mistral';
  }
}

Widget agentIcon(AiAgent agent, {double size = 40}) {
  // Utilizziamo il size per scalare tutte le componenti internamente
  return AnimatedAgentIcon(agent: agent, size: size);
}

// Nuovo widget per gestire le animazioni delle icone
class AnimatedAgentIcon extends StatefulWidget {
  final AiAgent agent;
  final double size;

  const AnimatedAgentIcon({
    Key? key,
    required this.agent,
    this.size = 40,
  }) : super(key: key);

  @override
  State<AnimatedAgentIcon> createState() => _AnimatedAgentIconState();
}

class _AnimatedAgentIconState extends State<AnimatedAgentIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    // Inizializza controller e animazioni
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // Avvia l'animazione dopo l'inizializzazione
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.agent) {
      case AiAgent.claude:
        return _buildClaudeIcon();
      case AiAgent.gpt:
        return _buildGptIcon();
      case AiAgent.deepseek:
        return _buildDeepseekIcon();
      case AiAgent.gemini:
        return _buildGeminiIcon();
      case AiAgent.mistral:
        return _buildMistralIcon();
    }
  }

  // Icona animata per Claude
  Widget _buildClaudeIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [Color(0xFFD1B2E0), Color(0xFF8A4BAF)],
                stops: [0.2, 1.0],
                center: Alignment(0.1, -0.1),
              ),
              borderRadius: BorderRadius.circular(widget.size / 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB17ACC).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Stack(
              children: [
                // Particelle che ruotano intorno
                _buildParticles(const Color(0xFFE2CCF2), 6),

                // Icona del cervello
                Center(
                  child: Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: widget.size * 0.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Icona animata per GPT
  Widget _buildGptIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF74D49A), Color(0xFF0C7A3E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(widget.size / 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF74D49A).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Stack(
              children: [
                // Effetto brillante rotante
                _buildRotatingGlow(const Color(0xFFB6F8D0)),

                // Icona robot
                Center(
                  child: Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: widget.size * 0.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Icona animata per DeepSeek
  Widget _buildDeepseekIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF176), Color(0xFFFFB300)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(widget.size / 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD54F).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Stack(
              children: [
                // Cerchi concentrici pulsanti
                _buildConcentricCircles(const Color(0xFFFFFDE7)),

                // Icona computer/tecnologia
                Center(
                  child: Icon(
                    Icons.memory,
                    color: Colors.white,
                    size: widget.size * 0.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Icona animata per Gemini
  Widget _buildGeminiIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(widget.size / 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4285F4).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Stack(
              children: [
                // Effetto stelle rotanti
                _buildStarsEffect(const Color(0xFFBBDAFF), 8),

                // Icona stella/gemma
                Center(
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: widget.size * 0.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Icona animata per Mistral
  Widget _buildMistralIcon() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(widget.size / 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF5722).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Stack(
              children: [
                // Effetto vortice
                _buildSwirlEffect(const Color(0xFFFFCCBC)),

                // Icona vento/vortice
                Center(
                  child: Icon(
                    Icons.air,
                    color: Colors.white,
                    size: widget.size * 0.6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Effetto particelle per l'icona Claude
  Widget _buildParticles(Color color, int count) {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(count, (index) {
            final angle = (index / count) * 2 * math.pi;
            final rotation = _rotateAnimation.value + angle;
            final distance = widget.size * 0.38;

            return Positioned(
              left: widget.size / 2 + distance * math.cos(rotation) - 3,
              top: widget.size / 2 + distance * math.sin(rotation) - 3,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Effetto bagliore rotante per GPT
  Widget _buildRotatingGlow(Color color) {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.7),
                  color.withOpacity(0.0),
                ],
                stops: const [0.0, 0.7],
                center: const Alignment(0.5, -0.5),
              ),
            ),
          ),
        );
      },
    );
  }

  // Effetto cerchi concentrici per DeepSeek
  Widget _buildConcentricCircles(Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Center(
          child: Container(
            width: widget.size * 0.8 * _pulseAnimation.value,
            height: widget.size * 0.8 * _pulseAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.5 * _pulseAnimation.value,
                height: widget.size * 0.5 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.7),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Effetto stelle per Gemini
  Widget _buildStarsEffect(Color color, int count) {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(count, (index) {
            final angle = (index / count) * 2 * math.pi;
            final rotation = _rotateAnimation.value + angle;
            final distance = widget.size * 0.35;
            final size = 4 + 2 * math.sin(_controller.value * 2 * math.pi);

            return Positioned(
              left: widget.size / 2 + distance * math.cos(rotation) - size / 2,
              top: widget.size / 2 + distance * math.sin(rotation) - size / 2,
              child: Transform.rotate(
                angle: rotation,
                child: Icon(
                  Icons.star,
                  color: color.withOpacity(0.8),
                  size: size,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Effetto vortice per Mistral
  Widget _buildSwirlEffect(Color color) {
    return AnimatedBuilder(
      animation: _rotateAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SwirlPainter(color: color),
          ),
        );
      },
    );
  }
}

// Custom painter per l'effetto vortice di Mistral
class _SwirlPainter extends CustomPainter {
  final Color color;

  _SwirlPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 3; i++) {
      final radius = size.width * 0.3 + i * 10;
      canvas.drawCircle(center, radius, paint);
    }

    // Disegna linee a spirale
    final spiralPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final turns = 2;
    final maxRadius = size.width * 0.4;

    for (double angle = 0; angle < turns * 2 * math.pi; angle += 0.1) {
      final radius = maxRadius * angle / (turns * 2 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (angle == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, spiralPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Color agentColor(AiAgent agent) {
  switch (agent) {
    case AiAgent.claude:
      return const Color(0xFFE0BBE4); // Purple for Claude
    case AiAgent.gpt:
      return const Color(0xFFB2DFDB); // Teal for GPT
    case AiAgent.deepseek:
      return const Color(0xFFFFF59D); // Yellow for DeepSeek
    case AiAgent.gemini:
      return const Color(0xFF4285F4); // Google Blue for Gemini
    case AiAgent.mistral:
      return const Color(0xFFFF5722); // Orange for Mistral
  }
}

Color agentDarkColor(AiAgent agent) {
  switch (agent) {
    case AiAgent.claude:
      return const Color(0xFF9C64A6); // Darker Purple for Claude
    case AiAgent.gpt:
      return const Color(0xFF00695C); // Darker Teal for GPT
    case AiAgent.deepseek:
      return const Color(0xFFFFEB3B); // Darker Yellow for DeepSeek
    case AiAgent.gemini:
      return const Color(0xFF0D47A1); // Darker Blue for Gemini
    case AiAgent.mistral:
      return const Color(0xFFE64A19); // Darker Orange for Mistral
  }
}