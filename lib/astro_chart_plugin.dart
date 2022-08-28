import './models/sign_data_model.dart';
import './models/sign_icons_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// 绘制星盘
/// 
/// 
class DrawAstro {
  
  DrawAstro({
    Key key,
    @required this.canvas,
    @required this.json,
    @required this.width,
    @required this.height,
    this.center
  });

  final Canvas canvas;
  final Map<String, dynamic> json;
  final double width;
  final double height;
  final Offset center;

  static String __version__ = '0.1.2';
  
  SignsData signsData;

  Map<String, num> signIcons = SIGN_ICONS;
  
  static DrawAstro fromJson(Map<String, dynamic> json){
    return DrawAstro(
      canvas: json["canvas"],
      json: json["json"],
      width: json["width"],
      height: json["height"]
    );
  }

  // 绘制各个元素
  void init(){
    double housesR = this.width/2-20;
    double signsR = this.width/8;
    double signLineLen = 20;

    this.signsData = SignsData.fromJson(this.json);

    this.canvas.save();
    
    this.drawCircle(Offset(this.width/2, this.height/2), this.width/2);

    this.drawCircle(Offset(this.width/2, this.height/2), this.width/2);

    this.drawCircle(Offset(this.width/2, this.height/2), this.width/2-20, color: Colors.orangeAccent,);

    this.drawTickMark(housesR, longMarkColor: Colors.green);

    this.drawSign(signsR, this.signsData.signs, lineLenth: signLineLen, iconSize: 8, signColors: SINGS_COLOR);

    this.drawHouse(housesR, this.signsData.houses, fontSize: 8, fontColor: Colors.grey[400], lineLenth: housesR - signsR-signLineLen);

    this.drawCusp(housesR+10, this.signsData.houses, fontSize: 8, fontColor: Colors.grey[400], signColors: SINGS_COLOR);

    this.drawPlanets(housesR, this.signsData.planets, signColors: SINGS_COLOR, lineColor: Colors.grey[350], iconSize: 8,fontSize: 6);

    this.drawAspect(signsR, this.signsData.planets, this.signsData.aspects, powerColors: {
      0: Colors.orange,
      1: Colors.pinkAccent,
      2: Colors.blueAccent,
      3: Colors.purpleAccent,
      4: Colors.teal
    });
  }
  
  void drawCircle(Offset c, double radius, {
    Color color = Colors.blueAccent,
    bool fill = false,
  }){
    Paint paint = Paint()
        ..isAntiAlias = true // 抗锯齿
        ..strokeWidth = 1
        ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
        ..color = color;

    this.canvas.drawCircle(c, radius, paint);
    paint = null;    
  }

  /// 绘制图标
  /// `icon` 图标, 如果是fontIcon, 需要使用`String.fromChartCode(code)`将16进制转成字符串
  /// 
  void drawIcon(String icon, Offset offset, {double size, Color color }) {
    TextPainter textPainter = new TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr
    );
    
    textPainter.text = new TextSpan(
      text: icon,
      style: TextStyle(
        color: color ?? Colors.red,
        fontFamily: 'iconfont',
        fontSize: size ?? 14
      )
    );

