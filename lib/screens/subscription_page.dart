import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_wallpaper/screens/payment_processing_screen.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String selectedPlan = "monthly"; // Default plan
  bool _isSubscribed = false; // Track subscription status
  String? userEmail; // Store logged-in user's email

  @override
  void initState() {
    super.initState();
    _fetchUserEmail(); // Fetch user email on page load
    _checkSubscriptionStatus(); // Check subscription status
    _checkSubscriptionExpiry(); // Check if subscription has expired
  }

  void _fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null && userData.containsKey("email")) {
            setState(() {
              userEmail = userData["email"]; // ✅ Get email from Firestore
            });
          } else {
            // 🔹 Firestore is missing email, so get it from FirebaseAuth
            setState(() {
              userEmail = user.email ?? "No Email Found"; // ✅ Fallback
            });

            // 🔹 Optional: Update Firestore with missing email
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .set(
              {"email": user.email},
              SetOptions(merge: true),
            );
          }
        } else {
          print("User document not found in Firestore!");
        }
      } catch (e) {
        print("Error fetching user email: $e");
      }
    }
  }

  Future<void> _checkSubscriptionExpiry() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null &&
              userData.containsKey("expiryDate") &&
              userData.containsKey("subscriptionActive")) {
            DateTime expiryDate =
                (userData["expiryDate"] as Timestamp).toDate();
            DateTime now = DateTime.now();

            if (now.isAfter(expiryDate)) {
              // Subscription has expired
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .update({
                "subscriptionActive": false, // Update status to false
              });

              setState(() {
                _isSubscribed = false; // Update UI
              });

              print("Subscription expired and status updated to false.");
            }
          }
        }
      } catch (e) {
        print("Error checking subscription expiry: $e");
      }
    }
  }

  Future<void> _checkSubscriptionStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null && userData.containsKey("subscriptionActive")) {
            bool isActive = userData["subscriptionActive"];
            DateTime expiryDate =
                (userData["expiryDate"] as Timestamp).toDate();
            DateTime now = DateTime.now();

            if (isActive && now.isAfter(expiryDate)) {
              // Subscription has expired
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid)
                  .update({
                "subscriptionActive": false, // Update status to false
              });

              setState(() {
                _isSubscribed = false; // Update UI
              });

              print("Subscription expired and status updated to false.");
            } else {
              setState(() {
                _isSubscribed = isActive; // Update UI
              });
            }
          } else {
            setState(() {
              _isSubscribed = false; // 🔹 Ensure UI updates
            });
            print("No subscription data found!");
          }
        } else {
          print("User document not found in Firestore!");
        }
      } catch (e) {
        print("Error checking subscription status: $e");
      }
    }
  }

  void _startFakePayment(String plan) {
    if (userEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Error: Unable to retrieve email!")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentProcessingScreen(
          subscriptionType: plan,
          // userEmail: userEmail!, // Replace with actual logged-in user's email
        ),
      ),
    ).then((paymentSuccess) {
      if (paymentSuccess == true) {
        setState(() {
          _isSubscribed = true; // Hide ads & enable premium
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Subscription Activated Successfully!")),
        );
      }
    });
  }

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
                backgroundColor: _isSubscribed
                    ? Colors.grey
                    : Colors.orangeAccent, // Disable if subscribed
                minimumSize: Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSubscribed
                  ? null // Disable button if subscribed
                  : () {
                      print("User selected: $selectedPlan");
                      _startFakePayment(selectedPlan);
                    },
              child: Text(
                _isSubscribed
                    ? "Already Subscribed"
                    : "Subscribe Now", // Change button text
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),

            SizedBox(height: 15),

            /// **Restore Purchase**
            TextButton(
              onPressed: () async {
                print("Restore Purchase Clicked");

                // Fetch latest subscription data from Firestore
                await _checkSubscriptionStatus();

                if (_isSubscribed) {
                  setState(() {}); // 🔹 Ensure UI updates after restoring
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("✅ Subscription Restored Successfully!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("⚠️ No Active Subscription Found!")),
                  );
                }
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
