import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tic_tac_toe/game.dart';


double lerp(double a, double b, double t) => a + (b - a) * t;


double slerp(double a, double b, double ta, double tb, double t) {
  // interval interpolation (by analogy with lerp)
  // interpolates value between a and b
  //   |
  // b |       /------
  //   |      /
  // a |-----/
  //   |
  //   +------------------
  //   0    ta  tb    1

  if (t <= ta) return a;
  if (t >= tb) return b;

  assert(ta != tb);
  return a + (b - a) * ((t - ta) / (tb - ta));
}


double solveLine(double x1, double y1, double x2, double y2, double x) {
  // (x2 - x) / (x2 - x1) == (y2 - y) / (y2 - y1)
  // y = y2 - (x2 - x) * (y2 - y1) / (x2 - x1);
  final y = y2 - (x2 - x) * (y2 - y1) / (x2 - x1);
  return y ;
}


double solveStep(double x1, double y1, double x2, double y2, double x) {
  // (x2 - x) / (x2 - x1) == (y2 - y) / (y2 - y1)
  // y = y2 - (x2 - x) * (y2 - y1) / (x2 - x1);
  if (x <= x1) return y1;
  if (x >= x2) return y2;

  final y = y2 - (x2 - x) * (y2 - y1) / (x2 - x1);
  return y ;
}




class _AnimatableGridLine {
  _AnimatableGridLine(int gridLineIndex) {
    final p1p2 = _getPoints(const Rect.fromLTWH(0, 0, 1, 1), gridLineIndex);
    endP1 = p1p2[0];
    endP2 = p1p2[1];
    p1 = ConstantTween<Offset>(endP1).animate(kAlwaysCompleteAnimation);
    p2 = ConstantTween<Offset>(endP2).animate(kAlwaysCompleteAnimation);
  }

  late Offset endP1, endP2;
  late Animation<Offset> p1, p2;

  static List<Offset> _getPoints(Rect fieldRect, int gridLineIndex) {
    /// returns two points which represents a grid line
    ///    0  1
    ///    |  |
    /// 2--+--+--
    ///    |  |
    /// 3--+--+--
    ///    |  |
    /// lineIndex :
    /// 0 - left vertical line
    /// 1 - right vertical line
    /// 2 - top horizontal line
    /// 3 - bottom horizontal line
    assert((gridLineIndex >= 0) && (gridLineIndex <= 3));
    switch (gridLineIndex) {
      case 0:
        return [
          Offset(fieldRect.width * (1 / 3), 0),
          Offset(fieldRect.width * (1 / 3), fieldRect.bottom),
        ];

      case 1:
        return [
          Offset(fieldRect.width * (2 / 3), 0),
          Offset(fieldRect.width * (2 / 3), fieldRect.bottom),
        ];

      case 2:
        return [
          Offset(fieldRect.left, fieldRect.height * (1 / 3)),
          Offset(fieldRect.right, fieldRect.height * (1 / 3)),
        ];

      case 3:
        return [
          Offset(fieldRect.left, fieldRect.height * (2 / 3)),
          Offset(fieldRect.right, fieldRect.height * (2 / 3)),
        ];
    }
    throw Exception('Invalid grid line index');
  }

  void draw(Canvas canvas, Rect fieldRect, Paint paint) {
    Offset rp1 = fieldRect.topLeft +
        Offset(p1.value.dx * fieldRect.width, p1.value.dy * fieldRect.height);
    Offset rp2 = fieldRect.topLeft +
        Offset(p2.value.dx * fieldRect.width, p2.value.dy * fieldRect.height);
    if (rp1 != rp2) canvas.drawLine(rp1, rp2, paint);
  }
}


class _GridPainter {
  _GridPainter(this.tickerProvider);

  void dispose() {
    _controller?.dispose();
  }

  List<_AnimatableGridLine> gridLines = [
    _AnimatableGridLine(0),
    _AnimatableGridLine(1),
    _AnimatableGridLine(2),
    _AnimatableGridLine(3),
  ];

  TickerProvider tickerProvider;

  AnimationController? _controller;
  AnimationController get controller => _controller!;

  static final _rand = Random.secure();


