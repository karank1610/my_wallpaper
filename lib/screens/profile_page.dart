import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_wallpaper/screens/full_screen_wallpaper.dart';

class ProfilePage extends StatefulWidget {
  final Function onNavigateToHome;

  ProfilePage({required this.onNavigateToHome});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _imagePath =
      "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png"; // Placeholder
  String _userName = "Guest";
  String _email = "guest@example.com";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> wallpapers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    fetchUserWallpapers();
  }

  void _loadUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? "No Email";
      });

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _userName = userData['username'] ?? "No Name";
        });
      }
    }
  }

  Future<void> fetchUserWallpapers() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final wallpapersRef = FirebaseDatabase.instance.ref().child('wallpapers');
    try {
      final snapshot = await wallpapersRef
          .orderByChild('uploadedBy')
          .equalTo(user.uid)
          .get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> fetchedWallpapers = [];
        data.forEach((key, value) {
          fetchedWallpapers.add({
            "imagePath": value['imageUrl'],
            "name": value['name'],
          });
        });

        setState(() {
          wallpapers = fetchedWallpapers;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user wallpapers: $e");
    }
  }

  void _logout() async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully logged out!')),
      );
      widget.onNavigateToHome();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _logout();
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp, color: Colors.white),
          onPressed: () {
            widget.onNavigateToHome();
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutConfirmation();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_imagePath),
              ),
            ),
            SizedBox(height: 10),
            Text(
              _userName,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              _email,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    'My Wallpapers',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Container(
                    height: 2,
                    width: 60,
                    color: Colors.pink,
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : wallpapers.isEmpty
                    ? Center(
                        child: Text(
                          'No wallpapers uploaded!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(10),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: wallpapers.length,
                        itemBuilder: (context, index) {
                          final wallpaper = wallpapers[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenWallpaper(
                                    imagePath: wallpaper['imagePath'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(wallpaper['imagePath']),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
