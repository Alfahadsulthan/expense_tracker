import 'package:expense_tracker/models/expense.dart';
import 'package:hive/hive.dart';

part 'expense_category.g.dart';

@HiveType(typeId: 2)
class ExpenseCategory extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Expense> amount;

  @HiveField(2)
  DateTime date;

  /// Month key format: yyyy-MM (e.g., 2025-08)
  @HiveField(3)
  String monthKey;

  ExpenseCategory({
    required this.name,
    required this.amount,
    required this.date,
    required this.monthKey,
  });
}
