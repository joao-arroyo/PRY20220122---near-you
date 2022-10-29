import '../Constants.dart';

class ExamsPrescription {
  String? databaseId;
  int? state;
  String? treatmentId;
  String? name;
  String? endDate;
  String? periodicity;

  ExamsPrescription({
     this.databaseId,
     this.treatmentId,
     this.name,
     this.periodicity,
     this.endDate,
  });

  factory ExamsPrescription.empty() {
    return ExamsPrescription(
      databaseId: "",
      treatmentId: "",
      name: "",
      periodicity: "",
      endDate: '',
    );
  }

  factory ExamsPrescription.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return ExamsPrescription(
      databaseId: snapshot.id,
      treatmentId: realData[TREATMENT_ID_KEY],
      name: realData[EXAMN_NAME_KEY],
      periodicity: realData[EXAMN_PERIODICITY_KEY],
      endDate: realData[EXAMN_END_DATE_KEY],
    );
  }
}
