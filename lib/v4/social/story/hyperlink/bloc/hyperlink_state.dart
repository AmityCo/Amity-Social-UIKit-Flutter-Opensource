part of 'hyperlink_bloc.dart';

abstract class HyperlinkState extends Equatable {
  final HyperLink? hyperLink;
  const HyperlinkState({this.hyperLink});
}

class HyperlinkInitialState extends HyperlinkState {
  const HyperlinkInitialState({HyperLink? hyperLink}) : super(hyperLink: hyperLink);
  @override
  List<Object?> get props => [
        hyperLink,
        identityHashCode(this)
      ];

  HyperlinkInitialState copyWith({
    HyperLink? hyperLink,
  }) {
    return HyperlinkInitialState( hyperLink:  hyperLink ?? this.hyperLink) ;
  }
}

class HyperlinkErrorState extends HyperlinkState {
  final String? urlError;
  final  String? customizedError;
  const HyperlinkErrorState({HyperLink? hyperLink, this.urlError, this.customizedError }) : super(hyperLink: hyperLink);


  @override
  List<Object?> get props => [
        hyperLink,
        urlError,
        customizedError,
        identityHashCode(this)
      ];

  HyperlinkErrorState copyWith({
    HyperLink? hyperLink,
    String? urlError,
    String? customizedError,
  }) {
    return HyperlinkErrorState( hyperLink:  hyperLink ?? this.hyperLink, urlError: urlError , customizedError: customizedError );
  }
}



class HyperlinkRemovedState extends HyperlinkState {
  const HyperlinkRemovedState({HyperLink? hyperLink,}): super(hyperLink: hyperLink);
  @override
  List<Object?> get props => [];

}

class HyperlinkAddedState extends HyperlinkState {
  const HyperlinkAddedState({HyperLink? hyperLink,}): super(hyperLink: hyperLink);
  @override
  List<Object?> get props => [];

}

class HyperlinkLoadingState extends HyperlinkState {
  const HyperlinkLoadingState({HyperLink? hyperLink,}): super(hyperLink: hyperLink);
  @override
  List<Object?> get props => [];

}


