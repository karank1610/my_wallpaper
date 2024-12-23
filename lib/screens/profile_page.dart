import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter/scheduler.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  bool isLoggedIn = false;
  bool isDeveloper = false;
  late Timer _timer;
  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 160), (timer) {
      setState(() {
        _animationValue += 0.01;
        if (_animationValue > 1) {
          _animationValue = 0.0;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.notifications, color: Colors.black),
          onPressed: () {
            // Handle notifications
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn ? "John Doe" : "Welcome!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLoggedIn)
                          Text(
                            "johndoe@example.com",
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                  if (!isLoggedIn)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoggedIn = true; // Simulate login
                        });
                      },
                      child: Text("Sign In"),
                    ),
                ],
              ),
              SizedBox(height: 16),

              // Metrics Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem(Icons.thumb_up, "Liked"),
                      _buildMetricItem(Icons.people, "Following"),
                      _buildMetricItem(Icons.remove_red_eye, "Viewed"),
                      _buildMetricItem(Icons.file_download, "Downloads"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Options List
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Column(
                  children: [
                    _buildOptionItem(
                      Icons.file_download,
                      "Downloads",
                      () {
                        // Navigate to Downloads Page
                      },
                    ),
                    Divider(height: 1),
                    _buildOptionItem(
                      Icons.campaign,
                      "Bulletin",
                      () {
                        // Navigate to Bulletin Page
                      },
                    ),
                    Divider(height: 1),
                    _buildOptionItem(
                      Icons.feedback,
                      "Help & Feedback",
                      () {
                        // Navigate to Help & Feedback Page
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Developer Button with Sparkle Animation
              if (isLoggedIn)
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(200, 100),
                        painter: StarParticlePainter(
                          numberOfParticles: 10,
                          maxParticleSize: 8,
                          particleColor: Colors.deepPurple.withAlpha(150),
                          animationValue: _animationValue,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (!isDeveloper) {
                            setState(() {
                              isDeveloper = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Application submitted successfully!"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isDeveloper
                              ? "Application Submitted"
                              : "Apply for Developer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class StarParticlePainter extends CustomPainter {
  final int numberOfParticles;
  final double maxParticleSize;
  final Color particleColor;
  final double animationValue;

  StarParticlePainter({
    required this.numberOfParticles,
    required this.maxParticleSize,
    required this.particleColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = particleColor;
    final random = Random();

    for (int i = 0; i < numberOfParticles; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * maxParticleSize;

      _drawStar(canvas, paint, x, y, radius);
    }
  }

  void _drawStar(
      Canvas canvas, Paint paint, double x, double y, double radius) {
    final path = Path();
    final angle = pi / 5;

    for (int i = 0; i < 10; i++) {
      final r = (i % 2 == 0) ? radius : radius / 2;
      final offsetX = x + r * cos(i * angle + animationValue * 2 * pi);
      final offsetY = y + r * sin(i * angle + animationValue * 2 * pi);
      if (i == 0) {
        path.moveTo(offsetX, offsetY);
      } else {
        path.lineTo(offsetX, offsetY);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
