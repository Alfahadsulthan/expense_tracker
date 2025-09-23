import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/expense_category.dart';
import 'package:expense_tracker/screens/categories.dart';
import 'package:expense_tracker/widgets/add_category_sheet.dart';
import 'package:expense_tracker/widgets/add_month_group_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';
import 'month_expenses.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthGroupScreen extends StatelessWidget {
  const MonthGroupScreen({super.key, required this.monthKey});
  final String monthKey;

  // 🔹 Helper widget for each menu button
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 28, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthExpenseCategoryListBox =
        Hive.box<ExpenseCategory>(kBoxMonthExpenseCategoryList);
    final expenseList = Hive.box<Expense>(kBoxExpenses);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Expense Categories by Month'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      // alignment: WrapAlignment.center,
                      spacing: 24,
                      // runSpacing: 16,
                      children: [
                        /// Category List Option
                        _buildMenuButton(
                          icon: Icons.category,
                          label: "Category List",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CategoriesScreen()),
                            );
                          },
                        ),

                        /// Category List Option
                        _buildMenuButton(
                          icon: Icons.add_outlined,
                          label: "Add New Category",
                          onTap: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => const AddCategorySheet(),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: expenseList.listenable(),
          builder: (context, exenseListBox, child) {
            return ValueListenableBuilder(
              valueListenable: monthExpenseCategoryListBox.listenable(),
              builder: (context, Box<ExpenseCategory> box, _) {
                // filter by monthKey
                final months =
                    box.values.where((e) => e.monthKey == monthKey).toList();

                // sort newest first
                months.sort((a, b) => b.date.compareTo(a.date));

                if (months.isEmpty) {
                  return const Center(child: Text('No Expense List yet'));
                }

                // 🔹 Calculate total expenses & per-category
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 150),
                  children: [
                    // 🔹 Overview Card
                    MonthGroupExpensePieChartWidget(
                        expenseList:
                            exenseListBox.values.map((e) => e).toList(),
                        groupExpenseCategoryList: months),

                    const SizedBox(height: 20),

                    // 🔹 Category List
                    ...months.map((key) {
                      List<Expense> expenseList =
                          Hive.box<Expense>(kBoxExpenses)
                              .values
                              .map((e) => e)
                              .toList();
                      num categoryTotal = 0;

                      for (Expense ct in expenseList) {
                        if (ct.monthKey == key.monthKey &&
                            ct.expenseCategoryName == key.name) {
                          categoryTotal += ct.amount;
                        }
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          title: Text(
                            key.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          subtitle:
                              Text("₹ ${categoryTotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[700],
                                  )),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MonthExpensesScreen(
                                  catrgoryName: key.name,
                                  monthKey: key.monthKey,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => AddMonthGroupSheet(initialMonthKey: monthKey),
          );
        },
        label: const Text('Add Expense Category'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class MonthGroupExpensePieChartWidget extends StatelessWidget {
  final List<ExpenseCategory> groupExpenseCategoryList;
  final List<Expense> expenseList;
  static List<Color> pieChartSectionColors = [
    Color(0xFF388E3C), // Dark Green
    Color(0xFF1976D2), // Dark Blue
    Color(0xFFD32F2F), // Dark Red
    Colors.deepPurple, // Red
    Colors.deepOrange, // Blue
    Colors.pink, // Orange
    Color(0xFF81C784), // Green
    Color(0xFFBA68C8), // Purple
    Color(0xFFFF8A65), // Coral
    Color(0xFFA1887F), // Brown
    Color(0xFF4DD0E1), // Cyan
    Color(0xFFDCE775), // Lime
  ];

  const MonthGroupExpensePieChartWidget(
      {super.key,
      required this.groupExpenseCategoryList,
      required this.expenseList});

  @override
  Widget build(BuildContext context) {
    final totalAmount =
        groupExpenseCategoryList.fold<double>(0, (sum, category) {
      num categoryTotal = 0;

      for (Expense ct in expenseList) {
        if (ct.monthKey == category.monthKey &&
            ct.expenseCategoryName == category.name) {
          categoryTotal += ct.amount;
        }
      }

      return sum + categoryTotal;
    });

    final Map<String, double> categoryTotals = {};
    for (var cat in groupExpenseCategoryList) {
      final categoryTotal = cat.amount.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );
      categoryTotals[cat.name] =
          (categoryTotals[cat.name] ?? 0) + categoryTotal;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("This Month’s Overview",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("₹ ${totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700])),

              const SizedBox(height: 16),

              // 🔹 Pie chart of categories

              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: groupExpenseCategoryList.map((gec) {
                      double categoryTotal = 0;

                      for (Expense ct in expenseList) {
                        if (ct.monthKey == gec.monthKey &&
                            ct.expenseCategoryName == gec.name) {
                          categoryTotal += ct.amount;
                        }
                      }
                      return PieChartSectionData(
                        color: pieChartSectionColors[
                            groupExpenseCategoryList.indexOf(gec)],
                        value: categoryTotal,
                        radius: 60,
                        title: gec.name,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                  itemCount: groupExpenseCategoryList.length,
                  itemBuilder: (context, index) {
                    final gec = groupExpenseCategoryList[index];
                    List<Expense> expenseList = Hive.box<Expense>(kBoxExpenses)
                        .values
                        .map((e) => e)
                        .toList();
                    double categoryTotal = 0;

                    for (Expense ct in expenseList) {
                      if (ct.monthKey == gec.monthKey &&
                          ct.expenseCategoryName == gec.name) {
                        categoryTotal += ct.amount;
                      }
                    }
                    final percent = (categoryTotal / totalAmount) * 100;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: pieChartSectionColors[index],
                      ),
                      title: Text(gec.name),
                      subtitle: Text("${percent.toStringAsFixed(1)}%"),
                      trailing: Text("₹${categoryTotal.toStringAsFixed(2)}"),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
