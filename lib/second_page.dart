import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// SecondPage receives the username and password from the login page
class SecondPage extends StatefulWidget {
  final String username;
  const SecondPage({super.key, required this.username});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  // Controllers for text input fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  // Loads saved user information from SharedPreferences
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstNameController.text = prefs.getString('firstName') ?? "";
      _lastNameController.text = prefs.getString('lastName') ?? "";
      _phoneController.text = prefs.getString('phone') ?? "";
      _emailController.text = prefs.getString('email') ?? "";
    });
  }
  // Saves user information to SharedPreferences
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstName', _firstNameController.text);
    await prefs.setString('lastName', _lastNameController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('email', _emailController.text);
  }

  // Opens a URL for calling, messaging, or emailing
  void _callPhone() async {
    final url = Uri.parse("tel:${_phoneController.text}");
    if (!await launchUrl(url)) {
      _showAlert("Calling not supported on this device");
    }
  }

  void _sendSMS() async {
    final url = Uri.parse("sms:${_phoneController.text}");
    if (!await launchUrl(url)) {
      _showAlert("SMS not supported on this device");
    }
  }

  void _sendEmail() async {
    final url = Uri.parse("mailto:${_emailController.text}");
    if (!await launchUrl(url)) {
      _showAlert("Email not supported on this device");
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcome Back, ${widget.username}!")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _firstNameController, decoration: const InputDecoration(labelText: "First Name")),
            TextField(controller: _lastNameController, decoration: const InputDecoration(labelText: "Last Name")),
            Row(
              children: [
                Expanded(child: TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Phone Number"))),
                IconButton(onPressed: _callPhone, icon: const Icon(Icons.call)),
                IconButton(onPressed: _sendSMS, icon: const Icon(Icons.message)),
              ],
            ),
            Row(
              children: [
                Expanded(child: TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email"))),
                IconButton(onPressed: _sendEmail, icon: const Icon(Icons.email)),
              ],
            ),
            ElevatedButton(onPressed: _saveData, child: const Text("Save Data")),
          ],
        ),
      ),
    );
  }
}
