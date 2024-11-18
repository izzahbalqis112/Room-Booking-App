import 'dart:async';
import 'package:animated_background/animated_background.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tfrb_userside/main/homepage/search.dart';
import '../../assets/Colors.dart';
import 'manageBooking/rooms/dataModel/roomStatus.dart';
import 'manageBooking/rooms/dataModel/rooms.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'manageBooking/rooms/viewSelectedRoomData.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  with TickerProviderStateMixin{
  late Future<List<RoomsModel>> _roomsData;
  int _currentIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _loadRoomsData();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  Future<void> _loadRoomsData() async {
    setState(() {
      _roomsData = _getRoomsData();
    });
  }

  Future<List<RoomsModel>> _getRoomsData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('roomsData')
          .get();

      List<RoomsModel> roomsList = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
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
        double roomPrice = double.tryParse(formattedRoomPrice.substring(3)) ?? 0.0;

        roomsList.add(RoomsModel(
          roomID: data['roomID'],
          images: List<String>.from(data['images'] ?? []),
          name: data['name'],
          about: data['about'],
          capacity: data['capacity'],
          roomStatus: roomStatus1,
          roomPrice: roomPrice,
          roomFacilities: roomFacilities,
          roomArea: data['roomArea'],
        ));
      }

      roomsList.sort((a, b) => a.name.compareTo(b.name));

      return roomsList;
    } else {
      return [];
    }
  }

  void _startTimer(List<RoomsModel> rooms) {
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % rooms.length;
        });
      }
    });
  }

  final Map<String, IconData> facilityIcons = {
    'Electric': EvaIcons.flash,
    'Water': EvaIcons.droplet,
    'Crane': Icons.fire_truck,
    'Table': Icons.table_bar,
    'Chair': Icons.chair,
    'Aircon': EvaIcons.thermometerMinus,
  };

  void _navigateToSearchPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            _navigateToSearchPage(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.grey.shade300), 
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), 
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.search, color: shadeColor6),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(color: shadeColor5),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            children: [
              Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 26, left: 4),
                              child: Container(
                                width: 80, 
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'lib/assets/img/TF-logo1.png', 
                                    width: 60, 
                                    height: 60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 18, left: 20),
                              child: Text(
                                'Book your room here !',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        FutureBuilder<List<RoomsModel>>(
                          future: _roomsData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError || snapshot.data == null) {
                              return Center(
                                child: Text('Error: Unable to fetch data'),
                              );
                            } else {
                              final rooms = snapshot.data!;
                              _startTimer(rooms);
                              return SingleChildScrollView(
                                child: Column(
                                  children: rooms.map((room) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewSelectedRoomDataPage(
                                              roomID: room.roomID,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 400,
                                        width: 380,
                                        decoration: BoxDecoration(
                                          color: shadeColor1,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: shadeColor2, 
                                            width: 2.0, 
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              top: 0,
                                              left: 0,
                                              right: 0,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20.0),
                                                  topRight: Radius.circular(20.0),
                                                ),
                                                child: Container(
                                                  height: 180,
                                                  width: 340,
                                                  child: PageView.builder(
                                                    itemCount: room.images.length,
                                                    controller: PageController(
                                                      initialPage: _currentIndex,
                                                    ),
                                                    onPageChanged: (index) {
                                                      setState(() {
                                                        _currentIndex = index;
                                                      });
                                                    },
                                                    itemBuilder: (context, index) {
                                                      return AnimatedSwitcher(
                                                        duration: Duration(milliseconds: 500),
                                                        child: CachedNetworkImage(
                                                          imageUrl: room.images[index],
                                                          fit: BoxFit.cover,
                                                          height: 200,
                                                          width: 400,
                                                          placeholder: (context, url) => CircularProgressIndicator(),
                                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 30,
                                              left: 20,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    room.name,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5), 
                                                  Container(
                                                    width: 360,
                                                    child: SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Text(
                                                        room.about,
                                                        style: TextStyle(
                                                          color: shadeColor5,
                                                          fontSize: 16,
                                                        ),
                                                        maxLines: 3, 
                                                        overflow: TextOverflow.ellipsis, 
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(top: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        for (String facility in room.roomFacilities ?? [])
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 4.0),
                                                            child: buildFacility(facility),
                                                          ),
                                                      ],
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              top: 190,
                                              right: 20,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'RM ' + room.roomPrice.toStringAsFixed(2), 
                                                        style: TextStyle(
                                                          color: shadeColor2,
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(width: 5), 
                                                      Text(
                                                        '/day', 
                                                        style: TextStyle(
                                                          color: shadeColor5,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(height: 80),
                      ],
                    ),
                  ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildFacility(String facilityName) {
    IconData iconData = facilityIcons[facilityName] ?? EvaIcons.questionMarkCircleOutline; 
    return Column(
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: shadeColor2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            iconData,
            color: Colors.white,
            size: 22,
          ),
        ),
        SizedBox(height: 5),
        Text(
          facilityName,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
