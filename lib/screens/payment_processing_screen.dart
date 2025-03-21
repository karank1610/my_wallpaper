import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

class PaymentProcessingScreen extends StatefulWidget {
  final String subscriptionType;

  const PaymentProcessingScreen({Key? key, required this.subscriptionType})
      : super(key: key);

  @override
  _PaymentProcessingScreenState createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool isVerifying = false;
  String? transactionId;
  String? _receiptFilePath;
  bool? isPaymentComplete;
  double _sliderValue = 0.0;
  final User? user = FirebaseAuth.instance.currentUser;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _redirectTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startRedirectTimer() {
    _redirectTimer = Timer(Duration(seconds: 10), () {
      // Redirect to home page after 10 seconds
      Navigator.of(context)
          .popUntil((route) => route.isFirst); // Go to home page
    });
  }

  Future<pw.Font> _loadCustomFont() async {
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    return pw.Font.ttf(fontData);
  }

  String _normalizeSubscriptionType(String subscriptionType) {
    if (subscriptionType.isEmpty) return subscriptionType;
    return subscriptionType[0].toUpperCase() +
        subscriptionType.substring(1).toLowerCase();
  }

  String _getSubscriptionPrice(String subscriptionType) {
    switch (subscriptionType) {
      case "Weekly":
        return "2.99";
      case "Monthly":
        return "7.99";
      case "Yearly":
        return "49.99";
      default:
        throw ArgumentError("Invalid subscription type: $subscriptionType");
    }
  }

  String _generateTransactionId() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(12, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  void _completePayment() async {
    if (user == null) return;

    setState(() => isVerifying = true);

    String txnId = _generateTransactionId();
    String subscriptionType = _normalizeSubscriptionType(
        widget.subscriptionType); // Normalize subscription type
    String price = _getSubscriptionPrice(subscriptionType); // Get price
    DateTime expiryDate = DateTime.now().add(
      subscriptionType == "Weekly"
          ? Duration(days: 7)
          : subscriptionType == "Monthly"
              ? Duration(days: 30)
              : Duration(days: 365),
    );

    // Debugging: Print subscription type and price
    print("Subscription Type: $subscriptionType");
    print("Subscription Price: $price");

    DocumentReference userRef =
        FirebaseFirestore.instance.collection("users").doc(user!.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);

      if (!snapshot.exists) return;

      transaction.update(userRef, {
        "isSubscribed": true,
        "subscriptionType": subscriptionType,
        "subscriptionPrice": price, // Use the correct price
        "expiryDate": expiryDate,
        "transactionHistory": FieldValue.arrayUnion([txnId]),
      });
    });

    await userRef.update({
      "subscriptionActive": true,
    });

    File receipt = await generateInvoice(
        user!.email!, subscriptionType, txnId, expiryDate, price);
    _receiptFilePath = receipt.path;

    _sendInvoiceEmail(
        user!.email!, subscriptionType, txnId, expiryDate, price, receipt.path);

    setState(() {
      isPaymentComplete = true;
      isVerifying = false;
    });
    _startRedirectTimer();
  }

  Future<File> generateInvoice(String email, String subscriptionType,
      String txnId, DateTime expiryDate, String price) async {
    final pdf = pw.Document();
    final font = await _loadCustomFont();

    // Load logo image
    final logoImage = pw.MemoryImage(
      (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "MyWallpaper",
                  style: pw.TextStyle(
                    fontSize: 24,
                    font: font,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Image(logoImage, width: 100, height: 50),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "Subscription Receipt",
              style: pw.TextStyle(
                fontSize: 20,
                font: font,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text(
              "Subscription Details",
              style: pw.TextStyle(
                fontSize: 16,
                font: font,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text("Plan: $subscriptionType", style: pw.TextStyle(font: font)),
            pw.Text(
                "Expiry Date: ${DateFormat('yyyy-MM-dd').format(expiryDate)}",
                style: pw.TextStyle(font: font)),
            pw.Text("Amount Paid: \$$price USD",
                style: pw.TextStyle(font: font)),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            pw.Text(
              "Thank you for subscribing to MyWallpaper!",
              style: pw.TextStyle(
                fontSize: 14,
                font: font,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "Contact Us: support@mywallpaper.com",
              style: pw.TextStyle(
                fontSize: 12,
                font: font,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/invoice_$txnId.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _sendInvoiceEmail(String email, String type, String txnId,
      DateTime expiryDate, String price, String receiptPath) async {
    if (!email.contains("@")) return;

    final smtpServer = gmail("forpcsurf@gmail.com", "prdt asuk brkj jpgn");

    final message = Message()
      ..from = Address("your_email@gmail.com", "MyWallpaper")
      ..recipients.add(email)
      ..subject = "Your Subscription Receipt - MyWallpaper"
      ..html = """
        <html>
          <body>
            <h2>Hello,</h2>
            <p>Thank you for subscribing to <strong>MyWallpaper</strong>!</p>
            <h3>Subscription Details:</h3>
            <ul>
              <li><strong>Plan:</strong> $type</li>
              <li><strong>Transaction ID:</strong> $txnId</li>
              <li><strong>Expiry Date:</strong> ${DateFormat('yyyy-MM-dd').format(expiryDate)}</li>
              <li><strong>Amount Paid:</strong> \$$price USD</li>
            </ul>
            <p>Your receipt is attached.</p>
            <p>Best regards,<br>MyWallpaper Team</p>
            <img src="https://images-platform.99static.com/Xqmnqz6kRBj5yT_U553WRCvE7uc=/400x400/99designs-contests-attachments/92/92793/attachment_92793967" alt="MyWallpaper Logo" width="100" height="100">
          </body>
        </html>
      """
      ..attachments.add(FileAttachment(File(receiptPath)));

    try {
      final sendReport = await send(message, smtpServer);
      print("Email sent: ${sendReport.toString()}");
    } catch (e) {
      print("Failed to send email: $e");
    }
  }

  Widget _buildReceiptDownloadButton() {
    if (_receiptFilePath != null) {
      return ElevatedButton.icon(
        icon: Icon(Icons.download, color: Colors.white),
        label: Text(
          "Download Invoice",
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          OpenFile.open(_receiptFilePath); // Open the receipt file
          Navigator.of(context)
              .popUntil((route) => route.isFirst); // Redirect to home page
          _redirectTimer
              ?.cancel(); // Cancel the timer if the user manually downloads the receipt
        },
      );
    }
    return Container();
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            strokeWidth: 5,
          ),
          SizedBox(height: 20),
          Text(
            "Processing Payment...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          SizedBox(height: 20),
          Text(
            "Subscription Active!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildReceiptDownloadButton(),
          SizedBox(height: 10),
          Text(
            "If you didn't receive the receipt via email,\nyou can download it manually.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: isVerifying
            ? _buildLoadingScreen()
            : isPaymentComplete == true
                ? _buildSuccessScreen()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Confirm Purchase",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Slider(
                          value: _sliderValue,
                          min: 0.0,
                          max: 100.0,
                          divisions: 100,
                          onChanged: (value) =>
                              setState(() => _sliderValue = value),
                          onChangeEnd: (value) {
                            if (value == 100.0 && !isVerifying)
                              _completePayment();
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
