import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VenueDetailReadonlyPage extends StatelessWidget {
  final String fieldId;

  const VenueDetailReadonlyPage({required this.fieldId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('รายละเอียดสนามกีฬา')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('sports_fields')
            .doc(fieldId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('ไม่พบข้อมูลสนาม'));
          }

          final field = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ชื่อสนาม: ${field['name']}',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('ที่ตั้ง: ${field['location']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('รายละเอียด: ${field['description'] ?? 'ไม่มีรายละเอียด'}',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
