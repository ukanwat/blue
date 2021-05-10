import 'package:blue/services/auth_service.dart';
import 'package:blue/services/boxes.dart';
import 'package:blue/services/hasura.dart';
import 'package:blue/services/preferences_update.dart';
import 'package:blue/widgets/progress.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetNameScreen extends StatefulWidget {
  static const routeName = 'set-name';
  @override
  _SetNameScreenState createState() => _SetNameScreenState();
}

class _SetNameScreenState extends State<SetNameScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  Map data;
  @override
  void didChangeDependencies() {
    data = ModalRoute.of(context).settings.arguments as Map;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/stark-bnb-icon-wa.png'),
              SizedBox(height: 20),
              Text(
                'Stark',
                style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 50,
                    fontFamily: 'Techna Sans Regular'),
              ),
              FittedBox(
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Theme.of(context).cardColor,
                    elevation: 10,
                    margin: EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 30,
                            ),
                            width: MediaQuery.of(context).size.width - 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (data['provider'] != 'google')
                                  TextFormField(
                                    controller: nameController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                        fillColor: Colors.grey.shade700,
                                        isDense: true,
                                        filled: true,
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        hintText: "Choose a Display Name",
                                        prefixIcon: Icon(
                                          FluentIcons.star_12_filled,
                                          size: 28,
                                          color: Colors.grey,
                                        )),
                                  ),
                                if (data['provider'] != 'google')
                                  SizedBox(height: 20),
                                TextFormField(
                                  controller: usernameController,
                                  inputFormatters: [
                                    new FilteringTextInputFormatter.allow(
                                        RegExp("[a-z0-9.]")),
                                  ],
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      fillColor: Colors.grey.shade700,
                                      isDense: true,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      hintText: "Choose a username",
                                      prefixIcon: Icon(
                                        FluentIcons.person_12_filled,
                                        size: 28,
                                        color: Colors.grey,
                                      )),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                          Container(
                            width: 100,
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    elevation: 3,
                                    backgroundColor:
                                        Theme.of(context).accentColor,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50))),
                                  ),
                                  child: Text('Done',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 18)),
                                  onPressed: () async {
                                    if (nameController.text == "") {
                                      snackbar('display name is empty', context,
                                          color: Colors.red);
                                      return;
                                    }
                                    if (usernameController.text == "") {
                                      snackbar('username is empty', context,
                                          color: Colors.red);
                                      return;
                                    }
                                    progressOverlay(context: context).show();
                                    bool notExists = await Hasura.checkUsername(
                                        usernameController.text);
                                    progressOverlay(context: context).dismiss();
                                    print('noexists');
                                    print(notExists);
                                    if (notExists) {
                                      snackbar(
                                          'username is unavailable', context,
                                          color: Colors.red);

                                      return;
                                    }
                                    if (data['provider'] == 'email') {
                                      Navigator.of(context).pop();
                                      Navigator.pop(context, {
                                        'name': nameController.text,
                                        'username': usernameController.text
                                      });
                                      print('noexists');
                                    } else if (data['provider'] == 'google') {
                                      Navigator.of(context).pop();
                                      Navigator.pop(
                                          context, usernameController.text);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ));
  }
}

class GradientBox extends StatelessWidget {
  GradientBox({
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      child: SizedBox.expand(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: begin,
          end: end,
          stops: [0, 1],
        ),
      ),
    );
  }
}
