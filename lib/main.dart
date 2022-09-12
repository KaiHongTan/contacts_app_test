import 'dart:convert';

import 'package:contacts_app_test/contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'contact_model.dart';

initDefaultContacts() async {
  final contactsBox = Hive.box('contacts');
  final jsonString = await rootBundle.loadString('lib/contacts.json');
  final jsonData = jsonDecode(jsonString);
  final jsonContacts = jsonData["contact"];
  for(var contact in jsonContacts){
    final con = Contact.fromJson(contact);
    contactsBox.add(con);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(ContactAdapter());
  final contactsBox = await Hive.openBox('contacts');
  if(contactsBox.isEmpty){
    initDefaultContacts();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode (SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const Contacts(),
    );
  }
}
