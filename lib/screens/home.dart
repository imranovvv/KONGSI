import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> groupNames = [
      "Family 👪",
      "Housemates",
      "Travel",
      "Housemates",
      "Travel",
      "Housemates",
      "Travel",
      "Housemates",
      "Travel"
    ];

    return Scaffold(
      body: Align(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'My Groups',
                style: TextStyle(
                  fontSize: 24, // Adjust the font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Balance: ',
                  style: TextStyle(
                    fontSize: 16, // Adjust the font size as needed
                  ),
                ),
                Text(
                  'RM150',
                  style: TextStyle(
                    fontSize: 16, // Adjust the font size as needed
                    color: Colors.green, // Set the text color to green
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 16, bottom: 16),
              child: Center(
                child: CupertinoSearchTextField(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CupertinoScrollbar(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: groupNames.length,
                    itemBuilder: (context, index) {
                      Color tileColor =
                          index.isOdd ? const Color(0xffECECEC) : Colors.white;

                      return Card(
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          tileColor: tileColor,
                          trailing: const Icon(CupertinoIcons.forward),
                          title: Text(groupNames[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
