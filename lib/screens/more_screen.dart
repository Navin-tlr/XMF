import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  // Function to handle signing out
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _MoreListTile(
            title: 'Goal Settings',
            icon: Icons.flag_outlined,
            onTap: () {},
          ),
          _MoreListTile(
            title: 'Preferences',
            icon: Icons.settings_outlined,
            onTap: () {},
          ),
          const Divider(), // A separator line
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Log Out',
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            onTap: _signOut, // Call the sign out function
          ),
        ],
      ),
    );
  }
}

// A reusable ListTile for our settings menu
class _MoreListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _MoreListTile({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[400]),
      title: const Text("Placeholder", style: TextStyle(color: Colors.white, fontSize: 16)), // Updated to use a const constructor
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}