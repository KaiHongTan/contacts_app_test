import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:contacts_app_test/contact_model.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class Contacts extends StatefulWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {

  @override
  void initState() {
    super.initState();
  }
  initDefaultContacts() async {
    final contactsBox = Hive.box('contacts');
    final jsonString = await rootBundle.loadString('lib/contacts.json');
    final jsonData = jsonDecode(jsonString);
    final jsonContacts = jsonData["contact"];
    for(var contact in jsonContacts){
      final con = Contact.fromJson(contact);
      contactBox.add(con);
    }
    final contact = Contact.fromJson(jsonContacts);
  }
  void addContact(Contact contact){
    final contactsBox = Hive.box('contacts');
    contactsBox.add(contact);
  }
  final contactBox = Hive.box('contacts');

  Future _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
    });
  }
  @override
  Widget build(BuildContext context) {
    return
        Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          children: [

            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RefreshIndicator(edgeOffset:250 ,child:
              CustomScrollView(
                slivers: <Widget>[
                  const SliverAppBar(
                    pinned: true,
                    expandedHeight: 250.0,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text('Contacts', style: TextStyle(color: Colors.white, fontSize: 32)),
                    ),
                  ),
                  FutureBuilder(
                          future: Hive.openBox('contacts'),
                          builder: (context, snapshot){
                            if (snapshot.connectionState == ConnectionState.none &&
                                snapshot.hasData == null){
                              print("asdff ${snapshot.data}");
                              return Container(color: Colors.red);
                            }
                            return
                                SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index){
                                          var values = contactBox.values.toList();
                                          values.sort((b,a)=>a.checkIn.compareTo(b.checkIn));
                                          final contact = values[index] as Contact;
                                          final DateTime timeStamp = DateTime.fromMillisecondsSinceEpoch(contact.checkIn! * 1000);
                                          final d12 = DateFormat('dd/MM/yyyy, hh:mm a').format(timeStamp);
                                          return Padding(
                                            padding: EdgeInsets.all(5),
                                            child:Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10)
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(padding: EdgeInsets.all(20),
                                                  child:Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(contact.user.toString(),
                                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),),
                                                      Text(contact.phone.toString(),
                                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),)
                                                    ],
                                                  )
                                                    ,),
                                                  Expanded(child:
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end, 
                                                    children: [
                                                      Padding(padding: EdgeInsets.only(right: 5, top: 5),
                                                      child: Text(d12.toString(),
                                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),),)

                                                    ],
                                                  ))
                                                ],
                                              ),
                                            ) ,
                                          );

                                            //ListTile(
                                                title: Text(contact.user.toString());
                                                trailing: Text(contact.phone.toString());
                                            subtitle: Text(timeStamp.toLocal().toString());
                                        }, childCount: Hive.box('contacts').length,
                                      semanticIndexOffset: 1),
                                );
                          },


                    ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      alignment: Alignment.center,
                        height: 80,
                        child:
                          const Text("You have reached the end of the list", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),))
                  )
                ],
              ), onRefresh: () => _refresh())
            )
          ],
        ),
      ),
    );
  }
}
