import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:firebase_database/firebase_database.dart';
import 'list_children.dart';
import 'ScreenArguments.dart';

void main() => runApp(MyApp());

FirebaseDatabase database = new FirebaseDatabase();

final myControllerFirstName = TextEditingController(text: 'Артём');
final myControllerLastName = TextEditingController(text: 'Васильев');
final myControllerMiddleName = TextEditingController(text: 'Геннадьевич');
final myControllerBirthday = TextEditingController(text: '16.11.1981');
final myControllerPosition = TextEditingController(text: 'Стажёр');

String firstName;
String lastName;
String middleName;
String birthday;
String position;
String key;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: {
      ListChildren.routeName: (context) => ListChildren(),
    }, home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('EKF'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                    controller: myControllerLastName,
                    decoration: InputDecoration(labelText: 'Фамилия'),
                    // ignore: missing_return
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Пожалуйста введите Фамилию';
                      else {
                        lastName = myControllerLastName.text;
                      }
                    }),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Имя'),
                    controller: myControllerFirstName,
                    // ignore: missing_return
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Пожалуйста введите Имя';
                      else {
                        firstName = myControllerFirstName.text;
                      }
                    }),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Отчество'),
                    controller: myControllerMiddleName,
                    // ignore: missing_return
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Пожалуйста введите Отчество';
                      else {
                        middleName = myControllerMiddleName.text;
                      }
                    }),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Дата рождения'),
                    controller: myControllerBirthday,
                    // ignore: missing_return
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Пожалуйста введите дату рождения';
                      else {
                        birthday = myControllerBirthday.text;
                      }
                    }),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Должность'),
                    controller: myControllerPosition,
                    // ignore: missing_return
                    validator: (value) {
                      if (value.isEmpty)
                        return 'Пожалуйста введите должность';
                      else {
                        position = myControllerPosition.text;
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text(
                      'Занести в базу',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    color: Colors.blue,
                    onPressed: passFirebase,
                  ),
                ),
                Text(
                  'Список сотрудников:',
                  style: TextStyle(fontSize: 20, letterSpacing: 0.75),
                  textAlign: TextAlign.center,
                ),
                ListEmployees(),
              ],
            ),
          ),
        ));
  }

  void passFirebase() {
    if (_formKey.currentState.validate()) {
      FirebaseDatabase.instance.reference().child('employees').push().set({
        'lastName': lastName,
        'firstName': firstName,
        'middleName': middleName,
        'birthday': birthday,
        'position': position,
      });
    }

    //_formKey.currentState.save();
  }
}

class ListEmployees extends StatefulWidget {
  @override
  _ListEmployeesState createState() => _ListEmployeesState();
}

class _ListEmployeesState extends State<ListEmployees> {
  var recentJobsRef = FirebaseDatabase.instance.reference().child('employees');

  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: recentJobsRef.onValue,
      builder: (context, snap) {
        if (snap.hasData &&
            !snap.hasError &&
            snap.data.snapshot.value != null) {
          Map data = snap.data.snapshot.value;

          List item = [];

          //print(data);
          data.forEach((index, data) => item.add({"key": index, ...data}));

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
                      title: Text(
                          '${item[index]['lastName']} ${item[index]['firstName']} ${item[index]['middleName']}'),
                      subtitle: Text(
                          'Дата рождения ${item[index]['birthday']}, Должность - ${item[index]['position']}'),
                      trailing: Icon(Icons.child_care),
                      onTap: () {
                        setState(() {
                          lastName = item[index]['lastName'];
                          firstName = item[index]['firstName'];
                          middleName = item[index]['middleName'];
                          birthday = item[index]['birthday'];
                          position = item[index]['position'];
                          key = item[index]['key'];

                          Navigator.pushNamed(
                            context,
                            ListChildren.routeName,
                            arguments: ScreenArguments(firstName, lastName,
                                middleName, birthday, position, key),
                          );
                        });
                      },
                    ),
                  ),
                );
              });
        } else {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Сотрудников нет',
                style: TextStyle(fontSize: 18, color: Colors.blue),
              ),
            ),
          );
        }
      },
    );
  }
}
