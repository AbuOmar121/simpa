import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simpa/screens/user_access/welcomeScreen/welcome.dart';

class SignUpLogic {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  String? errorMessage;

  bool validatePassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  bool validatePhoneNumber(String phone) {
    final normalized = normalizePhoneNumber(phone);
    return RegExp(r'^\+?\d{10,15}$').hasMatch(normalized);
  }

  String normalizePhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  }

  Future<bool> isPhoneNumberTaken(String phoneNumber) async {
    final normalized = normalizePhoneNumber(phoneNumber);
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: normalized)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> signUp(BuildContext context, VoidCallback setStateCallback) async {
    if (!formKey.currentState!.validate()) return;

    final phone = phoneController.text.trim();

    if (!validatePhoneNumber(phone)) {
      errorMessage = "Please enter a valid phone number";
      setStateCallback();
      return;
    }

    if (await isPhoneNumberTaken(phone)) {
      errorMessage = "This phone number is already registered";
      setStateCallback();
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage = "Passwords don't match";
      setStateCallback();
      return;
    }

    isLoading = true;
    errorMessage = null;
    setStateCallback();

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await _saveUserData(credential.user!.uid);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Welcome(user: credential.user!)),
        );
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = _getAuthErrorMessage(e);
    } catch (e) {
      errorMessage = "An unexpected error occurred";
    } finally {
      isLoading = false;
      setStateCallback();
    }
  }

  Future<void> _saveUserData(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': normalizePhoneNumber(phoneController.text.trim()),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'role': 'user',
    }, SetOptions(merge: true));
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Please enter a valid email';
      case 'weak-password':
        return 'Password must be at least 8 characters';
      default:
        return 'Sign up failed: ${e.message}';
    }
  }

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
