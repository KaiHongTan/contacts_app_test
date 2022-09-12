import 'dart:convert';
import 'dart:io';

import 'package:contacts_app_test/randomContactGen.dart';
import 'package:flutter/material.dart';
import 'package:contacts_app_test/contact_model.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:contacts_app_test/timeconfig.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import 'package:vcard_maintained/vcard_maintained.dart';

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
    for (var contact in jsonContacts) {
      final con = Contact.fromJson(contact);
      contactBox.add(con);
    }
    final contact = Contact.fromJson(jsonContacts);
  }

  void addContact(Contact contact) {
    final contactsBox = Hive.box('contacts');
    contactsBox.add(contact);
  }

  final contactBox = Hive.box('contacts');

  Future _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    RandomContactGen random = new RandomContactGen();
    for (Contact x in random.randomContacts(5)) {
      addContact(x);
    }
    setState(() {});
  }

  void shareAllVCFCard(BuildContext context, vCard, name) async {
    try {
      List<String> vcsCardPath = <String>[];

      var vCardAsString = vCard.getFormattedString();
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      var pathAsText = "$path/$name.txt";

      var contactAsFile = File(pathAsText);
      contactAsFile.writeAsString(vCardAsString);

      var vcf = contactAsFile
          .renameSync(contactAsFile.path.replaceAll(".txt", ".vcf"));
      vcsCardPath.add(vcf.path);
      Share.shareFiles(vcsCardPath);
    } catch (e) {
      print("Error Creating VCF File $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool isTimeAgo = await TimeConfig.getTimeAgo();
          if (isTimeAgo == true) {
            await TimeConfig.setTimeAgo(false);
          } else {
            await TimeConfig.setTimeAgo(true);
          }
          setState(() {});
        },
        label: FutureBuilder<bool>(
          future: TimeConfig.getTimeAgo(),
          initialData: true,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return snapshot.data == true ? Text("Time Ago") : Text("Timestamp");
          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          children: [
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: RefreshIndicator(
                    edgeOffset: 280,
                    child: CustomScrollView(
                      slivers: <Widget>[
                        const SliverAppBar(
                          pinned: true,
                          expandedHeight: 250.0,
                          flexibleSpace: FlexibleSpaceBar(
                            title: Text('Contacts',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 32)),
                          ),
                        ),
                        FutureBuilder(
                          future: Hive.openBox('contacts'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.none &&
                                snapshot.hasData == null) {
                              print("asdff ${snapshot.data}");
                              return Container(color: Colors.red);
                            }
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                var values = contactBox.values.toList();
                                values.sort(
                                    (b, a) => a.checkIn.compareTo(b.checkIn));
                                final contact = values[index] as Contact;
                                final DateTime timeStamp =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        contact.checkIn! * 1000);
                                final d12 = DateFormat('dd/MM/yyyy, hh:mm a')
                                    .format(timeStamp);
                                final timeAgo =
                                    timeago.format(timeStamp, locale: 'en');
                                return Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                contact.user.toString(),
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                contact.phone.toString(),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w300),
                                              )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    right: 5, top: 5),
                                                child: FutureBuilder<bool>(
                                                  future:
                                                      TimeConfig.getTimeAgo(),
                                                  initialData: true,
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<bool>
                                                              snapshot) {
                                                    return snapshot.data == true
                                                        ? Text(timeAgo)
                                                        : Text(d12);
                                                  },
                                                )),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: 15, top: 10),
                                              child: IconButton(
                                                icon: Icon(Icons.share),
                                                onPressed: () {
                                                  var vcard = VCard();
                                                  vcard.firstName =
                                                      contact.user.toString();
                                                  vcard.cellPhone =
                                                      contact.phone;
                                                  shareAllVCFCard(
                                                      context,
                                                      vcard,
                                                      contact.user.toString());
                                                  shareAllVCFCard(
                                                      context,
                                                      vcard,
                                                      contact.user.toString());
                                                },
                                                iconSize: 24,
                                              ),
                                            ),
                                          ],
                                        ))
                                      ],
                                    ),
                                  ),
                                );
                              },
                                  childCount: Hive.box('contacts').length,
                                  semanticIndexOffset: 1),
                            );
                          },
                        ),
                        SliverFillRemaining(
                            hasScrollBody: false,
                            child: Container(
                                alignment: Alignment.center,
                                height: 80,
                                child: const Text(
                                  "You have reached the end of the list",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                )))
                      ],
                    ),
                    onRefresh: () => _refresh()))
          ],
        ),
      ),
    );
  }
}
