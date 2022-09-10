// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';
import 'package:hive/hive.dart';

part 'contact_model.g.dart';


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
}
