import 'package:flutter/material.dart';
import 'package:simpa/screens/authentication/sign_in/sign_in_screen.dart';
import '../function/sign_up_logic.dart';

class TxtField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  TxtField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink),
          borderRadius: BorderRadius.circular(25),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final logic = SignUpLogic();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    logic.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _animation,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: logic.formKey,
                child: Column(
                  children: [
                    SizedBox(height: 32),
                    Image.asset('assets/images/Simpa for app@4x.png',
                        width: 200),
                    SizedBox(height: 16),
                    Text('Create Account',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink)),
                    SizedBox(height: 8),
                    Text('Fill in your details to continue',
                        style: TextStyle(fontSize: 18)),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TxtField(
                            controller: logic.firstNameController,
                            label: 'First Name',
                            prefixIcon: Icons.person,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: TxtField(
                            controller: logic.lastNameController,
                            label: 'Last Name',
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TxtField(
                      controller: logic.emailController,
                      label: 'Email',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(v)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TxtField(
                      controller: logic.phoneController,
                      label: 'Phone',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    TxtField(
                      controller: logic.passwordController,
                      label: 'Password',
                      obscure: logic.obscurePassword,
                      prefixIcon: Icons.lock,
                      suffixIcon: IconButton(
                        icon: Icon(logic.obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() =>
                            logic.obscurePassword = !logic.obscurePassword),
                      ),
                      validator: (v) => v!.isEmpty || !logic.validatePassword(v)
                          ? 'Include upper/lowercase, number, special char'
                          : null,
                    ),
                    SizedBox(height: 16),
                    TxtField(
                      controller: logic.confirmPasswordController,
                      label: 'Confirm Password',
                      obscure: logic.obscureConfirmPassword,
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(logic.obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() =>
                            logic.obscureConfirmPassword =
                                !logic.obscureConfirmPassword),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 16),
                    if (logic.errorMessage != null)
                      Text(logic.errorMessage!,
                          style: TextStyle(color: Colors.red)),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: logic.isLoading
                            ? null
                            : () => logic.signUp(context, () => setState(() {})),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          padding:
                              EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        child: logic.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Sign Up',
                                style:
                                    TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SignInScreen()));
                          },
                          child: Text('Sign In',
                              style: TextStyle(color: Colors.pink)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
