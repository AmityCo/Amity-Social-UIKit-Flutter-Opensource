import 'package:flutter/material.dart';

class CompoentSizeVM extends ChangeNotifier {
  double _communityDetailSectionSize = 0;
  double getCommunityDetailSectionSize() => _communityDetailSectionSize;
  void setCommunityDetailSectionSize(double size) {
    _communityDetailSectionSize = size;
    notifyListeners();
  }
}
