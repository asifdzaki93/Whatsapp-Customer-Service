import 'package:image_picker/image_picker.dart';

class UploadFile {
  final String path;
  final String name;
  final String mediaType;

  UploadFile({required this.path, required this.name, required this.mediaType});

  factory UploadFile.fromXFile(XFile file) {
    return UploadFile(
      path: file.path,
      name: file.name,
      mediaType: _getMediaType(file.name),
    );
  }

  static String _getMediaType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'image';
      case 'mp4':
      case 'mov':
      case 'avi':
        return 'video';
      case 'mp3':
      case 'wav':
      case 'ogg':
        return 'audio';
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
        return 'document';
      default:
        return 'other';
    }
  }
}
