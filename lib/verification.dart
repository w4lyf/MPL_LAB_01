import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerificationPage extends StatefulWidget {             // All fields passed from the previous screen TrainResultsPage
  final String trainNo;
  final String fromStation;
  final String toStation;
  final String selectedClass;
  final String selectedQuota;
  final DateTime journeyDate;

  const VerificationPage({
    Key? key,
    required this.trainNo,
    required this.fromStation,
    required this.toStation,
    required this.selectedClass,
    required this.selectedQuota,
    required this.journeyDate,
  }) : super(key: key);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final String serverUrl = 'http://localhost:3001';
  bool captchaAvailable = false;
  String captchaUrl = '';
  String captchaInput = '';
  String? _sessionId; // Store sessionId
  TextEditingController captchaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sendBookingDetails();                // Automatically triggers when page loads — sends booking info to the server
  }

  Future<void> _sendBookingDetails() async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/send-booking'),           // Sends a POST request to /api/send-booking with train details.
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'train': widget.trainNo,
          'from': widget.fromStation,
          'to': widget.toStation,
          'selectedClass': widget.selectedClass,
          'quota': widget.selectedQuota,
          'date': widget.journeyDate.toIso8601String().split('T')[0].replaceAll('-', ''),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessionId = data['sessionId'];                   // Gets a sessionId in response and starts checking for CAPTCHA
        _checkCaptcha();
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> _checkCaptcha({int retryCount = 5}) async {
    await Future.delayed(const Duration(seconds: 10)); // Wait before first check for image readiness

    for (int i = 0; i < retryCount; i++) {             // Retries 5 times with a short delay.
      final response = await http.get(
        Uri.parse('$serverUrl/api/check-captcha?sessionId=$_sessionId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['captchaAvailable']) {
          setState(() {                                // Updates UI to show CAPTCHA image when ready
            captchaUrl = '$serverUrl${data['captchaUrl']}?t=${DateTime.now().millisecondsSinceEpoch}';
            captchaAvailable = true;
          });
          return;                                      // Stop retrying once CAPTCHA is available
        }
      }

      await Future.delayed(const Duration(milliseconds: 500)); // Small retry delay
    }

    print("Failed to load CAPTCHA after retries.");
  }

Future<void> _submitCaptcha() async {                           // Sends a POST request to /api/submit-captcha with user input + sessionId.
  if (captchaController.text.isEmpty || _sessionId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("CAPTCHA or session is missing")),
    );
    return;
  }
  try {
    final response = await http.post(
      Uri.parse('$serverUrl/api/submit-captcha'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sessionId': _sessionId,
        'captchaInput': captchaController.text.trim(),
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      showDialog(                                              // If successful → shows AlertDialog with booking details
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Booking Successful"),
          content: Text(
            "Train: ${data['booking']['train']}\n"
            "From: ${data['booking']['from']}\n"
            "To: ${data['booking']['to']}\n"
            "Class: ${data['booking']['selectedClass']}\n"
            "Quota: ${data['booking']['quota']}\n"
            "Date: ${data['booking']['date']}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else {                                                    // If wrong → shows error SnackBar
      final errorData = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${errorData['error'] ?? 'CAPTCHA failed'}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Exception: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: captchaAvailable
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: const Color.fromRGBO(255, 244, 252, 1),
                      child: Image.network(                   // Captcha url
                        captchaUrl,
                        width: 200, 
                        height: 80, 
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('Failed to load CAPTCHA');
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    TextField(
                      controller: captchaController,
                      decoration: const InputDecoration(
                        labelText: 'Enter CAPTCHA',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => captchaInput = value,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitCaptcha,
                      child: const Text('Submit CAPTCHA'),
                    ),
                  ],
                )
              : const Text("Waiting for CAPTCHA..."),
        ),
      ),
    );
  }
}
