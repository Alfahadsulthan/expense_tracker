import 'package:expense_tracker/screens/month_expenses.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePieChartScreen extends StatelessWidget {
  final List<CategoryTotal> categoryTotals;

  const ExpensePieChartScreen({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    // Remove "Total" item (last one)
    final filteredTotals = categoryTotals
        .where((ct) => ct.categoryName != "Total" && ct.total > 0)
        .toList();

    final double grandTotal =
        filteredTotals.fold(0, (sum, ct) => sum + ct.total);

    return Scaffold(
      appBar: AppBar(title: const Text("Expense Chart")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Expenses by Category",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 🔹 Pie Chart with percentage
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: filteredTotals.map((ct) {
                    return PieChartSectionData(
                      color: Color(ct.colorHex),
                      value: ct.total,
                      radius: 90,
                      title: ct.categoryName,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Legend with amount + percentage
            Expanded(
              child: ListView.builder(
                itemCount: filteredTotals.length,
                itemBuilder: (context, index) {
                  final ct = filteredTotals[index];
                  final percent = (ct.total / grandTotal) * 100;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(ct.colorHex),
                    ),
                    title: Text(ct.categoryName),
                    subtitle: Text("${percent.toStringAsFixed(1)}%"),
                    trailing: Text("₹${ct.total.toStringAsFixed(2)}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
