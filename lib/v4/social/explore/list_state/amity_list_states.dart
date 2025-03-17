// amity_list_states.dart
import 'package:amity_sdk/amity_sdk.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// State enums
enum CategoryListState { loading, success, empty, error }
enum CommunityListState { loading, success, empty, error }

// Base state for both category and community lists
abstract class AmityListState extends Equatable {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final int itemCount;

  const AmityListState({
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.itemCount,
  });

  @override
  List<Object?> get props => [isLoading, hasError, errorMessage, itemCount];
}

// Category specific state
class CategoryState extends AmityListState {
  final List<AmityCommunityCategory> categories;

  const CategoryState({
    required super.isLoading,
    required super.hasError,
    super.errorMessage,
    required this.categories,
  }) : super(itemCount: categories.length);

  @override
  List<Object?> get props => [...super.props, categories];

  CategoryState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<AmityCommunityCategory>? categories,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
    );
  }
}

// Community specific state
class CommunityState extends AmityListState {
  final List<AmityCommunity> communities;

  const CommunityState({
    required super.isLoading,
    required super.hasError,
    super.errorMessage,
    required this.communities,
  }) : super(itemCount: communities.length);

  @override
  List<Object?> get props => [...super.props, communities];

  CommunityState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<AmityCommunity>? communities,
  }) {
    return CommunityState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      communities: communities ?? this.communities,
    );
  }
}
