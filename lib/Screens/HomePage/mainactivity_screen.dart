import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:metallicz/Screens/AboutUs/about_us.dart';
import 'package:metallicz/Screens/HomePage/profile.dart';
import '../../ResponseModels/user_data_response_model.dart';
import '../../Utils/all_imports.dart';
import '../../Utils/verifyscreen.dart';

class MainActivityScreen extends StatefulWidget {
  final String phone, vendorName;
  final bool isLoading;
  const MainActivityScreen(
      {super.key,
      required this.phone,
      required this.vendorName,
      required this.isLoading});

  @override
  State<MainActivityScreen> createState() => _MainActivityScreenState();
}

class _MainActivityScreenState extends State<MainActivityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Result? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeUser();
  }

  Future<void> initializeUser() async {
    await fetchUserData();
    final isVerified = await checkVerificationStatus();

    if (!isVerified) {
      final proceed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const VerifyScreen()),
      );

      if (proceed != true && mounted) {
        Navigator.pop(context);
        return;
      }
    }

    await updateLoginStatus("Activate");
  }

  Future<void> checkAndHandleVerification() async {
    final isVerified = await checkVerificationStatus();

    if (!isVerified) {
      final proceed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const VerifyScreen()),
      );

      if (proceed != true) {
        if (mounted) Navigator.pop(context); // User canceled
        return;
      }
    }

    await asyncInit(); // Proceed normally if verified or accepted
  }

  Future<void> asyncInit() async {
    await updateLoginStatus("Activate");
    await fetchUserData();
  }

  Future<bool> checkVerificationStatus() async {
    try {
      final userId = userData?.id;
      if (userId == null) return false;

      final response = await http.post(
        Uri.parse("http://otplai.com:4000/api/get_verification"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"id": userId}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = json['result'] as List<dynamic>;
        if (result.isNotEmpty) {
          final verification = result[0]['verification'];
          return verification == "true";
        }
      }
    } catch (e) {
      debugPrint("Verification check error: $e");
    }
    return false;
  }

  Future<void> updateLoginStatus(String status) async {
    try {
      final res = await http.post(
        Uri.parse("http://otplai.com:4000/api/logout"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"Contect_no": widget.phone, "loginstatus": status}),
      );

      if (status == "Deactivate" &&
          jsonDecode(res.body)["message"] == "Update.") {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false);
        }
      }
    } catch (e) {
      debugPrint("Login status error: $e");
    }
  }

  Future<void> logoutUser() async {
    await updateLoginStatus("Deactivate");
    final provider = context.read<LoginProvider>();
    provider.setRememberMe(false);
    provider.phoneController.clear();
  }

  Future<void> fetchUserData() async {
    try {
      final res = await http.post(
        Uri.parse('http://otplai.com:4000/api/get_img'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': 20, 'Contect_no': widget.phone}),
      );
      final model = UserDataModel.fromJson(jsonDecode(res.body));
      if (model.result?.isNotEmpty ?? false) {
        userData = model.result!.first;
      }
    } catch (e) {
      debugPrint("Fetch user error: $e");
    }
    setState(() => isLoading = false);
  }

  Widget _buildDrawerHeader(double screenWidth) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: AppColors.primary),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : InkWell(
              onTap: () {
                if (userData != null) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfilePage(
                              userData: userData!, phone: widget.phone)));
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  userData?.iMG?.isNotEmpty == true
                      ? ClipOval(
                          child: Image.network(
                            'http://otplai.com/Metallicz/Myapi/upload/${userData!.iMG}',
                            width: screenWidth * 0.2,
                            height: screenWidth * 0.2,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.error, color: Colors.red),
                          ),
                        )
                      : const Icon(Icons.account_circle,
                          size: 60, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome ${userData?.userName?.capitalize() ?? ''}!",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildListTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width * 0.65,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: height * 0.028, color: Colors.white),
        label: Text(
          label,
          style: TextStyle(fontSize: height * 0.022, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonBackground,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: EdgeInsets.symmetric(vertical: height * 0.016)),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black54),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Confirm Logout',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 12),
                  const Text('Are you sure you want to logout?',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("No",
                              style: TextStyle(color: AppColors.primary))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Yes, Logout",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );

    if (shouldLogout == true) await logoutUser();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("MainActivity"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(screenW),
              _buildListTile(Icons.account_balance_wallet, 'Accounts',
                  () => showToast("Under development")),
              _buildListTile(Icons.find_replace, 'Submitted Recee',
                  () => showToast("Under development")),
              _buildListTile(Icons.people_alt, 'All Clients',
                  () => showToast("Under development")),
              _buildListTile(Icons.logout, 'Logout', _showLogoutDialog),
              _buildListTile(
                  Icons.info_outline,
                  'About Us',
                  () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AboutUsPage()))),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: screenH * 0.02),
              color: Colors.black,
              child: Column(
                children: [
                  Image.asset(logo, width: screenW * 0.2),
                  SizedBox(height: screenH * 0.008),
                  Text("Metallicz Media™",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: screenH * 0.025,
                          fontWeight: FontWeight.bold)),
                  Text("We get you noticed!",
                      style: TextStyle(
                          color: AppColors.subtitleText,
                          fontSize: screenH * 0.018)),
                ],
              ),
            ),
            Container(
                height: 5, width: double.infinity, color: AppColors.primary),
            SizedBox(height: screenH * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt, color: AppColors.primary),
                const SizedBox(width: 10),
                Text("What you want to do.",
                    style: TextStyle(
                        color: AppColors.whiteText,
                        fontSize: screenH * 0.022,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            SizedBox(height: screenH * 0.04),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenW * 0.15),
              child: Column(
                children: [
                  _buildActionButton(Icons.assignment_turned_in, "RECEE", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AllClientsScreenRecee(
                                phone: widget.phone,
                                vendorName:
                                    userData?.vendorName ?? "default_vendor")));
                  }),
                  SizedBox(height: screenH * 0.02),
                  _buildActionButton(Icons.settings, "INSTALLATION", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => InstallationPage(
                                phone: widget.phone,
                                vendorName:
                                    userData?.vendorName ?? "Default_vendor",
                                userName: userData?.userName ?? "")));
                  }),
                  SizedBox(height: screenH * 0.02),
                  _buildActionButton(Icons.build, "RECTIFICATION", () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AllClientsScreenRectification(
                                phone: widget.phone,
                                vendorName:
                                    userData?.vendorName ?? "Default_vendor",
                                userName: userData?.userName ?? "")));
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.scaffoldBackground,
    );
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}

void showToast(String msg) => Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
