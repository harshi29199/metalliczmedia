import '../Utils/all_imports.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..forward();

  late final Animation<double> _animation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(logo, width: width*0.2),
                SizedBox(height: height * 0.01),
                Text(
                  "Metallicz Media™",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: height * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "We get you noticed!",
                  style: TextStyle(
                    color: AppColors.subtitleText,
                    fontSize: height * 0.018,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