  void _animateZoom(Duration duration) {
    double val = _controller?.value ?? 0.0;
    final oldController = _controller;
    _controller = AnimationController(
        vsync: tickerProvider, duration: duration, value: val);

    for (var gl in gridLines) {
      final m = Offset.lerp(gl.endP1, gl.endP2, 0.5);
      gl.p1 = Tween<Offset>(begin: m, end: gl.endP1).animate(_controller!);
      gl.p2 = Tween<Offset>(begin: m, end: gl.endP2).animate(_controller!);
    }

    oldController?.dispose();
  }

  Future<void> showZoom(Duration duration) {
    _animateZoom(duration);
    return controller.forward();
  }

  Future<void> hideZoom(Duration duration) {
    _animateZoom(duration);
    return controller.reverse();
  }


  void _animateSequential(Duration duration) {
    double val = _controller?.value ?? 0.0;
    final oldController = _controller;
    _controller = AnimationController(
        vsync: tickerProvider, duration: duration, value: val);

    for (int i = 0; i < gridLines.length; i++) {
      final gl = gridLines[i];
      final begin = 0.4 * _rand.nextDouble();
      final end = begin + 0.3 + (1 - begin - 0.3) * _rand.nextDouble();

      gl.p2 = Tween<Offset>(begin: gl.endP1, end: gl.endP2).animate(
          CurvedAnimation(parent: _controller!, curve: Interval(begin, end)));
    }

    oldController?.dispose();
  }

  Future<void> showSequential(Duration duration) {
    _animateSequential(duration);
    return controller.forward();
  }

  Future<void> hideSequential(Duration duration) {
    _animateSequential(duration);
    return controller.reverse();
  }


  void paint(Canvas canvas, Rect fieldRect, Paint paint) {
    for (var l in gridLines) {
      l.draw(canvas, fieldRect, paint);
    }
  }
}


class _CellPainter {
  _CellPainter(
    this.game,
    this.cellIndex,
    TickerProvider tickerProvider)
      : assert(cellIndex >= 0 && cellIndex <= 8) {
    _controller = AnimationController(
      value: 1.0, 
      vsync: tickerProvider, 
      duration: null);
  }

  void dispose() {
    _controller.dispose();
  }

  final TicTacToe game;
  final int cellIndex;
  late AnimationController _controller;

  Future<void> animate(Duration duration) {
    _controller.duration = duration;
    return _controller.forward(from: 0.0);
  }


  Player? get player => game.cells[cellIndex];

  void paint(Canvas canvas, Rect cellRect, Paint paint) {
    if (player == null) return;
    if (_controller.value == 0.0) return;

    if (player == game.xPlayer) {
      drawX(canvas, cellRect, paint, _controller.value);
    }
    else { // if (player == game.oPlayer)
      drawO(canvas, cellRect, paint, _controller.value);
    }
  }


  static void drawOval(Canvas canvas, Rect rect, double t, Paint paint,
      {double startAngle = (-pi / 2)}) {
    if (t == 0.0) return;
    if (t >= 1.0) return canvas.drawOval(rect, paint);

    canvas.drawArc(rect, startAngle, (2 * pi * t), false, paint);
  }

  static void drawX(Canvas canvas, Rect r, Paint paint, [double t = 1.0]) {
    if (t <= 0.0) return;
    t = t.clamp(0.0, 1.0);
    canvas.drawLine(r.topLeft,
        Offset.lerp(r.topLeft, r.bottomRight, (2 * t.clamp(0.0, 0.5)))!, paint);

    if (t > 0.5) {
      canvas.drawLine(r.topRight,
        Offset.lerp(r.topRight, r.bottomLeft, (2 * (t - 0.5)))!, paint);
    }
  }

  static void drawO(Canvas canvas, Rect r, Paint paint, [double t = 1.0]) {
    drawOval(canvas, r, t, paint);
  }

} // _CellPainter


class _EndGamePainter {
  _EndGamePainter(
    this.fp, {
      required Duration duration,
    }) : assert(fp.game.progress == GameProgress.end) {
    if (fp.game.winner != null) {
      final winCells = fp.game.winnerCells;
      cell1 = winCells![0];
      cell2 = winCells[1];
      cell3 = winCells[2];
    } else if (fp.game.isDraw) {
      final xcells = <int>[], ocells = <int>[];
      for (int i = 0; i < fp.game.cells.length; i++) {
        if (fp.game.cells[i] == null) continue;
        if (fp.game.cells[i] == fp.game.xPlayer) {
          xcells.add(i);
        }
        else {
          ocells.add(i);
        }
      }

      assert(xcells.length >= 2 && ocells.length >= 2);
      final rand = Random.secure();
      cell1 = xcells[rand.nextInt(xcells.length)];
      cell2 = null;
      cell3 = ocells[rand.nextInt(ocells.length)];
    } 

    _controller = AnimationController(
      vsync: fp.tickerProvider, 
      duration: duration);
  }

