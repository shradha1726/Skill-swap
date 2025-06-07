import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final List<Map<String, String>> profiles = [
    {
      'name': 'Alice',
      'skillsOffered': 'C++, Python',
      'skillsWanted': 'Graphic Design',
      'availability': 'Weekends',
      'imageUrl': 'https://randomuser.me/api/portraits/women/65.jpg',
    },
    {
      'name': 'Bob',
      'skillsOffered': 'Java Programming, GitHub',
      'skillsWanted': 'Javascript',
      'availability': 'Weekdays',
      'imageUrl': 'https://randomuser.me/api/portraits/men/43.jpg',
    },
    {
      'name': 'Charlie',
      'skillsOffered': 'Cloud Computing',
      'skillsWanted': 'Cyber Security',
      'availability': 'Evenings',
      'imageUrl': 'https://randomuser.me/api/portraits/men/52.jpg',
    },
  ];

  final CardSwiperController _controller = CardSwiperController();

  FutureOr<bool> _onSwipe(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final profile = profiles[previousIndex];
    String action = '';
    switch (direction) {
      case CardSwiperDirection.right:
        action = 'Liked';
        break;
      case CardSwiperDirection.left:
        action = 'Disliked';
        break;
      case CardSwiperDirection.top:
        action = 'Super liked';
        break;
      case CardSwiperDirection.bottom:
        action = 'Skipped';
        break;
      case CardSwiperDirection.none:
        throw UnimplementedError();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action ${profile['name']}')),
    );
    return true; // Allow swipe to proceed
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Skills'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CardSwiper(
                controller: _controller,
                cardsCount: profiles.length,
                cardBuilder: (context, index, hThreshold, vThreshold) {
                  final profile = profiles[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: Image.network(
                              profile['imageUrl']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile['name']!,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                  'Skills Offered: ${profile['skillsOffered']}'),
                              Text('Skills Wanted: ${profile['skillsWanted']}'),
                              Text('Availability: ${profile['availability']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onSwipe: _onSwipe,
                onEnd: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No more profiles')),
                  );
                },
                numberOfCardsDisplayed: 3,
                padding: const EdgeInsets.all(24),
                backCardOffset: const Offset(40, 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'dislike',
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.close),
                    onPressed: () =>
                        _controller.swipe(CardSwiperDirection.left),
                  ),
                  FloatingActionButton(
                    heroTag: 'like',
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.favorite),
                    onPressed: () =>
                        _controller.swipe(CardSwiperDirection.right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
