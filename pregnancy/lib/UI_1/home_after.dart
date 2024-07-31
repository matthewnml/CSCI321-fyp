import 'package:flutter/material.dart';
import 'package:pregnancy/UI_2/calendar.dart';
import 'package:pregnancy/UI_3/health.dart';
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: const Text(
                          'Articles',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(), // Added a divider below the Articles heading
                      _buildArticleTile(
                          'Picture1',
                          'Female Health Articles',
                          'Article preview...........................................................................................................',
                          const Color(0xFFE3D2C3),
                          'assets/article1.jpg',
                          context), // Pass context here
                      _buildArticleTile(
                          'Picture2',
                          'Conceiving Articles',
                          'Article preview...........................................................................................................',
                          const Color(0xFFC3D5E3),
                          'assets/article2.jpg',
                          context), // Pass context here
                      _buildArticleTile(
                          'Picture3',
                          'Parenting Articles',
                          'Article preview...........................................................................................................',
                          const Color(0xFFDAE3C3),
                          'assets/article3.jpg',
                          context), // Pass context here
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Handle "See more" button press
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ArticlesPage()),
                            );
                          },
                          child: const Text('See more',
                              style: TextStyle(color: Color(0xFF000000))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Guides',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Navigate to the Guides List page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GuidesPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGuideButton('Guide 1', const Color(0xFFE3C3C3),
                        const AssetImage('assets/fitnessguide.jpg')),
                    _buildGuideButton(
                        'Guide 2',
                        const Color(0xFFC3D5E3),
                        const AssetImage('assets/pregnancysymptomsguide.jpg')),
                    _buildGuideButton('Guide 3', const Color(0xFFDAE3C3),
                        const AssetImage('assets/nutritionguide.jpg')),
                    _buildGuideButton('Guide 4', const Color(0xFFE3D2C3),
                        const AssetImage('assets/videoguide.jpg')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideButton(
      String title, Color color, ImageProvider<Object> image) {
    return Container(
      width: 80,
      height: 80,
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
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleTile(String picture, String title, String previewText,
      Color color, String imagePath, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(previewText),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ArticlesPage()),
          );
        },
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


