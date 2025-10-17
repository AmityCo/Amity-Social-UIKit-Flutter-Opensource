import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

abstract class CameraPermissionEvent extends Equatable {
  const CameraPermissionEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize camera and request permissions
class InitializeCameraRequested extends CameraPermissionEvent {
  final bool isVideoMode;

  const InitializeCameraRequested({required this.isVideoMode});

  @override
  List<Object?> get props => [isVideoMode];
}

/// Camera selected (initial or flip)
class CameraSelected extends CameraPermissionEvent {
  final CameraDescription camera;

  const CameraSelected({required this.camera});

  @override
  List<Object?> get props => [camera];
}

/// Flash toggled
class FlashToggled extends CameraPermissionEvent {
  const FlashToggled();
}

/// Camera flipped (front/back)
class CameraFlipped extends CameraPermissionEvent {
  const CameraFlipped();
}

/// Recording started
class RecordingStarted extends CameraPermissionEvent {
  const RecordingStarted();
}

/// Recording stopped
class RecordingStopped extends CameraPermissionEvent {
  const RecordingStopped();
}

/// Recheck permissions (after app resume)
class PermissionsRechecked extends CameraPermissionEvent {
  final bool isVideoMode;

  const PermissionsRechecked({required this.isVideoMode});

  @override
  List<Object?> get props => [isVideoMode];
}

/// Dialog shown event (to mark that settings dialog has been displayed)
class PermissionDialogShown extends CameraPermissionEvent {
  final bool isCamera; // true for camera, false for microphone

  const PermissionDialogShown({required this.isCamera});

  @override
  List<Object?> get props => [isCamera];
}

/// Camera controller initialization completed
class CameraControllerInitialized extends CameraPermissionEvent {
  final bool success;

  const CameraControllerInitialized({required this.success});

  @override
  List<Object?> get props => [success];
}

/// Permission error detected during camera initialization
class PermissionErrorDetected extends CameraPermissionEvent {
  final bool isCameraError; // true for camera, false for microphone
  final String errorCode;

  const PermissionErrorDetected({
    required this.isCameraError,
    required this.errorCode,
  });

  @override
  List<Object?> get props => [isCameraError, errorCode];
}
