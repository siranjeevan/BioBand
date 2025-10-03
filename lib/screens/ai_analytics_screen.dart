import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../design_system/app_colors.dart';
import '../design_system/glass_container.dart';
import '../config/environment.dart';

class AiAnalyticsScreen extends StatefulWidget {
  const AiAnalyticsScreen({super.key});

  @override
  State<AiAnalyticsScreen> createState() => _AiAnalyticsScreenState();
}

class _AiAnalyticsScreenState extends State<AiAnalyticsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late List<FloatingParticle> _particles;
  late List<WatchLogo> _watchLogos;
  bool _isLoading = false;
  
  String get apiUrl => '${Environment.apiBaseUrl}/chat';

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    _particles = List.generate(15, (index) => FloatingParticle());
    _watchLogos = List.generate(5, (index) => WatchLogo());
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final userMessage = _messageController.text.trim();
    _messageController.clear();
    
    setState(() {
      _chatMessages.add({
        'role': 'user',
        'content': userMessage
      });
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage
        }),
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.body}');
        final data = jsonDecode(response.body);
        String aiResponse = data['answer'] ?? data['response'] ?? data['message'] ?? data['reply'] ?? 'No response received';
        
        setState(() {
          _chatMessages.add({
            'role': 'assistant',
            'content': aiResponse
          });
        });
      } else {
        setState(() {
          _chatMessages.add({
            'role': 'assistant',
            'content': 'Sorry, I encountered an error. Please try again.'
          });
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add({
          'role': 'assistant',
          'content': 'Sorry, I\'m having trouble connecting. Please check your internet connection.'
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + _pulseController.value * 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology, color: Colors.white, size: 20),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'AI Analytics',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          ),
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlesPainter(_particles, _floatingController.value),
                size: Size.infinite,
              );
            },
          ),
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return CustomPaint(
                painter: WatchLogoPainter(_watchLogos, _rotateController.value),
                size: Size.infinite,
              );
            },
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _chatMessages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + _pulseController.value * 0.2,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.primary.withValues(alpha: 0.3),
                                            AppColors.primary.withValues(alpha: 0.1),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.psychology,
                                        size: 50,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'AI Health Assistant',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Ask me anything about your health',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _chatMessages.length,
                          itemBuilder: (context, index) {
                            final message = _chatMessages[index];
                            final isUser = message['role'] == 'user';
                            
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300 + (index * 100)),
                              curve: Curves.easeOutBack,
                              child: Align(
                                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: isUser
                                        ? LinearGradient(
                                            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                                          )
                                        : LinearGradient(
                                            colors: [
                                              AppColors.surface.withValues(alpha: 0.3),
                                              AppColors.surface.withValues(alpha: 0.1),
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    message['content'] ?? '',
                                    style: TextStyle(
                                      color: isUser ? Colors.white : AppColors.textPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Add loading indicator
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'AI is thinking...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.surface.withValues(alpha: 0.3),
                        AppColors.surface.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Type your health question...',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + _pulseController.value * 0.05,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.send_rounded, color: Colors.white),
                                onPressed: _isLoading ? null : _sendMessage,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Include all the missing classes
class FloatingParticle {
  late double x;
  late double y;
  late double size;
  late double speed;
  late Color color;
  late double opacity;

  FloatingParticle() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = 2 + random.nextDouble() * 4;
    speed = 0.1 + random.nextDouble() * 0.3;
    opacity = 0.1 + random.nextDouble() * 0.3;
    color = [AppColors.primary, AppColors.textPrimary, Colors.white][random.nextInt(3)];
  }

  void update() {
    y -= speed * 0.01;
    x += sin(y * 10) * 0.001;
    if (y < -0.1) {
      y = 1.1;
      x = Random().nextDouble();
    }
  }
}

class WatchLogo {
  late double x;
  late double y;
  late double size;
  late double speed;
  late double rotation;
  late double opacity;

  WatchLogo() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = 30 + random.nextDouble() * 40;
    speed = 0.05 + random.nextDouble() * 0.1;
    rotation = random.nextDouble() * 2 * pi;
    opacity = 0.05 + random.nextDouble() * 0.1;
  }

  void update(double animationValue) {
    y -= speed * 0.01;
    rotation += 0.02;
    if (y < -0.2) {
      y = 1.2;
      x = Random().nextDouble();
    }
  }
}

class ParticlesPainter extends CustomPainter {
  final List<FloatingParticle> particles;
  final double animationValue;

  ParticlesPainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();
      
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      final center = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      canvas.drawCircle(center, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WatchLogoPainter extends CustomPainter {
  final List<WatchLogo> watchLogos;
  final double animationValue;

  WatchLogoPainter(this.watchLogos, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var watch in watchLogos) {
      watch.update(animationValue);
      
      final center = Offset(
        watch.x * size.width,
        watch.y * size.height,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(watch.rotation);
      
      _drawWatch(canvas, watch.size, watch.opacity);
      
      canvas.restore();
    }
  }

  void _drawWatch(Canvas canvas, double size, double opacity) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Watch face
    canvas.drawCircle(Offset.zero, size * 0.4, paint);
    
    // Watch band
    final bandPaint = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawLine(
      Offset(-size * 0.4, -size * 0.1),
      Offset(-size * 0.6, -size * 0.1),
      bandPaint,
    );
    canvas.drawLine(
      Offset(size * 0.4, -size * 0.1),
      Offset(size * 0.6, -size * 0.1),
      bandPaint,
    );
    
    // Watch hands
    final handPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawLine(
      Offset.zero,
      Offset(0, -size * 0.2),
      handPaint,
    );
    canvas.drawLine(
      Offset.zero,
      Offset(size * 0.15, 0),
      handPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}