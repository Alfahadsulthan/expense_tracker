// import 'package:expense_tracker/models/expense.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';

// class ExpenseBarChartScreen extends StatelessWidget {
//   final List<Expense> expenses;

//   const ExpenseBarChartScreen({super.key, required this.expenses});

//   @override
//   Widget build(BuildContext context) {
//     // 🔹 Group expenses by day
//     final Map<String, double> dailyTotals = {};
//     final dateFormat = DateFormat('dd MMM');

//     for (final e in expenses) {
//       final dayKey = dateFormat.format(e.date);
//       dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + e.amount;
//     }

//     // Sort by date order
//     final sortedKeys = dailyTotals.keys.toList()
//       ..sort((a, b) =>
//           dateFormat.parse(a).compareTo(dateFormat.parse(b)));

//     final maxY =
//         dailyTotals.values.isNotEmpty ? dailyTotals.values.reduce((a, b) => a > b ? a : b) : 0;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Daily Expenses")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: BarChart(
//           BarChartData(
//             alignment: BarChartAlignment.spaceAround,
//             maxY: maxY + (maxY * 0.2), // add headroom
//             titlesData: FlTitlesData(
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 40,
//                   getTitlesWidget: (value, meta) =>
//                       Text("₹${value.toInt()}",
//                           style: const TextStyle(fontSize: 10)),
//                 ),
//               ),
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   getTitlesWidget: (value, meta) {
//                     if (value < 0 || value >= sortedKeys.length) {
//                       return const SizedBox.shrink();
//                     }
//                     return Text(sortedKeys[value.toInt()],
//                         style: const TextStyle(fontSize: 10));
//                   },
//                 ),
//               ),
//               rightTitles:
//                   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               topTitles:
//                   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             ),
//             borderData: FlBorderData(show: false),
//             barGroups: List.generate(sortedKeys.length, (i) {
//               final day = sortedKeys[i];
//               final amount = dailyTotals[day] ?? 0;
//               return BarChartGroupData(
//                 x: i,
//                 barRods: [
//                   BarChartRodData(
//                     toY: amount,
//                     color: Colors.blue,

//                     width: 18,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ],
//               );
//             }),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ExpenseStackedBarChartScreen extends StatelessWidget {
  final List<Expense> expenses;
  final List<CategorySchema> categories;

  const ExpenseStackedBarChartScreen({
    super.key,
    required this.expenses,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM');

    // 🔹 Group expenses by day -> then by category
    final Map<String, Map<String, double>> dailyCategoryTotals = {};
    for (final e in expenses) {
      final dayKey = dateFormat.format(e.date);
      dailyCategoryTotals.putIfAbsent(dayKey, () => {});
      dailyCategoryTotals[dayKey]![e.categoryName] =
          (dailyCategoryTotals[dayKey]![e.categoryName] ?? 0) + e.amount;
    }

    // 🔹 Sort days in order
    final sortedDays = dailyCategoryTotals.keys.toList()
      ..sort((a, b) => dateFormat.parse(a).compareTo(dateFormat.parse(b)));

    // 🔹 Max Y (highest daily total)
    double maxY = 0;
    for (final totals in dailyCategoryTotals.values) {
      final daySum = totals.values.fold(0.0, (a, b) => a + b);
      if (daySum > maxY) maxY = daySum;
    }

    return Scaffold(
      appBar: AppBar( backgroundColor: Theme.of(context).colorScheme.inversePrimary,title: const Text("Daily Expenses by Category")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Bar Chart
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: sortedDays.length * 50, // 🔹 50px per day
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.white60,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '₹${rod.toY.toStringAsFixed(2)}',
                              const TextStyle(
                                color: Colors
                                    .black, // text color on white background
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY + (maxY * 0.2),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              "₹${value.toInt()}",
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= sortedDays.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Transform.rotate(
                                  angle: -0.4, // about -35 degrees (in radians)
                                  child: Text(
                                    sortedDays[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(sortedDays.length, (i) {
                        final day = sortedDays[i];
                        final totals = dailyCategoryTotals[day]!;
                        double runningTotal = 0;

                        // 🔹 Stacked segments for each category
                        final rods = totals.entries.map((entry) {
                          final category = categories.firstWhere(
                            (c) => c.name == entry.key,
                            orElse: () => CategorySchema(
                                date: DateTime.now(),
                                name: entry.key,
                                hexColor: 0xFF9E9E9E),
                          );
                          final startY = runningTotal;
                          runningTotal += entry.value;
                          return BarChartRodStackItem(
                            startY,
                            runningTotal,
                            Color(category.hexColor),
                          );
                        }).toList();

                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: runningTotal,
                              rodStackItems: rods,
                              width: 30,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Legend
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: categories.map((cat) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      color: Color(cat.hexColor),
                    ),
                    const SizedBox(width: 5),
                    Text(cat.name),
                  ],
                );
              }).toList(),
            ),
            const Divider(),
            Expanded(
              child: DailyCategoryBreakdown(
                dailyCategoryTotals: dailyCategoryTotals,
                categorylist: categories,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyCategoryBreakdown extends StatelessWidget {
  final Map<String, Map<String, double>> dailyCategoryTotals;
  final List<CategorySchema> categorylist;
  const DailyCategoryBreakdown(
      {super.key,
      required this.dailyCategoryTotals,
      required this.categorylist});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: dailyCategoryTotals.entries.map((dayEntry) {
        final day = dayEntry.key;
        final categories = dayEntry.value;

        final dayTotal = categories.values.fold(0.0, (a, b) => a + b);

        return ExpansionTile(
          title: Text(
            "$day  •  ₹${dayTotal.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: categories.entries.map((cat) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getCategoryColor(cat.key),
                radius: 8,
              ),
              title: Text(cat.key),
              trailing: Text(
                "₹${cat.value.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  /// Helper to fetch category color (you can map with your CategorySchema list)
  Color _getCategoryColor(String categoryName) {
    final category = categorylist.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => CategorySchema(
        date: DateTime.now(),
        name: categoryName, // first category name
        hexColor: 0xFF9E9E9E, // default grey
      ),
    );
    ;
    return Color(category.hexColor);
  }
}
