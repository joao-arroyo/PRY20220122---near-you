import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:near_you/model/routine.dart';
import 'package:near_you/screens/home_screen.dart';

import '../Constants.dart';
import '../widgets/calendar_timeline.dart';

class RoutineScreen extends StatefulWidget {
  String? currentTreatmentId;

  RoutineScreen(this.currentTreatmentId);

  static const routeName = '/Routine';

  @override
  _RoutineScreenState createState() => _RoutineScreenState(currentTreatmentId);
}

class _RoutineScreenState extends State<RoutineScreen> {
  static Map<String, Routine> routines = <String, Routine>{};
  String currentDateSelected = DateFormat('dd-MMM-yyyy').format(DateTime.now());
  late final Future<Map<String, Routine>> futureRoutine;
  var _currentIndex = 1;

  String? currentTreatmentId;

  _RoutineScreenState(this.currentTreatmentId);

  @override
  void initState() {
    futureRoutine = getRoutineList();
    futureRoutine.then((value) => {
          setState(() {
            routines = value;
          })
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Stack(children: <Widget>[
      Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80), // here the desired height
            child: AppBar(
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    //
                  },
                )
              ],
              backgroundColor: Color(0xff2F8F9D),
              centerTitle: true,
              title: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Rutinas',
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
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20),
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
                              height: 20,
                            ),
                            CalendarTimeline(
                              onChanged: (value){
                                setState(() {
                                  currentDateSelected = value;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Horario',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff2F8F9D)),
                                ),
                              ],
                            ),
                            FutureBuilder(
                              future: futureRoutine,
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
        ]),
        bottomNavigationBar: _buildBottomBar(),
        //TODO : REVIEW THIS
        floatingActionButton: keyboardIsOpened
            ? null
            : GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(top: 40),
                  child:
                      SvgPicture.asset('assets/images/tab_plus_selected.svg',
                        height: HomeScreen.screenHeight/9,
                      ),
                ),
                onTap: () {
                  setState(() {
                    //mostrar menu
                  });
                },
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      )
    ]);
  }

  Widget _buildBottomBar() {
    return Container(
      child: Material(
        elevation: 0.0,
        color: Colors.white,
        child: BottomNavigationBar(
          elevation: 0,
          onTap: (index) {
            _currentIndex = index;
          },
          backgroundColor: Colors.transparent,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/images/tab_metrics_unselected.svg',
                ),
                label: ""),
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/images/tab_person_unselected.svg',
                ),
                label: "")
          ],
        ),
      ),
    );
  }

  getScreenType() {
    if (!routines.containsKey(currentDateSelected)) {
      return noRoutineView();
    }
    return SizedBox(
        width: HomeScreen.screenWidth,
        height: 600,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(routines[currentDateSelected]?.hourCompleted??"00:00"),
            ),
            Wrap(
              children: [
                SizedBox(
                  width: HomeScreen.screenWidth* 0.79,
                  child: Card(
                      margin: EdgeInsets.all(20),
                      child: ClipPath(
                        child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Color(0xffF1F1F1),
                                border: Border(
                                    left: BorderSide(
                                        color: Color(0xff2F8F9D), width: 5))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: <Widget>[
                                  Text(
                                    "Completada",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff2F8F9D),
                                    ),
                                  )
                                ]),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        right: 20, top: 10, left: 10),
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
                                                Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "• Medicación: ",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color:
                                                          Color(0xff67757F),
                                                        ),
                                                      ),
                                                      Text(
                                                        ((routines[currentDateSelected]
                                                            ?.medicationPercentage ??
                                                            0) *
                                                            100).toInt()
                                                            .toString() +
                                                            "%",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: getAdherenceLevelColor(
                                                              ((routines[currentDateSelected]
                                                                  ?.medicationPercentage ??
                                                                  0) *
                                                                  100)
                                                                  .toInt()),
                                                        ),
                                                      )
                                                    ]),
                                                Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "• Alimentación: ",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color:
                                                          Color(0xff67757F),
                                                        ),
                                                      ),
                                                      Text(
                                                        ((routines[currentDateSelected]
                                                            ?.nutritionPercentage ??
                                                            0) *
                                                            100).toInt()
                                                            .toString() +
                                                            "%",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: getAdherenceLevelColor(
                                                              ((routines[currentDateSelected]
                                                                  ?.nutritionPercentage ??
                                                                  0) *
                                                                  100)
                                                                  .toInt()),
                                                        ),
                                                      )
                                                    ]),
                                                Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "• Actividad Física: ",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color:
                                                          Color(0xff67757F),
                                                        ),
                                                      ),
                                                      Text(
                                                        ((routines[currentDateSelected]
                                                            ?.activityPercentage ??
                                                            0) *
                                                            100).toInt()
                                                            .toString() +
                                                            "%",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: getAdherenceLevelColor(
                                                              ((routines[currentDateSelected]
                                                                  ?.activityPercentage ??
                                                                  0) *
                                                                  100)
                                                                  .toInt()),
                                                        ),
                                                      )
                                                    ]),
                                                Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        "• Exámenes: ",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          color:
                                                          Color(0xff67757F),
                                                        ),
                                                      ),
                                                      Text(
                                                        ((routines[currentDateSelected]
                                                            ?.examsPercentage ??
                                                            0) *
                                                            100).toInt()
                                                            .toString() +
                                                            "%",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          color: getAdherenceLevelColor(
                                                              ((routines[currentDateSelected]
                                                                  ?.examsPercentage ??
                                                                  0) *
                                                                  100)
                                                                  .toInt()),
                                                        ),
                                                      )
                                                    ]),
                                              ])
                                        ]))
                                //SizedBox
                              ],
                            )),
                        clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(3))),
                      )),
                )
              ],
            )
          ],
        ));
  }

  /*Future<List<RoutineData>> getRoutineQuestions() async {
    return StaticRoutine.RoutineStaticList;
  }
*/
  noRoutineView() {
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
                  'No registra aún ninguna\nrutina',
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

  void saveAndGoBack() {
    /*  final db = FirebaseFirestore.instance;
    final data = <String, String>{};
    for (int i = 0; i < RoutineResults.length; i++) {
      data.putIfAbsent((i + 1).toString(), () => RoutineResults[i]!);
    }
    db
        .collection(USERS_COLLECTION_KEY)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(ROUTINES_COLLECTION_KEY)
        .add(data)
        .then((value) => dialogSuccess());*/
  }

  Future<Map<String, Routine>> getRoutineList() async {
    final db = FirebaseFirestore.instance;
//    String todayFormattedDate = DateFormat('dd-MMM-yyyy').format(DateTime.now());
    Map<String, Routine> routines = <String, Routine>{};

    var future = await db
        .collection(ROUTINES_COLLECTION_KEY)
        .doc(currentTreatmentId) // TODO: add currentTreatmentId when created
        .collection(ROUTINES_RESULTS_KEY)
        .get();

    for (var element in future.docs) {
      routines.addAll({element.id: Routine.fromSnapshot(element)});
    }
    return routines;
  }

  getAdherenceLevelColor(int adherenceLevel) {
    var value = 0xff47B4AC;
    if (adherenceLevel < 80) {
      value = 0xffF8191E;
    }
    return Color(value);
  }

  bool isNotEmpty(String? str) {
    return str != null && str != '';
  }
}
