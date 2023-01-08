import 'package:flutter/cupertino.dart';

class InBodyChartPainter extends CustomPainter {
  Type type;
  InBodyPaint inBodyPaint;
  var processValue = 0.0;

  InBodyChartPainter(
      {required this.inBodyPaint,required this.processValue,this.type = const Type(0.0, 38.9, 46.8, 52.7, (46.8 / 0.5))});

  @override
  void paint(Canvas canvas, Size size) {
    const chartBoundsTop = 0.0;
    final chartBoundsBottom = size.height;
    const chartBoundsStart = 0.0;
    final chartBoundsEnd = size.width;

    const topPadding = 50.0; //textPaint.textSize
    const bottomPadding = 50.0; //textPaint.textSize
    const chartHPadding = 8.0;

    final chartWidth = chartBoundsEnd - 2 * chartHPadding;
    const startX = chartBoundsStart;
    const startY = chartBoundsTop + topPadding;

    final progressHigh = (chartBoundsBottom - topPadding - bottomPadding) / 3;
    final progressStartY = startY + progressHigh;
    final progressEndY = progressStartY + progressHigh;

    //刻度線
    var tickMarkEndY = (chartBoundsBottom - bottomPadding);

    //刻度線的x位置
    List<double> list = [];
    var stepValue = chartWidth ~/ 10;
    if (chartWidth > 0 && startX >= 0) {
      var start = (chartBoundsStart + chartHPadding);
      //val end = (chartBounds.end - chartHPadding).toInt()
      for (var value = 0; value <= 10; value++) {
        var pointX = start + value * stepValue;
        list.insert(value, pointX);
      }
    }

    {

      var lowestValuePaint = Paint()
        ..color = inBodyPaint.lowest
        ..style = PaintingStyle.fill;
      var standardValuePaint = Paint()
        ..color = inBodyPaint.standard
        ..style = PaintingStyle.fill;
      var highestValuePaint = Paint()
        ..color = inBodyPaint.highest
        ..style = PaintingStyle.fill;

      if (0.0 <= processValue && processValue <= type.lowestValue) {
        //var end = list[0];
        //var p1 = Offset(startX, progressStartY);
        //final p2 = Offset(end, progressEndY);
        Rect rect = Offset(startX, progressStartY) & Size(list[0], progressHigh);
        canvas.drawRect(rect, lowestValuePaint);
      } else if (type.lowestValue <= processValue &&
          processValue <= type.standardLowValue) {
        var chartOneUnitValue =
            chartWidth * 0.2 / (type.standardLowValue - type.lowestValue);
        var progressWidth = (processValue - type.lowestValue) * chartOneUnitValue;

        Rect rect = Offset(startX, progressStartY) & Size(list[0], progressHigh);
        canvas.drawRect(rect, lowestValuePaint);

        Rect rectLow =
            Offset(list[0], progressStartY) & Size(progressWidth, progressHigh);
        canvas.drawRect(rectLow, lowestValuePaint);
      } else if (type.standardLowValue <= processValue &&
          processValue <= type.standardValue) {
        var chartOneUnitValue =
            chartWidth * 0.1 / (type.standardValue - type.standardLowValue);
        var standardStart = list[2];
        var progressWidth = (processValue - type.standardLowValue) * chartOneUnitValue;

        //低
        Rect rectLow =
            Offset(startX, progressStartY) & Size(standardStart, progressHigh);
        canvas.drawRect(rectLow, lowestValuePaint);

        //標準
        Rect rectStander = Offset(standardStart, progressStartY) &
            Size(progressWidth, progressHigh);
        canvas.drawRect(rectStander, standardValuePaint);
      } else if (type.standardValue <= processValue &&
          processValue <= type.standardHighValue) {
        var chartOneUnitValue =
            chartWidth * 0.1 / (type.standardHighValue - type.standardValue);
        var standardStart = list[2];
        var progressWidth = (processValue - type.standardValue) * chartOneUnitValue;

        //低
        Rect rectLow =
            Offset(startX, progressStartY) & Size(standardStart, progressHigh);
        canvas.drawRect(rectLow, lowestValuePaint);

        //標準
        Rect rectStander = Offset(list[2], progressStartY) &
            Size(list[3]-list[2]+progressWidth, progressHigh);
        canvas.drawRect(rectStander, standardValuePaint);
      } else if (type.standardHighValue <= processValue &&
          processValue <= type.highestValue) {
        var chartOneUnitValue =
            chartWidth * 0.6 / (type.highestValue - type.standardHighValue);
        var standardStart = list[2];
        var standardEnd = list[4];
        var progressWidth =
            (processValue - type.standardHighValue) * chartOneUnitValue;

        //低
        Rect rectLow =
            Offset(startX, progressStartY) & Size(standardStart, progressHigh);
        canvas.drawRect(rectLow, lowestValuePaint);

        //標準
        Rect rectStander = Offset(standardStart, progressStartY) &
            Size(list[4]-list[2], progressHigh);
        canvas.drawRect(rectStander, standardValuePaint);

        //高
        Rect rectHeight = Offset(standardEnd, progressStartY) &
            Size(progressWidth, progressHigh);
        canvas.drawRect(rectHeight, highestValuePaint);
      } else {
        var standardStart = list[2];
        var standardEnd = list[4];
        var highestEnd = chartBoundsEnd;

        //低
        Rect rectLow =
            Offset(startX, progressStartY) & Size(standardStart, progressHigh);
        canvas.drawRect(rectLow, lowestValuePaint);

        //標準
        Rect rectStander = Offset(standardStart, progressStartY) &
            Size(list[4]-list[2], progressHigh);
        canvas.drawRect(rectStander, standardValuePaint);

        //高
        Rect rectHeight = Offset(standardEnd, progressStartY) &
            Size(chartBoundsEnd-list[4], progressHigh);
        canvas.drawRect(rectHeight, highestValuePaint);
      }
    }

    {
      const textStyle = TextStyle(
        color: Color(0xFFABACAE),
        fontSize: 16,
      );

      drawLabel(
          canvas,
          Offset(
            list[1] - (textStyle.fontSize! / 2),
            startY - (textStyle.fontSize! * 1.5),
          ),
          text: '低',
          textStyle: textStyle);

      drawLabel(
          canvas,
          Offset(
            list[3] - (textStyle.fontSize!),
            startY - (textStyle.fontSize! * 1.5),
          ),
          text: '標準',
          textStyle: textStyle);

      drawLabel(
          canvas,
          Offset(
            list[7] - (textStyle.fontSize! / 2),
            startY - (textStyle.fontSize! * 1.5),
          ),
          text: '高',
          textStyle: textStyle);

      //有小數點，顯示;無小數點，不顯示
      if ((type.standardLowValue % 1) > 0) {
        //standardLowValue
        drawLabel(
            canvas,
            Offset(
              list[2] - (textStyle.fontSize!),
              tickMarkEndY + (textStyle.fontSize!*0.125),
            ),
            text: format(type.standardLowValue),
            textStyle: textStyle);
      } else {
        //standardLowValue
        drawLabel(
            canvas,
            Offset(
              list[2] - (textStyle.fontSize! / 2),
              tickMarkEndY + (textStyle.fontSize!*0.125),
            ),
            text: format(type.standardLowValue),
            textStyle: textStyle);
      }


      if ((type.standardHighValue % 1) > 0) {
        //standardLowValue
        drawLabel(
            canvas,
            Offset(
              list[4] - (textStyle.fontSize!),
              tickMarkEndY + (textStyle.fontSize!*0.125),
            ),
            text: format(type.standardHighValue),
            textStyle: textStyle);
      } else {
        //standardHighValue
        drawLabel(
            canvas,
            Offset(
              list[4] - (textStyle.fontSize! / 2),
              tickMarkEndY + (textStyle.fontSize!*0.125),
            ),
            text: format(type.standardHighValue),
            textStyle: textStyle);
      }
    }

    //Ｘ軸
    {
      const lineWidth = 1.0;
      final paint = Paint()
        ..color = const Color(0xFFABACAE)
        ..strokeWidth = lineWidth;
      {
        const p1 = Offset(chartBoundsStart, startY);
        final p2 = Offset(chartBoundsEnd, startY);

        canvas.drawLine(p1, p2, paint);
      }
      {
        const p1 = Offset(startX + (lineWidth / 2), startY);
        final p2 = Offset(startX + (lineWidth / 2), tickMarkEndY);
        //Y軸
        canvas.drawLine(p1, p2, paint);
      }

      if (chartWidth > 0 && startX >= 0) {
        for (var pointX in list) {
          final p1 = Offset(pointX, startY);
          final p2 = Offset(pointX, tickMarkEndY);
          final p3 = Offset(pointX, startY + 10);

          if (list[2] == pointX || list[4] == pointX) {
            canvas.drawLine(p1, p2, paint);
          } else {
            canvas.drawLine(p1, p3, paint);
          }
        }
      }
    }
  }

  void drawLabel(Canvas canvas, Offset offset,
      {required String text, required TextStyle textStyle}) {
    var textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  static String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}

enum  InBodyPaint{
  male( Color(0xff0aff7a),Color(0xff03e956),Color(0xff00a52b)),
  female( Color(0xffff0a7a),Color(0xffe90356),Color(0xffa5002b)),
  ;
  const InBodyPaint(
      this.lowest,
      this.standard,
      this.highest,
      );

  final Color lowest;
  final Color standard;
  final Color highest;
}

class Type {
  const Type(
    this.lowestValue,
    this.standardLowValue,
    this.standardValue,
    this.standardHighValue,
    this.highestValue,
  );

//最低值
  final double lowestValue;

//標準低值
  final double standardLowValue;

//標準值
  final double standardValue;

//標準高值
  final double standardHighValue;

//最高值
  final double highestValue;
}
