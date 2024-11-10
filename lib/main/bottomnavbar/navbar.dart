import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/bookingHistory.dart';
import '../../Assets/Colors.dart';
import '../homepage/homepage.dart';
import '../homepage/more/morePage.dart';
import '../profile/profile.dart';

class ButtomNavBar extends StatefulWidget {
  @override
  _ButtomNavBarState createState() => _ButtomNavBarState();
}

class _ButtomNavBarState extends State<ButtomNavBar> {
  int index = 0;

  final screens = [
    HomePage(),
    BookingHistoryPage(initialTabIndex: 0),
    MorePage(),
    Profile(), //buat another method untuk part ni. kalau user login guna staff, die gi kat staff profile page
  ];

  @override
  Widget build(BuildContext context) {
    final items = <Widget> [
      Icon(Icons.home, size: 20, color: Colors.white,),
      Icon(Icons.history, size: 20, color: Colors.white,),
      Icon(Icons.rate_review, size: 20, color: Colors.white,),
      Icon(Icons.person, size: 20, color: Colors.white,),
    ];
    return Container(
      color: shadeColor2,
      child: SafeArea(
        top: true,
        child: Scaffold(
          extendBody: true,
          body: screens[index],
          bottomNavigationBar: CurvedNavigationBar(
            height: 60,
            index: index,
            items: items,
            color: shadeColor2,
            animationDuration: Duration(milliseconds: 300),
            backgroundColor: Colors.transparent,
            onTap: (newIndex) {
              setState(() {
                index = newIndex;
              });
            },
          ),
        ),
      ),
    );
  }
}
