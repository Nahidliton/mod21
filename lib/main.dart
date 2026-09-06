import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const SmartExpenseTracker());
}

class SmartExpenseTracker extends StatefulWidget {
  const SmartExpenseTracker({super.key});

  @override
  State<SmartExpenseTracker> createState() => _SmartExpenseTrackerState();
}

class _SmartExpenseTrackerState extends State<SmartExpenseTracker> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        brightness: Brightness.light,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        dialogBackgroundColor: const Color(0xFF1E1E1E),
      ),
      themeMode: _themeMode,
      home: ExpenseTrackerScreen(
        toggleTheme: toggleTheme,
        themeMode: _themeMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Expense Model
class Expense {
  String id;
  String title;
  double amount;
  String category;
  DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
    );
  }
}

// Main Screen
class ExpenseTrackerScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  const ExpenseTrackerScreen({
    super.key,
    required this.toggleTheme,
    required this.themeMode,
  });

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  String _selectedFilter = 'All';
  String _selectedCategoryFilter = 'All';
  double _monthlyBudget = 0.0;
  bool _isBudgetSet = false;

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  // Category list
  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Other'];
  final List<String> _filterOptions = ['All', 'Today', 'This Week', 'This Month', 'By Category'];

  @override
  void initState() {
    super.initState();
    _filteredExpenses = _expenses;
  }

  // Add Expense
  void _addExpense() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Add Expense'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Expense Title',
                        hintText: 'Enter expense title',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        hintText: 'Enter amount',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            hintText: 'Select date',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    _selectedDate = pickedDate;
                                  });
                                }
                              },
                            ),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('dd/MM/yyyy').format(_selectedDate),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _clearAddExpenseFields();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveExpense(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Expense'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveExpense(BuildContext context) {
    String title = _titleController.text.trim();
    String amountText = _amountController.text.trim();

    if (title.isEmpty) {
      _showSnackBar('Please enter expense title', Colors.red);
      return;
    }

    double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Amount must be greater than 0', Colors.red);
      return;
    }

    Expense newExpense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
    );

    setState(() {
      _expenses.add(newExpense);
      _applyFilter();
      _clearAddExpenseFields();
    });

    Navigator.pop(context);
    _showSnackBar('Expense added successfully!', Colors.green);
  }

  void _clearAddExpenseFields() {
    _titleController.clear();
    _amountController.clear();
    _selectedCategory = 'Food';
    _selectedDate = DateTime.now();
  }

  // Delete Expense
  void _deleteExpense(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _expenses.removeWhere((expense) => expense.id == id);
                  _applyFilter();
                });
                Navigator.pop(context);
                _showSnackBar('Expense deleted successfully!', Colors.orange);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Set Budget
  void _setBudget() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.blue),
              SizedBox(width: 8),
              Text('Set Monthly Budget'),
            ],
          ),
          content: TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Budget',
              hintText: 'Enter your monthly budget',
              prefixIcon: Icon(Icons.attach_money),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _budgetController.clear();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String budgetText = _budgetController.text.trim();
                double? budget = double.tryParse(budgetText);

                if (budget == null || budget < 0) {
                  _showSnackBar('Budget cannot be negative', Colors.red);
                  return;
                }

                setState(() {
                  _monthlyBudget = budget;
                  _isBudgetSet = true;
                  _budgetController.clear();
                });

                Navigator.pop(context);
                _showSnackBar('Budget set successfully!', Colors.green);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Set Budget'),
            ),
          ],
        );
      },
    );
  }

  // Calculate Totals
  double _calculateTotalExpense() {
    return _filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double _calculateTodayTotal() {
    DateTime today = DateTime.now();
    return _filteredExpenses
        .where((expense) =>
            expense.date.year == today.year &&
            expense.date.month == today.month &&
            expense.date.day == today.day)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double _calculateHighestExpense() {
    if (_filteredExpenses.isEmpty) return 0;
    return _filteredExpenses.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
  }

  double _calculateLowestExpense() {
    if (_filteredExpenses.isEmpty) return 0;
    return _filteredExpenses.map((e) => e.amount).reduce((a, b) => a < b ? a : b);
  }

  double _calculateAverageExpense() {
    if (_filteredExpenses.isEmpty) return 0;
    return _calculateTotalExpense() / _filteredExpenses.length;
  }

  // Category-wise totals
  Map<String, double> _calculateCategoryTotals() {
    Map<String, double> categoryTotals = {};
    for (String category in _categories) {
      categoryTotals[category] = _filteredExpenses
          .where((expense) => expense.category == category)
          .fold(0, (sum, expense) => sum + expense.amount);
    }
    return categoryTotals;
  }

  // Spending Status
  String _getSpendingStatus() {
    if (!_isBudgetSet || _monthlyBudget <= 0) return 'No Budget Set';
    
    double total = _calculateTotalExpense();
    double percentage = (total / _monthlyBudget) * 100;

    if (percentage < 50) return '🟢 Safe';
    if (percentage >= 50 && percentage < 80) return '🟡 Moderate';
    if (percentage >= 80 && percentage <= 100) return '🟠 Warning';
    return '🔴 Over Budget';
  }

  Color _getSpendingStatusColor() {
    if (!_isBudgetSet || _monthlyBudget <= 0) return Colors.grey;
    
    double total = _calculateTotalExpense();
    double percentage = (total / _monthlyBudget) * 100;

    if (percentage < 50) return Colors.green;
    if (percentage >= 50 && percentage < 80) return Colors.orange;
    if (percentage >= 80 && percentage <= 100) return Colors.deepOrange;
    return Colors.red;
  }

  // Filter Expenses
  void _applyFilter() {
    setState(() {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      
      if (_selectedFilter == 'All') {
        _filteredExpenses = List.from(_expenses);
      } else if (_selectedFilter == 'Today') {
        _filteredExpenses = _expenses.where((expense) =>
          expense.date.year == today.year &&
          expense.date.month == today.month &&
          expense.date.day == today.day
        ).toList();
      } else if (_selectedFilter == 'This Week') {
        DateTime weekStart = today.subtract(Duration(days: today.weekday - 1));
        _filteredExpenses = _expenses.where((expense) =>
          expense.date.isAfter(weekStart) || expense.date.isAtSameMomentAs(weekStart)
        ).toList();
      } else if (_selectedFilter == 'This Month') {
        _filteredExpenses = _expenses.where((expense) =>
          expense.date.year == today.year &&
          expense.date.month == today.month
        ).toList();
      } else if (_selectedFilter == 'By Category' && _selectedCategoryFilter != 'All') {
        _filteredExpenses = _expenses.where((expense) =>
          expense.category == _selectedCategoryFilter
        ).toList();
      } else {
        _filteredExpenses = List.from(_expenses);
      }
    });
  }

  // Show SnackBar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show All Categories Dialog
  void _showCategoryTotals() {
    Map<String, double> categoryTotals = _calculateCategoryTotals();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.pie_chart, color: Colors.blue),
              SizedBox(width: 8),
              Text('Category Totals'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                String category = _categories[index];
                double amount = categoryTotals[category] ?? 0;
                return Card(
                  child: ListTile(
                    leading: _getCategoryIcon(category),
                    title: Text(category),
                    trailing: Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData icon;
    Color color;
    switch (category) {
      case 'Food':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'Transport':
        icon = Icons.directions_car;
        color = Colors.blue;
        break;
      case 'Shopping':
        icon = Icons.shopping_bag;
        color = Colors.purple;
        break;
      default:
        icon = Icons.more_horiz;
        color = Colors.grey;
    }
    return Icon(icon, color: color, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A1A1A)
            : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Dark Mode Toggle Button
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: widget.toggleTheme,
            tooltip: widget.themeMode == ThemeMode.light
                ? 'Switch to Dark Mode'
                : 'Switch to Light Mode',
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: _setBudget,
            tooltip: 'Set Budget',
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: _showCategoryTotals,
            tooltip: 'Category Totals',
          ),
        ],
      ),
      body: Column(
        children: [
          // Budget Status Card
          if (_isBudgetSet)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getSpendingStatusColor().withOpacity(0.1),
                    _getSpendingStatusColor().withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getSpendingStatusColor(),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Budget',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₹${_monthlyBudget.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Remaining',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '₹${(_monthlyBudget - _calculateTotalExpense()).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getSpendingStatusColor(),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      Text(
                        _getSpendingStatus(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getSpendingStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    isExpanded: true,
                    dropdownColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2C2C2C)
                        : Colors.white,
                    items: _filterOptions.map((filter) {
                      return DropdownMenuItem(
                        value: filter,
                        child: Text(filter),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                        if (_selectedFilter != 'By Category') {
                          _selectedCategoryFilter = 'All';
                        }
                        _applyFilter();
                      });
                    },
                  ),
                ),
                if (_selectedFilter == 'By Category')
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedCategoryFilter,
                      isExpanded: true,
                      dropdownColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2C2C2C)
                          : Colors.white,
                      items: ['All', ..._categories].map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryFilter = value!;
                          _applyFilter();
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Statistics Cards
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildStatCard(
                  'Total',
                  _calculateTotalExpense(),
                  Colors.blue,
                  Icons.attach_money,
                ),
                _buildStatCard(
                  'Today',
                  _calculateTodayTotal(),
                  Colors.green,
                  Icons.today,
                ),
                _buildStatCard(
                  'Avg',
                  _calculateAverageExpense(),
                  Colors.purple,
                  Icons.analytics,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildStatCard(
                  'Highest',
                  _calculateHighestExpense(),
                  Colors.orange,
                  Icons.trending_up,
                ),
                _buildStatCard(
                  'Lowest',
                  _calculateLowestExpense(),
                  Colors.red,
                  Icons.trending_down,
                ),
                _buildStatCard(
                  'Expenses',
                  _filteredExpenses.length.toDouble(),
                  Colors.teal,
                  Icons.receipt_long,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Expense List
          Expanded(
            child: _filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _expenses.isEmpty
                              ? 'No expenses added yet!'
                              : 'No expenses match the filter',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_expenses.isEmpty)
                          Text(
                            'Tap the + button to add your first expense',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[500]
                                  : Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredExpenses.length,
                    itemBuilder: (context, index) {
                      Expense expense = _filteredExpenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: _getCategoryIcon(expense.category),
                          title: Text(
                            expense.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${expense.category} • ${DateFormat('dd/MM/yyyy').format(expense.date)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteExpense(expense.id),
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }

  Widget _buildStatCard(String label, double value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
            Text(
              label == 'Expenses'
                  ? value.toStringAsFixed(0)
                  : '₹${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}