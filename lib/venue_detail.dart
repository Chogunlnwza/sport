import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VenueDetailPage extends StatefulWidget {
  final String fieldId;

  VenueDetailPage({required this.fieldId});

  @override
  _VenueDetailPageState createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends State<VenueDetailPage> {
  DateTime? selectedDate;
  String? selectedTime;
  List<String> timeSlots = [
    '09:00-10:00',
    '10:00-11:00',
    '11:00-12:00',
    '12:00-13:00',
    '13:00-14:00',
    '14:00-15:00',
  ];

  Future<void> _pickDate() async {
    DateTime today = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(Duration(days: 14)),
      helpText: 'เลือกวันที่ต้องการจอง',
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldRef =
        FirebaseFirestore.instance.collection('sports_fields').doc(widget.fieldId);

    return Scaffold(
      appBar: AppBar(title: Text('รายละเอียดสนามกีฬา')),
      body: FutureBuilder<DocumentSnapshot>(
        future: fieldRef.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          var field = snapshot.data!;
          final imageUrl = field['image_url'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แสดงรูป
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 16),
                Text(field['name'] ?? '',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(field['location'] ?? '',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                SizedBox(height: 8),
                Text(field['description'] ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.black87)),
                Divider(height: 32),
                // วันที่
                Text("เลือกวันที่", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                          : 'แตะเพื่อเลือกวันที่',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // เวลา
                Text("เลือกเวลา", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: timeSlots.map((slot) {
                    final isSelected = selectedTime == slot;
                    return ChoiceChip(
                      label: Text(slot),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedTime = slot;
                        });
                      },
                      selectedColor: Colors.green.shade300,
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 32),

                // ปุ่มจอง
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.check_circle_outline),
                    label: Text('จองสนาม', style: TextStyle(fontSize: 18)),
                    onPressed: () async {
                      if (selectedDate == null || selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('กรุณาเลือกวันและเวลา')));
                        return;
                      }

                      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
                      final userId = FirebaseAuth.instance.currentUser?.uid;
                      final bookingRef = FirebaseFirestore.instance.collection('bookings');

                      final conflict = await bookingRef
                          .where('fieldId', isEqualTo: widget.fieldId)
                          .where('date', isEqualTo: formattedDate)
                          .where('time', isEqualTo: selectedTime)
                          .get();

                      final alreadyBooked = await bookingRef
                          .where('userId', isEqualTo: userId)
                          .where('date', isEqualTo: formattedDate)
                          .get();

                      if (conflict.docs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('ช่วงเวลานี้ถูกจองไปแล้ว')));
                      } else if (alreadyBooked.docs.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('คุณจองแล้วในวันเดียวกัน')));
                      } else {
                        await bookingRef.add({
                          'userId': userId,
                          'fieldId': widget.fieldId,
                          'date': formattedDate,
                          'time': selectedTime,
                          'createdAt': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('จองสำเร็จ')));
                      }
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
