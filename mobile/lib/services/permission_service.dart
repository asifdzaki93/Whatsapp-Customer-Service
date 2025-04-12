import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> checkAndRequestPermissions() async {
    final storage = await Permission.storage.status;
    final camera = await Permission.camera.status;
    final microphone = await Permission.microphone.status;

    if (!storage.isGranted || !camera.isGranted || !microphone.isGranted) {
      final storageResult = await requestStoragePermission();
      final cameraResult = await requestCameraPermission();
      final microphoneResult = await requestMicrophonePermission();

      return storageResult && cameraResult && microphoneResult;
    }

    return true;
  }
}
