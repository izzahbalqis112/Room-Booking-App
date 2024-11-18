import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../assets/Colors.dart';
import '../manageBooking/completedBooked/ratingBar.dart';

class RatingsReviewsHistoryPage extends StatefulWidget {
  @override
  _RatingsReviewsHistoryPageState createState() => _RatingsReviewsHistoryPageState();
}

class _RatingsReviewsHistoryPageState extends State<RatingsReviewsHistoryPage> {
  String? selectedDateFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedDateFilter,
              hint: Text('Filter by date'),
              onChanged: (newValue) {
                setState(() {
                  selectedDateFilter = newValue;
                });
              },
              items: <String>['Today', 'Yesterday', 'This Week', 'This Month', 'This Year']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(child: RatingsList(dateFilter: selectedDateFilter)),
        ],
      ),
    );
  }
}

class RatingsList extends StatelessWidget {
  final String? dateFilter;

  RatingsList({this.dateFilter});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _fetchCompletedBookings(),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final ratings = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            children: ratings.map((rating) {
              final bookingRatings = rating['bookingRatings'] as Map<String, dynamic>;

              if (bookingRatings == null || !bookingRatings.containsKey('userRating') || bookingRatings['userRating'] == null) {
                return ListTile(
                  title: Text(
                    'No ratings available',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              final user = rating['user'] as Map<String, dynamic>;
              final userRating = bookingRatings['userRating'] as double;
              final room = rating['room'] as Map<String, dynamic>;

              final dateTime = (bookingRatings['dateTimeToday'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
              final formattedTime = DateFormat('hh:mm a').format(dateTime);

              return ListTile(
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        user['picture'] ?? '',
                      ),
                    ),
                    SizedBox(width: 10), 
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16.0, 
                                color: Colors.black, 
                              ),
                              children: [
                                TextSpan(text: '${user['firstName']} ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: user['lastName']),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Booking ID ${rating['displayBookingID']}',
                            style: TextStyle(fontSize: 14.0, color: shadeColor2), 
                          ),
                          Text(
                            '${room['name']}',
                            style: TextStyle(fontSize: 14.0, color: shadeColor2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: RatingBar.builder(
                            initialRating: userRating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemSize: 20.0,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                            },
                          ),
                        ),
                        SizedBox(width: 10), 
                        Text('$formattedDate , $formattedTime', style: TextStyle(fontSize: 14.0)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('${bookingRatings['reviews']}', style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<List<DocumentSnapshot>> _fetchCompletedBookings() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return [];
    }
    String currentUserEmail = currentUser.email!;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('roomBookingData')
        .where('bookingStatus.status', isEqualTo: 'Completed')
        .where('user.email', isEqualTo: currentUserEmail)
        .get();

    DateTime now = DateTime.now();
    List<DocumentSnapshot> filteredDocs = snapshot.docs.where((doc) {
      final bookingRatings = doc['bookingRatings'] as Map<String, dynamic>?;
      if (bookingRatings == null || !bookingRatings.containsKey('userRating')) {
        return false;
      }
      final dateTime = (bookingRatings['dateTimeToday'] as Timestamp).toDate();

      switch (dateFilter) {
        case 'Today':
          return DateFormat('yyyy-MM-dd').format(dateTime) == DateFormat('yyyy-MM-dd').format(now);
        case 'Yesterday':
          return DateFormat('yyyy-MM-dd').format(dateTime) == DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: 1)));
        case 'This Week':
          DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
          DateTime weekEnd = weekStart.add(Duration(days: 6));
          return dateTime.isAfter(weekStart) && dateTime.isBefore(weekEnd.add(Duration(days: 1)));
        case 'This Month':
          return dateTime.month == now.month && dateTime.year == now.year;
        case 'This Year':
          return dateTime.year == now.year;
        default:
          return true;
      }
    }).toList();

    return filteredDocs;
  }
}
