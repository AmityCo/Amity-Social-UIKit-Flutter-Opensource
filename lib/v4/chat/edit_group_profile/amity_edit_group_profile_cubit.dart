part of 'amity_edit_group_profile_page.dart';

class AmityEditGroupProfileCubit extends Cubit<AmityEditGroupProfileState> {
  final AmityChannel channel;
  final TextEditingController nameController = TextEditingController();
  late final String originalName;

  AmityEditGroupProfileCubit(this.channel) : super(AmityEditGroupProfileLoading()) {
    originalName = channel.displayName ?? '';
    _initialize();
  }

  void _initialize() {
    nameController.text = originalName;
    
    // Add listener for text changes
    nameController.addListener(_onTextChanged);
    
    emit(AmityEditGroupProfileLoaded(
      imagePath: null,
      selectedImagePath: null,
      charCount: nameController.text.length,
      hasChanged: false,
    ));
  }

  void _onTextChanged() {
    final currentState = state;
    if (currentState is AmityEditGroupProfileLoaded) {
      final newCharCount = nameController.text.length;
      final nameChanged = nameController.text != originalName;
      final imageChanged = currentState.selectedImagePath != null;
      final hasChanged = nameChanged || imageChanged;

      emit(currentState.copyWith(
        charCount: newCharCount,
        hasChanged: hasChanged,
      ));
    }
  }

  void updateSelectedImage(String imagePath) {
    final currentState = state;
    if (currentState is AmityEditGroupProfileLoaded) {
      final nameChanged = nameController.text != originalName;
      final hasChanged = nameChanged || true; // Image is selected
      
      emit(currentState.copyWith(
        selectedImagePath: imagePath,
        hasChanged: hasChanged,
      ));
    }
  }

  Future<void> pickImage() async {
    final currentState = state;
    if (currentState is AmityEditGroupProfileLoaded) {
      try {
        final XFile? image = await currentState.mediaHandler.pickImage();
        if (image != null) {
          updateSelectedImage(image.path);
        }
      } catch (e) {
        // Handle error - could emit an error state or show a toast
        print('Failed to pick image: $e');
      }
    }
  }

  void saveGroupProfile() async {
    final currentState = state;
    if (currentState is! AmityEditGroupProfileLoaded) return;

    final updatedName = nameController.text;
    final selectedImage = currentState.selectedImagePath;

    // Save logic here
    AmityChatClient.newChannelRepository()
        .updateChannel(channel.channelId ?? "")
        .displayName(updatedName)
        .create()
        .then((_) {
          emit(currentState.copyWith(
            imagePath: selectedImage,
            selectedImagePath: null,
            hasChanged: false,
          ));
        })
        .catchError((error) {
          // Handle error
          emit(AmityEditGroupProfileLoading());
        });

    if (selectedImage != null) {
      // Upload image logic
    }
  }

  @override
  Future<void> close() {
    nameController.removeListener(_onTextChanged);
    nameController.dispose();
    return super.close();
  }
}