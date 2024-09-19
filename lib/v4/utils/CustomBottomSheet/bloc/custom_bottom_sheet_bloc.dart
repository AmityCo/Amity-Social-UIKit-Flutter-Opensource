import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'custom_bottom_sheet_events.dart';
part 'custom_bottom_sheet_state.dart';

class CustomBottomSheetBloc extends Bloc<CustomBottomSheetEvent, CustomBottomSheetState> {
  final double maxSize;
  final double minSize;

  CustomBottomSheetBloc(this.maxSize, this.minSize)
      : super(CustomBottomSheetExpanded(0.3)) {
    on<CustomBottomSheetExtentChanged>((event, emit) {
      if (event.extent > ((maxSize - minSize) * 0.5) + minSize) {
        emit(CustomBottomSheetExpanded(event.extent));
      } else {
        emit(CustomBottomSheetCollapsed(event.extent));
      }
    });
  }
}
