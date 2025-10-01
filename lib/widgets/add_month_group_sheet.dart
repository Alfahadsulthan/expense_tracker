import 'package:expense_tracker/models/expense_category.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class AddMonthGroupSheet extends StatefulWidget {
  final String? initialMonthKey;
  const AddMonthGroupSheet({
    super.key,
    this.initialMonthKey,
  });

  @override
  State<AddMonthGroupSheet> createState() =>
      _AddMonthGroupSheetState();
}

class _AddMonthGroupSheetState extends State<AddMonthGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final monthsBox = Hive.box<String>(kBoxMonths);
    final expensesCategoryListBox =
        Hive.box<ExpenseCategory>(kBoxMonthExpenseCategoryList);

    for (ExpenseCategory ec in expensesCategoryListBox.values) {
      if (ec.name.toLowerCase() == _nameCtrl.text.trim().toLowerCase() && ec.monthKey==widget.initialMonthKey) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Oops!"),
            content: const Text("Category already exists."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      }
    }

    final date = _date;
    final monthKey = widget.initialMonthKey ?? monthKeyFromDate(date);

    // Ensure month exists
    if (!monthsBox.values.contains(monthKey)) {
      await monthsBox.add(monthKey);
    }

    final expenseCategory = ExpenseCategory(
      name: _nameCtrl.text.trim(),
      amount: [],
      date: date,
      monthKey: monthKey,
    );
    await expensesCategoryListBox.add(expenseCategory);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Text(
                  'Add Expense Category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. My Expense, Bike Expense, Daddy Expense',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 12),
                // TextFormField(
                //   controller: _amountCtrl,
                //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
                //   decoration: const InputDecoration(
                //     labelText: 'Amount (₹)',
                //     border: OutlineInputBorder(),
                //   ),
                //   validator: (v) {
                //     if (v == null || v.trim().isEmpty) return 'Enter amount';
                //     final parsed = double.tryParse(v.trim());
                //     if (parsed == null || parsed <= 0) return 'Enter valid amount';
                //     return null;
                //   },
                // ),
                // const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('dd MMM yyyy').format(_date)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _date = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(DateFormat('hh:mm a').format(_date)),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_date),
                          );
                          if (picked != null) {
                            final newDt = DateTime(
                              _date.year,
                              _date.month,
                              _date.day,
                              picked.hour,
                              picked.minute,
                            );
                            setState(() => _date = newDt);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Expanded(
                    //   child: OutlinedButton.icon(
                    //     icon: const Icon(Icons.sms),
                    //     label: const Text('From SMS'),
                    //     onPressed: _fetchFromSMS,
                    //   ),
                    // ),
                    // const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save'),
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
