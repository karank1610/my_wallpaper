import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
            const Text('Help & Support', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const Text('Frequently Asked Questions',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              'Find answers to common questions about MyWallpaper',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 30),

            // Premium & Credits Section
            _buildSectionHeader('Premium & Credits'),
            _buildFAQItem(
              question: 'How do I get credits to download premium wallpapers?',
              answer:
                  'You can earn credits by watching short video ads. Each ad watched gives you 1 credit.',
            ),
            _buildFAQItem(
              question: 'How can I remove ads from the app?',
              answer:
                  'Purchase any premium subscription plan to enjoy an ad-free experience and unlimited downloads.',
            ),
            _buildFAQItem(
              question: 'What are the benefits of premium subscription?',
              answer:
                  'Premium users get:\n• No ads\n• Unlimited downloads\n• Exclusive wallpapers\n• Higher resolution downloads',
            ),

            // Downloads Section
            _buildSectionHeader('Downloads'),
            _buildFAQItem(
              question: 'Why can\'t I download some wallpapers?',
              answer:
                  'Premium wallpapers require credits or a subscription. Standard wallpapers are always free to download.',
            ),
            _buildFAQItem(
              question: 'Where do downloaded wallpapers save?',
              answer:
                  'All wallpapers are saved in your device\'s Pictures/MyWallpaper folder automatically.',
            ),

            // Account Section
            _buildSectionHeader('Account'),
            _buildFAQItem(
              question: 'How do I change my username?',
              answer:
                  'Go to Edit Profile in the app menu to update your username.',
            ),
            _buildFAQItem(
              question: 'I forgot my password. How to reset?',
              answer:
                  'Use the "Forgot Password" option on the login screen to reset via email.',
            ),

            // Support Contact Section
            const Divider(color: Colors.grey, height: 40),
            _buildSectionHeader('Still need help?'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.email, color: Colors.white, size: 20),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email Support',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5),
                        SelectableText(
                          'forpcsurf@gmail.com',
                          style: TextStyle(
                              color: Colors.blue[300],
                              fontSize: 14,
                              decoration: TextDecoration.underline),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'We typically respond within 24 hours',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Version 1.0.0 • © 2023 MyWallpaper',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, top: 20),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(answer, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 15),
          const Divider(color: Colors.grey, height: 1),
        ],
      ),
    );
  }
}
