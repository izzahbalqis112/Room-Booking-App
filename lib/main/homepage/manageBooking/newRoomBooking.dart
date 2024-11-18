import 'package:animated_background/animated_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/rooms/dataModel/roomStatus.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/rooms/dataModel/rooms.dart';
import 'package:tfrb_userside/main/homepage/more/notification/localNotifications.dart';
import 'package:uuid/uuid.dart';
import '../../../assets/Colors.dart';
import '../../userModel.dart';
import 'dataModel/booking.dart';
import 'dataModel/bookingStatus.dart';
import 'dataModel/managerModel.dart';
import 'package:flutter/services.dart';

class NewRoomBookingPage extends StatefulWidget {
  final String roomID;

  NewRoomBookingPage({required this.roomID});

  @override
  _NewRoomBookingPageState createState() => _NewRoomBookingPageState();
}

class _NewRoomBookingPageState extends State<NewRoomBookingPage> with TickerProviderStateMixin{
  late AnimationController _controller;
  late Future<RoomsModel?> _roomData;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User _currentUser;
  Map<String, dynamic>? _userProfileData;
  double _totalPrice = 0.0;
  String bookingID = Uuid().v4();
  String bookingStatusID = Uuid().v4();
  DateTime? _checkInDateTime;
  DateTime? _checkOutDateTime;
  int _numberOfAdults = 0;
  int _numberOfChildren = 0;
  Timestamp dateTimeBookingMade = Timestamp.now();
  late String displayBookingID;
  TextEditingController _adultsController = TextEditingController();
  TextEditingController _childrenController = TextEditingController();
  TextEditingController _userNote = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userNote = TextEditingController(text: ''); 
    _adultsController.text = '0';
    _childrenController.text = '0';
    _loadRoomData();
    _getCurrentUser();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _adultsController.dispose();
    _childrenController.dispose();
    _userNote.dispose();
    super.dispose();
  }

  Future<void> _loadRoomData() async {
    setState(() {
      _roomData = _getRoomData();
    });
  }

  Future<void> _getCurrentUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUser = currentUser;
      });
      await fetchAndDisplayUserData(_currentUser.email!);
    }
  }

  Future<void> fetchAndDisplayUserData(String email) async {
    try {
      QuerySnapshot userDataSnapshot = await _firestore
          .collection('usersAccount')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDataSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData = (userDataSnapshot.docs.first.data() as Map<String, dynamic>);
        setState(() {
          _userProfileData = userData;
        });
      } else {
        print('User data does not exist.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<RoomsModel?> _getRoomData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('roomsData')
          .doc(widget.roomID)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<String> roomFacilities = List<String>.from(data['roomFacilities'] ?? []);

        String roomStatus = data['roomStatus'];
        RoomStatusModel roomStatus1 = roomStatusList.firstWhere(
              (status) => status.roomStatus == roomStatus,
          orElse: () => RoomStatusModel(
            roomStatusID: '',
            roomStatus: 'Unknown',
            sortOrder: 0,
            active: false,
          ),
        );

        String formattedRoomPrice = data['roomPrice'];
        double roomPrice = 0.0;
        if (formattedRoomPrice.startsWith('RM ')) {
          roomPrice = double.tryParse(formattedRoomPrice.substring(3)) ?? 0.0;
        }

        return RoomsModel(
          roomID: data['roomID'],
          images: List<String>.from(data['images'] ?? []),
          name: data['name'],
          about: data['about'],
          capacity: data['capacity'],
          roomStatus: roomStatus1,
          roomPrice: roomPrice,
          roomFacilities: roomFacilities,
          roomArea: data['roomArea'],
        );
      }
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDateTime ?? DateTime.now() : _checkOutDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime date) {
        return !(date.weekday == 6 || date.weekday == 7);
      },
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 8, minute: 0), 
      );
      if (pickedTime != null) {
        DateTime selectedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        if (selectedDateTime.hour >= 8 && selectedDateTime.hour <= 17) { 
          if (isCheckIn) {
            setState(() {
              _checkInDateTime = selectedDateTime;
              _calculateTotalPrice();
            });
          } else {
            if (selectedDateTime.isAfter(_checkInDateTime!)) {
              setState(() {
                _checkOutDateTime = selectedDateTime;
                _calculateTotalPrice();
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Checkout date and time must be after check-in date and time"),
              ));
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Please select a time between 8am and 5pm"),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please select a time"),
        ));
      }
    }
  }

  void _calculateTotalPrice() async {
    if (_checkInDateTime != null && _checkOutDateTime != null) {
      RoomsModel? roomData = await _roomData;

      if (roomData != null) {
        int numberOfDays = _checkOutDateTime!.difference(_checkInDateTime!).inDays;

        if (_checkOutDateTime!.isAfter(DateTime(_checkInDateTime!.year, _checkInDateTime!.month, _checkInDateTime!.day))) {
          numberOfDays++;
        }

        double totalPrice = numberOfDays * roomData.roomPrice;

        if (numberOfDays == 1 && _checkOutDateTime!.difference(_checkInDateTime!).inHours < 24) {
          totalPrice = roomData.roomPrice;
        }

        setState(() {
          _totalPrice = double.parse(totalPrice.toStringAsFixed(2));
        });
      }
    }
  }

  void _showBookingReservedMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Booking successfully reserved", style: TextStyle(color: shadeColor6, fontWeight: FontWeight.bold),),
          content: Text("Your booking has been reserved. Our staff will review and confirm your booking shortly.", style: TextStyle(color: shadeColor5)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  String generateDisplayBookingID() {
    String uuid = Uuid().v4();

    String numericalPart = uuid.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericalPart.length > 4) {
      numericalPart = numericalPart.substring(0, 4);
    }

    String paddedNumericalPart = numericalPart.padLeft(4, '0');

    return '#$paddedNumericalPart';
  }

  Future<void> _saveNewBooking() async {
    try {
      String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

      if (_checkInDateTime == null || _checkOutDateTime == null) {
        _showErrorMessage('Please select both check-in and check-out dates');
        return;
      }

      bool isOverlap = await _checkBookingOverlap();
      if (isOverlap) {
        _showErrorMessage('Selected dates overlap with existing bookings. Please choose different dates.');
        return;
      }

      double totalBookingPrice = _totalPrice;
      displayBookingID = generateDisplayBookingID();

      if (_userProfileData != null) {
        UserModel user = UserModel(
          userID: _userProfileData!['userID'],
          firstName: _userProfileData!['firstName'],
          lastName: _userProfileData!['lastName'],
          email: _userProfileData!['email'],
          phoneNumber: _userProfileData!['phoneNumber'],
          password: _userProfileData!['password'],
          companyName: _userProfileData!['companyName'],
          picture: _userProfileData!['picture'],
        );

        RoomsModel? roomData = await _roomData;

        if (roomData != null) {
          BookingStatusModel bookingStatus = BookingStatusModel(
            bookingStatusID: 'Pending',
            status: 'Pending',
            description: 'The booking is pending approval.',
            sortOrder: 1,
            active: true,
          );

          ManagerModel? manager = null;
          String formattedTotalBookingPrice = 'RM ' + totalBookingPrice.toStringAsFixed(2);

          RoomBookingModel roomBookingModel = RoomBookingModel(
            bookingID: bookingID,
            displayBookingID: displayBookingID,
            dateTimeBookingMade: dateTimeBookingMade,
            user: user,
            note: _userNote.text,
            manager:  manager,
            room: roomData,
            checkInDateTime: _checkInDateTime!,
            checkOutDateTime: _checkOutDateTime!,
            bookingStatus: bookingStatus,
            guestsDetails: GuestDetails(
              adults: _numberOfAdults,
              children: _numberOfChildren,
            ),
            totalBookingPrice: formattedTotalBookingPrice,
          );

          Map<String, dynamic> roomBookingData = roomBookingModel.toJson();

          await _firestore.collection('roomBookingData').doc(roomBookingModel.bookingID).set(roomBookingData);


          bool isBookingSaved = true;

          if (isBookingSaved) {
            LocalNotifications.showSimpleNotification(
              title: 'Teaching Factory',
              body: 'Your booking request has been successfully sent to our staff. Please wait for a while...',
              payload: 'tf.utem',
            );

            await _firestore.collection('notifications').add({
              'title': 'Teaching Factory',
              'body': 'Your booking request has been successfully sent to our staff. Please wait for a while...',
              'payload': 'tf.utem',
              'userEmail': currentUserEmail,
              'displayBookingID': displayBookingID,
            });
          }

          Navigator.pop(context, true);

        } else {
          _showErrorMessage('Room data is null');
        }
      }
      _showBookingReservedMessage(context);
    } catch (e) {
      _showErrorMessage('Failed to save journal entry: $e');
    }
  }

  void _showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool> _checkBookingOverlap() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('roomBookingData')
        .where('roomId', isEqualTo: widget.roomID)
        .where('bookingStatus.status', isEqualTo: 'Reserved') 
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> snapshot in querySnapshot.docs) {
      Map<String, dynamic> bookingData = snapshot.data();

      DateTime existingCheckIn = DateTime.parse(bookingData['checkInDateTime']);
      DateTime existingCheckOut = DateTime.parse(bookingData['checkOutDateTime']);

      if (_checkInDateTime != null && _checkOutDateTime != null &&
          _checkInDateTime!.isBefore(existingCheckOut) &&
          _checkOutDateTime!.isAfter(existingCheckIn)) {
        return true; 
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    String formattedCheckInDateTime = _checkInDateTime != null
        ? DateFormat('dd/MM/yyyy , hh:mm a').format(_checkInDateTime!)
        : 'Select Check-In';

    String formattedCheckOutDateTime = _checkOutDateTime != null
        ? DateFormat('dd/MM/yyyy , hh:mm a').format(_checkOutDateTime!)
        : 'Select Check-Out';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FutureBuilder<RoomsModel?>(
          future: _roomData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                'Loading...',
                style: TextStyle(color: shadeColor2),
              );
            } else if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: shadeColor2),
              );
            } else if (snapshot.data == null) {
              return Text(
                'Room Data Not Found',
                style: TextStyle(color: shadeColor2),
              );
            } else {
              return Text(
                snapshot.data!.name,
                style: TextStyle(color: shadeColor2, fontWeight: FontWeight.bold),
              );
            }
          },
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: shadeColor2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: AnimatedBackground(
        behaviour:  RandomParticleBehaviour(
          options: ParticleOptions(
            spawnMaxRadius: 50,
            spawnMaxSpeed: 50,
            particleCount: 68,
            spawnMinSpeed: 10,
            minOpacity: 0.3,
            spawnOpacity: 0.4,
            baseColor: shadeColor1,
          ),
        ),
        vsync: this,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 380,
                  height: 240,
                  decoration: BoxDecoration(
                    color: shadeColor1,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: shadeColor2,
                      width: 1.0, 
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 30),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Check-In',
                                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 5), 
                              InkWell(
                                onTap: () => _selectDate(context, true),
                                child: Text(
                                  formattedCheckInDateTime,
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: _checkInDateTime != null ? shadeColor6 : Colors.grey, 
                                  ),
                                ),
                              ),
                              SizedBox(height: 40),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: Text(
                                  'Check-Out',
                                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 5),
                              InkWell(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  width: 180,
                                  child: Text(
                                    formattedCheckOutDateTime,
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: _checkOutDateTime != null ? shadeColor6 : Colors.grey, 
                                    ),
                                  ),
                                ),
                              ),
                          
                            ],
                          ),
                        ),
                        VerticalLine(
                          height: 220,
                          color: shadeColor2.withOpacity(0.6),
                        ),
                        SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guest',
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Adults :',
                              style: TextStyle(fontSize: 15.0, color: shadeColor6, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      if (_numberOfAdults > 0) {
                                        _numberOfAdults--;
                                      }
                                      _adultsController.text = _numberOfAdults.toString();
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 30,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15.0, color: shadeColor6, fontWeight: FontWeight.bold),
                                    controller: _adultsController,
                                    onChanged: (value) {
                                      setState(() {
                                        _numberOfAdults = int.tryParse(value) ?? 0;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      _numberOfAdults++;
                                      _adultsController.text = _numberOfAdults.toString();
                                    });
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: 20),
                            Text(
                              'Children :', 
                              style: TextStyle(fontSize: 15.0, color: shadeColor6, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      if (_numberOfChildren > 0) {
                                        _numberOfChildren--;
                                      }
                                      _childrenController.text = _numberOfChildren.toString();
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 30,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 15.0, color: shadeColor6, fontWeight: FontWeight.bold),
                                    controller: _childrenController,
                                    onChanged: (value) {
                                      setState(() {
                                        _numberOfChildren = int.tryParse(value) ?? 0;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      _numberOfChildren++;
                                      _childrenController.text = _numberOfChildren.toString();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: HorizontalLine(
                  width: 380,
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 20,),
              Center(
                child: Container(
                  width: 380,
                  height: 220,
                  decoration: BoxDecoration(
                    color: shadeColor1,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: shadeColor2, 
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Info',
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black), 
                            ),
                            SizedBox(height: 10),
                            if (_userProfileData != null)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(34),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.person, color: shadeColor6),
                                              SizedBox(width: 10),
                                              Text(
                                                'Name:',
                                                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: shadeColor6),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                '${_userProfileData!['firstName']} ${_userProfileData!['lastName']}', 
                                                style: TextStyle(fontSize: 15.0, color: shadeColor5),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.email, color: shadeColor6),
                                              SizedBox(width: 10),
                                              Text(
                                                'Email:',
                                                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: shadeColor6),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                _userProfileData!['email'],
                                                style: TextStyle(fontSize: 15.0, color: shadeColor5),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.phone, color: shadeColor6), 
                                              SizedBox(width: 10),
                                              Text(
                                                'Phone Number:',
                                                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: shadeColor6),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                _userProfileData!['phoneNumber'], 
                                                style: TextStyle(fontSize: 15.0, color: shadeColor5),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_userProfileData == null)
                              Text(
                                'User Info Not Available',
                                style: TextStyle(fontSize: 15.0),
                              ),
                          ],
                        ),


                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Center(
                child: Container(
                  width: 380,
                  height: 280,
                  decoration: BoxDecoration(
                    color: shadeColor1,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: shadeColor2,
                      width: 1.0, 
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Note (Optional)',
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black), 
                            ),
                            SizedBox(height: 10),
                            Container(
                              width: 340,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: shadeColor2,
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                maxLines: 5, 
                                maxLength: 60,
                                keyboardType: TextInputType.multiline, 
                                textAlign: TextAlign.start, 
                                style: TextStyle(fontSize: 15.0, color: shadeColor6, fontWeight: FontWeight.bold),
                                controller: _userNote,
                                decoration: InputDecoration(
                                  hintText: 'Add your note...',
                                  border: OutlineInputBorder(), 
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: HorizontalLine(
                  width: 380,
                  color: Colors.grey.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 20,),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Price',
                            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black), 
                          ),
                          SizedBox(height: 5,),
                          Text(
                            'RM ${_totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18.0, color: shadeColor6), 
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 150, top: 20), 
                        child: ElevatedButton(
                          onPressed: _saveNewBooking,
                          child: Text('Book Now', style: TextStyle(color: Colors.white), ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: shadeColor6, 
                          ),
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

class VerticalLine extends StatelessWidget {
  final double height;
  final Color color;

  VerticalLine({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: 1.0, 
      color: color,
    );
  }
}

class HorizontalLine extends StatelessWidget {
  final double width;
  final Color color;

  HorizontalLine({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.0, 
      width: width, 
      color: color,
    );
  }
}
