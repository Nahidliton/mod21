import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
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
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
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

// ============ CATEGORY MODEL ============
class ExpenseCategory {
  final String name;
  final String emoji;
  final bool isCustom;

  ExpenseCategory({
    required this.name,
    required this.emoji,
    this.isCustom = false,
  });
}

// ============ BUDGET HISTORY MODEL ============
class BudgetHistory {
  final double oldAmount;
  final double newAmount;
  final double changeAmount;
  final DateTime date;
  final String reason;

  BudgetHistory({
    required this.oldAmount,
    required this.newAmount,
    required this.changeAmount,
    required this.date,
    required this.reason,
  });
}

// ============ EMOJI AUTO-ASSIGNER ============
String autoAssignEmoji(String categoryName) {
  final lower = categoryName.toLowerCase().trim();
  final Map<String, String> keywordEmoji = {
    'food': '🍔', 'restaurant': '🍽️', 'cafe': '☕', 'coffee': '☕',
    'tea': '🍵', 'pizza': '🍕', 'burger': '🍔', 'snack': '🍿',
    'grocery': '🛒', 'groceries': '🛒', 'drink': '🥤', 'water': '💧',
    'breakfast': '🥞', 'lunch': '🍱', 'dinner': '🍽️', 'meal': '🍱',
    'fruit': '🍎', 'vegetable': '🥦', 'dessert': '🍰', 'sweet': '🍬',
    'bakery': '🥐', 'dairy': '🥛', 'milk': '🥛',
    'transport': '🚗', 'car': '🚗', 'taxi': '🚕', 'cab': '🚕',
    'bus': '🚌', 'train': '🚆', 'metro': '🚇', 'flight': '✈️',
    'air': '✈️', 'fuel': '⛽', 'petrol': '⛽', 'gas': '⛽',
    'parking': '🅿️', 'bike': '🏍️', 'cycle': '🚲', 'uber': '🚕',
    'ola': '🚕', 'ride': '🚕',
    'shopping': '🛍️', 'shop': '🛍️', 'clothes': '👕', 'clothing': '👕',
    'shoe': '👟', 'shoes': '👟', 'electronics': '💻', 'gadget': '📱',
    'mobile': '📱', 'phone': '📱', 'laptop': '💻', 'furniture': '🛋️',
    'gift': '🎁', 'toy': '🧸', 'book': '📚', 'stationery': '✏️',
    'health': '🏥', 'medical': '🏥', 'medicine': '💊', 'doctor': '👨‍⚕️',
    'hospital': '🏥', 'pharmacy': '💊', 'dental': '🦷', 'dentist': '🦷',
    'fitness': '💪', 'gym': '💪', 'yoga': '🧘', 'exercise': '🏃',
    'sports': '⚽',
    'bill': '📄', 'bills': '📄', 'electricity': '💡', 'power': '💡',
    'water bill': '💧', 'internet': '🌐', 'wifi': '📶', 'broadband': '🌐',
    'phone bill': '📱', 'mobile bill': '📱', 'rent': '🏠', 'mortgage': '🏠',
    'insurance': '🛡️', 'tax': '💰', 'utility': '🔌',
    'entertainment': '🎬', 'movie': '🎬', 'cinema': '🎬', 'game': '🎮',
    'gaming': '🎮', 'music': '🎵', 'concert': '🎤', 'party': '🎉',
    'hobby': '🎨', 'art': '🎨', 'photography': '📷', 'streaming': '📺',
    'netflix': '📺', 'spotify': '🎵', 'subscription': '🔁',
    'education': '🎓', 'school': '🏫', 'college': '🎓', 'university': '🎓',
    'tuition': '📖', 'course': '📚', 'course fee': '📚', 'training': '📖',
    'exam': '📝', 'fee': '📝',
    'travel': '✈️', 'trip': '🧳', 'tour': '🧳', 'hotel': '🏨',
    'stay': '🏨', 'vacation': '🏖️', 'holiday': '🏖️', 'resort': '🏨',
    'ticket': '🎫', 'visa': '🛂', 'passport': '🛂',
    'home': '🏠', 'house': '🏠', 'repair': '🔧', 'maintenance': '🔧',
    'cleaning': '🧹', 'laundry': '🧺', 'garden': '🌿', 'pest': '🐛',
    'decor': '🖼️',
    'personal': '🧴', 'care': '🧴', 'beauty': '💄', 'cosmetic': '💄',
    'salon': '💇', 'haircut': '💇', 'spa': '💆', 'skincare': '🧴',
    'finance': '💳', 'loan': '💳', 'credit': '💳', 'debit': '💳',
    'investment': '📈', 'stocks': '📈', 'saving': '🏦', 'bank': '🏦',
    'emi': '💳', 'fee charge': '💳',
    'pet': '🐾', 'dog': '🐶', 'cat': '🐱', 'vet': '🩺',
    'animal': '🐾',
    'family': '👨‍👩‍👧', 'kid': '🧒', 'child': '🧒', 'baby': '👶',
    'children': '🧒', 'childcare': '🍼', 'daycare': '🍼',
    'donation': '🤝', 'charity': '🤝', 'religious': '🙏',
    'temple': '🛕', 'church': '⛪', 'mosque': '🕌',
    'office': '💼', 'business': '💼', 'work': '💼',
    'emergency': '🚨', 'misc': '📦', 'other': '📦',
  };

  if (keywordEmoji.containsKey(lower)) return keywordEmoji[lower]!;
  final sortedKeys = keywordEmoji.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final key in sortedKeys) {
    if (lower.contains(key)) return keywordEmoji[key]!;
  }
  final words = lower.split(RegExp(r'[\s_\-]+'));
  for (final word in words) {
    if (word.isNotEmpty && keywordEmoji.containsKey(word)) {
      return keywordEmoji[word]!;
    }
  }
  return '🏷️';
}

