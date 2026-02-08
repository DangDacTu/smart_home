import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Truy cập vào nhánh logs để lấy lịch sử ra vào
    final _db = FirebaseDatabase.instance.ref().child('logs');

    return Scaffold(
      appBar: AppBar(title: const Text("Lịch Sử Ra Vào")),
      body: FirebaseAnimatedList(
        query: _db.limitToLast(50), // Hiển thị 50 bản ghi gần nhất
        itemBuilder: (context, snapshot, animation, index) {
          Map log = snapshot.value as Map;
          bool isOpening = log['action'].toString().contains("Mo");

          return SizeTransition(
            sizeFactor: animation,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isOpening ? Colors.green : Colors.red,
                  child: Icon(isOpening ? Icons.vpn_key : Icons.lock, color: Colors.white),
                ),
                title: Text("${log['user']} - ${log['method']}"), // Hiển thị người dùng và phương thức
                subtitle: Text("${log['action']} | ${log['time']}"), // Hiển thị hành động và thời gian
              ),
            ),
          );
        },
      ),
    );
  }
}