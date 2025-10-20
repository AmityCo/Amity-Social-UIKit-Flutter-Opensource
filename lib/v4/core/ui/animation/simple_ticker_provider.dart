import 'package:flutter/widgets.dart';

class SimpleTickerProvider extends StatefulWidget {
  final Widget child;
  final Function(TickerProvider) onInit;

  const SimpleTickerProvider({
    Key? key,
    required this.child,
    required this.onInit,
  }) : super(key: key);

  @override
  SimpleTickerProviderState createState() => SimpleTickerProviderState();
}

class SimpleTickerProviderState extends State<SimpleTickerProvider> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.onInit(this);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}