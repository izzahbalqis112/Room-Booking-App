import 'package:flutter/material.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/confirmedBooked/confirmedBooking.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/pending/cancelledBooking.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/completedBooked/completedBooking.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/pending/pendingBooking.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/process/processBooking.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/rejectedBookig.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/paymentMethod/toPayBooking.dart';
import '../../../Assets/Colors.dart';

class BookingHistoryPage extends StatefulWidget {
  final int initialTabIndex;

  BookingHistoryPage({required this.initialTabIndex});

  @override
  _BookingHistoryPageState createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: shadeColor1,
        title: Text(
          "My Booking Details",
          style: TextStyle(
            color: shadeColor6,
            fontWeight: FontWeight.bold, // Making the text bold
          ),
          textAlign: TextAlign.center, // Centering the text
        ),
        centerTitle: true,
        // Centering the title in the app bar
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: shadeColor2,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: shadeColor5,
          ),
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'To Pay'),
            Tab(text: 'Process',),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
            Tab(text: 'Rejected'),
          ],
          indicatorColor: shadeColor2,
          indicatorWeight: 4.0,
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PendingBookingPage(),
          ConfirmBookingPage(),
          ToPayBookingPage(),
          ProcessBookingPage(),
          CompletedBookingPage(),
          CancelledBookingPage(),
          RejectingBookingPage(),
        ],
      ),
    );
  }
}
