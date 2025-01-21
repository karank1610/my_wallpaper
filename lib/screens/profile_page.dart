import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<Map<String, dynamic>> filteredWallpapers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    fetchUserWallpapers(); // Fetch wallpapers uploaded by the logged-in user
  }

  void _loadUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? "No Email";
      });

      // Fetch additional user details from Firestore
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _userName = userData['username'] ?? "No Name";
          _imagePath =
              "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png"; // Default image
        });
      }
    }
  }

  Future<void> fetchUserWallpapers() async {
    final List<Map<String, dynamic>> fetchedWallpapers = [];
    final user = _auth.currentUser;
    if (user == null) return;

    // Use the new FirebaseDatabase instance method with '.ref()'
    final wallpapersRef = FirebaseDatabase.instance.ref().child('wallpapers');

    try {
      // Fetch wallpapers uploaded by the current user (based on user ID)
      final snapshot = await wallpapersRef
          .orderByChild('uploadedBy')
          .equalTo(user.uid)
          .get(); // Use '.get()' instead of '.once()'

      if (snapshot.exists) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          fetchedWallpapers.add({
            "imagePath":
                value['imageUrl'], // Firebase field name for the image URL
            "name": value['name'], // Firebase field name for the wallpaper name
          });
        });
      }

      setState(() {
        wallpapers = fetchedWallpapers;
        filteredWallpapers = wallpapers;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user wallpapers: $e");
    }
  }

  // Firebase logout function
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
            // Menu for logout
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: Colors.black,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned(
                    top: 40,
                    left: MediaQuery.of(context).size.width / 2 - 50,
                    child: GestureDetector(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.purple,
                        backgroundImage: NetworkImage(_imagePath),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
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
                    : (wallpapers.isEmpty
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                                  // Handle wallpaper tap (e.g., open full-screen view)
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(wallpaper['imagePath']),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
