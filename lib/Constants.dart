const String FIREBASE_NOT_FOUND_USER = "user-not-found";
const String FIREBASE_WRONG_PASSWORD = "wrong-password";
const String FIREBASE_EMAIL_ALREDY_IN_USE = "email-already-in-use";

const String SHOW_INTRO_SLIDE = "SHOW_INTRO_SLIDE";
const String PREF_USER_NAME = "PREF_USER_NAME";
const String PREF_NEXT_SURVEY_DATE = "PREF_NEXT_SURVEY_DATE";
const String PUSH_TOPIC_ALL = "all";
const String PUSH_TOPIC_PATIENT = "patient";
const String PUSH_TOPIC_DOCTOR = "doctor";
const String PUSH_PARAM_UNSUBSCRIBE = "unsubscribe";
const String PUSH_PARAM_TITLE = "title";
const String PUSH_PARAM_BODY = "body";
const String PUSH_PARAM_TYPE = "type";
const String PUSH_PARAM_TYPE_SURVEY = "survey";
const String PUSH_REPLACE_PACIENTE = "PACIENTE";
const String PUSH_REPLACE_MEDICO = "MEDICO";

const String EMAIL_KEY = "email";
const String FULL_NAME_KEY = "fullName";
const String BIRTH_DAY_KEY = "birthDay";
const String PHONE_KEY = "phoneNumber";

const String DIABETES_TYPE_KEY = "diabetesType";
const String MEDICAL_CENTER_VALUE = "medicalCenter";
const String MEDICAL_ASSURANCE_KEY = "medicalAssurance";
const String GENDER_KEY = "sex";
const String EDUCATIONAL_LEVEL_KEY = "educationalLevel";
const String CIVIL_STATUS_KEY = "civilStatus";
const String SMOKING_KEY = "smoking";
const String ADDRESS_KEY = "address";
const String REFERENCE_KEY = "reference";

const String USERS_COLLECTION_KEY = "users";
const String PENDING_VINCULATIONS_COLLECTION_KEY = "pendingVinculations";
const String USER_TYPE = "type";
const String USER_DEVICE_LOGGED = "deviceLogged";
const String USER_DEVICE_LOGGED_EMPTY = "NO_DEVICE_LOGGED";
const String USER_TYPE_MEDICO = "MEDICO";
const String USER_TYPE_PACIENTE = "PACIENTE";
const String TREATMENTS_KEY = "treatments";
const String PRESCRIPTIONS_KEY = "prescriptions";
const String ATTACHED_PATIENTS = "attachedPatients";
const String MEDICO_ID_KEY = "medicoId";
const String PATIENT_ID_KEY = "patientId";
const String USER_ID_KEY = "userId";
const String USER_DATE_NEXT_SURVEY_KEY = "nextSurveyDate";
const String VINCULATIONS_KEY = "vinculations";
const String ADHERENCE_LEVEL_KEY = "adherenceLevel";
const String PATIENT_CURRENT_TREATMENT_KEY = "currentTreatment";
const String EMPTY_STRING_VALUE = "";

const String TREATMENT_ID_KEY = "treatmentId";
const String TREATMENT_DATABASE_ID = "databaseId";
const String TREATMENT_START_DATE_KEY = "startDate";
const String TREATMENT_END_DATE_KEY = "endDate";
const String TREATMENT_DURATION_NUMBER_KEY = "durationNumber";
const String TREATMENT_DURATION_TYPE_KEY = "durationType";
const String TREATMENT_DESCRIPTION_KEY = "description";
const String TREATMENT_PRESCRIPTIONS_KEY = "prescriptions";
const String TREATMENT_STATE_KEY = "state";

const String PRESCRIPTIONS_COLLECTION_KEY = "prescriptions";

const String EXAMN_NAME_KEY = "name";
const String EXAMN_PERIODICITY_KEY = "duration";
const String EXAMN_END_DATE_KEY = "endDate";

const String ACTIVITY_NAME_KEY = "name";
const String ACTIVITY_ACTIVITY_KEY = "activity";
const String ACTIVITY_PERIODICITY_KEY = "periodicity";
const String ACTIVITY_CALORIES_KEY = "calories";
const String ACTIVITY_TIME_NUMBER_KEY = "timeNumber";
const String ACTIVITY_TIME_TYPE_KEY = "timeType";

const String MEDICATION_NAME_KEY = "name";
const String MEDICATION_START_DATE_KEY = "startDate";
const String MEDICATION_DURATION_NUMBER_KEY = "durationNumber";
const String MEDICATION_DURATION_TYPE_KEY = "durationType";
const String MEDICATION_PASTILLE_TYPE_KEY = "pastilleType";
const String MEDICATION_DOSE_KEY = "dose";
const String MEDICATION_QUANTITY_KEY = "quantity";
const String MEDICATION_PERIODICITY_KEY = "periodicity";
const String MEDICATION_RECOMMENDATION_KEY = "recomendation";

const String NUTRITION_NAME_KEY = "name";
const String NUTRITION_CARBOHYDRATES_KEY = "carbohydrates";
const String NUTRITION_MAX_CALORIES_KEY = "maxCalories";
const String NUTRITION_HEIGHT_KEY = "height";
const String NUTRITION_WEIGHT_KEY = "weight";
const String NUTRITION_IMC_KEY = "imc";

