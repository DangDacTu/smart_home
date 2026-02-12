import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController(); // Ô xác nhận mật khẩu
  bool _isLogin = true;
  bool _isLoading = false;

  // Hàm kiểm tra mật khẩu yếu
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return "Mật khẩu phải có ít nhất 8 ký tự.";
    }
    // Kiểm tra các dãy số liên tiếp hoặc lặp lại (giống logic trong code nhúng của bạn)
    bool isEasy = true;
    for (int i = 1; i < password.length; i++) {
      if (password[i] != password[0]) {
        isEasy = false;
        break;
      }
    }
    if (isEasy) return "Mật khẩu quá đơn giản (không được trùng lặp 1 ký tự).";
    
    // Kiểm tra dãy số liên tiếp (123456...)
    if (password == "123456" || password == "12345678" || password == "654321") {
      return "Mật khẩu này quá phổ biến và yếu.";
    }
    
    return null;
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();
    final confirmPass = _confirmPassController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showError("Vui lòng nhập đầy đủ thông tin.");
      return;
    }

    if (!_isLogin) {
      // 1. Kiểm tra mật khẩu yếu
      final error = _validatePassword(pass);
      if (error != null) {
        _showError(error);
        return;
      }

      // 2. Kiểm tra xác nhận mật khẩu
      if (pass != confirmPass) {
        _showError("Mật khẩu xác nhận không khớp.");
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      } else {
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
        await FirebaseDatabase.instance.ref("users/${cred.user!.uid}").set({
          "name": "Thành viên mới",
          "role": "member",
          "can_unlock": false,
        });
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Lỗi xác thực.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.blue.shade500],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Card(
                elevation: 15,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 70, color: Colors.blue.shade800),
                      const SizedBox(height: 10),
                      Text(
                        _isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ BẢO MẬT",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 25),
                      _buildTextField(_emailController, Icons.email, "Email", false),
                      const SizedBox(height: 15),
                      _buildTextField(_passController, Icons.lock, "Mật khẩu", true),
                      
                      // Chỉ hiện ô xác nhận khi ở chế độ Đăng ký
                      if (!_isLogin) ...[
                        const SizedBox(height: 15),
                        _buildTextField(_confirmPassController, Icons.lock_reset, "Xác nhận mật khẩu", true),
                      ],
                      
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade800,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ"),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(_isLogin ? "Tạo tài khoản mới" : "Đã có tài khoản? Đăng nhập"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String label, bool isPass) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
