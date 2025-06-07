import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'booking_detail_page.dart';

class BookingHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final bookingRef = FirebaseFirestore.instance.collection('bookings');

    return Scaffold(
      appBar: AppBar(title: Text('ประวัติการจอง')),
      body: FutureBuilder<QuerySnapshot>(
        future: bookingRef.where('userId', isEqualTo: userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('ยังไม่มีการจอง'));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];
              String fieldId = booking['fieldId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('sports_fields')
                    .doc(fieldId)
                    .get(),
                builder: (context, fieldSnapshot) {
                  if (!fieldSnapshot.hasData) return SizedBox();
                  var field = fieldSnapshot.data!;
                  String fieldName = field['name'] ?? 'ไม่ทราบชื่อสนาม';

                  return ListTile(
                    title: Text(fieldName),
                    subtitle: Text('วันที่: ${booking['date']} เวลา: ${booking['time']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingDetailPage(
                            bookingId: booking.id,
                            bookingData: booking.data() as Map<String, dynamic>,
                            fieldData: field.data() as Map<String, dynamic>,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
