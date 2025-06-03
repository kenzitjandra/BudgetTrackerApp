import 'package:flutter/material.dart';

// Data Model for Split Categories
class SplitCategory {
  String id; // Unique identifier
  String name;
  double percentage;

  SplitCategory({
    required this.id,
    required this.name,
    required this.percentage,
  });
}

class BudgetingPage extends StatefulWidget {
  const BudgetingPage({super.key});

  @override
  State<BudgetingPage> createState() => _BudgetingPageState();
}

class _BudgetingPageState extends State<BudgetingPage> {
  double budget = 0.0;
  final budgetController = TextEditingController();

  Map<String, List<SplitCategory>> _monthlySplitCategories = {};
  DateTime _selectedMonth = DateTime.now();

  String _getMonthKey(DateTime month) {
    return "${month.year}-${month.month.toString().padLeft(2, '0')}";
  }

  List<SplitCategory> _getCurrentMonthSplitCategories() {
    final key = _getMonthKey(_selectedMonth);
    if (!_monthlySplitCategories.containsKey(key)) {
      _monthlySplitCategories[key] = [
        SplitCategory(
          id: '${key}_default_needs',
          name: 'Needs',
          percentage: 50,
        ),
        SplitCategory(
          id: '${key}_default_wants',
          name: 'Wants',
          percentage: 30,
        ),
        SplitCategory(
          id: '${key}_default_savings',
          name: 'Savings',
          percentage: 20,
        ),
      ];
    }
    return _monthlySplitCategories[key]!;
  }

  String _getMonthName(int monthIndex) {
    const List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (monthIndex >= 1 && monthIndex <= 12) {
      return monthNames[monthIndex - 1];
    }
    return 'Invalid Month';
  }

