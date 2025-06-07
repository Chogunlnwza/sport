import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactUsPage extends StatelessWidget {
  TextEditingController nameController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  // ฟังก์ชันในการเปิดแอป Gmail
  void _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'Chogunzaza8@gmail.com', // ที่อยู่อีเมลที่คุณต้องการให้ผู้ใช้ส่งถึง
      query: Uri.encodeFull(
        'subject=คำถามจากผู้ใช้&body=ชื่อผู้ใช้: ${nameController.text}\n\nข้อความ: ${messageController.text}'
      ),
      // เพิ่ม subject และ body
    );

    // เปิดแอปอีเมล
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
      Get.snackbar(
        "ข้อความของคุณถูกส่งแล้ว ✅",
        "โปรดตรวจสอบอีเมลของคุณ",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        "Oops 😥",
        "ไม่สามารถเปิดแอปอีเมลได้",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ติดต่อเรา", style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ติดต่อเราผ่านอีเมล",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "กรุณากรอกชื่อและข้อความของคุณ แล้วเราจะตอบกลับโดยเร็วที่สุด",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "ชื่อของคุณ",
                prefixIcon: Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: "ข้อความของคุณ",
                prefixIcon: Icon(Icons.message_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendEmail,  // ส่งอีเมลเมื่อกดปุ่ม
                icon: Icon(Icons.send),
                label: Text(
                  "ส่งข้อความ",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
