import 'package:flutter/material.dart';
import 'package:pregnancy/UI_4/notificationpage.dart';// Import the notifications page
import 'duedatecalculator.dart'; // Import the Due Date Calculator page
import 'contractiontimer.dart'; // Import the Contraction Timer page
import 'kickcounter.dart'; // Import the Kick Counter page
import 'countdowndays.dart'; // Import the CountdownDays widget
import 'ivfinjection.dart'; // Import the IVF Injection page
// Import the GuidePage
import '/UI_2/calendar.dart'; // Import the calendar.dart file
import '/UI_3/health.dart'; // Import the health.dart file
import '/UI_4/setting.dart'; // Import the settings.dart file

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              const CountdownDays(userId: '',), // Display the CountdownDays widget
              const SizedBox(height: 32),
              const Center(
                child: CircleAvatar(
                  radius: 150,
                  backgroundImage: AssetImage('assets/bumpphoto.png'),
                  backgroundColor: Color(0xFFF0C29B),
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
                                    DueDateCalculatorPage(userId: userId)),
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
                                    ContractionTimerPage(userId: userId)),
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
                                    KickCounterPage(userId: userId)),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: FeatureButton(
                        title: 'IVF Injection',
                        image: const AssetImage('assets/ivfinjection.png'),
                        color: const Color(0xFFE3D2C3),
                        textColor: const Color(0xFF000000),
                        onTap: () {
                          // Navigate to IVF Injection feature
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    IVFInjectionTrackerPage(userId: userId)),
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
                          'Title 1',
                          'Article preview...........................................................................................................',
                          const Color(0xFFE3D2C3)),
                      _buildArticleTile(
                          'Picture2',
                          'Title 2',
                          'Article preview...........................................................................................................',
                          const Color(0xFFC3D5E3)),
                      _buildArticleTile(
                          'Picture3',
                          'Title 3',
                          'Article preview...........................................................................................................',
                          const Color(0xFFDAE3C3)),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // Handle "See more" button press
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGuideButton('Guide 1', const Color(0xFFE3C3C3),
                      const AssetImage('assets/fitnessguide.jpg')),
                  _buildGuideButton('Guide 2', const Color(0xFFC3D5E3),
                      const AssetImage('assets/pregnancysymptomsguide.jpg')),
                  _buildGuideButton('Guide 3', const Color(0xFFDAE3C3),
                      const AssetImage('assets/nutritionguide.jpg')),
                  _buildGuideButton('Guide 4', const Color(0xFFE3D2C3),
                      const AssetImage('assets/videoguide.jpg')),
                ],
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
                  image: DecorationImage(
                    image: image,
                    fit: BoxFit
                        .cover, // Use BoxFit.cover to make the image fill the entire space
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
      String picture, String title, String preview, Color color) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                picture,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
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
        ), // Add a divider between each article
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
