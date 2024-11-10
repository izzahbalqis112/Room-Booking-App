import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tfrb_userside/Assets/Colors.dart';
import '../../../bottomnavbar/navbar.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  List<PlatformFile>? pickedFiles;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        pickedFiles = result.files;
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (pickedFiles == null || pickedFiles!.isEmpty) return;
    DocumentSnapshot? bookingDoc;

    try {
      // Get the current user's email
      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      // Query Firestore for the specific booking document
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('roomBookingData')
          .where('bookingStatus.status', isEqualTo: 'Pending Payment')
          .where('user.email', isEqualTo: currentUserEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Assuming you want to update the first matched document
        DocumentSnapshot bookingDoc = snapshot.docs.first;
        List<Map<String, String>> fileDetailsList = [];

        for (PlatformFile pickedFile in pickedFiles!) {
          // Ensure the correct File import is used
          final file = File(pickedFile.path!);

          // Upload file to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('uploads/${pickedFile.name}');
          await storageRef.putFile(file);

          // Get file URL
          final fileURL = await storageRef.getDownloadURL();

          // Store file details
          fileDetailsList.add({
            'fileName': pickedFile.name,
            'fileURL': fileURL,
          });
        }

        // Set the payment details and update the booking status in the booking document
        await FirebaseFirestore.instance
            .collection('roomBookingData')
            .doc(bookingDoc.id)
            .set({
          'paymentDetails': fileDetailsList,
          'bookingStatus': {
            'status': 'Processing',
            'description': 'The booking request is being processed by the system',
            'bookingStatusID': 'Processing',
            'sortOrder': '6',
            'active': true,
          }
        }, SetOptions(merge: true));
      }

      bool isBookingUpdate = true;

      if (isBookingUpdate) {
        // Save notification data to Firestore
        await _firestore.collection('notifications').add({
          'title': 'Teaching Factory',
          'body': 'User booking request still in process',
          'payload': 'process_booking',
          'userEmail': currentUserEmail,
          'displayBookingID': bookingDoc!['displayBookingID'],
        });
      }

      // Navigate to bottom navigation bar page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ButtomNavBar()),
      );
    } catch (e) {
      // Handle errors
      print('Error uploading files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: shadeColor1,
      appBar: AppBar(
        backgroundColor: shadeColor6,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white,),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ButtomNavBar()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center, // Center align the text within RichText
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                      fontFamily: 'Roboto', // Customize the font family if needed
                    ),
                    children: [
                      TextSpan(
                        text: 'Important !!! ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red, // Customize the color if needed
                        ),
                      ),
                      WidgetSpan(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0), // Adjust the padding as needed
                            child: Text(
                              'Please refer to the office of the UTeM Treasurer regarding further details on the payment for the Teaching Factory room booking request.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: pickedFiles == null || pickedFiles!.isEmpty
                  ? Column(
                children: [
                  Text(
                    'Please provide all payment receipts here as a reference for the Teaching Factory staff/manager to proceed with your booking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'You can select multiple PDF files by tapping "Select PDFs" below, and then tap "Upload" to proceed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black54,
                    ),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: pickedFiles!.map((file) {
                  return ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text(file.name),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _pickFiles,
                child: Text('Select PDFs'),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _uploadFiles,
                child: Text('Upload'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
