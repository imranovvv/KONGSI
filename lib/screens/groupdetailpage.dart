import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kongsi/components/appbar.dart';
import 'package:kongsi/screens/groupdetails/addexpense.dart';
import 'package:kongsi/screens/groupdetails/balances.dart';
import 'package:kongsi/screens/groupdetails/expenses.dart';
import 'package:kongsi/screens/groupdetails/transactions.dart';
import 'package:share_plus/share_plus.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupName;
  final String groupId;

  const GroupDetailPage(
      {super.key, required this.groupName, required this.groupId});

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

  void _onShare(BuildContext context) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;

    await Share.share(
      'Enter the following code to join the group:  ${widget.groupId}',
      subject: 'Kongsi Group Invitation',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        _onShare(context);
        break;
      case 1:
        // Action for Option 2
        break;
      case 2:
        // Action for Option 3
        break;
    }
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
                builder: (context) => AddExpense(
                  groupId: widget.groupId,
                  debtors: const {},
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
      appBar: const CustomAppBar(
        showLogoutButton: false,
        showDoneButton: false,
      ),
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
            actions: [
              PopupMenuButton(
                onSelected: (item) => onSelected(context, item),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 0,
                    child: Text(
                      'Share code',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ],
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
                labelPadding: EdgeInsets.zero,
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
                            Icons.attach_money,
                            size: 20,
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
                            Icons.account_balance,
                            size: 20,
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
                            Icons.swap_horiz,
                            size: 20,
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
              children: [
                Expenses(groupId: widget.groupId),
                Balances(groupId: widget.groupId),
                Transactions(groupId: widget.groupId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
