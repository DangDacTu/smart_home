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
  final _confirmPassController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePass = true;

  String? _validatePassword(String password) {
    if (password.length < 8) return "Mật khẩu phải có ít nhất 8 ký tự.";
    if (RegExp(r'^(.)\1+$').hasMatch(password)) return "Mật khẩu quá đơn giản.";
    return null;
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();

    if (!_isLogin) {
      final error = _validatePassword(pass);
      if (error != null) { _showError(error); return; }
      if (pass != _confirmPassController.text.trim()) { _showError("Mật khẩu không khớp."); return; }
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      } else {
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
        await FirebaseDatabase.instance.ref("users/${cred.user!.uid}").set({
          "name": email.split('@')[0],
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.blue.shade600],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, size: 70, color: Colors.indigo.shade800),
                    const SizedBox(height: 10),
                    Text(_isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 25),
                    _buildField(_emailController, Icons.email, "Email", false),
                    const SizedBox(height: 15),
                    _buildField(_passController, Icons.lock, "Mật khẩu", true),
                    if (!_isLogin) ...[
                      const SizedBox(height: 15),
                      _buildField(_confirmPassController, Icons.lock_reset, "Xác nhận mật khẩu", true),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ"),
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
    );
  }

  Widget _buildField(TextEditingController controller, IconData icon, String label, bool isPass) {
    return TextField(
      controller: controller,
      obscureText: isPass ? _obscurePass : false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: isPass ? IconButton(icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePass = !_obscurePass)) : null,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}