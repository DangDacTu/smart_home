import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ControlPage extends StatelessWidget {
  const ControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _db = FirebaseDatabase.instance.ref();
    
    return Scaffold(
      appBar: AppBar(title: const Text("Điều Khiển")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(15),
        children: [
          // Các nút điều khiển trạng thái thiết bị
          _buildControlCard(_db, "Cửa Chính", "door_status", Icons.door_front_door),
          _buildControlCard(_db, "Đèn", "light_status", Icons.lightbulb),
          _buildControlCard(_db, "Cửa Sổ", "window_status", Icons.window),
        ],
      ),
    );
  }

  Widget _buildControlCard(DatabaseReference db, String title, String path, IconData icon) {
    return StreamBuilder(
      stream: db.child("device_control/$path").onValue,
      builder: (context, snap) {
        int val = (snap.data?.snapshot.value as int?) ?? 0;
        return Card(
          color: val == 1 ? Colors.green.shade100 : Colors.red.shade100,
          child: InkWell(
            onTap: () => db.child("device_control/$path").set(val == 1 ? 0 : 1), // Gửi lệnh lên Firebase
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: val == 1 ? Colors.green : Colors.red),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }
}