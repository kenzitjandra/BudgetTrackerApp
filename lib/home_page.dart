import 'package:flutter/material.dart';
import 'budgeting_page.dart'; // Make sure this path is correct
<<<<<<< HEAD
import 'expense_page.dart';
=======
>>>>>>> 3a997454ddeae1766d309707226a4795d6202e90

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define colors based on the new design
    final Color scaffoldBgColor = Color(0xFFF0F2F5); // Light greyish-blue
    final Color trackerTitleColor = Colors.grey.shade700;
    final Color welcomeTextColor = Colors.black;
    final Color blueCardColor =
        Colors.blue.shade600; // A slightly more vibrant blue
    final Color outlookCardColor = Color(0xFFE53935); // A strong reddish-pink
    final Color dailyQuotaCardColor = Colors.orange.shade700;
    final Color savingsCardColor = Colors.red.shade700;
    final Color graphBgColor = Colors.blue.shade50;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        toolbarHeight: 70, // Adjusted height
        backgroundColor:
            Colors.transparent, // Transparent to show scaffold background
        elevation: 0,
        centerTitle: true,
        title: Text(
          'TRACKER',
          style: TextStyle(
            fontSize: 16, // Smaller AppBar title
            fontWeight: FontWeight.bold,
            color: trackerTitleColor,
            letterSpacing: 1.5, // Added letter spacing
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white, // White background for avatar
              child: Icon(Icons.person, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ), // No top padding as AppBar is there
        child: Column(
          children: [
            // Main content card
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
                  Text(
                    'Welcome, Gill',
                    style: TextStyle(
                      fontSize: 26, // Larger welcome text
                      fontWeight: FontWeight.bold,
                      color: welcomeTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Row for (Column of 3 cards) and (Outlook card)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5, // Give more space to the column of 3 cards
                        child: Column(
                          children: [
                            _buildCard(
                              'Available Budget',
                              'Rp 1.000.000,00',
                              blueCardColor,
                              context,
                            ),
                            const SizedBox(height: 12),
                            _buildCard(
                              'Total Expense',
                              'Rp 1.000.000,00',
                              blueCardColor,
                              context,
                            ),
                            const SizedBox(height: 12),
                            _buildCard(
                              'Avg per day',
                              'Rp 1.000.000,00',
                              blueCardColor,
                              context,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex:
                            3, // Less space for outlook, but it needs to be tall
                        child: _buildOutlookCardNew(
                          "-2%",
                          "OVER\nSPENDING",
                          outlookCardColor,
                          context,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    'Daily Quota Remaining',
                    'Rp 70.000,00',
                    dailyQuotaCardColor,
                    context,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    'Savings Prediction',
                    'Rp -30.000,00',
                    savingsCardColor,
                    context,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: graphBgColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Spending Graph Placeholder',
                      style: TextStyle(color: Colors.blueGrey.shade400),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar and FAB remain unchanged from previous version
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              offset: const Offset(0, -3),
              blurRadius: 5.0,
            ),
          ],
        ),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          clipBehavior: Clip.antiAlias,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BudgetingPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
<<<<<<< HEAD
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExpensePage()),
          );
        },
        child: const Icon(Icons.add),
=======
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('FAB Tapped: Add New Transaction (Placeholder)'),
            ),
          );
        },
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade800,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add, size: 30),
>>>>>>> 3a997454ddeae1766d309707226a4795d6202e90
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Updated _buildCard to remove its own bottom margin, spacing handled by parent
  Widget _buildCard(
    String title,
    String value,
    Color color,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity, // Make card take full width available from parent
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16), // Slightly more rounded
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18, // Slightly larger value text
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // New Outlook card to fit the design
  Widget _buildOutlookCardNew(
    String percent,
    String status,
    Color bgColor,
    BuildContext context,
  ) {
    // This card needs to be tall enough to roughly match the 3 stacked cards.
    // We achieve this by ensuring its content has enough vertical presence.
    return Container(
      // height: 234, // Optionally set a fixed height if flex layout is tricky
      // The height of 3 blue cards: 3 * (14+8+18+32_padding) = 3 * 72 = 216. Plus 2 * 12 spacing = 24. Total = 240
      // Let's use internal padding and SizedBox to make it naturally tall
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 20,
      ), // Adjusted padding
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10), // Pushes content down a bit
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                percent,
                style: const TextStyle(
                  fontSize: 26, // Larger percentage
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.info_outline,
                color: Colors.white.withOpacity(0.85),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 10), // Flexible spacing
          Text(
            status,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13, // Adjusted font size
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20), // Pushes content up a bit from bottom
          // Added SizedBox to help with vertical stretching if wrapped in Expanded
        ],
      ),
    );
  }
}
