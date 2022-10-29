import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/Constants.dart';
import 'package:near_you/screens/home_screen.dart';
import 'package:near_you/screens/role_selection_screen.dart';
import 'package:near_you/screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../widgets/firebase_utils.dart';
import '../model/user.dart' as user;
import '../widgets/static_components.dart';
import 'getting_started_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoginWidget();
  }
}

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool showSelectRole = false;
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  bool userNotFound = false;
  bool wrongPassword = false;
  bool sessionStarted = false;

  @override
  void initState() {
    super.initState();
  }

  static StaticComponents staticComponents = StaticComponents();
  String emailValue = "";
  String passwordValue = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get inputBorder => OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xffCECECE)),
      borderRadius: BorderRadius.circular(10));

  get SizeBox12 => const SizedBox(
        height: 12,
      );

  @override
  Widget build(BuildContext context) {
    //return GettingStartedScreen();
    return Stack(children: <Widget>[
      Container(
          color: Colors.blue,
          width: double.maxFinite,
          height: double.maxFinite,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SvgPicture.asset('assets/images/backgroundLogin.svg'),
          )),
      Scaffold(backgroundColor: Colors.transparent, body: getFirstScreen())
    ]);
  }

  getFirstScreen() {
    var screenHeight = MediaQuery.of(context).size.height;
    return Form(
        key: loginFormKey,
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
                        height: screenHeight / 3.5,
                      ),
                      const Text(
                        "Iniciar Sesion",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff333333),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const <Widget>[
                            Text(
                              'Inicia sesión con una cuenta',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff555555),
                              ),
                            )
                          ]),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 40, right: 40),
                          //apply padding to all four sides
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1,
                                        color: const Color(0xffCECECE)),
                                    borderRadius: BorderRadius.circular(5),
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
                                        color: const Color(0xffCECECE)),
                                    borderRadius: BorderRadius.circular(5),
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
                                        color: const Color(0xffCECECE)),
                                    borderRadius: BorderRadius.circular(5),
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
                        height: 25,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: const <Widget>[
                            Expanded(
                                child: Divider(
                              color: Color(0xffCECECE),
                              thickness: 1,
                            )),
                            Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
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
                        height: 20,
                      ),
                      TextFormField(
                        controller: TextEditingController(text: emailValue),
                        onChanged: (value) {
                          emailValue = value.replaceAll(' ', '');
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
                          if (userNotFound) {
                            return "El email ingresado no se encuentra registrado";
                          }
                          if (wrongPassword) {
                            return "El email y la contraseña no coinciden";
                          }
                          if (sessionStarted) {
                            return "Ya existe una sesión iniciada para esta cuenta en otro dispositivo";
                          }
                        },
                        style: const TextStyle(fontSize: 14),
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
                        },
                        obscureText: true,
                        style: const TextStyle(fontSize: 14),
                        decoration:
                            staticComponents.getInputDecoration('Contraseña'),
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
                                _signInWithEmailAndPassword();
                              },
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizeBox12,
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Color(0xff9D9CB5),
                                      width: 1,
                                      style: BorderStyle.solid),
                                  borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.all(15),
                              textColor: const Color(0xff9D9CB5),
                              onPressed: () {
                                Navigator.of(context)
                                    .pushNamed(SignupScreen.routeName);
                              },
                              child: const Text(
                                'Registrarme',
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

  void _signInWithEmailAndPassword() async {
    final FormState? form = loginFormKey.currentState;
    wrongPassword = false;
    userNotFound = false;
    sessionStarted = false;
    if (!(form?.validate() ?? false)) {
      return;
    }
    User? authUser;
    try {
      var credential = (await _auth.signInWithEmailAndPassword(
        email: emailValue,
        password: passwordValue,
      ));
      authUser = credential.user;
    } on FirebaseException catch (e, _) {
      if (e.code == FIREBASE_NOT_FOUND_USER) {
        userNotFound = true;
        form?.validate();
        return;
      }
      if (e.code == FIREBASE_WRONG_PASSWORD) {
        wrongPassword = true;
        form?.validate();
        return;
      }
    }
    if (authUser != null) {
      var futureUser = await getUserById(authUser.uid);
      user.User dbUser = user.User.fromSnapshot(futureUser);
      showSelectRole = dbUser.type == null || dbUser.type == EMPTY_STRING_VALUE;
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      String androidUniqueId = androidInfo.id;
      if (dbUser.deviceLogged != null &&
          dbUser.deviceLogged != USER_DEVICE_LOGGED_EMPTY &&
          dbUser.deviceLogged != androidUniqueId) {
        //QSR1.210802.001
        sessionStarted = true;
        form?.validate();
        return;
      }
      await futureUser.reference.update({
        USER_DEVICE_LOGGED: androidUniqueId,
      });
      /*
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');
    */
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => getScreenAfterLogin(),
        ),
      );
    } else {
      showMessageErrorLogin();
    }
  }

  void showMessageErrorLogin() {
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

  getScreenAfterLogin() {
    if (showSelectRole) {
      return RoleSelectionScreen();
    } else {
      return HomeScreen();
    }
  }
}
