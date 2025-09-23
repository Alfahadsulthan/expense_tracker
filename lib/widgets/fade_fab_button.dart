import 'package:flutter/material.dart';

class FadingFab extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final Widget label;

  const FadingFab({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  FadingFabState createState() => FadingFabState();
}

class FadingFabState extends State<FadingFab> {
  // execute the action
  double _opacity = 0.2; // 10% visible

  void _handleTap()async {
    widget.onPressed();

    setState(() {
      _opacity = 1.0; // fully visible on touch
    });

   await Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _opacity = 0.2;
        });
      }
    });

    
    
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        onPressed: _handleTap,
        icon: widget.icon,
        label: widget.label,
      ),
    );
  }
}
