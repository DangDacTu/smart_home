import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _db = FirebaseDatabase.instance.ref();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("SMART UNIVERSE", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildBanner(),
            const SizedBox(height: 30),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
              children: [
                _buildCard(_db, "Cửa Chính", "door_status", Icons.sensor_door_outlined, Colors.indigo),
                _buildCard(_db, "Đèn Phòng", "light_status", Icons.light_mode_outlined, Colors.amber),
                _buildCard(_db, "Cửa Sổ", "window_status", Icons.grid_view_rounded, Colors.teal),
                _buildCard(_db, "Điều Hòa", "ac_status", Icons.ac_unit, Colors.cyan),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade800, Colors.blue.shade500]),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Chào buổi tối,", style: TextStyle(color: Colors.white70, fontSize: 16)),
              Text("Chủ nhà Universe", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.wb_cloudy_outlined, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildCard(DatabaseReference db, String title, String path, IconData icon, Color color) {
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
              boxShadow: [BoxShadow(color: isActive ? color.withOpacity(0.4) : Colors.black12, blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 45, color: isActive ? Colors.white : color),
                const SizedBox(height: 10),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.black87)),
                Text(isActive ? "BẬT" : "TẮT", style: TextStyle(fontSize: 12, color: isActive ? Colors.white70 : Colors.black45)),
              ],
            ),
          ),
        );
      },
    );
  }
}