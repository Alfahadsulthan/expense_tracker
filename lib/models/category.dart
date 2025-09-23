import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 3)
class CategorySchema extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int hexColor;

  @HiveField(2)
  DateTime date;

  CategorySchema({
    required this.name,
    required this.hexColor,
    required this.date,
  });
}
