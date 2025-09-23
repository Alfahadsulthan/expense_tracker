import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/expense_category.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import 'models/expense.dart';
import 'screens/month.dart';

const kBoxMonths = 'months';
const kBoxMonthExpenseCategoryList = 'month_expense_category_list';
const kBoxCategoryList = 'category';
const kBoxExpenses = 'expenses';
const kBoxUnwanted = 'unwanted';

Future<void> _initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(ExpenseCategoryAdapter());
  Hive.registerAdapter(CategoryAdapter());
  await Hive.openBox<String>(kBoxMonths);
  await Hive.openBox<Expense>(kBoxExpenses);
  await Hive.openBox<ExpenseCategory>(kBoxMonthExpenseCategoryList);
  await Hive.openBox<String>(kBoxUnwanted);
  await Hive.openBox<CategorySchema>(kBoxCategoryList);
}

String monthKeyFromDate(DateTime dt) => DateFormat('yyyy-MM').format(dt);
String monthLabelFromKey(String key) {
  final parts = key.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final dt = DateTime(year, month);
  return DateFormat('MMMM yyyy').format(dt);
}

Future<void> ensureCurrentMonthExists() async {
  final months = Hive.box<String>(kBoxMonths);
  final key = monthKeyFromDate(DateTime.now());
  // final key = monthKeyFromDate(DateTime.now().add(Duration(days: 30)));
  if (!months.values.contains(key)) {
    await months.add(key);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initHive();
  await ensureCurrentMonthExists();
  runApp(const ExpenseGuardApp());
}

class ExpenseGuardApp extends StatelessWidget {
  const ExpenseGuardApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Guard',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const MonthScreen(),
    );
  }
}
