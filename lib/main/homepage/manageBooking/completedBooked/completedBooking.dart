import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/completedBooked/ratingBar.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/completedBooked/selectedBookedDetailsPage.dart';
import '../../../../assets/Colors.dart';

class CompletedBookingPage extends StatefulWidget {
  @override
  _CompletedBookingPageState createState() => _CompletedBookingPageState();
}

class _CompletedBookingPageState extends State<CompletedBookingPage> {
  double _userRating = 0.0;
  late Future<List<DocumentSnapshot>> _CompletedBookingsFuture;

  @override
  void initState() {
    super.initState();
    _CompletedBookingsFuture = _fetchCompletedBookings();
  }

  Future<List<DocumentSnapshot>> _fetchCompletedBookings() async {
    // Get the current user's email
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    // Query Firestore for completed bookings belonging to the current user
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomBookingData')
        .where('bookingStatus.status', isEqualTo: 'Completed')
        .where('user.email', isEqualTo: currentUserEmail)
        .get();

    return snapshot.docs;
  }

  void _ratingsSaved(String bookingId, String userDescription) async {
    try {
      DocumentReference bookingRef = FirebaseFirestore.instance.collection('roomBookingData').doc(bookingId);

      // Update bookingRatings field
      await bookingRef.set({
        'bookingRatings': {
          'userRating': _userRating,
          'reviews': userDescription,
          'dateTimeToday': DateTime.now(),
        }
      }, SetOptions(merge: true));

      // Reload the page
      setState(() {
        _CompletedBookingsFuture = _fetchCompletedBookings();
      });

      Navigator.pop(context);
    } catch (error) {
      print('Error updating booking rating: $error');
      // Handle error
    }
  }

  void _showBottomSheet(BuildContext context, String bookingId, bool hasRated) {
    if (hasRated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already rated this booking.')),
      );
      return;
    }

    TextEditingController _descriptionController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Rate your experience with us!',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.0),
                RatingBar(
                  initialRating: _userRating,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.amber),
                    half: Icon(
                      Icons.star_half,
                      color: Colors.amber,
                    ),
                    empty: Icon(
                      Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _userRating = rating;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                Text(
                  'Rating: $_userRating',
                  style: TextStyle(fontSize: 16.0, color: shadeColor5),
                ),
                SizedBox(height: 20.0),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: 'Describe your experience (optional)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.length > 500) {
                        return 'Description must be less than 500 characters';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _ratingsSaved(bookingId, _descriptionController.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: shadeColor2,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text('Post'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _CompletedBookingsFuture,
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
                DocumentSnapshot booking = bookings[index];
                var bookingData = booking.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
                bool hasRated = bookingData['bookingRatings'] != null;
                return Column(
                  children: [
                    SizedBox(height: 20),
                    SingleChildScrollView(
                      child: ContainerWidget(
                        booking: booking,
                        showBottomSheet: (context) => _showBottomSheet(context, booking.id, hasRated),
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
  final Function(BuildContext) showBottomSheet;
  final DocumentSnapshot booking;

  const ContainerWidget({Key? key, required this.booking, required this.showBottomSheet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from the booking document
    var displayBookingID = booking['displayBookingID'] ?? '';
    var roomName = booking['room']['name'] ?? '';
    var status = booking['bookingStatus']['status'] ?? '';
    var totalPrice = booking['totalBookingPrice'] ?? 0;
    var checkInDate = DateTime.parse(booking['checkInDateTime'] as String).toLocal();
    var checkOutDate = DateTime.parse(booking['checkOutDateTime'] as String).toLocal();

    var checkInDateNoTime = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    var checkOutDateNoTime = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);

    var numberOfDays = checkOutDateNoTime.difference(checkInDateNoTime).inDays;

    List<dynamic> roomImages = booking['room']['images'] ?? [];
    DecorationImage? backgroundImage;

    if (roomImages.isNotEmpty) {
      // Assuming you want to use the first image in the list
      String imageUrl = roomImages[0];
      backgroundImage = DecorationImage(
        image: CachedNetworkImageProvider(imageUrl),
        fit: BoxFit.cover,
      );
    }

    return Container(
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
              status,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$roomName',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: shadeColor6,
                  ),
                ),
              ],
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
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectedBookedDetailsPage(booking: booking,),
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
                  'Booking confirmed! Rate our service & room.',
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
                  onPressed: () => showBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: shadeColor6,
                  ),
                  child: Text(
                    'Rate Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
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
