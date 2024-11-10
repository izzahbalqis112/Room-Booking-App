import 'package:flutter/material.dart';
import 'package:tfrb_userside/main/homepage/more/ratingsReviewsHistory.dart';
import '../../../assets/Colors.dart';
import 'notification/not.dart';

class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          "My Notification & Ratings",
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
            Tab(text: 'Notification'),
            Tab(text: 'Ratings History'),
          ],
          indicatorColor: shadeColor2,
          indicatorWeight: 4.0,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          NotificationPage(),
          RatingsReviewsHistoryPage(),
        ],
      ),
    );
  }
}
