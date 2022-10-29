/// Bar chart example
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:near_you/Constants.dart';

class GroupedBarChart extends StatelessWidget {
  final List<charts.Series<dynamic, String>> seriesList;
  final bool animate;

  GroupedBarChart(this.seriesList, {required this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      primaryMeasureAxis:
          charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
      domainAxis: charts.OrdinalAxisSpec(
          renderSpec: new charts.SmallTickRendererSpec(

              // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(
                  fontSize: 6, // size in Pts.
                  color: charts.Color.fromHex(code: "#999999")),

              // Change the line colors to match text color.
              lineStyle: new charts.LineStyleSpec(
                  color: charts.MaterialPalette.transparent)),
          showAxisLine: false,
          viewport: charts.OrdinalViewport(
              '0', seriesList[0].data.length > 7 ? 6 : 7)),
      behaviors: [
        // Add the sliding viewport behavior to have the viewport center on the
        // domain that is currently selected.
        new charts.SlidingViewport(),
        // A pan and zoom behavior helps demonstrate the sliding viewport
        // behavior by allowing the data visible in the viewport to be adjusted
        // dynamically.
        new charts.PanAndZoomBehavior(),
      ],
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
      defaultRenderer: charts.BarRendererConfig(
          cornerStrategy: const charts.ConstCornerStrategy(9),
          barRendererDecorator: charts.BarLabelDecorator<String>(
              labelPosition: charts.BarLabelPosition.outside)),
    );
  }
}

class BarCharData {
  String? dateLabel;
  double? adherence;
  DateTime? dateTime;
  double? medicationPercentage;
  double? nutritionPercentage;
  double? activitiesPercentage;
  double? examsPercentage;
  int? timestamp;

  BarCharData(
      {this.adherence,
      this.dateTime,
      this.medicationPercentage,
      this.nutritionPercentage,
      this.activitiesPercentage,
      this.examsPercentage,
      this.timestamp});

  factory BarCharData.fromSnapshot(snapshot) {
    var realData = snapshot.data();
    return BarCharData(
        adherence: realData[DATA_ADHERENCIA_KEY] ?? 0 * 100,
        timestamp: realData[DATA_TIMESTAMP_KEY],
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            realData[DATA_TIMESTAMP_KEY] ?? 0),
        medicationPercentage: realData[ROUTINE_MEDICATION_PERCENTAGE_KEY],
        nutritionPercentage: realData[ROUTINE_NUTRITION_PERCENTAGE_KEY],
        activitiesPercentage: realData[ROUTINE_ACTIVITY_PERCENTAGE_KEY],
        examsPercentage: realData[ROUTINE_EXAMS_PERCENTAGE_KEY]);
  }
}
