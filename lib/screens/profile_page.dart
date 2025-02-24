import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_wallpaper/screens/Edit_profile_page.dart';
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

  //  Load User Details from Firestore
  Future<void> _loadUserDetails() async {
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

  //  Fetch Wallpapers from Firebase Realtime Database
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
            "isPremium": value['isPremium'] ?? false,
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

  //  Pull-to-Refresh Functionality
  Future<void> _refreshPage() async {
    setState(() {
      isLoading = true;
    });
    await _loadUserDetails();
    await fetchUserWallpapers();
  }

  //  Logout Function
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
                    SizedBox(height: 10),
                    Text("My Wallpaper",
                        style: TextStyle(color: Colors.white, fontSize: 22)),
                    Text("Exclusive Wallpapers",
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.person, "Edit Profile", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              }),
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
        body: RefreshIndicator(
          onRefresh: _refreshPage,
          color: const Color.fromARGB(204, 163, 56, 233),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
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
                Text(_email,
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 20),
                Text('My Wallpapers',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                Container(
                  height: 3,
                  width: 100,
                  color: Colors.pink,
                ),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : wallpapers.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(vertical: 50),
                            child: Text('No wallpapers uploaded!',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16)),
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
                            // Inside itemBuilder of GridView.builder
                            itemBuilder: (context, index) {
                              final wallpaper = wallpapers[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenWallpaper(
                                          imagePath: wallpaper['imagePath']),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              wallpaper['imagePath']),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),

                                    // Three Dots Menu
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: Icon(Icons.more_vert,
                                            color: Colors.white),
                                        onPressed: () {
                                          showWallpaperOptions(
                                              context, wallpaper);
                                        },
                                      ),
                                    ),

                                    if (wallpaper['isPremium'])
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                          ),
                                          child: Icon(Icons.star,
                                              color: Colors.white, size: 20),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showWallpaperOptions(
      BuildContext context, Map<String, dynamic> wallpaper) async {
    int likes = 0;
    int downloads = 0;
    String category = "Others"; // Default category
    List<String> keywords = [];

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child('wallpapers')
          .orderByChild('imageUrl')
          .equalTo(wallpaper['imagePath'])
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          likes = (value['likes'] ?? 0) as int;
          downloads = (value['downloads'] ?? 0) as int;

          // ✅ Fetch category and keywords
          category = value['category'] ?? "Others";
          keywords = (value['keywords'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
        });
      }
    } catch (e) {
      print("Error fetching wallpaper details: $e");
    }

    // ✅ Update `wallpaper` with category and keywords before passing
    wallpaper['category'] = category;
    wallpaper['keywords'] = keywords;

    print("📌 Updated Wallpaper Data Before Editing: $wallpaper");

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Icon(Icons.favorite, color: Colors.red, size: 28),
                      SizedBox(height: 5),
                      Text("$likes Likes",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.download, color: Colors.blue, size: 28),
                      SizedBox(height: 5),
                      Text("$downloads Downloads",
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              Divider(color: Colors.grey),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                title: Text("Edit Wallpaper Details",
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  showEditWallpaperDialog(context, wallpaper);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Delete Wallpaper",
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  showDeleteConfirmationDialog(context, wallpaper['imagePath']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showEditWallpaperDialog(
      BuildContext context, Map<String, dynamic> wallpaper) {
    TextEditingController nameController =
        TextEditingController(text: wallpaper['name'] ?? '');
    TextEditingController keywordController = TextEditingController();

    // ✅ Ensure `category` is fetched properly
    List<String> categories = [
      "Nature",
      "Cars",
      "Abstract",
      "Animals",
      "Technology",
      "Others"
    ];
    String selectedCategory =
        (wallpaper['category'] as String?)?.trim() ?? "Others";

    if (!categories.contains(selectedCategory)) {
      selectedCategory = "Others";
    }

    // ✅ Ensure `keywords` are fetched properly
    if (wallpaper['keywords'] != null) {
      if (wallpaper['keywords'] is List) {
        keywordController.text = (wallpaper['keywords'] as List)
            .where((item) => item != null)
            .map((item) => item.toString())
            .join(", "); // Convert List to String
      } else if (wallpaper['keywords'] is String) {
        keywordController.text = wallpaper['keywords'];
      }
    }

    bool isPremium = wallpaper['isPremium'] ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled:
          true, // Makes bottom sheet expand properly with keyboard
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 15,
                top: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    15, // Push up when keyboard appears
              ),
              child: SingleChildScrollView(
                // Prevents keyboard from overlapping fields
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Edit Wallpaper",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    _buildTextField(nameController, "Wallpaper Name"),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: Colors.black,
                        decoration: InputDecoration(
                          labelText: "Select Category",
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.purple)),
                        ),
                        style: TextStyle(color: Colors.white),
                        onChanged: (newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                        items: categories.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                      ),
                    ),
                    _buildTextField(
                        keywordController, "Keywords (comma-separated)"),
                    SwitchListTile(
                      title: Text("Premium Wallpaper",
                          style: TextStyle(color: Colors.white)),
                      value: isPremium,
                      onChanged: (value) {
                        setState(() {
                          isPremium = value;
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        updateWallpaperDetails(
                          wallpaper['imagePath'],
                          nameController.text,
                          selectedCategory,
                          keywordController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList(),
                          isPremium,
                        );
                        Navigator.pop(context);
                      },
                      child: Text("Save Changes"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white, // White text color
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
        ),
      ),
    );
  }

// Update wallpaper details in Firebase
  void updateWallpaperDetails(String imagePath, String name, String category,
      List<String> keywords, bool isPremium) async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('wallpapers');
      final snapshot =
          await ref.orderByChild('imageUrl').equalTo(imagePath).get();

      if (snapshot.exists) {
        // ✅ Extract the first matching key
        String wallpaperKey = snapshot.children.first.key!;

        // ✅ Update the wallpaper data in Firebase
        await ref.child(wallpaperKey).update({
          'name': name,
          'category': category,
          'keywords': keywords,
          'isPremium': isPremium,
        });

        // ✅ Show success message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Wallpaper updated successfully!")));

        // ✅ Refresh user wallpapers list
        fetchUserWallpapers();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Wallpaper not found!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating wallpaper: $e")));
    }
  }

  void showDeleteConfirmationDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Wallpaper"),
          content: Text(
              "Are you sure you want to delete this wallpaper? This action cannot be undone."),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                deleteWallpaper(imagePath);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

// Delete wallpaper from Firebase Storage and Realtime Database
  void deleteWallpaper(String imagePath) async {
    try {
      final ref = FirebaseDatabase.instance.ref().child('wallpapers');
      final snapshot =
          await ref.orderByChild('imageUrl').equalTo(imagePath).get();

      if (snapshot.exists) {
        final wallpaperRef = snapshot.children.first.ref;

        // Get the storage reference from the image URL
        String storagePath = Uri.decodeFull(
            Uri.parse(imagePath).pathSegments.last.split('?alt=media')[0]);

        // Delete from Firebase Storage
        await FirebaseStorage.instance.ref().child(storagePath).delete();

        // Remove from Firebase Realtime Database
        await wallpaperRef.remove();

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Wallpaper deleted successfully!")));

        // Refresh homepage
        fetchUserWallpapers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting wallpaper: $e")));
    }
  }

  Widget _buildDrawerItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
      onTap: onTap,
    );
  }
}
