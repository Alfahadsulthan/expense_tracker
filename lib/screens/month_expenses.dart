import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/screens/expense_bar_chart.dart';
import 'package:expense_tracker/screens/expense_pie_chart.dart';
import 'package:expense_tracker/widgets/fade_fab_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../main.dart';
import '../widgets/add_expense_sheet.dart';
import 'categories.dart';

enum SortType {
  dateDesc,
  priceHighToLow,
  priceLowToHigh,
  nameAToZ,
  nameZToA,
}

class MonthExpensesScreen extends StatefulWidget {
  final String catrgoryName;
  final String monthKey;
  const MonthExpensesScreen(
      {super.key, required this.catrgoryName, required this.monthKey});

  @override
  State<MonthExpensesScreen> createState() => _MonthExpensesScreenState();
}

class _MonthExpensesScreenState extends State<MonthExpensesScreen> {
  SortType _selectedSort = SortType.dateDesc;
  String? _selectedCategory; // filter by category
  DateTime? _startDate; // filter start date
  DateTime? _endDate; // filter end date
  List<CategoryTotal> categoryTotalList = [];
  List<Expense> filteredAndSorted = [];

  List<Expense> _applyFiltersAndSorting(List<Expense> expenses) {
    var filtered = [...expenses];

    // 🔹 Category filter
    if (_selectedCategory != null) {
      filtered =
          filtered.where((e) => e.categoryName == _selectedCategory).toList();
    }

    // 🔹 Date range filter
    if (_startDate != null) {
      filtered = filtered
          .where((e) =>
              e.date.isAfter(_startDate!) ||
              e.date.isAtSameMomentAs(_startDate!))
          .toList();
    }
    if (_endDate != null) {
      filtered = filtered
          .where((e) =>
              e.date.isBefore(_endDate!) || e.date.isAtSameMomentAs(_endDate!))
          .toList();
    }

    // 🔹 Sorting
    switch (_selectedSort) {
      case SortType.dateDesc:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortType.priceHighToLow:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortType.priceLowToHigh:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortType.nameAToZ:
        filtered.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortType.nameZToA:
        filtered.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }

    return filtered;
  }

