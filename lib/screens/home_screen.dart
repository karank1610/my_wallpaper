import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:my_wallpaper/screens/collection_page.dart';
import 'package:my_wallpaper/screens/full_screen_wallpaper.dart';
import 'package:my_wallpaper/screens/profile_page.dart';
import 'package:my_wallpaper/screens/registration_page.dart';
import 'package:my_wallpaper/screens/wallpaper_upload_screen.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child("wallpapers");
  List<Map<String, dynamic>> wallpapers = [];
  bool isLoading = true;
  int myCurrentIndex = 0;
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredWallpapers = [];

  @override
  void initState() {
    super.initState();
    fetchWallpapers().then((_) async {
      await fetchWallpaperDetails();
      _searchController.addListener(_filterWallpapers);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchWallpapers() async {
    final List<Map<String, dynamic>> fetchedWallpapers = [];
    final storageRef = FirebaseStorage.instance.ref().child("new_wallpapers");

    try {
      final result = await storageRef.listAll();
      for (var item in result.items) {
        final url = await item.getDownloadURL();

        fetchedWallpapers.add({
          "imagePath": url,
          "name": item.name,
        });
      }

      setState(() {
        wallpapers = fetchedWallpapers;
        filteredWallpapers = wallpapers;
        isLoading = false;
      });
      // Fetch wallpaper details to get premium info after fetching wallpapers
    await fetchWallpaperDetails();
    } catch (e) {
      print("Error fetching wallpapers: $e");
    }
  }

  Future<void> fetchWallpaperDetails() async {
    try {
      final databaseSnapshot = await _databaseRef.get();

      if (databaseSnapshot.exists) {
        final Map<dynamic, dynamic> wallpapersData = databaseSnapshot.value as Map<dynamic, dynamic>;

        for (var wallpaper in wallpapers) {
          final imagePath = wallpaper["imagePath"];
          final entry = wallpapersData.entries.firstWhere(
            (entry) => entry.value["imageUrl"] == imagePath,
            orElse: () => MapEntry("", {}),
          );

          if (entry.value != null) {
            final name = entry.value["name"] as String?;
            final category = entry.value["category"] as String?;
            final keywords = entry.value["keywords"];
            final isPremium = entry.value["isPremium"] ?? false;

            String keywordsString = "";
            if (keywords is List<Object?>) {
              keywordsString = keywords.where((item) => item != null).map((item) => item.toString()).join(", ");
            } else if (keywords is String?) {
              keywordsString = keywords ?? "";
            }

            wallpaper["name"] = name ?? "Unnamed Wallpaper";
            wallpaper["category"] = category ?? "Uncategorized";
            wallpaper["keywords"] = keywordsString;
            wallpaper["isPremium"] = isPremium;
          }
        }

        setState(() {
          filteredWallpapers = wallpapers;
        });
      }
    } catch (e) {
      print("Error fetching wallpaper details: $e");
    }
  }

  void _filterWallpapers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredWallpapers = wallpapers.where((wallpaper) {
        final name = wallpaper["name"].toString().toLowerCase();
        final category = wallpaper["category"].toString().toLowerCase();
        final keywords = wallpaper["keywords"].toString().toLowerCase();

        return name.contains(query) || category.contains(query) || keywords.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.notifications, color: Colors.white),
          onPressed: () {},
        ),
        centerTitle: true,
        title: Text(
          "MyWallpaper",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CollectionPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search wallpapers...',
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredWallpapers.isEmpty
                    ? Center(child: Text("No wallpapers available.", style: TextStyle(color: Colors.white)))
                    : RefreshIndicator(
                        onRefresh: fetchWallpapers,
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(8.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: filteredWallpapers.length,
                          itemBuilder: (context, index) {
                            final wallpaper = filteredWallpapers[index];
                            String imagePath = wallpaper["imagePath"];

                            return GestureDetector(
                              onTap: () => _onWallpaperClick(imagePath),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      image: DecorationImage(
                                        image: NetworkImage(imagePath),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  if (wallpaper["isPremium"] == true)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  void _onWallpaperClick(String imagePath) {
    if (imagePath.startsWith('/data')) {
      imagePath = 'file://$imagePath';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenWallpaper(
          imagePath: imagePath,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(8, 20))
      ]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.redAccent,
            unselectedItemColor: Colors.black,
            currentIndex: myCurrentIndex,
            onTap: (index) async {
              setState(() {
                myCurrentIndex = index;
              });

              if (index == 1) {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  showDialog(
                    context: context,
                    builder: (_) => WallpaperUploadScreen(),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please log in first to upload wallpapers."),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } else if (index == 2) {
                User? user = FirebaseAuth.instance.currentUser;

                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        onNavigateToHome: () {
                          setState(() {
                            myCurrentIndex = 0;
                          });
                        },
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(),
                    ),
                  ).then((_) {
                    setState(() {
                      myCurrentIndex = 0;
                    });
                  });
                }
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Upload"),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
            ]),
      ),
    );
  }
}
