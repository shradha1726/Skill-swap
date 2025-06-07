import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'swipe_screen.dart'; // Import your SwipeScreen
import 'chat_overview_screen.dart'; // Import your ChatOverviewScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  int _selectedIndex = 0;

  // Keys for nested navigators for each tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onTap(int index) {
    if (index == _selectedIndex) {
      // Pop to first route if reselecting tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) {
          Widget page;
          switch (index) {
            case 0:
              page = const SwipeScreen();
              break;
            case 1:
              page = const ChatOverviewScreen(
                chatUserId: '',
                chatUserName: '',
              );
              break;
            default:
              page = const SwipeScreen();
          }
          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_user?.displayName ?? 'User'),
              accountEmail: Text(_user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade700,
                child: Text(
                  (_user?.displayName?.isNotEmpty ?? false)
                      ? _user!.displayName![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View/Edit Profile'),
              onTap: () {
                Navigator.pop(context); // close drawer
                Navigator.pushNamed(context, '/profileSettings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context); // close drawer
                await _signOut();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _buildOffstageNavigator(0),
          _buildOffstageNavigator(1),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Swipe',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}
