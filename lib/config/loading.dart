import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:maktrogps/config/static.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: SpinKitRing(
            lineWidth: 3.0,
            color: kBlueColor,
            size: 35.0,
          ),
        ),
      ),
    );
  }

  Future<bool> onWillPop() {

    return Future.value(true);
  }
}

/* class Loading extends StatelessWidget {
  const Loading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SpinKitFadingCube(
        color: kBlueColor,
        size: 40.0,
      )
    );
  }
} */

/// for seting animation duration(slow/fast animation)
/*
import 'package:geogps/Common/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget{
  const Loading({Key key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SpinKitFadingCube(
        color: kBlueColor,
        size: 40.0,
        //controller: AnimationController(vsync: this, duration: const Duration(milliseconds: 1500)),
      )
    );
  }
} */
