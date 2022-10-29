import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/Constants.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/screens/add_treatment_screen.dart';
import 'package:near_you/screens/home_screen.dart';
import 'package:near_you/screens/patient_detail_screen.dart';
import 'package:near_you/screens/visualize_prescription_screen.dart';
import 'package:near_you/widgets/static_components.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../common/adherence_prediction.dart';
import '../model/user.dart' as user;
import '../widgets/grouped_bar_chart.dart';

class PatientDetail extends StatefulWidget {
  final bool isDoctorView;
  user.User? detailedUser;

  PatientDetail(this.detailedUser, {required this.isDoctorView});

  factory PatientDetail.forDoctorView(user.User? paramUser) {
    return PatientDetail(
      paramUser,
      isDoctorView: true,
    );
  }

  factory PatientDetail.forPatientView(user.User? paramUser) {
    return PatientDetail(
      paramUser,
      isDoctorView: false,
    );
  }

  @override
  PatientDetailState createState() =>
      PatientDetailState(this.detailedUser, this.isDoctorView);
}

class PatientDetailState extends State<PatientDetail> {
  static StaticComponents staticComponents = StaticComponents();
  user.User? detailedUser;
  Treatment? currentTreatment;
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  bool isDoctorView;
  late final Future<Treatment> currentTreatmentFuture;
  late final Future<int> predictionFuture;
  late final Future<List<BarCharData>> barchartDataFuture;
  late final Future<List<String>> medicationFuture;
  late final Future<List<String>> activityFuture;
  late final Future<List<String>> nutritionFuture;
  late final Future<List<String>> examnFuture;
  int medicationCounter = 0;
  int activityCounter = 0;
  int nutritionCounter = 0;
  int examnCounter = 0;

  String? durationTypeValue;
  String? durationValue;
  String? stateValue;
  String? descriptionValue;
  String? startDateValue;
  String? endDateValue;
  List<String> medicationsList = <String>[];
  List<String> nutritionList = <String>[];
  List<String> activitiesList = <String>[];
  List<String> examnList = <String>[];
  int barChartPeriodIndex = 0;

  List<BarCharData>? barcharListGlobal;

  List<BarCharData> dailySeriesAdherence = <BarCharData>[];
  List<BarCharData> weeklySeriesAdherence = <BarCharData>[];
  List<BarCharData> monthlySeriesAdherence = <BarCharData>[];
  List<BarCharData> annualSeriesAdherence = <BarCharData>[];
  List<int> periodMedicationPercentages = List.filled(4, 0);
  List<int> periodNutritionPercentages = List.filled(4, 0);
  List<int> periodActivityPercentages = List.filled(4, 0);
  List<int> periodExamsPercentages = List.filled(4, 0);
  List<int> periodAdherences = List.filled(4, 0);

  int todayAdherence = 0;

  int adherencePrediction = 0;

  PatientDetailState(this.detailedUser, this.isDoctorView);

