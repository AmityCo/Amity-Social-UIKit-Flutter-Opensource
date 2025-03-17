part of 'communities_by_category_page_bloc.dart';

// ignore: must_be_immutable
class CommunitiesByCategoriesPageState extends Equatable {
  List<AmityCommunity> communities = [];
  
  CommunitiesByCategoriesPageState copyWith({
    List<AmityCommunity>? communities,
  }) {
    return CommunitiesByCategoriesPageState()
      ..communities = communities ?? this.communities;
  }
  
  @override
  List<Object> get props => [communities];
}