  @override
  void initState() {
    super.initState();
    budgetController.text = budget.toStringAsFixed(2);
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  double get totalSplitPercentage {
    final currentCategories = _getCurrentMonthSplitCategories();
    return currentCategories.fold(0.0, (sum, item) => sum + item.percentage);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });
  }

  void _showAddSplitCategoryDialog() {
    final nameController = TextEditingController();
    final percentageController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Split Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
              ),
              TextField(
                controller: percentageController,
                decoration: const InputDecoration(
                  labelText: 'Percentage',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final percentage =
                    double.tryParse(percentageController.text) ?? 0.0;
                if (name.isNotEmpty && percentage > 0) {
                  setState(() {
                    final currentCategories = _getCurrentMonthSplitCategories();
                    final monthKey = _getMonthKey(_selectedMonth);
                    currentCategories.add(
                      SplitCategory(
                        id:
                            '${monthKey}_${DateTime.now().millisecondsSinceEpoch.toString()}',
                        name: name,
                        percentage: percentage,
                      ),
                    );
                  });
                  Navigator.pop(dialogContext);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid name and percentage > 0.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSplitCategoryDialog(SplitCategory categoryToEdit) {
    final nameController = TextEditingController(text: categoryToEdit.name);
    final percentageController = TextEditingController(
      text: categoryToEdit.percentage.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Split Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
              ),
              TextField(
                controller: percentageController,
                decoration: const InputDecoration(
                  labelText: 'Percentage',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final percentage =
                    double.tryParse(percentageController.text) ?? 0.0;
                if (name.isNotEmpty && percentage >= 0) {
                  setState(() {
                    final currentCategories = _getCurrentMonthSplitCategories();
                    final index = currentCategories.indexWhere(
                      (cat) => cat.id == categoryToEdit.id,
                    );
                    if (index != -1) {
                      currentCategories[index].name = name;
                      currentCategories[index].percentage = percentage;
                    }
                  });
                  Navigator.pop(dialogContext);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid name and percentage.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSplitCategory(SplitCategory categoryToDelete) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category?'),
          content: Text(
            'Are you sure you want to delete "${categoryToDelete.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  final currentCategories = _getCurrentMonthSplitCategories();
                  currentCategories.removeWhere(
                    (cat) => cat.id == categoryToDelete.id,
                  );
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSplittingRow(SplitCategory category, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 20, color: Colors.grey[700]),
            onPressed: () {
              _showEditSplitCategoryDialog(category);
            },
            padding: const EdgeInsets.all(4.0),
            constraints: const BoxConstraints(),
            tooltip: 'Edit ${category.name}',
            splashRadius: 20,
          ),
          const SizedBox(width: 0),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20, color: Colors.red[700]),
            onPressed: () {
              _confirmDeleteSplitCategory(category);
            },
            padding: const EdgeInsets.all(4.0),
            constraints: const BoxConstraints(),
            tooltip: 'Delete ${category.name}',
            splashRadius: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${category.percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey.shade600,
              size: 20,
            ),
            onPressed: _previousMonth,
            tooltip: 'Previous Month',
          ),
          Text(
            _getMonthName(_selectedMonth.month),
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade600,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade600,
              size: 20,
            ),
            onPressed: _nextMonth,
            tooltip: 'Next Month',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final List<SplitCategory> currentDisplayCategories =
        _getCurrentMonthSplitCategories();

    return Scaffold(
      backgroundColor: const Color(
        0xFF1400FF,
      ), // Main background for ledger area
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              // White top card
              padding: EdgeInsets.only(
                top: statusBarHeight + 16.0, // Space for status bar + padding
                left: 16.0,
                right: 16.0,
                bottom: 20.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                // Content of the white card
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthSelector(),
                  const SizedBox(height: 20),
                  const Text(
                    'Budget',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: budgetController,
                    onChanged: (value) {
                      setState(() {
                        budget = double.tryParse(value) ?? 0.0;
                      });
                    },
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: Colors.black.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F6F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 14.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Splitting',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (currentDisplayCategories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'No split categories yet. Add one below!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentDisplayCategories.length,
                      itemBuilder: (context, index) {
                        final category = currentDisplayCategories[index];
                        return _buildSplittingRow(
                          category,
                          Colors.blue.shade700,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 50,
                          endIndent: 10,
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  if (currentDisplayCategories.isNotEmpty)
                    Center(
                      child: Text(
                        'Total: ${totalSplitPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              totalSplitPercentage == 100.0
                                  ? Colors.green.shade700
                                  : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.grey[350], thickness: 1),
                  const SizedBox(height: 10),
                  Center(
                    child: Tooltip(
                      message: 'Add New Split Category',
                      child: InkWell(
                        onTap: _showAddSplitCategoryDialog,
                        borderRadius: BorderRadius.circular(6.0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.blue.shade600,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.blue.shade700,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ), // End of white top card Container
            // --- "Ledger" Title ---
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
              child: Center(
                child: Text(
                  'Ledger',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // --- Column Labels for Ledger ---
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 12,
                top: 4,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Expenses',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Outlook',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Date',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // --- End of Column Labels for Ledger ---
            ListView.builder(
              // Ledger items
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              itemCount: 6,
              itemBuilder: (context, index) {
                DateTime itemDate = DateTime.now().subtract(
                  Duration(days: index * 2),
                );
                String dateText;

                if (index == 0 &&
                    itemDate.day == DateTime.now().day &&
                    itemDate.month == DateTime.now().month &&
                    itemDate.year == DateTime.now().year) {
                  dateText = 'Today';
                } else {
                  String day = itemDate.day.toString().padLeft(2, '0');
                  String month = itemDate.month.toString().padLeft(2, '0');
                  String year = (itemDate.year % 100).toString().padLeft(
                    2,
                    '0',
                  );
                  dateText = '$day/$month/$year';
                }

                String amount = 'Rp 80.000,00';
                String percentageChange = '+1.50%';
                if (index == 1 || index == 4) {
                  amount = 'Rp 120.000,00';
                  percentageChange = '-0.50%';
                } else if (index == 2 || index == 5) {
                  amount = 'Rp 50.000,00';
                  percentageChange = '+2.75%';
                }

                return Card(
                  color: Colors.white.withOpacity(0.15),
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                    ), // Horizontal padding removed for Row
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                            ), // Padding for text within column
                            child: Text(
                              amount,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            percentageChange,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  percentageChange.startsWith('+')
                                      ? Colors.greenAccent.shade100
                                      : Colors.redAccent.shade100,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 16.0,
                            ), // Padding for text within column
                            child: Text(
                              dateText,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 80), // Bottom spacing for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('FAB Tapped: Add New Ledger Entry (Placeholder)'),
            ),
          );
        },
        tooltip: 'Add New Ledger Entry',
        shape: const CircleBorder(), // Makes the FAB circular
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.home_filled, color: Colors.black54),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                tooltip: 'Home',
              ),
              const SizedBox(width: 48), // Space for FAB
              IconButton(
                icon: const Icon(
                  Icons.table_chart_outlined,
                  color: Colors.black54,
                ),
                onPressed: () {
                  /* Navigate to ledger/table view */
                },
                tooltip: 'View Sheets',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
