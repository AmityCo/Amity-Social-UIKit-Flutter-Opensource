import 'dart:async';
import 'package:amity_uikit_beta_service/v4/social/story/create/bloc/camera_permission_event.dart';
import 'package:amity_uikit_beta_service/v4/social/story/create/bloc/camera_permission_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPermissionBloc extends Bloc<CameraPermissionEvent, CameraPermissionState> {
  CameraPermissionBloc() : super(const CameraPermissionState()) {
    on<InitializeCameraRequested>(_onInitializeCameraRequested);
    on<CameraSelected>(_onCameraSelected);
    on<FlashToggled>(_onFlashToggled);
    on<CameraFlipped>(_onCameraFlipped);
    on<RecordingStarted>(_onRecordingStarted);
    on<RecordingStopped>(_onRecordingStopped);
    on<PermissionsRechecked>(_onPermissionsRechecked);
    on<PermissionDialogShown>(_onDialogShown);
    on<CameraControllerInitialized>(_onCameraControllerInitialized);
    on<PermissionErrorDetected>(_onPermissionErrorDetected);
  }

  Future<void> _onInitializeCameraRequested(
    InitializeCameraRequested event,
    Emitter<CameraPermissionState> emit,
  ) async {
    // Following old implementation pattern:
    // Assume permissions granted and let camera controller handle the actual permission requests
    // The camera package will show native iOS permission dialogs automatically
    emit(state.copyWith(
      cameraPermission: CameraPermissionStatus.granted,
      microphonePermission: CameraPermissionStatus.granted,
      clearDialogs: true,
    ));
  }

  Future<void> _onCameraSelected(
    CameraSelected event,
    Emitter<CameraPermissionState> emit,
  ) async {
    // Set initializing state
    emit(state.copyWith(
      initState: CameraInitializationStatus.initializing,
    ));
    
    // Note: Actual camera controller initialization is handled by widget
    // Widget will call CameraControllerInitialized event when done
  }

  Future<void> _onCameraControllerInitialized(
    CameraControllerInitialized event,
    Emitter<CameraPermissionState> emit,
  ) async {
    emit(state.copyWith(
      initState: event.success 
          ? CameraInitializationStatus.initialized 
          : CameraInitializationStatus.error,
      errorMessage: event.success ? null : 'Failed to initialize camera',
      clearError: event.success,
    ));
  }

  Future<void> _onFlashToggled(
    FlashToggled event,
    Emitter<CameraPermissionState> emit,
  ) async {
    emit(state.copyWith(isFlashOn: !state.isFlashOn));
  }

  Future<void> _onCameraFlipped(
    CameraFlipped event,
    Emitter<CameraPermissionState> emit,
  ) async {
    emit(state.copyWith(isBackCamera: !state.isBackCamera));
  }

  Future<void> _onRecordingStarted(
    RecordingStarted event,
    Emitter<CameraPermissionState> emit,
  ) async {
    emit(state.copyWith(isRecording: true));
  }

  Future<void> _onRecordingStopped(
    RecordingStopped event,
    Emitter<CameraPermissionState> emit,
  ) async {
    emit(state.copyWith(isRecording: false));
  }

  Future<void> _onPermissionsRechecked(
    PermissionsRechecked event,
    Emitter<CameraPermissionState> emit,
  ) async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    
    CameraPermissionStatus newCameraState = cameraStatus.isGranted 
        ? CameraPermissionStatus.granted 
        : cameraStatus.isPermanentlyDenied 
            ? CameraPermissionStatus.permanentlyDenied 
            : CameraPermissionStatus.denied;
    
    CameraPermissionStatus newMicState = micStatus.isGranted 
        ? CameraPermissionStatus.granted 
        : micStatus.isPermanentlyDenied 
            ? CameraPermissionStatus.permanentlyDenied 
            : CameraPermissionStatus.denied;
    
    emit(state.copyWith(
      cameraPermission: newCameraState,
      microphonePermission: newMicState,
    ));
  }

  Future<void> _onDialogShown(
    PermissionDialogShown event,
    Emitter<CameraPermissionState> emit,
  ) async {
    if (event.isCamera) {
      emit(state.copyWith(hasShownCameraDialog: true));
    } else {
      emit(state.copyWith(hasShownMicDialog: true));
    }
  }

  Future<void> _onPermissionErrorDetected(
    PermissionErrorDetected event,
    Emitter<CameraPermissionState> emit,
  ) async {
    // Update permission state based on error code
    if (event.isCameraError) {
      final status = (event.errorCode == 'CameraAccessDeniedWithoutPrompt' || 
                     event.errorCode == 'CameraAccessRestricted')
          ? CameraPermissionStatus.permanentlyDenied
          : CameraPermissionStatus.denied;
      
      emit(state.copyWith(cameraPermission: status));
    } else {
      final status = (event.errorCode == 'AudioAccessDeniedWithoutPrompt' || 
                     event.errorCode == 'AudioAccessRestricted')
          ? CameraPermissionStatus.permanentlyDenied
          : CameraPermissionStatus.denied;
      
      emit(state.copyWith(microphonePermission: status));
    }
  }
}
