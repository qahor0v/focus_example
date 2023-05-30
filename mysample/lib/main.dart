import 'package:flutter/material.dart';
void main() => runApp(const FocusTraversalGroupExampleApp());

class FocusTraversalGroupExampleApp extends StatelessWidget {
  const FocusTraversalGroupExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FocusTraversalGroupExample(),
    );
  }
}

class OrderedButton<T> extends StatefulWidget {
  const OrderedButton({
    super.key,
    required this.name,
    this.canRequestFocus = true,
    this.autofocus = false,
    required this.order,
  });

  final String name;
  final bool canRequestFocus;
  final bool autofocus;
  final T order;

  @override
  State<OrderedButton<T>> createState() => _OrderedButtonState<T>();
}

class _OrderedButtonState<T> extends State<OrderedButton<T>> {
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode(
      debugLabel: widget.name,
      canRequestFocus: widget.canRequestFocus,
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OrderedButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    focusNode.canRequestFocus = widget.canRequestFocus;
  }

  void _handleOnPressed() {
    focusNode.requestFocus();
    debugPrint('Button ${widget.name} pressed.');
    debugDumpFocusTree();
  }

  @override
  Widget build(BuildContext context) {
    FocusOrder order;
    if (widget.order is num) {
      order = NumericFocusOrder((widget.order as num).toDouble());
    } else {
      order = LexicalFocusOrder(widget.order.toString());
    }

    Color? overlayColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.focused)) {
        return Colors.red;
      }
      if (states.contains(MaterialState.hovered)) {
        return Colors.blue;
      }
      return null;  
    }

    Color? foregroundColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.focused) ||
          states.contains(MaterialState.hovered)) {
        return Colors.white;
      }
      return null; 
    }

    return FocusTraversalOrder(
      order: order,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: OutlinedButton(
          focusNode: focusNode,
          autofocus: widget.autofocus,
          style: ButtonStyle(
            overlayColor:
                MaterialStateProperty.resolveWith<Color?>(overlayColor),
            foregroundColor:
                MaterialStateProperty.resolveWith<Color?>(foregroundColor),
          ),
          onPressed: () => _handleOnPressed(),
          child: Text(widget.name),
        ),
      ),
    );
  }
}

class FocusTraversalGroupExample extends StatelessWidget {
  const FocusTraversalGroupExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(3, (int index) {
                  return OrderedButton<num>(
                    name: 'num: $index',
                     order: index,
                  );
                }),
              ),
            ),
             FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(3, (int index) {
                   final String order =
                      String.fromCharCode('A'.codeUnitAt(0) + (2 - index));
                  return OrderedButton<String>(
                    name: 'String: $order',
                    order: order,
                  );
                }),
              ),
            ),
             FocusTraversalGroup(
              policy: WidgetOrderTraversalPolicy(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(3, (int index) {
                  return OrderedButton<num>(
                    name: 'ignored num: ${3 - index}',
                    order: 3 - index,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
