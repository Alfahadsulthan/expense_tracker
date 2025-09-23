import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class AddCategorySheet extends StatefulWidget {
  const AddCategorySheet({
    super.key,
  });

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.lime,
    Colors.indigo,
    Colors.brown,
    Colors.grey,
    Colors.amber,
    Colors.deepPurple,
    Colors.lightGreen,
    Colors.deepOrange,
    Colors.blueGrey,
    Colors.black,
    Colors.greenAccent,
  ];

  Color? selectedColor;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedColor == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Oops!"),
          content: const Text("Please select a color."),
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

    final categoryBox = Hive.box<CategorySchema>(kBoxCategoryList);
    final expenseBox = Hive.box<Expense>(kBoxExpenses);

// normalize the input name
    final newName = _nameCtrl.text.trim().toLowerCase();

// 1. Check if category already exists
    for (CategorySchema c in categoryBox.values) {
      if (c.name.toLowerCase() == newName) {
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
        return; // stop execution
      }
    }

// 2. Update related expenses with new color
    for (Expense exp in expenseBox.values) {
      if (exp.categoryName.toLowerCase() == newName) {
        exp.categoryColor = selectedColor!.value;

        // If Expense extends HiveObject, this works:
        await exp.save();

      }
    }

    final date = _date;

    final category = CategorySchema(
      name: _nameCtrl.text.trim(),
      date: date,
      hexColor: selectedColor!.value,
    );
    await categoryBox.add(category);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categoryBox = Hive.box<CategorySchema>(kBoxCategoryList);
    for (CategorySchema c in categoryBox.values) {
      if (colors.any(
        (element) => element.value == c.hexColor,
      )) {
        colors.removeWhere((element) => element.value == c.hexColor);
      }
    }

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
                  'Add Category',
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
                InkWell(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Select a color"),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            final color = colors[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedColor = color;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black26,
                                    width: selectedColor == color ? 3 : 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text("Select Category Color"),
                      const SizedBox(width: 10),
                      Container(
                        color: selectedColor,
                        child: SizedBox(
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ],
                  ),
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
