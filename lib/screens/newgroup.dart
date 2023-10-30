import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kongsi/components/appbar.dart';
import 'package:dropdown_search/dropdown_search.dart';

class NewGroup extends StatefulWidget {
  const NewGroup({super.key});

  @override
  State<NewGroup> createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final List<String> items = [];
  final TextEditingController textController = TextEditingController();

  void addMember(String name) {
    setState(() {
      items.add(name);
      textController.clear();
    });
  }

  void removeMember(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showLogoutButton: false),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.width * 0.1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff10416d),
                  elevation: 0,
                ),
                onPressed: () {},
                child: const Text(
                  "Save",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          AppBar(
            centerTitle: true,
            title: const Text(
              'New Group',
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
                    controller: nameController,
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
                    placeholder: 'Description',
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    clearButtonMode: OverlayVisibilityMode.editing,
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    height: 40,
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
                    child: DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        constraints: const BoxConstraints.tightFor(
                          height: 300,
                        ),
                        showSearchBox: true,
                        searchDelay: Duration.zero,
                        showSelectedItems: true,
                        containerBuilder: (ctx, popupWidget) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: popupWidget,
                          );
                        },
                      ),
                      items: const [
                        "MYR",
                        "USD",
                        "EUR",
                      ],
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "Select currency",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 16, top: 3),
                        ),
                      ),
                      onChanged: print,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length + 1,
                      itemBuilder: (context, index) {
                        if (index < items.length) {
                          return ListTile(
                            contentPadding: const EdgeInsets.only(left: 20.0),
                            title: Text(items[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                removeMember(index);
                              },
                            ),
                          );
                        } else {
                          return ListTile(
                            contentPadding: const EdgeInsets.only(left: 20.0),
                            title: TextField(
                              controller: textController,
                              decoration: const InputDecoration(
                                hintText: 'Enter name', // Add hint text here
                              ),
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(30.0),
                              //   color: Colors.white,
                              // ),
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.only(
                                  right: 0.0), // Adjust the padding value here
                              child: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  addMember(textController.text);
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _customPopupItemBuilder(
    BuildContext context, dynamic item, bool isSelected) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8),
    decoration: !isSelected
        ? null
        : BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
    child: ListTile(
      title: Text(item.toString(),
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 102, 100, 100),
          )),
    ),
  );
}