  // 🔹 Helper widget for each menu button
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 28, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          Text(label,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _pickCategory() {
    final categoryListBox = Hive.box<CategorySchema>(kBoxCategoryList);
    final categories = categoryListBox.values.toList();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: [
            ListTile(
              title: const Text("All Categories"),
              onTap: () {
                setState(() => _selectedCategory = null);
                Navigator.pop(context);
              },
            ),
            ...categories.map((c) {
              return ListTile(
                title: Text(c.name),
                onTap: () {
                  setState(() => _selectedCategory = c.name);
                  Navigator.pop(context);
                },
              );
            })
          ],
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.catrgoryName),
        actions: [
          /// More Options
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      // alignment: WrapAlignment.center,
                      spacing: 24,
                      // runSpacing: 16,
                      children: [
                        /// Sort Option
                        _buildMenuButton(
                          icon: Icons.sort,
                          label: "Sort",
                          onTap: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        "Date (Latest First)",
                                        style:
                                            _selectedSort == SortType.dateDesc
                                                ? const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.lightBlue)
                                                : TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[500],
                                                  ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() =>
                                            _selectedSort = SortType.dateDesc);
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Price: High → Low",
                                        style: _selectedSort ==
                                                SortType.priceHighToLow
                                            ? const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.lightBlue)
                                            : TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[500],
                                              ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() => _selectedSort =
                                            SortType.priceHighToLow);
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Price: Low → High",
                                        style: _selectedSort ==
                                                SortType.priceLowToHigh
                                            ? const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.lightBlue)
                                            : TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[500],
                                              ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() => _selectedSort =
                                            SortType.priceLowToHigh);
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Name: A → Z",
                                        style:
                                            _selectedSort == SortType.nameAToZ
                                                ? const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.lightBlue)
                                                : TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[500],
                                                  ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() =>
                                            _selectedSort = SortType.nameAToZ);
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        "Name: Z → A",
                                        style:
                                            _selectedSort == SortType.nameZToA
                                                ? const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.lightBlue)
                                                : TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[500],
                                                  ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        setState(() =>
                                            _selectedSort = SortType.nameZToA);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        /// Filter Option
                        _buildMenuButton(
                          icon: Icons.filter_alt,
                          label: "Filter",
                          onTap: () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              builder: (_) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.calendar_today),
                                      title: Text(_startDate == null ||
                                              _endDate == null
                                          ? "Pick Date Range"
                                          : "${DateFormat('dd MMM').format(_startDate!)} → ${DateFormat('dd MMM').format(_endDate!)}"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickDateRange();
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.category),
                                      title: Text(
                                          _selectedCategory ?? "Pick Category"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickCategory();
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.refresh),
                                      title: const Text("Reset Filters"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _resetFilters();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        /// Pie Chart Option
                        _buildMenuButton(
                          icon: Icons.pie_chart,
                          label: "Pie Chart",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ExpensePieChartScreen(
                                        categoryTotals: categoryTotalList,
                                      )),
                            );
                          },
                        ),

                        /// Bar Chart Option
                        _buildMenuButton(
                          icon: Icons.bar_chart,
                          label: "Bar Chart",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExpenseStackedBarChartScreen(
                                  expenses: filteredAndSorted,
                                  categories:
                                      Hive.box<CategorySchema>(kBoxCategoryList)
                                          .values
                                          .toList(),
                                ),
                              ),
                            );
                          },
                        ),

                        /// Category List Option
                        _buildMenuButton(
                          icon: Icons.category,
                          label: "Category List",
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CategoriesScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),

      // 🔹 Expenses list + totals
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Expense>(kBoxExpenses).listenable(),
        builder: (context, Box<Expense> box, _) {
          final all = box.values
              .where((e) => e.expenseCategoryName == widget.catrgoryName &&
        e.monthKey == widget.monthKey)
              .toList();

          filteredAndSorted = _applyFiltersAndSorting(all);

          // 🔹 Build category totals
          categoryTotalList = Hive.box<CategorySchema>(kBoxCategoryList)
              .values
              .map((e) => CategoryTotal(
                    categoryName: e.name,
                    total: 0,
                    colorHex: e.hexColor,
                  ))
              .toList();

          for (final e in filteredAndSorted) {
            for (CategoryTotal ct in categoryTotalList) {
              if (ct.categoryName == e.categoryName) {
                ct.total += e.amount;
              }
            }
          }

          double grand = 0;
          for (CategoryTotal ct in categoryTotalList) {
            grand += ct.total;
          }
          categoryTotalList.add(CategoryTotal(
              categoryName: 'Total', total: grand, colorHex: 0xFF000000));

          if (filteredAndSorted.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No expenses match your filter",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  FloatingActionButton.extended(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => AddExpenseSheet(
                          expenseCategory: widget.catrgoryName,
                          monthKey: widget.monthKey,
                        ),
                      );
                    },
                    label: const Text('Add Expense'),
                    icon: const Icon(Icons.add),
                    backgroundColor: Colors.teal,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 100),
                      itemCount: filteredAndSorted.length,
                      itemBuilder: (context, index) {
                        final ex = filteredAndSorted[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            leading: CircleAvatar(
                              backgroundColor: Color(ex.categoryColor),
                              child: Text(
                                ex.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              ex.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800]),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Color(ex.categoryColor)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        ex.categoryName,
                                        style: TextStyle(
                                            color: Color(ex.categoryColor),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('dd MMM, hh:mm a')
                                          .format(ex.date),
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Text(
                              '₹${ex.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(ex.categoryColor)),
                            ),
                            onLongPress: () async => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Conformation!"),
                                content:
                                     Text("Are you sure to make changes on this? ${ex.name}"),
                                actions: [
                                  IconButton(
                                    onPressed: () async {
                                      Navigator.of(ctx).pop();
                                    },
                                    icon:const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                           Icon(
                                      CupertinoIcons.xmark
                                    ),
                                     SizedBox(width: 2),
                                         Text(
                                          "Cancle",
                                        ),
                                      ],
                                    ),
                                  ),
                                   
                                  IconButton(
                                    onPressed: () async {
                                      Navigator.of(ctx).pop();
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (_) => AddExpenseSheet(
                                          expenseCategory: ex.expenseCategoryName,
                                          monthKey: widget.monthKey,
                                          expenseToEdit: ex,
                                        ),
                                      );
                                    },
                                    icon:const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                         Icon(
                                      Icons.edit
                                    ),
                                     SizedBox(width: 2),
                                         Text(
                                          "Edit",
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      Navigator.of(ctx).pop();
                                      await ex.delete();
                                    },
                                    icon:const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                          Icon(
                                      CupertinoIcons.delete,
                                      color: Colors.red,
                                    ),
                                     SizedBox(width: 2),
                                         Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FadingFab(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => AddExpenseSheet(
                                expenseCategory: widget.catrgoryName,
                                monthKey: widget.monthKey,
                              ),
                            );
                          },
                          label: const Text('Add'),
                          icon: const Icon(Icons.add),
                        )),
                  ],
                ),
              ),

              // 🔹 Sticky totals + Add button
              Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(0, -2),
                      blurRadius: 6,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _TotalsBar(categoryTotals: categoryTotalList),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CategoryTotal {
  final String categoryName;
  final int colorHex;
  double total;

  CategoryTotal(
      {required this.categoryName,
      required this.total,
      required this.colorHex});
}

class _TotalsBar extends StatelessWidget {
  final List<CategoryTotal> categoryTotals;
  const _TotalsBar({
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: 10 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (CategoryTotal ct in categoryTotals) ...[
            if (ct.total > 0) ...[
              _row(
                  label: ct.categoryName,
                  textColor: Color(ct.colorHex),
                  total: ct.total),
              const SizedBox(height: 10),
            ]
          ]
        ],
      ),
    );
  }

  Widget _row(
      {required String label,
      required double total,
      required Color textColor,
      bool? bold}) {
    final style = TextStyle(
      color: textColor,
      fontWeight: bold != null ? FontWeight.w700 : FontWeight.w600,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text('₹${total.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