  void dispose() {
    _controller.dispose();
  }

  _FieldPainter fp;
  late int cell1;
  late int? cell2;
  late int cell3;

 
  late AnimationController _controller;

  Future<void> animateShow(){
    return _controller.forward();
  }

  TextPainter createTextPainter(String text, Color color, Rect fieldRect, [double? fontSize]) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize ?? fieldRect.width * 0.12,
      // fontWeight: FontWeight.bold
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    return textPainter;
  }


  void paintWinner(Canvas canvas, Rect fieldRect, Paint paint, Color textColor, double t) {

    fp.scaleFactor = slerp(1, 0.7, 0.4, 0.7, t);
    fp.opacity = slerp(1, 0.0, 0.5, 0.9, t);
    fp.xAngle = slerp(0, -pi/2*0.8, 0.4, 0.9, t);

    if(t >= 2/3) {
      final dt = (t-2/3)/(1-2/3);
      final dr1 = _FieldPainter.cellRect(4, fieldRect);
      var dr2 = dr1.translate(0.0, -dr1.height * 1.1 * dt).inflate(dr1.width * 0.15 * dt);
      fp.cellPainters[cell1].paint(canvas, dr2, paint);  
      
      final textAlpha = 255 * dt;
      final tp = createTextPainter('WINNER', textColor.withAlpha(textAlpha.toInt()), fieldRect);
      tp.paint(canvas, Offset(dr2.center.dx - tp.width / 2, dr2.bottom + dr1.height*0.5));
      return;
    }
    
    var r1 = _FieldPainter.cellRect(cell1, fieldRect);
    var r2 = _FieldPainter.cellRect(cell2!, fieldRect);
    var r3 = _FieldPainter.cellRect(cell3, fieldRect);

    if (t > 1/3 && t < 2/3) {
      final dr = _FieldPainter.cellRect(4, fieldRect);
      
      r1 = Rect.lerp(r1, dr, (t-1/3)/(1/3))!;
      r2 = Rect.lerp(r2, dr, (t-1/3)/(1/3))!;
      r3 = Rect.lerp(r3, dr, (t-1/3)/(1/3))!;
    }
    
    fp.cellPainters[cell1].paint(canvas, r1, paint);
    fp.cellPainters[cell2!].paint(canvas, r2, paint);
    fp.cellPainters[cell3].paint(canvas, r3, paint);

    if (t < 2/3) {
      drawStroke(canvas, r1, r3, paint, ((t)/(1/3)).clamp(0.0, 1.0));
    }
  }


  void paintDraw(Canvas canvas, Rect fieldRect, Paint xPaint, Paint oPaint, Color textColor, double t) {
    fp.scaleFactor = slerp(1, 0.7, 0.25, 0.7, t);
    fp.opacity = slerp(1, 0.0, 0.4, 0.8, t);
    fp.xAngle = slerp(0, -pi/2*0.8, 0.4, 0.9, t);

    var r1 = _FieldPainter.cellRect(cell1, fieldRect);
    var r3 = _FieldPainter.cellRect(cell3, fieldRect);

    final dr = _FieldPainter.cellRect(4, fieldRect);
    var dr1 = dr.translate(-dr.width/2 - 10.0, 0.0);
    var dr3 = dr.translate(dr.width/2 + 10.0, 0.0);

    r1 = Rect.lerp(r1, dr1, slerp(0,1,0,0.5,t))!;
    r3 = Rect.lerp(r3, dr3, slerp(0,1,0,0.5,t))!;
    if(t > 0.5) {
      double dh = dr1.height * (2*(t-0.5));
      r1 = r1.translate(0.0, -dh);
      r3 = r3.translate(0.0, -dh);

      final textAlpha = 255 * slerp(0.0, 1.0, 0.5, 0.7, t);
      final tp = createTextPainter('DRAW', textColor.withAlpha(textAlpha.toInt()), fieldRect);
      var to  = Offset(dr.center.dx - tp.width / 2, dr1.bottom + dr1.height*0.5);
      to = to + Offset(0.0, -dh);

      tp.paint(canvas, to);
    }

    fp.cellPainters[cell1].paint(canvas, r1, xPaint);
    fp.cellPainters[cell3].paint(canvas, r3, oPaint);
  }


  void paint(Canvas canvas, Rect fieldRect, Paint xPaint, Paint oPaint, Color textColor) {
    if (fp.game.isDraw) {
      paintDraw(canvas, fieldRect, xPaint, oPaint, textColor, _controller.value);
    }
    else {
      final winPaint = (fp.game.winner == fp.game.xPlayer) ? xPaint : oPaint;
      paintWinner(canvas, fieldRect, winPaint, textColor, _controller.value);
    }

    if (_controller.value >= 1.0) {
      final tp = createTextPainter('Press to start new game', textColor.withAlpha(200), fieldRect, 16.0);
      final offset = Offset(
        fieldRect.center.dx - tp.width/2, 
        fieldRect.bottom - tp.height - 20);
      tp.paint(canvas, offset);
    }
  }


  static void drawStroke(Canvas canvas, Rect rect1, Rect rect2, Paint paint, double t) {
    var p1 = rect1.center;
    var p2 = rect2.center;

    if (p1 == p2) return;

    var m = p1 + (p2 - p1) * 0.5;
    p1 = m + (p1 - m) * 1.45;
    p2 = m + (p2 - m) * 1.45;

    canvas.drawLine(p1, p1 + (p2 - p1) * t, paint);
  }

}


