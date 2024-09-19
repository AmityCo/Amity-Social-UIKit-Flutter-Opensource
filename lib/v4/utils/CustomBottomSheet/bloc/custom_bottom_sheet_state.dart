part of 'custom_bottom_sheet_bloc.dart';

abstract class CustomBottomSheetState extends Equatable {
  final double extent;

  CustomBottomSheetState(this.extent);

  @override
  List<Object?> get props => [extent];
}

class CustomBottomSheetCollapsed extends CustomBottomSheetState {
  CustomBottomSheetCollapsed(double extent) : super(extent);
}

class CustomBottomSheetExpanded extends CustomBottomSheetState {
  CustomBottomSheetExpanded(double extent) : super(extent);
}
