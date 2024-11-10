import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:tfrb_userside/main/auth/signup.dart';
import 'package:uuid/uuid.dart';
import '../../Assets/Colors.dart';
import '../userModel.dart';

class Signup1 extends StatefulWidget {
  const Signup1({Key? key}) : super(key: key);

  @override
  State<Signup1> createState() => _Signup1State();
}

class _Signup1State extends State<Signup1> {
  //text controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  bool _isFirstNameValid = true;
  bool _isCompanyNameValid = true;
  bool _isPhoneNumberValid = true;
  String? _phoneNumber;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _validateFirstName(String value) {
    return value.isNotEmpty;
  }

  bool _validateCompanyName(String value) {
    return value.isNotEmpty;
  }


  //memory control
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
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
                          Text(
                            "Fill in your information",
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
                                        onChanged: (value) {
                                          setState(() {
                                            _isFirstNameValid = _validateFirstName(value);
                                          });
                                        },
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.singleLineFormatter
                                        ],
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
                                        onChanged: (value) {
                                          // No validation needed for last name
                                        },
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.singleLineFormatter
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12), // Add space below the text

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
                                        onChanged: (value) {
                                          setState(() {
                                            _isCompanyNameValid = _validateCompanyName(value);
                                          });
                                        },
                                        keyboardType: TextInputType.text,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.singleLineFormatter
                                        ],
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
                                  padding: EdgeInsets.only(left: 1.0), // Adjust padding as needed
                                  width: MediaQuery.of(context).size.width - 80, // Adjust width as needed
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: _isPhoneNumberValid ? shadeColor2 : Colors.red, // Change border color based on validation
                                    ),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: InternationalPhoneNumberInput(
                                          onInputChanged: (PhoneNumber number) {
                                            setState(() {
                                              _phoneNumber = number.phoneNumber;
                                              _isPhoneNumberValid = _phoneNumber != null && _phoneNumber!.isNotEmpty;
                                            });
                                          },
                                          isEnabled: true,
                                          autoValidateMode: AutovalidateMode.disabled,
                                          selectorConfig: SelectorConfig(
                                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                          ),
                                          ignoreBlank: false,
                                          selectorTextStyle: TextStyle(color: Colors.black),
                                          initialValue: PhoneNumber(isoCode: 'MY'), // Default country code (Malaysia)
                                          countries: ['AD', 'AE', 'AF', 'AG', 'AI', 'AL', 'AM', 'AO', 'AQ', 'AR', 'AS', 'AT', 'AU', 'AW', 'AX', 'AZ', 'BA', 'BB', 'BD', 'BE', 'BF', 'BG', 'BH', 'BI', 'BJ', 'BL', 'BM', 'BN', 'BO', 'BQ', 'BR', 'BS', 'BT', 'BV', 'BW', 'BY', 'BZ', 'CA', 'CC', 'CD', 'CF', 'CG', 'CH', 'CI', 'CK', 'CL', 'CM', 'CN', 'CO', 'CR', 'CU', 'CV', 'CW', 'CX', 'CY', 'CZ', 'DE', 'DJ', 'DK', 'DM', 'DO', 'DZ', 'EC', 'EE', 'EG', 'EH', 'ER', 'ES', 'ET', 'FI', 'FJ', 'FK', 'FM', 'FO', 'FR', 'GA', 'GB', 'GD', 'GE', 'GF', 'GG', 'GH', 'GI', 'GL', 'GM', 'GN', 'GP', 'GQ', 'GR', 'GS', 'GT', 'GU', 'GW', 'GY', 'HK', 'HM', 'HN', 'HR', 'HT', 'HU', 'ID', 'IE', 'IL', 'IM', 'IN', 'IO', 'IQ', 'IR', 'IS', 'IT', 'JE', 'JM', 'JO', 'JP', 'KE', 'KG', 'KH', 'KI', 'KM', 'KN', 'KP', 'KR', 'KW', 'KY', 'KZ', 'LA', 'LB', 'LC', 'LI', 'LK', 'LR', 'LS', 'LT', 'LU', 'LV', 'LY', 'MA', 'MC', 'MD', 'ME', 'MF', 'MG', 'MH', 'MK', 'ML', 'MM', 'MN', 'MO', 'MP', 'MQ', 'MR', 'MS', 'MT', 'MU', 'MV', 'MW', 'MX', 'MY', 'MZ', 'NA', 'NC', 'NE', 'NF', 'NG', 'NI', 'NL', 'NO', 'NP', 'NR', 'NU', 'NZ', 'OM', 'PA', 'PE', 'PF', 'PG', 'PH', 'PK', 'PL', 'PM', 'PN', 'PR', 'PS', 'PT', 'PW', 'PY', 'QA', 'RE', 'RO', 'RS', 'RU', 'RW', 'SA', 'SB', 'SC', 'SD', 'SE', 'SG', 'SH', 'SI', 'SJ', 'SK', 'SL', 'SM', 'SN', 'SO', 'SR', 'SS', 'ST', 'SV', 'SX', 'SY', 'SZ', 'TC', 'TD', 'TF', 'TG', 'TH', 'TJ', 'TK', 'TL', 'TM', 'TN', 'TO', 'TR', 'TT', 'TV', 'TW', 'TZ', 'UA', 'UG', 'UM', 'US', 'UY', 'UZ', 'VA', 'VC', 'VE', 'VG', 'VI', 'VN', 'VU', 'WF', 'WS', 'YE', 'YT', 'ZA', 'ZM', 'ZW'], // List of supported countries
                                          formatInput: true, // Formats input based on country code
                                          keyboardType: TextInputType.phone, // You can adjust the keyboard type as needed
                                          inputDecoration: InputDecoration(
                                            border: InputBorder.none, // Remove underline
                                            hintText: 'Phone number',
                                            hintStyle: TextStyle(color: Colors.grey),
                                            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 0.9),
                                          ),
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
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20), // Adjust space as needed
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: shadeColor4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          44), // Adjust border radius
                                      side: BorderSide(
                                          color: shadeColor1,
                                          width: 2),
                                ),
                                  elevation: 5,
                                ),
                                  onPressed: () async {
                                  // Validate input fields
                                  setState(() {
                                    _isFirstNameValid = _firstNameController.text.isNotEmpty;
                                    _isCompanyNameValid = _companyNameController.text.isNotEmpty;
                                    _isPhoneNumberValid = _phoneNumber != null && _phoneNumber!.isNotEmpty;
                                  });

                                  // Check if all fields are valid
                                  if (_isFirstNameValid && _isCompanyNameValid && _isPhoneNumberValid) {
                                    try {

                                      String userID = Uuid().v4();

                                      // Create UserModel object
                                      UserModel userModel = UserModel(
                                        firstName: _firstNameController.text,
                                        lastName: _lastNameController.text,
                                        companyName: _companyNameController.text,
                                        phoneNumber: _phoneNumber!,
                                        email: '',
                                        password: '',
                                        userID: userID,
                                        picture: '',
                                      );

                                      // Define user profile data
                                      Map<String, dynamic> userProfileData = {
                                        'firstName': userModel.firstName,
                                        'lastName': userModel.lastName,
                                        'companyName': userModel.companyName,
                                        'phoneNumber': userModel.phoneNumber,
                                        'userID': userModel.userID,
                                        'picture': userModel.picture,
                                        'email': userModel.email,
                                        'password': userModel.password,
                                      };

                                      // Save user data to Firestore with the user ID as the document ID
                                      await _firestore.collection('usersAccount').doc(userModel.userID).set(userProfileData);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Signup(userID: userModel.userID)),
                                      );
                                    } catch (e) {
                                      // Handle any errors that occur during user account creation or Firestore data saving
                                      print('Error creating user account or saving data to Firestore: $e');
                                      Fluttertoast.showToast(
                                        msg: 'Error: $e',
                                        gravity: ToastGravity.BOTTOM,
                                      );
                                    }
                                  } else {
                                    // Display error message or handle invalid input fields
                                    Fluttertoast.showToast(
                                      msg: 'Please fill in all required fields.',
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                  }
                                },
                                child: Text(
                                  "Next",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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