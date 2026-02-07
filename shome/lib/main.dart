import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MaterialApp(home: AuthWrapper(), debugShowCheckedModeBanner: false));
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) return const DashboardScreen();
        return const LoginScreen();
      },
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = FirebaseDatabase.instance.ref();
  String role = "member";
  bool canUnlock = false;

  @override
  void initState() {
    super.initState();
    _loadUserPermissions();
  }

  void _loadUserPermissions() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    _db.child("users/$uid").onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          role = data['role'] ?? "member";
          canUnlock = data['can_unlock'] ?? false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Home - Quyền: ${role.toUpperCase()}"),
        actions: [IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Giao diện Admin: Tạo mã mời
            if (role == "admin") 
              _buildAdminTools(),
            
            // Giao diện Member chưa có quyền: Nhập mã mời
            if (role != "admin" && !canUnlock)
              _buildInviteInput(),

            // Bảng điều khiển (Chỉ hiện khi là Admin hoặc Member đã được cấp quyền)
            if (canUnlock || role == "admin")
              _buildDeviceGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTools() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.blue.shade50,
      child: Column(
        children: [
          const Text("QUẢN TRỊ VIÊN", style: TextStyle(fontWeight: FontWeight.bold)),
          ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text("Tạo mã mời: HOME2026"),
            onPressed: () {
              _db.child("invite_codes/HOME2026").set(FirebaseAuth.instance.currentUser!.uid);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã kích hoạt mã: HOME2026")));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInviteInput() {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const Icon(Icons.lock_person, size: 80, color: Colors.grey),
          const SizedBox(height: 10),
          const Text("Nhập mã từ Admin để nhận quyền điều khiển"),
          TextField(controller: controller, decoration: const InputDecoration(hintText: "Mã mời (VD: HOME2026)")),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () async {
              final snap = await _db.child("invite_codes/${controller.text}").get();
              if (snap.exists) {
                await _db.child("users/${FirebaseAuth.instance.currentUser!.uid}").update({
                  "can_unlock": true,
                  "home_id": snap.value
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mã không hợp lệ!")));
              }
            },
            child: const Text("Kết nối nhà"),
          )
        ],
      ),
    );
  }

  Widget _buildDeviceGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.all(15),
      children: [
        _buildControlCard("Cửa Chính", "door_status", Icons.door_front_door),
        _buildControlCard("Đèn", "light_status", Icons.lightbulb),
        _buildControlCard("Cửa Sổ", "window_status", Icons.window),
      ],
    );
  }

  Widget _buildControlCard(String title, String path, IconData icon) {
    return StreamBuilder(
      stream: _db.child("device_control/$path").onValue,
      builder: (context, snap) {
        int val = (snap.data?.snapshot.value as int?) ?? 0;
        return Card(
          color: val == 1 ? Colors.green.shade100 : Colors.red.shade100,
          child: InkWell(
            onTap: () => _db.child("device_control/$path").set(val == 1 ? 0 : 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: val == 1 ? Colors.green : Colors.red),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(val == 1 ? "Đang Mở/Bật" : "Đang Đóng/Tắt"),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final pass = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Home Universe")),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(children: [
          TextField(controller: email, decoration: const InputDecoration(labelText: "Email")),
          TextField(controller: pass, decoration: const InputDecoration(labelText: "Mật khẩu"), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text, password: pass.text),
            child: const Text("Đăng Nhập"),
          ),
          TextButton(
            onPressed: () async {
              UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text, password: pass.text);
              FirebaseDatabase.instance.ref("users/${cred.user!.uid}").set({
                "name": "Thành viên phụ", "role": "member", "can_unlock": false
              });
            },
            child: const Text("Đăng ký tài khoản phụ"),
          )
        ]),
      ),
    );
  }
}