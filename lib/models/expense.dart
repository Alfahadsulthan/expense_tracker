import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  /// Month key format: yyyy-MM (e.g., 2025-08)
  @HiveField(3)
  String monthKey;

  @HiveField(4, defaultValue: '')
  String expenseCategoryName;

    @HiveField(5, defaultValue: 0)
  int categoryColor;

  @HiveField(6, defaultValue: '')
  String categoryName;

  Expense({
    required this.name,
    required this.amount,
    required this.date,
    required this.monthKey,
    required this.expenseCategoryName,
    required this.categoryName,
    required this.categoryColor,
  });
}
