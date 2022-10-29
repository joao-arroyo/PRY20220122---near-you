import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:near_you/Constants.dart';
import 'package:near_you/model/medicationPrescription.dart';
import 'package:near_you/model/treatment.dart';
import 'package:near_you/widgets/static_components.dart';

import '../model/activityPrescription.dart';
import '../model/examsPrescription.dart';
import '../model/nutritionPrescription.dart';
import '../screens/home_screen.dart';

class PrescriptionDetail extends StatefulWidget {
  final bool isDoctorView;
  Treatment? currentTreatment;

  int currentPageIndex;

  PrescriptionDetail(this.currentTreatment,
      {required this.isDoctorView, required this.currentPageIndex});

  factory PrescriptionDetail.forDoctorView(
      Treatment? paramTreatment, int currentPageIndex) {
    return PrescriptionDetail(paramTreatment,
        isDoctorView: true, currentPageIndex: currentPageIndex);
  }

  factory PrescriptionDetail.forPrescriptionView(Treatment? paramTreatment) {
    return PrescriptionDetail(
      paramTreatment,
      isDoctorView: false,
      currentPageIndex: 0,
    );
  }

  @override
  PrescriptionDetailState createState() =>
      PrescriptionDetailState(currentTreatment, isDoctorView, currentPageIndex);
}

class PrescriptionDetailState extends State<PrescriptionDetail> {
  static StaticComponents staticComponents = StaticComponents();
  Treatment? currentTreatment;
  int _currentPage = 0;
  late final PageController _pageController;
  bool isDoctorView = true;
  List<MedicationPrescription> medicationsList = <MedicationPrescription>[];
  List<NutritionPrescription> nutritionList = <NutritionPrescription>[];
  List<ActivityPrescription> activitiesList = <ActivityPrescription>[];
  List<NutritionPrescription> nutritionNoPermittedList =
      <NutritionPrescription>[];
  List<ActivityPrescription> activitiesNoPermittedList =
      <ActivityPrescription>[];
  List<ExamsPrescription> examsList = <ExamsPrescription>[];
  final TextEditingController imcTextController = TextEditingController();

  bool readOnlyMedication = false;
  bool isMedicationLoading = false;
  bool isNutritionLoading = false;
  bool isPhisicalActivityLoading = false;
  bool isExamnLoading = false;

  String? medicationStartDateValue;

  //String? medicationNameValue;
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

  //String? heightValue;
  String? imcValue;

  //String? weightValue;

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

  bool editingMedication = false;

  //bool editingExamn = false;

  bool editingPermittedFood = false;
  bool editingPermittedActivity = false;

  int updateMedication = -1;
  int updatePermittedFood = -1;
  int updateNoPermittedFood = -1;
  int updatePermittedActivity = -1;
  int updateNoPermittedActivity = -1;

