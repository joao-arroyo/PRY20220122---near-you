import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:near_you/common/survey_static_values.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants.dart';
import '../main.dart';
import 'home_screen.dart';

class SurveyScreen extends StatefulWidget {
  String userId;
  String userName;

  SurveyScreen(this.userId, this.userName);

  static const routeName = '/survey';

  @override
  _SurveyScreenState createState() => _SurveyScreenState(userId, userName);
}

class _SurveyScreenState extends State<SurveyScreen> {
  static List<SurveyData> surveyList = <SurveyData>[];
  static List<String?> surveyResults = List.filled(surveyList.length, '0');

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userId;
  String userName;
  late final Future<List<SurveyData>> futureSurvey;

  double percentageProgress = 0;

  _SurveyScreenState(this.userId, this.userName);

  @override
  void initState() {
    futureSurvey = getSurveyQuestions();
    futureSurvey.then((value) => {
          setState(() {
            surveyList = value;
            surveyResults = List.filled(surveyList.length, null);
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
            preferredSize: const Size.fromHeight(80), // here the desired height
            child: AppBar(
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.white),
                  onPressed: () {
                    //
                  },
                )
              ],
              backgroundColor: const Color(0xff2F8F9D),
              centerTitle: true,
              title: const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text('Encuestas',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold))),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )),
        body: Stack(children: <Widget>[
          SizedBox(
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
                  return SizedBox(
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
                            const SizedBox(
                              height: 10,
                            ),
                            FutureBuilder(
                              future: futureSurvey,
                              builder: (context, AsyncSnapshot snapshot) {
                                //patientUser = user.User.fromSnapshot(snapshot.data);
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return getScreenType();
                                }
                                return const CircularProgressIndicator();
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
      )
    ]);
  }

  getScreenType() {
    if (surveyList.isEmpty) {
      return noSurveyView();
    }
    return SizedBox(
      width: 400,
      height: HomeScreen.screenHeight,
      child: Padding(
          padding:
              const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
                  Widget>[
            GFProgressBar(
              percentage: percentageProgress,
              lineHeight: 17,
              backgroundColor: const Color(0xffD9D9D9),
              progressBarColor: const Color(0xff2F8F9D),
              child: Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  (100 * percentageProgress).toInt().toString() + '%',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Text(
                'Hola $userName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2F8F9D),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              width: double.infinity,
              height: HomeScreen.screenHeight * 0.7,
              child: SingleChildScrollView(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 200,
                      ),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: const <Widget>[
                                    Text(
                                      "Tienes una encuesta pendiente",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff2F8F9D),
                                      ),
                                    )
                                  ]),
                              const SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                  child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: surveyList.length,
                                      itemBuilder: (context, index) {
                                        return Column(children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Flexible(
                                                  child: Text(
                                                surveyList[index].question,
                                                style: const TextStyle(
                                                    color: Color(0xff67757F),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ))
                                            ],
                                          ),
                                          SizedBox(
                                            child: ListView.builder(
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount: surveyList[index]
                                                    .options
                                                    .length,
                                                itemBuilder: (context, i) {
                                                  return ListTile(
                                                      dense: true,
                                                      leading: Radio<String>(
                                                        visualDensity:
                                                            const VisualDensity(
                                                          horizontal:
                                                              VisualDensity
                                                                  .minimumDensity,
                                                          vertical: VisualDensity
                                                              .minimumDensity,
                                                        ),
                                                        fillColor:
                                                            MaterialStateProperty
                                                                .resolveWith<
                                                                    Color>((Set<
                                                                        MaterialState>
                                                                    states) {
                                                          return const Color(
                                                              0xff999999);
                                                        }),
                                                        value: i.toString(),
                                                        /*  value: (surveyList[index].options.length -
                                                                i -
                                                                1)
                                                            .toString(), */
                                                        groupValue:
                                                            surveyResults[
                                                                index],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            surveyResults[
                                                                index] = value!;
                                                            int currentTotal =
                                                                0;
                                                            for (int j = 0;
                                                                j <
                                                                    surveyResults
                                                                        .length;
                                                                j++) {
                                                              if (surveyResults[
                                                                      j] !=
                                                                  null) {
                                                                currentTotal++;
                                                              }
                                                            }
                                                            percentageProgress =
                                                                currentTotal /
                                                                    surveyResults
                                                                        .length;
                                                          });
                                                        },
                                                      ),
                                                      title: Text(
                                                        "${surveyList[index].options.length - i}.- ${surveyList[index].options[i]}",
                                                        style: const TextStyle(
                                                            color: Color(
                                                                0xff67757F),
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                        textAlign:
                                                            TextAlign.left,
                                                      ));
                                                }),
                                          ),
                                          const SizedBox(height: 10)
                                        ]);
                                      })),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  FlatButton(
                                    disabledColor: const Color(0xffD9D9D9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    color: const Color(0xff2F8F9D),
                                    textColor: Colors.white,
                                    onPressed: percentageProgress == 1
                                        ? saveAndGoBack
                                        : null,
                                    child: const Text(
                                      'Enviar',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  )
                                ],
                              )
                            ],
                          )))),
            ),
          ])
          //Column
          ), //Padding
    );
  }

  Future<List<SurveyData>> getSurveyQuestions() async {
    return StaticSurvey.surveyStaticList;
  }

  noSurveyView() {
    return SizedBox(
      width: double.infinity,
      height: 470,
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const <Widget>[
                SizedBox(
                  height: 200,
                ),
                Text(
                  'Ya has completado  \nla encuesta',
                  textAlign: TextAlign.center,
                  maxLines: 5,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xff999999),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                SizedBox(
                  height: 10,
                ),
              ])),
    );
  }

  void saveAndGoBack() {
    saveSharedPreferencesDate();
    final db = FirebaseFirestore.instance;
    final data = <String, String>{};
    for (int i = 0; i < surveyResults.length; i++) {
      int number = i + 1;
      data.putIfAbsent("Pregunta$number", () => surveyResults[i]!);
    }
    data.addAll({
      SURVEY_TIMESTAMP_KEY: DateTime.now().millisecondsSinceEpoch.toString()
    });
    db
        .collection(USERS_COLLECTION_KEY)
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection(SURVEY_COLLECTION_KEY)
        .add(data)
        .then((value) => dialogSuccess());
  }

  void dialogSuccess() {
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
                        height: 10,
                      ),
                      SvgPicture.asset(
                        'assets/images/success_icon_modal.svg',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Encuesta\n completada',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                          '¡Gracias por completar el\nprogreso de su adherencia',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff999999))),
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
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            HomeScreen()));
                              },
                              child: const Text(
                                'Aceptar',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
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

  Future<void> saveSharedPreferencesDate() async {
    MyApp.dateNextSurvey = DateFormat('dd-MM-yyyy')
        .format(DateTime.now().add(const Duration(days: 7)));
    updateDateInFirebase();
    FirebaseMessaging.instance.subscribeToTopic(MyApp.dateNextSurvey!);
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(PREF_NEXT_SURVEY_DATE, MyApp.dateNextSurvey!);
  }

  Future<void> updateDateInFirebase() async {
    FirebaseFirestore.instance
        .collection(USERS_COLLECTION_KEY)
        .doc(userId)
        .update({
      USER_DATE_NEXT_SURVEY_KEY: MyApp.dateNextSurvey,
    });
  }
}
