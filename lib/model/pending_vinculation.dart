import '../Constants.dart';

class PendingVinculation {
  String? databaseId;
  String? medicoId;
  String? patientId;
  String? status;
  String? applicantType;
  String? emailPending;
  String? namePending;

  PendingVinculation(
      {required this.databaseId,
      required this.medicoId,
      required this.patientId,
      required this.applicantType,
        required this.status,
        required this.emailPending,
        required this.namePending,
      });

  factory PendingVinculation.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return PendingVinculation(
        databaseId: snapshot.id,
        medicoId: realData[MEDICO_ID_KEY],
        patientId: realData[PATIENT_ID_KEY],
        applicantType: realData[APPLICANT_VINCULATION_USER_TYPE],
        emailPending: realData[VINCULATION_PENDING_EMAIL_KEY],
        namePending: realData[VINCULATION_PENDING_NAME_KEY],
        status: realData[VINCULATION_STATUS_KEY]);
  }
}
