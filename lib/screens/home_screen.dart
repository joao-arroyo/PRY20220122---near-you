import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:near_you/main.dart';
import 'package:near_you/screens/login_screen.dart';
import 'package:near_you/screens/my_profile_screen.dart';
import 'package:near_you/screens/routine_detail_screen.dart.dart';
import 'package:near_you/screens/routine_screen.dart';
import 'package:near_you/screens/survey_screen.dart';
import 'package:near_you/widgets/firebase_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants.dart';
import '../common/static_common_functions.dart';
import '../model/pending_vinculation.dart';
import '../model/user.dart' as user;
import '../widgets/dialogs.dart';
import '../widgets/patient_detail.dart';
import '../widgets/patients_list.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  static double screenWidth = 0;
  static double screenHeight = 0;

  static getBodyHeight() {
    double percentage = 0.5;
    if (HomeScreen.screenHeight > 600) {
      percentage += 0.05;
    }
    var result = HomeScreen.screenHeight * percentage +
        (MySliverHeaderDelegate.publicShrinkHome >
                (MySliverHeaderDelegate._maxExtent / 2)
            ? MySliverHeaderDelegate._maxExtent / 2
            : MySliverHeaderDelegate.publicShrinkHome);
    return result;
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class MySliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  static final double _maxExtent = HomeScreen.screenHeight * 0.3;
  final VoidCallback onActionTap;
  static double publicShrinkHome = 0;
  user.User? currentUser;

  Function initAllData;
  Function showNotificationsModal;

  int patientsCounter;

  int notificationsCounter = 0;

  MySliverHeaderDelegate(
      {required this.onActionTap,
      required this.currentUser,
      required this.initAllData,
      required this.patientsCounter,
      required this.notificationsCounter,
      required this.showNotificationsModal});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    HomeScreen.screenWidth = MediaQuery.of(context).size.width;
    HomeScreen.screenHeight = MediaQuery.of(context).size.height;
    double iconsSize = HomeScreen.screenHeight / 40;
    publicShrinkHome = shrinkOffset;
    return Container(
      color: const Color(0xff2F8F9D),
      padding: const EdgeInsets.only(top: 20),
      child: Stack(
        children: [
          Align(
              alignment: const Alignment(
                  //little padding
                  0,
                  0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: getImageUser(context, shrinkOffset, _maxExtent),
                  ),
                  Padding(
                      padding: EdgeInsets.only(top: 5),
                      //getPaddingTopTitle(shrinkOffset, maxExtent)),
                      child: Text(
                          currentUser != null
                              ? currentUser?.fullName ??
                                  currentUser?.type ??
                                  "Nombre"
                              : "Nombre",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold))),
                  //apply padding to all four sides
                  Text(
                    getTextSubtitleHeader(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  getButtonVinculation(context, shrinkOffset, _maxExtent)
                ],
              )),
          //getImageUser(context, shrinkOffset, _maxExtent),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
                padding: EdgeInsets.only(
                    left: iconsSize, top: iconsSize, bottom: iconsSize),
                constraints: const BoxConstraints(),
                icon: SvgPicture.asset(
                  'assets/images/log_out.svg',
                  height: iconsSize,
                ),
                onPressed: () {
                  showLogoutModal(context);
                }),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                  padding: EdgeInsets.only(
                      right: iconsSize, top: iconsSize, bottom: iconsSize),
                  constraints: const BoxConstraints(),
                  icon: SvgPicture.asset(
                    'assets/images/refresh_icon.svg',
                    height: iconsSize,
                  ),
                  onPressed: () {
                    initAllData();
                  })),
        ],
      ),
    );
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => HomeScreen.screenHeight * 0.15;

  @override
  bool shouldRebuild(covariant MySliverHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }

  Future<void> logOut(BuildContext context) async {
    final db = FirebaseFirestore.instance;
    var userDocRef = db
        .collection(USERS_COLLECTION_KEY)
        .doc(FirebaseAuth.instance.currentUser!.uid);
    await userDocRef.update({
      USER_DEVICE_LOGGED: USER_DEVICE_LOGGED_EMPTY,
    });
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const LoginScreen(),
      ),
    );
  }

  Widget getButtonVinculation(
    context,
    double shrinkOffset,
    double maxExtent,
  ) {
    if (shrinkOffset > (maxExtent * 0.01)) {
      return SizedBox.shrink();
    } else {
      return Stack(
        children: <Widget>[
          FlatButton(
            height: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
            color: Colors.white,
            onPressed: () {
              currentUser!.isPatient()
                  ? (isNotEmtpy(currentUser!.medicoId)
                      ? showDialogDevinculation(
                          context, currentUser!.userId!, true, () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      HomeScreen()));
                        })
                      : showDialogVinculation(
                          currentUser!.fullName ?? "Nombre",
                          currentUser!.email!,
                          context,
                          currentUser!.isPatient(),
                          () {}, () {
                          Navigator.pop(context);
                          dialogWaitVinculation(context, () {
                            Navigator.pop(context);
                          }, currentUser!.isPatient());
                        }))
                  : showNotificationsModal(context);
            },
            child: Text(
              currentUser!.isPatient()
                  ? (isNotEmtpy(currentUser!.medicoId)
                      ? 'Desvincular'
                      : 'Vincular')
                  : 'Notificaciones',
              style: TextStyle(
                  fontSize: getFontSizeVinculation(shrinkOffset, maxExtent),
                  fontWeight: FontWeight.bold,
                  color: Color(0xff9D9CB5)),
            ),
          ),
          currentUser!.isPatient()
              ? const SizedBox(
                  height: 0,
                )
              : Positioned(
                  right: 0,
                  top: 7,
                  child: new Container(
                    padding: EdgeInsets.all(2),
                    decoration: new BoxDecoration(
                      color:
                          notificationsCounter > 0 ? Colors.red : Colors.grey,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: new Text(
                      notificationsCounter.toString(),
                      style: new TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
        ],
      );
    }
  }

  getPaddingTopTitle(double shrinkOffset, double maxExtent) {
    return 0.0;
    var result = maxExtent - (110 + shrinkOffset);
    if (result < 0) {
      result = 0;
    }
    return result;
  }

  getHeightVinculationButton(double shrinkOffset, double maxExtent) {
    var result = maxExtent / 12 - (shrinkOffset / 2);
    if (result < 0) {
      result = 0;
    }
    return result;
  }

  getFontSizeVinculation(double shrinkOffset, double maxExtent) {
    var result = maxExtent / 17 - (shrinkOffset / 2);
    if (result < 0) {
      result = 0;
    }
    return result;
  }

  String getTextSubtitleHeader() {
    if (currentUser == null) {
      return "";
    }

    if (currentUser!.isPatient()) {
      return currentUser?.diabetesType ?? 'Diabetes Typo 2';
    }

    return '$patientsCounter paciente' + (patientsCounter != 1 ? "s" : "");
  }

  void showLogoutModal(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(alignment: WrapAlignment.center, children: [
              AlertDialog(
                  title: Column(children: const [
                    SizedBox(
                      height: 20,
                    ),
                    Text("Cerrar sesión")
                  ]),
                  titleTextStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff67757F)),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('¿Estás seguro que deseas ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff999999))),
                      const Text('cerrar la sesión?',
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
                                logOut(context);
                              },
                              child: const Text(
                                'Aceptar',
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

  getImageUser(BuildContext context, double shrinkOffset, double maxExtent) {
    if (shrinkOffset > (maxExtent * 0.01)) {
      return const SizedBox.shrink();
    }
    return Align(
        alignment: Alignment(
            //little padding
            shrinkOffset / _maxExtent,
            0),
        child: Padding(
            padding: EdgeInsets.only(
                left: 30,
                top: (shrinkOffset / _maxExtent) * 35,
                right: 30,
                bottom: 0),
            child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              MyProfileScreen(currentUser)));
                },
                child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xff7c94b6),
                          image: const DecorationImage(
                            image:
                                NetworkImage('http://i.imgur.com/QSev0hg.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50.0)),
                          border: Border.all(
                            color: const Color(0xff47B4AC),
                            width: 4.0,
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/person_default.png',
                          height: HomeScreen.screenHeight / 15,
                        ))))));
  }
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // bool isUserPatient = false;
  user.User? currentUser;
  Future<DocumentSnapshot>? futureUser;
  late ValueNotifier<bool> notifier = ValueNotifier(false);
  List<PendingVinculation> pendingVinculationList = <PendingVinculation>[];
  int patientsCounter = 0;

  Future<List<PendingVinculation>>? pendingVinculationsFuture;

  int notificationsCounter = 0;

  bool disabledSurvey = false;

  @override
  void initState() {
    initAllData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HomeScreen.screenWidth = MediaQuery.of(context).size.width;
    HomeScreen.screenHeight = MediaQuery.of(context).size.height;
    final expandedHeight = MediaQuery.of(context).size.height * 0.2;
    return Stack(children: <Widget>[
      Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverPersistentHeader(
                pinned: true,
                delegate: MySliverHeaderDelegate(
                    onActionTap: () {
                      debugPrint("on Tap");
                    },
                    currentUser: currentUser,
                    initAllData: () {
                      initAllData();
                    },
                    patientsCounter: patientsCounter,
                    notificationsCounter: notificationsCounter,
                    showNotificationsModal: (context) {
                      showNOtificationsModal(context);
                    }),
              ),
            ];
          },
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
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                          // minHeight: HomeScreen.screenHeight *0.5,
                          ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: getTopPaddingBody(),
                          ),
                          FutureBuilder(
                            future: futureUser,
                            builder: (context, AsyncSnapshot snapshot) {
                              //currentUser = user.User.fromSnapshot(snapshot.data);
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return getScreenType();
                              }
                              return Padding(
                                  padding: EdgeInsets.only(
                                      top: HomeScreen.screenHeight * 0.3),
                                  child: CircularProgressIndicator());
                            },
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [_getFABDial()],
                          )
                        ],
                      ),
                    );
                  },
                ))
          ]),
        ),
        bottomNavigationBar: _buildBottomBar(),
        floatingActionButton: /* _getEmptyFABDial() */
            GestureDetector(
          child: Container(
            padding: const EdgeInsets.only(top: 40),
            child: SvgPicture.asset(
              notifier.value
                  ? 'assets/images/tab_close_selected.svg'
                  : 'assets/images/tab_plus_selected.svg',
              height: HomeScreen.screenHeight / 9,
            ),
          ),
          onTap: () {
            executeMainAction();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      )
    ]);
  }

  bool showMenu = false;

  Widget _getFABDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: const IconThemeData(size: 22),
      backgroundColor: Colors.transparent,
      visible: false,
      curve: Curves.bounceIn,
      openCloseDial: notifier,
      onClose: () {
        setState(() {
          notifier.value = false;
        });
      },
      //spaceBetweenChildren: 100,
      spacing: 200,
      children: [
        SpeedDialChild(
            child: const Icon(Icons.list, color: Colors.white),
            backgroundColor: const Color(0xFF2F8F9D),
            onTap: () {
              goToAllRoutines();
            },
            labelWidget: const Text(
              "Todas mis Rutinas",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF47B4AC),
                  fontSize: 16.0),
            )),
        SpeedDialChild(
            child: Icon(Icons.playlist_add_check_outlined, color: Colors.white),
            backgroundColor: Color(disabledSurvey ? 0xff999999 : 0xFF2F8F9D),
            onTap: () {
              if (!disabledSurvey) {
                goToSurvey();
              }
            },
            labelWidget: const Text(
              "Encuestas",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF47B4AC),
                  fontSize: 16.0),
            )),
        SpeedDialChild(
            child: const Icon(Icons.water_drop, color: Colors.white),
            backgroundColor: const Color(0xFF2F8F9D),
            onTap: () {
              goToMyRoutine();
            },
            labelWidget: const Text(
              "Mi rutina",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF47B4AC),
                  fontSize: 16.0),
            ))
      ],
    );
  }

  var _currentIndex = 1;

  Widget _buildBottomBar() {
    return Container(
      child: Material(
        elevation: 0.0,
        color: Colors.white,
        child: BottomNavigationBar(
          elevation: 0,
          onTap: (index) {
            _currentIndex = index;
            if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          MyProfileScreen(currentUser)));
            }
          },
          backgroundColor: Colors.transparent,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  currentUser?.isPatient() ?? false
                      ? 'assets/images/tab_metrics_unselected.svg'
                      : "",
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

  getTopPaddingBody() {
    if (MySliverHeaderDelegate.publicShrinkHome < 120) {
      return 7.toDouble();
    } else {
      var cant =
          (MySliverHeaderDelegate.publicShrinkHome - 168.toDouble()) / 10;
      return (50 + cant * 9.3).toDouble();
    }
  }

  getScreenType() {
    if (currentUser == null) {
      return Padding(
          padding: EdgeInsets.only(top: HomeScreen.screenHeight * 0.3),
          child: CircularProgressIndicator());
    } else if (currentUser!.isPatient()) {
      return PatientDetail.forPatientView(currentUser);
    } else {
      return medicoScreen();
    }
  }

  medicoScreen() {
    return Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Column(
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const <Widget>[]),
            const SizedBox(
              height: 20,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'Mis pacientes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff999999),
                    ),
                  )
                ]),
            Container(
                height: HomeScreen.getBodyHeight(),
                child: PatientsListLayout((int cant) {
                  setState(() {
                    patientsCounter = cant;
                  });
                }))
            //SizedBox
          ],
        ));
  }

  void executeMainAction() {
    if (currentUser!.isPatient()) {
      setState(() {
        //howMenu = false;
        notifier.value = true;
      });
    } else {
      showDialogVinculation(
          currentUser!.fullName ?? "Nombre",
          currentUser!.email!,
          context,
          currentUser!.isPatient(),
          errorVinculation,
          successPendingVinculation);
    }
  }

