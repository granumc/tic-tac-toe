
import 'package:flutter/material.dart';

class AppTheme {

  AppTheme({
    required this.name,
    this.captionColor = Colors.black87,
    this.hintColor = Colors.black87,
    this.bgColor = Colors.white,
    this.gridColor = Colors.blueGrey,
    this.xColor = Colors.indigo,
    this.oColor = Colors.red,
    this.textColor = Colors.blueGrey,
    });

  final String name;

  final Color captionColor;
  final Color hintColor;

  final Color bgColor;
  final Color gridColor;
  final Color xColor;
  final Color oColor;
  final Color textColor;

  static Map<String, AppTheme> themes = {
    defaultTheme.name: defaultTheme,
    tealTheme.name: tealTheme,
    choice01Theme.name: choice01Theme,
    choice02Theme.name: choice02Theme,
    theme2.name: theme2,
    deepGreenTheme.name: deepGreenTheme,
    mermaidLagoonTheme.name: mermaidLagoonTheme,
    fuchsiaTheme.name: fuchsiaTheme
  };
}


final defaultTheme = AppTheme(name: 'Default');


final tealTheme = AppTheme(
  name: 'Teal',
  captionColor: Color(0xff07443E),
  hintColor: Color(0xff0c756a),

  bgColor: Color(0xff14bdac),
  gridColor: Color(0xff0da192),
  xColor: Color(0xff545454),
  oColor: Color(0xfff2ebd3),
  textColor: Color(0xff07443E),
);


final choice01Theme = AppTheme(
  name: 'Choice 01',
  captionColor: Color(0xff07443E),
  hintColor: Color(0xff0c756a),

  bgColor: Color(0xfff0eeef),
  gridColor: Color(0xffcfcdcb),
  xColor: Color(0xff025b0e),
  oColor: Color(0xfffd7c84),
  textColor: Color(0xff07443E),
);


final choice02Theme = AppTheme(
  name: 'Choice 02',
  captionColor: Color(0xfff07167),
  hintColor: Color(0xfff07167),

  bgColor: Color(0xfffdfcdc),
  gridColor: Color(0xfffed9b7),
  xColor: Color(0xff0081a7),
  oColor: Color(0xfff07167),
  textColor: Color(0xff00afb9),
);


final theme2 = AppTheme(
  name: 'Theme 2',
  captionColor: Color(0xffffffff),
  hintColor: Color(0xffffffff),

  bgColor: Color(0xffaacd7e),
  gridColor: Color(0xffcfe4b6),
  xColor: Color(0xff47aad5),
  oColor: Color(0xffee907f),
  textColor: Color(0xffffffff),
);


final deepGreenTheme = AppTheme(
  name: 'Deep green',
  captionColor: Color(0xff3D550C),
  hintColor: Color(0xffffffff),

  bgColor: Color(0xff59981A),
  gridColor: Color(0xff81B622),
  xColor: Color(0xff3D550C),
  oColor: Color(0xffECF87F),
  textColor: Color(0xffffffff),
);


final mermaidLagoonTheme = AppTheme(
  name: 'Mermaid Lagoon',
  captionColor: Color(0xff2E8BC0),
  hintColor: Color(0xffffffff),

  bgColor: Color(0xff145DA0),
  gridColor: Color(0xff2E8BC0),
  // xColor: Color(0xff0C2D48),
  xColor: Color(0xffB1D4E0),
  oColor: Color(0xffe6f8ff),
  textColor: Color(0xffffffff),
);


final fuchsiaTheme = AppTheme(
  name: 'Fuchsia',
  captionColor: Color(0xffF0E5D0),
  hintColor: Color(0xffffffff),

  bgColor: Color(0xffFA3980),
  gridColor: Color(0xffF90067),
  xColor: Color(0xffEECAC9),
  oColor: Color(0xffF0E5D0),
  textColor: Color(0xffffffff),
);

