import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plume/booking_history_page.dart';
import 'package:plume/login.dart';
import 'package:plume/venue_detail.dart';
import 'package:plume/booking_page.dart';
import 'news_page.dart';
import 'profile_page.dart';
import 'UpcomingBookingsPage.dart';
import 'SettingsPage.dart';
import 'ContactUsPage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('หน้าแรก'),
        actions: [
          IconButton(
            icon: Icon(Icons.person), // เปลี่ยนเป็นไอคอนโปรไฟล์
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('เมนู')),
            ListTile(
              title: Text('ข่าวสาร'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => NewsPage()));
              },
            ),
            ListTile(
              title: Text('โปรไฟล์ผู้ใช้'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              },
            ),
            ListTile(
              title: Text('ประวัติการจอง'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => BookingHistoryPage()));
              },
            ),
            ListTile(
              title: Text('การตั้งค่า'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
              },
            ),
            ListTile(
              title: Text('ติดต่อเรา'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ContactUsPage()));
              },
            ),
            ListTile(
              title: Text('ออกจากระบบ'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'ค้นหาสนามกีฬา',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sports_fields').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('เกิดข้อผิดพลาด'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('ไม่มีข้อมูลสนามกีฬา'));
                }

                var fields = snapshot.data!.docs.where((doc) {
                  String name = (doc['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                if (fields.isEmpty) {
                  return Center(child: Text('ไม่พบสนามที่ค้นหา'));
                }

                return ListView.builder(
                  itemCount: fields.length,
                  itemBuilder: (context, index) {
                    var field = fields[index];
                    final imageUrl = field['image_url'];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VenueDetailPage(fieldId: field.id),
                            ),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12)),
                              child: imageUrl != null
                                  ? Image.network(
                                      imageUrl,
                                      width: 120,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.broken_image, size: 60),
                                    )
                                  : Container(
                                      width: 120,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image, size: 60),
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(field['name'] ?? '',
                                        style: TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 5),
                                    Text(field['location'] ?? '',
                                        style: TextStyle(color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
