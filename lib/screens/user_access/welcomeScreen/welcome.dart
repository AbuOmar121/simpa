import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:simpa/screens/user_access/book/booking_system.dart';
import 'package:simpa/screens/user_access/user_messaging/choose_vet.dart';
import 'package:simpa/screens/user_access/welcomeScreen/circle_pet.dart';
import 'package:simpa/screens/user_access/welcomeScreen/get_book.dart';
import 'package:simpa/screens/user_access/user/user_profile_screen.dart';
import 'package:simpa/screens/user_access/popups/add_pet_popup.dart';
import 'package:simpa/screens/user_access/notification/notifications.dart';
import 'package:simpa/screens/user_access/settings/main/settings.dart';
import 'package:simpa/screens/user_access/popups/exit_dialog.dart';
import 'package:simpa/screens/user_access/welcomeScreen/usercard.dart';
import 'package:simpa/splash.dart';

class Welcome extends StatefulWidget {
  final auth.User user;
  final int indexed;

  const Welcome({
    super.key,
    required this.user,
    this.indexed = 2,
  });

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with TickerProviderStateMixin {
  late Future<Map<String, dynamic>> _userDataFuture;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late int _selectedIndex;

  final List<String> _titles = [
    'Settings',
    'Chat',
    'Home',
    'Bookings',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.indexed;
    _userDataFuture = _fetchUserData();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _fadeController.forward();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (!doc.exists) {
        return {'error': 'User data not found'};
      }

      return doc.data()!;
    } catch (e) {
      return {'error': 'Failed to load user data'};
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => showExitConfirmationDialog(context),
      child: Scaffold(
        backgroundColor: Color(0xFFFFE1E1),
        appBar: AppBar(
          backgroundColor: Color(0xFFFF4F81),
          automaticallyImplyLeading: false,
          title: Text(
            _titles[_selectedIndex],
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(user: widget.user),
                  ),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _selectedIndex,
          color: Color(0xFFFF4F81),
          backgroundColor: Color(0xFFFFE1E1),
          animationDuration: Duration(milliseconds: 300),
          items: <Widget>[
            Icon(Icons.settings, size: 30, color: Colors.white),
            Icon(Icons.chat_bubble_outline, size: 30, color: Colors.white),
            Icon(Icons.home, size: 30, color: Colors.white),
            Icon(Icons.calendar_month, size: 30, color: Colors.white),
            Icon(Icons.person, size: 30, color: Colors.white),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_selectedIndex),
            child: _getScreen(_selectedIndex),
          ),
        ),
      ),
    );
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return SettingsScreen(user: widget.user);
      case 1:
        return ChooseVet(user: widget.user);
      case 2:
        return _mainContent();
      case 3:
        return BookingSystem(user: widget.user);

      case 4:
        return UserProfileScreen(user: widget.user);
      default:
        return SizedBox();
    }
  }

  Widget _mainContent() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Splash());
        }

        if (snapshot.hasError || snapshot.data?['error'] != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Color(0xFFF44336), size: 48),
                SizedBox(height: 16),
                Text(snapshot.data?['error'] ?? 'An error occurred'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _userDataFuture = _fetchUserData();
                    });
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final userData = snapshot.data!;
        final firstname = userData['firstName'] as String? ?? '';
        final lastName = userData['lastName'] as String? ?? '';
        final email = userData['email'] as String? ?? 'Not provided';
        final phone = userData['phone'] as String? ?? 'Not provided';

        return FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            color: Colors.pink,
            onRefresh: () async {
              setState(() {
                _userDataFuture = _fetchUserData();
              });
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12),
                    UserCard(
                      firstname: firstname,
                      lastname: lastName,
                      email: email,
                      phone: phone,
                    ),
                    _sectionTitle('Your Pets'),
                    SizedBox(height: 12),
                    CirclePet(user: widget.user),
                    SizedBox(height: 16),
                    _addPetButton(),
                    SizedBox(height: 8),
                    _sectionTitle('Upcoming Appointment'),
                    SizedBox(height: 12),
                    GetBook(user: widget.user),
                    SizedBox(height: 64),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F1F1F),
          ),
        ),
      ),
    );
  }

  Widget _addPetButton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          showAddPetPopup(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_sharp, size: 20, color: Colors.pink),
            SizedBox(width: 4),
            Text(
              'Add New Pet',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
