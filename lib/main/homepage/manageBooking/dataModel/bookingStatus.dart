import 'package:cloud_firestore/cloud_firestore.dart';

class BookingStatusModel {
  final String bookingStatusID;
  final String status;
  final String? description;
  final int sortOrder;
  final bool active;

  BookingStatusModel({
    required this.bookingStatusID,
    required this.status,
    this.description,
    required this.sortOrder,
    required this.active,
  });

  factory BookingStatusModel.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    var data = doc.data()!;
    return BookingStatusModel(
      bookingStatusID: doc.id,
      status: data['status'] as String,
      description: data['description'] as String?,
      sortOrder: data['sortOrder'] as int,
      active: data['active'] as bool,
    );
  }

  factory BookingStatusModel.fromJson(Map<String, dynamic> json) {
    return BookingStatusModel(
      bookingStatusID: json['bookingStatusID'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      sortOrder: json['sortOrder'] as int,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingStatusID': bookingStatusID,
      'status': status,
      'description': description,
      'sortOrder': sortOrder,
      'active': active,
    };
  }

}

List<Map<String, dynamic>> updatedSampleStatuses = [
  {
    'status': 'Pending',
    'description': 'The booking request is awaiting confirmation or further action.',
    'sortOrder': 1,
    'active': true,
  },
  {
    'status': 'Confirmed',
    'description': 'The booking has been successfully reserved and is confirmed for the specified date and time.',
    'sortOrder': 2,
    'active': true,
  },
  {
    'status': 'On hold',
    'description': 'The booking is temporarily held, often awaiting further information or confirmation.',
    'sortOrder': 3,
    'active': true,
  },
  {
    'status': 'Cancelled',
    'description': 'The booking has been cancelled either by the user or by the system.',
    'sortOrder': 4,
    'active': true,
  },
  {
    'status': 'Waitlisted',
    'description': 'The booking is on a waiting list and is pending availability.',
    'sortOrder': 5,
    'active': true,
  },
  {
    'status': 'Reserved',
    'description': 'The booking has been reserved but may require confirmation or payment to be finalized.',
    'sortOrder': 6,
    'active': true,
  },
  {
    'status': 'Completed',
    'description': 'The booking has been successfully fulfilled.',
    'sortOrder': 7,
    'active': true,
  },
  {
    'status': 'Arrived',
    'description': 'Indicates that the customer or participant has arrived for the booked service or event.',
    'sortOrder': 8,
    'active': true,
  },
  {
    'status': 'No show',
    'description': 'The customer failed to arrive for the booking without prior cancellation.',
    'sortOrder': 9,
    'active': true,
  },
  {
    'status': 'Tentative',
    'description': 'The booking is not yet confirmed and is subject to change or cancellation.',
    'sortOrder': 10,
    'active': true,
  },
  {
    'status': 'Pending payment',
    'description': 'The booking requires payment to be finalized or confirmed.',
    'sortOrder': 11,
    'active': true,
  },
  {
    'status': 'Processing',
    'description': 'The booking request is being processed by the system or administrative staff.',
    'sortOrder': 12,
    'active': true,
  },
  {
    'status': 'Expired',
    'description': 'The booking has passed its expiration date and is no longer valid.',
    'sortOrder': 13,
    'active': true,
  },
  {
    'status': 'In progress',
    'description': 'The booking is currently being fulfilled or serviced.',
    'sortOrder': 14,
    'active': true,
  },
  {
    'status': 'Partially completed',
    'description': 'Indicates that only a portion of the booking has been fulfilled or completed.',
    'sortOrder': 15,
    'active': true,
  },
];
