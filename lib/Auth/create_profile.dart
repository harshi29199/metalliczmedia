import 'dart:ui';

import 'package:http/http.dart' as http;
import '../Utils/all_imports.dart'; // Your helper methods like `heightGap`

class CreateProfilePage extends StatefulWidget {
  final String phone;
  const CreateProfilePage({super.key, required this.phone});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _nameError = false;
  bool _vendorError = false;
  String? _selectedVendor;
  bool _isSubmitting = false;
  bool _imageError = false;
  final List<String> _vendors = [];

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  /// Pick image from front camera
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _imageError = false;
      });
    }
  }

  /// Fetch vendor list from API
  Future<void> _fetchVendors() async {
    try {
      final uri = Uri.parse('http://otplai.com:4000/api/get_vendor');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"vendor_name": "all"}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> vendorList = data['result'];
        setState(() {
          _vendors.clear();
          _vendors.addAll(vendorList.map((v) => v['vendor_name'].toString()));
        });
      } else {
        _showToast("Failed to load vendors", Colors.red);
      }
    } catch (e) {
      debugPrint("Vendor fetch error: $e");
      _showToast("Error fetching vendors", Colors.red);
    }
  }

  /// Submit the user profile
  Future<void> _submitProfile() async {
    final name = _nameController.text.trim();

    setState(() {
      _imageError = _selectedImage == null;
      _nameError = name.isEmpty;
      _vendorError = _selectedVendor == null;
    });

    if (_imageError || _nameError || _vendorError) {
      _showToast("Please fill all details", Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final uri = Uri.parse('http://otplai.com:4000/api/user_img');
      final request = http.MultipartRequest('POST', uri)
        ..fields['User_name'] = name
        ..fields['Contect_no'] = widget.phone
        ..fields['vendor_name'] = _selectedVendor!
        ..files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        _showToast("Profile created! 🚀", AppColors.primary);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainActivityScreen(
              isLoading: false,
              phone: widget.phone,
              vendorName: _selectedVendor!,
            ),
          ),
        );
      } else {
        _showToast("Upload failed. Try again.", Colors.red);
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
      _showToast("Something went wrong.", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Helper to show styled toast
  void _showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      fontSize: 16.0,
    );
  }

  /// Build method
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            const Text("Create Profile", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06, vertical: size.height * 0.03),
        child: Column(
          children: [
            _buildProfileImagePicker(),
            heightGap(size.height * 0.03),
            _buildTextField(
              controller: _nameController,
              icon: Icons.person,
              hint: "Enter your name",
            ),
            heightGap(size.height * 0.03),
            _buildVendorDropdown(),
            heightGap(size.height * 0.05),
            _isSubmitting
                ? const CircularProgressIndicator(color: AppColors.primary)
                : _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// Profile image picker
  Widget _buildProfileImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _imageError ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primary.withOpacity(0.3),
          backgroundImage: _selectedImage != null
              ? FileImage(File(_selectedImage!.path))
              : null,
          child: _selectedImage == null
              ? const Icon(Icons.add_a_photo,
                  size: 40, color: AppColors.primary)
              : null,
        ),
      ),
    );
  }

  /// Vendor dropdown
  Widget _buildVendorDropdown() {
    return GestureDetector(
      onTap: () => _showVendorPicker(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.containerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _vendorError ? Colors.red : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.business, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedVendor ?? "Select Vendor",
                style: TextStyle(
                  color: _selectedVendor == null
                      ? AppColors.hintText
                      : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showVendorPicker() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Dialog(
          backgroundColor: AppColors.containerColor.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                final vendor = _vendors[index];
                return ListTile(
                  leading: const Icon(Icons.business, color: AppColors.primary),
                  title:
                      Text(vendor, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      _selectedVendor = vendor;
                      _vendorError =
                          false; // ✅ reset error when vendor is selected
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Submit button
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: const Text("Submit",
          style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  /// Custom text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      onChanged: (_) {
        if (_nameError) {
          setState(() {
            _nameError = false;
          });
        }
      },
      controller: controller,
      cursorColor: AppColors.primary,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.hintText),
        filled: true,
        fillColor: AppColors.containerColor,
        enabledBorder:
            _inputBorder(_nameError ? Colors.red : AppColors.primary),
        focusedBorder:
            _inputBorder(_nameError ? Colors.red : AppColors.primary, width: 2),
      ),
    );
  }

  /// Reusable input border
  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    );
  }
}
