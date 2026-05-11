import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class VenueDetailPage extends StatefulWidget {
  final String fieldId;

  const VenueDetailPage({super.key, required this.fieldId});

  @override
  State<VenueDetailPage> createState() => _VenueDetailPageState();
}

class _VenueDetailPageState extends State<VenueDetailPage> {
  DateTime? selectedDate;
  String? selectedTime;
  bool _isBooking = false;

  List<String> timeSlots = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
    '19:00 - 20:00',
  ];

  Future<void> _pickDate() async {
    DateTime today = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 14)),
      helpText: 'Select a Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black87, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _handleBooking() async {
    if (selectedDate == null || selectedTime == null) {
      Get.snackbar(
        "Missing Info", "Please select both date and time.",
        backgroundColor: Colors.orange.withOpacity(0.9), colorText: Colors.white,
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
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
        Get.snackbar(
          "Slot Unavailable", "This time slot is already booked.",
          backgroundColor: Colors.redAccent.withOpacity(0.9), colorText: Colors.white,
        );
      } else if (alreadyBooked.docs.isNotEmpty) {
        Get.snackbar(
          "Limit Reached", "You already have a booking on this date.",
          backgroundColor: Colors.redAccent.withOpacity(0.9), colorText: Colors.white,
        );
      } else {
        await bookingRef.add({
          'userId': userId,
          'fieldId': widget.fieldId,
          'date': formattedDate,
          'time': selectedTime,
          'createdAt': DateFormat('yyyyMMddHHmmss').format(DateTime.now()),
        });
        Get.snackbar(
          "Success!", "Your booking has been confirmed.",
          backgroundColor: Colors.green.withOpacity(0.9), colorText: Colors.white,
        );
        Navigator.pop(context); // Go back after success
      }
    } catch (e) {
      Get.snackbar(
        "Error", "Something went wrong: $e",
        backgroundColor: Colors.redAccent.withOpacity(0.9), colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldRef = FirebaseFirestore.instance.collection('sports_fields').doc(widget.fieldId);

    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: fieldRef.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var field = snapshot.data!;
          final imageUrl = field['image_url'];
          final name = field['name'] ?? 'Unknown Venue';
          final location = field['location'] ?? 'Unknown Location';
          final desc = field['description'] ?? 'No description available.';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                    ),
                  ),
                  background: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 50)),
                        )
                      : Container(color: Colors.teal, child: const Icon(Icons.sports, size: 80, color: Colors.white54)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venue Info Header
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text("About", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        desc,
                        style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Date Picker
                      const Text("1. Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))
                            ]
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                selectedDate != null ? DateFormat('EEEE, dd MMM yyyy').format(selectedDate!) : 'Tap to select a date',
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: selectedDate != null ? Colors.black87 : Colors.grey[500],
                                  fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.normal
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Time Picker
                      const Text("2. Select Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
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
                            selectedColor: Theme.of(context).colorScheme.primary,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 100), // Extra space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isBooking ? null : _handleBooking,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isBooking 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}
