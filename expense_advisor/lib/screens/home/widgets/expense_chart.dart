import 'package:flutter/material.dart';
import 'package:expense_advisor/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ExpenseChart extends StatelessWidget {
  final DateTimeRange dateRange;

  const ExpenseChart({Key? key, required this.dateRange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spending Trends",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            "Last ${dateRange.duration.inDays} days",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1000,
                      getTitlesWidget: leftTitleWidgets,
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 4000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1500),
                      FlSpot(1, 2200),
                      FlSpot(2, 1800),
                      FlSpot(3, 3200),
                      FlSpot(4, 2700),
                      FlSpot(5, 1900),
                      FlSpot(6, 2400),
                    ],
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        ThemeColors.primary.withOpacity(0.8),
                        ThemeColors.primary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          ThemeColors.primary.withOpacity(0.3),
                          ThemeColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: Colors.grey,
    );

    // Simple day labels
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final int index = value.toInt();

    if (index >= 0 && index < labels.length) {
      return SideTitleWidget(
        // axisSide: meta.axisSide,
        meta: meta,
        child: Text(labels[index], style: style),
      );
    }
    return const SizedBox.shrink();
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 10,
      color: Colors.grey.shade500,
    );

    String text;
    if (value == 0) {
      text = '0';
    } else if (value == 1000) {
      text = '1K';
    } else if (value == 2000) {
      text = '2K';
    } else if (value == 3000) {
      text = '3K';
    } else if (value == 4000) {
      text = '4K';
    } else {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      // axisSide: meta.axisSide,
      meta: meta,
      child: Text(text, style: style),
    );
  }
}
