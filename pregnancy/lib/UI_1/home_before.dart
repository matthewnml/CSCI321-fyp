import 'package:flutter/material.dart';
import 'package:pregnancy/UI_4/notificationpage.dart'; // Import the notifications page
import 'ivfinjection.dart'; // Import the IVF Injection page // Import the ArticlesPage
import '/UI_2/calendar.dart'; // Import the calendar.dart file
import '/UI_3/health_user.dart'; // Import the health.dart file
import '/UI_4/setting.dart'; // Import the settings.dart file
import 'nutrition_guides_page.dart'; // Import the NutritionGuidesPage
import 'fitness_guides_page.dart'; // Import the FitnessGuidesPage
import 'pregnancy_symptoms_guides_page.dart'; // Import the PregnancySymptomsGuidesPage
import 'video_guides_page.dart'; // Import the VideoGuidesPage
import 'female_health_articles_page.dart';
import 'conceiving_articles_page.dart';
import 'parenting_articles_page.dart';


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
    _pages = [
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FemaleHealthArticlesPage()),
                          );
                        },
                        child: _buildArticleTile(
                          'Picture1',
                          'Female Health Articles',
                          'Article preview...........................................................................................................',
                          const Color(0xFFE3D2C3),
                          'assets/article1.jpg',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ConceivingArticlesPage()),
                          );
                        },
                        child: _buildArticleTile(
                          'Picture2',
                          'Conceiving Articles',
                          'Article preview...........................................................................................................',
                          const Color(0xFFC3D5E3),
                          'assets/article2.jpg',
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ParentingArticlesPage()),
                          );
                        },
                        child: _buildArticleTile(
                          'Picture3',
                          'Parenting Articles',
                          'Article preview...........................................................................................................',
                          const Color(0xFFDAE3C3),
                          'assets/article3.jpg',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FitnessGuidesPage()),
                      );
                    },
                    child: _buildGuideButton(
                      'Fitness Guides',
                      const Color(0xFFE3C3C3),
                      const AssetImage('assets/fitnessguide.jpg'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PregnancySymptomsGuidesPage()),
                      );
                    },
                    child: _buildGuideButton(
                      'Pregnancy Symptoms Guides',
                      const Color(0xFFC3D5E3),
                      const AssetImage('assets/pregnancysymptomsguide.jpg'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NutritionGuidesPage()),
                      );
                    },
                    child: _buildGuideButton(
                      'Nutrition Guides',
                      const Color(0xFFDAE3C3),
                      const AssetImage('assets/nutritionguide.jpg'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VideoGuidesPage()),
                      );
                    },
                    child: _buildGuideButton(
                      'Video Guides',
                      const Color(0xFFE3D2C3),
                      const AssetImage('assets/videoguide.jpg'),
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
      width: 150,
      height: 200,
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

  Widget _buildArticleTile(
    String picture,
    String title,
    String preview,
    Color color,
    String imagePath, {
    Widget? child,
  }) {
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
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            preview,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
        ),
        const Divider(), // Add a divider between each article
        if (child != null) child,
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
