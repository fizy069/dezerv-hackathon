import 'package:events_emitter/events_emitter.dart';
import 'package:expense_advisor/dao/category_dao.dart';
import 'package:expense_advisor/events.dart';
import 'package:expense_advisor/model/category.model.dart';
import 'package:expense_advisor/widgets/dialog/category_form.dialog.dart';
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryDao _categoryDao = CategoryDao();
  EventListener? _categoryEventListener;
  List<Category> _categories = [];
  bool _isLoading = true;

  void loadData() async {
    setState(() => _isLoading = true);
    List<Category> categories = await _categoryDao.find();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();

    _categoryEventListener = globalEvent.on("category_update", (data) {
      debugPrint("categories are changed");
      loadData();
    });
  }

  @override
  void dispose() {
    _categoryEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
            tooltip: 'Sort categories',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _categories.isEmpty
              ? _buildEmptyState()
              : _buildCategoriesList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (builder) => const CategoryForm(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No categories yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a category to start tracking your expenses',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (builder) => const CategoryForm(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Category'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _categories.length,
      itemBuilder: (builder, index) {
        Category category = _categories[index];

        double? expenseProgress;
        bool isOverBudget = false;

        if ((category.budget ?? 0) > 0) {
          expenseProgress = (category.expense ?? 0) / (category.budget ?? 1);
          isOverBudget = expenseProgress > 1.0;
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              showDialog(
                context: context,
                builder: (builder) => CategoryForm(category: category),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: category.color.withOpacity(0.2),
                    child: Icon(category.icon, color: category.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                category.name,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),

                            if (expenseProgress != null)
                              Text(
                                '${(expenseProgress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isOverBudget
                                          ? Colors.red
                                          : Colors.green[700],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (expenseProgress != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₹${category.expense?.toStringAsFixed(0) ?? 0}',
                                style: TextStyle(
                                  color:
                                      isOverBudget
                                          ? Colors.red
                                          : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '₹${category.budget?.toStringAsFixed(0) ?? 0}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value:
                                  expenseProgress > 1.0 ? 1.0 : expenseProgress,
                              minHeight: 8,
                              color: isOverBudget ? Colors.red : null,
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                        ] else
                          Text(
                            "No budget set",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.apply(color: Colors.grey[600]),
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
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 4);
      },
    );
  }
}
