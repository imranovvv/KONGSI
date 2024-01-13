import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kongsi/components/appbar.dart';
import 'package:share_plus/share_plus.dart';

class NewGroupSuccess extends StatelessWidget {
  final String groupId;
  const NewGroupSuccess({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showLogoutButton: false,
        showDoneButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.checkmark_circle_fill,
                size: 50.0, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Group created successfully!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildJoinButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    return Builder(builder: (context) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff10416d),
          elevation: 0,
        ),
        onPressed: () => _onShare(context),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.share, size: 20.0),
            SizedBox(width: 8.0),
            Text('Send Invitation'),
          ],
        ),
      );
    });
  }

  void _onShare(BuildContext context) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;

    await Share.share(
      'Enter the following code to join the group: $groupId',
      subject: 'Kongsi Group Invitation',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
