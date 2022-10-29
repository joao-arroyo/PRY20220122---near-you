import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:near_you/Constants.dart';
import 'package:near_you/model/medicationPrescription.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/widgets/prescription_detail.dart';
import 'package:near_you/widgets/static_components.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../model/activityPrescription.dart';
import '../model/nutritionPrescription.dart';
import '../model/examsPrescription.dart';
import '../screens/home_screen.dart';
import '../widgets/grouped_bar_chart.dart';

class VisualizePrescriptionDetail extends StatefulWidget {
  final bool isDoctorView;
  Treatment? currentTreatment;

  int currentPageIndex;

  VisualizePrescriptionDetail(this.currentTreatment,
      {required this.isDoctorView, required this.currentPageIndex});

  factory VisualizePrescriptionDetail.forDoctorView(
      Treatment? paramTreatment, int currentPageIndex) {
    return VisualizePrescriptionDetail(paramTreatment,
        isDoctorView: true, currentPageIndex: currentPageIndex);
  }

  factory VisualizePrescriptionDetail.forPrescriptionView(
      Treatment? paramTreatment) {
    return VisualizePrescriptionDetail(
      paramTreatment,
      isDoctorView: false,
      currentPageIndex: 0,
    );
  }

  @override
  VisualizePrescriptionDetailState createState() =>
      VisualizePrescriptionDetailState(
          currentTreatment, isDoctorView, currentPageIndex);
}

