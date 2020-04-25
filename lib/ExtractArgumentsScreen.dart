import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ExtractArgumentsScreen.dart';
import 'ScreenArguments.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import 'main.dart';

final myControllerFirstNameChild = TextEditingController(text: 'Никита');
final myControllerLastNameChild = TextEditingController(text: 'Лобазин');
final myControllerMiddleNameChild = TextEditingController(text: 'Артёмович');
final myControllerBirthdayChild = TextEditingController(text: '30.09.2012');

String firstNameChild;
String lastNameChild;
String middleNameChild;
String birthdayChild;
String key;
int countChild;

FirebaseDatabase database = new FirebaseDatabase();

class ExtractArgumentsScreen extends StatefulWidget {
  static const routeName = '/extractArguments';
  @override
  _ExtractArgumentsScreenState createState() => _ExtractArgumentsScreenState();
}

class _ExtractArgumentsScreenState extends State<ExtractArgumentsScreen> {
  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    print(args.firstName);
    print(args.lastName);
    print(args.middleName);
    print(args.birthday);
    print(args.position);
    print(args.key);

    return Scaffold(
        appBar: AppBar(
          title: Text('${args.firstName} ${args.lastName}  ${args.middleName}'),
        ),
        body: SetGetChildren());
  }
}

class SetGetChildren extends StatefulWidget {
  @override
  _SetGetChildrenState createState() => _SetGetChildrenState();
}

class _SetGetChildrenState extends State<SetGetChildren> {
  final _formKeyChild = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    // TODO: implement build
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeyChild,
        child: Column(
          children: <Widget>[
            TextFormField(
                controller: myControllerLastNameChild,
                decoration: InputDecoration(labelText: 'Фамилия ребёнка'),
                // ignore: missing_return
                validator: (value) {
                  if (value.isEmpty)
                    return 'Пожалуйста введите фамилию ребёнка';
                  else {
                    lastNameChild = myControllerLastNameChild.text;
                  }
                }),
            TextFormField(
                decoration: InputDecoration(labelText: 'Имя'),
                controller: myControllerFirstNameChild,
                // ignore: missing_return
                validator: (value) {
                  if (value.isEmpty)
                    return 'Пожалуйста введите имя ребёнка';
                  else {
                    firstNameChild = myControllerFirstNameChild.text;
                  }
                }),
            TextFormField(
                decoration: InputDecoration(labelText: 'Отчество'),
                controller: myControllerMiddleNameChild,
                // ignore: missing_return
                validator: (value) {
                  if (value.isEmpty)
                    return 'Пожалуйста введите отчество ребёнка';
                  else {
                    middleNameChild = myControllerMiddleNameChild.text;
                  }
                }),
            TextFormField(
                decoration: InputDecoration(labelText: 'Дата рождения'),
                controller: myControllerBirthdayChild,
                // ignore: missing_return
                validator: (value) {
                  if (value.isEmpty)
                    return 'Пожалуйста введите дату рождения ребёнка';
                  else {
                    birthdayChild = myControllerBirthdayChild.text;
                  }
                }),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text(
                  'Добавить ребёнка в базу',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: passFirebase,
              ),
            ),
            Text(
              'Список детей сотрудника ${args.firstName} ${args.lastName}  ${args.middleName}:',
              style: TextStyle(fontSize: 20, letterSpacing: 0.75),
              textAlign: TextAlign.center,
            ),
            QueryTicketsChild(),

            //Text(item.length)
          ],
        ),
      ),
    ));
  }

  void passFirebase() {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;
    if (_formKeyChild.currentState.validate()) {
      FirebaseDatabase.instance
          .reference()
          .child('employees/${args.key}/children') //${args.key}
          .push()
          .set({
        'lastNameChild': lastNameChild,
        'firstNameChild': firstNameChild,
        'middleNameChild': middleNameChild,
        'birthdayChild': birthdayChild,
      });
    }
    _formKeyChild.currentState.save();
  }
}

class QueryTicketsChild extends StatefulWidget {
  @override
  _QueryTicketsChildState createState() => _QueryTicketsChildState();
}

class _QueryTicketsChildState extends State<QueryTicketsChild> {
  int countChild;
  Widget build(BuildContext context) {
    final ScreenArguments args = ModalRoute.of(context).settings.arguments;

    var recentJobsRef = FirebaseDatabase.instance
        .reference()
        .child('employees/${args.key}/children'); //${args.key}

    return StreamBuilder(
      stream: recentJobsRef.onValue,
      builder: (context, snap) {
        if (snap.hasData &&
            !snap.hasError &&
            snap.data.snapshot.value != null) {
          Map data = snap.data.snapshot.value;
          List item = [];

          //print(data);
          data.forEach((index, data) {
            item.add({"key": index, ...data});
          });

          countChild = item.length;

          //print(countChild);

          return ListView.builder(
              shrinkWrap: true,
              itemCount: item.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        border: Border.all(width: 1.0, color: Colors.blue)),
                    child: ListTile(
                      selected: true,
                      title: Text(item[index]['lastNameChild'] +
                          ' ' +
                          item[index]['firstNameChild'] +
                          ' ' +
                          item[index]['middleNameChild']),
                      subtitle: Text(item[index]['birthdayChild']),
                      trailing: Icon(
                        Icons.supervisor_account,
                        size: 36,
                      ),
                      onTap: () {},
                    ),
                  ),
                );
              });
        } else {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'У сотрудника нет детей',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ));
        }
      },
    );
  }
}
