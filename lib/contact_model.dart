// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';
import 'package:hive/hive.dart';

part 'contact_model.g.dart';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  Welcome({
    required this.contact,
  });

  List<Contact> contact;

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
    contact: List<Contact>.from(json["contact"].map((x) => Contact.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "contact": List<dynamic>.from(contact.map((x) => x.toJson())),
  };
}


@HiveType(typeId: 1)
class Contact {
  @HiveField(0)
  String? user;
  @HiveField(1)
  String? phone;
  @HiveField(2)
  int? checkIn;
  Contact(
      this.user,
      this.phone,
      this.checkIn,
      );

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
  json["user"], json["phone"], json["check-in"]
  );

  Map<String, dynamic> toJson() => {
    "user": user,
    "phone": phone,
    "check-in": checkIn,
  };
}
