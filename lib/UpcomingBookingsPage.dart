/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpcomingBookingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid; // ใช้ userId จาก Firebase Auth

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('การจองที่กำลังจะมา'),
        ),
        body: Center(child: Text('กรุณาเข้าสู่ระบบ')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('การจองที่กำลังจะมา'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId) // ใช้ userId ที่ได้จาก FirebaseAuth
            .where('bookingDate', isGreaterThan: DateTime.now()) // การกรองจองที่ยังไม่เกิดขึ้น
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('ไม่มีการจองที่กำลังจะมา'));
          }

          var bookings = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index];
              var field = booking['fieldName'] ?? 'ไม่พบข้อมูลสนาม';
              var bookingDate = (booking['bookingDate'] as Timestamp).toDate(); // แปลง Timestamp เป็น DateTime
              var bookingTime = booking['bookingTime'] ?? 'ไม่ระบุเวลา';

              return ListTile(
                title: Text(field),
                subtitle: Text('วันที่: ${bookingDate.toLocal().toString().split(' ')[0]} เวลา: $bookingTime'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // แสดงรายละเอียดการจอง
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingDetailPage(bookingId: booking.id)),
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

class BookingDetailPage extends StatelessWidget {
  final String bookingId;
  BookingDetailPage({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดการจอง'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').doc(bookingId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('ไม่พบข้อมูลการจอง'));
          }

          var booking = snapshot.data!;
          var field = booking['fieldName'] ?? 'ไม่พบชื่อสนาม';
          var bookingDate = (booking['bookingDate'] as Timestamp).toDate(); // แปลง Timestamp เป็น DateTime
          var bookingTime = booking['bookingTime'] ?? 'ไม่ระบุเวลา';
          var status = booking['status'] ?? 'ไม่ระบุสถานะ';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('สนามกีฬา: $field', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('วันที่: ${bookingDate.toLocal().toString().split(' ')[0]}', style: TextStyle(fontSize: 16)),
                Text('เวลา: $bookingTime', style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('สถานะการจอง: $status', style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // ยกเลิกการจอง
                    FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
                      'status': 'ยกเลิกแล้ว',
                    });
                    Navigator.pop(context);
                  },
                  child: Text('ยกเลิกการจอง'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}*/
