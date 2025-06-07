import 'package:flutter/material.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 120;

    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text('It\'s a Match!'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Match Icon or Animation Placeholder
            Icon(
              Icons.favorite,
              color: Colors.pinkAccent.shade400,
              size: 100,
            ),
            const SizedBox(height: 24),

            // Match Text
            const Text(
              'You and Alex have liked each other',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 40),

            // Avatars side by side with overlap
            SizedBox(
              height: avatarSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    child: CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/women/65.jpg'),
                    ),
                  ),
                  Positioned(
                    left: avatarSize * 0.6,
                    child: CircleAvatar(
                      radius: avatarSize / 2,
                      backgroundImage: NetworkImage(
                          'https://randomuser.me/api/portraits/men/43.jpg'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Send Message Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.message),
                  label: const Text(
                    'Send Message',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () {},
                ),

                // Keep Swiping Button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.deepPurple.shade300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Keep Swiping',
                    style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
