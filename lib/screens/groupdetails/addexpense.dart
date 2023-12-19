import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kongsi/components/appbar.dart';
import 'dart:async';

class AddExpense extends StatefulWidget {
  final String groupId;

  const AddExpense({Key? key, required this.groupId}) : super(key: key);

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  late DateTime selectedDate;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  late List<String> groupMembers;
  String selectedPaidBy = '';
  StreamController<List<String>> membersStreamController =
      StreamController<List<String>>();
  Set<String> selectedMembers = {};
  bool isCustomSplit = false;
  double splitAmounts = 0.0;
  Map<String, double> customAmounts = {};
  Map<double, TextEditingController> customAmountControllers = {};

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    dateController.text = formatDate(selectedDate);
    fetchGroupMembers();
    amountController.addListener(_updateSplitAmount);
  }

  void _updateSplitAmount() {
    double amount = double.tryParse(amountController.text) ?? 0.0;
    setState(() {
      splitAmounts = (selectedMembers.isNotEmpty && amount > 0)
          ? amount / selectedMembers.length
          : 0.0;
    });
  }

  @override
  void dispose() {
    amountController.removeListener(_updateSplitAmount);
    amountController.dispose();
    super.dispose();
    membersStreamController.close(); // Close the stream controller
  }

  void fetchGroupMembers() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('members')) {
          List<String> members =
              Map<String, dynamic>.from(data['members']).keys.toList();
          if (members.isNotEmpty) {
            setState(() {
              groupMembers = members;
              selectedPaidBy = members.first;
              selectedMembers = Set.from(members);
              for (double i = 0; i < members.length; i++) {
                customAmountControllers[i] = TextEditingController(text: '0');
              }
            });
            membersStreamController.add(members);
          }
        } else {
          print('No members found in group.');
        }
      } else {
        print('Group not found.');
      }
    } catch (error) {
      print('Error fetching group data: $error');
    }
  }

  // Show Cupertino picker for member selection
  void showMemberPicker() {
    int initialIndex = groupMembers.indexOf(selectedPaidBy);
    showCupertinoModalPopup(
      context: context,
      builder: (context) => buildPicker(
        CupertinoPicker(
          itemExtent: 40.0,
          scrollController:
              FixedExtentScrollController(initialItem: initialIndex),
          onSelectedItemChanged: (index) =>
              setState(() => selectedPaidBy = groupMembers[index]),
          children: groupMembers
              .map((member) => Center(
                  child: Text(member, style: const TextStyle(fontSize: 20.0))))
              .toList(),
        ),
      ),
    );
  }

  // Show Cupertino picker for date selection
  void showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => buildPicker(
        CupertinoDatePicker(
          initialDateTime: selectedDate,
          mode: CupertinoDatePickerMode.date,
          showDayOfWeek: true,
          dateOrder: DatePickerDateOrder.dmy,
          onDateTimeChanged: (newDate) => setState(() {
            selectedDate = newDate;
            dateController.text = formatDate(newDate);
          }),
        ),
      ),
    );
  }

  // Builds the picker with a given child
  Widget buildPicker(Widget child) {
    return Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(top: false, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showLogoutButton: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              centerTitle: true,
              title: const Text('New Expense',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  buildTextField(
                    titleController,
                    'Title',
                    TextInputType.text,
                  ),
                  const SizedBox(height: 20.0),
                  buildTextField(
                    amountController,
                    'Amount',
                    TextInputType.number,
                  ),
                  const SizedBox(height: 20.0),
                  buildDatePickerField(),
                  const SizedBox(height: 20.0),
                  buildPaidByField(),
                  const SizedBox(height: 20.0),
                  buildMembersList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 20, bottom: 20),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.05,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: const Color(0xff10416d),
                  onPressed: _saveExpense,
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Builds a text field for the form
  Widget buildTextField(TextEditingController controller, String placeholder,
      TextInputType keyboardType) {
    return CupertinoTextField(
      decoration: textFieldDecoration(),
      placeholder: placeholder,
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  // Builds the date picker field
  Widget buildDatePickerField() {
    return buildPickerContainer(
      CupertinoTextField(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        placeholder: 'Date',
        controller: dateController,
        readOnly: true,
        style: GoogleFonts.poppins(),
        onTap: showDatePicker,
      ),
    );
  }

  // Builds the member picker field
  Widget buildPaidByField() {
    return buildPickerContainer(
      CupertinoTextField(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        placeholder: 'Paid By',
        controller: TextEditingController(text: selectedPaidBy),
        readOnly: true,
        style: GoogleFonts.poppins(),
        onTap: showMemberPicker,
      ),
    );
  }

  // Builds a container for picker fields
  Widget buildPickerContainer(Widget child) {
    return Container(
      decoration: textFieldDecoration(),
      child: child,
    );
  }

  // Builds the members list with share of expense displayed next to checkboxes
  Widget buildMembersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Debtors',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black,
                  )),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(
                  isCustomSplit ? 'Custom Split' : 'Equal Split',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isCustomSplit = !isCustomSplit;
                    if (!isCustomSplit) {
                      customAmounts.clear();
                      for (var controller in customAmountControllers.values) {
                        controller.text = '0';
                      }
                      amountController.clear();
                    }
                  });
                },
              ),
            ],
          ),
        ),
        StreamBuilder<List<String>>(
          stream: membersStreamController.stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child:
                      Text('No members found', style: GoogleFonts.poppins()));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                String member = snapshot.data![index];
                bool isSelected = selectedMembers.contains(member);

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (!isSelected) {
                        selectedMembers.add(member);
                      } else {
                        selectedMembers.remove(member);
                        customAmounts[member] = 0;
                        customAmountControllers[index]?.text = '0';
                      }
                      _updateCustomAmount();
                      _updateSplitAmount();
                    });
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    title: Text(member, style: GoogleFonts.poppins()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        isCustomSplit
                            ? SizedBox(
                                width: 80,
                                height: 30,
                                child: TextField(
                                  controller: customAmountControllers[index],
                                  onTap: () => customAmountControllers[index]
                                          ?.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset:
                                              customAmountControllers[index]!
                                                  .value
                                                  .text
                                                  .length),
                                  enabled: isSelected,
                                  enableInteractiveSelection: false,
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    double val = double.tryParse(value) ?? 0.0;
                                    setState(() {
                                      customAmounts[member] = val;
                                      _updateCustomAmount();
                                    });
                                  },
                                ),
                              )
                            : Text(
                                isSelected
                                    ? '\$${splitAmounts.toStringAsFixed(2)}'
                                    : '\$0.00',
                              ),
                        CupertinoCheckbox(
                          value: isSelected,
                          activeColor: const Color(0xff10416d),
                          checkColor: Colors.white,
                          inactiveColor: const Color(0xff10416d),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedMembers.add(member);
                              } else {
                                selectedMembers.remove(member);
                                customAmounts[member] = 0;
                                customAmountControllers[index]?.text = '0';
                              }
                              _updateCustomAmount();
                              _updateSplitAmount();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _updateCustomAmount() {
    if (isCustomSplit) {
      double total =
          customAmounts.values.fold(0.0, (sum, element) => sum + element);
      setState(() {
        amountController.text = total.toStringAsFixed(2);
      });
    }
  }

  Future<void> _saveExpense() async {
    String title = titleController.text;
    double amount = double.tryParse(amountController.text) ?? 0.0;
    String date = formatDateForFirestore(selectedDate);
    Map<String, double> debtors = {};

    // Prepare the debtors map
    if (isCustomSplit) {
      debtors = customAmounts;
    } else {
      selectedMembers.forEach((member) {
        debtors[member] = splitAmounts;
      });
    }

    // Create a map of data to send
    Map<String, dynamic> expenseData = {
      'title': title,
      'amount': amount,
      'date': date,
      'paidBy': selectedPaidBy,
      'debtors': debtors,
    };

    try {
      // Sending data to Firestore, to a subcollection within 'groups'
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('expenses')
          .add(expenseData);

      // Show a success message or navigate away
      print('Expense added successfully');
    } catch (e) {
      // Handle any errors here
      print('Error adding expense: $e');
    }
  }

  BoxDecoration textFieldDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(5.0),
      color: Colors.white,
      boxShadow: const [
        BoxShadow(color: Colors.grey, offset: Offset(0, 1), blurRadius: 4)
      ],
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatDateForFirestore(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
