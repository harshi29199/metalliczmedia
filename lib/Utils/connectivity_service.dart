// import 'package:connectivity_plus/connectivity_plus.dart';
//
// class ConnectivityService {
//   final Connectivity _connectivity = Connectivity();
//
//   Stream<List<ConnectivityResult>> get connectivityStream =>
//       _connectivity.onConnectivityChanged;
// }
//
//
//
// class NoInternetScreen extends StatelessWidget {
//   const NoInternetScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.wifi_off, size: 80, color:AppColors.primary),
//             SizedBox(height: 20),
//             Text(
//               "No Internet Connection",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text("Please check your network settings"),
//           ],
//         ),
//       ),
//     );
//   }
// }
