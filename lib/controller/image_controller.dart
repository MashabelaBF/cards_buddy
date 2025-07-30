import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageController {
  bool _isPickingImage = false;

  bool get isPickingImage => _isPickingImage;

  Future<XFile?> pickImage(ImageSource source) async {
    if (_isPickingImage) return null;
    _isPickingImage = true;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    _isPickingImage = false;
   
    return image;
  }

  Future<XFile?> cropImage(XFile image) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );
    if (cropped != null) {
      return XFile(cropped.path);
    }
    return null;
  }
}
