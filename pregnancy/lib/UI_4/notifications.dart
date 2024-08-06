import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationService {
  Future<void> init() async {
    // Initialize the Firestore listeners
    _listenForFirestoreChanges();
    _checkAppointments();
  }

  Future<void> saveNotificationToDatabase(String title, String body, String receiverId) async {
    await FirebaseFirestore.instance
        .collection('user_accounts')
        .doc(receiverId)
        .collection('notifications')
        .add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _listenForFirestoreChanges() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('chats').snapshots().listen((snapshot) {
        for (var docChange in snapshot.docChanges) {
          try {
            if (docChange.type == DocumentChangeType.added || docChange.type == DocumentChangeType.modified) {
              var chat = docChange.doc.data();
              if (chat != null) {
                String receiverId = chat['specialistId'] as String? ?? '';
                if (chat['createdBy'] == user.uid) {
                  receiverId = chat['createdBy'] as String? ?? '';
                } else {
                  receiverId = chat['specialistId'] as String? ?? '';
                }

                if (receiverId.isNotEmpty && receiverId != user.uid) {
                  saveNotificationToDatabase(
                    'New message in chat with ${chat['specialistName'] ?? 'Unknown'}',
                    chat['lastMessage'] ?? 'No message',
                    receiverId,
                  );
                }
              }
            }
          } catch (e) {
            print('Error processing Firestore changes: $e');
          }
        }
      });
    }
  }

  Future<void> _checkAppointments() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      FirebaseFirestore.instance
          .collection('user_accounts')
          .doc(user.uid)
          .collection('appt_info')
          .where('Alert Me', isEqualTo: true)
          .snapshots()
          .listen((snapshot) {
        for (var doc in snapshot.docs) {
          try {
            var data = doc.data();
            DateTime appointmentDate = DateFormat('dd/MM/yyyy').parse(data['Date']);

            if (appointmentDate.year == tomorrow.year &&
                appointmentDate.month == tomorrow.month &&
                appointmentDate.day == tomorrow.day) {
              saveNotificationToDatabase(
                'Appointment Reminder',
                'You have an appointment with ${data['Doctor Name']} at ${data['Location']} tomorrow at ${data['Time']}',
                user.uid,
              );
            }
          } catch (e) {
            print('Error processing appointment data: $e');
          }
        }
      });
    }
  }
}
