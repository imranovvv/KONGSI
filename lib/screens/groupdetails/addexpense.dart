import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kongsi/components/appbar.dart';

class AddExpense extends StatefulWidget {
  final String groupId;

  const AddExpense({super.key, required this.groupId});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  TextEditingController expenseNameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController textController = TextEditingController();
  TextEditingController selectedValueController = TextEditingController();
  DateTime date = DateTime.now();

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

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
                    decoration: _textFieldDecoration(),
                    placeholder: 'Title',
                    controller: expenseNameController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.poppins(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  const SizedBox(height: 20.0),
                  CupertinoTextField(
                    decoration: _textFieldDecoration(),
                    placeholder: 'Amount',
                    controller: amountController,
                    keyboardType: TextInputType.text,
                    style: GoogleFonts.poppins(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  const SizedBox(height: 20.0),
                  CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                    onPressed: () => _showDialog(
                      CupertinoTextField(
                        placeholder: 'Date',
                        controller: selectedValueController,
                        readOnly: true,
                        onTap: () => _showDialog(
                          CupertinoDatePicker(
                            initialDateTime: date,
                            mode: CupertinoDatePickerMode.date,
                            showDayOfWeek: true,
                            onDateTimeChanged: (DateTime newDate) {
                              setState(() {
                                date = newDate;
                                selectedValueController.text =
                                    '${date.day}/${date.month}/${date.year}';
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    child: _cupertinoButtonContainer(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _textFieldDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(5.0),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(
          color: Colors.grey,
          offset: Offset(0, 1),
          blurRadius: 4,
        ),
      ],
    );
  }

  Container _cupertinoButtonContainer() {
    return Container(
      decoration: _textFieldDecoration(),
      child: CupertinoTextField(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        placeholder: 'Date',
        controller: selectedValueController,
        readOnly: true,
        style: GoogleFonts.poppins(),
        onTap: () => _showDialog(
          CupertinoDatePicker(
            initialDateTime: date,
            mode: CupertinoDatePickerMode.date,
            showDayOfWeek: true,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                date = newDate;
                selectedValueController.text =
                    '${date.day}/${date.month}/${date.year}';
              });
            },
          ),
        ),
      ),
    );
  }
}
