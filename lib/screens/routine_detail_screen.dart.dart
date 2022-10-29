import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:age_calculator/age_calculator.dart';
import 'package:near_you/common/static_common_functions.dart';
import 'package:near_you/screens/home_screen.dart';
import '../model/user.dart' as user;
import 'package:intl/intl.dart';

import '../Constants.dart';
import '../model/activityPrescription.dart';
import '../model/medicationPrescription.dart';
import '../model/nutritionPrescription.dart';
import '../model/examsPrescription.dart';
import '../widgets/firebase_utils.dart';
import '../widgets/static_components.dart';

class RoutineDetailScreen extends StatefulWidget {
  String currentTreatmentId;

  RoutineDetailScreen(this.currentTreatmentId);

  static const routeName = '/routine_detail';

  @override
  _RoutineDetailScreenState createState() =>
      _RoutineDetailScreenState(currentTreatmentId);
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  late final Future<List<MedicationPrescription>> medicationPrescriptionFuture;
  late final Future<List<NutritionPrescription>> nutritionPrescriptionFuture;
  late final Future<List<ActivityPrescription>> activityPrescriptionFuture;
  late final Future<List<ExamsPrescription>> examsPrescriptionFuture;
  late final Future<Map<String, int>> previousResultsFuture;

  Map<String, int> previousResults = {};
  List<MedicationPrescription> medicationsList = <MedicationPrescription>[];
  List<NutritionPrescription> nutritionList = <NutritionPrescription>[];
  List<ActivityPrescription> activitiesList = <ActivityPrescription>[];
  List<NutritionPrescription> nutritionNoPermittedList =
      <NutritionPrescription>[];
  List<ExamsPrescription> examsList = <ExamsPrescription>[];
  var currentRoutineIndex = 0;
  int totalPrescriptions = 0;
  double percentageProgress = 0;
  static StaticComponents staticComponents = StaticComponents();

  String currentTreatmentId;

  String? examsGlucosaLevelValue;

  _RoutineDetailScreenState(this.currentTreatmentId);

  get sizedBox10 => const SizedBox(height: 10);

