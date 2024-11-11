import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/pending/viewMoreBookingDetails.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../assets/Colors.dart';

class PendingBookingPage extends StatefulWidget {

  @override
  _PendingBookingPageState createState() => _PendingBookingPageState();
}

class _PendingBookingPageState extends State<PendingBookingPage> {
  late Future<List<DocumentSnapshot>> _pendingBookingsFuture;

  @override
  void initState() {
    super.initState();
    _pendingBookingsFuture = _fetchPendingBookings();
  }


  Future<List<DocumentSnapshot>> _fetchPendingBookings() async {
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomBookingData')
        .where('bookingStatus.status', isEqualTo: 'Pending')
        .where('user.email', isEqualTo: currentUserEmail) 
        .get();

    return snapshot.docs;
  }

  void _reloadPendingBookings() {
    setState(() {
      _pendingBookingsFuture = _fetchPendingBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _pendingBookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<DocumentSnapshot> bookings = snapshot.data ?? [];
            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                var booking = bookings[index];
                return Column(
                  children: [
                    SizedBox(height: 20),
                    SingleChildScrollView(
                      child: ContainerWidget(
                        booking: booking,
                        reloadPendingBookings: _reloadPendingBookings,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}


class ContainerWidget extends StatelessWidget {
  final DocumentSnapshot booking;
  final Function reloadPendingBookings;

  const ContainerWidget({
    Key? key,
    required this.booking,
    required this.reloadPendingBookings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var displayBookingID = booking['displayBookingID'] ?? '';
    var roomName = booking['room']['name'] ?? '';
    var pendingStatus = booking['bookingStatus']['status'] ?? '';
    var totalPrice = booking['totalBookingPrice'] ?? 0;
    var checkInDate = DateTime.parse(booking['checkInDateTime'] as String).toLocal();
    var checkOutDate = DateTime.parse(booking['checkOutDateTime'] as String).toLocal();

    var checkInDateNoTime = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    var checkOutDateNoTime = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);

    var numberOfDays = checkOutDateNoTime.difference(checkInDateNoTime).inDays;


    List<dynamic> roomImages = booking['room']['images'] ?? [];
    DecorationImage? backgroundImage;

    if (roomImages.isNotEmpty) {
      String imageUrl = roomImages[0];
      backgroundImage = DecorationImage(
        image: CachedNetworkImageProvider(imageUrl),
        fit: BoxFit.cover,
      );
    }

    Future<void> _deleteBooking(BuildContext context) async {
      try {
        final bookingRef = FirebaseFirestore.instance.collection('roomBookingData').doc(booking.id);

        await bookingRef.delete();

        reloadPendingBookings();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking deleted successfully')),
        );
      } catch (error) {
        print('Error deleting booking: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete booking')),
        );
      }
    }


    return  GestureDetector(
      onDoubleTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirm Action"),
            content: Text("Do you want to delete or cancel this booking?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteBooking(context);
                },
                child: Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No"),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: 500,
        height: 280,
        decoration: BoxDecoration(
          color: shadeColor1,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: Text(
                pendingStatus,
                style: TextStyle(
                  fontSize: 16,
                  color: shadeColor2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Text(
                roomName,
                style: TextStyle(
                  fontSize: 18,
                  color: shadeColor6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 10,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  image: backgroundImage,
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking ID : $displayBookingID',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 110,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$numberOfDays days',
                    style: TextStyle(
                      fontSize: 14,
                      color: shadeColor5,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 160,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalPrice',
                    style: TextStyle(
                      fontSize: 16,
                      color: shadeColor6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 130,
              left: 130,
              child: TextButton( // Use TextButton for button appearance
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMoreSelectedBookingIDDetailsPage(
                        bookingId: booking.id,
                        reloadPendingBookings: reloadPendingBookings, 
                      ),
                    ),
                  );
                },
                child: Text(
                  'View More >',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: shadeColor2,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 190),
              child: HorizontalLine(
                width: 480,
                color: Colors.grey.withOpacity(0.6),
              ),
            ),
            Positioned(
              top: 200,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking is reserved! Waiting for our staff to confirm...',
                    style: TextStyle(
                      fontSize: 14,
                      color: shadeColor5,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 224,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () async{
                      final Uri url = Uri(
                        scheme: 'tel',
                        path: "+6062702269",
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else{
                        print('cannot launch this url');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: shadeColor6,
                    ),
                    child: Text('Contact US', style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
