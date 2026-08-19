import 'package:flutter/material.dart';

double sHeight(BuildContext context) => MediaQuery.of(context).size.height;
double sWidth(BuildContext context) => MediaQuery.of(context).size.width;

SizedBox heightGap(double h) => SizedBox(height: h);
SizedBox widthGap(double w) => SizedBox(width: w);