  @override
  void initState() {
    previousResultsFuture = getPreviousResults();
    medicationPrescriptionFuture =
        getMedicationPrescriptions(currentTreatmentId);
    activityPrescriptionFuture = getActivityPrescriptions(currentTreatmentId);
    nutritionPrescriptionFuture = getNutritionPrescriptions(currentTreatmentId);
    examsPrescriptionFuture = getExamsPrescriptions(currentTreatmentId);
    previousResultsFuture.then((value) => setState(() {
          previousResults = value;
          initAllData();
        }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(HomeScreen.screenHeight / 10),
            // here the desired height
            child: AppBar(
              toolbarHeight: HomeScreen.screenHeight / 10,
              backgroundColor: Color(0xff2F8F9D),
              centerTitle: true,
              title: Text(getAppbarTitle(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold)),
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
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_month,
                                      color: Color(0xff999999)),
                                  Text(
                                      DateFormat(' dd - MMM yyyy hh:mm:ss')
                                          .format(DateTime.now()),
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Color(0xff999999)))
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                  color: Color(0xffCECECE),
                                  thickness: 1,
                                ))
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      icon: SvgPicture.asset(
                                        (currentRoutineIndex == 0
                                            ? 'assets/images/medication_selected.svg'
                                            : 'assets/images/medication_unselected.svg'),
                                        height: 44,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          currentRoutineIndex = 0;
                                        });
                                      }),
                                  IconButton(
                                      padding: const EdgeInsets.all(5),
                                      icon: SvgPicture.asset(
                                        (currentRoutineIndex == 1
                                            ? 'assets/images/nutrition_selected.svg'
                                            : 'assets/images/nutrition_unselected.svg'),
                                        height: 44,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          currentRoutineIndex = 1;
                                        });
                                      }),
                                  IconButton(
                                      padding: const EdgeInsets.all(5),
                                      icon: SvgPicture.asset(
                                          (currentRoutineIndex == 2
                                              ? 'assets/images/activity_selected.svg'
                                              : 'assets/images/activity_unselected.svg'),
                                          height: 44),
                                      onPressed: () {
                                        setState(() {
                                          currentRoutineIndex = 2;
                                        });
                                      }),
                                  IconButton(
                                      padding: const EdgeInsets.all(5),
                                      icon: SvgPicture.asset(
                                        (currentRoutineIndex == 3
                                            ? 'assets/images/exams_selected.svg'
                                            : 'assets/images/exams_unselected.svg'),
                                        height: 44,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          currentRoutineIndex = 3;
                                        });
                                      })
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            FutureBuilder(
                              future: medicationPrescriptionFuture,
                              builder: (context, AsyncSnapshot snapshot) {
                                //patientUser = user.User.fromSnapshot(snapshot.data);
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (totalPrescriptions == 0) {
                                    return getEmptyView();
                                  }
                                  return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        GFProgressBar(
                                          percentage: percentageProgress,
                                          lineHeight: 17,
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 5),
                                            child: Text(
                                              (100 * percentageProgress)
                                                      .toInt()
                                                      .toString() +
                                                  '%',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          backgroundColor: Color(0xffD9D9D9),
                                          progressBarColor: Color(0xff2F8F9D),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: HomeScreen.screenHeight * 0.5,
                                          child: getCurrrentSectionList(),
                                        )
                                      ]);
                                  //  return getScreenType();
                                }
                                return CircularProgressIndicator();
                              },
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  (currentRoutineIndex < 3
                                      ? FlatButton(
                                          disabledColor: Color(0xffD9D9D9),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          color: const Color(0xff2F8F9D),
                                          textColor: Colors.white,
                                          onPressed: () {
                                            nextRoutine();
                                          },
                                          child: const Text(
                                            'Siguiente',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        )),
                                  (currentRoutineIndex > 0
                                      ? FlatButton(
                                          shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  color: Color(0xff9D9CB5),
                                                  width: 1,
                                                  style: BorderStyle.solid),
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          textColor: Color(0xff9D9CB5),
                                          onPressed: () {
                                            previousRoutine();
                                          },
                                          child: const Text(
                                            'Anterior',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        )),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ))
        ]),
      )
    ]);
  }

  Widget getEmptyView() {
    return Container(
      width: double.infinity,
      height: HomeScreen.screenHeight * 0.55,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset('assets/images/no_routine_icon.svg'),
                SizedBox(height: 5),
                Text(
                  '¡Usted no presenta\nprescripción en esta sección!',
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff999999),
                    fontFamily: 'Italic',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ])),
    );
  }

  void nextRoutine() {
    setState(() {
      ++currentRoutineIndex;
    });
  }

  void previousRoutine() {
    setState(() {
      --currentRoutineIndex;
    });
  }

  Widget getCurrrentSectionList() {
    switch (currentRoutineIndex) {
      case 0:
        return getMedicationList();
      case 1:
        return getNutritionsLists();
      case 2:
        return getActivityList();
      default:
        return getExamsList();
    }
  }

  Widget getMedicationList() {
    if (medicationsList.isEmpty) {
      return getEmptyView();
    }

    return SizedBox(
        height: HomeScreen.screenHeight * 0.4,
        child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: medicationsList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("${index + 1}°Medicamento",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xff2F8F9D),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                              color: Color(0xffCECECE),
                              thickness: 1,
                            ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              height: 35,
                              child: Text(
                                  medicationsList[index].name ?? "Nombre",
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff999999))),
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                int value = medicationsList[index].state ?? 0;
                                int newValue = value == 0 ? 1 : 0;
                                setState(() {
                                  medicationsList[index].state = newValue;
                                  updatePercentageProgress();
                                });
                              },
                              color: (medicationsList[index].state ?? 0) == 0
                                  ? Colors.white
                                  : const Color(0xff3BACB6),
                              child: Text(
                                'Listo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      (medicationsList[index].state ?? 0) == 0
                                          ? const Color(0xff2F8F9D)
                                          : Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: SizedBox(
                                    height: 35,
                                    width: 172,
                                    child: Text("Periodicidad",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF999999)))),
                              ),
                              Flexible(
                                  child: SizedBox(
                                      height: 25,
                                      width: HomeScreen.screenWidth * 0.4,
                                      child: TextFormField(
                                        controller: TextEditingController(
                                            text: medicationsList[index]
                                                .periodicity),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff999999)),
                                        decoration: staticComponents
                                            .getMiddleInputDecorationDisabledRoutine(),
                                      )))
                            ]),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Recomendación",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xff999999)))
                          ],
                        ),
                        sizedBox10,
                        TextFormField(
                          controller: TextEditingController(
                              text: medicationsList[index].recomendation),
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xff999999)),
                          minLines: 2,
                          maxLines: 10,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: staticComponents
                              .getBigInputDecorationDisabledRoutine(),
                        ),
                        sizedBox10
                      ],
                    ),
                  )
                ],
              );
            }));
  }

  Widget getNutritionList() {
    return SizedBox(
        child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nutritionList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${index + 1}.¿Hoy consumiste tu porción de\n ${nutritionList[index].name} diaria?",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xff808080)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                          value: 1,
                                          groupValue:
                                              nutritionList[index].state,
                                          onChanged: (value) {
                                            setState(() {
                                              nutritionList[index].state =
                                                  value!;
                                              updatePercentageProgress();
                                            });
                                          }),
                                      Expanded(
                                        child: Text(
                                          'Si',
                                          style: TextStyle(
                                              color: Color(0xff67757F),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                          value: 0,
                                          groupValue:
                                              nutritionList[index].state,
                                          onChanged: (value) {
                                            setState(() {
                                              nutritionList[index].state =
                                                  value!;
                                              updatePercentageProgress();
                                            });
                                          }),
                                      Expanded(
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              color: Color(0xff67757F),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  flex: 1,
                                )
                              ]),
                        )
                      ],
                    ),
                  )
                ],
              );
            }));
  }

  Widget getNutritionListProhibited() {
    return SizedBox(
        child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nutritionNoPermittedList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${index + 1}.¿Hoy consumiste \n ${nutritionNoPermittedList[index].name}?",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xff808080)),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                          value: 1,
                                          groupValue:
                                              nutritionNoPermittedList[index]
                                                  .state,
                                          onChanged: (value) {
                                            setState(() {
                                              nutritionNoPermittedList[index]
                                                  .state = value!;
                                              updatePercentageProgress();
                                            });
                                          }),
                                      Expanded(
                                        child: Text(
                                          'Si',
                                          style: TextStyle(
                                              color: Color(0xff67757F),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                          value: 0,
                                          groupValue:
                                              nutritionNoPermittedList[index]
                                                  .state,
                                          onChanged: (value) {
                                            setState(() {
                                              nutritionNoPermittedList[index]
                                                  .state = value!;
                                              updatePercentageProgress();
                                            });
                                          }),
                                      Expanded(
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              color: Color(0xff67757F),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  flex: 1,
                                )
                              ]),
                        )
                      ],
                    ),
                  )
                ],
              );
            }));
  }

  Widget getActivityList() {
    if (activitiesList.isEmpty) {
      return getEmptyView();
    }
    return SizedBox(
        height: HomeScreen.screenHeight * 0.4,
        child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: activitiesList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xffD9D9D9),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("${index + 1}° Actividad",
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xff2F8F9D),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                              color: Color(0xffCECECE),
                              thickness: 1,
                            ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              height: 35,
                              child: Text(
                                  activitiesList[index].name ?? "Nombre",
                                  style: const TextStyle(
                                      fontSize: 14, color: Color(0xff999999))),
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                int value = activitiesList[index].state ?? 0;
                                int newValue = value == 0 ? 1 : 0;
                                setState(() {
                                  activitiesList[index].state = newValue;
                                  updatePercentageProgress();
                                });
                              },
                              color: (activitiesList[index].state ?? 0) == 0
                                  ? Colors.white
                                  : const Color(0xff3BACB6),
                              child: Text(
                                'Listo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (activitiesList[index].state ?? 0) == 0
                                      ? const Color(0xff2F8F9D)
                                      : Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: SizedBox(
                                    height: 35,
                                    width: 172,
                                    child: Text("Tiempo",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF999999)))),
                              ),
                              Flexible(
                                  child: SizedBox(
                                      height: 25,
                                      width: HomeScreen.screenWidth * 0.27,
                                      child: TextFormField(
                                        controller: TextEditingController(
                                            text: activitiesList[index]
                                                .timeNumber),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff999999)),
                                        decoration: staticComponents
                                            .getMiddleInputDecorationDisabledRoutine(),
                                      ))),
                              Flexible(
                                  child: SizedBox(
                                      height: 25,
                                      width: HomeScreen.screenWidth * 0.27,
                                      child: TextFormField(
                                        controller: TextEditingController(
                                            text:
                                                activitiesList[index].timeType),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xff999999)),
                                        decoration: staticComponents
                                            .getMiddleInputDecorationDisabledRoutine(),
                                      )))
                            ])
                      ],
                    ),
                  )
                ],
              );
            }));
  }

  Widget getExamsList() {
    if (examsList.isEmpty) {
      return getEmptyView();
    }
    return Column(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Column(
                children: [
                  Text(
                    "¿Cuanto fue tu nivel de glucosa el día de hoy?",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xff808080)),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 80),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                              child: SizedBox(
                                  height: 25,
                                  width: HomeScreen.screenWidth * 0.2,
                                  child: TextFormField(
                                    onChanged: (value) {
                                      examsGlucosaLevelValue = value;
                                    },
                                    controller: TextEditingController(
                                        text: examsGlucosaLevelValue),
                                    style: const TextStyle(
                                        fontSize: 14, color: Color(0xff999999)),
                                    decoration: staticComponents
                                        .getMiddleInputDecoration("3"),
                                  ))),
                          Flexible(
                            child: SizedBox(
                                height: 25,
                                child: Text("mg/dl",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF999999)))),
                          )
                        ]),
                  )
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lista de exámenes:",
                style: TextStyle(color: Color(0xff999999), fontSize: 14))
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
            height: HomeScreen.screenHeight * 0.3,
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: examsList.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xffD9D9D9),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "¿Pasaste tu examen de ${examsList[index].name}?",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xff808080)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Radio<int>(
                                              value: 1,
                                              groupValue:
                                                  examsList[index].state,
                                              onChanged: (value) {
                                                setState(() {
                                                  examsList[index].state =
                                                      value!;
                                                  updatePercentageProgress();
                                                });
                                              }),
                                          Expanded(
                                            child: Text(
                                              'Si',
                                              style: TextStyle(
                                                  color: Color(0xff67757F),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                      flex: 1,
                                    ),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Radio<int>(
                                              value: 0,
                                              groupValue:
                                                  examsList[index].state,
                                              onChanged: (value) {
                                                setState(() {
                                                  examsList[index].state =
                                                      value!;
                                                  updatePercentageProgress();
                                                });
                                              }),
                                          Expanded(
                                            child: Text(
                                              'No',
                                              style: TextStyle(
                                                  color: Color(0xff67757F),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                      flex: 1,
                                    )
                                  ]),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                }))
      ],
    );
  }

  String getAppbarTitle() {
    switch (currentRoutineIndex) {
      case 0:
        return 'Medicación';
      case 1:
        return 'Alimentación';
      case 2:
        return 'Actividad Física';
      default:
        return 'Exámenes';
    }
  }

  void updatePercentageProgress({onlyUpdate = false}) {
    int total = medicationsList.length +
        activitiesList.length +
        nutritionNoPermittedList.length +
        nutritionList.length +
        examsList.length;
    int medicationCompleted = 0;
    int activityCompleted = 0;
    int nutritionCompleted = 0;
    int nutritionNotPermittedCompleted = 0;
    int examsCompleted = 0;
    int nutritionValue = 0;
    int nutritionNPValue = 0;
    int examsValue = 0;
    final data = <String, Object>{};
    for (var element in medicationsList) {
      medicationCompleted += element.state ?? 0;
      if (isNotEmtpy(element.name)) {
        // TODO validate not empty prescriptions names
        data.addAll({element.name!: element.state ?? -1});
      }
    }
    for (var element in activitiesList) {
      activityCompleted += element.state ?? 0;
      if (isNotEmtpy(element.name)) {
        data.addAll({element.name!: element.state ?? -1});
      }
    }
    for (var element in nutritionList) {
      if (element.state != null) {
        nutritionCompleted++;
        nutritionValue += element.state!; //NO is 0, Yes is 1, no selected -1
      }
      if (isNotEmtpy(element.name)) {
        data.addAll({element.name!: element.state ?? -1});
      }
    }
    for (var element in nutritionNoPermittedList) {
      if (element.state != null) {
        nutritionNotPermittedCompleted++;
        nutritionNPValue += element.state!; //NO is 0, Yes is 1, no selected -1
      }
      if (isNotEmtpy(element.name)) {
        data.addAll({element.name!: element.state ?? -1});
      }
    }
    for (var element in examsList) {
      if (element.state != null) {
        examsCompleted++;
        examsValue += element.state!; //NO is 0, Yes is 1, no selected -1
      }
      if (isNotEmtpy(element.name)) {
        data.addAll({element.name!: element.state ?? -1});
      }
    }
    int currentCompleted = medicationCompleted +
        nutritionCompleted +
        nutritionNotPermittedCompleted +
        examsCompleted +
        activityCompleted;
    percentageProgress = currentCompleted / total;
    if (onlyUpdate) {
      return;
    }
    data.addAll({
      ROUTINE_TOTAL_PERCENTAGE_KEY: percentageProgress,
      ROUTINE_EXAM_GLUCOSA_LEVEL: examsGlucosaLevelValue ?? ""
    });
    saveResultsInDatabase(
        data,
        medicationCompleted,
        nutritionCompleted,
        nutritionNotPermittedCompleted,
        activityCompleted,
        examsCompleted,
        nutritionValue,
        nutritionNPValue,
        examsValue);
  }

  Widget getNutritionsLists() {
    if (nutritionList.isEmpty && nutritionNoPermittedList.isEmpty) {
      return getEmptyView();
    }
    return SizedBox(
        height: HomeScreen.screenHeight * 0.4,
        child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 1,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Alimentos permitidos",
                        style:
                            TextStyle(color: Color(0xff999999), fontSize: 14),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  getNutritionList(),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Alimentos no permitidos",
                          style:
                              TextStyle(color: Color(0xff999999), fontSize: 14))
                    ],
                  ),
                  SizedBox(height: 10),
                  getNutritionListProhibited()
                ],
              );
            }));
  }

  void saveResultsInDatabase(
      Map<String, Object> data,
      int medicationCompleted,
      int nutritionCompleted,
      int nutritionNotPermittedCompleted,
      int activityCompleted,
      int examsCompleted,
      int nutritionValue,
      int nutritionNPValue,
      int examsValue) async {
    final db = FirebaseFirestore.instance;
    String todayFormattedDate = getTodayFormattedDate();
    final int medicationListSize = medicationsList.length;
    final int activitiesListSize = activitiesList.length;
    final int nutritionsListSize =
        nutritionList.length + nutritionNoPermittedList.length;
    final int examsListSize = examsList.length;

    double medicationPercentage =
        medicationListSize > 0 ? medicationCompleted / medicationListSize : 0;
    double activitiesPercentage =
        activitiesListSize > 0 ? activityCompleted / activitiesListSize : 0;
    double nutritionPercentage = nutritionsListSize > 0
        ? (nutritionCompleted + nutritionNotPermittedCompleted) /
            nutritionsListSize
        : 0;
    double examsPercentage =
        examsListSize > 0 ? examsCompleted / examsListSize : 0;
    final Map<String, Object> routineData = {
      ROUTINE_MEDICATION_PERCENTAGE_KEY: medicationPercentage,
      ROUTINE_ACTIVITY_PERCENTAGE_KEY: activitiesPercentage,
      ROUTINE_NUTRITION_PERCENTAGE_KEY: nutritionPercentage,
      ROUTINE_EXAMS_PERCENTAGE_KEY: examsPercentage,
      ROUTINE_HOUR_COMPLETED_KEY: DateFormat('hh:mm').format(DateTime.now())
    };
    data.addAll(routineData);
    db
        .collection(ROUTINES_COLLECTION_KEY)
        .doc(currentTreatmentId)
        .collection(ROUTINES_RESULTS_KEY)
        .doc(todayFormattedDate)
        .set(data);
    saveDataCollection(
        medicationPercentage,
        activitiesPercentage,
        nutritionPercentage,
        examsPercentage,
        todayFormattedDate,
        nutritionValue,
        nutritionNPValue,
        examsValue);
  }

  int getTotalPrescriptionsSize() {
    updatePercentageProgress(onlyUpdate: true);
    return medicationsList.length +
        activitiesList.length +
        nutritionList.length +
        nutritionNoPermittedList.length +
        examsList.length;
  }

  getDataValue(double percentage) {
    if (percentage >= 80) {
      return 0;
    }
    if (percentage >= 50) {
      return 1;
    }
    if (percentage >= 25) {
      return 2;
    }
    if (percentage >= 10) {
      return 3;
    }
    return 4;
  }

  Future<void> saveDataCollection(
      double medicationPercentage,
      double activitiesPercentage,
      double nutritionPercentage,
      double examsPercentage,
      String todayFormattedDate,
      int nutritionValue,
      int nutritionNPValue,
      int examsValue) async {
    final db = FirebaseFirestore.instance;
    String? patientId = FirebaseAuth.instance.currentUser?.uid;
    var userReference = db.collection(USERS_COLLECTION_KEY).doc(patientId);
    final lastSurveySnapshot = await userReference
        .collection(
            SURVEY_COLLECTION_KEY) //TODO: REFACTOR THIS! THE SURVEY LIST CAN GROW A LOT
        .orderBy(SURVEY_TIMESTAMP_KEY, descending: true)
        .limit(1)
        .get();
    var surveyDataDocs = lastSurveySnapshot.docs;
    var surveyData = surveyDataDocs.isEmpty
        ? {
            DATA_PREGUNTA1_KEY: "0",
            DATA_PREGUNTA2_KEY: "0",
            DATA_PREGUNTA3_KEY: "0",
            DATA_PREGUNTA4_KEY: "0",
            DATA_PREGUNTA5_KEY: "0",
            DATA_PREGUNTA6_KEY: "0",
          }
        : surveyDataDocs.first.data();

    // Get Userdata
    final userSnapshot = await userReference.get();
    final user.User userData = user.User.fromSnapshot(userSnapshot);
    String? birthday = userData.birthDay;
    // Get Aggregated data
    int medicationData =
        medicationsList.isEmpty ? 0 : getDataValue(medicationPercentage * 100);
    int nutritionData = getNutritionData(nutritionValue, nutritionNPValue);
    int activityData =
        activitiesList.isEmpty ? 0 : getDataValue(activitiesPercentage * 100);
    int examsData = getExamsData(examsValue);
    int smokingData = userData.smoking == "Fumo" ? 4 : 0;
    int a1 = int.parse(surveyData[DATA_PREGUNTA1_KEY]);
    int a2 = int.parse(surveyData[DATA_PREGUNTA2_KEY]);
    int a3 = int.parse(surveyData[DATA_PREGUNTA3_KEY]);
    int a4 = int.parse(surveyData[DATA_PREGUNTA4_KEY]);
    int a5 = int.parse(surveyData[DATA_PREGUNTA5_KEY]);
    int a6 = int.parse(surveyData[DATA_PREGUNTA6_KEY] ?? "0");
    int sumData = smokingData +
        a1 +
        a2 +
        a3 +
        a4 +
        a5 +
        a6 +
        medicationData +
        nutritionData +
        activityData +
        examsData;
    double adherenceData = 1 - (sumData / 36);
    Map<String, dynamic> dataToAdd = {
      DATA_EDAD_KEY: isNotEmtpy(birthday)
          ? AgeCalculator.age(DateFormat.yMMMMd("en_US").parse(birthday!)).years
          : 0, //TODO: Review format of birthday
      DATA_SEXO_KEY: userData.gender,
      DATA_ESTADO_CIVIL_KEY: userData.civilStatus,
      DATA_NIVEL_EDUCACIONAL_KEY: userData.educationalLevel,
      DATA_FUMA_KEY: smokingData,
      DATA_PREGUNTA1_KEY: a1,
      DATA_PREGUNTA2_KEY: a2,
      DATA_PREGUNTA3_KEY: a3,
      DATA_PREGUNTA4_KEY: a4,
      DATA_PREGUNTA5_KEY: a5,
      DATA_PREGUNTA6_KEY: a6,
      DATA_MEDICACION_KEY: medicationData,
      DATA_ALIMENTACION_KEY: nutritionData,
      DATA_ACTIVIDAD_FISICA_KEY: activityData,
      DATA_EXAMENES_KEY: examsData,
      DATA_SUMA_KEY: sumData,
      DATA_ADHERENCIA_KEY: adherenceData,
      TREATMENT_ID_KEY: currentTreatmentId,
    };
    db
        .collection(DATA_COLLECTION_KEY)
        .doc("$currentTreatmentId-$todayFormattedDate")
        .set(dataToAdd);
    db
        .collection(BAR_CHART_COLLECTION_KEY)
        .doc("$currentTreatmentId-$todayFormattedDate")
        .set({
      DATA_ADHERENCIA_KEY: adherenceData,
      PATIENT_ID_KEY: patientId,
      DATA_TIMESTAMP_KEY: DateTime.now().millisecondsSinceEpoch,
      ROUTINE_MEDICATION_PERCENTAGE_KEY: medicationPercentage,
      ROUTINE_NUTRITION_PERCENTAGE_KEY: nutritionPercentage,
      ROUTINE_ACTIVITY_PERCENTAGE_KEY: activitiesPercentage,
      ROUTINE_EXAMS_PERCENTAGE_KEY: examsPercentage,
    });
    db
        .collection(USERS_COLLECTION_KEY)
        .doc(patientId)
        .update({ADHERENCE_LEVEL_KEY: adherenceData});
  }

  getNutritionData(int nutritionValue, int nutritionNPValue) {
    int nutritionTotal = nutritionList.length - nutritionValue;
    double nutritionPercentage =
        nutritionList.isNotEmpty ? nutritionTotal / nutritionList.length : 0;
    int nutritionDataValue =
        getNutritionOrExamDataValue(nutritionPercentage * 100);
    int nutritionNotPermitteDataValue = getNutritionOrExamDataValue(
        (nutritionNoPermittedList.isNotEmpty
                ? nutritionNPValue / nutritionNoPermittedList.length
                : 0) *
            100);
    int finalValue = nutritionDataValue + nutritionNotPermitteDataValue;
    return finalValue ~/ 2;
  }

  getExamsData(int examsValue) {
    int examsTotal = examsList.length - examsValue;
    double examsPercentage =
        examsList.isNotEmpty ? examsTotal / examsList.length : 0;
    return getNutritionOrExamDataValue(examsPercentage * 100);
  }

  int getNutritionOrExamDataValue(double nutritionPercentage) {
    if (nutritionPercentage >= 80) {
      return 2;
    }
    if (nutritionPercentage >= 50) {
      return 1;
    }
    return 0;
  }

  String getTodayFormattedDate() {
    return DateFormat('dd-MMM-yyyy').format(DateTime.now());
  }

  void initAllData() {
    medicationPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                medicationsList = value;
                for (int i = 0; i < medicationsList.length; i++) {
                  int? newState = previousResults[medicationsList[i].name];
                  medicationsList[i].state = newState == -1 ? null : newState;
                }
                totalPrescriptions = getTotalPrescriptionsSize();
              })
            }
        });
    nutritionPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                nutritionList = [];
                nutritionNoPermittedList = [];
                for (int i = 0; i < value.length; i++) {
                  int? newState = previousResults[value[i].name];
                  value[i].state = newState == -1 ? null : newState;
                  if (value[i].permitted == YES_KEY) {
                    nutritionList.add(value[i]);
                  } else {
                    nutritionNoPermittedList.add(value[i]);
                  }
                  totalPrescriptions = getTotalPrescriptionsSize();
                }
              })
            }
        });
    activityPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                activitiesList = value;
                for (int i = 0; i < activitiesList.length; i++) {
                  int? newState = previousResults[activitiesList[i].name];
                  activitiesList[i].state = newState == -1 ? null : newState;
                }
                totalPrescriptions = getTotalPrescriptionsSize();
              })
            }
        });
    examsPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                examsList = value;
                for (int i = 0; i < examsList.length; i++) {
                  int? newState = previousResults[examsList[i].name];
                  examsList[i].state = newState == -1 ? null : newState;
                }
                totalPrescriptions = getTotalPrescriptionsSize();
              })
            }
        });
  }

  Future<Map<String, int>> getPreviousResults() async {
    Map<String, int> resultMap = {};
    try {
      final db = FirebaseFirestore.instance;
      var results = await db
          .collection(ROUTINES_COLLECTION_KEY)
          .doc(currentTreatmentId)
          .collection(ROUTINES_RESULTS_KEY)
          .doc(getTodayFormattedDate())
          .get();
      var data = results.data();
      if (data != null && data.isNotEmpty) {
        for (String key in data.keys) {
          if (key == ROUTINE_EXAM_GLUCOSA_LEVEL) {
            examsGlucosaLevelValue = data[key];
          } else if (key != ROUTINE_HOUR_COMPLETED_KEY) {
            resultMap.addAll({key: data[key].toInt()});
          }
        }
      }
    } catch (e) {}
    return resultMap;
  }
}
