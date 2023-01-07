import 'dart:math';

import 'package:flutter/material.dart';

import 'in_body_chart_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var height = 0.0;
  var weight = 0.0;
  var valueBMI = 0.0;
  var valueBMI2 = 0.0;
  var age = 0;
  Sex? sex = Sex.male;
  InBodyPaint inBodyPaint = InBodyPaint.male;

  //體脂率
  var bodyFatPercentage = 0.0;
  var basalMetabolicRate = 0.0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    var textEditorWidth = width * 0.6;

    var textEditorHeight = SizedBox(
      width: textEditorWidth,
      child: TextField(
        keyboardType: TextInputType.number,
        onChanged: (text) {
          height = double.parse(text);
        },
      ),
    );

    var textEditorWeight = SizedBox(
      width: textEditorWidth,
      child: TextField(
        keyboardType: TextInputType.number,
        onChanged: (text) {
          weight = double.parse(text);
        },
      ),
    );

    var textEditorAge = SizedBox(
      width: textEditorWidth,
      child: TextField(
        keyboardType: TextInputType.number,
        onChanged: (text) {
          age = int.parse(text);
        },
      ),
    );

    //https://www.commonhealth.com.tw/article/87332
    Text textInfo = const Text('世界衛生組織計算標準體重之方法:'
        '\n男性: （身高cm－80）×70﹪＝標準體重'
        '\n女性: （身高cm－70）×60﹪＝標準體重'
        '\n標準體重±10﹪＝為正常體重'
        '\n標準體重±10﹪~ 20﹪＝為體重過重或過輕'
        '\n標準體重±20﹪~＝以上為肥胖或體重不足'
        '\n超重%＝｛（實際體重－理想體重）／（理想體重）｝×100%');

    var standardValue = 0.0;
    switch (sex) {
      case Sex.male:
        standardValue = (height - 80) * 0.7;
        break;
      case Sex.female:
        standardValue = (height - 70) * 0.6;
        break;
    }
    if (standardValue < 0) standardValue = 0;

    var standardLowValue = standardValue - standardValue * 0.1;
    if (standardLowValue < 0) standardLowValue = 0;

    var standardHighValue = standardValue + standardValue * 0.1;
    if (standardHighValue < 0) standardHighValue = 0;

    var highestValue = standardValue / 0.5;
    if (highestValue < 0) highestValue = 0;

    var overWeightPercentage = 0.0;
    if (standardValue > 0) {
      overWeightPercentage = (weight - standardValue) / standardValue * 100;
    }

    if (weight != 0 && height != 0) {
      valueBMI = weight / (pow(height / 100, 2));
      valueBMI2 = 1.3 * weight / pow(height / 100, 2.5);

      //1.2 x BMI + 0.23 x 年齡 – 5.4 -10.8 x 性別（男生的值為 1，女生為 0）
      if (age > 0) {
        basalMetabolicRate = 10 * weight + 6.25 * height;

        switch (sex) {
          case Sex.male:
            bodyFatPercentage = 1.2 * valueBMI2 + 0.23 * age - 5.4 - 10.8;
            if (age >= 50) {
              basalMetabolicRate -= age;
              basalMetabolicRate += 5;
            }
            break;
          case Sex.female:
            bodyFatPercentage = 1.2 * valueBMI2 + 0.23 * age - 5.4;
            if (age >= 50) {
              basalMetabolicRate -= age;
              basalMetabolicRate -= 161;
            }
            break;
        }
      }
    }

    switch (sex) {
      case Sex.male:
        inBodyPaint = InBodyPaint.male;
        break;
      case Sex.female:
        inBodyPaint = InBodyPaint.female;
        break;
    }

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Center(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    //textInfo,
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("體重:   \n$weight"),
                      SizedBox(
                        height: 140,
                        width: 250,
                        child: CustomPaint(
                            painter: InBodyChartPainter(
                              inBodyPaint: inBodyPaint,
                          processValue: weight,
                          type: Type(0.0, standardLowValue, standardValue,
                              standardHighValue, highestValue),
                        )),
                      ),
                    ]),
                    Text("標準體重：${InBodyChartPainter.format(standardValue)}"),
                    Text(
                        "超重：${InBodyChartPainter.format(overWeightPercentage)}%"),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                          "新制BMI:   \n${InBodyChartPainter.format(valueBMI2)}"),
                      SizedBox(
                        height: 140,
                        width: 250,
                        child: CustomPaint(
                            painter: InBodyChartPainter(

                              inBodyPaint: inBodyPaint,
                          processValue: valueBMI2,
                          type: const Type(0.0, 18.5, 22.0, 24.0, 55.0),
                        )),
                      ),
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(
                          "體脂率:   \n${InBodyChartPainter.format(bodyFatPercentage)}%"),
                      SizedBox(
                        height: 140,
                        width: 250,
                        child: CustomPaint(

                            painter: InBodyChartPainter(
                              inBodyPaint: inBodyPaint,
                          processValue: bodyFatPercentage,
                          type: const Type(0.0, 10.0, 15.0, 20.0, 50.0),
                        )),
                      ),
                    ]),
                    Text(
                        "基礎代謝率：${InBodyChartPainter.format(basalMetabolicRate)}"),
                    SizedBox(
                      width: 140,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<Sex>(
                                  value: Sex.male,
                                  groupValue: sex,
                                  onChanged: (Sex? value) {
                                    setState(() {
                                      sex = value;
                                    });
                                  },
                                ),
                                const Text('男')
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Row(
                              children: [
                                Radio<Sex>(
                                  value: Sex.female,
                                  groupValue: sex,
                                  onChanged: (Sex? value) {
                                    setState(() {
                                      sex = value;
                                    });
                                  },
                                ),
                                const Text('女')
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("身高："),
                        textEditorHeight,
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("體重："),
                        textEditorWeight,
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("年齡："),
                        textEditorAge,
                      ],
                    ),
                    TextButton(
                      onPressed: () async {
                        setState(() {});
                      },
                      child: const Text('產生圖表'),
                    ),
                  ],
                ),
                // This trailing comma makes auto-formatting nicer for build methods.
              ),
            ],
          ),
        ));
  }
}

enum Sex { male, female }
