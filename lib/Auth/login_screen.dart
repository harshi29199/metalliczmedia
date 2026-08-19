import '../Utils/all_imports.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _phoneError = false;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = context.read<LoginProvider>();
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('rememberMe') ?? false;

      await provider.loadRememberedPhone();

      if (remember && provider.phoneController.text.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainActivityScreen(
              isLoading: false,
              phone: provider.phoneController.text.trim(),
              vendorName: '',
            ),
          ),
        );
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;
    final loginProvider = context.watch<LoginProvider>();
    loginProvider.phoneController.text.trim();
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.containerColor,
                AppColors.containerColor,
                AppColors.containerColor,
                AppColors.primary,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
              child: Column(
                children: [
                  Image.asset(logo, width: sw * 0.3),
                  heightGap(sh * 0.008),
                  Text(
                    "Metallicz Media™",
                    style: TextStyle(
                      color: AppColors.whiteText,
                      fontSize: sh * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "We get you noticed!",
                    style: TextStyle(
                      color: AppColors.whiteText.withOpacity(0.8),
                      fontSize: sh * 0.018,
                    ),
                  ),
                  heightGap(sh * 0.04),
                  Container(
                    padding: EdgeInsets.all(sh * 0.02),
                    decoration: BoxDecoration(
                      color: AppColors.containerColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildPhoneForm(context, loginProvider, sh),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//Phone input form
  Widget _buildPhoneForm(
      BuildContext context, LoginProvider provider, double height) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Login',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        heightGap(height * 0.03),
        _buildTextField(
          controller: provider.phoneController,
          icon: Icons.phone_iphone_outlined,
          hint: 'Enter Phone Number',
        ),
        heightGap(height * 0.02),
        Row(
          children: [
            Checkbox(
              value: provider.rememberMe,
              activeColor: AppColors.primary,
              onChanged: provider.toggleRememberMe,
            ),
            const Text(
              "Remember Me",
              style: TextStyle(color: AppColors.primary),
            ),
          ],
        ),
        provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : ElevatedButton(
                onPressed: () async {
                  FocusScope.of(context).unfocus();

                  final phone = provider.phoneController.text.trim();

                  setState(() {
                    _phoneError = phone.length != 10;
                  });

                  if (_phoneError) {
                    Fluttertoast.showToast(
                      msg: "Please enter a valid 10-digit phone number",
                      backgroundColor: Colors.red,
                    );
                    return;
                  }

                  final message = await provider.sendOTP();
                  if (message == "Please Register Username") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateProfilePage(phone: phone),
                      ),
                    );
                    Fluttertoast.showToast(
                      msg: "Create Your Profile",
                      backgroundColor: AppColors.primary,
                    );
                  }
                  else if (message == "Login successfully.") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MainActivityScreen(
                          isLoading: false,
                          phone: phone,
                          vendorName: '',
                        ),
                      ),
                    );
                    Fluttertoast.showToast(
                      msg: "Login Successful",
                      backgroundColor: AppColors.primary,
                    );
                  }
                  else {
                    Fluttertoast.showToast(
                      msg: "Something went wrong",
                      backgroundColor: Colors.red,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, color: AppColors.whiteText),
                ),
              ),
      ],
    );
  }

// Reusable TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      onChanged: (_) {
        if (_phoneError) {
          setState(() {
            _phoneError = false;
          });
        }
      },

      keyboardType: TextInputType.number, // <-- numeric keyboard
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly
      ], // <-- only digits
      maxLength: 10, // optional: limits input to 10 digits
      cursorColor: AppColors.primary,
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: AppColors.whiteText),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primary),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.hintText),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _phoneError ? Colors.red : AppColors.primary,
            width: 1.5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _phoneError ? Colors.red : AppColors.primary,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
