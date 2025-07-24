import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'HomeScreen.dart';

class SettingsScreen extends StatelessWidget {
  final Box box;
  const SettingsScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: box.isEmpty
          ? Center(child: Text('No cards yet.'))
          : ListView.builder(
              itemCount: box.length,
              itemBuilder: (_, i) {
                final key = box.keyAt(i);
                final card = box.get(key);
                return FlippableCard(
                  card: card,
                  isFlipped: true,
                  onTap: () {}, // No flip/close on settings
                  onDelete: () {
                    box.delete(key);
                    (context as Element).markNeedsBuild();
                  },
                  forceDeleteIcon: true,
                );
              },
            ),
    );
  }
}
