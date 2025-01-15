import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_wallpaper/screens/collection_page.dart';
import 'package:my_wallpaper/screens/omg_page.dart';
import 'package:my_wallpaper/screens/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_wallpaper/screens/wallpaper_upload_screen.dart';
import 'package:my_wallpaper/screens/registration_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int myCurrentIndex = 0;
  List pages = [
    HomeScreen(),
    OmgPage(),
    CollectionPage(),
  ];
  int _currentTabIndex = 0;
  bool _isScrollingDown = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!_isScrollingDown) {
          setState(() {
            _isScrollingDown = true;
          });
        }
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (_isScrollingDown) {
          setState(() {
            _isScrollingDown = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category, color: Colors.white),
            onPressed: () {
              CollectionPage.showCategoryDialog(context);
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "Default"),
                Tab(text: "Latest"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildWallpaperGrid("default"),
                  _buildWallpaperGrid("latest"),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.redAccent,
              unselectedItemColor: Colors.black,
              currentIndex: myCurrentIndex,
              onTap: (index) async {
                setState(() {
                  myCurrentIndex = index;
                });

                if (index == 2) {
                  // Upload button tapped
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    // User is logged in, navigate to WallpaperUploadScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WallpaperUploadForm(), // Replace with actual screen
                      ),
                    );
                  } else {
                    // User is not logged in, show a snackbar or dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Please log in first to upload wallpapers."),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else if (index == 3) {
                  // Profile button tapped
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    // User is logged in, navigate to ProfilePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          onNavigateToHome: () {
                            setState(() {
                              myCurrentIndex = 0; // Reset index to Home
                            });
                            Navigator.pop(context); // Close the ProfilePage
                          },
                        ),
                      ),
                    );
                  } else {
                    // User is not logged in, navigate to SignUpPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SignUpScreen(), // Replace with your sign-up page
                      ),
                    );
                  }
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.search), label: "Search"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.upload), label: "Upload"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: "Profile")
              ]),
        ),
      ),
    );
  }

  Widget _buildWallpaperGrid(String type) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
          ),
          items: ["New Arrivals", "Most Downloaded"].map((bannerText) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      bannerText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Expanded(
          child: Stack(
            children: [
              GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                  top: 8.0,
                  bottom:
                      0.0, // Reduced padding to extend content below the navigation bar
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: 20, // Replace with dynamic count
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: Text(
                        "Wallpaper $index",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 40.0,
                  color: Colors.transparent, // Ensure no visual conflict
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
