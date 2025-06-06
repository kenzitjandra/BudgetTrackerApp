import 'package:flutter/material.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  String _selectedNeeds = 'Needs'; // Default dropdown value
  String _currentAmount = '0,00'; // Initial amount displayed

  void _onNumberTap(String number) {
    setState(() {
      if (_currentAmount == '0,00') {
        _currentAmount = number;
      } else {
        _currentAmount += number;
      }
    });
  }

  void _onDeleteTap() {
    setState(() {
      if (_currentAmount.isNotEmpty && _currentAmount != '0,00') {
        _currentAmount = _currentAmount.substring(0, _currentAmount.length - 1);
        if (_currentAmount.isEmpty) {
          _currentAmount = '0,00';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C), // Dark background for the entire screen
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C), // Dark grey app bar
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(top: 8.0), // Adjust padding to match screenshot
          child: Text(
            'Daily Expense',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0, top: 8.0),
            child: Text(
              '03/05/25',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0), // Small line under the app bar
          child: Container(
            color: const Color(0xFFF2F2F2).withOpacity(0.1), // Faint line
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Expense text
          const Padding(
            padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 8.0),
            child: Text(
              'Input Expense',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A), // Darker grey for input fields
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Rp',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentAmount,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedNeeds,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: const Color(0xFF505050), // Slightly lighter grey for dropdown
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: const Color(0xFF505050),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedNeeds = newValue!;
                      });
                    },
                    items: <String>['Needs', 'Food', 'Transport', 'Utilities', 'Entertainment']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Handle CANCEL
                        },
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Handle SAVE
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF42A5F5), // Blue SAVE button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'SAVE',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Blue summary section
          Container(
            padding: const EdgeInsets.all(20.0),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5), // Blue color for summary
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Total Remaining',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Rp 1.000.000,00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Daily Quota Remaining',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Rp 80.000,00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Expense List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text('Expenses', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Outlook', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Date', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 20), // Separator line

          // Expense List Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              children: const [
                ExpenseListItem(amount: 'Rp 80.000,00', outlook: '+1.50%', date: 'Today'),
                ExpenseListItem(amount: 'Rp 80.000,00', outlook: '+1.50%', date: '02/05/25'),
                ExpenseListItem(amount: 'Rp 80.000,00', outlook: '+1.50%', date: '01/05/25'),
                ExpenseListItem(amount: 'Rp 80.000,00', outlook: '+1.50%', date: '30/04/25'),
                ExpenseListItem(amount: 'Rp 80.000,00', outlook: '+1.50%', date: '29/04/25'),
                ExpenseListItem(amount: 'Rp 80.000,00', outlook: '+1.50%', date: '28/04/25'),
              ],
            ),
          ),
          // Numeric Keypad
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Color(0xFF3A3A3A), // Darker grey for keypad background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildKeypadButton('1'),
                    _buildKeypadButton('2'),
                    _buildKeypadButton('3'),
                    _buildKeypadButton('000'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildKeypadButton('4'),
                    _buildKeypadButton('5'),
                    _buildKeypadButton('6'),
                    _buildKeypadButton('.'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildKeypadButton('7'),
                    _buildKeypadButton('8'),
                    _buildKeypadButton('9'),
                    _buildKeypadButton('⌫', isBackspace: true), // Backspace icon
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String text, {bool isBackspace = false}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (isBackspace) {
            _onDeleteTap();
          } else {
            _onNumberTap(text);
          }
        },
        child: Container(
          margin: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          height: 60,
          child: Text(
            text,
            style: TextStyle(
              color: isBackspace ? const Color(0xFFF44336) : Colors.white, // Red for backspace
              fontSize: isBackspace ? 24 : 28,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class ExpenseListItem extends StatelessWidget {
  final String amount;
  final String outlook;
  final String date;

  const ExpenseListItem({
    super.key,
    required this.amount,
    required this.outlook,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(amount, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          Expanded(
            flex: 2,
            child: Text(outlook, style: const TextStyle(color: Color(0xFF66BB6A), fontSize: 16)), // Green for outlook
          ),
          Expanded(
            flex: 2,
            child: Text(date, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
