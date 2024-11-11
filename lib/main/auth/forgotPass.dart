import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../assets/Colors.dart';
import 'login.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _validateEmail(String email) {

    final RegExp googleEmail = RegExp(r'^[\w.+-]+@gmail\.com$', caseSensitive: false);
    final RegExp utemEmail = RegExp(r'^[\w.+-]+@(utem\.edu\.my|student\.utem\.edu\.my)$', caseSensitive: false);
    final RegExp outlookEmail = RegExp(r'^[\w.+-]+@outlook\.com$', caseSensitive: false);
    final RegExp yahooEmail = RegExp(r'^[\w.+-]+@yahoo\.com$', caseSensitive: false);


    if (googleEmail.hasMatch(email) ||
        utemEmail.hasMatch(email) ||
        outlookEmail.hasMatch(email) ||
        yahooEmail.hasMatch(email)) {
      return true; 
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      Fluttertoast.showToast(
        msg: 'Password reset email sent. Check your inbox.',
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to send password reset email. Please try again later.',
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.close, color: shadeColor5),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Center(
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
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        "Enter appropriate info to Reset Password",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 20),
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
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(32),
                                        borderSide: BorderSide(
                                          color: _isEmailValid ? shadeColor2 : Colors.red,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: _isEmailValid ? shadeColor2 : Colors.red,
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
                                    inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                                  ),
                                ),
                              ],
                            ),
                            if (!_isEmailValid)
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, top: 5.0),
                                child: Text(
                                  'Invalid email format',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.only(left: 0.05),
                        width: MediaQuery.of(context).size.width - 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(height: 22), 
                                ElevatedButton(
                                  onPressed: resetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: shadeColor4,
                                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 99.5), 
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(44), 
                                      side: BorderSide(color: shadeColor1, width: 2), 
                                    ),
                                    elevation: 5, 
                                  ),
                                  child: Text(
                                    "Reset Password",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white), 
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
    );
  }
}
