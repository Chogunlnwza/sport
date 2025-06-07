import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('การตั้งค่า'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('เปลี่ยนรหัสผ่าน'),
            onTap: () {
              // ไปที่หน้าจอเปลี่ยนรหัสผ่าน
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('เปลี่ยนรหัสผ่าน'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: InputDecoration(labelText: 'รหัสผ่านใหม่'),
                          obscureText: true,
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'ยืนยันรหัสผ่าน'),
                          obscureText: true,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          // รหัสผ่านถูกเปลี่ยน
                          Navigator.pop(context);
                        },
                        child: Text('บันทึก'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            title: Text('การแจ้งเตือน'),
            subtitle: Text('เปิด/ปิด การแจ้งเตือน'),
            onTap: () {
              // แสดงการตั้งค่าการแจ้งเตือน
            },
          ),
          ListTile(
            title: Text('ภาษา'),
            subtitle: Text('เปลี่ยนภาษาแอป'),
            onTap: () {
              // ไปที่หน้าจอเลือกภาษา
            },
          ),
        ],
      ),
    );
  }
}
