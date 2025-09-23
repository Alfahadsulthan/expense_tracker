// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 1;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      name: fields[0] as String,
      amount: fields[1] as double,
      date: fields[2] as DateTime,
      monthKey: fields[3] as String,
      expenseCategoryName: fields[4] == null ? '' : fields[4] as String,
      categoryName: fields[6] == null ? '' : fields[6] as String,
      categoryColor: fields[5] == null ? 0 : fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.monthKey)
      ..writeByte(4)
      ..write(obj.expenseCategoryName)
      ..writeByte(5)
      ..write(obj.categoryColor)
      ..writeByte(6)
      ..write(obj.categoryName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
