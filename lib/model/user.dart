import 'package:cloud_firestore/cloud_firestore.dart';

import '../Constants.dart';

class User {
  String? civilStatus;
  String? educationalLevel;
  String? medicalAssurance;

  User(
      {required this.fullName,
      required this.email,
      required this.userId,
      required this.birthDay,
      required this.phone,
      required this.type,
      required this.smoking,
      required this.gender,
      required this.medicalCenter,
      required this.diabetesType,
      required this.medicalAssurance,
      required this.educationalLevel,
      required this.civilStatus,
      required this.currentTreatment,
      required this.attachedPatients,
      required this.adherenceLevel,
      required this.address,
      required this.reference,
      required this.dateNextSurvey,
      required this.deviceLogged,
      required this.medicoId});

  String? attachedPatients;
  String? fullName;
  String? userId;
  String? email;
  String? dateNextSurvey;
  double? adherenceLevel;
  String? birthDay;
  String? phone;
  String? medicoId;

  String? age;

  String? address;

  String? medicalCenter;

  String? gender;

  String? reference;

  String? alternativePhone;

  String? smoking;

  String? allergies;

  String? type;
  String? deviceLogged;
  String? diabetesType;
  String? currentTreatment;

  factory User.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return User(
        fullName: realData[FULL_NAME_KEY],
        email: realData[EMAIL_KEY],
        userId: realData[USER_ID_KEY],
        birthDay: realData[BIRTH_DAY_KEY],
        phone: realData[PHONE_KEY],
        medicalCenter: realData[MEDICAL_CENTER_VALUE],
        gender: realData[GENDER_KEY],
        smoking: realData[SMOKING_KEY],
        type: realData[USER_TYPE],
        diabetesType: realData[DIABETES_TYPE_KEY],
        medicalAssurance: realData[MEDICAL_ASSURANCE_KEY],
        educationalLevel: realData[EDUCATIONAL_LEVEL_KEY],
        civilStatus: realData[CIVIL_STATUS_KEY],
        currentTreatment: realData[PATIENT_CURRENT_TREATMENT_KEY],
        attachedPatients: realData[ATTACHED_PATIENTS],
        adherenceLevel: realData[ADHERENCE_LEVEL_KEY],
        address: realData[ADDRESS_KEY],
        reference: realData[REFERENCE_KEY],
        dateNextSurvey: realData[USER_DATE_NEXT_SURVEY_KEY],
        deviceLogged: realData[USER_DEVICE_LOGGED],
        medicoId: realData[MEDICO_ID_KEY]);
  }

  bool isPatient() {
    return type == USER_TYPE_PACIENTE;
  }
}
