import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../Utils/excel_ppt_generator.dart';
import '../../HomePage/mainactivity_screen.dart';

class CameraElementProvider with ChangeNotifier {
  List<CameraElementData> submittedData = [];
  bool isSubmitted = false;

  void addSubmission(CameraElementData data) {
    submittedData.add(data);
    isSubmitted = true;
    notifyListeners();
  }

  Future<void> uploadFilesToServer({
    required String id,
    required String username,
    required String vendorName,
    required String date,
    required String status,
    required String type,
    required File pdfFile,
  }) async {
    var uri = Uri.parse('http://otplai.com:4000/api/recee_ppt');

    var request = http.MultipartRequest('POST', uri)
      ..fields['id'] = id
      ..fields['username'] = username
      ..fields['vendor_name'] = vendorName
      ..fields['date'] = date
      ..fields['status'] = status
      ..fields['type'] = type;

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      pdfFile.path,
      contentType: MediaType('application', 'pdf'),
    ));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final decoded = json.decode(respStr);
        debugPrint('✅ Upload Success: ${decoded['message']}');
      } else {
        debugPrint('❌ Upload Failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🚫 Error uploading: $e');
    }
  }

  Future<void> submitDetails({
    required BuildContext context,
    required File imageFile,
    required String height,
    required String width,
    required String comment,
    required String element,
    required String id,
    required String username,
    required String vendorname,
    required String date,
    required String status,
    required String type,
    required String branchname,
    required String mmid,
    required String bmid,
    required String clientNo,
    required File? buildingImage, // ✅ Add this
    required File? gsbImage, // ✅ Add this
    required String city, // ✅ Add this
    required String state, // ✅ Add this
  }) async {
    final newEntry = CameraElementData(
      imageFile: imageFile,
      height: height,
      width: width,
      comment: comment,
      element: element,
    );

    addSubmission(newEntry);

    final resultPaths = await generateExcelAndPDF(
        bmId: bmid,
        vendorName: vendorname,
        branchName: branchname,
        mmId: mmid,
        address: clientNo,
        data: submittedData,
        buildingImage: buildingImage,
        gsbImage: null,
        city: city,
        contact: clientNo,
        state: state);

    final pdfPath = resultPaths['pdf'];

    if (pdfPath != null) {
      await uploadFilesToServer(
        id: id,
        username: username,
        vendorName: vendorname,
        date: date,
        status: status,
        type: type,
        pdfFile: File(pdfPath),
      );
    }

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Files Generated"),
          content: const Text("Your Excel and PDF reports are ready."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MainActivityScreen(
                        isLoading: false,
                            phone: clientNo,
                            vendorName: vendorname,
                          )),
                  (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );

      // Navigate to main screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => MainActivityScreen(
                  phone: clientNo,
                  vendorName: vendorname, isLoading: false,
                )),
        (route) => false,
      );
    }
  }

  void reset() {
    submittedData.clear();
    isSubmitted = false;
    notifyListeners();
  }

  bool get submissionStatus => isSubmitted;
}
