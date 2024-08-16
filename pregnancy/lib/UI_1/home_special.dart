import 'package:flutter/material.dart';
import 'package:pregnancy/UI_1/article_management.dart';
import 'package:pregnancy/UI_1/guide_management.dart'; 
import 'package:pregnancy/UI_4/notification_page.dart'; // Import the notifications page
import '/UI_2/calendar.dart'; // Import the calendar.dart file
import '/UI_3/health_specialist.dart'; // Import the health_specialist.dart file
import '/UI_4/setting.dart'; // Import the settings.dart file
import 'nutrition_guides_page.dart'; // Import the NutritionGuidesPage
import 'fitness_guides_page.dart'; // Import the FitnessGuidesPage
import 'pregnancy_symptoms_guides_page.dart'; // Import the PregnancySymptomsGuidesPage
import 'video_guides_page.dart'; // Import the VideoGuidesPage
import 'female_health_articles_page.dart'; // Import the FemaleHealthArticlesPage
import 'conceiving_articles_page.dart'; // Import the ConceivingArticlesPage
import 'parenting_articles_page.dart'; // Import the ParentingArticlesPage

class HomeSpecialistPage extends StatefulWidget {
  final String userId;

  const HomeSpecialistPage({super.key, required this.userId});

  @override
  _HomeSpecialistPageState createState() => _HomeSpecialistPageState();
}

class _HomeSpecialistPageState extends State<HomeSpecialistPage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      HomePageContent(userId: widget.userId),
      const CalendarScreen(),
      const HealthSpecialistScreen(),
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildActionButtons(context),
          const SizedBox(height: 32),
          _buildArticlesSection(context),
          const SizedBox(height: 32),
          _buildGuidesSection(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArticleManagement()),
              );
            },
            child: const Text('Add Articles'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 133, 155, 173), // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GuideManagement()),
              );
            },
            child: const Text('Add Guides'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 133, 155, 173), // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticlesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Articles',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FemaleHealthArticlesPage()),
            );
          },
          child: _buildArticleTile(
            'Female Health Articles',
            const Color(0xFFE3D2C3),
            'assets/article1.jpg',
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConceivingArticlesPage()),
            );
          },
          child: _buildArticleTile(
            'Conceiving Articles',
            const Color(0xFFC3D5E3),
            'assets/article2.jpg',
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ParentingArticlesPage()),
            );
          },
          child: _buildArticleTile(
            'Parenting Articles',
            const Color(0xFFDAE3C3),
            'assets/article3.jpg',
          ),
        ),
      ],
    );
  }

  Widget _buildGuidesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guides',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
              Wrap(
                spacing: 16.0, // Space between the guide buttons horizontally
                runSpacing: 16.0, // Space between the rows vertically
          children: [
            _buildGuideButton(
              context,
              'Fitness Guides',
              const Color(0xFFE3C3C3),
              'assets/fitnessguide.jpg',
              const FitnessGuidesPage(),
            ),
            _buildGuideButton(
              context,
              'Pregnancy Symptoms Guides',
              const Color(0xFFC3D5E3),
              'assets/pregnancysymptomsguide.jpg',
              const PregnancySymptomsGuidesPage(),
            ),
            _buildGuideButton(
              context,
              'Nutrition Guides',
              const Color(0xFFDAE3C3),
              'assets/nutritionguide.jpg',
              const NutritionGuidesPage(),
            ),
            _buildGuideButton(
              context,
              'Video Guides',
              const Color(0xFFE3D2C3),
              'assets/videoguide.jpg',
              const VideoGuidesPage(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArticleTile(
    String title,
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
            child: Image.asset(imagePath),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const Divider(),
        if (child != null) child,
      ],
    );
  }

  Widget _buildGuideButton(
    BuildContext context,
    String title,
    Color color,
    String imagePath,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
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
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}