class VisualizePrescriptionDetailState
    extends State<VisualizePrescriptionDetail> {
  static StaticComponents staticComponents = StaticComponents();
  Treatment? currentTreatment;
  int _currentPage = 0;
  late final PageController _pageController;
  bool isDoctorView = true;
  late final Future<List<MedicationPrescription>> medicationPrescriptionFuture;
  late final Future<List<NutritionPrescription>> nutritionPrescriptionFuture;
  late final Future<List<ActivityPrescription>> activityPrescriptionFuture;
  late final Future<List<ExamsPrescription>> examnPrescriptionFuture;
  List<MedicationPrescription> medicationsList = <MedicationPrescription>[];
  List<NutritionPrescription> nutritionList = <NutritionPrescription>[];
  List<ActivityPrescription> activitiesList = <ActivityPrescription>[];
  List<NutritionPrescription> nutritionNoPermittedList =
      <NutritionPrescription>[];
  List<ActivityPrescription> activitiesNoPermittedList =
      <ActivityPrescription>[];
  List<ExamsPrescription> examsList = <ExamsPrescription>[];

  String? medicationStartDateValue;
  String? medicationNameValue;
  String? medicationDurationNumberValue;
  String? medicationDurationTypeValue;
  String? medicationTypeValue;
  String? medicationDoseValue;
  String? medicationQuantityValue;
  String? medicationPeriodicityValue;
  String? medicationRecommendationValue;

  String? nutritionNameValue;
  String? nutritionCarboValue;
  String? nutritionCaloriesValue;

  String? activityNameValue;
  String? activityActivityValue;
  String? activityPeriodicityValue;
  String? activityCaloriesValue;
  String? activityTimeNumberValue;
  String? activityTimeTypeValue;

  int medicationsCount = 0;

  final GlobalKey<FormState> medicationFormState = GlobalKey<FormState>();
  final GlobalKey<FormState> alimentationFormState = GlobalKey<FormState>();
  final GlobalKey<FormState> phisicalActivityFormState = GlobalKey<FormState>();

  bool startDateError = false;
  bool endDateError = false;
  bool durationError = false;
  bool durationTypeError = false;
  bool stateError = false;
  bool descriptionError = false;

  String? heightValue;

  String? imcValue;

  String? weightValue;
  bool editingMedication = false;
  bool editingPermittedFood = false;
  bool editingPermittedActivity = false;

  int updateMedication = -1;
  int updatePermittedFood = -1;
  int updateNoPermittedFood = -1;
  int updatePermittedActivity = -1;
  int updateNoPermittedActivity = -1;

  VisualizePrescriptionDetailState(
      this.currentTreatment, this.isDoctorView, int currentPageIndex) {
    _pageController = PageController(initialPage: currentPageIndex);
    _currentPage = currentPageIndex;
  }

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
                color: const Color(0xffCCD6DD),
                borderRadius: BorderRadius.circular(5),
                shape: BoxShape.rectangle),
          ),
        ),
      ));

  get borderGray => OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffD9D9D9)),
      borderRadius: BorderRadius.circular(5));

  get borderWhite => OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(5));

  get sizedBox10 => const SizedBox(height: 10);

  @override
  void initState() {
    medicationPrescriptionFuture = getMedicationPrescriptions();
    activityPrescriptionFuture = getActivityPrescriptions();
    nutritionPrescriptionFuture = getNutritionPrescriptions();
    examnPrescriptionFuture = getExamsPrescriptions();
    medicationPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                medicationsList = value;
              })
            }
        });
    nutritionPrescriptionFuture.then((value) {
      if (mounted) {
        setState(() {
          nutritionList = [];
          nutritionNoPermittedList = [];
          for (int i = 0; i < value.length; i++) {
            if (value[i].permitted == YES_KEY) {
              nutritionList.add(value[i]);
            } else {
              nutritionNoPermittedList.add(value[i]);
            }
          }
        });

        if (nutritionList.isNotEmpty) {
          weightController.text = nutritionList[0].weight.toString();
          heightController.text = nutritionList[0].height.toString();
          imcController.text = nutritionList[0].imc.toString();
        }
        if (nutritionNoPermittedList.isNotEmpty) {
          weightController.text = nutritionNoPermittedList[0].weight.toString();
          heightController.text = nutritionNoPermittedList[0].height.toString();
          imcController.text = nutritionNoPermittedList[0].imc.toString();
        }
      }
    });
    activityPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                activitiesList = value;
              })
            }
        });
    examnPrescriptionFuture.then((value) => {
          if (mounted)
            {
              setState(() {
                examsList = value;
              })
            }
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: HomeScreen.screenHeight *0.8,
      width: screenWidth,
      child: PageView.builder(
          scrollDirection: Axis.horizontal,
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: 4,
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
    String title = "";
    Widget childView;
    switch (i) {
      case 0:
        title = "Medicación";
        childView = getMedicationView();
        break;
      case 1:
        title = "Alimentación";
        childView = getAlimentationView();
        break;
      case 2:
        title = "Actividad Física";
        childView = getPhisicalActivityView();
        break;
      default:
        title = "Exámenes";
        childView = getExamnView();
    }
    return getPrescriptionPage(i, title, childView);
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

  getPrescriptionPage(int index, String title, Widget childView) {
    return Card(
      elevation: 10,
      shadowColor: Colors.black,
      margin: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: SizedBox(
        width: 400,
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
                            icon: Icon(index == 0 ? null : Icons.chevron_left,
                                size: 30, color: const Color(0xff2F8F9D)),
                            onPressed: () {
                              if (index > 0) {
                                goBack();
                              }
                            },
                          ),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2F8F9D),
                            ),
                          ),
                          IconButton(
                            icon: Icon(index == 3 ? null : Icons.chevron_right,
                                size: 30, color: const Color(0xff2F8F9D)),
                            onPressed: () {
                              if (index < 3) {
                                goAhead();
                              }
                            },
                          )
                        ]),
                    const SizedBox(
                      height: 10,
                    ),
                    childView
                  ]),
              const SizedBox(
                height: 20,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    index == 0 ? blueIndicator : grayIndicator,
                    index == 1 ? blueIndicator : grayIndicator,
                    index == 2 ? blueIndicator : grayIndicator,
                    index == 3 ? blueIndicator : grayIndicator,
                  ]),
              //SizedBox
            ],
          ), //Column
        ), //Padding
      ), //SizedBox
    );
  }

  getMedicationView() {
    return FutureBuilder(
        future: medicationPrescriptionFuture,
        builder:
            (context, AsyncSnapshot<List<MedicationPrescription>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              width: double.infinity,
              height: HomeScreen.screenHeight*0.65,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                //  shrinkWrap: true,
                 // physics: const NeverScrollableScrollPhysics(),
                  itemCount: medicationsList.length,
                  itemBuilder: (context, index) {
                    return VizualizeMedicationPrescriptionItem(
                      medication: medicationsList[index],
                    );
                  }),
            );
          }
          return const SizedBox(
            height: 460,
          );
        });
  }

  Future<List<MedicationPrescription>> getMedicationPrescriptions() async {
    List<MedicationPrescription> resultList = <MedicationPrescription>[];
    final db = FirebaseFirestore.instance;
    var future = await db
        .collection(MEDICATION_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatment?.databaseId)
        .get();
    for (var element in future.docs) {
      resultList.add(MedicationPrescription.fromSnapshot(element));
    }
    return resultList;
  }

  Future<List<ActivityPrescription>> getActivityPrescriptions() async {
    List<ActivityPrescription> resultList = <ActivityPrescription>[];
    final db = FirebaseFirestore.instance;
    var future = await db
        .collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatment?.databaseId)
        .get();
    for (var element in future.docs) {
      resultList.add(ActivityPrescription.fromSnapshot(element));
    }
    return resultList;
  }

  Future<List<NutritionPrescription>> getNutritionPrescriptions() async {
    List<NutritionPrescription> resultList = <NutritionPrescription>[];
    final db = FirebaseFirestore.instance;
    var future = await db
        .collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatment?.databaseId)
        .get();
    for (var element in future.docs) {
      resultList.add(NutritionPrescription.fromSnapshot(element));
    }
    return resultList;
  }

  Future<List<ExamsPrescription>> getExamsPrescriptions() async {
    List<ExamsPrescription> resultList = <ExamsPrescription>[];
    final db = FirebaseFirestore.instance;
    var future = await db
        .collection(EXAMS_PRESCRIPTION_COLLECTION_KEY)
        .where(TREATMENT_ID_KEY, isEqualTo: currentTreatment?.databaseId)
        .get();
    for (var element in future.docs) {
      resultList.add(ExamsPrescription.fromSnapshot(element));
    }
    return resultList;
  }

  bool isNotEmpty(String? str) {
    return str != null && str != '';
  }

  void goBackScreen() {
    if (isDoctorView) {
      Navigator.pop(context);
    }
  }

  getFormOrButtonAddMedication() {
    if (editingMedication) {
      return SizedBox(
        width: double.infinity,
        child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200, maxHeight: 800),
            child: Form(
                key: medicationFormState,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Column(
                        children: [
                          sizedBox10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 35,
                                width: 230,
                                child: TextFormField(
                                    controller: TextEditingController(
                                        text: medicationNameValue),
                                    style: const TextStyle(fontSize: 14),
                                    decoration: staticComponents
                                        .getMiddleInputDecorationDisabled()),
                              )
                            ],
                          ),
                          sizedBox10,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Fecha de inicio",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          SizedBox(
                              height: startDateError ? 55 : 35,
                              child: TextFormField(
                                readOnly: true,
                                controller: TextEditingController(
                                    text: medicationStartDateValue),
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                    filled: true,
                                    prefixIcon: IconButton(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      onPressed: () {},
                                      icon: const Icon(
                                          Icons.calendar_today_outlined,
                                          color: Color(
                                              0xff999999)), // myIcon is a 48px-wide widget.
                                    ),
                                    hintText: '18 - Jul 2022  15:00',
                                    hintStyle: const TextStyle(
                                        fontSize: 14, color: Color(0xff999999)),
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder:
                                        staticComponents.middleInputBorder,
                                    border: staticComponents.middleInputBorder,
                                    focusedBorder:
                                        staticComponents.middleInputBorder),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Duración",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: SizedBox(
                                    height: 35,
                                    width: 111,
                                    child: TextFormField(
                                      controller: TextEditingController(
                                          text: medicationDurationNumberValue),
                                      style: const TextStyle(fontSize: 14),
                                      decoration: staticComponents
                                          .getMiddleInputDecorationDisabled(),
                                    )),
                              ),
                              Flexible(
                                child: SizedBox(
                                    height: 35,
                                    width: 111,
                                    child: TextFormField(
                                      controller: TextEditingController(
                                          text: medicationDurationTypeValue),
                                      style: const TextStyle(fontSize: 14),
                                      decoration: staticComponents
                                          .getMiddleInputDecorationDisabled(),
                                    )),
                              )
                            ],
                          ),
                          sizedBox10,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Tipo",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          SizedBox(
                              height: 35,
                              child: TextFormField(
                                  controller: TextEditingController(
                                      text: medicationTypeValue),
                                  style: const TextStyle(fontSize: 14),
                                  decoration: staticComponents
                                      .getMiddleInputDecorationDisabled())),
                          sizedBox10,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Dosis",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          SizedBox(
                              height: 35,
                              child: TextFormField(
                                  controller: TextEditingController(
                                      text: medicationDoseValue),
                                  style: const TextStyle(fontSize: 14),
                                  decoration: staticComponents
                                      .getMiddleInputDecorationDisabled())),
                          sizedBox10,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Cantidad",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          SizedBox(
                              height: 35,
                              child: TextFormField(
                                  controller: TextEditingController(
                                      text: medicationQuantityValue),
                                  style: const TextStyle(fontSize: 14),
                                  decoration: staticComponents
                                      .getMiddleInputDecorationDisabled())),
                          sizedBox10,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Periodicidad",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          SizedBox(
                              height: 35,
                              child: TextFormField(
                                  controller: TextEditingController(
                                      text: medicationPeriodicityValue),
                                  style: const TextStyle(fontSize: 14),
                                  decoration: staticComponents
                                      .getMiddleInputDecorationDisabled())),
                          sizedBox10,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Recomendación",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          TextFormField(
                            controller: TextEditingController(
                                text: medicationRecommendationValue),
                            style: const TextStyle(fontSize: 14),
                            minLines: 2,
                            maxLines: 10,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: staticComponents
                                .getBigInputDecorationDisabled(),
                          ),
                          sizedBox10
                        ],
                      ),
                    )
                  ],
                ))),
      );
    }
    return staticComponents.emptyBox;
  }

  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final imcController = TextEditingController();

  Widget getAlimentationView() {
    return FutureBuilder(
        future: nutritionPrescriptionFuture,
        builder:
            (context, AsyncSnapshot<List<NutritionPrescription>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              width: double.infinity,
              height: HomeScreen.screenHeight*0.6,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 200,
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Peso",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                  child: TextFormField(
                                enabled: false,
                                controller: weightController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 10),
                                  filled: true,
                                  isDense: true,
                                  fillColor: Colors.white,
                                  hintText: '1.2',
                                  hintStyle: const TextStyle(
                                      fontSize: 14, color: Color(0xFF999999)),
                                  enabledBorder:
                                      StaticComponents().middleInputBorder,
                                  border: StaticComponents().middleInputBorder,
                                  focusedBorder:
                                      StaticComponents().middleInputBorder,
                                ),
                                keyboardType: TextInputType.number,
                              )),
                              const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Kg',
                                    style: TextStyle(
                                        fontSize: 14, color: Color(0xFF999999)),
                                  ))
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Estatura",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Flexible(
                                child: SizedBox(
                                  child: TextFormField(
                                    controller: heightController,
                                    enabled: false,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 10),
                                      filled: true,
                                      isDense: true,
                                      fillColor: Colors.white,
                                      hintText: '1.65',
                                      hintStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF999999)),
                                      enabledBorder:
                                          StaticComponents().middleInputBorder,
                                      border:
                                          StaticComponents().middleInputBorder,
                                      focusedBorder:
                                          StaticComponents().middleInputBorder,
                                    ),
                                    keyboardType: TextInputType.number,
                                    //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  ),
                                ),
                              ),
                              const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'm',
                                    style: TextStyle(
                                        fontSize: 14, color: Color(0xFF999999)),
                                  ))
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text("IMC ",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999))),
                              Icon(Icons.info,
                                  size: 18, color: Color(0xff999999))
                            ],
                          ),
                          sizedBox10,
                          SizedBox(
                              height: 35,
                              child: TextFormField(
                                controller: imcController,
                                style: const TextStyle(fontSize: 14),
                                decoration: staticComponents
                                    .getMiddleInputDecorationDisabled(),
                              )),
                          sizedBox10,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text("Alimentación ",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999))),
                              Icon(Icons.info,
                                  size: 18, color: Color(0xff999999))
                            ],
                          ),
                          sizedBox10,
                          SizedBox(
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: nutritionList.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 35,
                                          child: Icon(Icons.keyboard_arrow_down,
                                              size: 30,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        ),
                                        Text(
                                            nutritionList[index].name ??
                                                "Alimento",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xff999999))),
                                        const SizedBox(height: 10)
                                      ],
                                    );
                                  })),
                          //getButtonAddFoodOrList(),
                          sizedBox10,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text("Alimentos no permitidos",
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xff999999))),
                            ],
                          ),
                          sizedBox10,
                          SizedBox(
                              child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: nutritionNoPermittedList.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 35,
                                          child: Icon(Icons.keyboard_arrow_down,
                                              size: 30,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        ),
                                        Text(
                                            nutritionNoPermittedList[index]
                                                    .name ??
                                                "Actividad",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xff999999))),
                                        const SizedBox(height: 10)
                                      ],
                                    );
                                  })),
                          //getButtonAddFoodOrListProhibited(),
                        ],
                      ))),
            );
          }
          return const SizedBox(
            height: 460,
          );
        });
  }

  getPhisicalActivityView() {
    return FutureBuilder(
        future: activityPrescriptionFuture,
        builder: (context, AsyncSnapshot<List<ActivityPrescription>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              width: double.infinity,
              height: HomeScreen.screenHeight*0.65,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  //physics: const NeverScrollableScrollPhysics(),
                  itemCount: activitiesList.length,
                  itemBuilder: (context, index) {
                    return VizualizeActivityPrescriptionItem(
                      activity: activitiesList[index],
                    );
                  }),
            );
          }
          return const SizedBox(
            height: 460,
          );
        });
  }

  Widget getExamnView() {
    return FutureBuilder(
        future: examnPrescriptionFuture,
        builder: (context, AsyncSnapshot<List<ExamsPrescription>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              width: double.infinity,
              height: HomeScreen.screenHeight*0.65,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  //physics: const NeverScrollableScrollPhysics(),
                  itemCount: examsList.length,
                  itemBuilder: (context, index) {
                    return VizualizeExamnPrescriptionItem(
                      examn: examsList[index],
                    );
                  }),
            );
          }
          return const SizedBox(
            height: 460,
          );
        });
  }

  getButtonAddFoodOrList() {
    return !editingPermittedFood
        ? TextField(
            minLines: 1,
            maxLines: 10,
            enabled: false,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(Icons.circle, color: Colors.white),
              filled: true,
              fillColor: const Color(0xffD9D9D9),
              hintText: "No aplica",
              hintStyle:
                  const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              focusedBorder: borderGray,
              border: borderGray,
              enabledBorder: borderGray,
            )
            // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

            )
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                        controller:
                            TextEditingController(text: nutritionNameValue),
                        style: const TextStyle(fontSize: 14),
                        decoration:
                            staticComponents.getMiddleInputDecorationDisabled(),
                      ))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Carbohidratos",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                  height: 35,
                  child: TextFormField(
                    controller:
                        TextEditingController(text: nutritionCarboValue),
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecorationDisabled(),
                  )),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Calorías máx.",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: 35,
                  child: TextFormField(
                    controller:
                        TextEditingController(text: nutritionCaloriesValue),
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecorationDisabled(),
                  )),
            ]));
  }

  getButtonAddFoodOrListProhibited() {
    return editingPermittedFood
        ? TextField(
            minLines: 1,
            maxLines: 10,
            enabled: false,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(Icons.circle, color: Colors.white),
              filled: true,
              fillColor: const Color(0xffD9D9D9),
              hintText: "No aplica",
              hintStyle:
                  const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              focusedBorder: borderGray,
              border: borderGray,
              enabledBorder: borderGray,
            )
            // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

            )
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                          controller:
                              TextEditingController(text: nutritionNameValue),
                          style: const TextStyle(fontSize: 14),
                          decoration: staticComponents
                              .getMiddleInputDecorationDisabled())),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Carbohidratos",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: 35,
                  child: TextFormField(
                    controller:
                        TextEditingController(text: nutritionCarboValue),
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecorationDisabled(),
                  )),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Calorías máx.",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: 35,
                  child: TextFormField(
                    controller:
                        TextEditingController(text: nutritionCaloriesValue),
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecorationDisabled(),
                  )),
            ]));
  }

  getButtonAddRoutineOrList() {
    return !editingPermittedActivity
        ? TextField(
            minLines: 1,
            maxLines: 10,
            enabled: false,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(Icons.circle, color: Colors.white),
              filled: true,
              fillColor: const Color(0xffD9D9D9),
              hintText: "No aplica",
              hintStyle:
                  const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              focusedBorder: borderGray,
              border: borderGray,
              enabledBorder: borderGray,
            )
            // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

            )
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                          controller:
                              TextEditingController(text: activityNameValue),
                          style: const TextStyle(fontSize: 14),
                          decoration: staticComponents
                              .getMiddleInputDecorationDisabled()))
                ],
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Actividad",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              color: const Color(0xffD9D9D9),
                              child: const Text(
                                'L',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              color: const Color(0xffCECECE),
                              child: const Text(
                                'M',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              color: const Color(0xffD9D9D9),
                              child: const Text(
                                'I',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                  ]),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Tiempo",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: SizedBox(
                          height: 35,
                          width: 100,
                          child: TextFormField(
                            controller: TextEditingController(
                                text: activityTimeNumberValue),
                            style: const TextStyle(fontSize: 14),
                            decoration: staticComponents
                                .getMiddleInputDecorationDisabled(),
                          )),
                    ),
                    Flexible(
                        child: SizedBox(
                            height: 35,
                            width: 100,
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: activityTimeNumberValue),
                              style: const TextStyle(fontSize: 14),
                              decoration: staticComponents
                                  .getMiddleInputDecorationDisabled(),
                            )))
                  ]),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Periodicidad",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: 35,
                  child: TextFormField(
                    controller:
                        TextEditingController(text: activityPeriodicityValue),
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecorationDisabled(),
                  )),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Calorías",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: 35,
                  child: TextFormField(
                    controller:
                        TextEditingController(text: activityCaloriesValue),
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecorationDisabled(),
                  )),
            ]));
  }

  getButtonAddProhibitedRoutineOrList() {
    return editingPermittedActivity
        ? TextField(
            minLines: 1,
            maxLines: 10,
            enabled: false,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(Icons.circle, color: Colors.white),
              filled: true,
              fillColor: const Color(0xffD9D9D9),
              hintText: "No aplica",
              hintStyle:
                  const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              focusedBorder: borderGray,
              border: borderGray,
              enabledBorder: borderGray,
            )
            // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

            )
        : Container(
            //height: double.maxFinite,
            //  width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      height: durationError ? 55 : 35,
                      width: 180,
                      child: TextFormField(
                        controller:
                            TextEditingController(text: activityNameValue),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 10),
                            filled: true,
                            hintText: 'Caminar',
                            hintStyle: const TextStyle(
                                fontSize: 14, color: Color(0xFF999999)),
                            enabledBorder: staticComponents.middleInputBorder,
                            border: staticComponents.middleInputBorder,
                            focusedBorder: staticComponents.middleInputBorder),
                      ))
                ],
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Actividad",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              color: const Color(0xffD9D9D9),
                              child: const Text(
                                'L',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              color: const Color(0xffCECECE),
                              child: const Text(
                                'M',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: SizedBox(
                            width: 61,
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    color: Color(0xff9D9CB5),
                                    width: 1,
                                    style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 25,
                              onPressed: () {
                                // _signInWithEmailAndPassword();
                              },
                              color: const Color(0xffD9D9D9),
                              child: const Text(
                                'I',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xff999999),
                                ),
                              ),
                            ))),
                  ]),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Tiempo",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: SizedBox(
                          height: 35,
                          width: 100,
                          child: TextFormField(
                            controller: TextEditingController(
                                text: activityTimeNumberValue),
                            style: const TextStyle(fontSize: 14),
                            decoration: staticComponents
                                .getMiddleInputDecorationDisabled(),
                          )),
                    ),
                    Flexible(
                        child: SizedBox(
                            height: 35,
                            width: 100,
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: activityTimeNumberValue),
                              style: const TextStyle(fontSize: 14),
                              decoration: staticComponents
                                  .getMiddleInputDecorationDisabled(),
                            )))
                  ]),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Periodicidad",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: 35,
                  child: TextFormField(
                    controller:
                        TextEditingController(text: activityPeriodicityValue),
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecorationDisabled(),
                  )),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Calorías",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              SizedBox(
                  height: 35,
                  child: TextFormField(
                    controller:
                        TextEditingController(text: activityCaloriesValue),
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecorationDisabled(),
                  )),
            ]));
  }

  void editMedication(int index) {
    setState(() {
      editingMedication = true;
      updateMedication = index;
      medicationNameValue = medicationsList[index].name ?? "";
      medicationDurationNumberValue =
          medicationsList[index].durationNumber ?? "";
      medicationStartDateValue = medicationsList[index].startDate ?? "";
      medicationDoseValue = medicationsList[index].dose ?? "";
      medicationRecommendationValue =
          medicationsList[index].recomendation ?? "";
      if (isNotEmpty(medicationsList[index].durationType)) {
        medicationDurationTypeValue = medicationsList[index].durationType;
      }
      if (isNotEmpty(medicationsList[index].pastilleType)) {
        medicationTypeValue = medicationsList[index].pastilleType;
      }
      if (isNotEmpty(medicationsList[index].quantity)) {
        medicationQuantityValue = medicationsList[index].quantity;
      }
      if (isNotEmpty(medicationsList[index].periodicity)) {
        medicationPeriodicityValue = medicationsList[index].periodicity;
      }
    });
  }

  void editFood(int index, bool permitted) {
    setState(() {
      editingPermittedFood = permitted;
      if (editingPermittedFood) {
        updatePermittedFood = index;
        nutritionNameValue = nutritionList[index].name ?? "";
        nutritionCarboValue = nutritionList[index].carbohydrates ?? "";
        nutritionCaloriesValue = nutritionList[index].maxCalories ?? "";
      } else {
        updateNoPermittedFood = index;
        nutritionNameValue = nutritionNoPermittedList[index].name ?? "";
        nutritionCarboValue =
            nutritionNoPermittedList[index].carbohydrates ?? "";
        nutritionCaloriesValue =
            nutritionNoPermittedList[index].maxCalories ?? "";
      }
    });
  }

  void editActivity(int index, bool permitted) {
    setState(() {
      editingPermittedActivity = permitted;
      if (editingPermittedActivity) {
        updatePermittedActivity = index;
        activityNameValue = activitiesList[index].name ?? "";
        activityActivityValue = activitiesList[index].activity ?? "";
        activityTimeNumberValue = activitiesList[index].timeNumber ?? "";
        activityCaloriesValue = activitiesList[index].calories ?? "";
        if (isNotEmpty(activitiesList[index].periodicity)) {
          activityPeriodicityValue = activitiesList[index].periodicity;
        }
        if (isNotEmpty(activitiesList[index].timeType)) {
          activityTimeTypeValue = activitiesList[index].timeType;
        }
      } else {
        updateNoPermittedActivity = index;
        activityNameValue = activitiesNoPermittedList[index].name ?? "";
        activityActivityValue = activitiesNoPermittedList[index].activity ?? "";
        activityTimeNumberValue =
            activitiesNoPermittedList[index].timeNumber ?? "";
        activityCaloriesValue = activitiesNoPermittedList[index].calories ?? "";
        if (isNotEmpty(activitiesNoPermittedList[index].periodicity)) {
          activityPeriodicityValue =
              activitiesNoPermittedList[index].periodicity;
        }
        if (isNotEmpty(activitiesNoPermittedList[index].timeType)) {
          activityTimeTypeValue = activitiesNoPermittedList[index].timeType;
        }
      }
    });
  }
}

