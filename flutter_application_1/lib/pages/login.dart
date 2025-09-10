import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/config/internal_config.dart';
import 'package:flutter_application_1/pages/register.dart';
import 'package:flutter_application_1/pages/showtrip.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/model/request/CustomerLoginPostRequest.dart';
import 'package:flutter_application_1/model/response/CostumerLoginPostResponse.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String text = '';
  int number = 0;
  String phoneNo = '';
  String password = '';
  TextEditingController phoneNoCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  bool obscurePassword = true;

  String url = '';

  @override
  void initState() {
    super.initState();
    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/images/image.webp'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('หมายเลขโทรศัพท์', style: TextStyle(fontSize: 15)),
                  SizedBox(height: 8),
                  TextField(
                    controller: phoneNoCtl,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      phoneNo = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('รหัสผ่าน', style: TextStyle(fontSize: 15)),
                  TextField(
                    obscureText: obscurePassword,
                    controller: passwordCtl,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: register,
                        child: const Text(
                          'ลงทะเบียนใหม่',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      FilledButton(
                        onPressed: () {
                          login();
                          // log(phoneNoCtl.text);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => ShowtripPagState()),
                          // );
                        },
                        child: const Text(
                          'เข้าสู่ระบบ',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(text, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  void register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  void login() {
    if (phoneNoCtl.text.trim().isEmpty || passwordCtl.text.trim().isEmpty) {
      setState(() {
        text = "กรุณากรอกข้อมูลให้ครบถ้วน";
      });
      return;
    }

    CustomerLoginPostRequest customerLoginPostRequest =
        CustomerLoginPostRequest(
          phone: phoneNoCtl.text.trim(),
          password: passwordCtl.text.trim(),
        );

    http
        .post(
          Uri.parse("$url/customers/login"),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: customerLoginPostRequestToJson(customerLoginPostRequest),
        )
        .then((response) {
          log(response.body);
          if (response.statusCode == 200) {
            CostumerLoginPostResponse customerLoginPostResponse =
                costumerLoginPostResponseFromJson(response.body);

            log(customerLoginPostResponse.customer.fullname);
            log(customerLoginPostResponse.customer.email);

Navigator.push(
	context,
	MaterialPageRoute(
	  builder: (context) => ShowtripPagState(cid: customerLoginPostResponse.customer.idx,),
	));
          } else {
            setState(() {
              text = "เบอร์โทรศัพท์หรือรหัสผ่านไม่ถูกต้อง";
            });
          }
        })
        .catchError((error) {
          log('Error $error');
          setState(() {
            text = "เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์";
          });
        });
  }
}
