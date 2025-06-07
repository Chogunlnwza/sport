import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingDetailPage extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;
  final Map<String, dynamic> fieldData;

  BookingDetailPage({
    required this.bookingId,
    required this.bookingData,
    required this.fieldData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายละเอียดการจอง')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fieldData['image_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fieldData['image_url'],
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Text('ชื่อสนาม: ${fieldData['name'] ?? "-"}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('สถานที่: ${fieldData['location'] ?? "-"}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 12),
            Divider(),
            Text('วันที่: ${bookingData['date']}',
                style: TextStyle(fontSize: 16)),
            Text('เวลา: ${bookingData['time']}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 24),

            // QR CODE
            Center(
              child: QrImageView(
                data: bookingId,
                version: QrVersions.auto,
                size: 160.0,
              ),
            ),
            SizedBox(height: 16),
            Center(child: Text('QR Code สำหรับการจอง', style: TextStyle(fontSize: 14))),

            Spacer(),

            // ปุ่มยกเลิก
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.cancel),
                label: Text('ยกเลิกการจอง'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                onPressed: () async {
                  bool? confirm = await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('ยืนยันการยกเลิก'),
                      content: Text('คุณแน่ใจหรือไม่ว่าต้องการยกเลิกการจองนี้?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('ไม่'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('ใช่'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await FirebaseFirestore.instance
                        .collection('bookings')
                        .doc(bookingId)
                        .delete();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ยกเลิกการจองเรียบร้อยแล้ว')),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