class VizualizeMedicationPrescriptionItem extends StatefulWidget {
  const VizualizeMedicationPrescriptionItem(
      {Key? key, required this.medication})
      : super(key: key);

  final MedicationPrescription medication;

  @override
  State<VizualizeMedicationPrescriptionItem> createState() =>
      _VizualizeMedicationPrescriptionItemState();
}

class _VizualizeMedicationPrescriptionItemState
    extends State<VizualizeMedicationPrescriptionItem> {
  bool showForm = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    showForm = !showForm;
                  });
                },
                child: const SizedBox(
                  height: 35,
                  child: Icon(Icons.keyboard_arrow_down,
                      size: 30,
                      color:
                          Color(0xff999999)), // myIcon is a 48px-wide widget.
                ),
              ),
              Text(widget.medication.name ?? "Medicacion",
                  textAlign: TextAlign.left,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xff999999)))
            ],
          ),
          if (showForm)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xffD9D9D9),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: DisableWidget(
                            isDisable: true,
                            child: SizedBox(
                              height: 55,
                              child: TextFormField(
                                  controller: TextEditingController(
                                      text: widget.medication.name),
                                  style: const TextStyle(fontSize: 14),
                                  decoration: StaticComponents()
                                      .getMiddleInputDecoration(
                                          'Nombre del medicamento')),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        /* DisableWidget(
                          isDisable: true,
                          child: CheckButton(
                            onTap: () async {
                              //addOrUpdateMedicationLocally();
                            },
                          ),
                        ) */
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Periodicidad",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(height: 10),
                    DisableWidget(
                      isDisable: true,
                      child: TextFormField(
                        validator: (value) {
                          return null;
                        },
                        controller: TextEditingController(
                            text: widget.medication.periodicity ?? ''),
                        style: const TextStyle(fontSize: 14),
                        minLines: 2,
                        maxLines: 10,
                        textAlignVertical: TextAlignVertical.center,
                        decoration:
                            StaticComponents().getBigInputDecoration(''),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Descripción",
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff999999)))
                      ],
                    ),
                    const SizedBox(height: 10),
                    DisableWidget(
                      isDisable: true,
                      child: TextFormField(
                        validator: (value) {
                          return null;
                        },
                        controller: TextEditingController(
                            text: widget.medication.recomendation),
                        style: const TextStyle(fontSize: 14),
                        minLines: 2,
                        maxLines: 10,
                        textAlignVertical: TextAlignVertical.center,
                        decoration:
                            StaticComponents().getBigInputDecoration(''),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // getPrescriptionButtons()
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}

class VizualizeActivityPrescriptionItem extends StatefulWidget {
  const VizualizeActivityPrescriptionItem({Key? key, required this.activity})
      : super(key: key);

  final ActivityPrescription activity;

  @override
  State<VizualizeActivityPrescriptionItem> createState() =>
      _VizualizeActivityPrescriptionItem();
}

class _VizualizeActivityPrescriptionItem
    extends State<VizualizeActivityPrescriptionItem> {
  bool showForm = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    showForm = !showForm;
                  });
                },
                child: const SizedBox(
                  height: 35,
                  child: Icon(Icons.keyboard_arrow_down,
                      size: 30,
                      color:
                          Color(0xff999999)), // myIcon is a 48px-wide widget.
                ),
              ),
              Text(widget.activity.name ?? "Medicacion",
                  textAlign: TextAlign.left,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xff999999)))
            ],
          ),
          if (showForm)
            DisableWidget(
              isDisable: true,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xffD9D9D9),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextFormField(
                                  controller: TextEditingController(
                                      text: widget.activity.name),
                                  /* onChanged: (value) {
                            activityNameFormValue = value;
                          }, */
                                  style: const TextStyle(fontSize: 14),
                                  decoration: StaticComponents()
                                      .getMiddleInputDecoration(
                                          'Nombre de la actividad')),
                            ),
                          ),
                          const SizedBox(width: 10),
                          /* CheckButton(
                            onTap: () async {},
                          ), */
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Tiempo",
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xff999999)))
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: SizedBox(
                              height: 35,
                              child: TextFormField(
                                //controller: activityTimeFormValue,
                                controller: TextEditingController(
                                    text: widget.activity.timeNumber),
                                onChanged: (value) {},
                                style: const TextStyle(fontSize: 14),
                                decoration: StaticComponents()
                                    .getMiddleInputDecoration('2'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          SizedBox(
                              width: 140,
                              height: 35,
                              child: Container(
                                //color: Colors.white,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          10) //         <--- border radius here
                                      ),
                                ),
                                child: TextFormField(
                                  //controller: activityTimeFormValue,
                                  controller: TextEditingController(
                                      text: widget.activity.timeType),
                                  onChanged: (value) {},
                                  style: const TextStyle(fontSize: 14),
                                  decoration: StaticComponents()
                                      .getMiddleInputDecoration('2'),
                                  keyboardType: TextInputType.number,
                                ),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class VizualizeExamnPrescriptionItem extends StatefulWidget {
  const VizualizeExamnPrescriptionItem({Key? key, required this.examn})
      : super(key: key);

  final ExamsPrescription examn;

  @override
  State<VizualizeExamnPrescriptionItem> createState() =>
      _VizualizeExamnPrescriptionItem();
}

class _VizualizeExamnPrescriptionItem
    extends State<VizualizeExamnPrescriptionItem> {
  bool showForm = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    showForm = !showForm;
                  });
                },
                child: const SizedBox(
                  height: 35,
                  child: Icon(Icons.keyboard_arrow_down,
                      size: 30,
                      color:
                          Color(0xff999999)), // myIcon is a 48px-wide widget.
                ),
              ),
              Text(widget.examn.name ?? "Medicacion",
                  textAlign: TextAlign.left,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xff999999)))
            ],
          ),
          if (showForm)
            DisableWidget(
                isDisable: true,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xffD9D9D9),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextFormField(
                                  controller: TextEditingController(
                                      text: widget.examn.name),
                                  style: const TextStyle(fontSize: 14),
                                  decoration: StaticComponents()
                                      .getMiddleInputDecoration(
                                          'Nombre del Exámen'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            //CheckButton(onTap: () async {})
                          ],
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Periocidad",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xff999999)))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: TextEditingController(
                              text: widget.examn.periodicity),
                          style: const TextStyle(fontSize: 14),
                          decoration: StaticComponents()
                              .getMiddleInputDecoration('Nombre del Exámen'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Fecha de próximo exámen",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xff999999)))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller:
                              TextEditingController(text: widget.examn.endDate),
                          style: const TextStyle(fontSize: 14),
                          decoration: StaticComponents()
                              .getMiddleInputDecoration('Nombre del Exámen'),
                        ),
                      ],
                    ),
                  ),
                ))
        ],
      ),
    );
  }
}
