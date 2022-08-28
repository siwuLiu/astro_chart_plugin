# astro_chart_plugin

Flutter 星盘绘制插件

## Getting Started

Git依赖
```yaml
dependencies:
  
  astro_chart_plugin: # 项目名称
    git: 
      url: https://gitlab.com/astro-healing/astro_chart_plugin.git
```

本地依赖
```yaml
astro_chart_plugin:
  path: /Users/Administrator/astro_chart/astro_chart_plugin
```
> 依赖可参考[https://dart.dev/tools/pub/dependencies#git-packages](https://dart.dev/tools/pub/dependencies#git-packages)

导入包中font `fonts/iconfont.ttf`
```yaml
fonts:
  - family: iconfont
    fonts:
      - asset: fonts/iconfont.ttf
```

> 字体:
```css
@font-face {
  font-family: 'iconfont';  /* project id 1841761 */
  src: url('//at.alicdn.com/t/font_1841761_9yp583026rl.eot');
  src: url('//at.alicdn.com/t/font_1841761_9yp583026rl.eot?#iefix') format('embedded-opentype'),
  url('//at.alicdn.com/t/font_1841761_9yp583026rl.woff2') format('woff2'),
  url('//at.alicdn.com/t/font_1841761_9yp583026rl.woff') format('woff'),
  url('//at.alicdn.com/t/font_1841761_9yp583026rl.ttf') format('truetype'),
  url('//at.alicdn.com/t/font_1841761_9yp583026rl.svg#iconfont') format('svg');
}
```

使用
```dart
import 'package:astro_chart_plugin/astro_chart_plugin.dart';

class DrawPanit extends CustomPainter{
  DrawPanit({ this.width, this.height });
  final double width;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    DrawAstro drawAstro = DrawAstro(canvas: canvas,
      json: result,
      width: width,
      height: height);
      
    drawAstro.init();

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
```
实例: 

[/example/lib/main.dart](/example/lib/main.dart)


## `DrawAstro` 实例方法:
  - `init` 组合调用其他方法直接绘制一个完整星盘
  - `drawCircle` 绘制圆
  - `drawTickMark` 圆周刻度线
  - `drawSign` 绘制星座
  - `drawHouse` 绘制12宫
  - `drawCusp` 绘制宫头星
  - `drawPlanets` 分布在不同宫位中的各种星体
  - `drawAspect` // TODO
