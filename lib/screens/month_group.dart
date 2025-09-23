import 'package:expense_tracker/models/expense_category.dart';
import 'package:expense_tracker/screens/categories.dart';
import 'package:expense_tracker/widgets/add_category_sheet.dart';
import 'package:expense_tracker/widgets/add_month_group_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';
import 'month_expenses.dart';

class MonthGroupScreen extends StatelessWidget {
  const MonthGroupScreen({super.key, required this.monthKey});
  final String monthKey;

  @override
  Widget build(BuildContext context) {
    final monthExpenseCategoryListBox =
        Hive.box<ExpenseCategory>(kBoxMonthExpenseCategoryList);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Categories by Month'),
        actions: [
          IconButton(
            tooltip: 'Add Category',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const AddCategorySheet(),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoriesScreen()),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: monthExpenseCategoryListBox.listenable(),
        builder: (context, Box<ExpenseCategory> box, _) {
          
           // filter by monthKey
  final months = box.values
      .where((e) => e.monthKey == monthKey)
      .toList();

  // sort newest first
  months.sort((a, b) => b.date.compareTo(a.date));

          if (months.isEmpty) {
            return const Center(child: Text('No Expense List yet'));
          }

          return ListView.separated(
            itemCount: months.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final key = months[index];
              return ListTile(
                title: Text(key.name),
                trailing: const Icon(Icons.chevron_right),
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
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) =>  AddMonthGroupSheet(initialMonthKey: monthKey,),
          );
        },
        label: const Text('Add Expense Category'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
