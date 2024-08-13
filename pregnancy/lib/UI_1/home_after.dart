import 'package:flutter/material.dart';
import 'package:pregnancy/UI_2/calendar.dart';
import 'package:pregnancy/UI_3/health_user.dart';
import 'package:pregnancy/UI_4/setting.dart';
import 'package:pregnancy/UI_4/notification_page.dart'; // Import the notifications page
import 'babydevelopment.dart'; // Import the Baby Development page
import 'nutrition_guides_page.dart'; // Import the NutritionGuidesPage
import 'fitness_guides_page.dart'; // Import the FitnessGuidesPage
import 'pregnancy_symptoms_guides_page.dart'; // Import the PregnancySymptomsGuidesPage
import 'video_guides_page.dart'; // Import the VideoGuidesPage
import 'female_health_articles_page.dart';
import 'conceiving_articles_page.dart';
import 'parenting_articles_page.dart';

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
              // Navigate to the notifications page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
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
              // Congratulatory message inside a white text box
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  "Congratulations on Your Child's Birth!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: CircleAvatar(
                  radius: 150,
                  backgroundImage: AssetImage('assets/month10.png'), // Ensure the image path is correct
                  backgroundColor: const Color(0xFFF0C29B),
                ),
              ),
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
                        image: const AssetImage('assets/babydevelopment.png'),
                        color: const Color(0xFFE3C3C3),
                        textColor: const Color(0xFF000000),
                        onTap: () {
                          // Navigate to Baby Development
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BabyDevelopmentPage(userId: userId),
                            ),
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
                          '',
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
                          '',
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
                          '',
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
              Wrap(
                spacing: 16.0, // Space between the guide buttons horizontally
                runSpacing: 16.0, // Space between the rows vertically
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
  final AssetImage image;
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
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
