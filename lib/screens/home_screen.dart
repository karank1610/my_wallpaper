import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_wallpaper/screens/collection_page.dart';
import 'package:my_wallpaper/screens/omg_page.dart';
import 'profile_page.dart'; // Import the ProfilePage file

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0; // Tracks the selected tab (fragment)
  late Timer _rotationTimer;
  int _currentCollectionIndex = 0;
  late TabController _tabController;

  final List<Map<String, String>> collections = [
    {'title': 'Super Car Collection', 'image': 'assets/car.jpg'},
    {'title': 'Beautiful Sky', 'image': 'assets/sky.jpg'},
    {'title': 'Abstract Art', 'image': 'assets/abstract.jpg'},
    {'title': 'Explore Space', 'image': 'assets/space.jpg'},
  ];

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
    _rotationTimer.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Switch between HomeScreen and ProfilePage
        children: [
          _buildHomePage(),
          CollectionPage(),
          OmgPage(),
          ProfilePage(), // Add ProfilePage as another screen in the IndexedStack
        ],
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

  Widget _buildHomePage() {
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: images.map((image) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      image,
                      height: 165,
                      width: 115,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
