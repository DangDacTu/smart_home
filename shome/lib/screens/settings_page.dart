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

  void _loadUserData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    final snapshot = await _db.child("users/$uid").get();
    if (snapshot.exists) {
      Map data = snapshot.value as Map;
      setState(() {
        userRole = data['role'] ?? "member";
        userName = data['name'] ?? "Chủ nhà Universe";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Đồng bộ màu nền xám cực nhẹ
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "CÀI ĐẶT HỆ THỐNG",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          _buildUserHeaderGradient(), // Header phong cách Gradient mới
          const SizedBox(height: 30),
          
          _buildSectionTitle("QUẢN LÝ TRUY CẬP"),
          _buildModernSettingTile(
            icon: Icons.share_location_rounded,
            color: Colors.blue,
            title: "Mã mời thành viên",
            subtitle: "Cấp quyền: HOME2026",
            onTap: userRole == "admin" ? _generateInviteCode : null,
            enabled: userRole == "admin",
          ),
          _buildModernSettingTile(
            icon: Icons.vpn_key_rounded,
            color: Colors.orange,
            title: "Mật mã Master ESP32",
            subtitle: "Thay đổi mã số bàn phím",
            onTap: userRole == "admin" ? _showChangeMasterPassDialog : null,
            enabled: userRole == "admin",
          ),
          
          const SizedBox(height: 20),
          _buildSectionTitle("HỆ THỐNG"),
          _buildModernSettingTile(
            icon: Icons.auto_delete_rounded,
            color: Colors.redAccent,
            title: "Dọn dẹp nhật ký",
            subtitle: "Xóa sạch lịch sử ra vào",
            onTap: userRole == "admin" ? _clearLogs : null,
            enabled: userRole == "admin",
          ),
          _buildModernSettingTile(
            icon: Icons.info_outline_rounded,
            color: Colors.blueGrey,
            title: "Phiên bản ứng dụng",
            subtitle: "Smart Universe v2.0.26",
            onTap: () {},
          ),
          
          const SizedBox(height: 40),
          _buildLogoutButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Header đồng bộ với trang ControlPage
  Widget _buildUserHeaderGradient() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.indigo),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    userRole == "admin" ? "QUẢN TRỊ VIÊN" : "THÀNH VIÊN",
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.1),
      ),
    );
  }

  // Tile cài đặt theo phong cách Card trắng, bo góc lớn
  Widget _buildModernSettingTile({
    required IconData icon, 
    required Color color, 
    required String title, 
    required String subtitle, 
    VoidCallback? onTap, 
    bool enabled = true
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        onTap: enabled ? onTap : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: enabled ? color.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: enabled ? color : Colors.grey),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: enabled ? Colors.black87 : Colors.grey,
            fontSize: 15
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black45)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black26),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => FirebaseAuth.instance.signOut(),
        icon: const Icon(Icons.power_settings_new_rounded),
        label: const Text("ĐĂNG XUẤT HỆ THỐNG", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.redAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.red.shade50, width: 2),
          ),
        ),
      ),
    );
  }

  // --- LOGIC HÀM XỬ LÝ (GIỮ NGUYÊN) ---

  void _generateInviteCode() {
    _db.child("invite_codes/HOME2026").set(FirebaseAuth.instance.currentUser!.uid);
    _showMessage("Đã kích hoạt mã mời: HOME2026", Colors.green);
  }

  void _clearLogs() {
    _db.child("logs").remove();
    _showMessage("Nhật ký đã được làm trống!", Colors.blueGrey);
  }

  void _showChangeMasterPassDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const Text("Mật mã Master mới", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Mật mã gồm 6 chữ số dùng cho bàn phím cơ tại cửa.", style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                hintText: "000000",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("HỦY", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              if (controller.text.length == 6) {
                _db.child("device_control/master_password").set(controller.text);
                Navigator.pop(context);
                _showMessage("Cập nhật mật mã thành công!", Colors.green);
              }
            }, 
            child: const Text("XÁC NHẬN", style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(20),
      )
    );
  }
}