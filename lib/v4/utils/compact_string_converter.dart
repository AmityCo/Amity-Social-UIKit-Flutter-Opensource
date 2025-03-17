extension CompactStringFormatter on int {
  String formattedCompactString() {
    int n = this;
    double num = n.abs().toDouble();
    String sign = n < 0 ? "-" : "";

    String reduceScale(double number, int scale) {
      return number
          .toStringAsFixed(scale)
          .replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
    }

    if (num >= 1000000000) {
      double formatted = num / 1000000000;
      return "$sign${reduceScale(formatted, 1)}B";
    } else if (num >= 1000000) {
      double formatted = num / 1000000;
      return "$sign${reduceScale(formatted, 1)}M";
    } else if (num >= 1000) {
      double formatted = num / 1000;
      return "$sign${reduceScale(formatted, 1)}K";
    } else {
      return "$n";
    }
  }
}
