import 'package:flutter/material.dart';
import 'about_us_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool messageNotifications = false;
  bool autoDownloadResources = false;
  bool applyMonthlyResources = false;

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
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          SettingsTile(
            title: "Buy Premium",
            hasToggle: false,
            hasArrow: true,
          ),
          SettingsTile(
            title: "Auto update app",
            subtitle: "Do not auto update",
            hasToggle: false,
            hasArrow: true,
          ),
          SettingsTile(
            title: "Get data reminders for downloads",
            subtitle: "Never",
            hasToggle: false,
            hasArrow: true,
          ),
          SettingsTile(
            title: "Message notifications",
            hasToggle: true,
            isToggled: messageNotifications,
            onToggle: (value) {
              setState(() {
                messageNotifications = value;
              });
            },
          ),
          SettingsTile(
            title: "Automatically download free monthly featured resources",
            hasToggle: true,
            isToggled: autoDownloadResources,
            onToggle: (value) {
              setState(() {
                autoDownloadResources = value;
              });
            },
          ),
          SettingsTile(
            title: "Automatically apply free monthly featured resources",
            hasToggle: true,
            isToggled: applyMonthlyResources,
            onToggle: (value) {
              setState(() {
                applyMonthlyResources = value;
              });
            },
          ),
          SettingsTile(
            title: "Version number",
            subtitle: "15.3.0_expt_in_release_77230a0_250115",
            hasToggle: false,
            hasArrow: true,
          ),
          ListTile(
            title: const Text(
              "Check for updates",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
            onTap: () {},
          ),
          SettingsTile(
            title: "Clear cache",
            subtitle: "Cache empty",
            hasToggle: false,
            hasArrow: true,
          ),
          SettingsTile(
            title: "About Us",
            hasToggle: false,
            hasArrow: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  AboutUsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

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
              ? const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
              : null,
      onTap: onTap,
    );
  }
}