/* void startVinculation(String? emailPatient) {
    attachMedicoToPatient(emailPatient);
  }

 Future<void> attachMedicoToPatient(String? emailPatient) async {
    final db = FirebaseFirestore.instance;
    String? medicoId = FirebaseAuth.instance.currentUser?.uid;
    if (medicoId == null) return;
    String? patientId = await getUserIdByEmail(emailPatient);
    if (patientId == null) {
      //error no id for email
      Navigator.pop(context);
    }
    var postDocRef = db.collection(USERS_COLLECTION_KEY).doc(patientId);
    await postDocRef
        .update({
          MEDICO_ID_KEY: medicoId,
          // ....rest of your data
        })
        .whenComplete(() => refreshScreen())
        .onError((error, stackTrace) => Navigator.pop(context));
  }*/

  refreshScreen() {
    Navigator.pop(context);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen()));
  }

  void goToSurvey() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurveyScreen(
            currentUser!.userId!, currentUser!.fullName ?? "Paciente"),
      ),
    );
  }

  errorVinculation() {
    print("error vinculation");
  }

  successPendingVinculation() {
    Navigator.pop(context);
    dialogWaitVinculation(context, () {
      Navigator.pop(context);
    }, currentUser!.isPatient());
  }

  Future<List<PendingVinculation>> getPendingVinculations() async {
    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection(PENDING_VINCULATIONS_COLLECTION_KEY);
    final String currentUserId = currentUser!.userId!;
    QuerySnapshot<Map<String, dynamic>> future;
    if (currentUser!.isPatient()) {
      future = await collectionRef
          .where(PATIENT_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_PENDING)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_MEDICO)
          .limit(1)
          .get();
    } else {
      future = await collectionRef
          .where(MEDICO_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_PENDING)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_PACIENTE)
          .get();
    }

    List<PendingVinculation> vinculations = <PendingVinculation>[];
    for (var element in future.docs) {
      PendingVinculation currentVinculation =
          PendingVinculation.fromSnapshot(element);
      vinculations.add(currentVinculation);
    }
    return vinculations;
  }

  Future<List<PendingVinculation>> getRefusedVinculations() async {
    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection(PENDING_VINCULATIONS_COLLECTION_KEY);
    final String currentUserId = currentUser!.userId!;
    QuerySnapshot<Map<String, dynamic>> future;
    if (currentUser!.isPatient()) {
      future = await collectionRef
          .where(PATIENT_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_REFUSED)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_PACIENTE)
          .limit(1)
          .get();
    } else {
      future = await collectionRef
          .where(MEDICO_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_REFUSED)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_MEDICO)
          .get();
    }

    List<PendingVinculation> vinculations = <PendingVinculation>[];
    for (var element in future.docs) {
      PendingVinculation currentVinculation =
          PendingVinculation.fromSnapshot(element);
      vinculations.add(currentVinculation);
    }
    return vinculations;
  }

  Future<List<PendingVinculation>> getAcceptedVinculations() async {
    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection(PENDING_VINCULATIONS_COLLECTION_KEY);
    final String currentUserId = currentUser!.userId!;
    QuerySnapshot<Map<String, dynamic>> future;
    if (currentUser!.isPatient()) {
      future = await collectionRef
          .where(PATIENT_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_ACCEPTED)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_PACIENTE)
          .limit(1)
          .get();
    } else {
      future = await collectionRef
          .where(MEDICO_ID_KEY, isEqualTo: currentUserId)
          .where(VINCULATION_STATUS_KEY, isEqualTo: VINCULATION_STATUS_ACCEPTED)
          .where(APPLICANT_VINCULATION_USER_TYPE, isEqualTo: USER_TYPE_MEDICO)
          .get();
    }

    List<PendingVinculation> vinculations = <PendingVinculation>[];
    for (var element in future.docs) {
      PendingVinculation currentVinculation =
          PendingVinculation.fromSnapshot(element);
      vinculations.add(currentVinculation);
    }
    return vinculations;
  }

  void showNotificationPendingVinculation(
      PendingVinculation pendingVinculation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(alignment: WrapAlignment.center, children: [
              AlertDialog(
                  title: Column(children: const [
                    SizedBox(
                      height: 20,
                    ),
                    Text("Notificación de\n Vinculación",
                        textAlign: TextAlign.center)
                  ]),
                  titleTextStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff67757F)),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                          'El médico ${pendingVinculation.namePending}\n desea vincular su cuenta\n con usted',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
                                acceptVinculationWithDoctor(
                                    pendingVinculation.medicoId,
                                    FirebaseAuth.instance.currentUser?.uid,
                                    pendingVinculation.databaseId!);
                              },
                              child: const Text(
                                'Aceptar',
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
                                noAcceptVinculation(
                                    pendingVinculation.databaseId!);
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

  Future<void> acceptVinculationWithDoctor(
      String? medicoId, String? patientId, String pendingVinculationId) async {
    final db = FirebaseFirestore.instance;
    if (patientId == null || medicoId == null) {
      return;
    }
    updatePendingVinculationStatus(
        VINCULATION_STATUS_ACCEPTED, pendingVinculationId);
    var postDocRef = db.collection(USERS_COLLECTION_KEY).doc(patientId);
    await postDocRef.update({
      MEDICO_ID_KEY: medicoId,
      // ....rest of your data
    }).then((value) => showDialogSuccessVinculation(context,
            '¡Todo listo!\nSu ${currentUser!.isPatient() ? "médico" : "paciente"} fue vinculado \ncorrectamente.',
            () {
          Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => HomeScreen()));
        }));
  }

  void noAcceptVinculation(String pendingVinculationId) {
    Navigator.pop(context);
    updatePendingVinculationStatus(
        VINCULATION_STATUS_REFUSED, pendingVinculationId);
  }

  Future<void> updatePendingVinculationStatus(
      String status, String pendingVinculationId) async {
    final db = FirebaseFirestore.instance;
    await db
        .collection(PENDING_VINCULATIONS_COLLECTION_KEY)
        .doc(pendingVinculationId)
        .update({VINCULATION_STATUS_KEY: status});
  }

  void goToMyRoutine() {
    if (currentUser!.currentTreatment != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RoutineDetailScreen(currentUser!.currentTreatment!),
        ),
      );
    }
  }

  void goToAllRoutines() {
    if (currentUser!.currentTreatment != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoutineScreen(currentUser!.currentTreatment!),
        ),
      );
    }
  }

  Future<void> initAllData() async {
    futureUser = getUserById(FirebaseAuth.instance.currentUser!.uid);
    futureUser?.then((value) => {
          setState(() {
            currentUser = user.User.fromSnapshot(value);
            notifier = ValueNotifier(false);
            DateTime dateNextSurvey = DateFormat('dd-MM-yyyy').parse(
                currentUser?.dateNextSurvey ?? SURVEY_DISABLED_DEFAULT_DATE);
            disabledSurvey = DateTime.now().isBefore(dateNextSurvey);
            pendingVinculationsFuture = getPendingVinculations();
            pendingVinculationsFuture?.then((pendingResult) => {
                  setState(() {
                    if (pendingResult.isEmpty) {
                      return;
                    }
                    pendingVinculationList = pendingResult;
                    notificationsCounter = pendingResult.length;
                    if (currentUser!.isPatient()) {
                      showNotificationPendingVinculation(
                          pendingVinculationList[0]);
                    }
                  })
                });

            getRefusedVinculations().then((refusedList) => {
                  setState(() {
                    for (int i = 0; i < refusedList.length; i++) {
                      deleteVinculation(refusedList[i].databaseId!);
                    }
                  })
                });

            getAcceptedVinculations().then((acceptedList) => {
                  setState(() {
                    if (acceptedList.isEmpty) {
                      return;
                    }
                    if (currentUser!.isPatient()) {
                      dialogSuccessDoctorAccepts(context);
                      deleteVinculation(acceptedList.first.databaseId!);
                    }
                  })
                });
            saveUserNameSharedPref();
          })
        });
  }

  void showNOtificationsModal(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(alignment: WrapAlignment.center, children: [
              AlertDialog(
                  title: Column(children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text("Notificaciones")
                  ]),
                  titleTextStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff999999)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          height: HomeScreen.screenHeight * 0.3,
                          width: HomeScreen.screenWidth * 0.6,
                          child: getNotificationsList()),
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
                              },
                              child: const Text(
                                'Cerrar',
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

  getNotificationsList() {
    return FutureBuilder(
        future: pendingVinculationsFuture,
        builder: (context, AsyncSnapshot<List<PendingVinculation>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }
          if (pendingVinculationList.isEmpty) {
            return Container(
              width: HomeScreen.screenWidth * 0.6,
              height: HomeScreen.screenHeight * 0.3,
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Usted no tiene notificaciones',
                          textAlign: TextAlign.center,
                          maxLines: 5,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff999999),
                            fontFamily: 'Italic',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ])),
            );
          }
          return ListView.builder(
              itemCount: pendingVinculationList.length,
              padding: EdgeInsets.only(bottom: 60),
              itemBuilder: (context, index) {
                return Card(
                    color: Color(0xffF1F1F1),
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: ClipPath(
                      clipper: ShapeBorderClipper(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3))),
                      child: Wrap(
                        children: [
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pendingVinculationList[index]
                                                    .namePending ??
                                                "Paciente x",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xff2F8F9D),
                                                fontSize: 14),
                                          ),
                                          Text(
                                              pendingVinculationList[index]
                                                      .emailPending ??
                                                  "email",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xff67757F),
                                                  fontSize: 10)),
                                        ],
                                      )),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            noAcceptVinculation(
                                                pendingVinculationList[index]
                                                    .databaseId!);
                                            setState(() {
                                              pendingVinculationList
                                                  .removeAt(index);
                                              notificationsCounter =
                                                  pendingVinculationList.length;
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          icon: Icon(Icons.close,
                                              color: Color(0xff2F8F9D))),
                                      IconButton(
                                          onPressed: () {
                                            acceptVinculationWithDoctor(
                                                pendingVinculationList[index]
                                                    .medicoId,
                                                pendingVinculationList[index]
                                                    .patientId,
                                                pendingVinculationList[index]
                                                    .databaseId!);
                                            setState(() {
                                              pendingVinculationList
                                                  .removeAt(index);
                                              notificationsCounter =
                                                  pendingVinculationList.length;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.check,
                                            color: Color(0xff2F8F9D),
                                          ))
                                    ],
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ));
              });
        });
  }

  Future<void> saveUserNameSharedPref() async {
    if (currentUser == null || currentUser!.fullName == null) {
      return;
    }
    MyApp.userName = currentUser!.fullName!;
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(PREF_USER_NAME, MyApp.userName!);
    if (currentUser!.isPatient()) {
      FirebaseMessaging.instance.subscribeToTopic(PUSH_TOPIC_PATIENT);
    } else {
      FirebaseMessaging.instance.subscribeToTopic(PUSH_TOPIC_DOCTOR);
    }
  }
}
