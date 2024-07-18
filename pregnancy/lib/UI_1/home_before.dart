import 'package:flutter/material.dart';
import 'notification_history.dart'; // Import the notifications page
import 'ivfinjection.dart'; // Import the IVF Injection page
import 'guides.dart'; // Import the GuidePage
import 'articles.dart'; // Import the ArticlesPage
import '/UI_2/calendar.dart'; // Import the calendar.dart file
import '/UI_3/health.dart'; // Import the health.dart file
import '/UI_4/setting.dart'; // Import the settings.dart file

class HomeBeforePage extends StatefulWidget {
  final String userId;

  const HomeBeforePage({super.key, required this.userId});

  @override
  _HomeBeforePageState createState() => _HomeBeforePageState();
}

class _HomeBeforePageState extends State<HomeBeforePage> {
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
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
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
                    // Navigate to IVF Injection feature
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IVFInjectionTrackerPage(userId: userId)),
                    );
                  },
                ),
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
                        'Article preview..................................................................................',
                        const Color(0xFFE3D2C3),
                        'assets/article1.jpg',
                        context,
                      ),
                      _buildArticleTile(
                        'Picture2',
                        'Conceiving Articles',
                        'Article preview..................................................................................',
                        const Color(0xFFC3D5E3),
                        'assets/article2.jpg',
                        context,
                      ),
                      _buildArticleTile(
                        'Picture3',
                        'Parenting Articles',
                        'Article preview..................................................................................',
                        const Color(0xFFDAE3C3),
                        'assets/article3.jpg',
                        context,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ArticlesPage()),
                            );
                          },
                          child: const Text('See more', style: TextStyle(color: Color(0xFF000000))),
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
                    MaterialPageRoute(builder: (context) => const GuidesPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGuideButton(
                      'Guide 1',
                      const Color(0xFFE3C3C3),
                      const AssetImage('assets/fitnessguide.jpg'),
                      context,
                    ),
                    _buildGuideButton(
                      'Guide 2',
                      const Color(0xFFC3D5E3),
                      const AssetImage('assets/pregnancysymptomsguide.jpg'),
                      context,
                    ),
                    _buildGuideButton(
                      'Guide 3',
                      const Color(0xFFDAE3C3),
                      const AssetImage('assets/nutritionguide.jpg'),
                      context,
                    ),
                    _buildGuideButton(
                      'Guide 4',
                      const Color(0xFFE3D2C3),
                      const AssetImage('assets/videoguide.jpg'),
                      context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideButton(String title, Color color, ImageProvider<Object> image, BuildContext context) {
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

  Widget _buildArticleTile(String picture, String title, String preview, Color color, String imagePath, BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(imagePath), // Updated to use Image.asset
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            preview,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ArticlesPage()),
            );
          },
        ),
        const Divider(), // Add a divider between each article
      ],
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
