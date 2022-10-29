import '../Constants.dart';

class MedicationPrescription {
  String? databaseId;
  int? state;
  String? treatmentId;
  String? name;
  String? pastilleType;
  String? dose;
  String? quantity;
  String? recomendation;
  String? periodicity;
  String? startDate;
  String? endDate;
  String? durationNumber;
  String? durationType;

  MedicationPrescription(
      {this.databaseId,
      this.treatmentId,
      this.name,
      this.startDate,
      this.durationNumber,
      this.durationType,
      this.pastilleType,
      this.dose,
      this.quantity,
      this.periodicity,
      this.recomendation});

  factory MedicationPrescription.empty() {
    return MedicationPrescription(
        databaseId: "",
        treatmentId: "",
        name: "",
        startDate: "",
        durationNumber: "",
        durationType: "",
        pastilleType: "",
        dose: "",
        quantity: "",
        periodicity: "",
        recomendation: "");
  }

  factory MedicationPrescription.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return MedicationPrescription(
        databaseId: snapshot.id,
        treatmentId: realData[TREATMENT_ID_KEY],
        name: realData[MEDICATION_NAME_KEY],
        startDate: realData[MEDICATION_START_DATE_KEY],
        durationNumber: realData[MEDICATION_DURATION_NUMBER_KEY],
        durationType: realData[MEDICATION_DURATION_TYPE_KEY],
        pastilleType: realData[MEDICATION_PASTILLE_TYPE_KEY],
        dose: realData[MEDICATION_DOSE_KEY],
        quantity: realData[MEDICATION_QUANTITY_KEY],
        periodicity: realData[MEDICATION_PERIODICITY_KEY],
        recomendation: realData[MEDICATION_RECOMMENDATION_KEY]);
  }
}
