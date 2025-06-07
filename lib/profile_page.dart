import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nickname = "";
  String? profileImage;
  bool isLoading = true;
  TextEditingController nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        nickname = doc.data()?['nickname'] ?? "";
        profileImage = doc.data()?['profileImage'];
        nicknameController.text = nickname; // Set the controller text to the current nickname
        isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final imageBytes = await File(picked.path).readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImage': base64Image,
      });
      setState(() {
        profileImage = base64Image;
      });
    }
  }

  Future<void> _updateNickname() async {
    final newNickname = nicknameController.text.trim();
    if (newNickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณากรอกชื่อเล่น")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'nickname': newNickname,
        });
        setState(() {
          nickname = newNickname;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ชื่อเล่นอัปเดตสำเร็จ!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
        );
      }
    }
  }

  Future<void> _showConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ยืนยันการอัปเดตชื่อเล่น"),
        content: Text("คุณต้องการอัปเดตชื่อเล่นเป็น '${nicknameController.text}' ใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              _updateNickname();
              Navigator.of(context).pop();
            },
            child: Text("ยืนยัน"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("โปรไฟล์", style: GoogleFonts.poppins()),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            profileImage != null
                ? CircleAvatar(
                    radius: 60,
                    backgroundImage: MemoryImage(base64Decode(profileImage!)),
                  )
                : profileImage == null && isLoading
                    ? CircularProgressIndicator()
                    : CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pickAndUploadImage,
              icon: Icon(Icons.camera_alt),
              label: Text("แก้ไขรูปโปรไฟล์"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                labelText: "ชื่อเล่น",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showConfirmationDialog,  // Show confirmation dialog before updating nickname
              child: Text("อัปเดตชื่อเล่น"),
            ),
            const SizedBox(height: 20),
            Text("ชื่อเล่น: $nickname", style: GoogleFonts.poppins(fontSize: 18)),
            const SizedBox(height: 20),
            Text(
              "Email: ${FirebaseAuth.instance.currentUser?.email ?? '-'}",
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