class _FieldPainter extends CustomPainter {
  _FieldPainter(this.game, this.tickerProvider, {
      this.gridColor = Colors.blueGrey, //  Colors.blueGrey,
      this.xColor = Colors.indigo,
      this.oColor = Colors.red,
      this.textColor = Colors.blueGrey,
      this.strokeCap = StrokeCap.butt,
      Listenable? repaint})
      : assert(game.cells.length == 9),
        _gridPainter = _GridPainter(tickerProvider),
        super(repaint: repaint) {

    for (int i = 0; i < game.cells.length; i++) {
      cellPainters.add(_CellPainter(game, i, tickerProvider));
    }
  }

  void dispose() {
    _gridPainter.dispose();
    _endGamePainter?.dispose();
    for (var cellPainter in cellPainters) {
      cellPainter.dispose();
    }
  }


  TicTacToe game;
  TickerProvider tickerProvider;

  Color gridColor;
  Color xColor;
  Color oColor;
  Color textColor;
  StrokeCap strokeCap;

  double scaleFactor = 1.0;
  double xAngle = 0.0;
  double opacity = 1.0;


  final _GridPainter _gridPainter;
  final cellPainters = <_CellPainter>[];
  _EndGamePainter? _endGamePainter;
  

  static double xoWidth(Rect fieldRect) => 
    (fieldRect.width + fieldRect.height) / 2 * 0.03;


  static double cellPadding(Rect fieldRect) => 
    (fieldRect.width + fieldRect.height) * 0.03;


  static double gridLineWidth(Rect fieldRect) => 
    (fieldRect.width + fieldRect.height) / 2 * 0.025;


  static Rect cellRectRaw(int cellIndex, Rect fieldRect, 
      double gridLineWidth, double padding) {
    assert((cellIndex >= 0) && (cellIndex <= 8));

    final int i = cellIndex % 3;
    final int j = cellIndex ~/ 3;
    final double width = (fieldRect.width - 2 * gridLineWidth) / 3.0;
    final double height = (fieldRect.height - 2 * gridLineWidth) / 3.0;
    final double x = fieldRect.left + width * i + gridLineWidth * i;
    final double y = fieldRect.top + height * j + gridLineWidth * j;

    return Rect.fromLTWH(x, y, width, height).deflate(padding);
  }


  static cellRect(int cellIndex, Rect fieldRect) => cellRectRaw(
    cellIndex, fieldRect, gridLineWidth(fieldRect), cellPadding(fieldRect));


