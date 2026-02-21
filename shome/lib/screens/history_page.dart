import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _db = FirebaseDatabase.instance.ref().child('logs');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Đồng bộ màu nền
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "NHẬT KÝ RA VÀO",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryHeader(),
          Expanded(
            child: FirebaseAnimatedList(
              query: _db.limitToLast(50),
              sort: (a, b) => b.key!.compareTo(a.key!),
              padding: const EdgeInsets.only(bottom: 20),
              itemBuilder: (context, snapshot, animation, index) {
                Map log = snapshot.value as Map;
                return _buildTimelineItem(log, animation);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.indigo.shade700, Colors.blue.shade500]),
        borderRadius: BorderRadius.circular(25), // Đồng bộ bo góc
        boxShadow: [
          BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn("Tổng lượt", "128", Icons.history),
          _buildStatColumn("An toàn", "100%", Icons.security),
          _buildStatColumn("Cảnh báo", "02", Icons.warning_amber_rounded),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildTimelineItem(Map log, Animation<double> animation) {
    String action = log['action'].toString();
    bool isDenied = action.contains("Từ chối") || action.contains("Sai") || action.contains("KHÓA");
    Color mainColor = isDenied ? Colors.redAccent : Colors.blue.shade600;

    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: CircleAvatar(
            backgroundColor: mainColor.withOpacity(0.1),
            child: Icon(isDenied ? Icons.gpp_bad : Icons.gpp_good, color: mainColor),
          ),
          title: Text(
            log['user'] ?? "Ẩn danh",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text("$action qua ${log['method']}"),
          ),
          trailing: Text(
            log['time'] ?? "--:--",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
      ),
    );
  }
}