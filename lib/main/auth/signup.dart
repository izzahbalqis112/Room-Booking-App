import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../Assets/Colors.dart';
import '../bottomnavbar/navbar.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  final String userID;

  const Signup({Key? key, required this.userID}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState(userID: userID);
}

class _SignupState extends State<Signup> {
  final String userID;

  _SignupState({required this.userID});
  //text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;
  bool _passwordVisible = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _validateEmail(String email) {
    // Regular expressions for the accepted email formats
    final RegExp googleEmail =
    RegExp(r'^[\w.+-]+@gmail\.com$', caseSensitive: false);
    final RegExp utemEmail =
    RegExp(r'^[\w.+-]+@(utem\.edu\.my|student\.utem\.edu\.my)$', caseSensitive: false);
    final RegExp outlookEmail =
    RegExp(r'^[\w.+-]+@outlook\.com$', caseSensitive: false);
    final RegExp yahooEmail =
    RegExp(r'^[\w.+-]+@yahoo\.com$', caseSensitive: false);

    // Check if the email matches any of the accepted formats
    if (googleEmail.hasMatch(email) ||
        utemEmail.hasMatch(email) ||
        outlookEmail.hasMatch(email) ||
        yahooEmail.hasMatch(email)) {
      return true; // Email is valid
    } else {
      return false; // Email is invalid
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  bool _validatePassword(String password) {
    // Check if password length is at least 6 characters
    if (password.length < 6) {
      return false;
    }

    // Check for at least one uppercase letter
    bool hasUpperCase = false;
    // Count the number of uppercase letters
    int upperCaseCount = 0;
    for (int i = 0; i < password.length; i++) {
      if (password[i] == password[i].toUpperCase() && password[i] != password[i].toLowerCase()) {
        hasUpperCase = true;
        upperCaseCount++;
      }
    }

    // Check for at least one lowercase letter
    bool hasLowerCase = false;
    // Count the number of lowercase letters
    int lowerCaseCount = 0;
    for (int i = 0; i < password.length; i++) {
      if (password[i] == password[i].toLowerCase() && password[i] != password[i].toUpperCase()) {
        hasLowerCase = true;
        lowerCaseCount++;
      }
    }

    // Check for at least one special character
    bool hasSpecialChar = false;
    String specialChars = r'^ !@#$%^&*()_+{}|:<>?-=[]\;\';
    for (int i = 0; i < password.length; i++) {
    if (specialChars.contains(password[i])) {
    hasSpecialChar = true;
    break;
    }
    }

    // Return true only if all conditions are met
    // And if the desired count of uppercase and lowercase letters is achieved
    return hasUpperCase && hasLowerCase && hasSpecialChar && upperCaseCount >= 1 && lowerCaseCount >= 1;
  }

  // Validate confirm password
  bool _validateConfirmPassword(String confirmPassword) {
    return confirmPassword == _passwordController.text;
  }

  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Encode the password to UTF-8
    var digest = sha256.convert(bytes); // Generate the SHA-256 hash
    return digest.toString(); // Return the hashed password as a string
  }

  void _signup(String userID) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      // Create user with email and password
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String hashedPassword = hashPassword(_passwordController.text);

      // Update user profile with email and hashed password
      await _firestore.collection('usersAccount').doc(userID).update({
        'email': email,
        'password': hashedPassword,
      });

      // Signup successful, navigate to home screen or wherever you want to navigate
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ButtomNavBar()), // Replace ButtomNavBar() with your desired destination
      );
    } catch (e) {
      // Handle signup errors
      print("Signup error: $e");
      Fluttertoast.showToast(
        msg: 'Signup failed',
        gravity: ToastGravity.BOTTOM,
      );
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:  Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/img/authpage.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    'lib/assets/img/TF-logo1.png',
                    width: 100,
                    height: 100,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0), // Adjust the left padding as needed
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                              height:
                              40), // Adjust the space between "Teaching Factory" and the new text
                          Container(
                            padding: EdgeInsets.only(left: 0.05), // Adjust the left padding for center-left alignment
                            width: MediaQuery.of(context).size.width - 80, // Adjust width as needed
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _emailController,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32),
                                            borderSide: BorderSide(
                                              color: _isEmailValid
                                                  ? shadeColor2
                                                  : Colors
                                                  .red, // Dynamic border color based on email validity
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: _isEmailValid
                                                  ? shadeColor2
                                                  : Colors
                                                  .red, // Dynamic border color based on email validity
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          hintText: "Email",
                                          hintStyle: TextStyle(color: Colors.grey),
                                          prefixIcon: Icon(Icons.email),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _isEmailValid = _validateEmail(value);
                                          });
                                        },
                                        keyboardType: TextInputType.emailAddress,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .singleLineFormatter
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (!_isEmailValid)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0,
                                        top: 5.0), // Adjust padding as needed
                                    child: Text(
                                      'Invalid email format',
                                      style: TextStyle(
                                        color: Colors.red, // Adjust color as needed
                                        fontSize: 12, // Adjust font size as needed
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                // Password TextField
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32),
                                            borderSide: BorderSide(
                                              color: _isPasswordValid ? shadeColor2 : Colors.red,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: _isPasswordValid ? shadeColor2 : Colors.red,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          hintText: "Password",
                                          hintStyle: TextStyle(color: Colors.grey),
                                          prefixIcon: Icon(Icons.lock),
                                          fillColor: Colors.white,
                                          filled: true,
                                          suffixIcon: GestureDetector(
                                            onTap: _togglePasswordVisibility,
                                            child: Icon(
                                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                            ),
                                          ),
                                        ),
                                        obscureText: !_passwordVisible,
                                        onChanged: (value) {
                                          setState(() {
                                            _isPasswordValid = _validatePassword(value);
                                          });
                                        },
                                        keyboardType: TextInputType.visiblePassword,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.singleLineFormatter
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (!_isPasswordValid)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                    child: Text(
                                      'Password must be at least 6 characters with 1 uppercase, 1 lowercase, and 1 special character.',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12), // Add space below the text

                                // Confirm Password TextField
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _confirmPasswordController,
                                        decoration: InputDecoration(
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(32),
                                            borderSide: BorderSide(
                                              color: _isConfirmPasswordValid ? shadeColor2 : Colors.red,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: _isConfirmPasswordValid ? shadeColor2 : Colors.red,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          hintText: "Confirm Password",
                                          hintStyle: TextStyle(color: Colors.grey),
                                          prefixIcon: Icon(Icons.lock),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                        obscureText: !_passwordVisible,
                                        onChanged: (value) {
                                          setState(() {
                                            _isConfirmPasswordValid = _validateConfirmPassword(value);
                                          });
                                        },
                                        keyboardType: TextInputType.visiblePassword,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.singleLineFormatter
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (!_isConfirmPasswordValid)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                    child: Text(
                                      'Passwords do not match',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0), // Adjust the left padding as needed
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: shadeColor4,
                                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 130), // Adjust padding for size
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(44), // Adjust border radius
                                  side: BorderSide(color: shadeColor1, width: 2), // Border color and width
                                ),
                                elevation: 5, // Shadow
                              ),
                              onPressed: () async {
                                _signup(widget.userID);
                              },

                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ), // Text style
                              ),
                            ),
                          ),
                          const SizedBox(height: 25), // Add space below the button
                          Padding(
                            padding: const EdgeInsets.only(left: 65.0), // Adjust the left padding as needed
                            child: Row(
                              children: [
                                Text(
                                  "Already have an account?",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Login()), // Replace LoginPage with your actual login page widget.
                                    );
                                  },
                                  child: Text(
                                    " Log in",
                                    style: TextStyle(
                                      color: shadeColor2,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}