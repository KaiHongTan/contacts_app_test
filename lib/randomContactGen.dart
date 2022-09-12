import 'package:contacts_app_test/contact_model.dart';
import 'dart:math';

class RandomContactGen{

  static List<String> surnames = ["Wong", "Lee", "Chong", "Lau", "Tan", "Ong", "Ng", "Chew", "Kuok", "Lim", "Ho"];
  static List<String> name2 = ["Liam", "Olivia", "James", "Gerald", "Lawrence", "Kyle", "Joey", "Gary", "Clement"];

  List<Contact> randomContacts(int amount){
    List<Contact> list = [];
    var x = 0;
    while(x < amount) {
      var name = "${(name2..shuffle()).first} ${(surnames..shuffle()).first}";
      Random random = Random();
      var phoneno = "01${random.nextInt(89999999) + 10000000}";
      list.add(Contact(name, phoneno, DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond));
      x++;
    }
    return list;
  }
}