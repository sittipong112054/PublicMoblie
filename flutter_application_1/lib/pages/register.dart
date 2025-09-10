import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/model/request/CostumerRegisterPostRequest.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullnameCtl = TextEditingController();
  final phoneCtl = TextEditingController();
  final emailCtl = TextEditingController();
  final imageCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  final confirmPasswordCtl = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<bool> isPhoneExist(String phone) async {
    try {
      final res = await http.get(
        Uri.parse("http://10.0.2.2:3000/customers/check-phone?phone=$phone"),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["exists"] == true;
      }
    } catch (e) {}
    return false;
  }

  Future<void> registerUser() async {
    FocusScope.of(context).unfocus();
    if (fullnameCtl.text.isEmpty ||
        phoneCtl.text.isEmpty ||
        emailCtl.text.isEmpty ||
        imageCtl.text.isEmpty ||
        passwordCtl.text.isEmpty ||
        confirmPasswordCtl.text.isEmpty) {
      showMessage("กรุณากรอกข้อมูลให้ครบทุกช่อง");
      return;
    }

    if (passwordCtl.text != confirmPasswordCtl.text) {
      showMessage("รหัสผ่านไม่ตรงกัน");
      return;
    }

    if (await isPhoneExist(phoneCtl.text.trim())) {
      showMessage("เบอร์โทรศัพท์นี้ถูกใช้แล้ว กรุณาใช้เบอร์อื่น");
      return;
    }
    try {
      final request = CostumerRegisterPostRequestDart(
        fullname: fullnameCtl.text.trim(),
        phone: phoneCtl.text.trim(),
        email: emailCtl.text.trim(),
        image: imageCtl.text.trim(),
        password: passwordCtl.text.trim(),
      );

      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/customers"),
        headers: {"Content-Type": "application/json"},
        body: costumerRegisterPostRequestDartToJson(request),
      );

      if (response.statusCode == 200) {
        showMessage("สมัครสมาชิกสำเร็จ", success: true);
        // await Future.delayed(Duration(milliseconds: 3000));
      } else {
        final json = jsonDecode(response.body);
        showMessage("เกิดข้อผิดพลาด: ${json["message"] ?? "ไม่ทราบสาเหตุ"}");
      }
    } catch (e) {
      showMessage("เกิดข้อผิดพลาด: $e");
    }
  }

  void showMessage(String msg, {bool success = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(success ? "สำเร็จ" : "ข้อผิดพลาด"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (success) Navigator.pop(context);
            },
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ลงทะเบียนเป็นสมาชิก')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField("ชื่อ-สกุล", fullnameCtl),
            buildTextField(
              "หมายเลขโทรศัพท์",
              phoneCtl,
              keyboard: TextInputType.phone,
            ),
            buildTextField(
              "อีเมลล์",
              emailCtl,
              keyboard: TextInputType.emailAddress,
            ),
            buildTextField("ลิงก์รูปภาพ", imageCtl),
            buildPasswordField("รหัสผ่าน", passwordCtl, true),
            buildPasswordField("ยืนยันรหัสผ่าน", confirmPasswordCtl, false),
            const SizedBox(height: 20),
            Center(
              child: FilledButton(
                onPressed: registerUser,
                child: const Text(
                  'สมัครสมาชิก',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('มีบัญชีแล้ว?'),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('เข้าสู่ระบบ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController ctl, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          TextField(
            controller: ctl,
            keyboardType: keyboard,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget buildPasswordField(
    String label,
    TextEditingController ctl,
    bool isPassword,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          TextField(
            controller: ctl,
            obscureText: isPassword ? obscurePassword : obscureConfirmPassword,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  (isPassword ? obscurePassword : obscureConfirmPassword)
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    if (isPassword) {
                      obscurePassword = !obscurePassword;
                    } else {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    }
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}