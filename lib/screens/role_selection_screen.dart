import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:near_you/screens/home_screen.dart';

import '../Constants.dart';

class RoleSelectionScreen extends StatelessWidget {
  static const routeName = '/role_selection';
  static const PACIENTE = "Paciente";
  static const MEDICO = "Médico";

  @override
  Widget build(BuildContext context) {
    return const RoleSelectionWidget();
  }
}

class RoleSelectionWidget extends StatefulWidget {
  const RoleSelectionWidget({Key? key}) : super(key: key);

  @override
  State<RoleSelectionWidget> createState() => _RoleSelectionWidgetState();
}

class _RoleSelectionWidgetState extends State<RoleSelectionWidget> {
  bool selectedPaciente = false;
  bool selectedMedico = false;

  var imageMedicoEnabled;

  var imageMedicoDisabled;

  var imagePacienteEnabled;

  var imagePacienteDisabled;

  get SizeBox12 => const SizedBox(
        height: 12,
      );

  @override
  void initState() {
    super.initState();
    imageMedicoEnabled = getImage('assets/images/medico_enabled.png');
    imageMedicoDisabled = getImage('assets/images/medico_disabled.png');
    imagePacienteEnabled = getImage('assets/images/paciente_enabled.png');
    imagePacienteDisabled = getImage('assets/images/paciente_disabled.png');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(imageMedicoEnabled.image, context);
    precacheImage(imagePacienteEnabled.image, context);
    precacheImage(imageMedicoDisabled.image, context);
    precacheImage(imagePacienteDisabled.image, context);
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
              icon: const Icon(null),
              onPressed: () {
                setState(() {});
              },
            ),
          ),
          backgroundColor: Colors.transparent,
          body: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
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
                        const SizedBox(
                          height: 100,
                        ),
                        const Text(
                          "¡Hola!",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff333333),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Indicanos',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ' ¿Quién eres?',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xff2F8F9D),
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            getUserRoleWidget(RoleSelectionScreen.PACIENTE),
                            SizedBox(
                              height: 226,
                              child: const Padding(
                                  padding: EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: VerticalDivider(
                                    thickness: 1,
                                    color: const Color(0xffCECECE),
                                  )),
                            ),
                            getUserRoleWidget(RoleSelectionScreen.MEDICO)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ))
    ]);
  }

  getUserRoleWidget(String roleName) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 30,
          ),
          GestureDetector(
              onTap: () {
                setState(() {
                  selectedPaciente = roleName == RoleSelectionScreen.PACIENTE;
                  selectedMedico = roleName == RoleSelectionScreen.MEDICO;
                  updateInfoInFirebase();
                  Navigator.pushReplacement<void, void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => HomeScreen(),
                    ),
                  );
                });
              }, // Image tapped
              child: getImageUserRole(roleName)),
          const SizedBox(
            height: 12,
          ),
          Text(roleName, style: getUserRoleStyle(roleName))
        ]);
  }

  getUserRoleStyle(String roleName) {
    var color;
    color = Color(selectedMedico ? 0xff2F8F9D : 0xffCECECE);
    if (roleName == RoleSelectionScreen.PACIENTE) {
      color = Color(selectedPaciente ? 0xff2F8F9D : 0xffCECECE);
    }
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  getImageUserRole(String roleName) {
    if (roleName == RoleSelectionScreen.PACIENTE) {
      return selectedPaciente ? imagePacienteEnabled : imagePacienteDisabled;
    }
    return selectedMedico ? imageMedicoEnabled : imageMedicoDisabled;
  }

  static getImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.none,
    );
  }

  Future<void> updateInfoInFirebase() async {
    final db = FirebaseFirestore.instance;
    var isPatientSelected = selectedPaciente == true;
    var postDocRef= db.collection(USERS_COLLECTION_KEY).doc(FirebaseAuth.instance.currentUser?.uid);
    await postDocRef.update({
      USER_TYPE: isPatientSelected? USER_TYPE_PACIENTE: USER_TYPE_MEDICO,
      // ....rest of your data
    });
  }
}
