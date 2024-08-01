import 'package:flutter/material.dart';
import 'package:pregnancy/UI_4/notificationpage.dart'; // Import the notifications page
import 'ivfinjection.dart'; // Import the IVF Injection page
import 'guides.dart'; // Import the GuidesPage
import 'articles.dart'; // Import the ArticlesPage
import '/UI_2/calendar.dart'; // Import the calendar.dart file
import '/UI_3/health_user.dart'; // Import the health.dart file
import '/UI_4/setting.dart'; // Import the settings.dart file

class HomeSpecialistPage extends StatefulWidget {
  final String userId;

  const HomeSpecialistPage({super.key, required this.userId});

  @override
  _HomeSpecialPageState createState() => _HomeSpecialPageState();
}

class _HomeSpecialPageState extends State<HomeSpecialistPage> {
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
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
              Center(
                child: FeatureButton(
                  title: 'IVF Injection',
                  image: const AssetImage('assets/ivfinjection.png'),
                  color: const Color(0xFFE3C3C3),
                  textColor: const Color(0xFF000000),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IVFInjectionTrackerPage(userId: userId)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
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
                          MaterialPageRoute(builder: (context) => ArticlesPage()),
                        );
                      },
                      child: _buildArticleTile(
                          'Articles', const Color(0xFFE3C3C3), 'assets/article1.jpg'),
                    ),
                  ),
                  const SizedBox(width: 16), // Space between article and guide
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GuidesPage()),
                        );
                      },
                      child: _buildGuideButton(
                          'Guides', const Color(0xFFE3C3C3), const AssetImage('assets/fitnessguide.jpg')),
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

  Widget _buildGuideButton(String title, Color color, ImageProvider<Object> image) {
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
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
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

  Widget _buildArticleTile(String title, Color color, String imagePath) {
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
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
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
  final ImageProvider<Object> image;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const FeatureButton({
    super.key,
    required this.title,
    required this.image,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Image(image: image, width: 100, height: 100),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}