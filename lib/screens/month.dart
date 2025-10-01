import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/expense_category.dart';
import 'package:expense_tracker/screens/month_expenses.dart';
import 'package:expense_tracker/screens/month_group.dart';
import 'package:expense_tracker/screens/categories.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';

class MonthScreen extends StatelessWidget {
  const MonthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final monthsBox = Hive.box<String>(kBoxMonths);
    final expenseList = Hive.box<Expense>(kBoxExpenses);
    final monthExpenseCategoryListBox =
        Hive.box<ExpenseCategory>(kBoxMonthExpenseCategoryList);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Months Overview'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Add current month',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () async {
              await ensureCurrentMonthExists();
            },
          ),
          IconButton(
            tooltip: 'Category',
            icon: const Icon(Icons.category),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: monthExpenseCategoryListBox.listenable(),
        builder: (context, monthGroupExpenseBox, child) {
          return ValueListenableBuilder(
            valueListenable: expenseList.listenable(),
            builder: (context, expenseListValue, child) {
              return ValueListenableBuilder(
                valueListenable: monthsBox.listenable(),
                builder: (context, Box<String> box, _) {
                  final months = box.values.toList();
                  months.sort((a, b) => b.compareTo(a)); // newest first

                  if (months.isEmpty) {
                    return const Center(child: Text('No months yet'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: months.length,
                    itemBuilder: (context, index) {
                      final monthKey = months[index];
                      final monthCategories = monthGroupExpenseBox.values
                          .where((e) => e.monthKey == monthKey)
                          .toList();

                      // sort newest first
                      monthCategories.sort((a, b) => b.date.compareTo(a.date));

                      final allExpenses =
                          expenseListValue.values.map((e) => e).toList();

                      double categoryTotal = 0;
                      for (ExpenseCategory ec in monthCategories) {
                        for (Expense ct in allExpenses) {
                          if (ct.monthKey == ec.monthKey &&
                              ct.expenseCategoryName == ec.name) {
                            categoryTotal += ct.amount;
                          }
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Month heading card
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              color: Colors.teal[50],
                              elevation: 1,
                              child: ListTile(
                                title: Text(
                                  monthLabelFromKey(monthKey),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Total: ₹${categoryTotal.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.teal[800],
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MonthGroupScreen(monthKey: monthKey),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // 🔹 Sub-categories / related data below each month
                          ...monthCategories.map(
                            (cat) => Card(
                              margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                title: Text(
                                  cat.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  "Category expenses",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MonthExpensesScreen(
                                        catrgoryName: cat.name,
                                        monthKey: monthKey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}


// class MonthScreen extends StatelessWidget {
//   const MonthScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final monthsBox = Hive.box<String>(kBoxMonths);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Months'),
//         actions: [
//           IconButton(
//             tooltip: 'Add current month',
//             icon: const Icon(Icons.add_box_outlined),
//             onPressed: () async {
//               await ensureCurrentMonthExists();
//             },
//           ),
//           IconButton(
//             tooltip: 'Settings',
//             icon: const Icon(Icons.settings),
//             onPressed: () =>Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const CategoriesScreen()),
//               ),
//           ),
//         ],
//       ),
//       body: ValueListenableBuilder(
//         valueListenable: monthsBox.listenable(),
//         builder: (context, Box<String> box, _) {
//           final months = box.values.toList();
//           months.sort((a, b) => b.compareTo(a)); // newest first

//           if (months.isEmpty) {
//             return const Center(child: Text('No months yet'));
//           }

//           return ListView.separated(
//             itemCount: months.length,
//             separatorBuilder: (_, __) => const Divider(height: 0),
//             itemBuilder: (context, index) {
//               final key = months[index];
//               return ListTile(
//                 title: Text(monthLabelFromKey(key)),
//                 trailing: const Icon(Icons.chevron_right),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => MonthGroupScreen(monthKey:key ,),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: () {
//       //     showModalBottomSheet(
//       //       context: context,
//       //       isScrollControlled: true,
//       //       builder: (_) => const AddExpenseSheet(),
//       //     );
//       //   },
//       //   label: const Text('Add Expense'),
//       //   icon: const Icon(Icons.add),
//       // ),
//     );
//   }
// }