  static Paint xPaint(Rect fieldRect, Color xColor, StrokeCap strokeCap) => Paint()
    ..color = xColor
    ..strokeWidth = xoWidth(fieldRect)
    ..strokeCap = strokeCap
    ..style = PaintingStyle.stroke;

  static Paint oPaint(Rect fieldRect, Color oColor, StrokeCap strokeCap) => Paint()
    ..color = oColor
    ..strokeWidth = xoWidth(fieldRect)
    ..strokeCap = strokeCap
    ..style = PaintingStyle.stroke;

  static Paint gridPaint(Rect fieldRect, Color gridColor, StrokeCap strokeCap) => Paint()
    ..color = gridColor
    ..strokeWidth = gridLineWidth(fieldRect) * 0.8
    ..strokeCap = strokeCap
    ..style = PaintingStyle.stroke;
  

  Future<void> animateEndGame(Duration duration) {
    if (game.progress != GameProgress.end) {
      throw Exception('Game is not finished');
    }
    
    // TODO: consider returning real future
    if(_endGamePainter != null) {
      return Future.value();
    }

    _endGamePainter = _EndGamePainter(this, duration: duration);
    return _endGamePainter!.animateShow();
  }


  Future<void> showGridZoom(Duration duration) {
    return _gridPainter.showZoom(duration);
  }

  Future<void> showGridSequenial(Duration duration) {
    return _gridPainter.showSequential(duration);
  }



  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);

    final saveCanvas = xAngle != 0.0 || scaleFactor != 1.0;
    if (saveCanvas) canvas.save();  

    if (scaleFactor != 1.0) {
      final hw = r.width / 2.0;
      final hh = r.height / 2.0;
      canvas.translate(hw, hh);
      canvas.scale(scaleFactor);   
      canvas.translate(-hw, -hh); 
    }

    if (xAngle != 0.0) {
      final transformRotation = Matrix4.identity();
      transformRotation.setEntry(3, 2, 0.002);
      transformRotation.rotateX(xAngle);
      Offset translation = Offset(size.width * 0.5, size.height * 1);
      final Matrix4 transformResult = Matrix4.identity();
      transformResult.translate(translation.dx, translation.dy);
      transformResult.multiply(transformRotation);
      transformResult.translate(-translation.dx, -translation.dy);
      canvas.transform(transformResult.storage);
    }

    final _gridPaint = gridPaint(r, gridColor.withOpacity(opacity), strokeCap);
    final _xPaint = xPaint(r, xColor.withOpacity(opacity), strokeCap);
    final _oPaint = oPaint(r, oColor.withOpacity(opacity), strokeCap);

    _gridPainter.paint(canvas, r, _gridPaint);

    for (int i = 0; i < cellPainters.length; i++) {
      if (game.cells[i] == null) continue;
      
      if (_endGamePainter != null) {
        if (i == _endGamePainter!.cell1 ||
            i == _endGamePainter!.cell2 ||
            i == _endGamePainter!.cell3) continue;
      }

      final paint = (game.cells[i] == game.xPlayer) ? _xPaint : _oPaint;
      cellPainters[i].paint(canvas, cellRect(i, r), paint);
    }

    if (saveCanvas) canvas.restore();

    if (_endGamePainter != null) {
      _xPaint.color = _xPaint.color.withOpacity(1.0);
      _oPaint.color = _oPaint.color.withOpacity(1.0);
      _endGamePainter?.paint(canvas, r, _xPaint, _oPaint, textColor);
    }

  } // paint

  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}


class Field extends StatefulWidget {
  const Field(
      {Key? key,
      required this.game,
      this.onGameChanged,
      this.onGameEnded,
      this.onNewGameRequest,
      this.gridColor = Colors.blueGrey,
      this.xColor = Colors.indigo,
      this.oColor = Colors.red,
      this.textColor = Colors.blueGrey,
      this.strokeCap = StrokeCap.butt,
      this.gridAnimationDuration = const Duration(milliseconds: 1000),
      this.cellAnimationDuration = const Duration(milliseconds: 500),
      this.endgameAnimationDuration = const Duration(milliseconds: 2000),

      this.computerMoveDelay = const Duration(milliseconds: 250),
      
      this.animateGridOnCreate = true
      })
      : super(key: key);

