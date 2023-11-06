import 'package:flutter/material.dart';

class GroupDetailPage extends StatelessWidget {
  final String groupName;

  const GroupDetailPage({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName), // Display the group name in the app bar
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Group Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Group Name: $groupName', // Display the group name
                style: TextStyle(fontSize: 18),
              ),
              // Add more group details here as needed
            ],
          ),
        ),
      ),
    );
  }
}
