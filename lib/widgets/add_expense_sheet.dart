import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/widgets/add_category_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/expense.dart';

class AddExpenseSheet extends StatefulWidget {
  final String expenseCategory;
  final String monthKey;
  const AddExpenseSheet(
      {super.key, required this.expenseCategory, required this.monthKey});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  CategorySchema? selectedCategory;

  List<CategorySchema> categoryList =
      Hive.box<CategorySchema>(kBoxCategoryList).values.toList();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  // /// Read latest SMS containing "debited" and fill fields
  // Future<void> _fetchFromSMS() async {
  //   var permission = await Permission.sms.status;
  //   if (!permission.isGranted) {
  //     permission = await Permission.sms.request();
  //     if (!permission.isGranted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("SMS permission is required.")),
  //       );
  //       return;
  //     }
  //   }

  //   final SmsQuery query = SmsQuery();
  //   List<SmsMessage> messages = await query.querySms(
  //     kinds: [SmsQueryKind.inbox],
  //     count: 30,
  //   );

  //   for (var msg in messages) {
  //     if (msg.body != null && msg.body!.toLowerCase().contains("debited")) {
  //       final extractedAmount = _extractAmount(msg.body!);
  //       final extractedDescription = _extractDescription(msg.body!);

  //       if (extractedAmount != null) {
  //         setState(() {
  //           _amountCtrl.text = extractedAmount.toString();
  //           _nameCtrl.text = extractedDescription ?? "Bank Transaction";
  //         });
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Auto-filled from SMS.")),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("No valid amount found in SMS.")),
  //         );
  //       }
  //       return;
  //     }
  //   }

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text("No matching bank SMS found.")),
  //   );
  // }

  // double? _extractAmount(String text) {
  //   final regex = RegExp(r'(\d{1,3}(,\d{3})*|\d+)(\.\d{1,2})?');
  //   final match = regex.firstMatch(text.replaceAll(",", ""));
  //   if (match != null) {
  //     return double.tryParse(match.group(0)!);
  //   }
  //   return null;
  // }

  // String? _extractDescription(String text) {
  //   final parts = text.split("debited");
  //   if (parts.length > 1) {
  //     return parts[1].trim().split(" ").take(5).join(" ");
  //   }
  //   return null;
  // }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCategory == null) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Oops!"),
            content: const Text("Please select a category."),
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

    final monthsBox = Hive.box<String>(kBoxMonths);
    final expensesBox = Hive.box<Expense>(kBoxExpenses);

    final date = _date;
    final monthKey = monthKeyFromDate(date);

    // Ensure month exists
    if (!monthsBox.values.contains(monthKey)) {
      await monthsBox.add(monthKey);
    }

    final expense = Expense(
      categoryColor: selectedCategory!.hexColor,
      categoryName: selectedCategory!.name,
      name: _nameCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      date: date,
      expenseCategoryName: widget.expenseCategory,
      monthKey: monthKey,
    );
    await expensesBox.add(expense);

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
                  'Add Expense',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Petrol, Snacks, EMI',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter amount';
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Enter valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder(
                    valueListenable:
                        Hive.box<CategorySchema>(kBoxCategoryList).listenable(),
                    builder: (context, Box<CategorySchema> box, _) {
                      List<CategorySchema> categoryList = box.values.toList();
                      return DropdownButtonFormField<CategorySchema>(
                        decoration: const InputDecoration(
                          labelText: 'Select Category',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedCategory, // will be null at first
                        hint: const Text(''), // empty default
                        items: categoryList.map((screen) {
                          return DropdownMenuItem(
                            value: screen,
                            child: Text(screen.name,
                                style:
                                    TextStyle(color: Color(screen.hexColor))),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      );
                    }),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const AddCategorySheet(),
                    );
                  },
                  label: const Text('Add Category'),
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(height: 12),
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