// ============ EXPENSE MODEL ============
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
}

// ============ MAIN SCREEN ============
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
  
  // Month filter state
  DateTime _selectedMonth = DateTime.now();

  double _monthlyBudget = 0.0;
  bool _isBudgetSet = false;

  List<BudgetHistory> _budgetHistory = [];

  String _currencySymbol = '৳';
  String _currencyCode = 'BDT';

  List<ExpenseCategory> _categories = [
    ExpenseCategory(name: 'Food', emoji: '🍔'),
    ExpenseCategory(name: 'Transport', emoji: '🚗'),
    ExpenseCategory(name: 'Shopping', emoji: '🛍️'),
    ExpenseCategory(name: 'Other', emoji: '📦'),
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _newCategoryController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  List<String> get _categoryNames => _categories.map((c) => c.name).toList();

  ExpenseCategory _getCategoryByName(String name) {
    return _categories.firstWhere(
      (c) => c.name == name,
      orElse: () => ExpenseCategory(name: name, emoji: '🏷️'),
    );
  }

  @override
  void initState() {
    super.initState();
    _applyFilter();
  }

  void _changeCurrency() {
    final currencies = [
      {'symbol': '৳', 'code': 'BDT', 'name': 'Bangladeshi Taka'},
      {'symbol': '\$', 'code': 'USD', 'name': 'US Dollar'},
      {'symbol': '€', 'code': 'EUR', 'name': 'Euro'},
      {'symbol': '₹', 'code': 'INR', 'name': 'Indian Rupee'},
      {'symbol': '£', 'code': 'GBP', 'name': 'British Pound'},
      {'symbol': '¥', 'code': 'JPY', 'name': 'Japanese Yen'},
      {'symbol': 'A\$', 'code': 'AUD', 'name': 'Australian Dollar'},
      {'symbol': 'C\$', 'code': 'CAD', 'name': 'Canadian Dollar'},
      {'symbol': 'AED', 'code': 'AED', 'name': 'UAE Dirham'},
      {'symbol': 'SAR', 'code': 'SAR', 'name': 'Saudi Riyal'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: currencies.length,
          itemBuilder: (context, index) {
            final c = currencies[index];
            return ListTile(
              leading: CircleAvatar(child: Text(c['symbol']!)),
              title: Text(c['name']!),
              subtitle: Text(c['code']!),
              trailing: _currencyCode == c['code']
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() {
                  _currencySymbol = c['symbol']!;
                  _currencyCode = c['code']!;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _addExpense() {
    // Reset date to be within the selected month
    _selectedDate = _selectedMonth;

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
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        hintText: 'Enter amount',
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: '$_currencySymbol ',
                        border: const OutlineInputBorder(),
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
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat.name,
                          child: Text('${cat.emoji}  ${cat.name}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Create New Category'),
                        onPressed: () {
                          _showCreateCategoryDialog((newCat) {
                            setState(() {
                              _categories.add(newCat);
                              _selectedCategory = newCat.name;
                            });
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() => _selectedDate = pickedDate);
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            hintText: 'Select date',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: const OutlineInputBorder(),
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
                  onPressed: () => _saveExpense(context),
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

  void _showCreateCategoryDialog(Function(ExpenseCategory) onCreated) {
    _newCategoryController.clear();
    String previewEmoji = '🏷️';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add_box, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('New Category'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _newCategoryController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      hintText: 'e.g. Gym, Netflix, Pet Food',
                      prefixIcon: const Icon(Icons.label),
                      suffixIcon: Text(
                        previewEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      border: const OutlineInputBorder(),
                      helperText: 'Emoji is auto-assigned based on the name',
                    ),
                    onChanged: (value) {
                      setState(() => previewEmoji = autoAssignEmoji(value));
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          previewEmoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'The emoji above will be used for this category.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = _newCategoryController.text.trim();
                    if (name.isEmpty) {
                      _showSnackBar('Category name cannot be empty', Colors.red);
                      return;
                    }
                    if (_categories.any(
                        (c) => c.name.toLowerCase() == name.toLowerCase())) {
                      _showSnackBar('Category already exists', Colors.red);
                      return;
                    }

                    final newCategory = ExpenseCategory(
                      name: name,
                      emoji: autoAssignEmoji(name),
                      isCustom: true,
                    );

                    onCreated(newCategory);
                    Navigator.pop(context);
                    _showSnackBar(
                      'Category "$name" created ${newCategory.emoji}',
                      Colors.green,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create'),
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
    _selectedCategory = _categories.isNotEmpty ? _categories.first.name : 'Food';
    _selectedDate = _selectedMonth; // Reset to the selected month
  }

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

  // ============ SET / UPDATE BUDGET (+ / -) WITH REASON ============
  void _setBudget() {
    _budgetController.clear();
    _reasonController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final input = _budgetController.text.trim();
            double previewBudget = _monthlyBudget;
            if (input.isNotEmpty) {
              if (input.startsWith('+')) {
                final val = double.tryParse(input.substring(1));
                if (val != null) previewBudget += val;
              } else if (input.startsWith('-')) {
                final val = double.tryParse(input.substring(1));
                if (val != null) previewBudget -= val;
              } else {
                final val = double.tryParse(input);
                if (val != null) previewBudget = val;
              }
            }

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(_isBudgetSet ? 'Update Budget' : 'Set Budget'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isBudgetSet) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Current Budget:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '$_currencySymbol${_monthlyBudget.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _budgetController,
                      keyboardType: TextInputType.text,
                      onChanged: (val) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: _isBudgetSet ? 'Amount (e.g. 1000, +500, -200)' : 'Monthly Budget',
                        helperText: _isBudgetSet 
                            ? 'Type + to add, - to subtract, or just a number to replace.' 
                            : null,
                        prefixIcon: const Icon(Icons.attach_money),
                        prefixText: '$_currencySymbol ',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason for change (Optional)',
                        hintText: 'e.g., Salary increased, Cut expenses',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_isBudgetSet && input.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('New Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '$_currencySymbol${previewBudget.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_isBudgetSet) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.history),
                        label: const Text('View Budget History'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showBudgetHistory();
                        },
                      ),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final inputText = _budgetController.text.trim();
                    if (inputText.isEmpty) {
                      _showSnackBar('Please enter an amount', Colors.red);
                      return;
                    }

                    double newBudget = _monthlyBudget;
                    double changeAmount = 0;

                    if (inputText.startsWith('+')) {
                      final val = double.tryParse(inputText.substring(1));
                      if (val == null) {
                        _showSnackBar('Invalid number', Colors.red);
                        return;
                      }
                      newBudget += val;
                      changeAmount = val;
                    } else if (inputText.startsWith('-')) {
                      final val = double.tryParse(inputText.substring(1));
                      if (val == null) {
                        _showSnackBar('Invalid number', Colors.red);
                        return;
                      }
                      newBudget -= val;
                      changeAmount = -val;
                    } else {
                      final val = double.tryParse(inputText);
                      if (val == null) {
                        _showSnackBar('Invalid number', Colors.red);
                        return;
                      }
                      newBudget = val;
                      changeAmount = newBudget - _monthlyBudget;
                    }

                    if (newBudget < 0) {
                      _showSnackBar('Budget cannot be negative', Colors.red);
                      return;
                    }

                    final reason = _reasonController.text.trim();
                    final oldBudget = _monthlyBudget;

                    setState(() {
                      _monthlyBudget = newBudget;
                      _isBudgetSet = true;
                      
                      _budgetHistory.add(BudgetHistory(
                        oldAmount: oldBudget,
                        newAmount: newBudget,
                        changeAmount: changeAmount,
                        date: DateTime.now(),
                        reason: reason.isEmpty 
                            ? (_budgetHistory.isEmpty ? 'Initial budget' : 'Updated budget') 
                            : reason,
                      ));
                    });

                    Navigator.pop(context);
                    _showSnackBar('Budget updated successfully!', Colors.green);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isBudgetSet ? 'Update' : 'Set Budget'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============ VIEW BUDGET HISTORY ============
  void _showBudgetHistory() {
    if (_budgetHistory.isEmpty) {
      _showSnackBar('No budget history yet', Colors.orange);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.history, color: Colors.blue),
              SizedBox(width: 8),
              Text('Budget History'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _budgetHistory.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final history = _budgetHistory.reversed.toList()[index];
                final isAddition = history.changeAmount >= 0;
                
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: isAddition ? Colors.green : Colors.red,
                    child: Icon(
                      isAddition ? Icons.arrow_upward : Icons.arrow_downward, 
                      color: Colors.white, 
                      size: 20
                    ),
                  ),
                  title: Text(
                    '${isAddition ? '+' : ''} $_currencySymbol${history.changeAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: isAddition ? Colors.green : Colors.red,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(history.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'From $_currencySymbol${history.oldAmount.toStringAsFixed(2)} to $_currencySymbol${history.newAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reason: ${history.reason}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
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

  // ============ CALCULATIONS ============
  double _calculateTotalExpense() =>
      _filteredExpenses.fold(0, (sum, e) => sum + e.amount);

  double _calculateTodayTotal() {
    DateTime today = DateTime.now();
    // Only show today's total if the selected month is the current month
    if (today.year != _selectedMonth.year || today.month != _selectedMonth.month) {
      return 0;
    }
    
    return _filteredExpenses
        .where((e) =>
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double _calculateHighestExpense() {
    if (_filteredExpenses.isEmpty) return 0;
    return _filteredExpenses
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);
  }

  double _calculateLowestExpense() {
    if (_filteredExpenses.isEmpty) return 0;
    return _filteredExpenses
        .map((e) => e.amount)
        .reduce((a, b) => a < b ? a : b);
  }

  double _calculateAverageExpense() {
    if (_filteredExpenses.isEmpty) return 0;
    return _calculateTotalExpense() / _filteredExpenses.length;
  }

  String _getSpendingStatus() {
    if (!_isBudgetSet || _monthlyBudget <= 0) return 'No Budget Set';
    double pct = (_calculateTotalExpense() / _monthlyBudget) * 100;
    if (pct < 50) return '🟢 Safe';
    if (pct < 80) return '🟡 Moderate';
    if (pct <= 100) return '🟠 Warning';
    return '🔴 Over Budget';
  }

  Color _getSpendingStatusColor() {
    if (!_isBudgetSet || _monthlyBudget <= 0) return Colors.grey;
    double pct = (_calculateTotalExpense() / _monthlyBudget) * 100;
    if (pct < 50) return Colors.green;
    if (pct < 80) return Colors.orange;
    if (pct <= 100) return Colors.deepOrange;
    return Colors.red;
  }

  void _applyFilter() {
    setState(() {
      _filteredExpenses = _expenses.where((e) =>
          e.date.year == _selectedMonth.year &&
          e.date.month == _selectedMonth.month).toList();
    });
  }

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

  // ============ PDF EXPORT ============
  Future<void> _exportToPdf() async {
    if (_filteredExpenses.isEmpty) {
      _showSnackBar('No expenses to export for this month', Colors.orange);
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final pdf = pw.Document();

      final now = DateTime.now();
      final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(now);
      final monthStr = DateFormat('MMMM yyyy').format(_selectedMonth);

      final sortedExpenses = List<Expense>.from(_filteredExpenses)
        ..sort((a, b) => b.date.compareTo(a.date));

      final total = _filteredExpenses.fold<double>(0, (s, e) => s + e.amount);
      final avg = _filteredExpenses.isEmpty ? 0.0 : total / _filteredExpenses.length;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (context) => pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.blueGrey300, width: 2),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Smart Expense Tracker',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Expense Report ($_currencyCode) - $monthStr',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      dateStr,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
          ),
          build: (context) => [
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.blue200),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _pdfSummaryCell('Total Expenses', '${_filteredExpenses.length}'),
                      _pdfSummaryCell('Total Amount', '$_currencyCode ${total.toStringAsFixed(2)}'),
                      _pdfSummaryCell('Average', '$_currencyCode ${avg.toStringAsFixed(2)}'),
                    ],
                  ),
                  if (_isBudgetSet) ...[
                    pw.SizedBox(height: 12),
                    pw.Divider(color: PdfColors.blue200),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _pdfSummaryCell('Monthly Budget', '$_currencyCode ${_monthlyBudget.toStringAsFixed(2)}'),
                        _pdfSummaryCell('Spent', '$_currencyCode ${total.toStringAsFixed(2)}'),
                        _pdfSummaryCell('Remaining', '$_currencyCode ${(_monthlyBudget - total).toStringAsFixed(2)}'),
                        _pdfSummaryCell('Status', _getSpendingStatus().replaceAll(RegExp(r'[^\w\s]'), '').trim()),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Expense Details',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Title', 'Category', 'Amount'],
              data: sortedExpenses
                  .map((e) => [
                        DateFormat('dd/MM/yyyy').format(e.date),
                        e.title,
                        e.category,
                        '$_currencyCode ${e.amount.toStringAsFixed(2)}',
                      ])
                  .toList(),
              headerStyle: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blue700),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerRight,
              },
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(4),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
                width: 0.5,
              ),
              oddRowDecoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColors.grey400),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Grand Total: $_currencyCode ${total.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
          ],
        ),
      );

      if (mounted) Navigator.pop(context); 

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'expense_report_${DateFormat('yyyyMM').format(_selectedMonth)}.pdf',
      );

      _showSnackBar('PDF report downloaded/shared!', Colors.green);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnackBar('Error generating PDF: $e', Colors.red);
    }
  }

  pw.Widget _pdfSummaryCell(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  // ============ BUILD ============
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
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.light
                ? Icons.dark_mode
                : Icons.light_mode),
            onPressed: widget.toggleTheme,
            tooltip: widget.themeMode == ThemeMode.light
                ? 'Switch to Dark Mode'
                : 'Switch to Light Mode',
          ),
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            onPressed: _changeCurrency,
            tooltip: 'Change Currency ($_currencyCode)',
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: _setBudget,
            tooltip: 'Set / Update Budget',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
            tooltip: 'Export as PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // ============ MONTH SELECTOR ============
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C2C)
                : Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Showing Month:', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedMonth,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      initialDatePickerMode: DatePickerMode.year,
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedMonth = picked;
                        _applyFilter();
                      });
                    }
                  },
                ),
              ],
            ),
          ),

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
                      Text('Monthly Budget',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600])),
                      Text('$_currencySymbol${_monthlyBudget.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Remaining',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600])),
                      Text(
                          '$_currencySymbol${(_monthlyBudget - _calculateTotalExpense()).toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getSpendingStatusColor())),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Status',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600])),
                      Text(_getSpendingStatus(),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getSpendingStatusColor())),
                    ],
                  ),
                ],
              ),
            ),
          
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildStatCard('Total', _calculateTotalExpense(),
                    Colors.blue, Icons.attach_money),
                _buildStatCard('Today', _calculateTodayTotal(),
                    Colors.green, Icons.today),
                _buildStatCard('Avg', _calculateAverageExpense(),
                    Colors.purple, Icons.analytics),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildStatCard('Highest', _calculateHighestExpense(),
                    Colors.orange, Icons.trending_up),
                _buildStatCard('Lowest', _calculateLowestExpense(),
                    Colors.red, Icons.trending_down),
                _buildStatCard('Expenses',
                    _filteredExpenses.length.toDouble(),
                    Colors.teal, Icons.receipt_long),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox,
                            size: 64,
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                          style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[400]
                                  : Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add an expense',
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[500]
                                  : Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredExpenses.length,
                    itemBuilder: (context, index) {
                      Expense expense = _filteredExpenses[index];
                      final cat = _getCategoryByName(expense.category);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: Text(
                            cat.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                          title: Text(expense.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            '${expense.category} • ${DateFormat('dd/MM/yyyy').format(expense.date)}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_currencySymbol${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
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

  Widget _buildStatCard(
      String label, double value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 14),
                const SizedBox(width: 4),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).brightness ==
                                Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600])),
              ],
            ),
            Text(
              label == 'Expenses'
                  ? value.toStringAsFixed(0)
                  : '$_currencySymbol${value.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}