    textPainter.layout();
    textPainter.paint(this.canvas, offset);
    textPainter = null;
  }

  /// 绘制刻度线
  /// `radius` 刻度线围绕的半径
  /// 
  void drawTickMark(double radius, {
      Color color = Colors.grey, // 正常刻度颜色
      Color longMarkColor = Colors.orange, // 突出色
      double markSize = 8, // 刻度线长度
    }){
    double deg = 1;
    double currentDeg = 0;
    double arcCount = 360/deg;
    
    Paint paint = Paint()
      ..isAntiAlias = true // 抗锯齿
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..color = color;

    _setStartPosition(radius);

    for(var i=0; i<arcCount; i++){
      canvas.save();

      double size = markSize;

      if(i == 90 || i == 270){
        size = radius/5*3;
      } else if(i % 5 == 0) {
        paint.color = longMarkColor;
        size = markSize + 5;
      } else {
        paint.color = color;
      }

      currentDeg = i * deg;
      canvas.translate(
        sin(degToRad(currentDeg))*radius,
        radius - cos(degToRad(currentDeg))*radius);
      canvas.rotate(degToRad(currentDeg));

      canvas.drawLine(Offset(0, 0), Offset(0, size), paint);

      canvas.restore();
    }

    canvas.restore();
  }

  /// 内圈星座
  void drawSign(double radius, List<SignItem> signs, {
    double rotateDeg=0,
    double lineLenth = 20.0,
    double iconSize = 14,
    Color strokeColor = Colors.orange,
    Map<String, Color> signColors,
    bool showSpliteLine = true
  }){
    double currentDeg = 0;
    double totalRotate = 0;
    String icon;
    Color iconColor;

    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    canvas.save();
    this._setStartPosition(radius);

    for(int i=0; i<signs.length; i++){
      this.canvas.save();

      currentDeg = - signs[i].startDegree.toDouble() - 90;

      totalRotate = currentDeg - rotateDeg;

      this.canvas.translate(sin(degToRad(totalRotate)) * radius, radius - cos(degToRad(totalRotate)) * radius);

      this.canvas.rotate(degToRad(totalRotate));

      if(showSpliteLine){
        this.canvas.drawLine(Offset(0, -lineLenth), Offset(0, 0), paint);
      }

      this.canvas.restore();
      this.canvas.save();

      this.canvas.translate(
        sin(degToRad(totalRotate)) * (radius+lineLenth/2),
        radius - cos(degToRad(totalRotate)) * (radius+lineLenth/2));

      this.canvas.rotate(degToRad(totalRotate));

      // 纠正字体偏转
      this.canvas.translate(sin(degToRad(15))*radius, radius-cos(degToRad(15))*radius);
      this.canvas.rotate(-degToRad(totalRotate));

      if(i==0){
        icon = String.fromCharCode(signIcons[signs[signs.length-1].name]);
        if(signColors != null){
          signColors[signs[signs.length-1].name] != null ? iconColor = signColors[signs[signs.length-1].name] : iconColor = Colors.black;
        } else {
          iconColor = Colors.blueAccent;
        }
      }else{
        icon = String.fromCharCode(signIcons[signs[i-1].name]);
        if(signColors != null){
          signColors[signs[i-1].name] != null ? iconColor = signColors[signs[i-1].name] : iconColor = Colors.black;
        } else {
          iconColor = Colors.blueAccent;
        }
      }


      this.drawIcon(icon, Offset(-iconSize/2, -iconSize/2), size: iconSize, color: iconColor);
      this.canvas.restore();
    }

    this.canvas.restore();

    this.drawCircle(Offset(this.width/2, this.height/2), radius, color: strokeColor);
    this.drawCircle(Offset(this.width/2, this.height/2), radius + lineLenth, color: strokeColor);
    paint = null;
  }

  /// 12宫分宫线及宫位标
  void drawHouse(radius, List<HouseItem> houses, {
    Color markColor = Colors.grey,
    Color houseLineColor = Colors.orange,
    Color fontColor = Colors.black54,
    double fontSize = 12,
    double lineLenth = 100,
  }){
    double currentDeg = 0;
    int gapDeg = 0;
    String currentHouse = '';

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = houseLineColor;

    this.canvas.save();
    this._setStartPosition(radius);
    
    for(int i=0; i<houses.length; i++){
      this.canvas.save();
      currentDeg = - houses[i].startAngleDegree.toDouble() - 90.0;

      this.canvas.translate(sin(degToRad(currentDeg)) * radius, radius - cos(degToRad(currentDeg)) * radius);
      this.canvas.rotate(degToRad(currentDeg));

      canvas.drawLine(Offset(0, 0), Offset(0, lineLenth), paint);

      if(i==0){
        currentHouse = houses[houses.length - 1].index.toString();
        gapDeg =  360 - houses[houses.length - 1].startAngleDegree;
      }else{
        currentHouse = houses[i - 1].index.toString();
        gapDeg =  houses[i].startAngleDegree - houses[i-1].startAngleDegree;
      }

      double markR = lineLenth - fontSize-5;
      
      canvas.translate(sin(degToRad(gapDeg/2))*markR, markR - cos(degToRad(gapDeg/2))*markR);

      this.drawIcon(currentHouse, 
        Offset(-fontSize/2, lineLenth - fontSize-5), 
        size: fontSize,
        color: fontColor);

      this.canvas.restore();
    }

    this.canvas.restore();

  }

  /// 宫头星
  void drawCusp(double radius, List<HouseItem> houses, {
    double rotateAng = 0.0,
    double iconOffset = 0.0,
    Map<String, Color> signColors,
    Color fontColor = Colors.grey,
    double fontSize = 10.0,
    double iconSize = 10.0
  }){
    double currentAngle = 0.0;
    double totalRotate = 0;
    String icon;
    Color iconColor;

    this.canvas.save();
    this._setStartPosition(radius);

    for(int i=0; i<houses.length; i++){
      currentAngle = - houses[i].startAngleDegree.toDouble() - 90.0;
      totalRotate = currentAngle - rotateAng;
      
      this.canvas.save();

      this.canvas.translate(sin(degToRad(totalRotate))*radius, radius-cos(degToRad(totalRotate))*radius);
      this.canvas.rotate(totalRotate);
      this.canvas.restore();
      this.canvas.save();

      this.canvas.translate(sin(degToRad(totalRotate))*radius, radius-cos(degToRad(totalRotate))*radius);
      this.canvas.rotate(degToRad(totalRotate));
      this.canvas.rotate(-degToRad(totalRotate));

      icon = String.fromCharCode(signIcons[houses[i].cuspSign]);
      if(signColors != null){
        signColors[houses[i].cuspSign] != null ? iconColor = signColors[houses[i].cuspSign] : iconColor = Colors.black;
      } else {
        iconColor = Colors.blueAccent;
      }
      this.drawIcon(icon, Offset(-fontSize/2, -fontSize/2), color: iconColor, size: iconSize);

      this.canvas.restore();
      this.canvas.save();

      this.drawPostion(radius, '${houses[i].cuspPositionDegree}°', 
        size: fontSize,
        color: fontColor,
        aligment: Alignment.centerLeft,
        rotate: totalRotate);
      this.drawPostion(radius, '${houses[i].cuspPositionArcminute}\'',
        size: fontSize,
        color: fontColor,
        aligment: Alignment.centerRight,
        rotate: totalRotate);

      this.canvas.restore();
    }

    this.canvas.restore();
  }

  /// 分布在不同宫位中的各种星体
  void drawPlanets(double radius, List<PlanetsItem> planets, {
    double rotateDeg = 0,
    Map<String, Color> signColors,
    double fontSize = 8.0,
    double iconSize = 10.0,
    Color iconColor = Colors.green,
    Color fontColor = Colors.grey,
    Color lineColor = Colors.red
  }){
    double currentDeg = 0.0;
    double totalRotate = 0.0;
    double gapDeg = 0.0;
    String icon;
    double iconR = radius - 24;
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.grey;
    
    this.canvas.save(); 
    this._setStartPosition(radius);

    planets.sort((PlanetsItem a, PlanetsItem b) {
      if(a.startPosition > b.startPosition){
        return 1;
      }
      return 0;
    });

    for(int i = 0; i < planets.length; i++){
      currentDeg = - planets[i].startPosition.toDouble() - 90;
      totalRotate = currentDeg;
      gapDeg = 0;
      double _itemDeg = planets[i].startPosition.toDouble();

      // check两个星体之间与下一个的距离
      if(i<planets.length-1
        && i>0 
        && (_itemDeg - planets[i+1].startPosition).abs() < 4
        && (_itemDeg - planets[i-1].startPosition).abs() > 4){
          gapDeg = -(6 - (_itemDeg - planets[i+1].startPosition).abs());
      }

      // check两个星体之间与上一个的距离
      if(i>0
        && (_itemDeg - planets[i-1].startPosition).abs() < 4
        && i<planets.length-1
        && (_itemDeg - planets[i+1].startPosition).abs() > 4){
          gapDeg = (6 - (_itemDeg - planets[i-1].startPosition).abs());
      }

      this.canvas.save();

      this.canvas.translate(sin(degToRad(totalRotate)) * radius, radius - cos(degToRad(totalRotate)) * radius);
      this.canvas.rotate(degToRad(totalRotate));
      
      paint.color = lineColor;
      if(gapDeg != 0){
        Offset p;
        this.canvas.drawLine(Offset(0, 0), Offset(0, 10), paint);
        gapDeg > 0
          ? p = Offset(-sin(degToRad(24)) * 20, cos(degToRad(24))*20)
          : p = Offset(sin(degToRad(24)) * 20, cos(degToRad(24))*20);
        this.canvas.drawLine(Offset(0, 10), p, paint);
      } else {
        this.canvas.drawLine(Offset(0, 0), Offset(0, 14), paint);
      }

      totalRotate -= gapDeg;

      this.canvas.restore();
      this.canvas.save();

      this.canvas.translate(0, radius-iconR);
      this.canvas.translate(sin(degToRad(totalRotate)) * iconR, iconR - cos(degToRad(totalRotate)) * iconR);

      icon = signIcons[planets[i].name] == null ? planets[i].name : String.fromCharCode(signIcons[planets[i].name]);
      if(signColors != null){
        signColors[planets[i].name] != null ? iconColor = signColors[planets[i].name] : iconColor = Colors.black;
      }

      this.drawIcon(icon, Offset(-iconSize/2, -iconSize/2), size: iconSize, color: iconColor);

      this.canvas.restore();
      this.canvas.save();

      this.canvas.translate(0, radius-iconR+20);
      this.canvas.translate(sin(degToRad(totalRotate))*(iconR-20), (iconR-20)-cos(degToRad(totalRotate))*(iconR-20));
      this.canvas.rotate(degToRad(totalRotate));

      if(signColors != null){
        signColors[planets[i].positionSign] != null ? iconColor = signColors[planets[i].positionSign] : iconColor = Colors.black;
      }
      
      this.drawIcon(String.fromCharCode(signIcons[planets[i].positionSign]),
        Offset(-iconSize/2, -iconSize/2),
        size: iconSize,
        color: iconColor);

      this.drawIcon('${planets[i].positionDegree}°',
        Offset(-fontSize/2, -16),
        size: fontSize,
        color: fontColor);

      this.drawIcon('${planets[i].positionArcminute}\'',
        Offset(-fontSize/2, fontSize/2),
        size: fontSize,
        color: fontColor);

      this.canvas.restore();
    }
    
    this.canvas.restore();
  }

  void drawPostion(radius, text, {
    double size = 10,
    Color color = Colors.black,
    double top = 0,
    double bottom = 0,
    double rotate = 0,
    Alignment aligment = Alignment.topLeft
  }){
    double ang;

    if(aligment == Alignment.centerLeft ){
      ang = -size;
    } else if(aligment == Alignment.centerRight){
      ang = size;
    } else {
      ang = 0;
    }

    this.canvas.save();
    
    if(top != 0){
      radius -= top;
      this.canvas.translate(sin(degToRad(rotate)) * radius, radius-cos(degToRad(rotate)) * radius + top);
    } else 
    if(aligment == Alignment.topCenter){
      radius += (size+2);
      this.canvas.translate(sin(degToRad(rotate))*radius, (radius-cos(degToRad(rotate))*radius)-(size+2));
    } else if(aligment == Alignment.bottomCenter){
      radius -= (size+2);
      this.canvas.translate(sin(degToRad(rotate))*radius, (radius-cos(degToRad(rotate))*radius)+(size+2));
    } else {
      this.canvas.translate(sin(degToRad(rotate + ang/2)) * radius, radius - cos(degToRad(rotate + ang/2))*radius);
    }

    this.drawIcon(text, Offset(-size/2, -size/2), size: size, color: color);
    this.canvas.restore();
  }

  /// 相位
  void drawAspect(double radius, List<PlanetsItem> planets, List<AspectItem> aspects, {
    Map<num, Color> powerColors,
    double fontSize = 8
  }){
    List<LineOffset> lines = [];
    Map<String, double> planetsDeg = {};

    planets.forEach((PlanetsItem item){
      planetsDeg[item.name] = item.startPosition.toDouble();
    });

    aspects.forEach((AspectItem aspect){
      
      Offset p1 = Offset(
        sin(degToRad(planetsDeg[aspect.srcObj])) * radius,
        radius - cos(degToRad(planetsDeg[aspect.srcObj])) * radius,
      );
      Offset p2 = Offset(
        sin(degToRad(planetsDeg[aspect.destObj])) * radius,
        radius - cos(degToRad(planetsDeg[aspect.destObj])) * radius,
      );

      lines.add(LineOffset(p1, p2));
    });

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey;

    this.canvas.save();
    this._setStartPosition(radius);

    for(int i=0; i<lines.length; i++){
      if(powerColors !=null && powerColors.containsKey(aspects[i].power)){
        paint.color = powerColors[aspects[i].power];
      } else {
        paint.color = Colors.grey;
      }
      this.canvas.drawLine(lines[i].p1, lines[i].p2, paint);
      this.drawIcon(aspects[i].t, lines[i].p2, color: paint.color, size: fontSize);
    }

    this.canvas.restore();
  }

  void _setStartPosition(double radius){
    this.canvas.translate(this.width/2, this.height/2-radius);
  }

  // 通过星体简称检索其所处角度
  num _getObjDeg(String obj){
    double x;
    return x;
  }

  // test Method
  void _drawDebug(){
    drawRect(this.canvas, Offset(0, 0), Offset(40, 40), style: PaintingStyle.stroke);
  }
  
}

num degToRad(num deg) => deg * (pi / 180.0);
num radToDeg(num rad) => rad * (180.0 / pi);

void drawRect(Canvas canvas, Offset begin, Offset end, {
  Color borderColor,
  double borderWidth,
  PaintingStyle style
}) {
  Rect rect = Rect.fromPoints(begin, end);
  Paint rectPaint = Paint()
    ..color = borderColor ?? Colors.pink
    ..strokeWidth = borderWidth ?? 2
    ..style = style ?? PaintingStyle.fill;
  
  canvas.drawRect(rect, rectPaint);
}

class LineOffset{
  LineOffset(this.p1, this.p2);

  final Offset p1;
  final Offset p2;
}

Widget iconTest = IconButton(icon: Icon(SignIcons.cap), onPressed: null);