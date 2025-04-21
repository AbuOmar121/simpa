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

    final String petName = pet.petName;
    final String petBreed = pet.petBreed;
    final String petGender = pet.petGender;
    final String petType = pet.petType;
    final DateTime? petBirth = pet.birthdate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Details'),
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              petName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Breed: $petBreed', style: const TextStyle(fontSize: 18)),
            Text('Gender: $petGender', style: const TextStyle(fontSize: 18)),
            Text('Type: $petType', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            Text(
              'Birthdate: ${petBirth != null ? petBirth.toLocal().toString().split(' ')[0] : 'Unknown'}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
