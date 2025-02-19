import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_wallpaper/screens/full_screen_wallpaper.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child("wallpapers");
  List<Map<String, String>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot = await _databaseRef.get();
      if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
        Set<String> uniqueCategories = {};
        List<Map<String, String>> fetchedCategories = [];
        final data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic> &&
              value.containsKey("category") &&
              value.containsKey("imageUrl")) {
            String category = value["category"].toString();
            if (!uniqueCategories.contains(category)) {
              uniqueCategories.add(category);
              fetchedCategories.add({
                "name": category,
                "image": value["imageUrl"].toString(),
              });
            }
          }
        });

        setState(() {
          categories = fetchedCategories;
          isLoading = false;
        });
      } else {
        print("No categories found.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
        backgroundColor: Colors.black, // Change AppBar color
        centerTitle: true,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Change back arrow color
          onPressed: () {
            Navigator.pop(context); // Fix back arrow functionality
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(
                    context,
                    categories[index]['name']!,
                    categories[index]['image']!,
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String name, String image) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WallpaperPage(category: name),
          ),
        );
      },
      child: Stack(
        children: [
          Hero(
            tag: name,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(image),
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
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  const Color.fromARGB(0, 213, 136, 136),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
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
                name,
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

class WallpaperPage extends StatefulWidget {
  final String category;

  const WallpaperPage({super.key, required this.category});

  @override
  _WallpaperPageState createState() => _WallpaperPageState();
}

class _WallpaperPageState extends State<WallpaperPage> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref().child("wallpapers");

  List<String> wallpapers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWallpapers();
  }

  Future<void> fetchWallpapers() async {
    try {
      final snapshot = await _databaseRef.get();
      if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
        List<String> fetchedWallpapers = [];
        final data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          if (value is Map<dynamic, dynamic> &&
              value.containsKey("category") &&
              value.containsKey("imageUrl") &&
              value["category"].toString() == widget.category) {
            fetchedWallpapers.add(value["imageUrl"].toString());
          }
        });

        setState(() {
          wallpapers = fetchedWallpapers;
          isLoading = false;
        });
      } else {
        print("No wallpapers found.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching wallpapers: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.category} Wallpapers",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Change back arrow color
          onPressed: () {
            Navigator.pop(context); // Fix back arrow functionality
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : wallpapers.isEmpty
              ? Center(
                  child: Text(
                    "No wallpapers found for ${widget.category}.",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: wallpapers.length,
                    itemBuilder: (context, index) {
                      return _buildWallpaperCard(wallpapers[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildWallpaperCard(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Navigate to FullScreenWallpaper when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenWallpaper(imagePath: imageUrl),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
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
    );
  }
}
