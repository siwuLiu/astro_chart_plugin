import 'package:flutter/material.dart';
import './data/test_data.dart';
import 'package:astro_chart_plugin/astro_chart_plugin.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: AstroChart(),
        )
      ),
    );
  }
}

class AstroChart extends StatelessWidget {
  const AstroChart({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double drawWidth = MediaQuery.of(context).size.width-10;
    return Container(
      padding: EdgeInsets.all(5),
      height: drawWidth,
      child: CustomPaint(
        painter: DrawPanit(
          width: drawWidth,
          height: drawWidth
        ),
      )
    );
  }
}


class DrawPanit extends CustomPainter{
  DrawPanit({ this.width, this.height });
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    DrawAstro(canvas: canvas,
      json: result,
      width: width,
      height: height).init();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}