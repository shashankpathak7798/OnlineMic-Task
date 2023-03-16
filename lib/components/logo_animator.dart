import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';

class LogoAnimator extends StatefulWidget {
  const LogoAnimator({
    super.key,
  });

  @override
  State<LogoAnimator> createState() => _LogoAnimatorState();
}

class _LogoAnimatorState extends State<LogoAnimator> with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation? _animation;
  AnimationStatus _status = AnimationStatus.dismissed;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1),);
    _animation = Tween(end: 1.0, begin: 0.0,).animate(_controller!)
    ..addListener(() {
      setState(() {

      });
    })..addStatusListener((status) {
      _status = status;
      });

    if(_status == AnimationStatus.dismissed) {
      _controller?.forward();
    } else {
      _controller?.reverse();
    }

  }


  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()..setEntry(2, 1, 0.0015)..rotateY(pi * _animation?.value),
      child: Image.asset(
        'assets/images/LogoMaker.png',
        width: 300,
      ),
    );
  }
}