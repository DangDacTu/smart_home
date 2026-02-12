import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _db = FirebaseDatabase.instance.ref();
  String userRole = "member";
  String userName = "Người dùng";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Tải thông tin người dùng hiện tại
  void _loadUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await _db.child("users/$uid").get();
    if (snapshot.exists) {
      Map data = snapshot.value as Map;
      setState(() {
        userRole = data['role'] ?? "member";
        userName = data['name'] ?? "Chưa đặt tên";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("CÀI ĐẶT", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildUserHeader(),
          const SizedBox(height: 30),
          
          _buildSectionTitle("Quản lý truy cập"),
          _buildSettingTile(
            icon: Icons.share_rounded,
            color: Colors.blue,
            title: "Tạo mã mời thành viên",
            subtitle: "Cấp quyền cho người thân (HOME2026)",
            onTap: userRole == "admin" ? _generateInviteCode : null,
            enabled: userRole == "admin",
          ),
          _buildSettingTile(
            icon: Icons.password_rounded,
            color: Colors.orange,
            title: "Đổi mật mã Master",
            subtitle: "Mật mã bàn phím vật lý trên ESP32",
            onTap: userRole == "admin" ? _showChangeMasterPassDialog : null,
            enabled: userRole == "admin",
          ),
          
          const SizedBox(height: 20),
          _buildSectionTitle("Hệ thống"),
          _buildSettingTile(
            icon: Icons.delete_sweep_rounded,
            color: Colors.redAccent,
            title: "Xóa nhật ký ra vào",
            subtitle: "Dọn dẹp database lịch sử",
            onTap: userRole == "admin" ? _clearLogs : null,
            enabled: userRole == "admin",
          ),
          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            color: Colors.grey,
            title: "Thông tin phiên bản",
            subtitle: "Smart Home Universe v2.0.26",
            onTap: () {},
          ),
          
          const SizedBox(height: 40),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  // --- WIDGETS CHI TIẾT ---

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.indigo.shade100,
            child: Icon(Icons.person, size: 40, color: Colors.indigo.shade700),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(userRole == "admin" ? "Chủ hộ (Admin)" : "Thành viên", 
                   style: TextStyle(color: Colors.indigo.shade400, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45)),
    );
  }

  Widget _buildSettingTile({required IconData icon, required Color color, required String title, required String subtitle, VoidCallback? onTap, bool enabled = true}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      color: enabled ? Colors.white : Colors.grey.shade100,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: enabled ? Colors.black87 : Colors.black26)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.black26),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: () => FirebaseAuth.instance.signOut(),
      icon: const Icon(Icons.logout_rounded),
      label: const Text("ĐĂNG XUẤT"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // --- LOGIC HÀM XỬ LÝ ---

  void _generateInviteCode() {
    _db.child("invite_codes/HOME2026").set(FirebaseAuth.instance.currentUser!.uid);
    _showMessage("Đã tạo mã mời: HOME2026", Colors.green);
  }

  void _clearLogs() {
    _db.child("logs").remove();
    _showMessage("Đã xóa sạch lịch sử!", Colors.orange);
  }

  void _showChangeMasterPassDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Đổi mật mã Master (6 số)"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(hintText: "Nhập 6 số mới"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.length == 6) {
                _db.child("device_control/master_password").set(controller.text);
                Navigator.pop(context);
                _showMessage("Đã cập nhật mật mã bàn phím!", Colors.green);
              }
            }, 
            child: const Text("Lưu")
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }
}