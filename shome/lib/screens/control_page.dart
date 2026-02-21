import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _db = FirebaseDatabase.instance.ref();

    return Scaffold(
      // Nền màu xám nhạt hiện đại
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "SMART UNIVERSE",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildWelcomeHeader(),
            const SizedBox(height: 30),
            const Text(
              "Thiết bị trong nhà",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            // Lưới các thiết bị
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
              children: [
                _buildModernCard(_db, "Cửa Chính", "door_status", Icons.sensor_door_outlined, Colors.blue),
                _buildModernCard(_db, "Đèn Phòng", "light_status", Icons.light_mode_outlined, Colors.amber),
                _buildModernCard(_db, "Cửa Sổ", "window_status", Icons.grid_view_rounded, Colors.teal),
                _buildModernCard(_db, "Điều Hòa", "ac_status", Icons.ac_unit, Colors.cyan),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget tiêu đề chào mừng
  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade400]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Chào buổi tối,", style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 5),
              Text("Chủ nhà", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 35),
          )
        ],
      ),
    );
  }

  // Widget Card điều khiển kiểu hiện đại
  Widget _buildModernCard(DatabaseReference db, String title, String path, IconData icon, Color color) {
    return StreamBuilder(
      stream: db.child("device_control/$path").onValue,
      builder: (context, snap) {
        bool isActive = (snap.data?.snapshot.value as int?) == 1;

        return GestureDetector(
          onTap: () => db.child("device_control/$path").set(isActive ? 0 : 1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isActive ? color : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: isActive ? color.withOpacity(0.4) : Colors.black12,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 45,
                  color: isActive ? Colors.white : color,
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isActive ? "ĐANG BẬT" : "ĐANG TẮT",
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.white70 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 10),
                // Nút gạt giả lập
                Container(
                  width: 35,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white54 : color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}