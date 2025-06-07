import 'package:flutter/material.dart';

void main() {
  runApp(const SwipeScreen());
}

class SwipeScreen extends StatelessWidget {
  const SwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swipe Profiles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          headline4: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black87),
          bodyText1: TextStyle(fontSize: 18, color: Colors.black87),
          bodyText2: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
      home: const SwipeProfilesScreen(),
    );
  }
}

class UserProfile {
  final String username;
  final String skillsOffered;
  final String skillsWanted;
  final String availability;

  UserProfile({
    required this.username,
    required this.skillsOffered,
    required this.skillsWanted,
    required this.availability,
  });
}

class SwipeProfilesScreen extends StatefulWidget {
  const SwipeProfilesScreen({super.key});

  @override
  State<SwipeProfilesScreen> createState() => _SwipeProfilesScreenState();
}

class _SwipeProfilesScreenState extends State<SwipeProfilesScreen>
    with SingleTickerProviderStateMixin {
  final List<UserProfile> profiles = [
    UserProfile(
      username: 'Alice Johnson',
      skillsOffered: 'Flutter, Dart, UI Design',
      skillsWanted: 'Firebase, Backend',
      availability: 'Weekdays, 9 AM - 5 PM',
    ),
    UserProfile(
      username: 'Bob Smith',
      skillsOffered: 'Firebase, Node.js, Backend',
      skillsWanted: 'Flutter, UX Design',
      availability: 'Weekends, Flexible',
    ),
    UserProfile(
      username: 'Clara Lee',
      skillsOffered: 'React, JavaScript',
      skillsWanted: 'Dart, Flutter',
      availability: 'Evenings',
    ),
  ];

  int currentIndex = 0;
  Offset cardOffset = Offset.zero;
  double rotation = 0.0;
  String swipeStatus = ''; // 'like', 'pass', or ''

  void onPanUpdate(DragUpdateDetails details) {
    setState(() {
      cardOffset += details.delta;
      rotation = cardOffset.dx / 350; // gentle rotation
      if (cardOffset.dx > 120) {
        swipeStatus = 'like';
      } else if (cardOffset.dx < -120) {
        swipeStatus = 'pass';
      } else {
        swipeStatus = '';
      }
    });
  }

  void onPanEnd(DragEndDetails details) {
    if (swipeStatus == 'like') {
      _showSnackBar('Liked ${profiles[currentIndex].username}');
      _nextProfile();
    } else if (swipeStatus == 'pass') {
      _showSnackBar('Passed ${profiles[currentIndex].username}');
      _nextProfile();
    } else {
      // Animate card back to center
      setState(() {
        cardOffset = Offset.zero;
        rotation = 0.0;
        swipeStatus = '';
      });
    }
  }

  void _nextProfile() {
    setState(() {
      cardOffset = Offset.zero;
      rotation = 0.0;
      swipeStatus = '';
      currentIndex = (currentIndex + 1) % profiles.length;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget _buildBadge(String text, Color color, Alignment alignment,
      {double rotationAngle = 0.0}) {
    return Align(
      alignment: alignment,
      child: Transform.rotate(
        angle: rotationAngle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 4),
            borderRadius: BorderRadius.circular(12),
            color: color.withOpacity(0.1),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = profiles[currentIndex];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Profiles'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: GestureDetector(
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.identity()
              ..translate(cardOffset.dx, cardOffset.dy)
              ..rotateZ(rotation),
            curve: Curves.easeOut,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    width: 340,
                    height: 460,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.username,
                            style: theme.textTheme.headline4),
                        const SizedBox(height: 24),
                        Text('Skills Offered',
                            style: theme.textTheme.bodyText2!
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(profile.skillsOffered,
                            style: theme.textTheme.bodyText1),
                        const SizedBox(height: 20),
                        Text('Skills Wanted',
                            style: theme.textTheme.bodyText2!
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(profile.skillsWanted,
                            style: theme.textTheme.bodyText1),
                        const SizedBox(height: 20),
                        Text('Availability',
                            style: theme.textTheme.bodyText2!
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(profile.availability,
                            style: theme.textTheme.bodyText1),
                        const Spacer(),
                        Center(
                          child: Icon(
                            Icons.account_circle,
                            size: 120,
                            color: Colors.blue.shade100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (swipeStatus == 'like')
                  _buildBadge('LIKE', Colors.green, Alignment.topLeft,
                      rotationAngle: -0.4),
                if (swipeStatus == 'pass')
                  _buildBadge('PASS', Colors.red, Alignment.topRight,
                      rotationAngle: 0.4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
