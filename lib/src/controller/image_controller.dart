import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
class ImageController {
  static const  String imageName = "mainLogo";
  static const String tempFolderName = "CineSyncPrinterManager";


  static Future<File?> downloadImage(String imageUrl) async {
    try {
      final directory = await getTemporaryDirectory();

      // Create a folder named 'images' inside the temporary directory
      final imagesFolder = Directory(path.join(directory.path, tempFolderName));
      if (!await imagesFolder.exists()) {
        imagesFolder.createSync();
      }

      final files = await imagesFolder.list().toList();
      final mainLogoFiles = files.where((file) => file.path.contains('/$imageName')).toList();

      for (final mainLogoFile in mainLogoFiles) {
        await mainLogoFile.delete();
        print('Existing mainlogo removed: ${mainLogoFile.path}');
      }

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        final file = File('${imagesFolder.path}/$imageName.jpg');
        await file.writeAsBytes(bytes);
        return file;
      } else {
        print('Failed to download the image. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading the image: $e');
      return null;
    }
  }

  static Future<File?> downloadImageAndDisplay(String imageUrl) async {
    File? imageFile = await downloadImage(imageUrl);
    return imageFile;
  }

  static Future<void> removeExistingMainLogo(String imageName) async {
    try {
      final directory = await getTemporaryDirectory();

      // Create a folder named 'images' inside the temporary directory
      final imagesFolder = Directory('${directory.path}/$tempFolderName');
      if (await imagesFolder.exists()) {
        final files = await imagesFolder.list().toList();
        final mainLogoFiles = files.where((file) => file.path.contains('/$imageName')).toList();

        for (final mainLogoFile in mainLogoFiles) {
          await mainLogoFile.delete();
          print('Existing mainlogo removed: ${mainLogoFile.path}');
        }

        if (mainLogoFiles.isEmpty) {
          print('No existing mainlogo files found. Nothing to remove.');
        }
      } else {
        print('No existing mainlogo folder found. Nothing to remove.');
      }
    } catch (e) {
      print('Error removing existing mainlogo: $e');
    }
  }
}