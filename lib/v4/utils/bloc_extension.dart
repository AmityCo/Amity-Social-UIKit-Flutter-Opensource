import 'package:flutter_bloc/flutter_bloc.dart';

extension BlocExtension<Event,State> on Bloc<Event,State> {
  void addEvent(Event event) {
    if(!isClosed) {
      add(event);
    }
  }
}