import 'package:flutter/material.dart';
import 'package:near_you/screens/home_screen.dart';

import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_html/flutter_html.dart';

class GettingStartedScreen extends StatefulWidget {
  static const routeName = '/getting_started';

  @override
  _GettingStartedScreenState createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            const Circles1(),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                        padding:
                            EdgeInsets.fromLTRB(0, screenHeight / 4, 0, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                width: double.maxFinite,
                                height: screenHeight * 0.3,
                                child:
                                    SvgPicture.asset('assets/images/logo.svg')),
                            SizedBox(
                              height: screenHeight / 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 60, left: 60),
                              child: Html(
                                data:
                                    'Monitorea <span style="color:#2F8F9D">el seguimiento a la<br> adherencia con</span> una rutina diaria.',
                                style: {
                                  "body": Style(
                                    fontSize: FontSize(14),
                                    textAlign: TextAlign.center,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xffd555555),
                                  ),
                                },
                              ),
                            )
                          ],
                        )),
                    SizedBox(
                      height: screenHeight / 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.all(15),
                          color: const Color(0xff3BACB6),
                          textColor: Colors.white,
                          onPressed: () {
                            onClickStart();
                          },
                          child: const Text(
                            'Empezar',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 20),
                              //apply padding to all four sides
                              child: Text(
                                'Ya tengo una cuenta',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            LoginButton()
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onClickStart() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => SignupScreen()));
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: const Text(
                'Iniciar Sesion',
                style: TextStyle(fontSize: 14, color: Color(0xff3BACB6)),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => LoginScreen()));
              },
            ),
            const Text(
              'Aqui',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }
}

class Circles1 extends StatelessWidget {
  const Circles1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SvgPicture.asset('assets/images/backgroundLogin.svg',
          fit: BoxFit.fill),
    );
  }
}
