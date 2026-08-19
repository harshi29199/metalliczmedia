import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart'; // For Offset

class CameraElementData {
  final File imageFile;
  final String height;
  final String width;
  final String comment;
  final String element;
  final Offset? markerStart; // start point of marker rectangle
  final Offset? markerEnd; // end point of marker rectangle

  CameraElementData({
    required this.imageFile,
    required this.height,
    required this.width,
    required this.comment,
    required this.element,
    this.markerStart,
    this.markerEnd,
  });
}

Future<Map<String, String>> generateExcelAndPDF({
  required List<CameraElementData> data,
  required File? buildingImage,
  required File? gsbImage,
  required String address,
  required String city,
  required String branchName,
  required String bmId,
  required String mmId,
  required String vendorName,
  required String state,
  required String contact,
}) async {
  // 1. Excel Generation
  final excel = Excel.createExcel();
  final Sheet sheet = excel['ElementsData'];

  final headerStyle = CellStyle(
    bold: true,
    fontFamily: getFontFamily(FontFamily.Calibri),
    textWrapping: TextWrapping.WrapText,
  );

  List<String> headers = ['Element', 'Height', 'Width', 'Comment'];
  for (int i = 0; i < headers.length; i++) {
    final cell =
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
    cell.value = TextCellValue(headers[i]);
    cell.cellStyle = headerStyle;
  }

  for (int i = 0; i < data.length; i++) {
    final item = data[i];
    final rowIndex = i + 1;
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        .value = TextCellValue(item.element);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        .value = TextCellValue(item.height);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        .value = TextCellValue(item.width);
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        .value = TextCellValue(item.comment);
  }

  excel.rename('Sheet1', 'OldSheet');
  excel.rename('ElementsData', 'ProductElements');

  final tempDir = await getTemporaryDirectory();
  final excelFilePath = '${tempDir.path}/product_elements.xlsx';
  final List<int>? excelBytes = excel.save();
  if (excelBytes == null) throw Exception('Failed to encode Excel file');
  await File(excelFilePath).writeAsBytes(excelBytes);

  // 2. PDF Generation
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) => [
        pw.Center(
          child: pw.Text('Metallicz Media',
              style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 8),
        pw.Center(
          child: pw.Text('Branch Name: $branchName',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 20),
        pw.Text('Address: $address, $city, $state',
            style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 10),
        pw.Text('VendorName: $vendorName', style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 10),
        pw.Text('Date: ${DateTime.now().toString().split(" ").first}',
            style: pw.TextStyle(fontSize: 14)),
        pw.SizedBox(height: 30),

        for (final item in data) ...[
          pw.Text('Elements: ${item.element}',
              style: pw.TextStyle(fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Image(pw.MemoryImage(item.imageFile.readAsBytesSync())),
          pw.SizedBox(height: 30),
        ]
      ],
    ),
  );

  final pdfFilePath = '${tempDir.path}/$branchName recee_report.pdf';
  final pdfFile = File(pdfFilePath);
  await pdfFile.writeAsBytes(await pdf.save());

  return {
    'excel': excelFilePath,
    'pdf': pdfFilePath,
  };
}
