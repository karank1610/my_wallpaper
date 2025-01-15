import 'package:flutter/material.dart';

class CollectionPage {
  static void showCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Categories",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildCategoryItem(
                    context, "Community", "assets/assets/community.jpg"),
                _buildCategoryItem(
                    context, "Curated", "assets/assets/curated.jpg"),
                _buildCategoryItem(
                    context, "Popular", "assets/assets/popular.jpg"),
                _buildCategoryItem(
                    context, "Trending", "assets/assets/trending.jpg"),
                _buildCategoryItem(context, "Cars", "assets/assets/car.jpg"),
                _buildCategoryItem(
                    context, "Animals", "assets/assets/animal.jpeg"),
                _buildCategoryItem(
                    context, "Anime", "assets/assets/anime.jpeg"),
                _buildCategoryItem(
                    context, "Nature", "assets/assets/nature.jpeg"),
                _buildCategoryItem(
                    context, "Technology", "assets/assets/technology.jpeg"),
                _buildCategoryItem(
                    context, "Space", "assets/assets/space.jpeg"),
                _buildCategoryItem(
                    context, "Pattern", "assets/assets/pattern.jpg"),
                _buildCategoryItem(
                    context, "Artwork", "assets/assets/artwok.jpeg"),
                _buildCategoryItem(context, "Science Fiction",
                    "assets/assets/sciencefiction.jpeg"),
                _buildCategoryItem(
                    context, "Marvel", "assets/assets/marvel.jpg"),
                _buildCategoryItem(context, "God", "assets/assets/god.jpg"),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildCategoryItem(
      BuildContext context, String title, String image) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(); // Close the dialog
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WallpaperPage(category: title),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
        ),
        height: 100,
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(2, 2), // Horizontal and vertical offset
                blurRadius: 4, // Blur effect
                color: Colors.black, // Shadow color
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WallpaperPage extends StatelessWidget {
  final String category;

  const WallpaperPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$category Wallpapers",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          "Wallpapers will be displayed here.",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
