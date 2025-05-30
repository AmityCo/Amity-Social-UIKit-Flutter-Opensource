part of 'group_profile_page.dart';

class GroupProfileCubit extends Cubit<GroupProfileState> {
  final AmityChannel channel;
  final TextEditingController nameController = TextEditingController();
  late final String originalName;

  GroupProfileCubit(this.channel) : super(GroupProfileLoading()) {
    originalName = channel.displayName ?? '';
    _initialize();
  }

  void _initialize() {
    nameController.text = originalName;
    
    // Add listener for text changes
    nameController.addListener(_onTextChanged);
    
    emit(GroupProfileLoaded(
      imagePath: null,
      selectedImagePath: null,
      charCount: nameController.text.length,
      hasChanged: false,
    ));
  }

  void _onTextChanged() {
    final currentState = state;
    if (currentState is GroupProfileLoaded) {
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
    if (currentState is GroupProfileLoaded) {
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
    if (currentState is GroupProfileLoaded) {
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
    if (currentState is! GroupProfileLoaded) return;

    final updatedName = nameController.text;
    final selectedImage = currentState.selectedImagePath;

    // Save logic here
    AmityChatClient.newChannelRepository()
        .updateChannel(channel.channelId ?? "")
        .displayName(updatedName)
        // .avatar(avatar) // Add avatar logic when uploading image
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
          emit(GroupProfileLoading());
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