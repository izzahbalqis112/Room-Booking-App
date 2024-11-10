import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _notifications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _fetchNotifications(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _notifications = snapshot.data!.docs;
            return ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                var notification = _notifications[index].data() as Map<String, dynamic>;
                return Dismissible(
                  key: Key(_notifications[index].id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    var notificationId = _notifications[index].id; // Simpan ID notifikasi sebelum memadamkan
                    setState(() {
                      _notifications.removeAt(index);
                    });
                    _deleteNotification(notificationId); // Gunakan ID notifikasi yang disimpan untuk pemadaman
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10), // Add padding to ListTile content
                      title: Text(
                        notification['title'] ?? 'No title',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(
                            notification['body'] ?? 'No body',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Booking ID: ${notification['displayBookingID'] ?? 'No ID'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<QuerySnapshot> _fetchNotifications() async {
    // Dapatkan e-mel pengguna semasa
    String? currentUserEmail = _auth.currentUser?.email;

    // Query Firestore untuk notifikasi berdasarkan e-mel pengguna semasa
    QuerySnapshot querySnapshot = await _firestore
        .collection('notifications')
        .where('userEmail', isEqualTo: currentUserEmail)
        .get();
    return querySnapshot;
  }
}
