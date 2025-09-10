import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/model/response/customer_idx_get_res.dart';

import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  int idx = 0;
  ProfilePage({super.key, required this.idx});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<void> loadData;
  late CustomerIdxGetResponse customerIdxGetResponse;
  TextEditingController nameCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController imageCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData = loadDataAsync();
  }

  @override
  Widget build(BuildContext context) {
    log('Customer id: ${widget.idx}');

    final labelStyle = const TextStyle(fontSize: 13, color: Colors.black54);
    InputDecoration deco(String hint) => InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFF6F7FB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE6E8EF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5B3DF0)),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อมูลส่วนตัว'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              log(value);
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'ยืนยันการยกเลิกสมาชิก?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('ปิด'),
                          ),
                          FilledButton(
                            onPressed: delete,
                            child: const Text('ยืนยัน'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('ยกเลิกสมาชิก'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // รูปโปรไฟล์แบบโค้งและเงาอ่อน
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12),
                      child: PhysicalModel(
                        color: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.black12,
                        borderRadius: BorderRadius.circular(80),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          customerIdxGetResponse.image,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 150,
                            height: 150,
                            alignment: Alignment.center,
                            color: const Color(0xFFF0F1F5),
                            child: const Icon(
                              Icons.person,
                              size: 56,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ฟิลด์ตัวอย่าง (ชื่อ) + แต่งสไตล์
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('ชื่อ-นามสกุล', style: labelStyle),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtl,
                      decoration: deco('กรอกชื่อ-นามสกุล'),
                    ),
                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('หมายเลขโทรศัพท์', style: labelStyle),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneCtl,
                      keyboardType: TextInputType.phone,
                      decoration: deco('กรอกเบอร์โทรศัพท์'),
                    ),
                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('อีเมล', style: labelStyle),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: emailCtl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: deco('กรอกอีเมล'),
                    ),
                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('รูปภาพ (URL)', style: labelStyle),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: imageCtl,
                      keyboardType: TextInputType.url,
                      decoration: deco('เช่น https://...'),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: FilledButton(
                        onPressed: update,
                        child: const Text('บันทึกข้อมูล'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void delete() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];

    var res = await http.delete(Uri.parse('$url/customers/${widget.idx}'));
    log(res.statusCode.toString());
    if (res.statusCode == 200) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('สำเร็จ'),
          content: Text('ลบข้อมูลสำเร็จ'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('ปิด'),
            ),
          ],
        ),
      ).then((s) {
        Navigator.popUntil(context, (route) => route.isFirst);
      });
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ผิดพลาด'),
          content: Text('ลบข้อมูลไม่สำเร็จ'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    }
  }

  void update() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];

    var json = {
      "fullname": nameCtl.text,
      "phone": phoneCtl.text,
      "email": emailCtl.text,
      "image": imageCtl.text,
    };
    // Not using the model, use jsonEncode() and jsonDecode()
    try {
      var res = await http.put(
        Uri.parse('$url/customers/${widget.idx}'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(json),
      );
      log(res.body);
      var result = jsonDecode(res.body);
      // Need to know json's property by reading from API Tester
      log(result['message']);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('สำเร็จ'),
          content: const Text('บันทึกข้อมูลเรียบร้อย'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    } catch (err) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('ผิดพลาด'),
          content: Text('บันทึกข้อมูลไม่สำเร็จ ' + err.toString()),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ปิด'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    var res = await http.get(Uri.parse('$url/customers/${widget.idx}'));
    log(res.body);
    customerIdxGetResponse = customerIdxGetResponseFromJson(res.body);
    log(jsonEncode(customerIdxGetResponse));
    nameCtl.text = customerIdxGetResponse.fullname;
    phoneCtl.text = customerIdxGetResponse.phone;
    emailCtl.text = customerIdxGetResponse.email;
    imageCtl.text = customerIdxGetResponse.image;
  }
}
