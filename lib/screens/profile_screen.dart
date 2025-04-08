import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'authentication_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final user = _authService.getCurrentUser();
    final _passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthenticationScreen()));
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Logged in as: ${user?.email}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Change Password'),
                    content: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: 'New Password'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await _authService.changePassword(_passwordController.text);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password changed successfully')),
                          );
                        },
                        child: const Text('Submit'),
                      )
                    ],
                  ),
                );
              },
              child: const Text('Change Password'),
            )
          ],
        ),
      ),
    );
  }
}