  final TicTacToe game;
  final void Function(Future<void>?)? onGameChanged;
  final void Function(Future<void>?)? onGameEnded;
  final void Function()? onNewGameRequest;

  final Color gridColor;
  final Color xColor;
  final Color oColor;
  final Color textColor;
  final StrokeCap strokeCap;

  final Duration gridAnimationDuration;
  final Duration cellAnimationDuration;
  final Duration endgameAnimationDuration;


  final Duration computerMoveDelay;


  final bool animateGridOnCreate;


  @override
  _FieldState createState() => _FieldState();
}


class _FieldState extends State<Field> with TickerProviderStateMixin {
  late AnimationController _controller;

  late _FieldPainter _fieldPainter;
  final GlobalKey _key = GlobalKey(); // used to get widget's size

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.repeat(period: Duration(seconds: 60));

    _fieldPainter = _createFieldPainter();

    if(widget.animateGridOnCreate) {
      if (Random(DateTime.now().millisecondsSinceEpoch).nextInt(2) == 0) {
        _fieldPainter.showGridZoom(widget.gridAnimationDuration);
      }
      else {
        _fieldPainter.showGridSequenial(widget.gridAnimationDuration);
      }
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    _fieldPainter.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Field oldWidget) {
    super.didUpdateWidget(oldWidget);

    _fieldPainter.gridColor = widget.gridColor;
    _fieldPainter.xColor= widget.xColor;
    _fieldPainter.oColor = widget.oColor;
    _fieldPainter.textColor = widget.textColor;
    _fieldPainter.strokeCap = widget.strokeCap;

    if (oldWidget.game != widget.game) {
      setState(() {
        _fieldPainter.dispose();
        _fieldPainter = _createFieldPainter();
        if (Random(DateTime.now().millisecondsSinceEpoch).nextInt(2) == 0) {
          _fieldPainter.showGridZoom(widget.gridAnimationDuration);
        }
        else {
          _fieldPainter.showGridSequenial(widget.gridAnimationDuration);
        }
      });
    }

    // hack
    // TODO: write explanation
    bool shouldAnimateCell = 
      (widget.game.xPlayer.type == PlayerType.computer) && 
      (widget.game.vacantCellsCount == 8);

    if (shouldAnimateCell) {
      int cellIndex = widget.game.cells.indexWhere((element) => element != null);
      _fieldPainter.cellPainters[cellIndex].animate(widget.cellAnimationDuration);
    } 

  }


  _FieldPainter _createFieldPainter() {
    return _FieldPainter(
      widget.game, 
      this, 
      repaint: _controller,
      gridColor: widget.gridColor,
      xColor: widget.xColor,
      oColor: widget.oColor,
      textColor: widget.textColor,
      strokeCap: widget.strokeCap
    );
  }


  void onCellTap(int cellIndex) {
    assert(cellIndex >= 0 && cellIndex <= 8);
    if (!widget.game.canMakeMove || widget.game.cells[cellIndex] != null) return;

    widget.game.makeMove(cellIndex);
    final f = _fieldPainter.cellPainters[cellIndex].animate(widget.cellAnimationDuration);
    widget.onGameChanged?.call(f);
    f.then((value){
      if (widget.game.progress == GameProgress.end) {
        final f2 = _fieldPainter.animateEndGame(widget.endgameAnimationDuration);
        widget.onGameEnded?.call(f2);
      }
      else {
        if (widget.game.currentPlayer.type == PlayerType.computer){
          int nextMove = widget.game.getNextMove(widget.game.difficulty);
          // short delay before computer make move
          Future.delayed(widget.computerMoveDelay, () => onCellTap(nextMove));
        }
      }
    });
  }


  void onTapDown(TapDownDetails details) {
    if(widget.game.progress == GameProgress.end){
      widget.onNewGameRequest?.call();
      return;
    }

    if(widget.game.currentPlayer.type != PlayerType.human) return;

    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final col = (details.localPosition.dx ~/ (box.size.width / 3.0));
    final row = (details.localPosition.dy ~/ (box.size.height / 3.0));
    onCellTap(row * 3 + col);
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: GestureDetector(
            onTapDown: onTapDown,
            child: CustomPaint(
              key: _key,
              painter: _fieldPainter,
              // child: Container(color: widget.bgColor, width: 400, height: 400,),
            ),
          ),
        ),
      ),
    );
  }
}