  get blueIndicator => Expanded(
          child: SizedBox(
        height: 6,
        child: Center(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
                color: const Color(0xff2F8F9D),
                borderRadius: BorderRadius.circular(5),
                shape: BoxShape.rectangle),
          ),
        ),
      ));

  get grayIndicator => Expanded(
          child: SizedBox(
        height: 6,
        child: Center(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
                color: Color(0xffCCD6DD),
                borderRadius: BorderRadius.circular(5),
                shape: BoxShape.rectangle),
          ),
        ),
      ));

  @override
  void initState() {
    predictionFuture = AdherencePrediction.getPrediction(detailedUser!);
    barchartDataFuture = getAdherenceHistory();
    currentTreatmentFuture =
        getCurrentTReatmentById(detailedUser!.currentTreatment!);
    medicationFuture =
        getMedicationPrescriptions(detailedUser!.currentTreatment!);
    activityFuture = getActivityPrescriptions(detailedUser!.currentTreatment!);
    nutritionFuture =
        getNutritionPrescriptions(detailedUser!.currentTreatment!);
    examnFuture = getExamsPrescriptions(detailedUser!.currentTreatment!);
    predictionFuture.then((value) => {
          setState(() {
            adherencePrediction = value;
          })
        });
    barchartDataFuture.then((value) => {
          setState(() {
            barcharListGlobal = value;
            updateBarCharSeries();
          })
        });
    currentTreatmentFuture.then((value) => {
          setState(() {
            currentTreatment = value;
            durationTypeValue = currentTreatment!.durationType;
            durationValue = currentTreatment!.durationNumber;
            stateValue = currentTreatment!.state;
            descriptionValue = currentTreatment!.description;
            startDateValue = currentTreatment!.startDate;
            endDateValue = currentTreatment!.endDate;
          })
        });
    medicationFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                medicationsList = value;
                if (value.isNotEmpty) medicationCounter = 1;
              })
            }
        });

    activityFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                activitiesList = value;
                if (value.isNotEmpty) activityCounter = 1;
              })
            }
        });

    nutritionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                nutritionList = value;
                if (value.isNotEmpty) nutritionCounter = 1;
              })
            }
        });

    examnFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                examnList = value;
                if (value.isNotEmpty) examnCounter = 1;
              })
            }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: getPatientHeight(),
      width: screenWidth,
      child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: 3,
          itemBuilder: (ctx, i) => getCurrentPageByIndex(ctx, i)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  getCurrentPageByIndex(BuildContext ctx, int i) {
    switch (i) {
      case 0:
        return getAdherencePage();
      case 1:
        return getCurrentTreatment();
      case 2:
        return getTreatmentHistory();
    }
  }

  void goBack() {
    _pageController.animateToPage(
      --_currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void goAhead() {
    _pageController.animateToPage(
      ++_currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  getAdherencdePage() {
    return Card(
      elevation: 10,
      shadowColor: Colors.black,
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: SizedBox(
        width: 400,
        height: 580,
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(
                  height: HomeScreen.screenHeight * 0.15,
                ),
                // TODO: Review this to get pinned at bottom
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      blueIndicator,
                      grayIndicator,
                      grayIndicator
                    ])
              ],
            )

            //Column
            ), //Padding
      ), //SizedBox
    );
  }

  getAdherencePage() {
    return Card(
      elevation: 10,
      shadowColor: Colors.black,
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: SizedBox(
        width: 400,
        height: 580,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
                  Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Color(0xff2F8F9D)),
                        onPressed: () {
                          goBack();
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 40, right: 40),
                        //apply padding to all four sides
                        child: Text(
                          'Adherencia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2F8F9D),
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.arrow_forward, color: Color(0xff2F8F9D)),
                        onPressed: () {
                          goAhead();
                        },
                      )
                    ]),
                const SizedBox(
                  height: 10,
                ),
                getAdherencePageOrEmptyState()
              ]),
              const SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    blueIndicator,
                    grayIndicator,
                    grayIndicator
                  ]),

              //SizedBox
            ],
          ), //Column
        ), //Padding
      ), //SizedBox
    );
  }

  getCurrentTreatment() {
    return FutureBuilder(
        future: currentTreatmentFuture,
        builder: (context, AsyncSnapshot<Treatment> snapshot) {
          if (!snapshot.hasData && isNotEmpty(detailedUser!.currentTreatment)) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Card(
              elevation: 10,
              shadowColor: Colors.black,
              margin: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: SizedBox(
                width: 400,
                height: 580,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.arrow_back,
                                        color: Color(0xff2F8F9D)),
                                    onPressed: () {
                                      goBack();
                                    },
                                  ),
                                  const Text(
                                    'Consulta Actual',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff2F8F9D),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward,
                                        color: Color(0xff2F8F9D)),
                                    onPressed: () {
                                      goAhead();
                                    },
                                  )
                                ]),
                            const SizedBox(
                              height: 10,
                            ),
                            getCurrentTreatmentOrEmptyState()
                          ]),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            grayIndicator,
                            blueIndicator,
                            grayIndicator
                          ]),

                      //SizedBox
                    ],
                  ), //Column
                ), //Padding
              ), //SizedBox
            );
          }
        });
  }

  getTreatmentHistory() {
    return Card(
      elevation: 10,
      shadowColor: Colors.black,
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: SizedBox(
        width: 400,
        height: 580,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: Color(0xff2F8F9D)),
                            onPressed: () {
                              goBack();
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 15),
                            //apply padding to all four sides
                            child: Text(
                              'Historial del Tratamiento',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff2F8F9D),
                              ),
                            ),
                          ),
                        ]),
                    //TODO: to review later
                    SizedBox(
                      height: getScreenHeight(),
                      //  child: ListViewHomeLayout()
                    )
                  ]),
              const SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    grayIndicator,
                    grayIndicator,
                    blueIndicator
                  ]),

              //SizedBox
            ],
          ), //Column
        ), //Padding
      ), //SizedBox
    );
  }

  getTreatmentButtons() {
    return isDoctorView
        ? Container(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(
                        height: 17,
                      ),
                      SizedBox(
                        height: 27,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          color: const Color(0xff2F8F9D),
                          textColor: Colors.white,
                          onPressed: () {
                            goToAddTreatment(false);
                          },
                          child: const Text(
                            'Agregar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      FlatButton(
                        height: 27,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                color: Color(0xff9D9CB5),
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(30)),
                        textColor: const Color(0xff9D9CB5),
                        onPressed: () {
                          goToAddTreatment(true);
                        },
                        child: const Text(
                          'Actualizar',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: 27,
                          child: FlatButton(
                            height: 27,
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(30)),
                            textColor: const Color(0xff9D9CB5),
                            onPressed: () {
                              deleteCurrentTreatment();
                            },
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                    ])),
          )
        : SizedBox(height: 0);
  }

  getCurrentTreatmentOrEmptyState() {
    var hasCurrentTreatment = isNotEmpty(detailedUser?.currentTreatment);
    bool isPatient = !isDoctorView;
    if (hasCurrentTreatment) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        width: double.infinity,
        height: getScreenHeight(),
        child: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 200,
                ),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.only(
                                  top: 5, left: 15, right: 15, bottom: 5),
                              decoration: BoxDecoration(
                                  color: const Color(0xff9D9CB5),
                                  border: Border.all(
                                      width: 1, color: const Color(0xff9D9CB5)),
                                  borderRadius: BorderRadius.circular(5),
                                  shape: BoxShape.rectangle),
                              child: Text(
                                "ID Tratamiento",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              )),
                          Container(
                              padding: EdgeInsets.only(
                                  top: 5, left: 15, right: 15, bottom: 5),
                              decoration: BoxDecoration(
                                  color: const Color(0xff2F8F9D),
                                  border: Border.all(
                                      width: 1, color: const Color(0xff2F8F9D)),
                                  borderRadius: BorderRadius.circular(5),
                                  shape: BoxShape.rectangle),
                              child: Text(
                                "#T00003",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14),
                              ))
                        ]),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fecha de inicio",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        height: 35,
                        child: TextField(
                          readOnly: true,
                          controller:
                              TextEditingController(text: startDateValue),
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff999999)),
                          decoration: InputDecoration(
                              filled: true,
                              prefixIcon: IconButton(
                                padding: EdgeInsets.only(bottom: 5),
                                onPressed: () {},
                                icon: const Icon(Icons.calendar_today_outlined,
                                    color: Color(
                                        0xff999999)), // myIcon is a 48px-wide widget.
                              ),
                              fillColor: Color(0xffF1F1F1),
                              hintText: '18 - Jul 2022  15:00',
                              hintStyle: const TextStyle(
                                  fontSize: 14, color: Color(0xff999999)),
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: staticComponents.littleInputBorder,
                              border: staticComponents.littleInputBorder,
                              focusedBorder:
                                  staticComponents.littleInputBorder),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Fecha de fin",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        height: 35,
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(text: endDateValue),
                          style:
                              TextStyle(fontSize: 14, color: Color(0xff999999)),
                          decoration: InputDecoration(
                              filled: true,
                              prefixIcon: IconButton(
                                padding: EdgeInsets.only(bottom: 5),
                                onPressed: () {},
                                icon: const Icon(Icons.calendar_today_outlined,
                                    color: Color(
                                        0xff999999)), // myIcon is a 48px-wide widget.
                              ),
                              fillColor: Color(0xffF1F1F1),
                              hintText: '18 - Jul 2022  15:00',
                              hintStyle: const TextStyle(
                                  fontSize: 14, color: Color(0xff999999)),
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: staticComponents.littleInputBorder,
                              border: staticComponents.littleInputBorder,
                              focusedBorder:
                                  staticComponents.littleInputBorder),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Duración",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        height: 35,
                        child: TextField(
                          readOnly: true,
                          controller: TextEditingController(
                              text: currentTreatment != null
                                  ? '${durationValue} ${durationTypeValue}'
                                  : ''),
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF999999)),
                          decoration:
                              staticComponents.getLittleInputDecoration(''),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    /*  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Estado",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ), */
                    /* SizedBox(
                        height: 35,
                        child: TextField(
                          controller: TextEditingController(text: stateValue),
                          readOnly: true,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF999999)),
                          decoration: staticComponents
                              .getLittleInputDecoration('Activo'),
                        )),
                    const SizedBox(
                      height: 10,
                    ), */
                    /* Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Descripción 1/1",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ), */
                    /* TextField(
                      minLines: 1,
                      maxLines: 10,
                      readOnly: true,
                      controller: TextEditingController(text: descriptionValue),
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF999999)),
                      decoration: staticComponents.getLittleInputDecoration(
                          'Tratamiento de de la diabetes\n con 6 meses de pre...'),
                    ), */
                    /*  const SizedBox(
                      height: 30,
                    ), */
                    medicationCounter +
                                activityCounter +
                                nutritionCounter +
                                examnCounter >
                            0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                                Container(
                                    padding: EdgeInsets.only(
                                        top: 5, left: 15, right: 15, bottom: 5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xff9D9CB5),
                                        border: Border.all(
                                            width: 1,
                                            color: const Color(0xff9D9CB5)),
                                        borderRadius: BorderRadius.circular(5),
                                        shape: BoxShape.rectangle),
                                    child: Text(
                                      "Prescripciones",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14),
                                    ))
                              ])
                        : SizedBox(
                            height: 0,
                          ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            "Prescripción ${medicationCounter + activityCounter + nutritionCounter + examnCounter}/4",
                            style: TextStyle(
                                fontSize: 15,
                                color: Color(0xff2F8F9D),
                                fontWeight: FontWeight.w600))
                      ],
                    ),
                    getMedicationTreatmentCard(),
                    getNutritionTreatmentCard(),
                    getActivityTreatmentCard(),
                    getExamnTreatmentCard(),
                    //getOtherTreatmentCard(),
                    getTreatmentButtons()
                  ],
                ))),
      );
    } else {
      return getEmptyStateCard(
          'Aún no se tiene un\n tratamiento actual creado\n para este paciente. Haga\n click en agregar',
          !isPatient);
    }
  }

  getMedicationTreatmentCard() {
    return FutureBuilder(
      future: medicationFuture,
      builder: (context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (medicationsList.isEmpty) {
            return staticComponents.emptyBox;
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizePrescriptionScreen(
                        detailedUser!.currentTreatment!, 0),
                  ));
            },
            child: Card(
                color: Color(0xffF1F1F1),
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: ClipPath(
                  child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Color(0xff2F8F9D), width: 5))),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 5, right: 12),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Medicación",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    )
                                  ])),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, top: 7, bottom: 7),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        medicationsList.length >
                                                                3
                                                            ? 3
                                                            : medicationsList
                                                                .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                        medicationsList[index],
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      );
                                                    }))
                                          ]),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Container(
                                            width: 24,
                                            height: 24,
                                            child: Icon(Icons.chevron_right,
                                                color: Color(0xff2F8F9D))))
                                  ]))
                          //SizedBox
                        ],
                      )),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                )),
          );
        }
        return CircularProgressIndicator();
      },
    );

    /*return SizedBox(
      height: 0,
    );*/
  }

  getNutritionTreatmentCard() {
    return FutureBuilder(
      future: nutritionFuture,
      builder: (context, AsyncSnapshot snapshot) {
        //patientUser = user.User.fromSnapshot(snapshot.data);
        if (snapshot.connectionState == ConnectionState.done) {
          if (nutritionList.isEmpty) {
            return staticComponents.emptyBox;
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizePrescriptionScreen(
                        detailedUser!.currentTreatment!, 1),
                  ));
            },
            child: Card(
                color: Color(0xffF1F1F1),
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: ClipPath(
                  child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Color(0xff2F8F9D), width: 5))),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 5, right: 12),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Alimentación",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    )
                                  ])),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, top: 7, bottom: 7),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        nutritionList.length > 3
                                                            ? 3
                                                            : nutritionList
                                                                .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                        nutritionList[index],
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      );
                                                    }))
                                          ]),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Container(
                                            width: 24,
                                            height: 24,
                                            child: Icon(Icons.chevron_right,
                                                color: Color(0xff2F8F9D))))
                                  ]))
                          //SizedBox
                        ],
                      )),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                )),
          );
        }
        return CircularProgressIndicator();
      },
    );
    /*
    return SizedBox(
      height: 0,
    );*/
  }

  getExamnTreatmentCard() {
    return FutureBuilder(
      future: examnFuture,
      builder: (context, AsyncSnapshot snapshot) {
        //patientUser = user.User.fromSnapshot(snapshot.data);
        if (snapshot.connectionState == ConnectionState.done) {
          if (examnList.isEmpty) {
            return staticComponents.emptyBox;
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizePrescriptionScreen(
                        detailedUser!.currentTreatment!, 3),
                  ));
            },
            child: Card(
                color: Color(0xffF1F1F1),
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: ClipPath(
                  child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Color(0xff2F8F9D), width: 5))),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 5, right: 12),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Exámenes",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    )
                                  ])),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, top: 7, bottom: 7),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        examnList.length > 3
                                                            ? 3
                                                            : examnList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                        examnList[index],
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      );
                                                    }))
                                          ]),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Container(
                                            width: 24,
                                            height: 24,
                                            child: Icon(Icons.chevron_right,
                                                color: Color(0xff2F8F9D))))
                                  ]))
                          //SizedBox
                        ],
                      )),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                )),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  getActivityTreatmentCard() {
    return FutureBuilder(
      future: activityFuture,
      builder: (context, AsyncSnapshot snapshot) {
        //patientUser = user.User.fromSnapshot(snapshot.data);
        if (snapshot.connectionState == ConnectionState.done) {
          if (activitiesList.isEmpty) {
            return staticComponents.emptyBox;
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VisualizePrescriptionScreen(
                        detailedUser!.currentTreatment!, 2),
                  ));
            },
            child: Card(
                color: Color(0xffF1F1F1),
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: ClipPath(
                  child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                          border: Border(
                              left: BorderSide(
                                  color: Color(0xff2F8F9D), width: 5))),
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, top: 5, right: 12),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Actividad Física",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    )
                                  ])),
                          Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, top: 7, bottom: 7),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                                height: 40,
                                                child: ListView.builder(
                                                    padding: EdgeInsets.zero,
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount: activitiesList
                                                                .length >
                                                            3
                                                        ? 3
                                                        : activitiesList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Text(
                                                        activitiesList[index],
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xff67757F),
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      );
                                                    }))
                                          ]),
                                    ),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: Container(
                                            width: 24,
                                            height: 24,
                                            child: Icon(Icons.chevron_right,
                                                color: Color(0xff2F8F9D))))
                                  ]))
                          //SizedBox
                        ],
                      )),
                  clipper: ShapeBorderClipper(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3))),
                )),
          );
        }
        return CircularProgressIndicator();
      },
    );
    /*
    return SizedBox(
      height: 0,
    );*/
  }

  getEmptyStateCard(String message, bool showButton) {
    return Container(
      width: double.infinity,
      height: 470,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 200,
                ),
                Text(
                  showButton
                      ? message
                      : 'No cuentas con un \ntratamiento actual',
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff999999),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                showButton
                    ? SizedBox(
                        height: 27,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          color: const Color(0xff2F8F9D),
                          textColor: Colors.white,
                          onPressed: () {
                            goToAddTreatment(false);
                          },
                          child: const Text(
                            'Agregar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
                const SizedBox(
                  height: 10,
                ),
              ])),
    );
  }

  void goToAddTreatment(bool update) {
    Navigator.push(
      context,
      MaterialPageRoute(
        //TODO: Review this
        builder: (context) => AddTreatmentScreen(
            detailedUser!.userId!, update ? currentTreatment : null),
      ),
    );
  }

  void deleteCurrentTreatment() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          //Center Row contents horizontally,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(alignment: WrapAlignment.center, children: [
              AlertDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(const Radius.circular(10))),
                  content: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      SvgPicture.asset(
                        'assets/images/warning_icon.svg',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('¿Desea eliminar el tratamiento\n actual?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(
                              height: 17,
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.all(15),
                              color: const Color(0xff3BACB6),
                              textColor: Colors.white,
                              onPressed: () {
                                deleteCurrentTreatmentById();
                              },
                              child: const Text(
                                'Si, Eliminar',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: const BorderSide(
                                      color: Color(0xff9D9CB5),
                                      width: 1,
                                      style: BorderStyle.solid)),
                              padding: const EdgeInsets.all(15),
                              color: Colors.white,
                              textColor: const Color(0xff9D9CB5),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            )
                          ])
                    ],
                  ))
            ])
          ],
        );
      },
    );
  }

  Future<Treatment> getCurrentTReatmentById(String currentTreatment) async {
    final db = FirebaseFirestore.instance;
    var future =
        await db.collection(TREATMENTS_KEY).doc(currentTreatment).get();
    return Treatment.fromSnapshot(future);
  }

  Future<void> deleteCurrentTreatmentById() async {
    Navigator.pop(context);
    final db = FirebaseFirestore.instance;
    await db
        .collection(TREATMENTS_KEY)
        .doc(detailedUser!.currentTreatment)
        .delete()
        //.onError((error, stackTrace) => )
        .whenComplete(() => {
              db
                  .collection(USERS_COLLECTION_KEY)
                  .doc(detailedUser!.userId)
                  .update({
                PATIENT_CURRENT_TREATMENT_KEY: EMPTY_STRING_VALUE
              }).whenComplete(() => showSuccessDeleteDialog())
            });
  }

  showSuccessDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          //Center Row contents horizontally,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(alignment: WrapAlignment.center, children: [
              AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  content: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Operación\nExitosa',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Se eliminó correctamente el\ntratamiento.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff67757F))),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(
                              height: 17,
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.all(15),
                              color: const Color(0xff3BACB6),
                              textColor: Colors.white,
                              onPressed: () {
                                goBackScreen();
                              },
                              child: const Text(
                                'Aceptar',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ]),
                      const SizedBox(
                        height: 15,
                      )
                    ],
                  ))
            ])
          ],
        );
      },
    );
  }

  bool isNotEmpty(String? str) {
    return str != null && str != '';
  }

  void goBackScreen() {
    if (isDoctorView) {
      Navigator.pop(context);
    }
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => isDoctorView
                ? PatientDetailScreen(detailedUser!.userId!)
                : HomeScreen()));
  }

  Future<List<String>> getMedicationPrescriptions(
      String currentTreatmentId) async {
    List<String> result = <String>[];
    final db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection(MEDICATION_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatmentId)
        .get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      String currentValue = snapshot.docs[i][MEDICATION_NAME_KEY];
      result.add(currentValue);
    }
    return result;
  }

  Future<List<String>> getActivityPrescriptions(
      String currentTreatmentId) async {
    List<String> result = <String>[];
    final db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatmentId)
        .get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      String currentValue = snapshot.docs[i][ACTIVITY_NAME_KEY];
      result.add(currentValue);
    }
    return result;
  }

  Future<List<String>> getNutritionPrescriptions(
      String currentTreatmentId) async {
    List<String> result = <String>[];
    final db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatmentId)
        .get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      String currentValue = snapshot.docs[i][NUTRITION_NAME_KEY];
      result.add(currentValue);
    }
    return result;
  }

  Future<List<String>> getExamsPrescriptions(String currentTreatmentId) async {
    List<String> result = <String>[];
    final db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection(EXAMS_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatmentId)
        .get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      String currentValue = snapshot.docs[i][EXAMN_NAME_KEY];
      result.add(currentValue);
    }
    return result;
  }

  getGradientColors(int percentage, [bool? inverted]) {
    var redList = <Color>[
      Color(0xff9D2F2F),
      Color(0xffE72A2A),
      Color(0xff9D2F2F)
    ];
    var blueList = <Color>[
      Color(0xff2F8F9D),
      Color(0xff47B4AC),
      Color(0xff2F8F9D)
    ];
    if (percentage >= 80) {
      return inverted != null && inverted ? blueList : redList;
    }
    return inverted != null && inverted ? redList : blueList;
  }

  String getAdherenceMessage() {
    if (adherencePrediction >= 80) {
      return "Ten cuidado, tus niveles de abandono al tratamiento son altos";
    }
    return "¡Sigue así con tu tratamiento!";
  }

  getColoredTriangle(int percentage) {
    if (percentage < 80) {
      return Image.asset(
        'assets/images/arrow_up_red.png',
        fit: BoxFit.none,
      );
    }
    return Image.asset(
      'assets/images/arrow_up_blue.png',
      fit: BoxFit.none,
    );
  }

  Future<List<BarCharData>> getAdherenceHistory() async {
    List<BarCharData> result = <BarCharData>[];
    final db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection(BAR_CHART_COLLECTION_KEY)
        .where(PATIENT_ID_KEY, isEqualTo: detailedUser?.userId)
        .get();

    for (int i = 0; i < snapshot.docs.length; i++) {
      result.add(BarCharData.fromSnapshot(snapshot.docs[i]));
    }
    result.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

    return result;
  }

  updateBarCharSeries() {
    setState(() {
      dailySeriesAdherence = getDailySeriesAdherence();
      weeklySeriesAdherence = getWeeklySeriesAdherence();
      monthlySeriesAdherence = getMonthlySeriesAdherence();
      annualSeriesAdherence = getAnnualSeriesAdherence();
    });
  }

  getBarCharView() {
    List<BarCharData> seriesData = <BarCharData>[];
    switch (barChartPeriodIndex) {
      case 0:
        seriesData = dailySeriesAdherence;
        break;
      case 1:
        seriesData = weeklySeriesAdherence;
        break;
      case 2:
        seriesData = monthlySeriesAdherence;
        break;
      case 3:
        seriesData = annualSeriesAdherence;
    }
    List<charts.Series<dynamic, String>> barCharSeries = [
      charts.Series<BarCharData, String>(
        id: 'Adherence',
        labelAccessorFn: (BarCharData barChartData, _) =>
            '${((barChartData.adherence ?? 0) * 100).toInt()}%',
        domainFn: (BarCharData barChartData, _) => barChartData.dateLabel!,
        measureFn: (BarCharData barChartData, _) => barChartData.adherence,
        colorFn: (ordinary, __) {
          if (ordinary.adherence! >= 80) {
            return charts.Color.fromHex(code: "#DCF0EF");
          }
          return charts.Color.fromHex(code: "#2F8F9D");
        },
        insideLabelStyleAccessorFn: (BarCharData barChartData, _) {
          final color = ((barChartData.adherence ?? 0) >= 0.8)
              ? charts.Color.fromHex(code: "#6EC6A4")
              : charts.Color.fromHex(code: "#F8191E");
          return charts.TextStyleSpec(color: color, fontSize: 10);
        },
        outsideLabelStyleAccessorFn: (BarCharData barChartData, _) {
          final color = ((barChartData.adherence ?? 0) >= 0.8)
              ? charts.Color.fromHex(code: "#6EC6A4")
              : charts.Color.fromHex(code: "#F8191E");
          return charts.TextStyleSpec(color: color, fontSize: 10);
        },
        data: seriesData,
      ),
    ];

    return GroupedBarChart(barCharSeries, animate: true);
  }

  List<BarCharData> getDailySeriesAdherence() {
    List<BarCharData> result = <BarCharData>[];
    DateTime today = DateTime.now();
    int firstIndex = 0;
    if ((barcharListGlobal?.length ?? 0) > 7) {
      firstIndex = (barcharListGlobal?.length ?? 7) - 7;
    }
    for (int i = 0; i < daysList.length; i++) {
      BarCharData currentBarChart = BarCharData(
          dateTime: null,
          medicationPercentage: null,
          nutritionPercentage: null,
          activitiesPercentage: null,
          examsPercentage: null);
      currentBarChart.dateLabel = daysList[i];
      currentBarChart.adherence = 0;
      result.add(currentBarChart);
    }
    double medicationSum = 0;
    double nutritionSum = 0;
    double activitiesSum = 0;
    double examsSum = 0;
    double adherenceTotalSum = 0;
    int cantCounter = 0;
    bool firstFound = false;
    DateTime? firstRangeDate;
    for (int i = firstIndex; i < (barcharListGlobal?.length ?? 0); i++) {
      BarCharData currentBarChart = barcharListGlobal![i];
      DateTime currentDate = currentBarChart.dateTime!;
      if (today.subtract(const Duration(days: 7)).isAfter(currentDate)) {
        continue; // skip if is invalid range
      }
      if (!firstFound) {
        firstFound = true;
        firstRangeDate = currentDate;
      }
      if (today.day == currentDate.day &&
          today.month == currentDate.month &&
          today.year == currentDate.year) {
        todayAdherence = ((currentBarChart.adherence ?? 0) * 100).toInt();
      }
      int day = currentDate.weekday - 1;
      currentBarChart.dateLabel = result[day].dateLabel;
      result[day] = currentBarChart;
      medicationSum += currentBarChart.medicationPercentage ?? 0;
      nutritionSum += currentBarChart.nutritionPercentage ?? 0;
      activitiesSum += currentBarChart.activitiesPercentage ?? 0;
      examsSum += currentBarChart.examsPercentage ?? 0;
      adherenceTotalSum += currentBarChart.adherence ?? 0;
    }
    if (firstFound) {
      cantCounter = daysBetween(firstRangeDate!, today);
    }
    periodMedicationPercentages[0] =
        ((cantCounter > 0 ? medicationSum / cantCounter : 0) * 100).toInt();
    periodNutritionPercentages[0] =
        ((cantCounter > 0 ? nutritionSum / cantCounter : 0) * 100).toInt();
    periodActivityPercentages[0] =
        ((cantCounter > 0 ? activitiesSum / cantCounter : 0) * 100).toInt();
    periodExamsPercentages[0] =
        ((cantCounter > 0 ? examsSum / cantCounter : 0) * 100).toInt();
    periodAdherences[0] =
        ((cantCounter > 0 ? adherenceTotalSum / cantCounter : 0) * 100).toInt();

    int todayIndex = today.weekday;
    if (todayIndex == DateTime.sunday) return result;

    List<BarCharData> finalResult = <BarCharData>[];
    for (int i = todayIndex; i < result.length; i++) {
      finalResult.add(result[i]);
    }
    for (int i = 0; i < todayIndex; i++) {
      finalResult.add(result[i]);
    }
    return finalResult;
  }

  List<BarCharData> getWeeklySeriesAdherence() {
    List<BarCharData> result = <BarCharData>[];
    DateTime today = DateTime.now();
    int firstIndex = 0;

    if ((barcharListGlobal?.length ?? 0) > 30) {
      firstIndex = barcharListGlobal?.length ?? 30 - 30;
    }
    for (int i = 0; i < weeksList.length; i++) {
      BarCharData currentBarChart = BarCharData(
          dateTime: null,
          medicationPercentage: null,
          nutritionPercentage: null,
          activitiesPercentage: null,
          examsPercentage: null);
      currentBarChart.dateLabel = weeksList[i];
      currentBarChart.adherence = 0;
      result.add(currentBarChart);
    }
    double sum1 = 0;
    int cant1 = 0;
    double sum2 = 0;
    int cant2 = 0;
    int cant3 = 0;
    int cant4 = 0;
    double sum3 = 0;
    double sum4 = 0;
    double medicationSum = 0;
    double nutritionSum = 0;
    double activitiesSum = 0;
    double adherenceTotalSum = 0;
    double examsSum = 0;
    int cantCounter = 0;
    bool firstFound = false;
    DateTime? firstRangeDate;
    bool firstWeek1 = false;
    bool firstWeek2 = false;
    bool firstWeek3 = false;
    bool firstWeek4 = false;
    DateTime? firstRange1;
    DateTime? firstRange2;
    DateTime? firstRange3;
    DateTime? firstRange4;

    for (int i = firstIndex; i < (barcharListGlobal?.length ?? 0); i++) {
      BarCharData currentBarChart = barcharListGlobal![i];
      DateTime currentDate = currentBarChart.dateTime!;
      if (today.subtract(const Duration(days: 30)).isAfter(currentDate)) {
        continue; // skip if is invalid range
      }
      if (!firstFound) {
        firstFound = true;
        firstRangeDate = currentDate;
      }
      int day = currentDate.day;
      double currentAdherence = currentBarChart.adherence!;
      if (day > 7 && day <= 15) {
        cant2++;
        sum2 += currentAdherence;
        if (!firstWeek2) {
          firstWeek2 = true;
          firstRange2 = currentDate;
        }
      } else if (day > 15 && day <= 21) {
        cant3++;
        sum3 += currentAdherence;
        if (!firstWeek3) {
          firstWeek3 = true;
          firstRange3 = currentDate;
        }
      } else if (day > 21) {
        cant4++;
        sum4 += currentAdherence;
        if (!firstWeek4) {
          firstWeek4 = true;
          firstRange4 = currentDate;
        }
      } else {
        cant1++;
        sum1 += currentAdherence;
        if (!firstWeek1) {
          firstWeek1 = true;
          firstRange1 = currentDate;
        }
      }
      medicationSum += currentBarChart.medicationPercentage ?? 0;
      nutritionSum += currentBarChart.nutritionPercentage ?? 0;
      activitiesSum += currentBarChart.activitiesPercentage ?? 0;
      examsSum += currentBarChart.examsPercentage ?? 0;
      adherenceTotalSum += currentBarChart.adherence ?? 0;
    }
    if (firstFound) {
      cantCounter = daysBetween(firstRangeDate!, today);
    }
    periodMedicationPercentages[1] =
        ((cantCounter > 0 ? medicationSum / cantCounter : 0) * 100).toInt();
    periodNutritionPercentages[1] =
        ((cantCounter > 0 ? nutritionSum / cantCounter : 0) * 100).toInt();
    periodActivityPercentages[1] =
        ((cantCounter > 0 ? activitiesSum / cantCounter : 0) * 100).toInt();
    periodExamsPercentages[1] =
        ((cantCounter > 0 ? examsSum / cantCounter : 0) * 100).toInt();
    periodAdherences[1] =
        ((cantCounter > 0 ? adherenceTotalSum / cantCounter : 0) * 100).toInt();

    int todayDay = today.day;
    if (todayDay > 7 && todayDay <= 15 && firstWeek2) {
      cant2 = daysBetween(firstRange2, today);
    } else if (todayDay > 15 && todayDay <= 21 && firstWeek3) {
      cant3 = daysBetween(firstRange3, today);
    } else if (todayDay > 21 && firstWeek4) {
      cant4 = daysBetween(firstRange4, today);
    } else if (firstWeek1) {
      cant1 = daysBetween(firstRange1, today);
    }

    result[0].adherence = cant1 > 0 ? sum1 / cant1 : 0;
    result[1].adherence = cant2 > 0 ? sum2 / cant2 : 0;
    result[2].adherence = cant3 > 0 ? sum3 / cant3 : 0;
    result[3].adherence = cant4 > 0 ? sum4 / cant4 : 0;
    return result;
  }

  List<BarCharData> getMonthlySeriesAdherence() {
    List<BarCharData> result = <BarCharData>[];
    DateTime today = DateTime.now();
    int firstIndex = 0;
    if ((barcharListGlobal?.length ?? 0) > 365) {
      firstIndex = barcharListGlobal?.length ?? 365 - 365;
    }
    for (int i = 0; i < monthsList.length; i++) {
      BarCharData currentBarChart = BarCharData(
          dateTime: null,
          medicationPercentage: null,
          nutritionPercentage: null,
          activitiesPercentage: null,
          examsPercentage: null);
      currentBarChart.dateLabel = monthsList[i];
      currentBarChart.adherence = 0;
      result.add(currentBarChart);
    }
    double medicationSum = 0;
    double nutritionSum = 0;
    double activitiesSum = 0;
    double examsSum = 0;
    double adherenceSum = 0;
    int cantCounter = 0;
    bool firstFound = false;
    DateTime? firstRangeDate;
    for (int i = firstIndex; i < (barcharListGlobal?.length ?? 0); i++) {
      BarCharData currentBarChart = barcharListGlobal![i];
      DateTime currentDate = currentBarChart.dateTime!;
      if (today.subtract(const Duration(days: 365)).isAfter(currentDate)) {
        continue; // skip if is invalid range
      }
      if (!firstFound) {
        firstFound = true;
        firstRangeDate = currentDate;
      }
      double sum = currentBarChart.adherence ?? 0;
      medicationSum += currentBarChart.medicationPercentage ?? 0;
      nutritionSum += currentBarChart.nutritionPercentage ?? 0;
      activitiesSum += currentBarChart.activitiesPercentage ?? 0;
      examsSum += currentBarChart.examsPercentage ?? 0;
      adherenceSum += currentBarChart.adherence ?? 0;
      int cantCounterMonth = 1;
      int month = currentDate.month;
      DateTime? firstOfMonth = currentDate;
      while (i + 1 < barcharListGlobal!.length &&
          month == barcharListGlobal![i + 1].dateTime!.month) {
        i++;
        currentBarChart = barcharListGlobal![i];
        currentDate = currentBarChart.dateTime!;
        month = currentDate.month;
        sum += currentBarChart.adherence ?? 0;
        medicationSum += currentBarChart.medicationPercentage ?? 0;
        nutritionSum += currentBarChart.nutritionPercentage ?? 0;
        activitiesSum += currentBarChart.activitiesPercentage ?? 0;
        examsSum += currentBarChart.examsPercentage ?? 0;
        adherenceSum += currentBarChart.adherence ?? 0;
        cantCounterMonth++;
      }
      if (month == today.month) {
        cantCounterMonth = daysBetween(firstOfMonth, today);
      } else {
        cantCounterMonth =
            DateTime(currentDate.year, currentDate.month + 1, 0).day;
      }
      currentBarChart = result[month - 1];
      currentBarChart.adherence =
          cantCounterMonth > 0 ? sum / cantCounterMonth : 0;
    }
    if (firstFound) {
      cantCounter = daysBetween(firstRangeDate, today);
    }
    periodMedicationPercentages[2] =
        ((cantCounter > 0 ? medicationSum / cantCounter : 0) * 100).toInt();
    periodNutritionPercentages[2] =
        ((cantCounter > 0 ? nutritionSum / cantCounter : 0) * 100).toInt();
    periodActivityPercentages[2] =
        ((cantCounter > 0 ? activitiesSum / cantCounter : 0) * 100).toInt();
    periodExamsPercentages[2] =
        ((cantCounter > 0 ? examsSum / cantCounter : 0) * 100).toInt();
    periodAdherences[2] =
        ((cantCounter > 0 ? adherenceSum / cantCounter : 0) * 100).toInt();

    return result;
  }

  List<BarCharData> getAnnualSeriesAdherence() {
    List<BarCharData> result = <BarCharData>[];
    DateTime today = DateTime.now();
    int firstIndex = 0;
    double medicationSum = 0;
    double nutritionSum = 0;
    double activitiesSum = 0;
    double examsSum = 0;
    double adherenceTotalSum = 0;
    int cantCounter = 0;
    bool firstFound = false;
    DateTime? firstRangeDate;
    for (int i = firstIndex; i < (barcharListGlobal?.length ?? 0); i++) {
      BarCharData currentBarChart = barcharListGlobal![i];
      DateTime currentDate = currentBarChart.dateTime!;
      int year = currentDate.year;
      double sum = currentBarChart.adherence ?? 0;
      int cantCounterYear = 1;
      medicationSum += currentBarChart.medicationPercentage ?? 0;
      nutritionSum += currentBarChart.nutritionPercentage ?? 0;
      activitiesSum += currentBarChart.activitiesPercentage ?? 0;
      examsSum += currentBarChart.examsPercentage ?? 0;
      adherenceTotalSum += currentBarChart.adherence ?? 0;
      if (!firstFound) {
        firstFound = true;
        firstRangeDate = currentDate;
      }
      DateTime? firstOfYear = currentDate;
      while (i + 1 < barcharListGlobal!.length &&
          year == barcharListGlobal![i + 1].dateTime!.year) {
        i++;
        currentBarChart = barcharListGlobal![i];
        currentDate = currentBarChart.dateTime!;
        year = currentDate.year;
        sum += currentBarChart.adherence ?? 0;
        cantCounterYear++;
        medicationSum += currentBarChart.medicationPercentage ?? 0;
        nutritionSum += currentBarChart.nutritionPercentage ?? 0;
        activitiesSum += currentBarChart.activitiesPercentage ?? 0;
        examsSum += currentBarChart.examsPercentage ?? 0;
        adherenceTotalSum += currentBarChart.adherence ?? 0;
      }
      if (year == today.year) {
        cantCounterYear = daysBetween(firstOfYear, today);
      } else if (cantCounterYear < 365) {
        cantCounterYear = 365;
      }
      currentBarChart = BarCharData(
          dateTime: null,
          medicationPercentage: null,
          nutritionPercentage: null,
          activitiesPercentage: null,
          examsPercentage: null);
      currentBarChart.dateLabel = year.toString();
      currentBarChart.adherence =
          cantCounterYear > 0 ? sum / cantCounterYear : 0;
      result.add(currentBarChart);
    }
    if (firstFound) {
      cantCounter = daysBetween(firstRangeDate, today);
    }
    periodMedicationPercentages[3] =
        ((cantCounter > 0 ? medicationSum / cantCounter : 0) * 100).toInt();
    periodNutritionPercentages[3] =
        ((cantCounter > 0 ? nutritionSum / cantCounter : 0) * 100).toInt();
    periodActivityPercentages[3] =
        ((cantCounter > 0 ? activitiesSum / cantCounter : 0) * 100).toInt();
    periodExamsPercentages[3] =
        ((cantCounter > 0 ? examsSum / cantCounter : 0) * 100).toInt();
    periodAdherences[3] =
        ((cantCounter > 0 ? adherenceTotalSum / cantCounter : 0) * 100).toInt();

    return result;
  }

  getAdherenceColor(int adherence) {
    if (adherence >= 80) return Color(0xff47B4AC);
    return Color(0xffE72A2A);
  }

  getScreenHeight() {
    return getPatientHeight() - 110;
  }

  getAdherencePageOrEmptyState() {
    return Container(
      width: double.infinity,
      height: getScreenHeight(),
      child: SingleChildScrollView(
          child: ConstrainedBox(
              child: Column(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        adherencePrediction < 0
                            ? Container(
                                width: double.infinity,
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 40),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          SizedBox(height: 5),
                                          Text(
                                            'No tiene suficiente\ninformación para mostrar\nel riesgo',
                                            textAlign: TextAlign.center,
                                            maxLines: 5,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14,
                                              color: Color(0xff999999),
                                              fontFamily: 'Italic',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ])),
                              )
                            : Column(
                                children: [
                                  Container(
                                    width: HomeScreen.screenHeight * 0.25,
                                    height: HomeScreen.screenHeight * 0.25,
                                    child: FittedBox(
                                        child: Material(
                                            elevation: 10,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(100)),
                                            child: CircularPercentIndicator(
                                                animation: true,
                                                backgroundColor: Colors.white,
                                                radius: 100,
                                                lineWidth: 15,
                                                percent:
                                                    adherencePrediction / 100,
                                                center: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    ShaderMask(
                                                      blendMode:
                                                          BlendMode.srcIn,
                                                      shaderCallback: (bounds) =>
                                                          LinearGradient(
                                                                  colors: getGradientColors(
                                                                      adherencePrediction))
                                                              .createShader(
                                                        Rect.fromLTRB(
                                                            0,
                                                            0,
                                                            bounds.width,
                                                            bounds.height),
                                                      ),
                                                      child: Text(
                                                          "$adherencePrediction%",
                                                          style: TextStyle(
                                                              fontSize: 42,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900)),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text(
                                                      'RIESGO DE\nABANDONO',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Color(
                                                              0xff666666)),
                                                    )
                                                  ],
                                                ),
                                                linearGradient: LinearGradient(
                                                    begin: Alignment.topRight,
                                                    end: Alignment.bottomLeft,
                                                    colors: getGradientColors(
                                                        adherencePrediction)),
                                                rotateLinearGradient: true,
                                                circularStrokeCap:
                                                    CircularStrokeCap.round))),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    getAdherenceMessage(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff999999),
                                    ),
                                  )
                                ],
                              )
                      ]),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          //apply padding to all four sides
                          child: Text(
                            'Periodo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Color(0xffCECECE),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(
                          color: Color(0xffCECECE),
                          thickness: 1,
                        )),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 2),
                          //apply padding to all four sides
                          child: Text(
                            (barcharListGlobal?.isEmpty ?? true)
                                ? ""
                                : 'Adherencia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Color(0xffCECECE),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20, left: 2),
                          //apply padding to all four sides
                          child: Text(
                            (barcharListGlobal?.isEmpty ?? true)
                                ? ""
                                : '${periodAdherences[barChartPeriodIndex]}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: getAdherenceColor(
                                  periodAdherences[barChartPeriodIndex]),
                            ),
                          ),
                        )
                      ]),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 20.0),
                      height: 20,
                      child: new ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: const BorderSide(
                                      color: Color(0xff3BACB6),
                                      width: 1,
                                      style: BorderStyle.solid),
                                ),
                                height: 20,
                                color: barChartPeriodIndex != 0
                                    ? Colors.white
                                    : const Color(0xff3BACB6),
                                textColor: barChartPeriodIndex != 0
                                    ? Color(0xff999999)
                                    : Colors.white,
                                onPressed: () {
                                  setState(() {
                                    barChartPeriodIndex = 0;
                                  });
                                },
                                child: const Text(
                                  'Diario',
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Color(0xff3BACB6),
                                    width: 1,
                                    style: BorderStyle.solid),
                              ),
                              height: 20,
                              color: barChartPeriodIndex != 1
                                  ? Colors.white
                                  : const Color(0xff3BACB6),
                              textColor: barChartPeriodIndex != 1
                                  ? Color(0xff999999)
                                  : Colors.white,
                              onPressed: () {
                                setState(() {
                                  barChartPeriodIndex = 1;
                                });
                              },
                              child: const Text(
                                'Semanal',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Color(0xff3BACB6),
                                    width: 1,
                                    style: BorderStyle.solid),
                              ),
                              height: 20,
                              color: barChartPeriodIndex != 2
                                  ? Colors.white
                                  : const Color(0xff3BACB6),
                              textColor: barChartPeriodIndex != 2
                                  ? Color(0xff999999)
                                  : Colors.white,
                              onPressed: () {
                                setState(() {
                                  barChartPeriodIndex = 2;
                                });
                              },
                              child: const Text(
                                'Mensual',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: const BorderSide(
                                    color: Color(0xff3BACB6),
                                    width: 1,
                                    style: BorderStyle.solid),
                              ),
                              height: 20,
                              color: barChartPeriodIndex != 3
                                  ? Colors.white
                                  : const Color(0xff3BACB6),
                              textColor: barChartPeriodIndex != 3
                                  ? Color(0xff999999)
                                  : Colors.white,
                              onPressed: () {
                                setState(() {
                                  barChartPeriodIndex = 3;
                                });
                              },
                              child: const Text(
                                'Anual',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  (barcharListGlobal?.isEmpty ?? true)
                      ? SizedBox(
                          height: 0,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 20, right: 2),
                                //apply padding to all four sides
                                child: Text(
                                  'Adherencia de Hoy',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff2F8F9D),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(right: 30, left: 2),
                                  //apply padding to all four sides
                                  child: Text(
                                    '$todayAdherence%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: getAdherenceColor(todayAdherence),
                                    ),
                                  ))
                            ]),
                  Container(
                      height: 150,
                      child: FutureBuilder(
                        future: barchartDataFuture,
                        builder: (context,
                            AsyncSnapshot<List<BarCharData>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (barcharListGlobal?.isEmpty ?? true) {
                              return Container(
                                width: double.infinity,
                                height: HomeScreen.screenHeight * 0.55,
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 40),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          SizedBox(height: 5),
                                          Text(
                                            'No tiene suficiente\ninformación para mostrar\ngráficos',
                                            textAlign: TextAlign.center,
                                            maxLines: 5,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 14,
                                              color: Color(0xff999999),
                                              fontFamily: 'Italic',
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ])),
                              );
                            }
                            return getBarCharView();
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      )),
                  (barcharListGlobal?.isEmpty ?? true)
                      ? SizedBox(
                          height: 0,
                        )
                      : Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: const <Widget>[
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 2),
                                    child: Text(
                                      'Cumplimiento de rutinas',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff999999),
                                      ),
                                    ),
                                  )
                                ]),
                            SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                                height: 86,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Color(0xFFEBE3E3),
                                              width: 1),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  10) //         <--- border radius here
                                              ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text("Medicación",
                                                style: TextStyle(
                                                    color: Color(0xff797979),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ShaderMask(
                                                  blendMode: BlendMode.srcIn,
                                                  shaderCallback: (bounds) =>
                                                      LinearGradient(
                                                              colors: getGradientColors(
                                                                  periodMedicationPercentages[
                                                                      barChartPeriodIndex],
                                                                  true))
                                                          .createShader(
                                                    Rect.fromLTRB(
                                                        0,
                                                        0,
                                                        bounds.width,
                                                        bounds.height),
                                                  ),
                                                  child: Text(
                                                      "${periodMedicationPercentages[barChartPeriodIndex]}%",
                                                      style: TextStyle(
                                                          fontSize:
                                                              periodMedicationPercentages[
                                                                          barChartPeriodIndex] !=
                                                                      100
                                                                  ? 42
                                                                  : 35,
                                                          fontWeight:
                                                              FontWeight.w900)),
                                                ),
                                                SizedBox(
                                                    height: 30,
                                                    child: getColoredTriangle(
                                                        periodMedicationPercentages[
                                                            barChartPeriodIndex]))
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 5),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Color(0xFFEBE3E3),
                                              width: 1),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  10) //         <--- border radius here
                                              ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Alimentación",
                                              style: TextStyle(
                                                  color: Color(0xff797979),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ShaderMask(
                                                  blendMode: BlendMode.srcIn,
                                                  shaderCallback: (bounds) =>
                                                      LinearGradient(
                                                              colors: getGradientColors(
                                                                  periodNutritionPercentages[
                                                                      barChartPeriodIndex],
                                                                  true))
                                                          .createShader(
                                                    Rect.fromLTRB(
                                                        0,
                                                        0,
                                                        bounds.width,
                                                        bounds.height),
                                                  ),
                                                  child: Text(
                                                      "${periodNutritionPercentages[barChartPeriodIndex]}%",
                                                      style: TextStyle(
                                                          fontSize:
                                                              periodNutritionPercentages[
                                                                          barChartPeriodIndex] !=
                                                                      100
                                                                  ? 42
                                                                  : 35,
                                                          fontWeight:
                                                              FontWeight.w900)),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                  child: getColoredTriangle(
                                                      periodNutritionPercentages[
                                                          barChartPeriodIndex]),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                            SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                                height: 86,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(right: 5),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Color(0xFFEBE3E3),
                                              width: 1),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  10) //         <--- border radius here
                                              ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text("Actividad Física",
                                                style: TextStyle(
                                                    color: Color(0xff797979),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ShaderMask(
                                                  blendMode: BlendMode.srcIn,
                                                  shaderCallback: (bounds) =>
                                                      LinearGradient(
                                                              colors: getGradientColors(
                                                                  periodActivityPercentages[
                                                                      barChartPeriodIndex],
                                                                  true))
                                                          .createShader(
                                                    Rect.fromLTRB(
                                                        0,
                                                        0,
                                                        bounds.width,
                                                        bounds.height),
                                                  ),
                                                  child: Text(
                                                      "${periodActivityPercentages[barChartPeriodIndex]}%",
                                                      style: TextStyle(
                                                          fontSize:
                                                              periodActivityPercentages[
                                                                          barChartPeriodIndex] !=
                                                                      100
                                                                  ? 42
                                                                  : 35,
                                                          fontWeight:
                                                              FontWeight.w900)),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                  child: getColoredTriangle(
                                                      periodActivityPercentages[
                                                          barChartPeriodIndex]),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 5),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Color(0xFFEBE3E3),
                                              width: 1),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  10) //         <--- border radius here
                                              ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Exámenes",
                                              style: TextStyle(
                                                  color: Color(0xff797979),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ShaderMask(
                                                  blendMode: BlendMode.srcIn,
                                                  shaderCallback: (bounds) =>
                                                      LinearGradient(
                                                              colors: getGradientColors(
                                                                  periodExamsPercentages[
                                                                      barChartPeriodIndex],
                                                                  true))
                                                          .createShader(
                                                    Rect.fromLTRB(
                                                        0,
                                                        0,
                                                        bounds.width,
                                                        bounds.height),
                                                  ),
                                                  child: Text(
                                                      "${periodExamsPercentages[barChartPeriodIndex]}%",
                                                      style: TextStyle(
                                                          fontSize:
                                                              periodExamsPercentages[
                                                                          barChartPeriodIndex] !=
                                                                      100
                                                                  ? 42
                                                                  : 35,
                                                          fontWeight:
                                                              FontWeight.w900)),
                                                ),
                                                SizedBox(
                                                  height: 30,
                                                  child: getColoredTriangle(
                                                      periodExamsPercentages[
                                                          barChartPeriodIndex]),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ))
                          ],
                        ),
                  //SizedBox
                ],
              ),
              constraints: BoxConstraints(
                minHeight: 200,
              ))),
    );
  }

  getPatientHeight() {
    if (isDoctorView) {
      return HomeScreen.screenHeight * 0.8;
    }
    double percentage = 0.55;
    var maxExtent = HomeScreen.screenHeight * 0.3;
    var result = HomeScreen.screenHeight * percentage +
        (MySliverHeaderDelegate.publicShrinkHome > (maxExtent / 1.4)
            ? maxExtent / 1.4
            : MySliverHeaderDelegate.publicShrinkHome);
    return result;
  }

  int daysBetween(DateTime? from, DateTime to) {
    if (from == null) return 0;
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round() + 1;
  }
}
