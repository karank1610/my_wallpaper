import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final bool isLoggedIn;
  final String? userName;
  final String? userEmail;
  final String? profilePicUrl;

  ProfilePage({
    this.isLoggedIn = false,
    this.userName,
    this.userEmail,
    this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[100],
        leading: SizedBox(),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.blue),
            onPressed: () {
              // Notification action
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue),
            onPressed: () {
              // Settings action
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: isLoggedIn && profilePicUrl != null
                      ? NetworkImage(profilePicUrl!)
                      : AssetImage('assets/profile.png') as ImageProvider,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: isLoggedIn
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName ?? "User Name",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              userEmail ?? "user@example.com",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                ),
                if (!isLoggedIn)
                  ElevatedButton(
                    onPressed: () {
                      // Sign In action
                    },
                    child: Text("Sign In"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),

            // Metrics Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricTile(Icons.favorite, "Liked", Colors.red),
                    _buildMetricTile(Icons.person, "Following", Colors.green),
                    _buildMetricTile(
                        Icons.download_outlined, "Downloads", Colors.blue),
                    _buildMetricTile(Icons.visibility, "Viewed", Colors.purple),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Options List
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Column(
                children: [
                  _buildOptionTile(Icons.download_outlined, "Downloads"),
                  _buildOptionTile(Icons.announcement_outlined, "Bulletin"),
                  _buildOptionTile(Icons.feedback_outlined, "Help & Feedback"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        // Metric tap action
      },
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        label,
        style: TextStyle(fontSize: 16),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        // Option tap action
      },
    );
  }
}
