import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentAPIPage extends StatefulWidget {
  final String trainNo;
  final String fromStation;
  final String toStation;
  final String selectedClass;
  final String selectedQuota;
  final DateTime journeyDate;

  const PaymentAPIPage({
    Key? key,
    required this.trainNo,
    required this.fromStation,
    required this.toStation,
    required this.selectedClass,
    required this.selectedQuota,
    required this.journeyDate,
  }) : super(key: key);

  @override
  State<PaymentAPIPage> createState() => _PaymentAPIPageState();
}

class _PaymentAPIPageState extends State<PaymentAPIPage> {
  final String serverUrl = 'http://192.168.117.169:3001';
  bool captchaAvailable = false;
  String captchaUrl = '';
  String captchaInput = '';
  String? _sessionId; // ✅ Store sessionId here
  TextEditingController captchaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sendBookingDetails();
  }

  Future<void> _sendBookingDetails() async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/send-booking'),
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
        _sessionId = data['sessionId']; // ✅ Store sessionId
        _checkCaptcha();
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> _checkCaptcha({int retryCount = 5}) async {
    await Future.delayed(const Duration(seconds: 10)); // ✅ Wait before first check

    for (int i = 0; i < retryCount; i++) {
      final response = await http.get(Uri.parse('$serverUrl/api/check-captcha'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['captchaAvailable']) {
          setState(() {
            captchaUrl = '$serverUrl${data['captchaUrl']}?t=${DateTime.now().millisecondsSinceEpoch}';
            captchaAvailable = true;
          });
          return; // ✅ Stop retrying once CAPTCHA is available
        }
      }

      await Future.delayed(const Duration(milliseconds: 500)); // ✅ Small retry delay
    }

    print("Failed to load CAPTCHA after retries.");
  }


Future<void> _submitCaptcha() async {
  if (captchaController.text.isEmpty || _sessionId == null) {
    print("Error: sessionId is null or captcha is empty.");
    return;
  }

  final response = await http.post(
    Uri.parse('$serverUrl/api/submit-captcha'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'sessionId': _sessionId, // ✅ Send sessionId
      'captchaInput': captchaController.text.trim(), // ✅ Ensure correct input is sent
    }),
  );

  if (response.statusCode == 200) {
    print("CAPTCHA Submitted: ${response.body}");
  } else {
    print("CAPTCHA Submission Failed: ${response.statusCode} - ${response.body}");
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment API')),
      body: Column(
        children: [
                    if (captchaAvailable) ...[
            Container(
              color: Colors.purple, // ✅ Set purple background
              padding: const EdgeInsets.all(8), // ✅ Add padding around image
              child: Image.network(
                captchaUrl,
                fit: BoxFit.contain, // ✅ Keep aspect ratio
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Failed to load CAPTCHA');
                },
              ),
            ),
            TextField(
              controller: captchaController,
              decoration: const InputDecoration(labelText: 'Enter CAPTCHA'),
              onChanged: (value) => captchaInput = value,
            ),
            ElevatedButton(onPressed: _submitCaptcha, child: const Text('Submit CAPTCHA'))
          ]
else
            const Center(child: Text("Waiting for CAPTCHA...")),
        ],
      ),
    );
  }
}
