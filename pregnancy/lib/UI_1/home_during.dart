import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pregnancy/UI_4/notifications.dart'; // Import the notifications page
import 'duedatecalculator.dart'; // Import the Due Date Calculator page
import 'contractiontimer.dart'; // Import the Contraction Timer page
import 'kickcounter.dart'; // Import the Kick Counter page
import 'countdowndays.dart'; // Import the CountdownDays widget
import 'guides.dart'; // Import the GuidePage
import 'articles.dart'; // Import the ArticlesPage
import '/UI_2/calendar.dart'; // Import the calendar.dart file
import '/UI_3/health.dart'; // Import the health.dart file
import '/UI_4/setting.dart'; // Import the settings.dart file

class HomeDuringPage extends StatefulWidget {
  final String userId;

  const HomeDuringPage({super.key, required this.userId});

  @override
  _HomeDuringPageState createState() => _HomeDuringPageState();
}

class _HomeDuringPageState extends State<HomeDuringPage> {
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

class HomePageContent extends StatefulWidget {
  final String userId;

  const HomePageContent({super.key, required this.userId});

  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  int _remainingDays = 50; // Default value

  @override
  void initState() {
    super.initState();
    _fetchDueDateFromFirebase();
  }

  Future<void> _fetchDueDateFromFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user_accounts')
            .doc(user.uid)
            .get();
        if (userDoc.exists && userDoc['due_date_data'] != null) {
          Map<String, dynamic> dueDateData = userDoc['due_date_data'];
          Timestamp dueDateTimestamp = dueDateData['estimatedDueDate'];
          DateTime dueDate = dueDateTimestamp.toDate();
          final now = DateTime.now();
          final difference = dueDate.difference(now).inDays;
          setState(() {
            _remainingDays = difference;
          });
        }
      }
    } catch (error) {
      print('Error fetching due date: $error');
    }
  }

  String _getBabyImage(int remainingDays) {
    if (remainingDays > 270) return 'assets/month1.png';
    if (remainingDays > 240) return 'assets/month2.png';
    if (remainingDays > 210) return 'assets/month3.png';
    if (remainingDays > 180) return 'assets/month4.png';
    if (remainingDays > 150) return 'assets/month5.png';
    if (remainingDays > 120) return 'assets/month6.png';
    if (remainingDays > 90) return 'assets/month7.png';
    if (remainingDays > 60) return 'assets/month8.png';
    if (remainingDays > 30) return 'assets/month9.png';
    return 'assets/month10.png';
  }

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
                    builder: (context) => const NotificationsPage()),
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
              CountdownDays(userId: widget.userId), // Display the CountdownDays widget
              const SizedBox(height: 32),
              Center(
                child: CircleAvatar(
                  radius: 150,
                  backgroundImage: AssetImage(_getBabyImage(_remainingDays)),
                  backgroundColor: const Color(0xFFF0C29B),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FeatureButton(
                        title: 'Due Date Calculator',
                        image: const AssetImage('assets/duedatecalculator.png'),
                        color: const Color(0xFFE3C3C3),
                        textColor: const Color(0xFF000000),
                        onTap: () {
                          // Navigate to Due Date Calculator
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    DueDateCalculatorPage(userId: widget.userId)),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FeatureButton(
                        title: 'Contraction Timer',
                        image: const AssetImage('assets/contractiontimer.png'),
                        color: const Color(0xFFC3D5E3),
                        textColor: const Color(0xFF000000),
                        onTap: () {
                          // Navigate to Contraction Timer
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ContractionTimerPage(userId: widget.userId)),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FeatureButton(
                        title: 'Kick Counter',
                        image: const AssetImage('assets/kickcounter.png'),
                        color: const Color(0xFFDAE3C3),
                        textColor: const Color(0xFF000000),
                        onTap: () {
                          // Navigate to Kick Counter feature
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    KickCounterPage(userId: widget.userId)),
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
                          context), // Pass context
                      _buildArticleTile(
                          'Picture2',
                          'Conceiving Articles',
                          'Article preview...........................................................................................................',
                          const Color(0xFFC3D5E3),
                          'assets/article2.jpg',
                          context), // Pass context
                      _buildArticleTile(
                          'Picture3',
                          'Parenting Articles',
                          'Article preview...........................................................................................................',
                          const Color(0xFFDAE3C3),
                          'assets/article3.jpg',
                          context), // Pass context
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
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
                    _buildGuideButton('Fitness Guides', const Color(0xFFE3C3C3),
                        const AssetImage('assets/fitnessguide.jpg')),
                    _buildGuideButton(
                        'Pregnancy Symptoms Guides',
                        const Color(0xFFC3D5E3),
                        const AssetImage('assets/pregnancysymptomsguide.jpg')),
                    _buildGuideButton('Nutrition Guides', const Color(0xFFDAE3C3),
                        const AssetImage('assets/nutritionguide.jpg')),
                    _buildGuideButton('Video Guides', const Color(0xFFE3D2C3),
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
      width: 150,
      height: 200,
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

  Widget _buildFeatureButton(
      BuildContext context,
      String title,
      ImageProvider<Object> image,
      Color color,
      Color textColor,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: image,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleTile(
      String picture, String title, String preview, Color color, String imagePath, BuildContext context) {
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
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            preview,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ArticlesPage()),
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: image,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
