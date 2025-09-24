import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/expense_category.dart';
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

                      return ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          // 🔹 Month List with Cards
                          ...months.map((key) {
                            final months = monthGroupExpenseBox.values
                                .where((e) => e.monthKey == key)
                                .toList();

                            // sort newest first
                            months.sort((a, b) => b.date.compareTo(a.date));
                            List<Expense> expenseList =
                                expenseListValue.values.map((e) => e).toList();
                            double categoryTotal = 0;
                            for (ExpenseCategory ec in months) {
                              for (Expense ct in expenseList) {
                                if (ct.monthKey == ec.monthKey &&
                                    ct.expenseCategoryName == ec.name) {
                                  categoryTotal += ct.amount;
                                }
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
                                  monthLabelFromKey(key),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                    "Total: ₹ ${categoryTotal.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[700],
                                    )),
                                trailing: const Icon(Icons.arrow_forward_ios,
                                    size: 18),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          MonthGroupScreen(monthKey: key),
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
                });
          }),
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
