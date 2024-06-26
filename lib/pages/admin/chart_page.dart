import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('User Statistics', style: TextStyle(color: Colors.grey[300])),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[900],
        padding: EdgeInsets.all(16),
        child: Card(
          color: Colors.grey[850],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceEvenly,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return Text('Mon',
                                          style:
                                              TextStyle(color: Colors.white));
                                    case 1:
                                      return Text('Tue',
                                          style:
                                              TextStyle(color: Colors.white));
                                    case 2:
                                      return Text('Wed',
                                          style:
                                              TextStyle(color: Colors.white));
                                    case 3:
                                      return Text('Thu',
                                          style:
                                              TextStyle(color: Colors.white));
                                    case 4:
                                      return Text('Fri',
                                          style:
                                              TextStyle(color: Colors.white));
                                    case 5:
                                      return Text('Sat',
                                          style:
                                              TextStyle(color: Colors.white));
                                    case 6:
                                      return Text('Sun',
                                          style:
                                              TextStyle(color: Colors.white));
                                    default:
                                      return Text('');
                                  }
                                })),
                      ),
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [
                          BarChartRodData(toY: 5, color: Colors.orange)
                        ]),
                        BarChartGroupData(x: 1, barRods: [
                          BarChartRodData(toY: 6, color: Colors.orange)
                        ]),
                        BarChartGroupData(x: 2, barRods: [
                          BarChartRodData(toY: 7, color: Colors.orange)
                        ]),
                        BarChartGroupData(x: 3, barRods: [
                          BarChartRodData(toY: 8, color: Colors.orange)
                        ]),
                        BarChartGroupData(x: 4, barRods: [
                          BarChartRodData(toY: 6, color: Colors.orange)
                        ]),
                        BarChartGroupData(x: 5, barRods: [
                          BarChartRodData(toY: 7, color: Colors.orange)
                        ]),
                        BarChartGroupData(x: 6, barRods: [
                          BarChartRodData(toY: 8, color: Colors.orange)
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
