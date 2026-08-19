import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../../../Utils/all_imports.dart';
import 'installation_in_progress.dart';

class InstallationStoreOverview extends StatefulWidget {
  final String phone;
  final String clientAddress;
  final String city;
  final String state;
  final String clientNo;
  final String lon;
  final String lat;
  final String date;
  final String vendorName;
  final String userName;
  final String id;
  final String logoUrl;
  final String branchName;
  final String clientName;
  final String installationImg;

  const InstallationStoreOverview({
    super.key,
    required this.phone,
    required this.clientAddress,
    required this.city,
    required this.state,
    required this.clientNo,
    required this.lon,
    required this.lat,
    required this.date,
    required this.vendorName,
    required this.userName,
    required this.id,
    required this.logoUrl,
    required this.clientName,
    required this.branchName,
    required this.installationImg,
  });

  @override
  State<InstallationStoreOverview> createState() =>
      _InstallationStoreOverviewState();
}

class _InstallationStoreOverviewState extends State<InstallationStoreOverview> {
  late GoogleMapController _mapController;
  LatLng? storeLocation;

  @override
  void initState() {
    super.initState();
    final lat = double.tryParse(widget.lat);
    final lon = double.tryParse(widget.lon);

    if (lat != null && lon != null && lat != 0.0 && lon != 0.0) {
      storeLocation = LatLng(lat, lon);
    } else {
      _getCoordinatesFromCity(widget.city);
    }
  }

  bool _locationFromCity = false;

  bool _isDownloading = false;

  Future<void> _getCoordinatesFromCity(String city) async {
    try {
      final locations = await locationFromAddress(city);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          storeLocation = LatLng(loc.latitude, loc.longitude);
          _locationFromCity = true; // 👈 Add this line
        });
      } else {
        Fluttertoast.showToast(
            msg: "Could not find coordinates for $city",
            backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error finding city location: $e", backgroundColor: Colors.red);
    }
  }

  void _openGoogleMaps() async {
    final lat = double.tryParse(widget.lat);
    final lon = double.tryParse(widget.lon);

    final url = (lat != null && lon != null && lat != 0.0 && lon != 0.0)
        ? Uri.parse(
            "https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving")
        : Uri.parse(
            "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.clientAddress)}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      Fluttertoast.showToast(
          msg: "Could not open Google Maps", backgroundColor: Colors.red);
    }
  }

  Future<void> _refreshPage() async {
    setState(() {
      _isDownloading = false;
      storeLocation = null;
    });

    final lat = double.tryParse(widget.lat);
    final lon = double.tryParse(widget.lon);

    if (lat != null && lon != null && lat != 0.0 && lon != 0.0) {
      setState(() {
        storeLocation = LatLng(lat, lon);
        _locationFromCity = false;
      });
    } else {
      await _getCoordinatesFromCity(widget.city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Installation Store",
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: Colors.black,
        color: AppColors.primary,
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoCard(),
              const SizedBox(height: 24),
              _sectionTitle("Store Location on Map"),
              const SizedBox(height: 12),
              _mapWidget(screenHeight),
              const SizedBox(height: 20),
              _actionButton(
                icon: Icons.navigation,
                text: "Navigate to Store",
                color: Colors.green,
                onPressed: _openGoogleMaps,
              ),
              const SizedBox(height: 16),
              _actionButton(
                text: "Start Installation",
                color: Colors.orange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InstallationInProgressPage(
                        phone: widget.phone,
                        address: widget.clientAddress,
                        city: widget.city,
                        clientno: widget.clientNo,
                        state: widget.state,
                        log: widget.lon,
                        lat: widget.lat,
                        username: widget.userName,
                        vendorname: widget.vendorName,
                        id: widget.id,
                        date: widget.date,
                        logoUrl: widget.logoUrl,
                        clientName: widget.clientName,
                        branchName: widget.branchName,
                        installationImg:
                            'https://otplai.com/Metallicz/Myapi/upload_ppt/${widget.installationImg}',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _actionButton(
                text: _isDownloading ? "Downloading..." : "Download PPT",
                color: Colors.deepOrange,
                isLoading: _isDownloading,
                onPressed: _isDownloading ? null : _downloadPPT,
              ),
              SizedBox(height: screenHeight * 0.07),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.orange[700],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Address: ${widget.branchName}",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.location_on, "Street Line", widget.clientAddress),
            _infoRow(Icons.location_city, "City", widget.city),
            _infoRow(Icons.map, "State", widget.state),
            GestureDetector(
              onTap: () => _launchDialer(widget.clientNo),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone, color: Colors.white),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Contact",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          widget.clientNo,
                          style: const TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text("$label: ",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Center(
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
    );
  }

  Widget _mapWidget(double screenHeight) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: screenHeight * 0.25,
        width: double.infinity,
        child: storeLocation != null
            ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: storeLocation!,
                  zoom: _locationFromCity ? 10 : 14,
                ),
                myLocationEnabled: true,
                compassEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
                markers: _locationFromCity
                    ? {}
                    : {
                        Marker(
                          markerId: const MarkerId("storeLocation"),
                          position: storeLocation!,
                          infoWindow: const InfoWindow(title: "Store Location"),
                        ),
                      },
              )
            : const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Icon(icon ?? Icons.check_circle_outline, color: Colors.white),
        label: Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Future<void> _downloadPPT() async {
    try {
      setState(() => _isDownloading = true);
      final status = await Permission.manageExternalStorage.request();
      if (await Permission.manageExternalStorage.isDenied) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          Fluttertoast.showToast(
              msg: 'Storage permission denied', backgroundColor: Colors.red);
          return;
        }
      }


      final fileName = widget.installationImg.trim();
      final url = 'https://otplai.com/Metallicz/Myapi/upload_ppt/$fileName';
      final response = await http.get(Uri.parse(url));
      if (widget.installationImg.trim().isEmpty) {
        Fluttertoast.showToast(
            msg: 'No file available to download', backgroundColor: Colors.red);
        return;
      }

      if (response.statusCode == 200) {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        final filePath = '${downloadsDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        Fluttertoast.showToast(
            msg: 'PPT saved to Downloads/$fileName',
            backgroundColor: AppColors.primary);
        OpenFile.open(filePath);
      } else {
        Fluttertoast.showToast(
            msg: 'Failed to download PPT (${response.statusCode})',
            backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Download error: $e', backgroundColor: Colors.red);
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  Future<void> _launchDialer(String phoneNumber) async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.intent.action.DIAL',
        data: Uri.encodeFull('tel:$phoneNumber'),
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } else {
      final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dialer not available')),
        );
      }
    }
  }
}
