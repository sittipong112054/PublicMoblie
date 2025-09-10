// To parse this JSON data, do
//
//     final costumerRegisterPostRequestDart = costumerRegisterPostRequestDartFromJson(jsonString);

import 'dart:convert';

CostumerRegisterPostRequestDart costumerRegisterPostRequestDartFromJson(String str) => CostumerRegisterPostRequestDart.fromJson(json.decode(str));

String costumerRegisterPostRequestDartToJson(CostumerRegisterPostRequestDart data) => json.encode(data.toJson());

class CostumerRegisterPostRequestDart {
    String fullname;
    String phone;
    String email;
    String image;
    String password;

    CostumerRegisterPostRequestDart({
        required this.fullname,
        required this.phone,
        required this.email,
        required this.image,
        required this.password,
    });

    factory CostumerRegisterPostRequestDart.fromJson(Map<String, dynamic> json) => CostumerRegisterPostRequestDart(
        fullname: json["fullname"],
        phone: json["phone"],
        email: json["email"],
        image: json["image"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "fullname": fullname,
        "phone": phone,
        "email": email,
        "image": image,
        "password": password,
    };
}
