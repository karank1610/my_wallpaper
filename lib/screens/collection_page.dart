import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Prism",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              onPressed: () {
                _showCategoryDialog(context);
              },
              icon: const Icon(Icons.grid_view, color: Colors.grey),
              iconSize: 30,
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
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
                _buildCategoryItem(context, "Community", "assets/assets/community.jpg"),
                _buildCategoryItem(context, "Curated", "assets/assets/curated.jpg"),
                _buildCategoryItem(context, "Popular", "assets/assets/popular.jpg"),
                _buildCategoryItem(context, "Trending", "assets/assets/trending.jpg"),
                _buildCategoryItem(context, "Cars", "assets/assets/car.jpg"),
                _buildCategoryItem(context, "Animals", "assets/assets/animal.jpeg"),
                _buildCategoryItem(context, "Anime", "assets/assets/anime.jpeg"),
                _buildCategoryItem(context, "Nature", "assets/assets/nature.jpeg"),
                _buildCategoryItem(context, "Technology", "assets/assets/technology.jpeg"),
                _buildCategoryItem(context, "Space", "assets/assets/space.jpeg"),
                _buildCategoryItem(context, "Pattern", "assets/assets/pattern.jpg"),
                _buildCategoryItem(context, "Artwork", "assets/assets/artwok.jpeg"),
                _buildCategoryItem(context, "Science Fiction", "assets/assets/sciencefiction.jpeg"),
                _buildCategoryItem(context, "Marvel", "assets/assets/marvel.jpg"),
                _buildCategoryItem(context, "God", "assets/assets/god.jpg"),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
               style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink, // Background color for the button
            ),
              onPressed: () {
                Navigator.of(context).pop();
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

  Widget _buildCategoryItem(BuildContext context, String title, String image) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
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
    final Map<String, List<String>> wallpapersByCategory = {
      "Community": ["assets/assets/communityw1.jpg", "assets/assets/communityw2.jpg","assets/assets/communityw3.jpg","assets/assets/communityw4.jpg","assets/assets/communityw5.jpg"],
      "Curated": ["assets/assets/curatedw3.jpeg","assets/assets/curatedw4.jpg","assets/assets/curatedw5.jpeg"],
      "Popular": ["assets/assets/popularw1.jpg", "assets/assets/popularw2.jpg",],
      "Trending": ["assets/assets/trendingw1.jpg", "assets/assets/trendingw2.jpg"],
      "Cars": ["assets/assets/carw1.jpg", "assets/assets/carw2.jpg"],
      "Animals": ["assets/assets/animalw1.jpg"],
      "Anime": ["assets/assets/animew1.jpg"],
      "Nature": ["assets/assets/naturew1.jpg", "assets/assets/naturew2.jpg"],
      "Technology": ["assets/assets/technologyw1.jpg","assets/assets/technologyw3.jpg"],
      "Space": ["assets/assets/spacew2.jpeg"],
      "Pattern": ["assets/assets/patternw1.jpeg", "assets/assets/patternw2.jpeg"],
      "Artwork": ["assets/assets/artworkw1.jpg", "assets/assets/artworkw2.jpg"],
      "Science Fiction": ["assets/assets/sciencefictionw1.jpeg", "assets/assets/sciencefictionw2.jpeg"],
      "Marvel": ["assets/assets/marvelw1.jpeg", "assets/assets/marvelw2.jpeg"],
      "God": ["assets/assets/godw1.jpg", "assets/assets/godw2.jpeg"],
    };

    final wallpapers = wallpapersByCategory[category] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$category Wallpapers",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: wallpapers.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              wallpapers[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}