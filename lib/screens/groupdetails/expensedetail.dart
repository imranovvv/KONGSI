import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kongsi/components/appbar.dart';
import 'package:kongsi/screens/groupdetails/expenses.dart';

class ExpenseDetail extends StatefulWidget {
  final Expense expense;
  final String currencySymbol;

  const ExpenseDetail(this.expense, this.currencySymbol, {super.key});

  @override
  State<ExpenseDetail> createState() => _ExpenseDetailState();
}

class _ExpenseDetailState extends State<ExpenseDetail> {
  @override
  Widget build(BuildContext context) {
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
                  'This expense was paid by ${widget.expense.paidBy}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(widget.expense.date),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'People who are involved in this expense:',
              style: TextStyle(
                fontSize: 16,
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
                  return Column(
                    children: [
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(debtor),
                            Text(
                              '${widget.currencySymbol}${amountOwed.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 1.0, // Set the thickness of the divider
                        color: Colors.grey, // Set the divider color
                        height: 0.0, // You can adjust the height to add spacing
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
