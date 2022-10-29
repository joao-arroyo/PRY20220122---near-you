import 'package:flutter/material.dart';
import 'package:near_you/widgets/static_components.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'firebase_utils.dart';

void showDialogVinculation(
    String currentUserName,
    String currentEmail,
    BuildContext context,
    bool userIsPatient,
    Function errorFunction,
    Function successFunction) {
  String? emailUser;
  bool validationError = false;
  final GlobalKey<FormState> vinculationFormKey = GlobalKey<FormState>();
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
                  Text("Ingrese el correo electrónico")
                ]),
                titleTextStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff67757F)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Form(
                        key: vinculationFormKey,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value == '') {
                              return "Complete el campo";
                            }
                            if (validationError) {
                              return "Email inválido";
                            }
                          },
                          controller: TextEditingController(text: emailUser),
                          onChanged: (value) {
                            emailUser = value;
                          },
                          style: TextStyle(fontSize: 14),
                          decoration: StaticComponents().getInputDecoration(
                              'Correo del ${userIsPatient ? "médico" : "paciente"}'),
                        )),
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
                            onPressed: () async {
                              final FormState form =
                                  vinculationFormKey.currentState!;
                              validationError = false;
                              if (form.validate()) {
                                bool attachment = await attachMedicoToPatient(
                                    currentUserName,
                                    currentEmail,
                                    emailUser,
                                    userIsPatient,
                                    errorFunction,
                                    successFunction);
                                validationError = !attachment;
                                form.validate();
                              }
                            },
                            child: const Text(
                              'Vincular',
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

void dialogWaitVinculation(
    BuildContext context, Function acceptFunction, bool isPatient) {
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
                      height: 30,
                    ),
                    SvgPicture.asset(
                      'assets/images/clock_icon.svg',
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                        'Es tiempo de esperar la\n confirmación de su ${isPatient ? 'médico' : 'paciente'}\n asignado',
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
                              acceptFunction();
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

void showDialogSuccessVinculation(BuildContext context, String message, Function execute) {
  Navigator.pop(context);
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
                  Text("Operación\n Exitosa", textAlign: TextAlign.center)
                ]),
                titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff67757F)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(message,
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
                             execute();
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

void dialogSuccessDoctorAccepts(BuildContext context) {
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
                      height: 40,
                    ),
                    SvgPicture.asset(
                      'assets/images/success_icon_modal.svg',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text('¡Su medico acepto la\n vinculacion!',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff67757F))),
                    const SizedBox(
                      height: 30,
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

void showDialogDevinculation(
    BuildContext context, String patientId, bool isPatient, Function execute) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(alignment: WrapAlignment.center, children: [
            AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    SvgPicture.asset(
                      'assets/images/warning_icon.svg',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                        isPatient
                            ? '¿Desea desvincular al médico\n asignado?'
                            : '¿Desea desvincular este\n paciente?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xfF67757F))),
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
                              devinculate(context, patientId, isPatient, execute);
                            },
                            child: Text(
                              isPatient ? 'Desvincular' : 'Sí, Desvincular',
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
