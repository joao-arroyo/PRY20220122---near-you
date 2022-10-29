import 'package:cloud_firestore/cloud_firestore.dart';

import '../Constants.dart';

class Treatment {
  Treatment(
      {
        required this.databaseId,
        required this.treatmentId,
      required this.medicoId,
      required this.patientId,
      required this.startDate,
      required this.endDate,
      required this.durationNumber,
        required this.durationType,
        required this.state,
      required this.description,
      required this.prescriptions});

  int? treatmentId;
  String? medicoId;
  String? databaseId;
  String? patientId;
  String? startDate;
  String? endDate;
  String? durationNumber;
  String? durationType;
  String? state;

  String? description;
  /*  String? weight;
  String? height;
  String? imc;*/

  List<String>? prescriptions;

  factory Treatment.empty() {
    return Treatment(
        databaseId :"",
        treatmentId: 0, medicoId: "",
        patientId: "",
        startDate: "d",
        endDate: "",
        durationNumber: "",
        durationType: "",
        state: "", description:
        "",
        prescriptions: List.empty(growable: true));
  }
  factory Treatment.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return Treatment(
        databaseId: realData[TREATMENT_DATABASE_ID],
        treatmentId: realData[TREATMENT_ID_KEY],
        medicoId: realData[MEDICO_ID_KEY],
        patientId: realData[PATIENT_ID_KEY],
        startDate: realData[TREATMENT_START_DATE_KEY],
        endDate: realData[TREATMENT_END_DATE_KEY],
        durationNumber: realData[TREATMENT_DURATION_NUMBER_KEY],
        durationType: realData[TREATMENT_DURATION_TYPE_KEY],
        state: realData[TREATMENT_STATE_KEY],
        description: realData[TREATMENT_DESCRIPTION_KEY],
        prescriptions: realData[PRESCRIPTIONS_KEY]);
  }
}