  PrescriptionDetailState(
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

  void refreshMedicationPrescription() async {
    setState(() => isMedicationLoading = true);
    final medications = await getMedicationPrescriptions();
    medicationsList = medications;
    clearMedicationForm();
    setState(() => isMedicationLoading = false);
  }

  void refreshNutritionPrescription() async {
    setState(() => isNutritionLoading = true);
    final nutritions = await getNutritionPrescriptions();
    for (int i = 0; i < nutritions.length; i++) {
      if (nutritions[i].permitted == YES_KEY) {
        nutritionList.add(nutritions[i]);
      } else {
        nutritionNoPermittedList.add(nutritions[i]);
      }
    }
    if (nutritionList.isNotEmpty) {
      weightController.text = nutritionList[0].weight.toString();
      heightController.text = nutritionList[0].height.toString();
      imcTextController.text = nutritionList[0].imc.toString();
    }
    if (nutritionNoPermittedList.isNotEmpty) {
      weightController.text = nutritionNoPermittedList[0].weight.toString();
      heightController.text = nutritionNoPermittedList[0].height.toString();
      imcTextController.text = nutritionNoPermittedList[0].imc.toString();
    }
    editNotPermittedFood = false;
    editPermittedFood = false;
    setState(() => isNutritionLoading = false);
  }

  void clearMedicationForm() {
    medicationNameValue.clear();
    medicationPeriodicityValue = null;
    medicationRecommendationValue = null;
  }

  void refreshActivityPrescription() async {
    setState(() => isPhisicalActivityLoading = true);
    final response = await getActivityPrescriptions();
    activitiesList = response;
    setState(() => isPhisicalActivityLoading = false);
  }

  void refreshExamnPrescription() async {
    setState(() => isExamnLoading = true);
    final response = await getExamsPrescriptions();
    examsList = response;
    setState(() => isExamnLoading = false);
  }

  @override
  void initState() {
    refreshMedicationPrescription();
    refreshNutritionPrescription();
    refreshActivityPrescription();
    refreshExamnPrescription();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: HomeScreen.screenHeight * 0.8,
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
    imcTextController.dispose();
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
        childView = getExamnsView();
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

  getMedicationButtons() {
    return isDoctorView
        ? SizedBox(
            height: 190,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          onPressed: () async {
                            await saveMedicationInDatabase();
                          },
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                              Navigator.pop(context, _currentPage);
                            },
                            child: const Text(
                              'Cancelar',
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
        : const SizedBox(height: 0);
  }

  getAlimentationButtons() {
    return isDoctorView
        ? SizedBox(
            height: 190,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          onPressed: saveEachFoodInDatabase,
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                              Navigator.pop(context, _currentPage);
                            },
                            child: const Text(
                              'Cancelar',
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
        : const SizedBox(height: 0);
  }

  getActivityButtons() {
    return isDoctorView
        ? SizedBox(
            height: 190,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          onPressed: () async {
                            await saveActivityInDatabase();
                          },
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                              Navigator.pop(context, _currentPage);
                            },
                            child: const Text(
                              'Cancelar',
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
        : const SizedBox(height: 0);
  }

  getMedicationView() {
    return Container(
      width: double.infinity,
      height: HomeScreen.screenHeight * 0.65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isMedicationLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text("Medicamentos ",
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xff999999)))
                        ],
                      ),
                      sizedBox10,
                      SizedBox(
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: medicationsList.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 40),
                                          onPressed: () {
                                            showReadOnlyMedication(index);
                                          },
                                          icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 30,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        )),
                                    SizedBox(
                                        height: 35,
                                        width: 150,
                                        child: Text(
                                            medicationsList[index].name ??
                                                "Medicacion",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xff999999)))),
                                    SizedBox(
                                        height: 35,
                                        width: 14,
                                        child: IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 14),
                                          onPressed: () {
                                            showEditMedicationForm(index);
                                          },
                                          icon: const Icon(Icons.edit,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        )),
                                    SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 30),
                                          onPressed: () {
                                            //deleteMedication(index);
                                            deleteMedicationLocally(index);
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        ))
                                  ],
                                );
                              })),
                      sizedBox10,
                      getFormOrButtonAddMedication()
                    ],
                  ))),
    );
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
    //El databaseId cambia siempre que entramos en la pantalla
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
                  shape: const RoundedRectangleBorder(
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
    /*  Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => isDoctorView
                ? PrescriptionDetailScreen(detailedUser!.userId!)
                : HomeScreen()));*/
  }

  /* void validateAndSave() {
   final FormState? form = medicationFormState.currentState;
    bool durationValid = isNotEmtpy(durationTypeValue);
    bool stateValid = isNotEmtpy(pastilleValue);
    bool isValidDropdowns = durationValid && stateValid;
    durationTypeError = !durationValid;
    stateError = !stateValid;
    if ((form?.validate() ?? false) && isValidDropdowns) {
      //saveIdDatabase();
    }
  }*/

  /*  getFormOrButtonAddExamn() {
    if (editingExamn) {
      return SizedBox(
        width: double.infinity,
        height: 400,
        child: SingleChildScrollView(
            child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 200,
                ),
                child: Form(
                    //key: medicationFormState,
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
                                height: durationError ? 55 : 35,
                                width: 220,
                                child: TextFormField(
                                    controller: TextEditingController(text: medicationNameValue),
                                    onChanged: (value) {
                                      medicationNameValue = value;
                                    },
                                    style: const TextStyle(fontSize: 14),
                                    decoration: staticComponents
                                        .getMiddleInputDecoration('Nombre del examen')),
                              ),
                              Flexible(
                                  child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  setState(() {
                                    editingMedication = false;
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(15))),
                                  height: 30,
                                  width: 30,
                                  child: const Icon(Icons.check, color: Color(0xff999999)),
                                ),
                              ))
                            ],
                          ),
                          sizedBox10,

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Periodicidad",
                                  style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: stateError ? Colors.red : const Color(0xFF999999),
                                  width: 1),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(10) //         <--- border radius here
                                  ),
                            ),
                            child: SizedBox(
                              height: 35,
                              width: double.infinity,
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<String>(
                                    hint: const Text(
                                      'Seleccionar',
                                      style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
                                    ),
                                    dropdownColor: Colors.white,
                                    value: medicationPeriodicityValue,
                                    icon: const Padding(
                                      padding: EdgeInsetsDirectional.only(end: 12.0),
                                      child: Icon(Icons.keyboard_arrow_down,
                                          color:
                                              Color(0xff999999)), // myIcon is a 48px-wide widget.
                                    ),
                                    onChanged: (newValue) {
                                      setState(() {
                                        medicationPeriodicityValue = newValue.toString();
                                      });
                                    },
                                    items: periodicityList.map((String item) {
                                      return DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          sizedBox10,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Recomendación",
                                  style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                            ],
                          ),
                          sizedBox10,
                          TextFormField(
                            validator: (value) {
                              if (value == null || value == '') {
                                setState(() {
                                  durationError = true;
                                });
                                return "Complete el campo";
                              }
                              setState(() {
                                durationError = false;
                              });
                              return null;
                            },
                            controller: TextEditingController(text: medicationRecommendationValue),
                            onChanged: (value) {
                              medicationRecommendationValue = value;
                            },
                            style: const TextStyle(fontSize: 14),
                            minLines: 2,
                            maxLines: 10,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: staticComponents.getBigInputDecoration('Agregar texto'),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          // getPrescriptionButtons()
                        ],
                      ),
                    ),
                    getMedicationButtons()
                  ],
                )))),
      );
    }
    return GestureDetector(
        onTap: () {
          setState(() {
            editingMedication = true;
          });
        },
        child: TextField(
            minLines: 1,
            maxLines: 10,
            enabled: false,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: const Icon(Icons.circle, color: Colors.white),
              filled: true,
              fillColor: const Color(0xffD9D9D9),
              hintText: "Agregar medicamento",
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              focusedBorder: borderGray,
              border: borderGray,
              enabledBorder: borderGray,
            )
            // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

            ));
  } */

  bool addNewMedication = false;

  getFormOrButtonAddMedication() {
    return Column(children: [
      if (editingMedication || readOnlyMedication || addNewMedication) ...[
        buildMedicationForm()
      ] else ...[
        GestureDetector(
          onTap: () {
            setState(() {
              editingMedication = false;
              addNewMedication = true;
            });
          },
          child: TextField(
              minLines: 1,
              maxLines: 10,
              enabled: false,
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                prefixIcon: const Icon(Icons.circle, color: Colors.white),
                filled: true,
                fillColor: const Color(0xffD9D9D9),
                hintText: "Agregar medicamento",
                hintStyle:
                    const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                focusedBorder: borderGray,
                border: borderGray,
                enabledBorder: borderGray,
              )
              // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

              ),
        ),
      ],
      getMedicationButtons(),
    ]);
  }

  final TextEditingController medicationNameValue = TextEditingController();

  buildMedicationForm() {
    return Container(
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
                    isDisable: readOnlyMedication,
                    child: SizedBox(
                      height: durationError ? 55 : 35,
                      child: TextFormField(
                          controller: medicationNameValue,
                          style: const TextStyle(fontSize: 14),
                          decoration: staticComponents.getMiddleInputDecoration(
                              'Nombre del medicamento')),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DisableWidget(
                  isDisable: readOnlyMedication,
                  child: CheckButton(
                    onTap: () async {
                      addOrUpdateMedicationLocally();
                    },
                  ),
                )
              ],
            ),
            sizedBox10,

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Periodicidad",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999)))
              ],
            ),
            sizedBox10,
            DisableWidget(
              isDisable: readOnlyMedication,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: stateError ? Colors.red : const Color(0xFF999999),
                      width: 1),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10) //         <--- border radius here
                      ),
                ),
                child: SizedBox(
                  height: 35,
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        hint: Text(
                          medicationPeriodicityValue ?? 'Seleccionar',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black),
                        ),
                        dropdownColor: Colors.white,
                        icon: const Padding(
                          padding: EdgeInsetsDirectional.only(end: 12.0),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Color(
                                  0xff999999)), // myIcon is a 48px-wide widget.
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            medicationPeriodicityValue = newValue;
                          });
                        },
                        items: periodicityList.map((String item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            sizedBox10,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Descripción",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999)))
              ],
            ),
            sizedBox10,
            DisableWidget(
              isDisable: readOnlyMedication,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value == '') {
                    setState(() {
                      durationError = true;
                    });
                    return "Complete el campo";
                  }
                  setState(() {
                    durationError = false;
                  });
                  return null;
                },
                controller:
                    TextEditingController(text: medicationRecommendationValue),
                onChanged: (value) {
                  medicationRecommendationValue = value;
                },
                style: const TextStyle(fontSize: 14),
                minLines: 2,
                maxLines: 10,
                textAlignVertical: TextAlignVertical.center,
                decoration:
                    staticComponents.getBigInputDecoration('Agregar texto'),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // getPrescriptionButtons()
          ],
        ),
      ),
    );
  }

  final formKey = GlobalKey<FormState>();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  String? errorWeight;
  String? errorHeight;

  Widget getAlimentationView() {
    return Container(
      width: double.infinity,
      height: HomeScreen.screenHeight * 0.65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isNutritionLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  child: Form(
                    key: formKey,
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
                                //width: 150,
                                //height: 55,
                                child: TextFormField(
                              validator: (value) {
                                if (value == null || value == '') {
                                  return "Complete el campo";
                                }
                                return null;
                              },
                              onChanged: _calculateIMC,
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
                              onFieldSubmitted: _calculateIMC,
                              //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              //keyboardType: TextInputType.number,
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
                                //height: heightError ? 55 : 35,

                                child: TextFormField(
                                  validator: (value) {
                                    if (value == null || value == '') {
                                      return "Complete el campo";
                                    }
                                    double height = double.parse(value);
                                    if (height > 2.5 || height < 0.30) {
                                      return "Valido solo entre 0.30 y 2.5";
                                    }

                                    return null;
                                  },
                                  controller: heightController,
                                  /*  onChanged: (value) {
                                    heightValue = value;
                                  }, */
                                  onChanged: _calculateIMC,
                                  onFieldSubmitted: _calculateIMC,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 10),
                                    filled: true,
                                    isDense: true,
                                    fillColor: Colors.white,
                                    hintText: '1.65',
                                    hintStyle: const TextStyle(
                                        fontSize: 14, color: Color(0xFF999999)),
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
                            Icon(Icons.info, size: 18, color: Color(0xff999999))
                          ],
                        ),
                        sizedBox10,
                        SizedBox(
                            height: 35,
                            child: TextFormField(
                              enabled: false,
                              controller: imcTextController,
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0, horizontal: 10),
                                  filled: true,
                                  fillColor: const Color(0xffD9D9D9),
                                  hintText: '17.5',
                                  hintStyle: const TextStyle(
                                      fontSize: 14, color: Color(0xFF999999)),
                                  enabledBorder:
                                      StaticComponents().middleInputBorder,
                                  border: StaticComponents().middleInputBorder,
                                  focusedBorder:
                                      StaticComponents().middleInputBorder),
                            )),
                        sizedBox10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Text("Alimentos permitidos ",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xff999999))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        getPermittedFoodView(),
                        const SizedBox(height: 10),

                        //sizedBox10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Text("Alimentos no permitidos ",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xff999999))),
                          ],
                        ),
                        const SizedBox(height: 10),
                        getNotPermittedFoodView(),
                        const SizedBox(height: 10),
                        const SizedBox(height: 32),
                        getAlimentationButtons()
                      ],
                    ),
                  ))),
    );
  }

  bool readOnlyPermittedFood = false;

  Widget getPermittedFoodView() {
    return Column(
      children: [
        ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 100,
            ),
            //height: nutritionList.isNotEmpty ? 100 : null,
            child: Scrollbar(
              child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: nutritionList.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                            height: 35,
                            child: IconButton(
                              padding: const EdgeInsets.only(bottom: 40),
                              onPressed: () {
                                /* setState(() {
                                  readOnlyPermittedFood = !readOnlyPermittedFood;
                                }); */
                              },
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 30,
                                  color: Color(
                                      0xff999999)), // myIcon is a 48px-wide widget.
                            )),
                        const SizedBox(width: 10),
                        SizedBox(
                            height: 35,
                            child: Text(nutritionList[index].name ?? "Alimento",
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xff999999)))),
                        const Spacer(),
                        SizedBox(
                            height: 35,
                            width: 14,
                            child: IconButton(
                              padding: const EdgeInsets.only(bottom: 14),
                              onPressed: () {
                                showPermittedFoodForm(index);
                              },
                              icon: const Icon(Icons.edit,
                                  color: Color(
                                      0xff999999)), // myIcon is a 48px-wide widget.
                            )),
                        const SizedBox(width: 10),
                        SizedBox(
                            height: 35,
                            child: IconButton(
                              padding: const EdgeInsets.only(bottom: 30),
                              onPressed: () {
                                deletePermittedFoodLocally(index);
                              },
                              icon: const Icon(Icons.delete,
                                  color: Color(
                                      0xff999999)), // myIcon is a 48px-wide widget.
                            ))
                      ],
                    );
                  }),
            )),
        switchAddNutritionButtonOrForm(),
      ],
    );
  }

  bool editPermittedFood = false;
  bool addNewPermittedfood = false;
  final TextEditingController foodPermittedFormValue = TextEditingController();

  switchAddNutritionButtonOrForm() {
    return editPermittedFood || addNewPermittedfood
        ? Container(
            width: double.infinity,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextFormField(
                          controller: foodPermittedFormValue,
                          style: const TextStyle(fontSize: 14),
                          decoration: staticComponents
                              .getMiddleInputDecoration('Frutas')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CheckButton(
                    onTap: () async {
                      addOrUpdatePermittedFoodLocally();
                    },
                  )
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                editPermittedFood = false;
                addNewPermittedfood = true;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar alimento",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ),
          );
  }

  int currentNotPermitedFoodIndex = 0;
  bool readOnlyNotPermittedFood = false;

  Widget getNotPermittedFoodView() {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          child: Scrollbar(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: nutritionNoPermittedList.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: const EdgeInsets.only(bottom: 40),
                            onPressed: () {},
                            icon: const Icon(Icons.keyboard_arrow_down,
                                size: 30,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      const SizedBox(width: 10),
                      SizedBox(
                          height: 35,
                          child: Text(
                              nutritionNoPermittedList[index].name ??
                                  "Actividad",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xff999999)))),
                      const Spacer(),
                      SizedBox(
                          height: 35,
                          width: 14,
                          child: IconButton(
                            padding: const EdgeInsets.only(bottom: 14),
                            onPressed: () {
                              showNotPermittedFoodForm(index);
                            },
                            icon: const Icon(Icons.edit,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          )),
                      const SizedBox(width: 10),
                      SizedBox(
                          height: 35,
                          child: IconButton(
                            padding: const EdgeInsets.only(bottom: 30),
                            onPressed: () {
                              deleteNotPermittedFoodLocally(index);
                            },
                            icon: const Icon(Icons.delete,
                                color: Color(
                                    0xff999999)), // myIcon is a 48px-wide widget.
                          ))
                    ],
                  );
                }),
          ),
        ),
        switchAddNotPermittedNutritionButtonOrForm(),
      ],
    );
  }

  bool editNotPermittedFood = false;
  bool addNewNotPermittedfood = false;
  final TextEditingController foodNotPermittedForm = TextEditingController();

  switchAddNotPermittedNutritionButtonOrForm() {
    return editNotPermittedFood || addNewNotPermittedfood
        ? Container(
            width: double.infinity,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xffD9D9D9),
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextFormField(
                          controller: foodNotPermittedForm,
                          style: const TextStyle(fontSize: 14),
                          decoration: staticComponents
                              .getMiddleInputDecoration('Dulces')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CheckButton(onTap: () async {
                    addOrUpdateNotPermittedFoodLocally();
                  }),
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                editNotPermittedFood = false;
                addNewNotPermittedfood = true;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar alimento",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ));
  }

  getExamnsView() {
    return Container(
      width: double.infinity,
      height: HomeScreen.screenHeight * 0.65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isPhisicalActivityLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: examsList.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 40),
                                          onPressed: () {
                                            showReadOnlyExamn(index);
                                          },
                                          icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 30,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        )),
                                    SizedBox(
                                        height: 35,
                                        child: Text(
                                            examsList[index].name ?? "Exámenes",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xff999999)))),
                                    const Spacer(),
                                    SizedBox(
                                        height: 35,
                                        width: 14,
                                        child: IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 14),
                                          onPressed: () {
                                            editExam(index);
                                          },
                                          icon: const Icon(Icons.edit,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        )),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 30),
                                          onPressed: () {
                                            deleteExamnLocally(index);
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        ))
                                  ],
                                );
                              })),
                      sizedBox10,
                      getFormOrButtonExam(),

                      /*  buildPhisicalActivityForm(),
                      getActivityButtons(), */
                    ],
                  ))),
    );
  }

  bool editingExamn = false;
  bool addNewExamn = false;
  bool readOnlyExamn = false;

  Widget getFormOrButtonExam() {
    return Column(
      children: [
        if (editingExamn || readOnlyExamn || addNewExamn) ...[
          DisableWidget(isDisable: readOnlyExamn, child: buildExamnForm())
        ] else ...[
          GestureDetector(
              onTap: () {
                setState(() {
                  editingExamn = false;
                  addNewExamn = true;
                });
              },
              child: TextField(
                  minLines: 1,
                  maxLines: 10,
                  enabled: false,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    prefixIcon: const Icon(Icons.circle, color: Colors.white),
                    filled: true,
                    fillColor: const Color(0xffD9D9D9),
                    hintText: "Agregar Exámen",
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                    focusedBorder: borderGray,
                    border: borderGray,
                    enabledBorder: borderGray,
                  )
                  // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                  ))
        ],
        getExamsButtons()
      ],
    );
  }

  final TextEditingController examnNameFormValue = TextEditingController();
  String? examnDurationFormValue;
  String? examnEndDateFormValue;

  Widget buildExamnForm() {
    return Container(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextFormField(
                      controller: examnNameFormValue,
                      style: const TextStyle(fontSize: 14),
                      decoration: staticComponents
                          .getMiddleInputDecoration('Nombre del Exámen'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CheckButton(onTap: () async {
                  addOrUpdateExamnLocally();
                })
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Periocidad",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999)))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 40,
              width: double.infinity,
              //color: Colors.white,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: durationTypeError
                        ? Colors.red
                        : const Color(0xFF999999),
                    width: 1),
                borderRadius: const BorderRadius.all(
                    Radius.circular(10) //         <--- border radius here
                    ),
              ),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<String>(
                    hint: Text(
                      examnDurationFormValue ?? 'Duración',
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xff999999)),
                    onChanged: (newValue) {
                      setState(() {
                        examnDurationFormValue = newValue;
                      });
                    },
                    items: ['Diario', 'Semanal', 'Mensual'].map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Fecha de próximo exámen",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999)))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
                height: 40,
                child: TextFormField(
                  /* validator: (value) {
                    return null;
                  }, */
                  readOnly: true,
                  controller:
                      TextEditingController(text: examnEndDateFormValue),
                  onTap: () {
                    selectDateForNextExamn(context);
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                      filled: true,
                      prefixIcon: IconButton(
                        padding: const EdgeInsets.only(bottom: 5),
                        onPressed: () {},
                        icon: const Icon(Icons.calendar_today_outlined,
                            color: Color(
                                0xff999999)), // myIcon is a 48px-wide widget.
                      ),
                      hintText: '18 - Jul 2022  15:00',
                      hintStyle: const TextStyle(
                          fontSize: 14, color: Color(0xff999999)),
                      contentPadding: EdgeInsets.zero,
                      fillColor: Colors.white,
                      enabledBorder: staticComponents.middleInputBorder,
                      border: staticComponents.middleInputBorder,
                      focusedBorder: staticComponents.middleInputBorder),
                )),
          ],
        ),
      ),
    );
  }

  getPhisicalActivityView() {
    return Container(
      width: double.infinity,
      height: HomeScreen.screenHeight * 0.65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: isPhisicalActivityLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                          child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: activitiesList.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 40),
                                          onPressed: () {
                                            showReadOnlyActivity(index);
                                          },
                                          icon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 30,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        )),
                                    SizedBox(
                                        height: 35,
                                        child: Text(
                                            activitiesList[index].name ??
                                                "Actividad",
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xff999999)))),
                                    const Spacer(),
                                    SizedBox(
                                        height: 35,
                                        width: 14,
                                        child: IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 14),
                                          onPressed: () {
                                            editActivity(index);
                                          },
                                          icon: const Icon(Icons.edit,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        )),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                        height: 35,
                                        child: IconButton(
                                          padding:
                                              const EdgeInsets.only(bottom: 30),
                                          onPressed: () {
                                            deleteActivityLocally(index);
                                          },
                                          icon: const Icon(Icons.delete,
                                              color: Color(
                                                  0xff999999)), // myIcon is a 48px-wide widget.
                                        ))
                                  ],
                                );
                              })),
                      sizedBox10,
                      getFormOrButtonActivity(),

                      /*  buildPhisicalActivityForm(),
                      getActivityButtons(), */
                    ],
                  ))),
    );
  }

  bool editingActivity = false;
  bool addNewActivity = false;
  bool readOnlyActivity = false;

  Widget getFormOrButtonActivity() {
    return Column(
      children: [
        if (editingActivity || readOnlyActivity || addNewActivity) ...[
          DisableWidget(
              isDisable: readOnlyActivity, child: buildPhisicalActivityForm()),
        ] else ...[
          GestureDetector(
            onTap: () {
              setState(() {
                editingActivity = false;
                addNewActivity = true;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar Actividad",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )),
          ),
        ],
        getActivityButtons(),
      ],
    );
  }

  final TextEditingController activityNameFormValue = TextEditingController();
  final TextEditingController activityTimeFormValue = TextEditingController();
  String? activityDurationFormValue;

  Widget buildPhisicalActivityForm() {
    return Container(
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextFormField(
                        controller: activityNameFormValue,
                        /* onChanged: (value) {
                          activityNameFormValue = value;
                        }, */
                        style: const TextStyle(fontSize: 14),
                        decoration: staticComponents.getMiddleInputDecoration(
                            'Nombre de la actividad')),
                  ),
                ),
                const SizedBox(width: 10),
                CheckButton(
                  onTap: () async {
                    addOrUpdateActivityLocally();
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Tiempo",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999)))
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
                      controller: activityTimeFormValue,
                      /* controller: TextEditingController(text: medicationNameValue),
                      onChanged: (value) {
                        activityTimeFormValue = value;
                      }, */
                      style: const TextStyle(fontSize: 14),
                      decoration:
                          staticComponents.getMiddleInputDecoration('2'),
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: durationTypeError
                                ? Colors.red
                                : const Color(0xFF999999),
                            width: 1),
                        borderRadius: const BorderRadius.all(Radius.circular(
                                10) //         <--- border radius here
                            ),
                      ),
                      child: SizedBox(
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<String>(
                              hint: Text(
                                activityDurationFormValue ?? 'Horas',
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                              ),
                              dropdownColor: Colors.white,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Color(0xff999999)),
                              onChanged: (newValue) {
                                setState(() {
                                  activityDurationFormValue = newValue;
                                });
                              },
                              items: ['Horas', 'Minutos'].map((String item) {
                                return DropdownMenuItem(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }

  getButtonAddRoutineOrList() {
    return !editingPermittedActivity
        ? GestureDetector(
            onTap: () {
              setState(() {
                editingPermittedActivity = true;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar rutina física",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
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
                        onChanged: (value) {
                          activityNameValue = value;
                        },
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
                      )),
                  const Flexible(
                      child: SizedBox(
                          height: 35,
                          child: Icon(
                            Icons.check,
                            color: Color(0xff999999),
                          )))
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
                              color: Colors.white,
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
                        height: durationError ? 55 : 35,
                        width: 100,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value == '') {
                              setState(() {
                                durationError = true;
                              });
                              return "Complete el campo";
                            }
                            setState(() {
                              durationError = false;
                            });
                            return null;
                          },
                          controller: TextEditingController(
                              text: activityTimeNumberValue),
                          onChanged: (value) {
                            activityTimeNumberValue = value;
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration:
                              staticComponents.getMiddleInputDecoration('3'),
                        )),
                  ),
                  SizedBox(
                      height: 35,
                      width: 140,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: durationTypeError
                                  ? Colors.red
                                  : const Color(0xFF999999),
                              width: 1),
                          borderRadius: const BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Text(
                                  'Seleccionar',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF999999)),
                                ),
                                dropdownColor: Colors.white,
                                value: activityTimeTypeValue,
                                icon: const Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(end: 12.0),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(
                                          0xff999999)), // myIcon is a 48px-wide widget.
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    activityTimeTypeValue = newValue.toString();
                                  });
                                },
                                items: durationsActivityList.map((String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ))
                ],
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Periodicidad",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: stateError ? Colors.red : const Color(0xFF999999),
                      width: 1),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10) //         <--- border radius here
                      ),
                ),
                child: SizedBox(
                  height: 35,
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        hint: const Text(
                          'Seleccionar',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF999999)),
                        ),
                        dropdownColor: Colors.white,
                        value: activityPeriodicityValue,
                        icon: const Padding(
                          padding: EdgeInsetsDirectional.only(end: 12.0),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Color(
                                  0xff999999)), // myIcon is a 48px-wide widget.
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            activityPeriodicityValue = newValue.toString();
                          });
                        },
                        items: periodicityList.map((String item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
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
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                      return null;
                    },
                    controller:
                        TextEditingController(text: activityCaloriesValue),
                    onChanged: (value) {
                      activityCaloriesValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecoration('15 Kcal'),
                  )),
            ]));
  }

  getButtonAddProhibitedRoutineOrList() {
    return editingPermittedActivity
        ? GestureDetector(
            onTap: () {
              setState(() {
                editingPermittedActivity = false;
              });
            },
            child: TextField(
                minLines: 1,
                maxLines: 10,
                enabled: false,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  prefixIcon: const Icon(Icons.circle, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xffD9D9D9),
                  hintText: "Agregar rutina física",
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  focusedBorder: borderGray,
                  border: borderGray,
                  enabledBorder: borderGray,
                )
                // staticComponents.getLittleInputDecoration('Tratamiento de de la diabetes\n con 6 meses de pre...'),

                ))
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
                        onChanged: (value) {
                          activityNameValue = value;
                        },
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
                      )),
                  const Flexible(
                      child: SizedBox(
                          height: 35,
                          child: Icon(
                            Icons.check,
                            color: Color(0xff999999),
                          )))
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
                              color: Colors.white,
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
                        height: durationError ? 55 : 35,
                        width: 100,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value == '') {
                              setState(() {
                                durationError = true;
                              });
                              return "Complete el campo";
                            }
                            setState(() {
                              durationError = false;
                            });
                            return null;
                          },
                          controller: TextEditingController(
                              text: activityTimeNumberValue),
                          onChanged: (value) {
                            activityTimeNumberValue = value;
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration:
                              staticComponents.getMiddleInputDecoration('3'),
                        )),
                  ),
                  SizedBox(
                      height: 35,
                      width: 140,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: durationTypeError
                                  ? Colors.red
                                  : const Color(0xFF999999),
                              width: 1),
                          borderRadius: const BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: const Text(
                                  'Seleccionar',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF999999)),
                                ),
                                dropdownColor: Colors.white,
                                value: activityTimeTypeValue,
                                icon: const Padding(
                                  padding:
                                      EdgeInsetsDirectional.only(end: 12.0),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(
                                          0xff999999)), // myIcon is a 48px-wide widget.
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    activityTimeTypeValue = newValue.toString();
                                  });
                                },
                                items: durationsActivityList.map((String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ))
                ],
              ),
              sizedBox10,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Periodicidad",
                      style: TextStyle(fontSize: 14, color: Color(0xff999999)))
                ],
              ),
              sizedBox10,
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: stateError ? Colors.red : const Color(0xFF999999),
                      width: 1),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(10) //         <--- border radius here
                      ),
                ),
                child: SizedBox(
                  height: 35,
                  width: double.infinity,
                  child: DropdownButtonHideUnderline(
                    child: ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButton<String>(
                        hint: const Text(
                          'Seleccionar',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF999999)),
                        ),
                        dropdownColor: Colors.white,
                        value: activityPeriodicityValue,
                        icon: const Padding(
                          padding: EdgeInsetsDirectional.only(end: 12.0),
                          child: Icon(Icons.keyboard_arrow_down,
                              color: Color(
                                  0xff999999)), // myIcon is a 48px-wide widget.
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            activityPeriodicityValue = newValue.toString();
                          });
                        },
                        items: periodicityList.map((String item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
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
                  height: durationError ? 55 : 35,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value == '') {
                        setState(() {
                          durationError = true;
                        });
                        return "Complete el campo";
                      }
                      setState(() {
                        durationError = false;
                      });
                      return null;
                    },
                    controller:
                        TextEditingController(text: activityCaloriesValue),
                    onChanged: (value) {
                      activityCaloriesValue = value;
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration:
                        staticComponents.getMiddleInputDecoration('15 Kcal'),
                  )),
            ]));
  }

  getExamsButtons() {
    return isDoctorView
        ? SizedBox(
            height: 190,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          onPressed: () async {
                            await saveExamnInDatabase();
                          },
                          child: const Text(
                            'Guardar',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
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
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Cancelar',
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
        : const SizedBox(height: 0);
  }

  /*  Future<void> saveExamnInDatabase() async {
    final db = FirebaseFirestore.instance;
    final String currentTreatmentDatabaseId = currentTreatment!.databaseId!;
    final data = <String, String>{
      TREATMENT_ID_KEY: currentTreatmentDatabaseId,
      EXAMN_NAME_KEY: examnNameFormValue.text,
      EXAMN_PERIODICITY_KEY: examnDurationFormValue ?? "",
      EXAMN_END_DATE_KEY: examnEndDateFormValue ?? "",
    };

    if (editingExamn) {
      String? databaseId = examnList[activityIndex].databaseId;
      await db.collection(EXAMN_PRESCRIPTION_COLLECTION_KEY).doc(databaseId).update(data);
    } else {
      var value = await db.collection(EXAMN_PRESCRIPTION_COLLECTION_KEY).add(data);
      saveInPendingList(
          PENDING_EXAMN_PRESCRIPTIONS_COLLECTION_KEY, value.id, currentTreatmentDatabaseId);
    }

    /* then((value) => saveInPendingListAndGoBack(
        PENDING_Others_PRESCRIPTIONS_COLLECTION_KEY, value.id, currentTreatmentDatabaseId)); */
  } */

  /*  Future<void> saveActivityInDatabase() async {
    final db = FirebaseFirestore.instance;
    final String currentTreatmentDatabaseId = currentTreatment!.databaseId!;
    final data = <String, String>{
      TREATMENT_ID_KEY: currentTreatmentDatabaseId,
      ACTIVITY_NAME_KEY: activityNameFormValue.text,
      //ACTIVITY_ACTIVITY_KEY: activityActivityValue ?? "",
      ACTIVITY_TIME_NUMBER_KEY: activityTimeFormValue.text,
      ACTIVITY_TIME_TYPE_KEY: activityDurationFormValue ?? "",
      //ACTIVITY_PERIODICITY_KEY: activityPeriodicityValue ?? "",
      //ACTIVITY_CALORIES_KEY: activityCaloriesValue ?? "",
      //PERMITTED_KEY: editingPermittedActivity ? YES_KEY : NO_KEY
    };

    /*  if (updatePermittedActivity >= 0 || updateNoPermittedActivity >= 0) {
      String? databaseId;
      if (updatePermittedActivity >= 0) {
        databaseId = activitiesList[updatePermittedActivity].databaseId;
      } else {
        databaseId = activitiesNoPermittedList[updateNoPermittedActivity].databaseId;
      }

      db
          .collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY)
          .doc(databaseId)
          .update(data)
          .then((value) => Navigator.pop(context, _currentPage));
    } else { */
    if (editingActivity) {
      String? databaseId = activitiesList[activityIndex].databaseId;
      await db.collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY).doc(databaseId).update(data);
    } else {
      final response = await db.collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY).add(data);
      await saveInPendingList(
          PENDING_ACTIVITY_PRESCRIPTIONS_COLLECTION_KEY, response.id, currentTreatmentDatabaseId);
    }

    /*  .then((value) =>
          saveInPendingList(
              PENDING_ACTIVITY_PRESCRIPTIONS_COLLECTION_KEY, value.id, currentTreatmentDatabaseId)); */
    //}
  } */

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  get firebase => FirebaseFirestore.instance;

  String get currentTreatmentDatabaseId => currentTreatment!.databaseId!;

  Future<void> saveMedicationInDatabase() async {
    final currentCollection =
        firebase.collection(MEDICATION_PRESCRIPTION_COLLECTION_KEY);
    if (medicationsList.isNotEmpty) {
      for (var index = 0; index < medicationsList.length; index++) {
        String? databaseId = medicationsList[index].databaseId;
        final medication = medicationsList[index];

        final data = <String, String>{
          TREATMENT_ID_KEY: currentTreatmentDatabaseId,
          MEDICATION_NAME_KEY: medication.name ?? '',
          MEDICATION_PERIODICITY_KEY: medication.periodicity ?? "",
          MEDICATION_RECOMMENDATION_KEY: medication.recomendation ?? ""
        };

        if (await docExits(
            databaseId, MEDICATION_PRESCRIPTION_COLLECTION_KEY)) {
          currentCollection.doc(databaseId).update(data);
        } else {
          final response = await currentCollection.add(data);
          saveInPendingList(PENDING_MEDICATION_PRESCRIPTIONS_COLLECTION_KEY,
              response.id, currentTreatmentDatabaseId);
        }
      }
    }
    if (tempDeletedMedicationIdForLater.isNotEmpty) {
      for (var i = 0; i < tempDeletedMedicationIdForLater.length; i++) {
        String id = tempDeletedMedicationIdForLater[i];
        currentCollection.doc(id).delete();
      }
    }
    if (mounted) {
      Navigator.pop(context, _currentPage);
    }
  }

  void addOrUpdateMedicationLocally() {
    if (editingMedication) {
      setState(() {
        medicationsList[updateMedication] = medicationsList[updateMedication]
          ..name = medicationNameValue.text
          ..periodicity = medicationPeriodicityValue
          ..recomendation = medicationRecommendationValue;
      });
    } else {
      setState(() {
        editingMedication = false;
      });
      setState(() {
        medicationsList.add(MedicationPrescription(
          name: medicationNameValue.text,
          periodicity: medicationPeriodicityValue,
          recomendation: medicationRecommendationValue,
        ));
      });
    }
    addNewMedication = false;
    editingMedication = false;
    clearMedicationForm();
  }

  Future<bool> docExits(String? id, String collectionId) async {
    var document =
        await FirebaseFirestore.instance.collection(collectionId).doc(id).get();
    return document.exists;
  }

  List<String> tempDeletedMedicationIdForLater = [];

  void showReadOnlyMedication(int index) {
    setState(() {
      readOnlyMedication = !readOnlyMedication;
      editingMedication = false;
      addNewMedication = false;
    });
    if (readOnlyMedication) {
      fillMedicationFormWithValues(index);
    } else {
      clearMedicationForm();
    }
  }

  void deleteMedicationLocally(int index) {
    setState(() {
      String? databaseId = medicationsList[index].databaseId;
      bool exits = databaseId != null;
      if (exits) {
        tempDeletedMedicationIdForLater.add(databaseId);
      }
      medicationsList.removeAt(index);
    });
  }

  void showEditMedicationForm(int index) {
    setState(() {
      editingMedication = true;
      addNewMedication = false;
      updateMedication = index;
      fillMedicationFormWithValues(index);
      readOnlyMedication = false;
    });
  }

  void fillMedicationFormWithValues(int index) {
    medicationNameValue.text = medicationsList[index].name ?? "";
    medicationPeriodicityValue = medicationsList[index].periodicity ?? "";
    medicationRecommendationValue = medicationsList[index].recomendation ?? "";
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> saveActivityInDatabase() async {
    final currentCollection =
        firebase.collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY);
    if (activitiesList.isNotEmpty) {
      for (var index = 0; index < activitiesList.length; index++) {
        String? databaseId = activitiesList[index].databaseId;
        final activity = activitiesList[index];

        final data = <String, String>{
          TREATMENT_ID_KEY: currentTreatmentDatabaseId,
          ACTIVITY_NAME_KEY: activity.name ?? '',
          ACTIVITY_TIME_NUMBER_KEY: activity.timeNumber ?? '',
          ACTIVITY_TIME_TYPE_KEY: activity.timeType ?? "",
        };

        if (await docExits(databaseId, ACTIVITY_PRESCRIPTION_COLLECTION_KEY)) {
          currentCollection.doc(databaseId).update(data);
        } else {
          final response = await currentCollection.add(data);
          saveInPendingList(PENDING_ACTIVITY_PRESCRIPTIONS_COLLECTION_KEY,
              response.id, currentTreatmentDatabaseId);
        }
      }
    }
    if (tempDeletedActivityIdForLater.isNotEmpty) {
      for (var i = 0; i < tempDeletedActivityIdForLater.length; i++) {
        String id = tempDeletedActivityIdForLater[i];
        currentCollection.doc(id).delete();
      }
    }
    if (mounted) {
      Navigator.pop(context, _currentPage);
    }
  }

  void showReadOnlyActivity(int index) {
    setState(() {
      readOnlyActivity = !readOnlyActivity;
      editingActivity = false;
      addNewActivity = false;
    });
    if (readOnlyActivity) {
      fillActivityFormWithValues(index);
    } else {
      clearActivityForm();
    }
  }

  List<String> tempDeletedActivityIdForLater = [];

  void deleteActivityLocally(int index) {
    setState(() {
      String? databaseId = activitiesList[index].databaseId;
      bool exits = databaseId != null;
      if (exits) {
        tempDeletedActivityIdForLater.add(databaseId);
      }
      activitiesList.removeAt(index);
    });
  }

  int activityIndex = 0;

  void showEditActivityForm(int index) {
    setState(() {
      editingActivity = true;
      addNewActivity = false;
      activityIndex = index;
      fillActivityFormWithValues(index);
      readOnlyActivity = false;
    });
  }

  fillActivityFormWithValues(int index) {
    activityNameFormValue.text = activitiesList[index].name ?? '';
    activityTimeFormValue.text = activitiesList[index].timeNumber ?? '';
    activityDurationFormValue = activitiesList[index].timeType ?? '';
  }

  clearActivityForm() {
    activityNameFormValue.clear();
    activityTimeFormValue.clear();
    activityDurationFormValue = null;
  }

  void addOrUpdateActivityLocally() {
    if (editingActivity) {
      setState(() {
        activitiesList[activityIndex] = activitiesList[activityIndex]
          ..name = activityNameFormValue.text
          ..timeType = activityDurationFormValue
          ..timeNumber = activityTimeFormValue.text;
      });
    } else {
      setState(() {
        editingActivity = false;
      });
      setState(() {
        activitiesList.add(ActivityPrescription(
          name: activityNameFormValue.text,
          timeNumber: activityTimeFormValue.text,
          timeType: activityDurationFormValue,
        ));
      });
    }
    addNewActivity = false;
    editingActivity = false;
    clearActivityForm();
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> saveExamnInDatabase() async {
    final currentCollection =
        firebase.collection(EXAMS_PRESCRIPTION_COLLECTION_KEY);
    if (examsList.isNotEmpty) {
      for (var index = 0; index < examsList.length; index++) {
        String? databaseId = examsList[index].databaseId;
        final examn = examsList[index];

        final data = <String, String>{
          TREATMENT_ID_KEY: currentTreatmentDatabaseId,
          EXAMN_NAME_KEY: examn.name ?? '',
          EXAMN_PERIODICITY_KEY: examn.periodicity ?? "",
          EXAMN_END_DATE_KEY: examn.endDate ?? "",
        };

        if (await docExits(databaseId, EXAMS_PRESCRIPTION_COLLECTION_KEY)) {
          currentCollection.doc(databaseId).update(data);
        } else {
          final response = await currentCollection.add(data);
          saveInPendingList(PENDING_EXAMS_PRESCRIPTIONS_COLLECTION_KEY,
              response.id, currentTreatmentDatabaseId);
        }
      }
    }
    if (tempDeletedExamnIdForLater.isNotEmpty) {
      for (var i = 0; i < tempDeletedExamnIdForLater.length; i++) {
        String id = tempDeletedExamnIdForLater[i];
        currentCollection.doc(id).delete();
      }
    }
    if (mounted) {
      Navigator.pop(context, _currentPage);
    }
  }

  void showReadOnlyExamn(int index) {
    setState(() {
      readOnlyExamn = !readOnlyExamn;
      editingExamn = false;
      addNewExamn = false;
    });
    if (readOnlyExamn) {
      fillExamnFormWithValues(index);
    } else {
      clearExamnForm();
    }
  }

  List<String> tempDeletedExamnIdForLater = [];

  void deleteExamnLocally(int index) {
    setState(() {
      String? databaseId = examsList[index].databaseId;
      bool exits = databaseId != null;
      if (exits) {
        tempDeletedExamnIdForLater.add(databaseId);
      }
      examsList.removeAt(index);
    });
  }

  int examnIndex = 0;

  void showEditExamnForm(int index) {
    setState(() {
      editingExamn = true;
      addNewExamn = false;
      examnIndex = index;
      fillExamnFormWithValues(index);
      readOnlyExamn = false;
    });
  }

  fillExamnFormWithValues(int index) {
    examnNameFormValue.text = examsList[index].name ?? '';
    examnDurationFormValue = examsList[index].periodicity ?? "";
    examnEndDateFormValue = examsList[index].endDate ?? '';
  }

  clearExamnForm() {
    examnNameFormValue.clear();
    examnDurationFormValue = null;
    examnEndDateFormValue = null;
  }

  void addOrUpdateExamnLocally() {
    if (editingExamn) {
      setState(() {
        examsList[examnIndex] = examsList[examnIndex]
          ..name = examnNameFormValue.text
          ..periodicity = examnDurationFormValue
          ..endDate = examnEndDateFormValue;
      });
    } else {
      setState(() {
        editingExamn = false;
      });
      setState(() {
        examsList.add(ExamsPrescription(
            name: examnNameFormValue.text,
            periodicity: examnDurationFormValue,
            endDate: examnEndDateFormValue));
      });
    }
    addNewExamn = false;
    editingExamn = false;
    clearExamnForm();
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void addOrUpdatePermittedFoodLocally() {
    if (editPermittedFood) {
      setState(() {
        nutritionList[currentPermitedFoodIndex] =
            nutritionList[currentPermitedFoodIndex]
              ..name = foodPermittedFormValue.text;
      });
    } else {
      setState(() {
        editPermittedFood = false;
      });
      setState(() {
        nutritionList.add(NutritionPrescription(
          name: foodPermittedFormValue.text,
          permitted: YES_KEY,
        ));
      });
    }
    addNewPermittedfood = false;
    editPermittedFood = false;
    foodPermittedFormValue.clear();
  }

  List<String> tempDeletedPermittedFoodForLater = [];

  void deletePermittedFoodLocally(int index) {
    setState(() {
      String? databaseId = nutritionList[index].databaseId;
      bool exits = databaseId != null;
      if (exits) {
        tempDeletedPermittedFoodForLater.add(databaseId);
      }
      nutritionList.removeAt(index);
    });
  }

  int currentPermitedFoodIndex = 0;

  void showPermittedFoodForm(int index) {
    setState(() {
      editPermittedFood = true;
      addNewPermittedfood = false;
      currentPermitedFoodIndex = index;
      foodPermittedFormValue.text = nutritionList[index].name ?? '';
    });
  }

  ////NOT PERMITED////////////////////////////////////////////////////////////////////////////////////

  void addOrUpdateNotPermittedFoodLocally() {
    if (editNotPermittedFood) {
      setState(() {
        nutritionNoPermittedList[currentNotPermitedFoodIndex] =
            nutritionNoPermittedList[currentNotPermitedFoodIndex]
              ..name = foodNotPermittedForm.text;
      });
    } else {
      setState(() {
        editNotPermittedFood = false;
      });
      setState(() {
        nutritionNoPermittedList.add(NutritionPrescription(
          name: foodNotPermittedForm.text,
          permitted: NO_KEY,
        ));
      });
    }
    addNewNotPermittedfood = false;
    editNotPermittedFood = false;
    foodNotPermittedForm.clear();
  }

  List<String> tempDeletedNotPermittedFoodForLater = [];

  void deleteNotPermittedFoodLocally(int index) {
    setState(() {
      String? databaseId = nutritionNoPermittedList[index].databaseId;
      bool exits = databaseId != null;
      if (exits) {
        tempDeletedNotPermittedFoodForLater.add(databaseId);
      }
      nutritionNoPermittedList.removeAt(index);
    });
  }

  void showNotPermittedFoodForm(int index) {
    setState(() {
      editNotPermittedFood = true;
      addNewNotPermittedfood = false;
      currentNotPermitedFoodIndex = index;
      foodNotPermittedForm.text = nutritionNoPermittedList[index].name ?? '';
    });
  }

  void saveEachFoodInDatabase() async {
    if (!formKey.currentState!.validate() ||
        (nutritionList.isEmpty && nutritionNoPermittedList.isEmpty)) return;

    if (nutritionList.isNotEmpty) {
      for (var i = 0; i < nutritionList.length; i++) {
        saveFoodInDatabase(nutritionList[i]);
      }
    }

    if (tempDeletedPermittedFoodForLater.isNotEmpty) {
      for (var i = 0; i < tempDeletedPermittedFoodForLater.length; i++) {
        String id = tempDeletedPermittedFoodForLater[i];
        firebase
            .collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY)
            .doc(id)
            .delete();
      }
    }

    if (nutritionNoPermittedList.isNotEmpty) {
      for (var i = 0; i < nutritionNoPermittedList.length; i++) {
        saveFoodInDatabase(nutritionNoPermittedList[i]);
      }
    }

    if (tempDeletedNotPermittedFoodForLater.isNotEmpty) {
      for (var i = 0; i < tempDeletedNotPermittedFoodForLater.length; i++) {
        String id = tempDeletedNotPermittedFoodForLater[i];
        firebase
            .collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY)
            .doc(id)
            .delete();
      }
    }

    if (mounted) {
      Navigator.pop(context, _currentPage);
    }
  }

  //databaseID = FoW5LrG3K132gAYKEdeS
  Future<void> saveFoodInDatabase(NutritionPrescription food) async {
    String? databaseId = food.databaseId;
    final currentCollection =
        firebase.collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY);
    final data = {
      TREATMENT_ID_KEY: currentTreatmentDatabaseId,
      NUTRITION_NAME_KEY: food.name ?? "",
      NUTRITION_HEIGHT_KEY: heightController.text,
      NUTRITION_WEIGHT_KEY: weightController.text,
      NUTRITION_IMC_KEY: imcTextController.text,
      PERMITTED_KEY: food.permitted,
    };

    if (await docExits(databaseId, NUTRITION_PRESCRIPTION_COLLECTION_KEY)) {
      currentCollection.doc(databaseId).update(data);
    } else {
      final response = await currentCollection.add(data);
      saveInPendingList(PENDING_NUTRITION_PRESCRIPTIONS_COLLECTION_KEY,
          response.id, currentTreatmentDatabaseId);
    }
  }

  Future<void> updateFoodInDatabase(
      String? foodName, bool isPermitted, int index) async {
    //final String treatmentId = currentTreatment!.databaseId!;
    String? databaseid;
    if (isPermitted) {
      databaseid = nutritionList[index].databaseId;
    } else {
      databaseid = nutritionNoPermittedList[index].databaseId;
    }
    //isPermitted ? nutritionNoPermittedList[index].databaseId : nutritionList[index].databaseId;
    final db = FirebaseFirestore.instance;
    final data = {
      NUTRITION_NAME_KEY: foodName ?? "",
      NUTRITION_HEIGHT_KEY: heightController.text,
      NUTRITION_WEIGHT_KEY: weightController.text,
      NUTRITION_IMC_KEY: imcTextController.text,
    };
    await db
        .collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY)
        .doc(databaseid)
        .update(data);
  }

  //krxDLN2L3HBFlQHw9adS

  Map<String, String> makeFoodStructure(
      String? foodName, bool isPermitted, String treatmentId) {
    return {
      TREATMENT_ID_KEY: treatmentId,
      NUTRITION_NAME_KEY: foodName ?? "",
      NUTRITION_HEIGHT_KEY: heightController.text,
      NUTRITION_WEIGHT_KEY: weightController.text,
      NUTRITION_IMC_KEY: imcTextController.text,
      PERMITTED_KEY: isPermitted ? YES_KEY : NO_KEY,
    };
  }

  Future<void> saveInPendingList(
      String idKey, String prescriptionId, String currentTreatmentDatabaseId,
      {bool dontGoBack = false}) async {
    final db = FirebaseFirestore.instance;
    final data = <String, String>{
      PENDING_PRESCRIPTIONS_ID_KEY: prescriptionId,
      PENDING_PRESCRIPTIONS_TREATMENT_KEY: currentTreatmentDatabaseId,
    };
    await db.collection(idKey).add(data);
    /* .then((value) =>
        dontGoBack ? refreshMedicationPrescription() : Navigator.pop(context, _currentPage)); */
  }

  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(21001, 1, 1),
    );

    final TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (d != null && time != null) {
      setState(() {
        medicationStartDateValue =
            '${DateFormat('dd - MMM yyyy ').format(d)}${time.hour}:${time.minute}';
      });
    }
  }

  Future<void> selectDateForNextExamn(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime(21001, 1, 1),
    );

    final TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (d != null && time != null) {
      setState(() {
        examnEndDateFormValue =
            '${DateFormat('dd - MMM yyyy ').format(d)}${time.hour}:${time.minute}';
      });
    }
  }

  void deleteMedication(int index) {
    final db = FirebaseFirestore.instance;
    db
        .collection(MEDICATION_PRESCRIPTION_COLLECTION_KEY)
        .doc(medicationsList[index].databaseId)
        .delete();
    setState(() {
      medicationsList.removeAt(index);
    });
  }

  void deleteActivity(int index) {
    final db = FirebaseFirestore.instance;
    db
        .collection(ACTIVITY_PRESCRIPTION_COLLECTION_KEY)
        .doc(activitiesList[index].databaseId)
        .delete();
    setState(() {
      activitiesList.removeAt(index);
    });
  }

  void deleteExamn(int index) {
    final db = FirebaseFirestore.instance;
    db
        .collection(EXAMS_PRESCRIPTION_COLLECTION_KEY)
        .doc(examsList[index].databaseId)
        .delete();
    setState(() {
      examsList.removeAt(index);
    });
  }

  void deleteNutritionPermitted(int index, bool permitted) {
    String? deleteId;
    if (permitted) {
      deleteId = nutritionList[index].databaseId;
      setState(() {
        nutritionList.removeAt(index);
      });
    } else {
      deleteId = nutritionNoPermittedList[index].databaseId;
      setState(() {
        nutritionNoPermittedList.removeAt(index);
      });
    }
    final db = FirebaseFirestore.instance;
    db.collection(NUTRITION_PRESCRIPTION_COLLECTION_KEY).doc(deleteId).delete();
  }

  void editActivity(int index) {
    setState(() {
      editingActivity = true;
      addNewActivity = false;
      activityIndex = index;
      fillActivityFormWithValues(index);
      readOnlyActivity = false;
    });
  }

  int currentExamnIndex = 0;

  void editExam(int index) {
    setState(() {
      editingExamn = true;
      addNewExamn = false;
      currentExamnIndex = index;
      fillExamnFormWithValues(index);
      readOnlyExamn = false;
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

  void _calculateIMC(String value) {
    if (!formKey.currentState!.validate()) return;
    double height = double.parse(
        heightController.text.isEmpty ? '0.0' : heightController.text);
    double weight = double.parse(
        weightController.text.isEmpty ? '0.0' : weightController.text);
    if (height != 0.0 && weight != 0.0) {
      imcTextController.text = (weight / (pow(height, 2))).toStringAsFixed(2);
    }
  }
}

class DisableWidget extends StatelessWidget {
  const DisableWidget({Key? key, this.isDisable = false, required this.child})
      : super(key: key);

  final bool isDisable;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
        ignoring: isDisable,
        child: Opacity(opacity: isDisable ? 0.5 : 1, child: child));
  }
}

class CheckButton extends StatelessWidget {
  const CheckButton({Key? key, required this.onTap}) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
            color: Color(0xff6EC6A4),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        height: 30,
        width: 30,
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
