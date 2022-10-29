class StaticSurvey {
  static List<SurveyData> surveyStaticList = [
    SurveyData(
        "1. ¿Dejaría de monitorear su tratamiento si se siente mejor o peor después de seguir las indicaciones de su médico?",
        [
          "Nunca / raramente",
          "De vez en cuando",
          "A veces",
          "Usualmente- casi siempre",
          "Todo el tiempo – siempre"
        ]),
    SurveyData(
        "2. Cuando viaja o sale de casa ¿se olvida de llevar su medicina?", [
      "Nunca / raramente",
      "De vez en cuando",
      "A veces",
      "Usualmente- casi siempre",
      "Todo el tiempo – siempre"
    ]),
    SurveyData("3. Cuando siente que sus síntomas están bajo control ¿deja de seguir su tratamiento?", [
      "Nunca / raramente",
      "De vez en cuando",
      "A veces",
      "Usualmente- casi siempre",
      "Todo el tiempo – siempre"
    ]),
    SurveyData(
        "4. ¿Alguna vez sintió que fue un inconveniente seguir su tratamiento de diabetes?", [
      "Nunca / raramente",
      "De vez en cuando",
      "A veces",
      "Usualmente- casi siempre",
      "Todo el tiempo – siempre"
    ]),
    SurveyData("5. ¿Con qué frecuencia tiene dificultad de seguir su tratamiento?", [
      "Nunca / raramente",
      "De vez en cuando",
      "A veces",
      "Usualmente- casi siempre",
      "Todo el tiempo – siempre"
    ]),
    SurveyData("6. ¿Ha fumado usted cigarrillo en los últimos días?", [
      "Nunca / raramente",
      "De vez en cuando",
      "A veces",
      "Usualmente- casi siempre",
      "Todo el tiempo – siempre"
    ])
  ];
}

class SurveyData {
  String question;
  List<String> options;

  SurveyData(this.question, this.options);
}
