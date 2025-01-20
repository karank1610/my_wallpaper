import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package

class ProfilePage extends StatefulWidget {
  final Function onNavigateToHome;

  ProfilePage({required this.onNavigateToHome});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _imagePath =
      "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png"; // Placeholder fixed
  String _userName = "Kanani Jay6145";
  String _email = "@KananiJay6145";

  final List<String> wallpapers = [
    'assets/wallpaper1.jpg',
    'assets/wallpaper2.jpg',
    'assets/wallpaper3.jpg',
    'assets/wallpaper4.jpg',
    'assets/wallpaper5.jpg',
  ];

  // Firebase logout function
  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      print("User logged out");

      // Show a success message after logout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully logged out!')),
      );

      // Navigate back to the Home page after logging out
      widget.onNavigateToHome(); // Make sure this is called after the sign-out
    } catch (e) {
      print("Error logging out: $e");

      // Show an error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
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
            widget.onNavigateToHome(); // Return to Home Page
          },
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.menu, color: Colors.white),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutConfirmation(); // Show logout confirmation
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
            automaticallyImplyLeading: false, // Disable default back button
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
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

  void _pickImage() {
    setState(() {
      _imagePath =
          "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png"; // Placeholder fixed
    });
  }

  // Show confirmation dialog before logging out
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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                _logout(); // Ensure logout logic completes before navigation
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
