import 'package:flutter/material.dart';
import 'package:simpa/firebase/models/pet_model.dart';

class PetsProfile extends StatefulWidget {
  final Pet pet;

  const PetsProfile({super.key, required this.pet});

  @override
  State<PetsProfile> createState() => _PetsProfileState();
}

class _PetsProfileState extends State<PetsProfile> {
  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Details'),
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pet.petName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Breed: ${pet.petBreed}',
                style: const TextStyle(fontSize: 18)),
            Text('Gender: ${pet.petGender}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
