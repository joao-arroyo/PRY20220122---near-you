import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:near_you/screens/login_screen.dart';
import 'package:near_you/widgets/static_components.dart';

import '../Constants.dart';

class SignupScreen extends StatelessWidget {
  static const routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    return const SignUpWidget();
  }
}

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key}) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final GlobalKey<FormState> signUpFormKeyFirstScreen = GlobalKey<FormState>();
  final GlobalKey<FormState> signUpFormKeySecondScreen = GlobalKey<FormState>();

  static StaticComponents staticComponents = StaticComponents();
  bool secondScreen = false;
  String emailValue = "";
  String passwordValue = "";
  String fullNameValue = "";
  String phoneNumberValue = "";
  String? genderValue;
  String? diabetesValue;
  String? medicalAssuranceValue;
  String? educationalLevelValue;
  String? civilStatusValue;
  String? smokeValue;
  String addressValue = "";
  String medicalCenterValue = "";
  String referenceValue = "";
  String altPhoneValue = "";
  String allergiesValue = "";

  static List<String> genderList = ["Hombre", "Mujer"];
  static List<String> diabetesTypesList = [
    "Diabetes Tipo 1",
    "Diabetes Tipo 2",
    "Diabetes Gestacional"
  ];
  static List<String> medicalAssuranceList = [
    "SIS",
    "EsSalud",
    "IPRESS",
    "EPS",
    "No tengo"
  ];
  static List<String> educationalLevelList = [
    "Primaria completa",
    "Secundaria Incompleta",
    "Secundaria Completa",
    "Universitaria o Técnica Incompleta",
    "Universitaria o Técnica completa"
  ];
  static List<String> civilStatusList = [
    "Soltero",
    "Casado",
    "Viudo o divorciado"
  ];
  static List<String> smokeList = ["No fumo", "Fumo"];

  String _selectedDate = '';
  final firebaseAuth.FirebaseAuth _auth = firebaseAuth.FirebaseAuth.instance;

  bool emailAlreadyInUse = false;

  get inputBorder => OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffCECECE)),
      borderRadius: BorderRadius.circular(10));

  get SizeBox12 => const SizedBox(
        height: 12,
      );

  get getFirstScreenComponent => Form(
        key: signUpFormKeyFirstScreen,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
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
                        height: 50,
                      ),
                      const Text(
                        "Crear cuenta",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff333333),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: TextEditingController(text: emailValue),
                        onChanged: (value) {
                          emailValue = value;
                          emailAlreadyInUse = false;
                        },
                        validator: (value) {
                          if (value == null || value == '') {
                            return "Campo requerido";
                          }
                          if (!RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+")
                              .hasMatch(value)) {
                            return "Formato de email inválido";
                          }
                          if (emailAlreadyInUse) {
                            return "El email ingresdo ya se encuentra registrado";
                          }
                        },
                        style: TextStyle(fontSize: 14),
                        decoration: staticComponents
                            .getInputDecoration('Correo Electrónico'),
                      ),
                      SizeBox12,
                      TextFormField(
                        controller: TextEditingController(text: passwordValue),
                        onChanged: (value) {
                          passwordValue = value;
                        },
                        validator: (value) {
                          if (value == null || value == '') {
                            return "Campo requerido";
                          }
                          if (!RegExp(REGEX_PASSWORD).hasMatch(value)) {
                            return "La contraseña debe cumplir: Mayúscula, minuscula, caracter extraño y mayor a 6 dígitos";
                          }
                        },
                        // obscureText: true,
                        style: TextStyle(fontSize: 14),
                        decoration:
                            staticComponents.getInputDecoration('Contraseña'),
                      ),
                      SizeBox12,
                      TextFormField(
                        controller: TextEditingController(text: fullNameValue),
                        onChanged: (value) {
                          fullNameValue = value;
                        },
                        validator: (value) {
                          if (value == null || value == '') {
                            return "Campo requerido";
                          }
                        },
                        style: TextStyle(fontSize: 14),
                        decoration: staticComponents
                            .getInputDecoration('Nombre Completo'),
                      ),
                      SizeBox12,
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: _selectedDate),
                        onTap: () {
                          _selectDate(context);
                        },
                        validator: (value) {
                          if (value == null || value == '') {
                            return "Campo requerido";
                          }
                        },
                        style: TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          filled: true,
                          suffixIcon: Padding(
                            padding:
                                const EdgeInsetsDirectional.only(end: 12.0),
                            child: const Icon(Icons.calendar_today,
                                color: Color(0xffCECECE)),
                          ),
                          fillColor: Colors.white,
                          hintText: 'Fecha de nacimiento',
                          hintStyle: const TextStyle(
                              fontSize: 14, color: Color(0xffCECECE)),
                          contentPadding: const EdgeInsets.all(15),
                          enabledBorder: staticComponents.inputBorder,
                          border: staticComponents.inputBorder,
                        ),
                      ),
                      SizeBox12,
                      TextField(
                          controller:
                              TextEditingController(text: phoneNumberValue),
                          onChanged: (value) {
                            phoneNumberValue = value;
                          },
                          style: TextStyle(fontSize: 14),
                          decoration:
                              staticComponents.getInputDecoration('Teléfono')),
                      SizeBox12,
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(
                              height: 30,
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.all(15),
                              color: const Color(0xff3BACB6),
                              textColor: Colors.white,
                              onPressed: () {
                                validateAndGoToSecondScreen();
                              },
                              child: const Text(
                                'Siguiente',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: const <Widget>[
                                  Expanded(
                                      child: Divider(
                                    color: Color(0xffCECECE),
                                    thickness: 1,
                                  )),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    //apply padding to all four sides
                                    child: Text(
                                      'o',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffCECECE),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Divider(
                                    color: Color(0xffCECECE),
                                    thickness: 1,
                                  )),
                                ]),
                            const SizedBox(
                              height: 25,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'Crear una cuenta con',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff555555),
                                    ),
                                  )
                                ]),
                            const SizedBox(
                              height: 30,
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 40, right: 40),
                                //apply padding to all four sides
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: Color(0xffCECECE)),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          shape: BoxShape.rectangle),
                                      child: IconButton(
                                          padding: const EdgeInsets.all(5),
                                          constraints: const BoxConstraints(),
                                          icon: SvgPicture.asset(
                                            'assets/images/facebookLogin.svg',
                                          ),
                                          onPressed: () {
                                            //do something,
                                          }),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: Color(0xffCECECE)),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          shape: BoxShape.rectangle),
                                      child: IconButton(
                                          padding: const EdgeInsets.all(5),
                                          constraints: const BoxConstraints(),
                                          icon: SvgPicture.asset(
                                            'assets/images/googleLogin.svg',
                                          ),
                                          onPressed: () {
                                            //do something,
                                          }),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 1,
                                              color: Color(0xffCECECE)),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          shape: BoxShape.rectangle),
                                      child: IconButton(
                                          padding: const EdgeInsets.all(5),
                                          constraints: const BoxConstraints(),
                                          icon: SvgPicture.asset(
                                            'assets/images/instagramLogin.svg',
                                          ),
                                          onPressed: () {
                                            //do something,
                                          }),
                                    )
                                  ],
                                )),
                            const SizedBox(
                              height: 30,
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 8),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _selectedDate = DateFormat.yMMMMd("en_US").format(d);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
          color: Colors.blue,
          width: double.maxFinite,
          height: double.maxFinite,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SvgPicture.asset('assets/images/backgroundLogin.svg'),
          )),
      Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(secondScreen ? Icons.arrow_back : null,
                  color: Color(0xffCECECE)),
              onPressed: () {
                setState(() {
                  secondScreen = false;
                });
              },
            ),
          ),
          backgroundColor: Colors.transparent,
          body: secondScreen ? getSecondScreen() : getFirstScreenComponent)
    ]);
  }

  getSecondScreen() {
    return Form(
        key: signUpFormKeySecondScreen,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
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
                        height: 50,
                      ),
                      const Text(
                        "Crear cuenta",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff333333),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffCECECE), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: DropdownButtonFormField<String>(
                                value: diabetesValue,
                                icon: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.only(end: 7),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(
                                          0xffCECECE)), // myIcon is a 48px-wide widget.
                                ),
                                decoration:
                                    InputDecoration.collapsed(hintText: ''),
                                hint: Text(
                                  'Tipo de diabetes',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xffCECECE)),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    diabetesValue = newValue.toString();
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'Campo requerido' : null,
                                items: diabetesTypesList
                                    .map<DropdownMenuItem<String>>(
                                        (String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child:
                                        SizedBox(height: 20, child: Text(item)),
                                  );
                                }).toList(),
                              ),
                            )),
                      ),
                      SizeBox12,
                      TextField(
                        controller:
                            TextEditingController(text: medicalCenterValue),
                        onChanged: (value) {
                          medicalCenterValue = value;
                        },
                        style: TextStyle(fontSize: 14),
                        decoration: staticComponents.getInputDecoration(
                            'Centro Médico del tratamiento'),
                      ),
                      SizeBox12,
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffCECECE), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: DropdownButtonFormField<String>(
                                value: medicalAssuranceValue,
                                icon: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.only(end: 7),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(
                                          0xffCECECE)), // myIcon is a 48px-wide widget.
                                ),
                                decoration:
                                    InputDecoration.collapsed(hintText: ''),
                                hint: Text(
                                  'Seguro médico',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xffCECECE)),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    medicalAssuranceValue = newValue.toString();
                                  });
                                },
                                items: medicalAssuranceList
                                    .map<DropdownMenuItem<String>>(
                                        (String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child:
                                        SizedBox(height: 20, child: Text(item)),
                                  );
                                }).toList(),
                              ),
                            )),
                      ),
                      SizeBox12,
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffCECECE), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: DropdownButtonFormField<String>(
                                value: genderValue,
                                icon: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.only(end: 7),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(
                                          0xffCECECE)), // myIcon is a 48px-wide widget.
                                ),
                                decoration:
                                    InputDecoration.collapsed(hintText: ''),
                                hint: Text(
                                  'Sexo',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xffCECECE)),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    genderValue = newValue.toString();
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'Campo requerido' : null,
                                items: genderList.map<DropdownMenuItem<String>>(
                                    (String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child:
                                        SizedBox(height: 20, child: Text(item)),
                                  );
                                }).toList(),
                              ),
                            )),
                      ),
                      SizeBox12,
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffCECECE), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: DropdownButtonFormField<String>(
                                value: educationalLevelValue,
                                icon: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.only(end: 7),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(
                                          0xffCECECE)), // myIcon is a 48px-wide widget.
                                ),
                                decoration:
                                    InputDecoration.collapsed(hintText: ''),
                                hint: Text(
                                  'Nivel Educacional',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xffCECECE)),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    educationalLevelValue = newValue.toString();
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'Campo requerido' : null,
                                items: educationalLevelList
                                    .map<DropdownMenuItem<String>>(
                                        (String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child:
                                        SizedBox(height: 20, child: Text(item)),
                                  );
                                }).toList(),
                              ),
                            )),
                      ),
                      SizeBox12,
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffCECECE), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: DropdownButtonFormField<String>(
                                value: civilStatusValue,
                                icon: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.only(end: 7),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(
                                          0xffCECECE)), // myIcon is a 48px-wide widget.
                                ),
                                decoration:
                                    InputDecoration.collapsed(hintText: ''),
                                hint: Text(
                                  'Estado Civil',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xffCECECE)),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    civilStatusValue = newValue.toString();
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'Campo requerido' : null,
                                items: civilStatusList
                                    .map<DropdownMenuItem<String>>(
                                        (String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child:
                                        SizedBox(height: 20, child: Text(item)),
                                  );
                                }).toList(),
                              ),
                            )),
                      ),
                      SizeBox12,
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffCECECE), width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  10) //         <--- border radius here
                              ),
                        ),
                        child: Container(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: DropdownButtonFormField<String>(
                                value: smokeValue,
                                icon: Padding(
                                  padding:
                                      const EdgeInsetsDirectional.only(end: 7),
                                  child: Icon(Icons.keyboard_arrow_down,
                                      color: Color(
                                          0xffCECECE)), // myIcon is a 48px-wide widget.
                                ),
                                decoration:
                                    InputDecoration.collapsed(hintText: ''),
                                hint: Text(
                                  'Tabaquismo',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xffCECECE)),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    smokeValue = newValue.toString();
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'Campo requerido' : null,
                                items: smokeList.map<DropdownMenuItem<String>>(
                                    (String item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child:
                                        SizedBox(height: 20, child: Text(item)),
                                  );
                                }).toList(),
                              ),
                            )),
                      ),
                      SizeBox12,
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const SizedBox(
                              height: 30,
                            ),
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.all(15),
                              color: const Color(0xff3BACB6),
                              textColor: Colors.white,
                              onPressed: () {
                                validateAndRegister();
                              },
                              child: const Text(
                                'Registrar',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  content: Column(
                    children: [
                      const SizedBox(
                        height: 80,
                      ),
                      SvgPicture.asset(
                        'assets/images/success_icon_modal.svg',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('¡Exito!',
                          style: TextStyle(
                              fontSize: 25,
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
                                // Navigator.pop(context);
                                Navigator.of(context)
                                    .pushNamed(LoginScreen.routeName);
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

  registerUser() async {
    try {
      var credential = (await _auth.createUserWithEmailAndPassword(
        email: emailValue,
        password: passwordValue,
      ));
      firebaseAuth.User? user = credential.user;
      if (user != null) {
        saveUserDataInDatabase();
      }
    } on FirebaseException catch (e, _) {
      if (e.code == FIREBASE_EMAIL_ALREDY_IN_USE) {
        setState(() {
          secondScreen = false;
          emailAlreadyInUse = true;
        });
        SchedulerBinding.instance.addPostFrameCallback((_) {
          validateAndGoToSecondScreen();
        });
      }
    } on Exception catch (e, _) {
      showMessageErrorRegister();
    }
  }

  void showMessageErrorRegister() {
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
                        height: 80,
                      ),
                      SvgPicture.asset(
                        'assets/images/warning_icon.svg',
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('¡Error!',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff67757F))),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                          'Ha ocurrido un error, intente nuevamente más tarde',
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
                                Navigator.pop(context);
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

  void saveUserDataInDatabase() {
    final db = FirebaseFirestore.instance;
    String? newUserId = FirebaseAuth.instance.currentUser?.uid;
    final userData = <String, String>{
      USER_ID_KEY: newUserId!,
      EMAIL_KEY: emailValue,
      FULL_NAME_KEY: fullNameValue,
      BIRTH_DAY_KEY: _selectedDate,
      PHONE_KEY: phoneNumberValue,
      DIABETES_TYPE_KEY: diabetesValue.toString(),
      MEDICAL_CENTER_VALUE: medicalCenterValue,
      MEDICAL_ASSURANCE_KEY: medicalAssuranceValue.toString(),
      GENDER_KEY: genderValue.toString(),
      EDUCATIONAL_LEVEL_KEY: educationalLevelValue.toString(),
      CIVIL_STATUS_KEY: civilStatusValue.toString(),
      SMOKING_KEY: smokeValue.toString(),
      PATIENT_CURRENT_TREATMENT_KEY: EMPTY_STRING_VALUE,
    };
    db
        .collection(USERS_COLLECTION_KEY)
        .doc(newUserId)
        .set(userData)
        .then((_) => dialogSuccess());
  }

  void validateAndGoToSecondScreen() {
    final FormState? form = signUpFormKeyFirstScreen.currentState;
    if (form?.validate() ?? false) {
      setState(() {
        secondScreen = true;
      });
    }
  }

  void validateAndRegister() {
    final FormState? form = signUpFormKeySecondScreen.currentState;
    if (form?.validate() ?? false) {
      registerUser();
    }
  }
}
