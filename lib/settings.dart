import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isEditing = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();                          // SharedPref saves data for the current session
    setState(() {
      nameController.text = prefs.getString('name') ?? 'Abhinav S';               // Dummy data for database
      dobController.text = prefs.getString('dob') ?? '02-01-2005';
      ageController.text = prefs.getString('age') ?? '20';
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('dob', dobController.text);
    await prefs.setString('age', ageController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(                                                                 // Makes sure UI doesn't overlap system UI like status bar 
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(                                                                    // Header
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'SETTINGS',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CircleAvatar(                                                       // Avatar
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Profile Card
              Container(
                width: double.infinity,                                               // Force Take full width. Default width is that of child
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(                                                        // Vertically order children
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profile Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: nameController,
                      enabled: isEditing,                                             // Controlled with isEditing Variable.
                      decoration: const InputDecoration(labelText: 'Name'),           // Can edit only if true
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: dobController,
                      enabled: isEditing,
                      decoration: const InputDecoration(labelText: 'Date of Birth'),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: ageController,
                      enabled: isEditing,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),                                               // Empty box to usually function as padding

              ElevatedButton(
                onPressed: () async {
                  if (isEditing) {
                    await _saveProfile();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile updated successfully.")),
                    );
                  }
                  setState(() {
                    isEditing = !isEditing;                                             // set isEditing = true
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  isEditing ? 'Save Profile' : 'Update Profile',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
