import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/pages/pets/pet_profile.dart';
import 'package:simpa/pages/user/user_profile_screen.dart';
import 'package:simpa/popups/add_pet_popup.dart';
import 'package:simpa/pages/settings.dart';
import 'package:simpa/pages/welcomeScreen/usercard.dart';

class Welcome extends StatefulWidget {
  final User user;
  const Welcome({super.key, required this.user});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  late Future<Map<String, dynamic>> _userDataFuture;
  late Future<List<Pet>> _petsFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
    _petsFuture = _fetchPetsData();
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

  Future<List<Pet>> _fetchPetsData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('ownerId', isEqualTo: widget.user.uid)
          .get();

      return querySnapshot.docs.map((doc) {
        return Pet.fromDocumentSnapshot(doc);
      }).toList();
    } catch (e) {
      return []; // Return an empty list on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE1E1),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color(0xFFFF4F81),
        automaticallyImplyLeading: false,
        title: Text(
          'Simpa',
          style: TextStyle(
            fontFamily: 'Inter Tight',
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(user: widget.user),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data?['error'] != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Color(0xFFF44336), size: 48),
                  SizedBox(height: 16),
                  Text(
                    snapshot.data?['error'] ?? 'An error occurred',
                  ),
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

          return Container(
            color: Color(0xFFFFE1E1),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User card
                    UserCard(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UserProfileScreen(user: widget.user),
                          ),
                        );
                      },
                      firstname: firstname,
                      lastname: lastName,
                      email: email,
                      phone: phone,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          'Your Pets',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: Color.fromRGBO(0, 0, 0, 0.125),
                            offset: Offset(0, 2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FutureBuilder<List<Pet>>(
                        future: _petsFuture,
                        builder: (context, petsSnapshot) {
                          if (petsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (petsSnapshot.hasError ||
                              petsSnapshot.data == null) {
                            return Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  'Failed to load pets',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromRGBO(31, 31, 31, 1),
                                  ),
                                ),
                              ),
                            );
                          }

                          final pets = petsSnapshot.data!;
                          if (pets.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  'There are no pets',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromRGBO(31, 31, 31, 1),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: pets.map((pet) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PetsProfile(
                                            pet: pet,
                                            user: widget.user,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Color(0xFFB2B2B2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/images/animal.jpeg',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(Icons.pets,
                                                      size: 60,
                                                      color: Colors.grey);
                                                },
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    pet.petName,
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromRGBO(
                                                          31, 31, 31, 1),
                                                    ),
                                                  ),
                                                  Text(
                                                    pet.petType,
                                                    style: TextStyle(
                                                      fontFamily: 'Manrope',
                                                      fontSize: 14,
                                                      color: Color.fromRGBO(
                                                          31, 31, 31, 1),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            color:
                                                Color.fromRGBO(31, 31, 31, 1),
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    height: 0.5,
                                    thickness: 0.5,
                                    color: Color(0xFFFA9DBC),
                                  ),
                                ],
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          showAddPetPopup(context, onPetAdded: () {
                            setState(() {
                              _petsFuture = _fetchPetsData();
                            });
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: Color(0xFFE91E63),
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Add a new pet',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE91E63),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 64),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Container(
                            width: 100,
                            height: 54.01,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF4F81), Color(0xFFFF69B4)],
                                stops: [0, 1],
                                begin: AlignmentDirectional(1, 1),
                                end: AlignmentDirectional(-1, -1),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: GestureDetector(
                              onTap: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.medical_services,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ask a vet',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFF4F81), Color(0xFFFF69B4)],
                                stops: [0, 1],
                                begin: AlignmentDirectional(1, 1),
                                end: AlignmentDirectional(-1, -1),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: GestureDetector(
                              onTap: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Book a Vet',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          'Upcoming Appointments',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No upcoming appointments',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1F1F1F),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
