import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../model/card_model.dart';
import '../controller/image_controller.dart';
import 'HomeScreen.dart';
import 'alerts.dart';

class SettingsScreen extends StatelessWidget {
  final Box box;
  const SettingsScreen({super.key, required this.box});

  @override
  Widget build(BuildContext context) {
    void showEditCardDialog(BuildContext context, dynamic key, Map cardMap) async {
      final card = CardModel.fromMap(cardMap);
      final imageController = ImageController();
      final result = await showCardInputDialog(
        context: context,
        title: 'Edit Card',
        initialName: card.name,
        initialCode: card.code,
        initialImage: card.image != null && card.image!.isNotEmpty ? XFile(card.image!) : null,
        isPickingImage: imageController.isPickingImage,
        pickImage: imageController.pickImage,
        cropImage: imageController.cropImage,
      );
      if (result != null) {
        box.put(key, CardModel(
          name: result['name'],
          code: result['code'],
          date: card.date,
          image: result['image']).toMap());
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SettingsScreen(box: box)));
      }
    }

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
                  onDelete: () async {
                    final confirm = await showDeleteConfirmationDialog(context);
                    if (confirm == true) {
                      box.delete(key);
                      (context as Element).markNeedsBuild();
                    }
                  },
                  forceDeleteIcon: true,
                  onEdit: () {
                    showEditCardDialog(context, key, card);
                  },
                );
              },
            ),
    );
  }
}