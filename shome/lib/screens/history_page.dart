import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _db = FirebaseDatabase.instance.ref().child('logs');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "NHẬT KÝ RA VÀO",
          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryHeader(),
          Expanded(
            child: FirebaseAnimatedList(
              query: _db.limitToLast(50),
              sort: (a, b) => b.key!.compareTo(a.key!),
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
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.indigo.shade700,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
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
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildTimelineItem(Map log, Animation<double> animation) {
    // LOGIC KIỂM TRA: Nếu hành động chứa từ "Từ chối", "Sai", hoặc "KHOA"
    String action = log['action'].toString();
    bool isDenied = action.contains("Từ chối") || 
                    action.contains("Sai") || 
                    action.contains("KHÓA") || 
                    action.contains("Denied");

    Color mainColor = isDenied ? Colors.redAccent : Colors.green.shade600;
    IconData statusIcon = isDenied ? Icons.cancel : Icons.check_circle; // Dấu X hoặc Dấu Tích

    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: mainColor, shape: BoxShape.circle),
                  ),
                  Container(width: 2, height: 60, color: Colors.grey.shade300),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: isDenied ? Border.all(color: Colors.red.shade100, width: 1) : null,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            log['user'] ?? "Ẩn danh",
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 15,
                              color: isDenied ? Colors.red.shade900 : Colors.black87
                            ),
                          ),
                          Text(
                            log['time'] ?? "--:--",
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(statusIcon, color: mainColor, size: 18), // HIỂN THỊ DẤU X ĐỎ Ở ĐÂY
                          const SizedBox(width: 8),
                          Text(
                            "$action qua ${log['method']}",
                            style: TextStyle(
                              color: isDenied ? Colors.redAccent : Colors.black87, 
                              fontSize: 13,
                              fontWeight: isDenied ? FontWeight.w500 : FontWeight.normal
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
