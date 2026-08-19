import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:metallicz/Utils/all_imports.dart';
import 'package:pro_image_editor/core/models/editor_configs/utils/editor_safe_area.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:share_plus/share_plus.dart';

class ReceeFormPage extends StatefulWidget {
  final String branchname, mmid, bmid, address, city, state, client_no, phone;
  final String lon, lat, username, vendorname, date, id, logourl, client_name;

  const ReceeFormPage({
    super.key,
    required this.branchname,
    required this.mmid,
    required this.bmid,
    required this.address,
    required this.city,
    required this.state,
    required this.client_no,
    required this.lon,
    required this.lat,
    required this.username,
    required this.vendorname,
    required this.date,
    required this.id,
    required this.phone,
    required this.logourl,
    required this.client_name,
  });

  @override
  State<ReceeFormPage> createState() => _ReceeFormPageState();
}

class _ReceeFormPageState extends State<ReceeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  final List<Map<String, dynamic>> receeElements = [];
  List<String> elementList = [];
  List<String> priceList = [];

  List<File> buildingPhotos = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchClientElements();
  }

  void _editReceeElement(int index) {
    final item = receeElements[index];

    final elementController = TextEditingController(text: item['element']);
    final heightController = TextEditingController(text: item['height']);
    final widthController = TextEditingController(text: item['width']);
    final priceController = TextEditingController(text: item['price']);
    final commentController = TextEditingController(text: item['comment']);
    String? selectedElement = item['element'];
    final photo = item['photo'];

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Edit Element",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary)),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Element',
                      prefixIcon: const Icon(Icons.extension),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                    value: selectedElement,
                    items: elementList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select an element'
                        : null,
                    onChanged: (value) {
                      final i = elementList.indexOf(value!);
                      elementController.text = value;
                      priceController.text =
                          (i < priceList.length) ? priceList[i] : '';
                      selectedElement = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  _validatedTextField(
                      controller: heightController,
                      label: "Height (in)",
                      icon: Icons.height,
                      type: TextInputType.number),
                  const SizedBox(height: 12),
                  _validatedTextField(
                      controller: widthController,
                      label: "Width (in)",
                      icon: Icons.swap_horiz,
                      type: TextInputType.number),
                  const SizedBox(height: 12),
                  _validatedTextField(
                      isOptional: true,
                      controller: commentController,
                      label: "Comment",
                      icon: Icons.comment),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        receeElements[index] = {
                          "photo": photo,
                          "element": elementController.text,
                          "height": heightController.text,
                          "width": widthController.text,
                          "price": priceController.text,
                          "comment": commentController.text.trim().isEmpty
                              ? "No Comment"
                              : commentController.text.trim(),
                        };
                        setState(() {});
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Update",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showElementOptions(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose Action",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Edit"),
                onTap: () {
                  Navigator.pop(context);
                  _editReceeElement(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete"),
                onTap: () {
                  setState(() {
                    receeElements.removeAt(index);
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, String> elementHeights = {};
  Map<String, String> elementWidths = {};

  Future<void> fetchClientElements() async {
    final url = Uri.parse("http://otplai.com:4000/api/client_get");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'client_name': widget.client_name}),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)['result'][0];
      setState(() {
        elementList = result['element'].split(',');
        priceList = result['price'].split(',');

        final heights = result['height'].split(',');
        final widths = result['width'].split(',');

        for (int i = 0; i < elementList.length; i++) {
          final element = elementList[i];
          if (i < heights.length && heights[i].trim().isNotEmpty) {
            elementHeights[element] = heights[i];
          }
          if (i < widths.length && widths[i].trim().isNotEmpty) {
            elementWidths[element] = widths[i];
          }
        }
      });
    } else {
      Fluttertoast.showToast(
          msg: "Failed to load client data", backgroundColor: Colors.red);
    }
  }

  Future<File?> _pickImage({
    required ImageSource source,
    bool withEditor = false,
  }) async {
    bool hasDrawnRect = false;

    try {
      final picked = await picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (picked == null) return null;

      final file = File(picked.path);

      if (!withEditor) return file;

      final editedFile = await Navigator.push<File?>(
        context,
        MaterialPageRoute(
          builder: (_) => ProImageEditor.file(
            file,
            configs: ProImageEditorConfigs(
              designMode: ImageEditorDesignMode.cupertino,
              paintEditor: PaintEditorConfigs(
                safeArea: EditorSafeArea(
                    left: true, bottom: true, right: true, top: true),
                enabled: true,
                enableModeRect: true,
                enableModeFreeStyle: false,
                enableModeArrow: true,
                enableModePolygon: false,
                enableModeCircle: true,
                enableModeBlur: false,
                enableModePixelate: false,
                enableModeDashLine: false,
                enableModeEraser: false,
                enableModeLine: false,
                enableZoom: false,
                enableDoubleTapZoom: false,
                enableFreeStyleHighPerformanceScaling: false,
                enableFreeStyleHighPerformanceHero: false,
                enableFreeStyleHighPerformanceMoving: false,
                enableShareZoomMatrix: false,
              ),
              cropRotateEditor: CropRotateEditorConfigs(enabled: false),
              textEditor: TextEditorConfigs(enabled: false),
              filterEditor: FilterEditorConfigs(enabled: false),
              blurEditor: BlurEditorConfigs(enabled: false),
              emojiEditor: EmojiEditorConfigs(enabled: false),
              stickerEditor: StickerEditorConfigs(enabled: false),
              tuneEditor: TuneEditorConfigs(enabled: false),
            ),
            callbacks: ProImageEditorCallbacks(
              paintEditorCallbacks: PaintEditorCallbacks(
                onDone: () {
                  hasDrawnRect = true;
                },
              ),
              onImageEditingComplete: (bytes) async {
                if (!hasDrawnRect) {
                  Fluttertoast.showToast(
                    msg: "Please draw a rectangle before saving!",
                    backgroundColor: Colors.red,
                  );
                  return; // Block saving
                }

                final editedPath =
                    '${(await getTemporaryDirectory()).path}/edited_${DateTime.now().millisecondsSinceEpoch}.png';
                final result = await File(editedPath).writeAsBytes(bytes);
                Navigator.pop(context, result);
              },
            ),
          ),
        ),
      );

      return editedFile;
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to pick/edit image: $e",
        backgroundColor: Colors.red,
      );
      return null;
    }
  }

  void _addReceeElement() {
    final elementController = TextEditingController();
    final heightController = TextEditingController();
    final widthController = TextEditingController();
    final priceController = TextEditingController();
    final commentController = TextEditingController();
    String? selectedElement;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Select Element",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Element',
                      prefixIcon: const Icon(Icons.extension),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.black,
                    ),
                    value: selectedElement,
                    items: elementList
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select an element'
                        : null,
                    onChanged: (value) {
                      final index = elementList.indexOf(value!);
                      elementController.text = value;
                      priceController.text =
                          (index < priceList.length) ? priceList[index] : '';
                      selectedElement = value;

                      heightController.text = elementHeights[value] ?? '';
                      widthController.text = elementWidths[value] ?? '';

                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  elementHeights.containsKey(selectedElement)
                      ? _readOnlyTextField(
                          label: "Height (inches)",
                          value: elementHeights[selectedElement]!,
                          icon: Icons.height,
                        )
                      : _validatedTextField(
                          controller: heightController,
                          label: "Height (inches)",
                          icon: Icons.height,
                          type: TextInputType.number,
                        ),
                  const SizedBox(height: 12),
                  elementWidths.containsKey(selectedElement)
                      ? _readOnlyTextField(
                          label: "Width (inches)",
                          value: elementWidths[selectedElement]!,
                          icon: Icons.swap_horiz,
                        )
                      : _validatedTextField(
                          controller: widthController,
                          label: "Width (inches)",
                          icon: Icons.swap_horiz,
                          type: TextInputType.number,
                        ),
                  const SizedBox(height: 12),
                  _validatedTextField(
                    isOptional: true,
                    controller: commentController,
                    label: "Comment",
                    icon: Icons.comment,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        Navigator.pop(context); // Close this bottom sheet

                        /// Now ask for photo
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text("Take Photo"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final photo = await _pickImage(
                                        source: ImageSource.camera,
                                        withEditor: true);
                                    if (photo != null) {
                                      _saveElementToList(
                                        photo: photo,
                                        element: elementController.text,
                                        height: heightController.text,
                                        width: widthController.text,
                                        price: priceController.text,
                                        comment: commentController.text,
                                      );
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text("Choose from Gallery"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final photo = await _pickImage(
                                        source: ImageSource.gallery,
                                        withEditor: true);
                                    if (photo != null) {
                                      _saveElementToList(
                                        photo: photo,
                                        element: elementController.text,
                                        height: heightController.text,
                                        width: widthController.text,
                                        price: priceController.text,
                                        comment: commentController.text,
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.photo_camera, color: Colors.white),
                    label: const Text("Next: Take Photo",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveElementToList({
    required File photo,
    required String element,
    required String height,
    required String width,
    required String price,
    required String comment,
  }) {
    receeElements.add({
      "photo": photo,
      "element": element,
      "height": height,
      "width": width,
      "price": price,
      "comment": comment.trim().isEmpty ? "No Comment" : comment.trim(),
    });
    setState(() {});
  }

  Widget _validatedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType type = TextInputType.text,
    bool isOptional = false, // 🔸 Add this new parameter
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      validator: isOptional
          ? null
          : (value) =>
              value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.black,
      ),
    );
  }

  void _submitForm() async {
    final confirm = await showDialog<String>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          title: const Text("Confirm Submission"),
          content: const Text(
            "Are you sure you want to submit this Recee?\n\n"
            "Before submitting, you should send a site video to your vendor on WhatsApp.\n\n"
            "You can also choose to skip this step.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, "cancel"),
              child: const Text("No", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, "skip"),
              child: const Text("Skip & Submit",
                  style: TextStyle(color: Colors.orangeAccent)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, "yes"),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Yes, Continue",
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );

    if (confirm == "cancel" || confirm == null) return;

    // Step 1: Optional video capture and WhatsApp sharing
    if (confirm == "yes") {
      final picker = ImagePicker();
      final pickedVideo = await picker.pickVideo(source: ImageSource.camera);

      if (pickedVideo == null) {
        Fluttertoast.showToast(
          msg: "Video not selected. Submission cancelled.",
          backgroundColor: Colors.red,
        );
        return;
      }

      await Share.shareXFiles(
        [XFile(pickedVideo.path)],
        text: "${widget.branchname} Site video for Recee submission.",
      );
    }

    // Step 2: Proceed with Recee submission
    setState(() => isLoading = true);

    try {
      final uri = Uri.parse('http://otplai.com:4000/api/create_recee_ppt');
      final request = http.MultipartRequest('POST', uri);

      List<String> statuses =
          List.generate(receeElements.length, (_) => "pending");

      request.fields.addAll({
        "client_name": widget.client_name,
        "branch_name": widget.branchname,
        "client_address": widget.address,
        "city": widget.city,
        "state": widget.state,
        "client_no": widget.client_no,
        "lon": widget.lon,
        "lat": widget.lat,
        "user_name": widget.username,
        "vendor_name": widget.vendorname,
        "report_date": "${DateTime.now().day.toString().padLeft(2, '0')}/"
            "${DateTime.now().month.toString().padLeft(2, '0')}/"
            "${DateTime.now().year}",
        "id": widget.id,
        "client_logo": widget.logourl,
        "status": statuses.join(','),
      });

      for (int i = 0; i < buildingPhotos.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'building_photo', // 👈 Same field name for all
          buildingPhotos[i].path,
        ));
      }

      List<String> elements = [];
      List<String> prices = [];
      List<String> comments = [];
      List<String> heights = [];
      List<String> widths = [];

      for (final e in receeElements) {
        elements.add(e['element']);
        prices.add(e['price']);
        comments.add(e['comment'].toString().trim().isEmpty
            ? "No Comment"
            : e['comment']);
        heights.add(e['height']);
        widths.add(e['width']);
        request.files
            .add(await http.MultipartFile.fromPath('logo', e['photo'].path));
      }

      request.fields.addAll({
        'element': elements.join(','),
        'element_price': prices.join(','),
        'comment': comments.join(','),
        'height': heights.join(','),
        'width': widths.join(','),
      });

      request.fields.forEach((key, value) => print("$key: $value"));

      for (var file in request.files) {}

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      setState(() => isLoading = false);

      if (streamedResponse.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Recee Submitted Successfully",
          backgroundColor: AppColors.primary,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainActivityScreen(
              phone: widget.phone,
              vendorName: widget.vendorname,
              isLoading: false,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: "Submission failed: ${streamedResponse.statusCode}",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(
        msg: "Error occurred: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  Widget _imagePickerTile({
    required String label,
    File? image,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(label),
      trailing: image != null
          ? Image.file(image, width: 60, height: 60, fit: BoxFit.cover)
          : const Icon(Icons.camera_alt),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Recee Form", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionCard(
                title: "Overview Photo",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (buildingPhotos.length >= 4) {
                          Fluttertoast.showToast(
                            msg: "Only 4 overview photos allowed",
                            backgroundColor: Colors.orange,
                          );
                          return;
                        }
                        final photo =
                            await _pickImage(source: ImageSource.camera);
                        if (photo != null) {
                          setState(() {
                            buildingPhotos.add(photo);
                          });
                        }
                      },
                      icon: const Icon(Icons.add_a_photo, color: Colors.white),
                      label: const Text("Add Overview Photos",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(buildingPhotos.length, (index) {
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                buildingPhotos[index],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  buildingPhotos.removeAt(index);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
              heightGap(20),
              _sectionCard(
                title: "Recee Elements",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _addReceeElement,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Add Element",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: receeElements.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) => GestureDetector(
                          onLongPress: () => _showElementOptions(index),
                          child: _receeElementCard(receeElements[index])),
                    ),
                  ],
                ),
              ),
              heightGap(30),
              Center(
                child: ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      if (!_formKey.currentState!.validate()) return;

                      if (buildingPhotos.length != 4) {
                        Fluttertoast.showToast(
                            msg: "Please upload exactly 4 overview photos",
                            backgroundColor: Colors.red);
                        return;
                      }

                      if (receeElements.isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Please add at least one Elements",
                            backgroundColor: Colors.red);
                        return;
                      }

                      _submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16))),
              ),
              heightGap(20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _receeElementCard(Map<String, dynamic> e) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              e['photo'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 2),
          Text(e['element'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("H: ${e['height']}  W: ${e['width']}",
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

Widget _readOnlyTextField({
  required String label,
  required String value,
  required IconData icon,
}) {
  return TextFormField(
    initialValue: value,
    enabled: false,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[800],
    ),
    style: const TextStyle(color: Colors.white),
  );
}
