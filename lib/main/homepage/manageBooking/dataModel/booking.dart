import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfrb_userside/main/homepage/manageBooking/rooms/dataModel/rooms.dart';
import '../../../userModel.dart';
import 'bookingStatus.dart';
import 'managerModel.dart';

class GuestDetails {
  final int adults;
  final int children;

  GuestDetails({
    required this.adults,
    required this.children,
  });

  Map<String, dynamic> toJson() {
    return {
      'adults': adults,
      'children': children,
    };
  }
}

class RoomBookingModel {
  final String bookingID;
  final String displayBookingID;
  final Timestamp dateTimeBookingMade;
  final UserModel user;
  final String? note;
  final ManagerModel? manager;
  final RoomsModel room;
  final DateTime checkInDateTime;
  final DateTime checkOutDateTime;
  final BookingStatusModel bookingStatus;
  final GuestDetails? guestsDetails;
  final String totalBookingPrice;

  RoomBookingModel({
    required this.bookingID,
    required this.displayBookingID,
    required this.dateTimeBookingMade,
    required this.user,
    this.manager,
    required this.room,
    required this.checkInDateTime,
    required this.checkOutDateTime,
    required this.bookingStatus,
    this.guestsDetails,
    required this.totalBookingPrice,
    this.note,
  });

  factory RoomBookingModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return RoomBookingModel(
      bookingID: doc.id,
      displayBookingID: data['displayBookingID'] as String,
      dateTimeBookingMade: data['dateTimeBookingMade'] as Timestamp,
      user: UserModel.fromDocument(data['user'] as DocumentSnapshot<Map<String, dynamic>>),
      manager: ManagerModel.fromDocument(data['manager'] as DocumentSnapshot<Map<String, dynamic>>),
      room: RoomsModel.fromDocument(data['room'] as DocumentSnapshot<Map<String, dynamic>>),
      checkInDateTime: (data['checkInDateTime'] as Timestamp).toDate(),
      checkOutDateTime: (data['checkOutDateTime'] as Timestamp).toDate(),
      bookingStatus: BookingStatusModel.fromDocument(data['bookingStatus'] as DocumentSnapshot<Map<String, dynamic>>),
      guestsDetails: data['guestsDetails'] != null
          ? GuestDetails(
        adults: data['guestsDetails']['adults'] as int,
        children: data['guestsDetails']['children'] as int,
      )
          : null,
      totalBookingPrice: data['totalBookingPrice'] as String,
      note: data['note'] as String?,
    );
  }

  factory RoomBookingModel.fromJson(Map<String, dynamic> json) {
    return RoomBookingModel(
      bookingID: json['bookingID'] as String,
      displayBookingID: json['displayBookingID'] as String,
      dateTimeBookingMade: json['dateTimeBookingMade'] as Timestamp,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      manager: ManagerModel.fromJson(json['manager'] as Map<String, dynamic>),
      room: RoomsModel.fromJson(json['room'] as Map<String, dynamic>),
      checkInDateTime: DateTime.parse(json['checkInDateTime'] as String),
      checkOutDateTime: DateTime.parse(json['checkOutDateTime'] as String),
      bookingStatus: BookingStatusModel.fromJson(json['bookingStatus'] as Map<String, dynamic>),
      guestsDetails: json['guestsDetails'] != null
          ? GuestDetails(
        adults: json['guestsDetails']['adults'] as int,
        children: json['guestsDetails']['children'] as int,
      )
          : null,
      totalBookingPrice: json['totalBookingPrice'] as String,
      note: json['note'] as String?, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingID': bookingID,
      'displayBookingID': displayBookingID,
      'dateTimeBookingMade': dateTimeBookingMade,
      'user': user.toJson(),
      'manager': manager != null ? manager!.toJson() : null,
      'room': room.toJson(),
      'checkInDateTime': checkInDateTime.toIso8601String(),
      'checkOutDateTime': checkOutDateTime.toIso8601String(),
      'bookingStatus': bookingStatus.toJson(),
      'guestsDetails': guestsDetails != null ? guestsDetails!.toJson() : null,
      'totalBookingPrice': totalBookingPrice,
      'note': note, 
    };
  }
}
