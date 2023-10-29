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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(showLogoutButton: false),
      body: Column(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                child: Column(
                  children: [
                    CupertinoTextField(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.white,
                      ),
                      placeholder: 'Title',
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      // clearButtonMode: OverlayVisibilityMode.editing,
                      style: GoogleFonts.poppins(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                    ),
                    const SizedBox(height: 20.0),
                    CupertinoTextField(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.white,
                      ),
                      placeholder: 'Description',
                      controller: emailController,
                      keyboardType: TextInputType.text,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6), // Adjust the horizontal padding here
                      clearButtonMode: OverlayVisibilityMode.editing,
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white,
                      ),
                      child: DropdownSearch<String>(
                        popupProps: PopupProps.menu(
                          constraints: const BoxConstraints.tightFor(
                            height: 300,
                          ),
                          showSearchBox: true,
                          searchDelay: Duration.zero,
                          showSelectedItems: true,
                          // disabledItemFn: (String s) => s.startsWith('I'),
                          // itemBuilder: _customPopupItemBuilder,
                          containerBuilder: (ctx, popupWidget) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(
                                    30.0), // Adjust the radius as needed
                              ),
                              child: popupWidget,
                            );
                          },
                        ),
                        items: const [
                          "Brazil",
                          "Italia (Disabled)",
                          "Tunisia",
                          'Canada',
                          'Canadaa',
                          'Canadaaa',
                          'Canadaaaa',
                        ],
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: "Select country",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 16, top: 3),
                          ),
                        ),
                        onChanged: print,
                        // selectedItem: "Brazil",
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
