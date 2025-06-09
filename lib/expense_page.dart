import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> addExpense(String userId, String date, double amount, String category, String token) async {
  final url = Uri.parse('http://localhost:5000/api/expense');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'userId': userId,
      'date': date,
      'amount': amount,
      'category': category,
    }),
  );

  if (response.statusCode == 200) {
    print("Expense added: ${response.body}");
  } else {
    print("Failed to add expense: ${response.body}");
  }
}

Future<List<Map<String, dynamic>>> fetchExpenses(String userId, String token) async {
  final url = Uri.parse('http://localhost:5000/api/expense/$userId');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    print("Failed to fetch expenses: ${response.body}");
    return [];
  }
}



class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  String? userId;
  String? token;
  String _selectedNeeds = 'Needs';
  String _currentAmount = '0,00';
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, String>> _expenses = [];

  @override
  void initState() {
    super.initState();
    loadUserCredentials();
  }

  Future<void> loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    final savedToken = prefs.getString('token');

    setState(() {
      userId = savedUserId;
      token = savedToken;
    });

    if (savedUserId != null && savedToken != null) {
      final expensesFromDB = await fetchExpenses(savedUserId, savedToken);
      setState(() {
        _expenses.clear();
        for (final expense in expensesFromDB) {
          final formattedDate = DateTime.tryParse(expense['date'] ?? '');
          final displayDate = formattedDate != null
              ? "${formattedDate.day.toString().padLeft(2, '0')}/"
                "${formattedDate.month.toString().padLeft(2, '0')}/"
                "${formattedDate.year.toString().substring(2)}"
              : 'Unknown';

          _expenses.add({
            'amount': (expense['amount'] ?? 0).toStringAsFixed(2),
            'category': expense['category'] ?? 'Unknown',
            'date': displayDate,
            'expenseId': expense['_id'],
          });
        }
      });
    }
  }

  String get formattedDate {
    return "${_selectedDate.day.toString().padLeft(2, '0')}/"
        "${_selectedDate.month.toString().padLeft(2, '0')}/"
        "${_selectedDate.year.toString().substring(2)}";
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onNumberTap(String number) {
    setState(() {
      if (number == '.' && _currentAmount.contains(',')) return;
      if (_currentAmount == '0,00') {
        _currentAmount = number == '.' ? '0,' : number;
      } else {
        _currentAmount += number;
      }
    });
  }

  void _onDeleteTap() {
    setState(() {
      if (_currentAmount.isNotEmpty) {
        _currentAmount = _currentAmount.substring(0, _currentAmount.length - 1);
        if (_currentAmount.isEmpty) {
          _currentAmount = '0,00';
        }
      }
    });
  }

  void _resetInput() {
    setState(() {
      _currentAmount = '0,00';
      _selectedNeeds = 'Needs';
    });
  }

  void _saveExpense() async {
    if (userId == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not logged in. Please login again.')),
      );
      return;
    }

    final amount = double.tryParse(_currentAmount.replaceAll(',', '.')) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    final dateFormatted = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";

    await addExpense(userId!, dateFormatted, amount, _selectedNeeds, token!);

    final newExpenses = await fetchExpenses(userId!, token!);
    setState(() {
      _expenses.clear();
      for (final expense in newExpenses) {
        final formattedDate = DateTime.tryParse(expense['date'] ?? '');
        final displayDate = formattedDate != null
            ? "${formattedDate.day.toString().padLeft(2, '0')}/"
              "${formattedDate.month.toString().padLeft(2, '0')}/"
              "${formattedDate.year.toString().substring(2)}"
            : 'Unknown';

        _expenses.add({
          'amount': (expense['amount'] ?? 0).toStringAsFixed(2),
          'category': expense['category'] ?? 'Unknown',
          'date': displayDate,
          'expenseId': expense['_id'],
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense submitted!')),
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    final url = Uri.parse('http://localhost:5000/api/expense/$expenseId');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      print("Deleted successfully");
    } else {
      print("Delete failed: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color topBackgroundColor = Color(0xFFF7F8FA);
    const Color blueSectionColor = Color(0xFF4A90E2);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: topBackgroundColor,
        elevation: 0,
        title: const Text(
          'Daily Expense',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _pickDate,
              child: Center(
                child: Text(
                  formattedDate,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(color: blueSectionColor),
          Padding(
            padding: const EdgeInsets.only(top: 230.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Remaining',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rp 1.000.000,00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Daily Quota Remaining',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rp 80.000,00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('Expenses', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('Category', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Date', textAlign: TextAlign.right, style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _expenses.length,
                      itemBuilder: (context, index) {
                        final item = _expenses[index];
                        return ExpenseListItem(
                          amount: 'Rp ${item['amount']}',
                          category: item['category']!,
                          date: item['date']!,
                          onDelete: () async {
                            final expenseId = item['expenseId'];
                            if (expenseId != null) {
                              await deleteExpense(expenseId);
                              setState(() {
                                _expenses.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Expense deleted')),
                              );
                            } else {
                              print("Expense ID is null, cannot delete.");
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: topBackgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('Rp', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              _currentAmount,
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedNeeds,
                        decoration: const InputDecoration(border: InputBorder.none),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedNeeds = newValue!;
                          });
                        },
                        items: ['Needs', 'Food', 'Transport', 'Utilities', 'Entertainment']
                            .map((value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _resetInput,
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: (_currentAmount == '0,00' || _currentAmount.isEmpty)
                              ? null
                              : _saveExpense,
                          child: Text(
                            'SAVE',
                            style: TextStyle(
                              color: (_currentAmount == '0,00' || _currentAmount.isEmpty)
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['1', '2', '3', '000'].map((e) => _buildKeypadButton(e)).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['4', '5', '6', '.'].map((e) => _buildKeypadButton(e)).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['7', '8', '9', '0'].map((e) => _buildKeypadButton(e)).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['⌫'].map((e) => _buildKeypadButton(e, isBackspace: true)).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String text, {bool isBackspace = false}) {
    return Expanded(
      child: InkWell(
        onTap: () => isBackspace ? _onDeleteTap() : _onNumberTap(text),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          margin: const EdgeInsets.all(4.0),
          alignment: Alignment.center,
          height: 50,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class ExpenseListItem extends StatelessWidget {
  final String amount;
  final String category;
  final String date;
  final VoidCallback? onDelete;

  const ExpenseListItem({
    super.key,
    required this.amount,
    required this.category,
    required this.date,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(amount, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Text(date, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.delete, color: Colors.red[200]),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
