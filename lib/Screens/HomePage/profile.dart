import 'dart:ui';

import 'package:http/http.dart' as http;

import '../../ResponseModels/user_data_response_model.dart';
import '../../Utils/all_imports.dart';

class ProfilePage extends StatefulWidget {
  final String phone;
  const ProfilePage({super.key, required this.userData, required this.phone});

  final Result userData;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Result userData;

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
  }

  Future<void> _refreshUserData() async {
    try {
      final response = await http.post(
        Uri.parse('http://otplai.com:4000/api/get_img'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Contect_no': widget.phone}),
      );

      final data = jsonDecode(response.body);
      debugPrint("Refreshed Profile Data: $data");

      if (response.statusCode == 200 && data['message'] == 'User found') {
        final updatedUser = Result.fromJson(data['data']);
        setState(() {
          userData = updatedUser;
        });
      }
    } catch (e) {
      debugPrint('Refresh error: $e');
    }
  }

  Future<void> _deleteUser() async {
    final provider = context.read<LoginProvider>();
    provider.resetLoginState();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete your profile? This cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No',
                  style: TextStyle(color: AppColors.primary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(
                  context, true), // ✅ FIXED: just close and return true
              child:
                  const Text('Yes, Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse('http://otplai.com:4000/api/deleteuser'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'Contect_no': widget.phone}),
        );
        final data = jsonDecode(response.body);
        if (response.statusCode == 200 && data['message'] == "Data Delete.") {
          if (!mounted) return;
          Fluttertoast.showToast(
            msg: "Profile Deleted Successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          final provider = context.read<LoginProvider>();
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          provider.setRememberMe(false); //
          // 👇 Clear the phoneController too

          provider.phoneController.clear();

          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        } else {
          Fluttertoast.showToast(msg: "Deletion failed: ${data['message']}",backgroundColor: Colors.red);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e",backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👇 Wrap existing body with RefreshIndicator and call _refreshUserData
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.scaffoldBackground,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refreshUserData,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // for refresh to trigger
            child: Column(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: userData.iMG != null &&
                            userData.iMG!.isNotEmpty
                        ? NetworkImage(
                            'http://otplai.com/Metallicz/Myapi/upload/${userData.iMG}')
                        : null,
                    child: userData.iMG == null || userData.iMG!.isEmpty
                        ? const Icon(Icons.person,
                            size: 60, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _capitalize(userData.userName ?? 'No Name'),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 30),
                Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    title: const Text("Contact Number",
                        style: TextStyle(color: Colors.white70)),
                    subtitle: Text(
                      userData.contectNo ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    title: const Text("Vendor's Name",
                        style: TextStyle(color: Colors.white70)),
                    subtitle: Text(userData.vendorName ?? "Unknown",
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _deleteUser,
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Delete My Profile",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }
}
