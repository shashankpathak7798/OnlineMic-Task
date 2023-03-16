import 'package:flutter/material.dart';

import '../components/logo_animator.dart';
import '../screens/main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  AnimationController? _controller1, _controller2;
  Animation? _animation1, _animation2;
  bool _isVisible = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller1 = AnimationController(vsync: this, duration: Duration(milliseconds: 800),);
    _animation1 = Tween<double>(begin: 0, end: 120,).animate(_controller1!)..addListener(() {setState(() {
      
    });})..addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        setState(() {
          _isVisible = true;
        });
        _controller2?.forward();
      }
    });


    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _animation2 = Tween<double>(begin: 0, end: 1).animate(_controller2!)
      ..addListener(() {
        setState(() {});
      });

    _controller1?.forward();

    
    Future.delayed(Duration(seconds: 5,),).then((value) => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return MainScreen();
    },)));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller1?.dispose();
    _controller2?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _controller1!,
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: child,
                );
              },
              child: LogoAnimator(),
            ),

            AnimatedBuilder(animation: _controller2!, builder: (context, child) {
              return Visibility(visible: _isVisible, child: child!);
            },
            child: Column(children: [
              Text('Lorem ipsum', style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold,),),
              Container(width: 250, child: Text('Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia desrecent', style: TextStyle(fontSize: 16, color: Colors.white,), textAlign: TextAlign.center,),),
              SizedBox(height: 20,),

              ElevatedButton.icon(onPressed: () {}, label: Text('Sign Up With Facebook'), icon: Icon(Icons.facebook), style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.indigoAccent),
              ),),

              ElevatedButton.icon(onPressed: () {}, label: Text('Sign Up With Gmail', style: TextStyle(color: Colors.black,),), icon: Icon(Icons.mail_outline_outlined, color: Colors.black,), style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),),

              SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?', style: TextStyle(color: Colors.white,),),
                  TextButton(onPressed: () {}, child: Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600,),),),
                ],
              ),
            ],),
            )
          ],
        ),
      ),
    );
  }
}
