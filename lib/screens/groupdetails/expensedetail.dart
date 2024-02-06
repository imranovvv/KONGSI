import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kongsi/components/appbar.dart';
import 'package:kongsi/screens/groupdetails/expenses.dart';

class ExpenseDetail extends StatefulWidget {
  final Expense expense;
  final String currencySymbol;
  final String userName;

  const ExpenseDetail(this.expense, this.currencySymbol, this.userName,
      {super.key});

  @override
  State<ExpenseDetail> createState() => _ExpenseDetailState();
}

class _ExpenseDetailState extends State<ExpenseDetail> {
  @override
  Widget build(BuildContext context) {
    String paidByDisplay = widget.expense.paidBy == widget.userName
        ? "${widget.expense.paidBy} (me)"
        : widget.expense.paidBy;

    return Scaffold(
      appBar: const CustomAppBar(
        showLogoutButton: false,
        showDoneButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              centerTitle: true,
              title: Text(
                widget.expense.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                '${widget.currencySymbol}${widget.expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paid by $paidByDisplay',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(widget.expense.date),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'People who are involved in this expense:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.expense.debtors.length,
                itemBuilder: (context, index) {
                  var debtor = widget.expense.debtors.keys.toList()[index];
                  var amountOwed =
                      widget.expense.debtors.values.toList()[index];
                  String displayName =
                      debtor == widget.userName ? "$debtor (me)" : debtor;
                  return Column(
                    children: [
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(displayName),
                            Text(
                              '${widget.currencySymbol}${amountOwed.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                        height: 0.0,
                      ),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> buildDebtorsList(Map<String, double> debtors) {
    return debtors.entries.map((entry) {
      return Text('${entry.key} owes \$${entry.value.toStringAsFixed(2)}');
    }).toList();
  }
}