const String MEDICATION_PRESCRIPTION_COLLECTION_KEY = "medicationPrescriptions";
const String NUTRITION_PRESCRIPTION_COLLECTION_KEY = "nutritionPrescriptions";
const String ACTIVITY_PRESCRIPTION_COLLECTION_KEY = "activityPrescriptions";
const String EXAMS_PRESCRIPTION_COLLECTION_KEY = "examnPrescriptions";


const String PENDING_MEDICATION_PRESCRIPTIONS_COLLECTION_KEY =
    "pendingMedicationPrescriptions";
const String PENDING_NUTRITION_PRESCRIPTIONS_COLLECTION_KEY =
    "pendingNutritionPrescriptions";
const String PENDING_ACTIVITY_PRESCRIPTIONS_COLLECTION_KEY =
    "pendingActivityPrescriptions";
    const String PENDING_EXAMS_PRESCRIPTIONS_COLLECTION_KEY =
    "pendingExamsPrescriptions";
const String PENDING_PRESCRIPTIONS_TREATMENT_KEY = "pendingTreatmentId";
const String PENDING_PRESCRIPTIONS_ID_KEY = "pendingPrescriptionId";

const String PERMITTED_KEY = "permitted";
const String YES_KEY = "yes";
const String NO_KEY = "no";

const String APPLICANT_VINCULATION_USER_TYPE = "applicantType";

//TODO  Chequear el mostrar el role selection si es otro user

const List<String> durationsList = ["días", "semanas", "meses", "años"];
const List<String> durationsActivityList = ["horas", "segundos", "horas"];
const List<String> pastilleTypeList = ["Pastilla antidiabética", "Otro tipo"];
const List<String> pastilleQuantitiesList = [
  "1 pastilla",
  "2 pastillas",
  "3 pastillas",
  "4 pastillas",
  "5 pastillas"
];
const List<String> periodicityList = ["Diaria", "Semanal", "Mensual"];

const String SURVEY_COLLECTION_KEY = "surveys";
const String SURVEY_TIMESTAMP_KEY = "timestamp";

const String VINCULATION_STATUS_KEY = "vinculationStatus";
const String VINCULATION_STATUS_PENDING = "pending";
const String VINCULATION_STATUS_ACCEPTED = "accepted";
const String VINCULATION_STATUS_REFUSED = "refused";
const String VINCULATION_PENDING_NAME_KEY = "pendingName";
const String VINCULATION_PENDING_EMAIL_KEY = "pendingEmail";

const String ROUTINE_MEDICATION_PERCENTAGE_KEY = "medicationPercentage";
const String ROUTINE_NUTRITION_PERCENTAGE_KEY = "nutritionPercentage";
const String ROUTINE_ACTIVITY_PERCENTAGE_KEY = "activityPercentage";
const String ROUTINE_EXAMS_PERCENTAGE_KEY = "examsPercentage";
const String ROUTINE_TOTAL_PERCENTAGE_KEY = "totalPercentage";
const String ROUTINE_HOUR_COMPLETED_KEY = "hourCompleted";
const String ROUTINE_EXAM_GLUCOSA_LEVEL = "glucosaLevel";

const String ROUTINES_COLLECTION_KEY = "routines";
const String ROUTINES_RESULTS_KEY = "routinesResults";

const String DATA_COLLECTION_KEY = "data";
const String BAR_CHART_COLLECTION_KEY = "dataBarChart";

const String DATA_EDAD_KEY = "Edad";
const String DATA_SEXO_KEY = "Sexo";
const String DATA_ESTADO_CIVIL_KEY = "EstadoCivil";
const String DATA_NIVEL_EDUCACIONAL_KEY = "NivelEducacional";
const String DATA_FUMA_KEY = "Fuma";
const String DATA_PREGUNTA1_KEY = "Pregunta1";
const String DATA_PREGUNTA2_KEY = "Pregunta2";
const String DATA_PREGUNTA3_KEY = "Pregunta3";
const String DATA_PREGUNTA4_KEY = "Pregunta4";
const String DATA_PREGUNTA5_KEY = "Pregunta5";
const String DATA_PREGUNTA6_KEY = "Pregunta6";
const String DATA_MEDICACION_KEY = "Medicacion";
const String DATA_ALIMENTACION_KEY = "Alimentacion";
const String DATA_ACTIVIDAD_FISICA_KEY = "ActividadFisica";
const String DATA_EXAMENES_KEY = "Examenes";
const String DATA_SUMA_KEY = "Suma";
const String DATA_ADHERENCIA_KEY = "Adherencia";
const String DATA_TIMESTAMP_KEY = "timestamp";
const String REGEX_PASSWORD = "^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[#?!@\$%^&*-]).{7,}\$";
const String REGEX_EMAIL = "^[a-zA-Z0-9.a-zA-Z0-9.!#\$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+";
const String PREDICTIONS_KEY = "predictions";
const int ADHERENCE_PREDICTION_ERROR = -1;
const String NOT_SPECIFIED_VALUE = "no especificado";
const String VINCULATED_KEY = "vinculado";
const String SURVEY_DISABLED_DEFAULT_DATE = "01-01-1800";