import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class NewGroupSuccess extends StatelessWidget {
  const NewGroupSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Created'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Group Created',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () => _onShare(context),
                  child: const Text('Send Invitation'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onShare(BuildContext context) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;

    await Share.share(
      'Check out our new group!',
      subject: 'Group Invitation',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
