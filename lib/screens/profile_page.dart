import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
<<<<<<< HEAD
  final Function onNavigateToHome;

  ProfilePage({required this.onNavigateToHome});
=======
  const ProfilePage({super.key});
>>>>>>> bd53509da20207125046a8e55f4f0f57be382127

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _imagePath =
      "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png"; // Placeholder fixed
  String _userName = "Kanani Jay6145";
  String _email = "@KananiJay6145";

<<<<<<< HEAD
  final List<String> wallpapers = [
    'assets/wallpaper1.jpg',
    'assets/wallpaper2.jpg',
    'assets/wallpaper3.jpg',
    'assets/wallpaper4.jpg',
    'assets/wallpaper5.jpg',
  ];
=======
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 160), (timer) {
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
>>>>>>> bd53509da20207125046a8e55f4f0f57be382127

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
<<<<<<< HEAD
          icon: Icon(Icons.arrow_back_sharp),
=======
          icon: const Icon(Icons.notifications, color: Colors.black),
>>>>>>> bd53509da20207125046a8e55f4f0f57be382127
          onPressed: () {
            widget.onNavigateToHome(); // Return to Home Page
          },
        ),
        actions: [
          IconButton(
<<<<<<< HEAD
            icon: Icon(Icons.menu),
=======
            icon: const Icon(Icons.settings, color: Colors.black),
>>>>>>> bd53509da20207125046a8e55f4f0f57be382127
            onPressed: () {
              // Menu icon with no assigned event
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false, // Disable default back button
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
<<<<<<< HEAD
                  Positioned(
                    top: 40,
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: GestureDetector(
                      onTap: () {
                        _pickImage();
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.purple,
                        backgroundImage: NetworkImage(_imagePath),
                        child: _imagePath.isEmpty
                            ? Icon(Icons.camera_alt,
                                size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
=======
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
>>>>>>> bd53509da20207125046a8e55f4f0f57be382127
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
<<<<<<< HEAD
                          _userName,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          _email,
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Wallpapers',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Container(
                          height: 2,
                          width: 60,
                          color: Colors.pink,
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                GridView.builder(
                  padding: EdgeInsets.all(10),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.6,
=======
                          isLoggedIn ? "John Doe" : "Welcome!",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isLoggedIn)
                          const Text(
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
                      child: const Text("Sign In"),
                    ),
                ],
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

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
                    const Divider(height: 1),
                    _buildOptionItem(
                      Icons.campaign,
                      "Bulletin",
                      () {
                        // Navigate to Bulletin Page
                      },
                    ),
                    const Divider(height: 1),
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

              const SizedBox(height: 16),

              // Developer Button with Sparkle Animation
              if (isLoggedIn)
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 100),
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
                              const SnackBar(
                                content:
                                    Text("Application submitted successfully!"),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isDeveloper
                              ? "Application Submitted"
                              : "Apply for Developer",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
>>>>>>> bd53509da20207125046a8e55f4f0f57be382127
                  ),
                  itemCount: wallpapers.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(wallpapers[index]),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  void _pickImage() {
    setState(() {
      _imagePath =
          "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png"; // Placeholder fixed
    });
=======
  Widget _buildMetricItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
    const angle = pi / 5;

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
>>>>>>> bd53509da20207125046a8e55f4f0f57be382127
  }
}
