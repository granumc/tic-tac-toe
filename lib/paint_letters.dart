import 'dart:ui';
import 'dart:math';


void drawW(Canvas canvas, Rect rect, Paint paint, [double t = 1.0]) {
  final a = <Offset>[
    rect.topLeft,
    Offset.lerp(rect.bottomLeft, rect.bottomRight, 0.25)!,
    Offset.lerp(rect.topCenter, rect.bottomCenter, 0.25)!,
    Offset.lerp(rect.bottomLeft, rect.bottomRight, 0.75)!,
    rect.topRight,
  ];

  if (t >= 1.0) {
    canvas.drawPoints(PointMode.polygon, a, paint);
    return;
  }

  const w = [
    [0.0, 0.25],
    [0.25, 0.5],
    [0.5, 0.75],
    [0.75, 1.0],
  ];

  for (int i = 0; i < a.length - 1; i++) {
    if (w[i][0] < t) {
      if (w[i][1] <= t) {
        canvas.drawLine(a[i], a[i + 1], paint);
      }
      else {
        canvas.drawLine(
            a[i],
            Offset.lerp(a[i], a[i + 1], (t - w[i][0]) / (w[i][1] - w[i][0]))!,
            paint);
      }
    }
  }
}

void drawN(Canvas canvas, Rect rect, Paint paint, [double t = 1.0]) {
  final a = <Offset>[
    rect.bottomLeft,
    rect.topLeft,
    rect.bottomRight,
    rect.topRight
  ];

  if (t >= 1.0) {
    canvas.drawPoints(PointMode.polygon, a, paint);
    return;
  }

  const w = [
    [0.0, 1 / 3],
    [1 / 3, 2 / 3],
    [2 / 3, 1],
  ];

  for (int i = 0; i < a.length - 1; i++) {
    if (w[i][0] < t) {
      if (w[i][1] <= t) {
        canvas.drawLine(a[i], a[i + 1], paint);
      } else {
        canvas.drawLine(
            a[i],
            Offset.lerp(a[i], a[i + 1], (t - w[i][0]) / (w[i][1] - w[i][0]))!,
            paint);
      }
    }
  }
}

void drawD(Canvas canvas, Rect rect, Paint paint, [double t = 1.0]) {
  t = t.clamp(0.0, 1.0);
  if (t >= 0.3) {
    canvas.drawLine(rect.topLeft, rect.bottomLeft, paint);
  }
  else {
    canvas.drawLine(rect.topLeft,
        Offset.lerp(rect.topLeft, rect.bottomLeft, t / 0.3)!, paint);
  }

  final r = Rect.fromCenter(
      center: rect.centerLeft, width: rect.width * 2, height: rect.height);

  if (t > 0.3) {
    canvas.drawArc(r, -pi / 2, pi * ((t - 0.3) / 0.7), false, paint);
  }
}

void drawR(Canvas canvas, Rect rect, Paint paint, [double t = 1.0]) {
  t = t.clamp(0.0, 1.0);

  if (t >= 0.4) {
    canvas.drawLine(rect.topLeft, rect.bottomLeft, paint);
  } else {
    canvas.drawLine(rect.topLeft,
        Offset.lerp(rect.topLeft, rect.bottomLeft, t / 0.4)!, paint);
  }

  final r = Rect.fromLTWH(
      rect.left - rect.width, rect.top, rect.width * 2, rect.height / 2);

  if (t >= 0.8) {
    canvas.drawArc(r, -pi / 2, pi, false, paint);
  } else if (t > 0.4) {
    canvas.drawArc(r, -pi / 2, pi * ((t - 0.4) / 0.4), false, paint);
  }

  if (t > 0.8) {
    canvas.drawLine(
        rect.centerLeft,
        Offset.lerp(rect.centerLeft, rect.bottomRight, (t - 0.8) / 0.2)!,
        paint);
  }
}

void drawA(Canvas canvas, Rect rect, Paint paint, [double t = 1.0]) {
  t = t.clamp(0.0, 1.0);

  if (t >= 0.4) {
    canvas.drawLine(rect.bottomLeft, rect.topCenter, paint);
  } 
  else {
    canvas.drawLine(rect.bottomLeft,
        Offset.lerp(rect.bottomLeft, rect.topCenter, t / 0.4)!, paint);
  }

  if (t >= 0.8) {
    canvas.drawLine(rect.topCenter, rect.bottomRight, paint);
  } 
  else if (t > 0.4) {
    canvas.drawLine(
        rect.topCenter,
        Offset.lerp(rect.topCenter, rect.bottomRight, (t - 0.4) / 0.4)!,
        paint);
  }

  final p1 = Offset.lerp(rect.bottomLeft, rect.topCenter, 0.5)!;
  final p2 = Offset.lerp(rect.topCenter, rect.bottomRight, 0.5)!;

  if (t >= 0.8) {
    canvas.drawLine(p1, Offset.lerp(p1, p2, (t - 0.8) / 0.2)!, paint);
  }
}

void drawX(Canvas canvas, Rect r, Paint paint, [double t = 1.0]) {
  if (t <= 0.0) return;
  t = t.clamp(0.0, 1.0);
  canvas.drawLine(r.topLeft,
      Offset.lerp(r.topLeft, r.bottomRight, (2 * t.clamp(0.0, 0.5)))!, paint);

  if (t > 0.5) {
    canvas.drawLine(r.topRight,
        Offset.lerp(r.topRight, r.bottomLeft, (2 * (t - 0.5)))!, paint);
  }
}

void drawOval(Canvas canvas, Rect rect, double t, Paint paint,
    {double startAngle = (-pi / 2)}) {
  if (t == 0.0) return;
  if (t >= 1.0) return canvas.drawOval(rect, paint);

  canvas.drawArc(rect, startAngle, (2 * pi * t), false, paint);
}


void drawO(Canvas canvas, Rect r, Paint paint, [double t = 1.0]) {
  drawOval(canvas, r, t, paint);
}

