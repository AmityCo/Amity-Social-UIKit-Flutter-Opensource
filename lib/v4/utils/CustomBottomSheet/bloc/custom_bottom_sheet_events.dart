part of 'custom_bottom_sheet_bloc.dart';

abstract class CustomBottomSheetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CustomBottomSheetExtentChanged extends CustomBottomSheetEvent {
  final double extent;

  CustomBottomSheetExtentChanged({required this.extent});

  @override
  List<Object?> get props => [extent];
}
