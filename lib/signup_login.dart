import 'package:flutter/material.dart';
import 'package:railway_app/navigation_container.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controller to read text from username and password fields.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Creates a Firebase auth instance to handle login.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Controls whether a loading indicator is shown.
  bool _isLoading = false;

  Future<void> _login() async {
    // Shows a loading spinner while logging in.
    setState(() {
      _isLoading = true;
    });
    try {
      // .trim removes spaces from the beginning and end
      final String email = _usernameController.text.trim();
      final String password = _passwordController.text;

      // Tries to log in with Firebase
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      User? user = userCredential.user;

      if (user != null && user.emailVerified) {
        // Navigate to page defined in NavigationContainer with index = 0
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const NavigationContainer(initialIndex: 0),
          ),
        );
      } else {
        await _auth.signOut(); // Sign out unverified user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please verify your email before logging in.')),
        );
      }
    } on FirebaseAuthException catch (e) { // Handle common firebase errors
      String errorMessage = 'Authentication failed';  
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This user account has been disabled';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(                                                                  // Scaffold is basic layout structure
      backgroundColor: Colors.white,
      body: Center(                                                                   // Centers everything vertically and horizaontally
        child: Column(                                                                // Orders children vertically
          mainAxisAlignment: MainAxisAlignment.center,                                // Centers column content
          children: [
            Image(
              image: const AssetImage('./assets/railway_logo_1.png'),                 // Display an image
              width: 550,
              height: 190,
            ),

            Text(                                                                     // Display Text
              "EzyTicket",
              style: TextStyle(
                fontSize: 25,
                fontFamily: "Mono",
                fontWeight: FontWeight.bold
              ),
            ),
            
            Padding(                                                                  // Add spacing around the children
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),      // Use .all for equal padding
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Email', 
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,                             // Email keyboard
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: TextField(
                controller: _passwordController,
                obscureText: true,                                                    // display * on pwd
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 7),
              child: _isLoading
                ? CircularProgressIndicator()                                         // Show loading indicator
                : ElevatedButton(                                                     // Button
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
            ),
            
            // Sign up Text Button
            TextButton(
              onPressed: () {
                _showSignUpDialog();                                                   // Navigate to sign-up popup
              },
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  // Sign-up dialog method
  void _showSignUpDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Up'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(hintText: 'Password'),
                  obscureText: true,
                ),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(hintText: 'Confirm Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),                               // Show previous context/page
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }
                
                try {
                  // Create user
                  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                  );

                  // Get user and send verification email
                  User? user = userCredential.user;
                  if (user != null) {
                    await user.sendEmailVerification();
                    
                    // Close dialog
                    Navigator.of(context).pop();
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Account created! Please check your email for verification link.'),
                        duration: Duration(seconds: 8),
                      ),
                    );
                  }
              }on FirebaseAuthException catch (e) {
                  String errorMessage = 'Registration failed';
                  
                  if (e.code == 'weak-password') {
                    errorMessage = 'The password is too weak';
                  } else if (e.code == 'email-already-in-use') {
                    errorMessage = 'Email is already in use';
                  } else if (e.code == 'invalid-email') {
                    errorMessage = 'Email address is not valid';
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: Text('Sign Up'),
            ),
          ],
        );
      },
    );
  }

  // Cleanup controllers after widget is removed from memory
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}