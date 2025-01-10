import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_wallpaper/screens/collection_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            icon: Icon(Icons.category, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CollectionPage(),
                ),
              );
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
      bottomNavigationBar: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height:
            _isScrollingDown ? 0 : 70, // Height adjustment for floating effect
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), // Transparent white
            borderRadius: BorderRadius.circular(40.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2), // Floating shadow
                blurRadius: 15.0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.0),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: _currentTabIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: "Search",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.upload_file),
                  label: "Upload",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.black54,
            ),
          ),
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
          child: GridView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(8.0),
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
        ),
      ],
    );
  }
}
