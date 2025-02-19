import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_wallpaper/screens/full_screen_wallpaper.dart';
import 'package:my_wallpaper/screens/home_screen.dart';
import 'package:my_wallpaper/screens/settings.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onNavigateToHome;

  const ProfilePage({Key? key, required this.onNavigateToHome})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _imagePath =
      "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png";
  String _userName = "Guest";
  String _email = "guest@example.com";
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
        });
      }
    } catch (e) {
      print("Error fetching user wallpapers: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  void _logout() async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully logged out!')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
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
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          widget.onNavigateToHome();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Profile', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_sharp, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onNavigateToHome();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        endDrawer: Drawer(
          backgroundColor: Colors.black,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.black),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CircleAvatar(
                    //   radius: 30,
                    //   backgroundImage: NetworkImage(_imagePath),
                    // ),
                    SizedBox(height: 10),
                    Text("My Wallpaper",
                        style: TextStyle(color: Colors.white, fontSize: 22)),
                    Text("Exclusive Wallpapers",
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.settings, "Settings", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              }),
              _buildDrawerItem(
                  Icons.exit_to_app, "Logout", _showLogoutConfirmation),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_imagePath),
              ),
              SizedBox(height: 10),
              Text(_userName,
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              Text(_email, style: TextStyle(color: Colors.grey, fontSize: 14)),
              SizedBox(height: 20),
              Text('My Wallpapers',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 15),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : wallpapers.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Text('No wallpapers uploaded!',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16)),
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
                                    image: NetworkImage(
                                        wallpapers[index]['imagePath']),
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
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }
}
