import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simpa/screens/user_access/pets/details.dart';
import 'package:simpa/screens/user_access/stylesAndDec/dec.dart';

class PetData extends StatefulWidget {
  final String petGender;
  final DateTime? petBirth;
  final String petType;
  final String petBreed;
  final String age;

  const PetData({
    super.key,
    required this.petGender,
    required this.petBirth,
    required this.petType,
    required this.petBreed,
    required this.age,
  });

  @override
  State<PetData> createState() => _PetDataState();
}

class _PetDataState extends State<PetData> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 500,
        ),
        decoration: BoxDec.style,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailBar(
                icon: Icons.male,
                detail: 'Gender',
                data: widget.petGender,
              ),
              Divider(),
              DetailBar(
                icon: Icons.calendar_month,
                detail: 'Birth date',
                data: widget.petBirth != null
                    ? DateFormat('yyyy-MM-dd').format(widget.petBirth!.toLocal())
                    : 'Unknown',
              ),

              Divider(),
              DetailBar(
                icon: Icons.pets,
                detail: 'pet type',
                data: widget.petType,
              ),
              Divider(),
              DetailBar(
                icon: Icons.vertical_distribute_outlined,
                detail: 'breed',
                data: widget.petBreed,
              ),
              Divider(),
              DetailBar(
                icon: Icons.yard_outlined,
                detail: 'Age',
                data: widget.age,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
