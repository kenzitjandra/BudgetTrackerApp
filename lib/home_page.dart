import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'budgeting_page.dart';
import 'expense_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>?> fetchBudget(String userId, String month, String token) async {
  final url = Uri.parse('http://localhost:5000/api/budget/$userId/$month');
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
  });

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("Failed to load budget: ${response.body}");
    return null;
  }
}

Future<List<dynamic>> fetchExpenses(String userId, String token) async {
  final url = Uri.parse('http://localhost:5000/api/expense/$userId');
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
  });

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("Failed to load expenses: ${response.body}");
    return [];
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userId;
  String? token;
  double totalBudget = 0.0;
  double totalExpenses = 0.0;
  List<FlSpot> dailyExpenses = [];
  String outlookStatus = '';
  String outlookPercent = '';
  Color outlookColor = Colors.grey;
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    token = prefs.getString('token');

    if (userId != null && token != null) {
      final currentMonth = "${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}";

      final budgetData = await fetchBudget(userId!, currentMonth, token!);
      final expenseData = await fetchExpenses(userId!, token!);

      // double dailyTotal = 0.0;
      Map<int, double> dayTotals = {};
      for (var item in expenseData) {
        DateTime date;
        final rawDate = item['date'];

        if (rawDate is Map && rawDate.containsKey('\$date')) {
          date = DateTime.tryParse(rawDate['\$date']) ?? DateTime.now();
        } else if (rawDate is String) {
          date = DateTime.tryParse(rawDate) ?? DateTime.now();
        } else {
          date = DateTime.now();
        }
        int day = date.day;
        dayTotals[day] = (dayTotals[day] ?? 0) + (item['amount'] as num).toDouble();
      }
      List<FlSpot> graphData = dayTotals.entries
          .map((e) => FlSpot(e.key.toDouble(), e.value))
          .toList();
      graphData.sort((a, b) => a.x.compareTo(b.x));

      setState(() {
        totalBudget = (budgetData?['totalBudget'] ?? 0).toDouble();
        totalExpenses = expenseData.fold(0.0, (sum, item) => sum + (item['amount'] as num).toDouble());
        dailyExpenses = graphData;

        // 🌡️ Spending prediction logic
        final now = DateTime.now();
        final currentDay = now.day;
        final totalDaysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
        final expectedSpending = (totalBudget / totalDaysInMonth) * currentDay;
        final diff = totalExpenses - expectedSpending;
        final percentage = (diff / totalBudget) * 100;

        outlookStatus = percentage > 0 ? 'OVER\nSPENDING' : 'UNDER\nSPENDING';
        outlookColor = percentage > 0 ? Colors.red : Colors.green;
        outlookPercent = '${percentage.abs().toStringAsFixed(1)}%';
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    final Color scaffoldBgColor = Color(0xFFF0F2F5);
    final Color trackerTitleColor = Colors.grey.shade700;
    final Color welcomeTextColor = Colors.black;
    final Color primaryBlue = const Color(0xFF4A90E2);
    // final Color outlookCardColor = Color(0xFFE53935);
    final Color dailyQuotaCardColor = Colors.orange.shade700;
    final Color savingsCardColor = Colors.red.shade700;
    final Color graphBgColor = primaryBlue.withOpacity(0.1);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('TRACKER',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: trackerTitleColor,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
                    });
                    _loadDashboardData();
                  },
                ),
                Text(
                  "${_getMonthName(selectedMonth.month)} ${selectedMonth.year}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
                    });
                    _loadDashboardData();
                  },
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: welcomeTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildCard('Available Budget', 'Rp ${totalBudget.toStringAsFixed(0)}', primaryBlue, context),
                            const SizedBox(height: 12),
                            _buildCard('Total Expense', 'Rp ${totalExpenses.toStringAsFixed(0)}', primaryBlue, context),
                            const SizedBox(height: 12),
                            _buildCard('Avg per day', 'Rp ${(totalExpenses / DateTime.now().day).toStringAsFixed(0)}', primaryBlue, context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildOutlookCardNew(outlookPercent, outlookStatus, outlookColor, context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCard('Daily Quota Remaining', 'Rp ${(totalBudget / 30 - totalExpenses / DateTime.now().day).toStringAsFixed(0)}', dailyQuotaCardColor, context),
                  const SizedBox(height: 12),
                  _buildCard('Savings Prediction', 'Rp ${(totalBudget - totalExpenses).toStringAsFixed(0)}', savingsCardColor, context),
                  const SizedBox(height: 20),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: graphBgColor,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(show: false),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: dailyExpenses,
                            isCurved: true,
                            color: primaryBlue,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.home, color: Colors.black54),
                tooltip: 'Home',
                onPressed: () {},
              ),
              const SizedBox(width: 48),
              IconButton(
                icon: const Icon(Icons.receipt_long, color: Colors.black54),
                tooltip: 'Budgeting Page',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BudgetingPage()),
                  );
                  _loadDashboardData();
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExpensePage()),
          );
          _loadDashboardData();
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        foregroundColor: primaryBlue,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildCard(String title, String value, Color color, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 8),
          Text(value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlookCardNew(String percent, String status, Color bgColor, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(percent,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.info_outline, color: Colors.white, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(status,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

}
