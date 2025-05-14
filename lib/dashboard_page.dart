import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Dashboard'),
        backgroundColor: Color(0xFF3E5BFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: token == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back!',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Your Token:', style: TextStyle(color: Colors.grey)),
                  Text(
                    token ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: Colors.green.shade100,
                    child: ListTile(
                      title: Text("Balance"),
                      subtitle: Text("\$5,400.00",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Recent Transactions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          leading: Icon(Icons.fastfood),
                          title: Text("McDonald's"),
                          trailing: Text("-\$12.50"),
                        ),
                        ListTile(
                          leading: Icon(Icons.shopping_cart),
                          title: Text("Groceries"),
                          trailing: Text("-\$60.00"),
                        ),
                        ListTile(
                          leading: Icon(Icons.attach_money),
                          title: Text("Freelance Payment"),
                          trailing: Text("+\$300.00"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
