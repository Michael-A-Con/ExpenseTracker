import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'individual_bar.dart';

class MyBarGraph extends StatefulWidget {
  final List<double> monthlySummary;
  final int startMonth;

  const MyBarGraph(
      {super.key, required this.monthlySummary, required this.startMonth});

  @override
  State<MyBarGraph> createState() => _MyBarGraphState();
}

class _MyBarGraphState extends State<MyBarGraph> {
  List<IndividualBar> barData = [];

  void initializeBarData() {
    barData = List.generate(
      widget.monthlySummary.length,
      (index) => IndividualBar(
        x: index,
        y: widget.monthlySummary[index],
      ),
    );
  }

  //calculate appropiate Y value for chart
  double calculateMax() {
    double max = 300000.00;

    widget.monthlySummary.sort();
    max = widget.monthlySummary.last * 1.05;

    if (max < 300000.00) {
      return 300000.00;
    }

    return max;
  }

  @override
  Widget build(BuildContext context) {
    //init bar chart
    initializeBarData();

    double barWidth = 20;
    double spaceBetweenBars = 10;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: barWidth * barData.length + spaceBetweenBars * (barData.length - 1),
        child: BarChart(BarChartData(
          minY: 0,
          maxY: calculateMax(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getBottomTitles,
              reservedSize: 25,
            )),
          ),
          barGroups: barData
              .map(
                  (data) => BarChartGroupData(
                  x: data.x,
                      barRods: [
                        BarChartRodData(
                          toY: data.y,
                          width: barWidth,
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xff2f4f4f),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: calculateMax(),
                            color: Colors.grey[200]
                          )
                        )]))
              .toList(),
        )),
      ),
    );
  }

  // Bottom titles
  Widget getBottomTitles(double value, TitleMeta meta) {
    const textstyle = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    String text;

    switch (value.toInt()%12) {
      case 0:
        text = 'J';
        break;
      case 1:
        text = 'F';
        break;
      case 2:
        text = 'M';
        break;
      case 3:
        text = 'A';
        break;
      case 4:
        text = 'M';
        break;
      case 5:
        text = 'J';
        break;
      case 6:
        text = 'J';
        break;
      case 7:
        text = 'A';
        break;
      case 8:
        text = 'S';
        break;
      case 9:
        text = 'O';
        break;
      case 10:
        text = 'N';
        break;
      case 11:
        text = 'D';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
        child: Text(text, style: textstyle), axisSide: meta.axisSide);
  }
}
