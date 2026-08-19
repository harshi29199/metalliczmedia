// Enhanced UI version of InstallationInProgressPage

import 'dart:ui';
import 'package:http/http.dart' as http;
import '../../Utils/all_imports.dart';
import 'installation_data_modal.dart';

class InstallationInProgressPage extends StatefulWidget {
  final String phone,
      address,
      city,
      clientno,
      state,
      log,
      lat,
      username,
      vendorname,
      id,
      date,
      logoUrl,
      clientName,
      branchName,
      installationImg;

  const InstallationInProgressPage({
    super.key,
    required this.phone,
    required this.address,
    required this.city,
    required this.clientno,
    required this.state,
    required this.log,
    required this.lat,
    required this.username,
    required this.vendorname,
    required this.id,
    required this.date,
    required this.logoUrl,
    required this.clientName,
    required this.branchName,
    required this.installationImg,
  });

  @override
  State<InstallationInProgressPage> createState() =>
      _InstallationInProgressPageState();
}

class _InstallationInProgressPageState
    extends State<InstallationInProgressPage> {
  late Future<List<Result>> _futureData;
  final Map<int, File?> comparisonImages = {};
  final List<File> extraInstallations = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _futureData = fetchInstallationData();
  }

  Future<List<Result>> fetchInstallationData() async {
    final response = await http.post(
      Uri.parse("http://otplai.com:4000/api/recee_get_ppt"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"id": widget.id}),
    );

    if (response.statusCode == 200) {
      final modal =
          GetInstallationDataPptModal.fromJson(jsonDecode(response.body));
      return modal.result
              ?.where((r) => r.imageUrl?.isNotEmpty ?? false)
              .toList() ??
          [];
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  Future<void> _captureExtraImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null)
      setState(() => extraInstallations.add(File(picked.path)));
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Installation In Progress"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Result>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return _buildExtraImageUI(h);
          }

          return ListView(
            padding: EdgeInsets.all(w * 0.04),
            children: data.expand((item) {
              final imageUrls = item.imageUrl?.split(',') ?? [];
              final heights = item.height?.split(',') ?? [];
              final widths = item.width?.split(',') ?? [];
              final elements = item.element?.split(',') ?? [];
              final comments = item.comment?.split(',') ?? [];

              return List.generate(
                  imageUrls.length,
                  (i) => _buildComparisonCard(
                        w: w,
                        h: h,
                        index: i,
                        imgUrl: imageUrls[i].trim(),
                        height: i < heights.length ? heights[i].trim() : 'N/A',
                        width: i < widths.length ? widths[i].trim() : 'N/A',
                        element:
                            i < elements.length ? elements[i].trim() : 'N/A',
                        comment:
                            i < comments.length ? comments[i].trim() : 'N/A',
                      ));
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _submitInstallationForm,
        icon: const Icon(Icons.cloud_upload, color: Colors.white),
        label: const Text("Submit Data", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildExtraImageUI(double h) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ...extraInstallations.map((file) => Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(file,
                          height: h * 0.25,
                          width: double.infinity,
                          fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () =>
                            setState(() => extraInstallations.remove(file)),
                        child: const CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 14,
                          child:
                              Icon(Icons.close, size: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              )),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            onPressed: _captureExtraImage,
            icon: const Icon(Icons.add_a_photo, color: Colors.white),
            label: const Text("Add Installation Image",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required double w,
    required double h,
    required int index,
    required String imgUrl,
    required String height,
    required String width,
    required String element,
    required String comment,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.only(bottom: w * 0.04),
      child: Padding(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _buildImageColumn(
                    "Recee",
                    Image.network(
                      "https://otplai.com/Metallicz/Myapi/upload_ppt/$imgUrl",
                      height: h * 0.2,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )),
                SizedBox(width: w * 0.03),
                _buildImageColumn("Installation", _buildInstallImage(index, h)),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Text("Element: $element",
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text("Height: $height   |   Width: $width"),
            Text("Comment: $comment"),
          ],
        ),
      ),
    );
  }

  Widget _buildImageColumn(String label, Widget image) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image,
          ),
        ],
      ),
    );
  }

  Widget _buildInstallImage(int index, double h) {
    final imageFile = comparisonImages[index];
    if (imageFile != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              imageFile,
              height: h * 0.2,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: () => setState(() => comparisonImages.remove(index)),
              child: const CircleAvatar(
                backgroundColor: Colors.red,
                radius: 14,
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          )
        ],
      );
    } else {
      return GestureDetector(
        onTap: () => _captureComparisonImage(index),
        child: Container(
          height: h * 0.2,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: const Center(
            child: Text("Tap to Capture",
                style: TextStyle(color: Colors.white70)),
          ),
        ),
      );
    }
  }


  Future<void> _captureComparisonImage(int index) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null)
      setState(() => comparisonImages[index] = File(picked.path));
  }

  Future<void> _submitInstallationForm() async {
    int totalImages = 0;

    if ((await _futureData).isEmpty) {
      totalImages = extraInstallations.length;
    } else {
      totalImages =
          comparisonImages.values.where((file) => file != null).length;
    }

    if (totalImages < 1) {
      Fluttertoast.showToast(
        msg: "Please capture at least 1 installation images before submitting.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Continue with confirmation dialog as usual
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Confirm Submission",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to submit this Installation?",
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text('No', style: TextStyle(color: AppColors.primary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(
                  context, true), // ✅ FIXED: just close and return true
              child: const Text('Yes, Submit',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => isSubmitting = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>  Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final uri =
          Uri.parse("http://otplai.com:4000/api/create_installation_ppt");
      final request = http.MultipartRequest("POST", uri);

      request.fields.addAll({
        'id': widget.id,
        'vendor_name': widget.vendorname,
        'branch_name': widget.branchName,
        'client_address': widget.address,
        'city': widget.city,
        'state': widget.state,
        'client_logo': widget.logoUrl,
        'client_name': widget.clientName,
        'client_no': widget.clientno,
        'report_date': widget.date,
      });

      if ((await _futureData).isEmpty) {
        for (File file in extraInstallations) {
          request.files.add(await http.MultipartFile.fromPath(
              'installation_img_url', file.path));
        }
        request.fields['element'] = 'N/A';
        request.fields['element_price'] = 'N/A';
        request.fields['comment'] = 'N/A';
        request.fields['height'] = 'N/A';
        request.fields['width'] = 'N/A';
        request.fields['recee_image_url'] = 'N/A';
      } else {
        final results = await _futureData;
        List<String> receeUrls = [];
        List<String> elements = [],
            elementPrices = [],
            comments = [],
            heights = [],
            widths = [];

        for (int i = 0; i < results.length; i++) {
          final result = results[i];
          final imageUrls = result.imageUrl?.split(',') ?? [];
          final elms = result.element?.split(',') ?? [];
          final prices = result.elementPrice?.split(',') ?? [];
          final cmnts = result.comment?.split(',') ?? [];
          final hts = result.height?.split(',') ?? [];
          final wds = result.width?.split(',') ?? [];

          for (int j = 0; j < imageUrls.length; j++) {
            if (!comparisonImages.containsKey(j)) continue;

            final receeUrl = imageUrls[j].trim();
            final installFile = comparisonImages[j];
            if (receeUrl.isEmpty || installFile == null) continue;

            receeUrls.add(receeUrl);
            request.files.add(await http.MultipartFile.fromPath(
                'installation_img_url', installFile.path));

            elements.add(j < elms.length ? elms[j].trim() : '');
            elementPrices.add(j < prices.length ? prices[j].trim() : '');
            comments.add(j < cmnts.length ? cmnts[j].trim() : '');
            heights.add(j < hts.length ? hts[j].trim() : '');
            widths.add(j < wds.length ? wds[j].trim() : '');
          }
        }

        request.fields['element'] = elements.join(',');
        request.fields['element_price'] = elementPrices.join(',');
        request.fields['comment'] = comments.join(',');
        request.fields['height'] = heights.join(',');
        request.fields['width'] = widths.join(',');
        request.fields['recee_image_url'] = receeUrls.join(',');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      Navigator.pop(context);
      setState(() => isSubmitting = false);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Installation Submitted Successfully",backgroundColor: AppColors.primary);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainActivityScreen(
                phone: widget.phone,
                vendorName: widget.vendorname,
                isLoading: false,
              ),
            ));
      } else {
        Fluttertoast.showToast(
            msg: "Upload failed: ${response.statusCode}",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      setState(() => isSubmitting = false);
      Fluttertoast.showToast(msg: "Error: $e", backgroundColor: Colors.red);
    }
  }
}
