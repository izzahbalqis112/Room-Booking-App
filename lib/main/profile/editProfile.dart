import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Assets/Colors.dart';

class EditProfilePage extends StatefulWidget {
  final String userID;

  const EditProfilePage({Key? key, required this.userID}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isFirstNameValid = true;
  bool _isCompanyNameValid = true;
  bool _isPhoneNumberValid = true;
  String? _phoneNumber;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;
  Map<String, dynamic>? _userProfileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      _isLoading = true;
    });
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUser = currentUser;
      });
      await fetchAndDisplayUserData(_currentUser.email!);
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchAndDisplayUserData(String email) async {
    try {
      QuerySnapshot userDataSnapshot = await _firestore
          .collection('usersAccount')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDataSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
        userDataSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _userProfileData = userData;
          _isLoading = false;
          _firstNameController.text = _userProfileData?['firstName'] ?? '';
          _lastNameController.text = _userProfileData?['lastName'] ?? '';
          _companyNameController.text = _userProfileData?['companyName'] ?? '';
          _phoneNumber = _userProfileData?['phoneNumber'];
          _phoneNumberController.text = _phoneNumber ?? '';
        });
      } else {
        print('User data does not exist.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _handleEditPressed() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? userEmail = _currentUser.email;
      if (userEmail != null) {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('usersAccount')
            .where('email', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentReference userDocRef = userQuerySnapshot.docs.first.reference;
          await userDocRef.update({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'companyName': _companyNameController.text,
            'phoneNumber': _phoneNumberController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully.'),
            ),
          );

          Navigator.pop(context, true);
        } else {
          print('User document not found.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile. User not found.'),
            ),
          );
        }
      } else {
        print('User email is null.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile. User email is null.'),
          ),
        );
      }
    } catch (e) {
      print('Error updating user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile. Please try again later.'),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 200.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              "Edit your information below:",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: MediaQuery.of(context).size.width - 80,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _firstNameController,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: _isFirstNameValid ? shadeColor2 : Colors.red,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: _isFirstNameValid ? shadeColor2 : Colors.red,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            hintText: "First name",
                                            hintStyle: TextStyle(color: Colors.grey),
                                            prefixIcon: Icon(Icons.person),
                                            fillColor: Colors.white,
                                            filled: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!_isFirstNameValid)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        top: 5.0,
                                      ),
                                      child: Text(
                                        'First name cannot be empty',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _lastNameController,
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
                                            hintText: "Last name (optional)",
                                            hintStyle: TextStyle(color: Colors.grey),
                                            prefixIcon: Icon(Icons.person),
                                            fillColor: Colors.white,
                                            filled: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _companyNameController,
                                          decoration: InputDecoration(
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(32),
                                              borderSide: BorderSide(
                                                color: _isCompanyNameValid ? shadeColor2 : Colors.red,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: _isCompanyNameValid ? shadeColor2 : Colors.red,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            hintText: "Company/Organization name",
                                            hintStyle: TextStyle(color: Colors.grey),
                                            prefixIcon: Icon(Icons.business),
                                            fillColor: Colors.white,
                                            filled: true,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!_isCompanyNameValid)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        top: 5.0,
                                      ),
                                      child: Text(
                                        'Company/Organization name cannot be empty',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: MediaQuery.of(context).size.width - 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(
                                        color: _isPhoneNumberValid ? shadeColor2 : Colors.red,
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Icon(Icons.phone), 
                                        ),
                                        Expanded(
                                          child: TextField(
                                            controller: _phoneNumberController,
                                            keyboardType: TextInputType.phone, 
                                            decoration: InputDecoration(
                                              hintText: 'Phone number',
                                              hintStyle: TextStyle(color: Colors.grey),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(
                                                vertical: 16,
                                                horizontal: 8,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _phoneNumber = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (!_isPhoneNumberValid)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        top: 5.0,
                                      ),
                                      child: Text(
                                        'Phone number cannot be empty',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _handleEditPressed,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: shadeColor2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          "Update",
                                          style: TextStyle(color: Colors.white),
                                        ),
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
