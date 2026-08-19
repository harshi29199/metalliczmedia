import 'package:http/http.dart' as http;
import '../../Utils/all_imports.dart';

class LoginProvider with ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool _isLoading = false;
  bool _isOTPSent = false;
  bool rememberMe = false;

  bool get isLoading => _isLoading;
  bool get isOTPSent => _isOTPSent;
  void resetLoginState() {
    rememberMe = false;
    phoneController.clear();
    notifyListeners();
  }

  // Load remembered phone number on app start
  Future<void> loadRememberedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('rememberedPhone');
    final remember = prefs.getBool('rememberMe') ?? false;

    if (remember && savedPhone != null) {
      phoneController.text = savedPhone;
      rememberMe = remember;
    } else {
      // 👇 Important: Reset both if not remembered
      phoneController.clear();
      rememberMe = false;
    }

    notifyListeners();
  }
  void setRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  // Save or remove remembered phone number
  Future<void> saveRememberedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('rememberedPhone', phoneController.text.trim());
      await prefs.setBool('rememberMe', true);
    } else {
      await prefs.remove('rememberedPhone');
      await prefs.setBool('rememberMe', false);
    }
  }

  // Toggle checkbox
  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  // Internal setter for loading
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // API Call to send OTP
  Future<String?> sendOTP() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) return null;

    setLoading(true);
    try {
      final uuid = const Uuid();
      final id = uuid.v4().toString();

      final uri = Uri.parse('http://otplai.com:4000/api/create_user');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'id': id,
        'Contect_no': phone,
      });

      // 🔍 Print request details
      debugPrint('--- API Request ---');
      debugPrint('URL: $uri');
      debugPrint('Headers: $headers');
      debugPrint('Body: $body');

      final response = await http.post(uri, headers: headers, body: body);

      // 🔍 Print response details
      debugPrint('--- API Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      final data = jsonDecode(response.body);

      await saveRememberedPhone();

      setLoading(false);

      if (response.statusCode == 200 && data['message'] != null) {
        return data['message'];
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      setLoading(false);
      return null;
    }
  }
}
