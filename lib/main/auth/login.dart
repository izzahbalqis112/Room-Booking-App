import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tfrb_userside/main/auth/signup1.dart';
import '../../Assets/Colors.dart';
import '../bottomnavbar/navbar.dart';
import 'forgotPass.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailValid = true;
  bool _passwordVisible = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  void _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );


      User? user = userCredential.user;

      // Fetch manager's email from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('usersAccount')
          .where('email', isEqualTo: _emailController.text)
          .get();

      // Check if manager email exists in the collection
      if (querySnapshot.docs.isNotEmpty) {
        String userEmail = querySnapshot.docs.first.get('email');

        // Check if the logged-in user's email matches the manager's email
        if (user?.email == _emailController.text && _emailController.text == userEmail) {
          // Login successful, navigate to home screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ButtomNavBar()),
          );
        } else {
          // User is not authorized, show error message
          Fluttertoast.showToast(
            msg: 'You are not authorized to log in',
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        // Manager email not found in the collection
        Fluttertoast.showToast(
          msg: 'You are not authorized to log in',
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Login failed',
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                        Text(
                          "Log in into your Account",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 20), // Add space below the text
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 12), // Add space below the text
                        Container(
                          padding: EdgeInsets.only(left: 0.05),
                          width: MediaQuery.of(context).size.width - 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                            color: shadeColor2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: shadeColor2,
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
                                            _passwordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                        ),
                                      ),
                                      obscureText: !_passwordVisible,
                                      keyboardType: TextInputType.visiblePassword,
                                      inputFormatters: [
                                        FilteringTextInputFormatter
                                            .singleLineFormatter
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ForgotPassword(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color:
                                        shadeColor2, // You can adjust the color as needed
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const SizedBox(height: 5), // Ad
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: shadeColor4,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 16,
                                          horizontal:
                                          140),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            44), // Adjust border radius
                                        side: BorderSide(
                                            color: shadeColor1,
                                            width: 2), // Border color and width
                                      ),
                                      elevation: 5, //shadow
                                    ),
                                    onPressed: _login,
                                    child: Text(
                                      "Log in",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.white), // Text style
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),

                              // Don't have an account? Signup
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Signup1()), // Replace LoginPage with your actual login page widget.
                                      );
                                    },
                                    child: Text(
                                      " Sign up",
                                      style: TextStyle(
                                        color: shadeColor2,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
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
