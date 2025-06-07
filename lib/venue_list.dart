import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'venue_detail.dart';
import 'booking_history_page.dart'; // ✅ import หน้า booking

class VenueListPage extends StatelessWidget {
  const VenueListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการสนามกีฬา'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: 'ประวัติการจอง',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookingHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('sports_fields').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          }

          final venues = snapshot.data!.docs;

          if (venues.isEmpty) {
            return const Center(child: Text('ไม่มีสนามกีฬาในระบบ'));
          }

          return ListView.builder(
            itemCount: venues.length,
            itemBuilder: (context, index) {
              final doc = venues[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(doc['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(doc['location']),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VenueDetailPage(fieldId: doc.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
