import 'package:cloud_firestore/cloud_firestore.dart';

import '../Constants.dart';

class Routine {
  Routine(
      {required this.hourCompleted,
      required this.medicationPercentage,
      required this.activityPercentage,
      required this.nutritionPercentage,
      required this.examsPercentage,
      required this.totalPercentage});

  String? dateId;
  String? hourCompleted;
  double medicationPercentage;
  double activityPercentage;
  double nutritionPercentage;
  double examsPercentage;
  double totalPercentage;

  factory Routine.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return Routine(
        hourCompleted: realData[ROUTINE_HOUR_COMPLETED_KEY],
        medicationPercentage: (realData[ROUTINE_MEDICATION_PERCENTAGE_KEY]??0).toDouble(),
        nutritionPercentage: (realData[ROUTINE_NUTRITION_PERCENTAGE_KEY]??0).toDouble(),
        activityPercentage: (realData[ROUTINE_ACTIVITY_PERCENTAGE_KEY]??0).toDouble(),
        examsPercentage: (realData[ROUTINE_EXAMS_PERCENTAGE_KEY]??0).toDouble(),
        totalPercentage: (realData[ROUTINE_TOTAL_PERCENTAGE_KEY]??0).toDouble());
  }
}
