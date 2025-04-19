import 'package:simpa/authintication/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpa/firebase/models/pet_model.dart';
import 'package:simpa/add_pet_popup.dart';

class Welcome extends StatefulWidget {
  final User user;
  const Welcome({super.key, required this.user});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  late Future<Map<String, dynamic>> _userDataFuture;
  late Future<List<Pet>> _petsFuture;

  // ignore: unused_field
  bool _isSigningOut = false;

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
        print(doc.data());
        return Pet.fromDocumentSnapshot(doc);
      }).toList();
    } catch (e) {
      print(e);
      return []; // Return an empty list on error
    }
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SignInScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign out')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE1E1),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF4F81),
        automaticallyImplyLeading: false,
        title: const Text(
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
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              print("Settings tapped");
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              print("Notifications tapped");
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 30,
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data?['error'] != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.data?['error'] ?? 'An error occurred',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _userDataFuture = _fetchUserData();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userData = snapshot.data!;
          final firstname = userData['firstName'] as String? ?? '';
          final email = userData['email'] as String? ?? 'Not provided';
          final phone = userData['phone'] as String? ?? 'Not provided';

          return Container(
            color: const Color(0xFFFFE1E1),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User card
                    GestureDetector(
                      onTap: () {
                        print("User card tapped");
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: const Color.fromRGBO(0, 0, 0, 0.125),
                                offset: const Offset(0, 2),
                              )
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(178, 178, 178, 1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/User.png',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.person,
                                            size: 60, color: Colors.grey);
                                      },
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome back, $firstname!',
                                          style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Color.fromRGBO(31, 31, 31, 1),
                                          ),
                                        ),
                                        Text(
                                          '$email - $phone',
                                          style: const TextStyle(
                                            fontFamily: 'Manrope',
                                            fontSize: 14,
                                            color:
                                                Color.fromRGBO(31, 31, 31, 1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color.fromRGBO(31, 31, 31, 1),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
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
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 4,
                            color: const Color.fromRGBO(0, 0, 0, 0.125),
                            offset: const Offset(0, 2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FutureBuilder<List<Pet>>(
                        future: _petsFuture,
                        builder: (context, petsSnapshot) {
                          print(petsSnapshot.data);
                          if (petsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (petsSnapshot.hasError ||
                              petsSnapshot.data == null) {
                            return const Padding(
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
                            return const Padding(
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
                                      print("Pet tapped: ${pet.petName}");
                                      // Navigate to pet details page or perform any action
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFB2B2B2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/images/animal.jpeg',
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(Icons.pets,
                                                      size: 60,
                                                      color: Colors.grey);
                                                },
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    pet.petName,
                                                    style: const TextStyle(
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
                                                    style: const TextStyle(
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
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            color:
                                                Color.fromRGBO(31, 31, 31, 1),
                                            size: 24,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(
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
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
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
                    const SizedBox(height: 64),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Container(
                            width: 100,
                            height: 54.01,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF4F81), Color(0xFFFF69B4)],
                                stops: [0, 1],
                                begin: AlignmentDirectional(1, 1),
                                end: AlignmentDirectional(-1, -1),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                print("Add a new pet tapped");
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            width: 100,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF4F81), Color(0xFFFF69B4)],
                                stops: [0, 1],
                                begin: AlignmentDirectional(1, 1),
                                end: AlignmentDirectional(-1, -1),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                print("Add a new pet tapped");
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
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
                    const SizedBox(height: 32),
                    const Padding(
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
                    const SizedBox(height: 16),
                    const Padding(
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
