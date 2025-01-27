import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  // Define the main categories
  final List<Map<String, String>> categories = [
    {"title": "Community", "image": "assets/assets/community.jpg"},
    {"title": "Curated", "image": "assets/assets/curated.jpg"},
    {"title": "Popular", "image": "assets/assets/popular.jpg"},
    {"title": "Trending", "image": "assets/assets/trending.jpg"},
    {"title": "Nature", "image": "assets/assets/nature.jpeg"},
    {"title": "Technology", "image": "assets/assets/technology.jpeg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Categories",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 5,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two items per row
            crossAxisSpacing: 16, // Spacing between columns
            mainAxisSpacing: 16, // Spacing between rows
            childAspectRatio: 0.75, // Taller card ratio
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(
              context,
              categories[index]['title']!,
              categories[index]['image']!,
            );
          },
        ),
      ),
    );
  }

  // Widget to build each category card
  Widget _buildCategoryCard(BuildContext context, String title, String image) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                WallpaperPage(category: title),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      },
      child: Stack(
        children: [
          // Background Image
          Hero(
            tag: title,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 6),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // Title with Glass Effect
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(1, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for the WallpaperPage
class WallpaperPage extends StatelessWidget {
  final String category;

  const WallpaperPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$category Wallpapers",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 5,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: category,
              child: const Icon(
                Icons.wallpaper,
                color: Colors.white,
                size: 100,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Wallpapers will be displayed here.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
