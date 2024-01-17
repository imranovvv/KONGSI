import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kongsi/components/appbar.dart';
import 'dart:async';

class AddExpense extends StatefulWidget {
  final String groupId;
  final String title;
  final String paidBy;
  final String debtor;
  final double amount;
  final bool isReimbursement;

  const AddExpense({
    Key? key,
    required this.groupId,
    this.title = '',
    this.paidBy = '',
    this.debtor = '',
    this.amount = 0,
    this.isReimbursement = false,
  }) : super(key: key);

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  late DateTime selectedDate;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String? titleError;
  String? amountError;
  String? numericError;

  String? userName;
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
    fetchUserDataAndGroupMembers();

    if (widget.title.isNotEmpty) {
      titleController.text = widget.title;
    }
    if (widget.amount != 0) {
      amountController.text = widget.amount.toStringAsFixed(2);
    }

    amountController.addListener(_updateSplitAmount);
    amountController.addListener(_validateAmount);
  }

  void _validateAmount() {
    String amountText = amountController.text;
    double? amount = double.tryParse(amountText);
    if (amount == null && amountText.isNotEmpty) {
      setState(() => numericError = 'Enter numbers only');
    } else {
      setState(() => numericError = null);
    }
    _updateSplitAmount();
  }

  void _updateSplitAmount() {
    if (selectedMembers.isNotEmpty) {
      double amount = double.tryParse(amountController.text) ?? 0.0;
      setState(() {
        splitAmounts = amount > 0 ? amount / selectedMembers.length : 0.0;
      });
    }
  }

  @override
  void dispose() {
    amountController.removeListener(_updateSplitAmount);
    amountController.dispose();
    super.dispose();
    membersStreamController.close();
  }

  Future<void> fetchUserDataAndGroupMembers() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        var groupSnapshot = await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .get();

        var membersMap = groupSnapshot.data()?['members'];
        if (membersMap != null) {
          membersMap.forEach((name, uid) {
            if (uid == user.uid) {
              userName = name;
            }
          });
        }

        if (groupSnapshot.exists) {
          Map<String, dynamic>? data = groupSnapshot.data();
          if (data != null && data.containsKey('members')) {
            List<String> members =
                Map<String, dynamic>.from(data['members']).keys.toList();

            if (members.isNotEmpty) {
              setState(() {
                groupMembers = members;
                selectedPaidBy = (userName != null && members.contains(userName)
                    ? userName
                    : members.first)!;
                selectedMembers =
                    widget.debtor.isNotEmpty && members.contains(widget.debtor)
                        ? {widget.debtor}
                        : Set.from(members);

                for (double i = 0; i < members.length; i++) {
                  customAmountControllers[i] = TextEditingController(text: '0');
                }
              });
              _updateSplitAmount();

              membersStreamController.add(members);
            }
          } else {
            print('No members found in group.');
          }
        } else {
          print('Group not found.');
        }
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

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

  void showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => buildPicker(
        CupertinoDatePicker(
          initialDateTime: selectedDate,
          mode: CupertinoDatePickerMode.date,
          showDayOfWeek: true,
          dateOrder: DatePickerDateOrder.dmy,
          maximumDate: DateTime.now(),
          onDateTimeChanged: (newDate) => setState(() {
            selectedDate = newDate;
            dateController.text = formatDate(newDate);
          }),
        ),
      ),
    );
  }

  Widget buildPicker(Widget child) {
    return Container(
      height: 216,
      margin: const EdgeInsets.only(bottom: 0),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: SafeArea(top: false, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showLogoutButton: false,
        showDoneButton: false,
      ),
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
                    titleError,
                    TextInputType.text,
                  ),
                  const SizedBox(height: 20.0),
                  buildTextField(
                      amountController,
                      'Amount',
                      amountError,
                      const TextInputType.numberWithOptions(
                          signed: true, decimal: true)),
                  const SizedBox(height: 20.0),
                  buildDatePickerField(),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Paid By',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black,
                          )),
                    ),
                  ),
                  buildPaidByField(),
                  const SizedBox(height: 20.0),
                  buildMembersList(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 0, bottom: 20),
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

  Widget buildTextField(TextEditingController controller, String placeholder,
      String? errorMessage, TextInputType keyboardType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoTextField(
          decoration: textFieldDecoration(),
          placeholder: placeholder,
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        if (errorMessage != null ||
            (controller == amountController && numericError != null))
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Text(errorMessage ?? numericError ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

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

  Widget buildPaidByField() {
    return buildPickerContainer(
      CupertinoTextField(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        placeholder: 'Paid By',
        controller: TextEditingController(
          text: '$selectedPaidBy${selectedPaidBy == userName ? ' (me)' : ''}',
        ),
        readOnly: true,
        style: GoogleFonts.poppins(),
        onTap: showMemberPicker,
      ),
    );
  }

  Widget buildPickerContainer(Widget child) {
    return Container(
      decoration: textFieldDecoration(),
      child: child,
    );
  }

  Widget buildMembersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('For whom',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black,
                  )),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(
                  isCustomSplit ? 'Custom Split' : 'Equal Split',
                  style: GoogleFonts.poppins(
                    color: Colors.blue[800],
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10.0),
          child: widget.isReimbursement
              ? Text(
                  '${widget.paidBy} is paying \$${widget.amount.toStringAsFixed(2)} to settle his debt with ${widget.debtor}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Text(
                  'Tick members whom you are paying for',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
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
                bool isCheckboxEnabled = !widget.isReimbursement ||
                    member == widget.debtor; // Add this line

                return InkWell(
                  onTap: isCheckboxEnabled
                      ? () {
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
                        }
                      : null,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    title: Text(
                      '$member${member == userName ? ' (me)' : ''}', // Updated line
                      style: GoogleFonts.poppins(),
                    ),
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
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
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
                          onChanged: isCheckboxEnabled
                              ? (bool? value) {
                                  // Update this line
                                  setState(() {
                                    if (value == true) {
                                      selectedMembers.add(member);
                                    } else {
                                      selectedMembers.remove(member);
                                      customAmounts[member] = 0;
                                      customAmountControllers[index]?.text =
                                          '0';
                                    }
                                    _updateCustomAmount();
                                    _updateSplitAmount();
                                  });
                                }
                              : null,
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
    setState(() {
      titleError = titleController.text.isEmpty ? 'Title is required' : null;
      amountError = amountController.text.isEmpty ? 'Amount is required' : null;
      if (numericError != null) {
        amountError = numericError;
      }
    });

    if (titleError != null || amountError != null) {
      return;
    }
    String title = titleController.text;
    double amount = double.tryParse(amountController.text) ?? 0.0;
    String date = formatDateForFirestore(selectedDate);
    Map<String, double> debtors = {};

    if (isCustomSplit) {
      debtors = customAmounts;
    } else {
      for (var member in selectedMembers) {
        debtors[member] = splitAmounts;
      }
    }

    Map<String, dynamic> expenseData = {
      'title': title,
      'amount': amount,
      'date': date,
      'paidBy': selectedPaidBy,
      'debtors': debtors,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('expenses')
          .add(expenseData);

      if (mounted) Navigator.of(context).pop();

      print('Expense added successfully');
    } catch (e) {
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
