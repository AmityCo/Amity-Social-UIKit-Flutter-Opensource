import 'dart:math';

import 'package:amity_sdk/amity_sdk.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'hyperlink_event.dart';
part 'hyperlink_state.dart';

class HyperlinkBloc extends Bloc<HyperlinkEvent, HyperlinkState> {
  HyperlinkBloc() : super(HyperlinkInitialState()) {
    on<HyperlinkEvent>((event, emit) {});

    on<SetInitalStateEvent>((event, emit) {
      emit(HyperlinkInitialState(hyperLink: event.hyperlink));
    });

    on<OnRemoveHyperLink>((event, emit) {
      emit(const HyperlinkRemovedState(hyperLink: null));
    });

    on<OnHyperLinkAdded>((event, emit) {
      emit(HyperlinkAddedState(hyperLink: event.hyperlink));
    });

    on<OnURLErrorEvent>((event, emit) {
      if (state is HyperlinkErrorState) {
        var previousState = state as HyperlinkErrorState;
        HyperlinkErrorState newState = previousState.copyWith(
            urlError: event.error,
            customizedError: previousState.customizedError);
        emit(newState);
        return;
      } else {
        HyperlinkErrorState newState = HyperlinkErrorState(
            urlError: event.error, hyperLink: state.hyperLink);
        emit(newState);
      }
    });

    on<OnCustmizedErrorEvent>((event, emit) {
      if (state is HyperlinkErrorState) {
        var previousState = state as HyperlinkErrorState;
        HyperlinkErrorState newState = previousState.copyWith(
            customizedError: event.error, urlError: previousState.urlError);
        emit(newState);
        return;
      } else {
        HyperlinkErrorState newState = HyperlinkErrorState(
            hyperLink: state.hyperLink, customizedError: event.error);
        emit(newState);
      }
    });


    on<LoadingStateHyperLink>((event, emit) {
      emit(HyperlinkLoadingState( hyperLink: state.hyperLink));
    });

    on<VerifyAndSaveHyperLinkEvent>((event, emit) async {
      add(LoadingStateHyperLink( ));
      if (event.urlText.isEmpty) {
        add(OnURLErrorEvent(error: "Please enter a valid URL."));
        return;
      }
      // else if(!Uri.parse(event.urlText).isAbsolute){
      //   add(OnURLErrorEvent(error: "Please enter a valid URL."));
      //   return;
      // }

      await AmityCoreClient()
          .validateUrls([event.urlText])
          .then((value) {
            if(event.customizedText.isEmpty){
              HyperLink hyperlink = HyperLink(
                url: event.urlText,
              );
              add(OnHyperLinkAdded(hyperlink: hyperlink));
            }
          })
          .onError((error, stackTrace) {
            add(OnURLErrorEvent(error: "Please enter a whitelisted URL."));
          });

      if (event.customizedText.isNotEmpty) {
        await AmityCoreClient()
            .validateTexts([event.customizedText])
            .then((value) {
              HyperLink hyperlink = HyperLink(
                url: event.urlText,
                customText: event.customizedText,
              );
              add(OnHyperLinkAdded(hyperlink: hyperlink));
            })
            .onError((error, stackTrace) {
              add(OnCustmizedErrorEvent(error: "Your text contains a blocklisted word."));
            });
      }

      emit(state);
    });
  }





}
