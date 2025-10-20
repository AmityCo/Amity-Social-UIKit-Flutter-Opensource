import 'package:equatable/equatable.dart';

enum CameraPermissionStatus {
  notDetermined,
  checking,
  denied,
  permanentlyDenied,
  granted,
}

enum CameraInitializationStatus {
  notInitialized,
  initializing,
  initialized,
  error,
}

class CameraPermissionState extends Equatable {
  final CameraPermissionStatus cameraPermission;
  final CameraPermissionStatus microphonePermission;
  final CameraInitializationStatus initState;
  final bool isRecording;
  final bool isFlashOn;
  final bool isBackCamera;
  final String? errorMessage;
  final bool shouldShowCameraDialog;
  final bool shouldShowMicrophoneDialog;
  final bool hasShownCameraDialog; // Track if dialog was already shown
  final bool hasShownMicDialog; // Track if dialog was already shown

  const CameraPermissionState({
    this.cameraPermission = CameraPermissionStatus.notDetermined,
    this.microphonePermission = CameraPermissionStatus.notDetermined,
    this.initState = CameraInitializationStatus.notInitialized,
    this.isRecording = false,
    this.isFlashOn = false,
    this.isBackCamera = true,
    this.errorMessage,
    this.shouldShowCameraDialog = false,
    this.shouldShowMicrophoneDialog = false,
    this.hasShownCameraDialog = false,
    this.hasShownMicDialog = false,
  });

  CameraPermissionState copyWith({
    CameraPermissionStatus? cameraPermission,
    CameraPermissionStatus? microphonePermission,
    CameraInitializationStatus? initState,
    bool? isRecording,
    bool? isFlashOn,
    bool? isBackCamera,
    String? errorMessage,
    bool? shouldShowCameraDialog,
    bool? shouldShowMicrophoneDialog,
    bool? hasShownCameraDialog,
    bool? hasShownMicDialog,
    bool clearError = false,
    bool clearDialogs = false,
  }) {
    return CameraPermissionState(
      cameraPermission: cameraPermission ?? this.cameraPermission,
      microphonePermission: microphonePermission ?? this.microphonePermission,
      initState: initState ?? this.initState,
      isRecording: isRecording ?? this.isRecording,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isBackCamera: isBackCamera ?? this.isBackCamera,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      shouldShowCameraDialog: clearDialogs ? false : (shouldShowCameraDialog ?? this.shouldShowCameraDialog),
      shouldShowMicrophoneDialog: clearDialogs ? false : (shouldShowMicrophoneDialog ?? this.shouldShowMicrophoneDialog),
      hasShownCameraDialog: hasShownCameraDialog ?? this.hasShownCameraDialog,
      hasShownMicDialog: hasShownMicDialog ?? this.hasShownMicDialog,
    );
  }

  bool get canCapture {
    return cameraPermission == CameraPermissionStatus.granted &&
           initState == CameraInitializationStatus.initialized;
  }

  bool get canCaptureVideo {
    return canCapture && microphonePermission == CameraPermissionStatus.granted;
  }

  @override
  List<Object?> get props => [
        cameraPermission,
        microphonePermission,
        initState,
        isRecording,
        isFlashOn,
        isBackCamera,
        errorMessage,
        shouldShowCameraDialog,
        shouldShowMicrophoneDialog,
        hasShownCameraDialog,
        hasShownMicDialog,
      ];
}
