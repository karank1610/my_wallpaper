import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:my_wallpaper/screens/full_screen_wallpaper.dart';
// Import your full-screen page

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> likedWallpapers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLikedWallpapers();
  }

  Future<void> _fetchLikedWallpapers() async {
    if (user == null) return;

    DatabaseReference wallpaperRef =
        FirebaseDatabase.instance.ref().child('wallpapers');
    final snapshot = await wallpaperRef.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> wallpapersData =
          snapshot.value as Map<dynamic, dynamic>;

      List<Map<String, dynamic>> tempWallpapers = [];
      wallpapersData.forEach((key, value) {
        if (value['likedBy'] != null && value['likedBy'][user!.uid] == true) {
          tempWallpapers.add({
            'key': key,
            'imageUrl': value['imageUrl'],
            'name': value['name'] ?? 'No Name',
          });
        }
      });

      setState(() {
        likedWallpapers = tempWallpapers;
        isLoading = false;
      });
    } else {
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
          "My Favorites",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : likedWallpapers.isEmpty
              ? Center(
                  child: Text("No favorite wallpapers yet!",
                      style: TextStyle(color: Colors.white)))
              : GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: likedWallpapers.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenWallpaper(
                              imagePath: likedWallpapers[index]['imageUrl'],
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          likedWallpapers[index]['imageUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
