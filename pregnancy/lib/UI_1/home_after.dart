import 'package:flutter/material.dart';
import 'package:pregnancy/UI_2/calendar.dart';
import 'package:pregnancy/UI_3/health_user.dart';
import 'package:pregnancy/UI_4/setting.dart';
import 'package:pregnancy/UI_4/notificationpage.dart'; // Import the notifications page
import 'babydevelopment.dart'; // Import the Baby Development page
import 'guides.dart'; // Import the GuidePage
import 'articles.dart'; // Import the ArticlesPage

class HomeAfterPage extends StatefulWidget {
  final String userId;

  const HomeAfterPage({super.key, required this.userId});

  @override
  _HomeAfterPageState createState() => _HomeAfterPageState();
}

class _HomeAfterPageState extends State<HomeAfterPage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      HomePageContent(userId: widget.userId),
      const CalendarScreen(),
      const HealthScreen(),
      SettingsScreen(userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final String userId;

  const HomePageContent({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF4F4),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Navigate to the notifications page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationPage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: const Color(0xFFFFF4F4),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Baby Development Section
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FeatureButton(
                        title: 'Baby Development',
                        image: const AssetImage('assets/babydevelopment.jpg'),
                        color: const Color(0xFFE3C3C3),
                        textColor: const Color(0xFF000000),
                        onTap: () {
                          // Navigate to Baby Development
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BabyDevelopmentPage(userId: userId)),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Articles & Guides Section
              const Text(
                'Articles & Guides',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ArticlesPage()),
                        );
                      },
                      child: _buildArticleTile(
                        'Articles',
                        const Color(0xFFE3C3C3),
                        'assets/article1.jpg',
                        context,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between article and guide
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GuidesPage()),
                        );
                      },
                      child: _buildGuideButton(
                        'Guides',
                        const Color(0xFFE3C3C3),
                        const AssetImage('assets/fitnessguide.jpg'),
                        context,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideButton(String title, Color color, ImageProvider<Object> image, BuildContext context) {
    return Container(
      width: 100,
      height: 450,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: image,
                    fit: BoxFit.cover, // Use BoxFit.cover to make the image fill the entire space
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleTile(String title, Color color, String imagePath, BuildContext context) {
    return Container(
      width: 100,
      height: 450,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover, // Use BoxFit.cover to make the image fill the entire space
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureButton extends StatelessWidget {
  final String title;
  final AssetImage image;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const FeatureButton(
      {super.key,
      required this.title,
      required this.image,
      required this.color,
      required this.textColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image(image: image, height: 50, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
                color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}


