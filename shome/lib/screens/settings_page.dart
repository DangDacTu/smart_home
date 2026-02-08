import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài Đặt Hệ Thống")),
      body: ListView(
        children: [
          // Mục dành cho Admin tạo mã mời
          ListTile(
            leading: const Icon(Icons.share_arrival_time),
            title: const Text("Chia sẻ mã mời"),
            subtitle: const Text("Bấm để tạo mã cho thành viên mới (HOME2026)"),
            onTap: () {
              // Lưu UID của Admin vào nhánh invite_codes để xác nhận khi member nhập mã
              FirebaseDatabase.instance
                  .ref("invite_codes/HOME2026")
                  .set(FirebaseAuth.instance.currentUser!.uid);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Đã kích hoạt mã: HOME2026")),
              );
            },
          ),
          const Divider(),
          // Mục đăng xuất
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}