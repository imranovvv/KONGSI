import 'package:flutter/material.dart';
import 'package:kongsi/components/appbar.dart';

class JoinGroup extends StatefulWidget {
  const JoinGroup({super.key});

  @override
  State<JoinGroup> createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  List<String> items = [];
  TextEditingController textController = TextEditingController();

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
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
            Padding(
              padding:
                  const EdgeInsets.all(16.0), // Adjust the padding as needed
              child: ElevatedButton(
                onPressed: () {
                  // Add your save action here
                },
                child: Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
