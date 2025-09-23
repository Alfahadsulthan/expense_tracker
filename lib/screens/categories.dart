import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/widgets/add_category_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryListBox = Hive.box<CategorySchema>(kBoxCategoryList);

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const AddCategorySheet(),
            );
          },
          label: const Text('Add'),
          icon: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar( backgroundColor: Theme.of(context).colorScheme.inversePrimary,title: const Text('Category List')),
      body: ValueListenableBuilder(
        valueListenable: categoryListBox.listenable(),
        builder: (context, Box<CategorySchema> box, _) {
          final items = box.values.toList();
          if (items.isEmpty) {
            return const Center(child: Text('No Category items yet'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final category = items[index];
              return ListTile(
                title: Text(category.name,
                    style: TextStyle(
                        color: Color(category.hexColor),
                        fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Delete Category"),
                        content: Text(
                            "You are about to delete this category(${category.name}). Are you sure?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              final key = box.keyAt(index);
                              box.delete(key);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
