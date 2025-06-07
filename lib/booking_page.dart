import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'venue_detail_readonly.dart'; // <-- เพิ่มตรงนี้

class BookingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('รายการจอง')),
        body: Center(child: Text('กรุณาเข้าสู่ระบบ')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('รายการจองของคุณ')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, bookingSnapshot) { 
          if (bookingSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (bookingSnapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          }

          final bookings = bookingSnapshot.data?.docs ?? [];

          if (bookings.isEmpty) {
            return Center(child: Text('คุณยังไม่มีการจองใด ๆ'));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final fieldId = booking['fieldId'];
              final date = booking['date'] ?? 'ไม่ระบุวันที่';
              final time = booking['time'] ?? 'ไม่ระบุเวลา';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('sports_fields')
                    .doc(fieldId)
                    .get(),
                builder: (context, fieldSnapshot) {
                  if (fieldSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('กำลังโหลดข้อมูลสนาม...'),
                      subtitle: Text('วันที่: $date เวลา: $time'),
                    );
                  }

                  if (!fieldSnapshot.hasData || !fieldSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('ไม่พบข้อมูลสนาม'),
                      subtitle: Text('วันที่: $date เวลา: $time'),
                    );
                  }

                  final fieldData = fieldSnapshot.data!.data() as Map<String, dynamic>;
                  final fieldName = fieldData['name'] ?? 'ไม่มีชื่อสนาม';

                  return ListTile(
                    title: Text('สนาม: $fieldName'),
                    subtitle: Text('วันที่: $date เวลา: $time'),
                    trailing: TextButton(
                      child: Text('ดูรายละเอียด'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VenueDetailReadonlyPage(fieldId: fieldId),
                          ),
                        );
                      },
                    ),
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
