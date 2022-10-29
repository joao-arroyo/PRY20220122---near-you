import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/widgets/patient_detail.dart';

import '../model/user.dart' as user;
import '../widgets/firebase_utils.dart';

class PatientDetailScreen extends StatefulWidget {
  String userId;

  PatientDetailScreen(this.userId);

  static const routeName = '/patient_detail';

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState(userId);
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  String userId;
  user.User? patientUser;
  late final Future<DocumentSnapshot> futureUser;

  _PatientDetailScreenState(this.userId);

  var _currentIndex = 1;

  @override
  void initState() {
    futureUser = getUserById(userId);
    futureUser.then((value) => {
          setState(() {
            patientUser = user.User.fromSnapshot(value);
          })
        });
    super.initState();
    //initStateAsync();
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Stack(children: <Widget>[
      Scaffold(
          appBar: PreferredSize(
              preferredSize: Size.fromHeight(80), // here the desired height
              child: AppBar(
                backgroundColor: Color(0xff2F8F9D),
                centerTitle: true,
                title: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                        patientUser != null
                            ? patientUser?.fullName ??
                                patientUser?.type ??
                                "Nombre"
                            : "Nombre",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold))),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )),
          body: Stack(children: <Widget>[
            Container(
                width: double.maxFinite,
                height: double.maxFinite,
                child: FittedBox(
                  fit: BoxFit.none,
                  child: SvgPicture.asset('assets/images/backgroundHome.svg'),
                )),
            Scaffold(
                backgroundColor: Colors.transparent,
                body: LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    return Container(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              FutureBuilder(
                                future: futureUser,
                                builder: (context, AsyncSnapshot snapshot) {
                                  //patientUser = user.User.fromSnapshot(snapshot.data);
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return getScreenType();
                                  }
                                  return CircularProgressIndicator();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ))
          ]))
    ]);
  }

  getScreenType() {
    if (patientUser == null) {
      return const CircularProgressIndicator();
    }
    return PatientDetail.forDoctorView(patientUser);
  }

}
