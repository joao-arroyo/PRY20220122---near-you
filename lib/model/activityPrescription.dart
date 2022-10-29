import '../Constants.dart';

class ActivityPrescription {
  String? databaseId;
  int? state;
  String? name;
  String? activity;
  String? periodicity;
  String? calories;
  String? timeNumber;
  String? timeType;
  String? treatmentId;

  ActivityPrescription(
      {this.databaseId,
      this.treatmentId,
      this.name,
      this.activity,
      this.timeNumber,
      this.timeType,
      this.periodicity,
      this.calories});

  factory ActivityPrescription.empty() {
    return ActivityPrescription(
        databaseId: "",
        treatmentId: "",
        name: "",
        activity: "",
        timeNumber: "",
        timeType: "",
        periodicity: "",
        calories: "");
  }

  factory ActivityPrescription.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return ActivityPrescription(
        databaseId: snapshot.id,
        treatmentId: realData[TREATMENT_ID_KEY],
        name: realData[ACTIVITY_NAME_KEY],
        activity: realData[ACTIVITY_ACTIVITY_KEY],
        timeNumber: realData[ACTIVITY_TIME_NUMBER_KEY],
        timeType: realData[ACTIVITY_TIME_TYPE_KEY],
        periodicity: realData[ACTIVITY_PERIODICITY_KEY],
        calories: realData[ACTIVITY_CALORIES_KEY]);
  }
}
