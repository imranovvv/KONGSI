import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kongsi/components/appbar.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  TextEditingController expenseNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController textController = TextEditingController();
  TextEditingController selectedValueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showLogoutButton: false),
      body: Column(
        children: [
          AppBar(
            centerTitle: true,
            title: const Text(
              'New Expense',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
              child: Column(
                children: [
                  CupertinoTextField(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey, // You can set the shadow color
                          offset:
                              Offset(0, 1), // Specify the offset of the shadow
                          blurRadius: 4, // Specify the blur radius
                        ),
                      ],
                    ),
                    placeholder: 'Title',
                    controller: expenseNameController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.poppins(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  const SizedBox(height: 20.0),
                  CupertinoTextField(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey, // You can set the shadow color
                          offset:
                              Offset(0, 1), // Specify the offset of the shadow
                          blurRadius: 4, // Specify the blur radius
                        ),
                      ],
                    ),
                    placeholder: 'Amount',
                    controller: amountController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.poppins(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
