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
  const HomeScreen({super.key});

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
    _tabController = TabController(length: 2, vsync: this);

    _rotationTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentCollectionIndex =
            (_currentCollectionIndex + 1) % collections.length;
      });
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.collections), label: 'Collection'),
          BottomNavigationBarItem(icon: Icon(Icons.whatshot), label: 'OMG'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Me'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Set the correct index for the selected tab
          });
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildWallpaperGrid(String type) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Padding(
            padding: const EdgeInsets.only(top: 35),
            child: Container(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search wallpapers...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(text: 'Wallpapers'),
            Tab(text: 'Live Wallpapers'),
          ],
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCollection(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCircularOption('Hot', Icons.local_fire_department),
                    _buildCircularOption('New', Icons.new_releases),
                    _buildCircularOption('Trending', Icons.trending_up),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '🔥 Explore trending wallpapers now!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildWallpaperCategory('Nature', [
                  'assets/wallpaper1.jpg',
                  'assets/wallpaper2.jpg',
                  'assets/wallpaper3.jpg'
                ]),
                _buildWallpaperCategory('Cars', [
                  'assets/wallpaper4.jpg',
                  'assets/wallpaper5.jpg',
                  'assets/wallpaper6.jpg'
                ]),
                _buildWallpaperCategory('Abstract Art', [
                  'assets/abstract.jpg',
                  'assets/animals.jpg',
                  'assets/nature.jpg'
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              collections[_currentCollectionIndex]['image']!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          left: 10,
          bottom: 20,
          child: Text(
            collections[_currentCollectionIndex]['title']!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          right: 10,
          bottom: 11,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: Colors.black.withOpacity(0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              // Navigate to view wallpapers
            },
            child: Text(
              'View',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircularOption(String label, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.blue,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildWallpaperCategory(String title, List<String> images) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to view all wallpapers in this category
                },
                child: Text(
                  'View All',
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
