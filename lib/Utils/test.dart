import 'package:flutter/material.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

import 'excel_ppt_generator.dart'; // 📂 to open PDF
// import your generateExcelAndPDF.dart file here

class MyReportScreen extends StatelessWidget {
  final List<CameraElementData> dummyData = [
    CameraElementData(
      imageFile: File('path/to/image.jpg'), // replace with actual
      height: '10',
      width: '5',
      comment: 'Good placement',
      element: 'Signboard',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate Report')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await generateExcelAndPDF(
              data: dummyData,
              buildingImage: null,
              gsbImage: null,
              address: 'MG Road',
              city: 'Mumbai',
              branchName: 'Mumbai Branch',
              bmId: 'BM123',
              mmId: 'MM456',
              vendorName: 'VendorX',
              state: 'Maharashtra',
              contact: '+91 9876543210',
            );

            final pdfPath = result['pdf'];
            if (pdfPath != null) {
              await OpenFile.open(pdfPath);
            }
          },
          child: Text('Generate & View PDF'),
        ),
      ),
    );
  }
}
