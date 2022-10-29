import 'package:age_calculator/age_calculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/common/static_common_functions.dart';
import '../model/user.dart' as user;
import 'package:intl/intl.dart';

import '../Constants.dart';
import '../widgets/dialogs.dart';
import '../widgets/firebase_utils.dart';
import '../widgets/static_components.dart';
import 'home_screen.dart';

class MyProfileScreen extends StatefulWidget {
  user.User? currentUser;
  bool isEditMode;

  MyProfileScreen(this.currentUser, {this.isEditMode = false});

  static const routeName = '/my_profile';

  @override
  _MyProfileScreenState createState() =>
      _MyProfileScreenState(currentUser, isEditMode);
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final GlobalKey<FormState> profileKey = GlobalKey<FormState>();
  static StaticComponents staticComponents = StaticComponents();
  user.User? currentUser;
  late final Future<DocumentSnapshot> futureUser;
  var _currentIndex = 1;

  var addressError = false;

  bool emailError = false;

  bool birthDayError = false;

  bool nameError = false;

  get sizedBox10 => const SizedBox(height: 10);

  double percentageProgress = 0;

  bool isEditMode = false;

  _MyProfileScreenState(this.currentUser, this.isEditMode);

  @override
  void initState() {
    futureUser = getUserById(FirebaseAuth.instance.currentUser!.uid);
    futureUser.then((value) => {
          setState(() {
            currentUser = user.User.fromSnapshot(value);
            //  notifier = ValueNotifier(false);
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
              actions: getActions(),
              backgroundColor: Color(0xff2F8F9D),
              centerTitle: true,
              title: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(isEditMode ? 'Editar Perfil' : 'Mi Perfil',
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
                              height: 180,
                              width: double.maxFinite,
                              child: Container(
                                color: Color(0xff2F8F9D),
                                child: Column(
                                  children: [
                                    Material(
                                      elevation: 10,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(100)),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xff7c94b6),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  'http://i.imgur.com/QSev0hg.jpg'),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50.0)),
                                            border: Border.all(
                                              color: Color(0xff47B4AC),
                                              width: 4.0,
                                            ),
                                          ),
                                          child: Image.asset(
                                            'assets/images/person_default.png',
                                            height: 90,
                                          )),
                                    ),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            currentUser?.fullName ?? "Nombre",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          )
                                        ]),
                                    FlatButton(
                                      height: 20,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.only(
                                          left: 30,
                                          right: 30,
                                          top: 5,
                                          bottom: 5),
                                      color: Colors.white,
                                      onPressed: () {
                                        if (getVinculationCondition()) {
                                          showDialogVinculation(
                                              currentUser!.fullName ?? "Nombre",
                                              currentUser!.email!,
                                              context,
                                              currentUser!.isPatient(),
                                              () {},
                                              successPendingVinculation);
                                        } else {
                                          startDevinculation();
                                        }
                                      },
                                      child: Text(
                                        getVinculationCondition()
                                            ? 'Vincular'
                                            : 'Desvincular',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff9D9CB5)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            getScreenType(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ))
        ]),
        bottomNavigationBar: isEditMode ? null : _buildBottomBar(),
        //TODO : REVIEW THIS
        floatingActionButton: isEditMode
            ? null
            : Container(
                padding: EdgeInsets.only(top: 40),
                child:
                    SvgPicture.asset('assets/images/person_tab_selected.svg',
                      height: HomeScreen.screenHeight/9),
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
                  'assets/images/plus_tab_unselected.svg',
                ),
                label: "")
          ],
        ),
      ),
    );
  }

  getScreenType() {
    return Form(
      key: profileKey,
      child: Container(
        padding: EdgeInsets.only(bottom: 30, left: 35, right: 35),
        child: Column(
          children: [
            sizedBox10,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.person, size: 18, color: Color(0xff999999)),
                Text(" Nombre (*)",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999))),
              ],
            ),
            sizedBox10,
            SizedBox(
                height: nameError ? 45 : 25,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value == '') {
                      setState(() {
                        nameError = true;
                      });
                      return "Campo requerido";
                    }
                    setState(() {
                      nameError = false;
                    });
                    return null;
                  },
                  onChanged: (value) {
                    currentUser!.fullName = value;
                  },
                  controller:
                      TextEditingController(text: currentUser!.fullName ?? ""),
                  style: const TextStyle(fontSize: 14),
                  decoration: getDecoration(),
                )),
            sizedBox10,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.person, size: 18, color: Color(0xff999999)),
                Text(" Edad (*)",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999))),
              ],
            ),
            sizedBox10,
            SizedBox(
                height: 25,
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: isNotEmtpy(currentUser!.birthDay)
                          ? AgeCalculator.age(DateFormat.yMMMMd("en_US")
                                  .parse(currentUser!.birthDay!))
                              .years
                              .toString()
                          : '0'),
                  style: const TextStyle(fontSize: 14),
                  decoration: getDecoration(),
                )),
            sizedBox10,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.calendar_today, size: 18, color: Color(0xff999999)),
                Text(" Fecha de Cumpleaños (*)",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999))),
              ],
            ),
            sizedBox10,
            SizedBox(
                height: birthDayError ? 45 : 25,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value == '') {
                      setState(() {
                        birthDayError = true;
                      });
                      return "Campo requerido";
                    }
                    setState(() {
                      birthDayError = false;
                    });
                    return null;
                  },
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                  controller:
                      TextEditingController(text: currentUser!.birthDay),
                  style: const TextStyle(fontSize: 14),
                  decoration: getDecoration(),
                )),
            sizedBox10,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.medical_information_sharp,
                    size: 18, color: Color(0xff999999)),
                Text(" Centro Médico",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999))),
              ],
            ),
            sizedBox10,
            SizedBox(
                height: 25,
                child: TextFormField(
                  onChanged: (value) {
                    currentUser!.medicalCenter = value;
                  },
                  controller:
                      TextEditingController(text: currentUser!.medicalCenter),
                  style: const TextStyle(fontSize: 14),
                  decoration: getDecoration(),
                )),
            sizedBox10,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.mail_sharp, size: 18, color: Color(0xff999999)),
                Text(" Correo electronico (*)",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999))),
              ],
            ),
            sizedBox10,
            SizedBox(
                height: emailError ? 45 : 25,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value == '') {
                      setState(() {
                        emailError = true;
                      });
                      return "Campo requerido";
                    }
                    setState(() {
                      emailError = false;
                    });
                    return null;
                  },
                  onChanged: (value) {
                    currentUser!.email = value;
                  },
                  controller: TextEditingController(text: currentUser!.email),
                  style: const TextStyle(fontSize: 14),
                  decoration: getDecoration(),
                )),
            sizedBox10,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.location_pin, size: 18, color: Color(0xff999999)),
                Text(" Dirección (*)",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999))),
              ],
            ),
            sizedBox10,
            SizedBox(
                height: addressError ? 45 : 25,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value == '') {
                      setState(() {
                        addressError = true;
                      });
                      return "Campo requerido";
                    }
                    setState(() {
                      addressError = false;
                    });
                    return null;
                  },
                  onChanged: (value) {
                    currentUser!.address = value;
                  },
                  controller: TextEditingController(text: currentUser!.address),
                  style: const TextStyle(fontSize: 14),
                  decoration: getDecoration(),
                )),
            sizedBox10,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(Icons.person, size: 18, color: Color(0xff999999)),
                Text(" Referencia",
                    style: TextStyle(fontSize: 14, color: Color(0xff999999))),
              ],
            ),
            sizedBox10,
            SizedBox(
                height: 25,
                child: TextFormField(
                  onChanged: (value) {
                    currentUser!.reference = value;
                  },
                  controller:
                      TextEditingController(text: currentUser!.reference),
                  style: const TextStyle(fontSize: 14),
                  decoration: getDecoration(),
                )),
            sizedBox10,
            getButtonOrEmptySpace()
          ],
        ),
      ),
    );
  }

  void startDevinculation() {
    showDialogDevinculation(context, currentUser!.userId!, true, () {
      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => MyProfileScreen(
                    currentUser,
                    isEditMode: isEditMode,
                  )));
    });
  }

  bool getVinculationCondition() {
    return !currentUser!.isPatient() ||
        !isNotEmtpy(currentUser?.medicoId ?? "");
  }

  successPendingVinculation() {
    Navigator.pop(context);
    dialogWaitVinculation(context, () {
      Navigator.pop(context);
    }, currentUser!.isPatient());
  }

  getActions() {
    if (isEditMode) {
      return [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: Icon(Icons.check, color: Colors.white),
          onPressed: () {
            //
          },
        ),
        IconButton(
          icon: Icon(Icons.delete_outlined, color: Colors.white),
          onPressed: () {
            //
          },
        )
      ];
    }
    return [
      IconButton(
        icon: Icon(Icons.edit_outlined, color: Colors.white),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MyProfileScreen(
                        currentUser,
                        isEditMode: true,
                      )));
        },
      )
    ];
  }

  getDecoration() {
    if (isEditMode) {
      return staticComponents.getMiddleInputDecoration('');
    }
    return staticComponents.getProfileInputDecorationDisabled();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 8),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      setState(() {
        currentUser!.birthDay = DateFormat.yMMMMd("en_US").format(d);
      });
    }
  }

  getButtonOrEmptySpace() {
    if (!isEditMode) {
      return SizedBox(height: 20);
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(
            height: 17,
          ),
          FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            color: const Color(0xff2F8F9D),
            textColor: Colors.white,
            onPressed: validateAndSave,
            child: const Text(
              'Guardar',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ]);
  }

  void validateAndSave() {
    final FormState? form = profileKey.currentState;
    if (form?.validate() ?? false) {
      saveIdDatabase();
    }
  }

  void navigateBack() {
    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => MyProfileScreen(
                  currentUser,
                  isEditMode: false,
                )));
  }

  Future<void> saveIdDatabase() async {
    final db = FirebaseFirestore.instance;
    var postDocRef =
        db.collection(USERS_COLLECTION_KEY).doc(currentUser!.userId);
    await postDocRef.update({
      FULL_NAME_KEY: currentUser!.fullName,
      BIRTH_DAY_KEY: currentUser!.birthDay,
      MEDICAL_CENTER_VALUE: currentUser!.medicalCenter,
      EMAIL_KEY: currentUser!.email,
      ADDRESS_KEY: currentUser!.address,
      REFERENCE_KEY: currentUser!.reference,
    }).then((value) => navigateBack());
  }
}
