import '../Constants.dart';

class NutritionPrescription {
  String? databaseId;
  int? state;
  String? treatmentId;
  String? name;
  String? carbohydrates;
  String? maxCalories;
  String? permitted;
  String? height;
  String? weight;
  String? imc;

  NutritionPrescription({
    this.databaseId,
    this.treatmentId,
    this.name,
    this.carbohydrates,
    this.maxCalories,
    this.permitted,
    this.weight,
    this.height,
    this.imc,
  });

  factory NutritionPrescription.empty() {
    return NutritionPrescription(
        databaseId: "",
        treatmentId: "",
        name: "",
        carbohydrates: "",
        maxCalories: "",
        permitted: "");
  }

  factory NutritionPrescription.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return NutritionPrescription(
      databaseId: snapshot.id,
      treatmentId: realData[TREATMENT_ID_KEY],
      name: realData[NUTRITION_NAME_KEY],
      carbohydrates: realData[NUTRITION_CARBOHYDRATES_KEY],
      maxCalories: realData[NUTRITION_MAX_CALORIES_KEY],
      permitted: realData[PERMITTED_KEY],
      weight: realData[NUTRITION_WEIGHT_KEY],
      height: realData[NUTRITION_HEIGHT_KEY],
      imc: realData[NUTRITION_IMC_KEY]
    );
  }
}
