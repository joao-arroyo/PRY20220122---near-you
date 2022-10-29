import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/common/static_common_functions.dart';
import 'package:near_you/screens/patient_detail_screen.dart';
import 'package:near_you/widgets/dialogs.dart';
import '../model/user.dart' as user;

import '../Constants.dart';
import '../screens/home_screen.dart';

class PatientsListLayout extends StatefulWidget {
  Function updatePatientsCounter;

  PatientsListLayout(this.updatePatientsCounter);

  @override
  PatientListState createState() {
    return new PatientListState(updatePatientsCounter);
  }
}

class PatientListState extends State<PatientsListLayout> {
  List<user.User> patients = <user.User>[];

  late final Future<List<user.User>> patientsListFuture;

  Function updatePatientsCounter;

  PatientListState(this.updatePatientsCounter);

  @override
  void initState() {
    patientsListFuture = getListOfPatients();
    patientsListFuture.then((value) => {
          if (this.mounted)
            {
              setState(() {
                patients = value;
                updatePatientsCounter(value.length);
              })
            }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: patientsListFuture,
        builder: (context, AsyncSnapshot<List<user.User>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (patients.isEmpty) {
            return Container(
              width: double.infinity,
              height: HomeScreen.screenHeight,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Usted no tiene pacientes\nvinculados',
                          textAlign: TextAlign.center,
                          maxLines: 5,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff999999),
                            fontFamily: 'Italic',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ])),
            );
          }
          return ListView.builder(
              itemCount: patients.length,
              padding: EdgeInsets.only(bottom: 60),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PatientDetailScreen(patients[index].userId ?? ""),
                      ),
                    );
                  },
                  child: Card(
                      color: Color(0xffF1F1F1),
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: ClipPath(
                        child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        color: Color(0xff2F8F9D), width: 5))),
                            child: Column(
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            patients[index].fullName ??
                                                "Nombre",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff2F8F9D),
                                            ),
                                          ),
                                        ])),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  isNotEmtpy(patients[index]
                                                          .currentTreatment)
                                                      ? "•  1 Consulta"
                                                      : "•  0 Consultas",
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color(0xff67757F),
                                                  ),
                                                ),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "•  Nivel de adherencia: ",
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                      ),
                                                      Text(
                                                        ((patients[index].adherenceLevel ??
                                                                        0) *
                                                                    100)
                                                                .toInt()
                                                                .toString() +
                                                            "%",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              getAdherenceLevelColor(
                                                                  index),
                                                        ),
                                                      )
                                                    ]),
                                              ]),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 25),
                                              child: InkWell(
                                                  onTap: () {
                                                    //TODO: remove pending notifications to user if devinculate
                                                    showDialogDevinculation(
                                                        context,
                                                        patients[index].userId!,
                                                        false, () {
                                                      Navigator.pop(context);
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  HomeScreen()));
                                                    });
                                                  },
                                                  child: Container(
                                                      width: 24,
                                                      height: 24,
                                                      child: SvgPicture.asset(
                                                          'assets/images/unlink_icon.svg'))))
                                        ]))
                                //SizedBox
                              ],
                            )),
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3))),
                      )),
                );
              });
        });
  }

  getAdherenceLevelColor(int index) {
    var value = 0xff47B4AC;
    double adherenceLevel = (patients[index].adherenceLevel ?? 0) * 100;
    if (adherenceLevel < 80) {
      value = 0xffF8191E;
    }
    return Color(value);
  }

  Future<List<user.User>> getListOfPatients() async {
    final db = FirebaseFirestore.instance;
    String? medicoId = FirebaseAuth.instance.currentUser?.uid;
    if (medicoId == null) {
      return <user.User>[];
    }
    var future = await db
        .collection(USERS_COLLECTION_KEY)
        .where(MEDICO_ID_KEY, isEqualTo: medicoId)
        .get();
    List<user.User> patients = <user.User>[];
    for (var element in future.docs) {
      user.User currentUser = user.User.fromSnapshot(element);
      currentUser.userId = element.id;
      patients.add(currentUser);
    }
    return patients;
  }
}
