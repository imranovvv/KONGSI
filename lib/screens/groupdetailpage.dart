import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kongsi/components/appbar.dart';
import 'package:kongsi/screens/groupdetails/addexpense.dart';
import 'package:kongsi/screens/groupdetails/balances.dart';
import 'package:kongsi/screens/groupdetails/expenses.dart';
import 'package:kongsi/screens/groupdetails/transactions.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupName;

  const GroupDetailPage({super.key, required this.groupName});

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          backgroundColor: const Color(0xff10416d),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    const AddExpense(), // Replace with the actual name of your AddExpense page class
              ),
            );
            print('FAB button pressed');
          },
          child: const Icon(Icons.add),
        ),
      ),
      appBar: const CustomAppBar(showLogoutButton: false),
      body: Column(
        children: [
          AppBar(
            centerTitle: true,
            title: Text(
              widget.groupName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: const Color(0xffb2c3d1),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Tab(
                      child: Column(
                        children: [
                          Text('Expenses'),
                          Icon(
                            Icons.attach_money, // Add your icon here
                            size: 20, // Adjust the size as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Tab(
                      child: Column(
                        children: [
                          Text('Balances'),
                          Icon(
                            Icons.account_balance, // Add your icon here
                            size: 20, // Adjust the size as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: Tab(
                      child: Column(
                        children: [
                          Text('Transactions'),
                          Icon(
                            Icons.swap_horiz, // Add your icon here
                            size: 20, // Adjust the size as needed
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                Expenses(),
                Balances(),
                Transactions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
