import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../Themes/app_colors.dart';
import '../HomePage/mainactivity_screen.dart';

class CameraRectificationElementspage extends StatefulWidget {
  final String id;
  final String clientName;
  final String branchName;
  final String clientLogo;
  final String clientAddress;
  final String city;
  final String state;
  final String clientNo;
  final String vendorName;
  final String userName;
  final String reportDate;
  final String issue;
  final String phone;

  const CameraRectificationElementspage({
    super.key,
    required this.id,
    required this.clientName,
    required this.branchName,
    required this.clientLogo,
    required this.clientAddress,
    required this.city,
    required this.state,
    required this.clientNo,
    required this.vendorName,
    required this.userName,
    required this.reportDate,
    required this.issue,
    required this.phone,
  });

  @override
  State<CameraRectificationElementspage> createState() =>
      _CameraRectificationElementspageState();
}

class _CameraRectificationElementspageState
    extends State<CameraRectificationElementspage> {
  File? gsbPhoto;
  File? buildingPhoto;
  List<File> rectificationPhotos = [];
  List<TextEditingController> rectificationComments = [];
  bool isSubmitting = false;

  Future<void> _pickPhoto(bool isGsb) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        if (isGsb) {
          gsbPhoto = File(picked.path);
        } else {
          buildingPhoto = File(picked.path);
        }
      });
    }
  }

  Future<void> _pickRectificationPhotos() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        rectificationPhotos.add(File(picked.path));
        rectificationComments.add(TextEditingController());
      });
    }
  }

  Future<void> _submitRectification() async {
    // 🧠 Validations
    if (gsbPhoto == null) {
      Fluttertoast.showToast(msg: "Please capture Overview photo",toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
      return;
    }
    if (buildingPhoto == null) {
      Fluttertoast.showToast(msg: "Please capture Building photo",toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    if (rectificationPhotos.isEmpty) {
      Fluttertoast.showToast(msg: "Please add at least one Rectification photo",toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    bool anyEmptyComment = rectificationComments.any((c) => c.text.trim().isEmpty);
    if (anyEmptyComment) {
      Fluttertoast.showToast(msg: "Please add comments for all rectification photos",toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    setState(() => isSubmitting = true);

    final uri = Uri.parse('http://otplai.com:4000/api/create_rectification_ppt');
    final request = http.MultipartRequest('POST', uri);

    request.fields['id'] = widget.id;
    request.fields['client_name'] = widget.clientName;
    request.fields['branch_name'] = widget.branchName;
    request.fields['client_logo'] = widget.clientLogo;
    request.fields['client_address'] = widget.clientAddress;
    request.fields['city'] = widget.city;
    request.fields['state'] = widget.state;
    request.fields['client_no'] = widget.clientNo;
    request.fields['vendor_name'] = widget.vendorName;
    request.fields['user_name'] = widget.userName;
    request.fields['report_date'] = widget.reportDate;
    request.fields['issue'] = widget.issue;

    request.files.add(await http.MultipartFile.fromPath('gsb_photo', gsbPhoto!.path));
    request.files.add(await http.MultipartFile.fromPath('building_photo', buildingPhoto!.path));

    for (final file in rectificationPhotos) {
      request.files.add(await http.MultipartFile.fromPath('logo', file.path));
    }

    final List<String> comments = rectificationComments.map((c) => c.text.trim()).toList();
    request.fields['comment'] = comments.join(', ');

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Rectification Submitted Successfully",
          backgroundColor: AppColors.primary,
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainActivityScreen(
              phone: widget.phone,
              vendorName: widget.vendorName,
              isLoading: false,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "Submission Failed: ${response.statusCode}",toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e",toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    for (var controller in rectificationComments) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Rectification Submission'),
        backgroundColor: AppColors.primary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(
                  title: "Building Photo",
                  child: _imagePickerTile(
                    label: "Click Building Photo",
                    image: buildingPhoto,
                    onTap: () async {
                      buildingPhoto = await _pickImage(source: ImageSource.camera);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _sectionCard(
                  title: "Overview Photo",
                  child: _imagePickerTile(
                    label: "Click Overview Photo",
                    image: gsbPhoto,
                    onTap: () async {
                      gsbPhoto = await _pickImage(source: ImageSource.camera);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 25),
                _sectionCard(
                  title: "Rectification Steps",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickRectificationPhotos,
                        icon: const Icon(Icons.add_a_photo,color: Colors.white,),
                        label: const Text("Add Rectification Photo",style: TextStyle(
                          color: Colors.white
                        ),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (rectificationPhotos.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: rectificationPhotos.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    rectificationPhotos[index],
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: rectificationComments[index],
                                  maxLines: 2,
                                  textInputAction: TextInputAction.done,
                                  onEditingComplete: () =>
                                      FocusScope.of(context).unfocus(),
                                  decoration: InputDecoration(
                                    labelText: 'Enter comment',
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.primary),
                                    ),
                                    filled: true,
                                    fillColor: Colors.black,
                                    labelStyle:
                                    TextStyle(color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitRectification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isSubmitting
                        ?  CircularProgressIndicator(color: AppColors.primary)
                        : const Text("Submit Rectification",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _sectionCard({required String title, required Widget child}) {
    return SizedBox(
      width: double.infinity, // 👈 Makes it full width
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }



  Future<File?> _pickImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    return picked != null ? File(picked.path) : null;
  }


  Widget _imagePickerTile({
    required String label,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.camera_alt,color: Colors.white),
            label: Text(label,style: TextStyle(
              color: Colors.white
            ),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.2),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (image != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              image,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }


}
