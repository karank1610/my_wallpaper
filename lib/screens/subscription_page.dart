import 'package:flutter/material.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selectedPlan = "monthly"; // Default plan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Go Premium",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// **Premium Banner**
            _buildPremiumHeader(),

            SizedBox(height: 25),

            /// **Subscription Plans**
            _buildPlanCard("Weekly", "\$2.99 / week", "weekly", Icons.timer),
            _buildPlanCard(
                "Monthly", "\$7.99 / month", "monthly", Icons.calendar_today),
            _buildPlanCard("Yearly", "\$49.99 / year", "yearly", Icons.star,
                isBestValue: true),

            SizedBox(height: 20),

            /// **Benefits List**
            _buildFeature(Icons.wallpaper, "Unlimited Premium Wallpapers"),
            _buildFeature(Icons.block, "No Reward Ads"),
            _buildFeature(Icons.ondemand_video, "No Custom Ads"),
            _buildFeature(Icons.star, "Exclusive Content"),
            _buildFeature(Icons.hd, "High-Quality 4K Wallpapers"),

            SizedBox(height: 30),

            /// **Subscribe Button**
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                print("User selected: $selectedPlan");
              },
              child: Text("Subscribe Now",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),

            SizedBox(height: 15),

            /// **Restore Purchase**
            TextButton(
              onPressed: () {
                print("Restore Purchase Clicked");
              },
              child: Text("Restore Purchase",
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  /// **🟠 Premium Header**
  Widget _buildPremiumHeader() {
    return Column(
      children: [
        Icon(Icons.workspace_premium, color: Colors.orangeAccent, size: 60),
        SizedBox(height: 10),
        Text("Enjoy Premium Experience",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("Get exclusive access with no ads and premium content!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  /// **📌 Subscription Plan Card**
  Widget _buildPlanCard(
      String title, String price, String planType, IconData icon,
      {bool isBestValue = false}) {
    bool isSelected = selectedPlan == planType;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = planType;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: [Colors.orangeAccent, Colors.redAccent])
              : LinearGradient(colors: [Colors.grey[900]!, Colors.black]),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                  color: Colors.orangeAccent.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 30),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isBestValue)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text("Best Value",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                      ),
                    SizedBox(height: isBestValue ? 5 : 0),
                    Text(title,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(price,
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ],
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  /// **✔️ Feature List Item**
  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 24),
          SizedBox(width: 12),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
