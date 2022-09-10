import 'package:flutter/material.dart';
import 'package:contacts_app_test/contact_model.dart';
import 'package:hive/hive.dart';

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

  void addContact(Contact contact){
    final contactsBox = Hive.box('contacts');
    contactsBox.add(contact);
  }
  var contactBox = Hive.box('contacts');

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
            ElevatedButton(onPressed: (){
              final newContact = Contact('Test', '0192807993', 1662839984);
              addContact(newContact);

            }, child: Text("Add",style: TextStyle(color: Colors.white),)),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RefreshIndicator(child:
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
                                          final contact = contactBox.get(index) as Contact;
                                          return ListTile(
                                                title: Text(contact.user.toString()),
                                                trailing: Text(contact.phone.toString())
                                              );
                                        }, childCount: Hive.box('contacts').length,
                                      semanticIndexOffset: 1

                                    )
                                );
                          },


                    ),

                ],
              ), onRefresh: () => _refresh())
            )
          ],
        ),
      ),
    );
  }
}
