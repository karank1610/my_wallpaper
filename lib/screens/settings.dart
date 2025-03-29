import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_page.dart'; // Page for editing profile details
import 'subscription_page.dart'; // Subscription page
import 'about_us_page.dart'; // About Us page

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool darkMode = true;

  void _logoutUser() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pop(context); // Close settings
      // You might want to redirect to the login page here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          /// **Profile Options**
          SettingsTile(
            title: "Change Profile Picture",
            hasArrow: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),

          /// **Premium Subscription**
          SettingsTile(
            title: "Buy Premium",
            hasArrow: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubscriptionPage()),
              );
            },
          ),

          /// **Notification Settings**
          SettingsTile(
            title: "Enable Notifications",
            hasToggle: true,
            isToggled: notificationsEnabled,
            onToggle: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),

          /// **Version Info**
          SettingsTile(
            title: "Version",
            subtitle: "1.0.0",
            hasArrow: false,
          ),

          /// **Clear Cache**
          SettingsTile(
            title: "Clear Cache",
            subtitle: "Free up space",
            hasArrow: true,
            onTap: () {
              // Implement cache clearing functionality
            },
          ),

          /// **About Us**
          SettingsTile(
            title: "About Us",
            hasArrow: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              );
            },
          ),

          /// **Logout**
          SettingsTile(
            title: "Logout",
            hasArrow: true,
            onTap: _logoutUser,
          ),
        ],
      ),
    );
  }
}

/// **Reusable Settings Tile Widget**
class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool hasToggle;
  final bool isToggled;
  final bool hasArrow;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.hasToggle = false,
    this.isToggled = false,
    this.hasArrow = false,
    this.onTap,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: Colors.grey))
          : null,
      trailing: hasToggle
          ? Switch(
              value: isToggled,
              onChanged: onToggle,
              activeColor: Colors.blue,
            )
          : hasArrow
              ? const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16)
              : null,
      onTap: onTap,
    );
  }
}
