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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Months'),
        actions: [
          IconButton(
            tooltip: 'Add current month',
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () async {
              await ensureCurrentMonthExists();
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () =>Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoriesScreen()),
              ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: monthsBox.listenable(),
        builder: (context, Box<String> box, _) {
          final months = box.values.toList();
          months.sort((a, b) => b.compareTo(a)); // newest first

          if (months.isEmpty) {
            return const Center(child: Text('No months yet'));
          }

          return ListView.separated(
            itemCount: months.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final key = months[index];
              return ListTile(
                title: Text(monthLabelFromKey(key)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MonthGroupScreen(monthKey:key ,),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     showModalBottomSheet(
      //       context: context,
      //       isScrollControlled: true,
      //       builder: (_) => const AddExpenseSheet(),
      //     );
      //   },
      //   label: const Text('Add Expense'),
      //   icon: const Icon(Icons.add),
      // ),
    );
  }
}
