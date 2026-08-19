// ignore_for_file: unused_import

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metallicz/Screens/Recee/recee_submit_form.dart';
import '../../Utils/all_imports.dart';

class StoreOverViewPage extends StatefulWidget {
  final String address, city, state, client_no, lon, lat;
  final String bmid, mmid, phone, branchname, username;
  final String vendorname, date, id, logourl, clientName;

  const StoreOverViewPage({
    super.key,
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
    required this.bmid,
    required this.mmid,
    required this.branchname,
    required this.logourl,
    required this.clientName,
    required this.phone,
  });

  @override
  State<StoreOverViewPage> createState() => _StoreOverViewPageState();
}

class _StoreOverViewPageState extends State<StoreOverViewPage> {
  late GoogleMapController _mapController;
  LatLng? storeLocation;
  File? buildingImage;
  File? gsbImage;
  int photoStep = 0;
  bool showMap = false;

  @override
  void initState() {
    super.initState();
    final lat = double.tryParse(widget.lat);
    final lon = double.tryParse(widget.lon);

    if (lat != null && lon != null && lat != 0.0 && lon != 0.0) {
      storeLocation = LatLng(lat, lon);
      showMap = true;
    } else {
      _getCoordinatesFromCity(widget.city);
    }
  }
  bool _locationFromCity = false;

  Future<void> _getCoordinatesFromCity(String city) async {
    try {
      final locations = await locationFromAddress(city);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          storeLocation = LatLng(loc.latitude, loc.longitude);
          showMap = true;
          _locationFromCity = true;
        });
      } else {
        Fluttertoast.showToast(msg: "Could not find coordinates for $city",backgroundColor: Colors.red);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error finding city location: $e",backgroundColor: Colors.red);
    }
  }

  void _openSmartNavigation() async {
    final lat = double.tryParse(widget.lat);
    final lon = double.tryParse(widget.lon);

    if (lat != null && lon != null && lat != 0.0 && lon != 0.0) {
      // ✅ Navigate using coordinates
      final url = Uri.parse(
          "https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } else {
      // ✅ Navigate using full address (Street line)
      final encodedAddress = Uri.encodeComponent(widget.address);
      final url = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$encodedAddress");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Overview", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(),
            const SizedBox(height: 24),
            _sectionTitle("Store Location on Map"),
            const SizedBox(height: 12),
            _mapWidget(screenHeight),
            const SizedBox(height: 24),
            _actionButton(
              icon: Icons.navigation,
              text: "Navigate to Store",
              color: Colors.green,
              onPressed: _openSmartNavigation,
            ),
            const SizedBox(height: 16),
            _actionButton(
              icon: Icons.assignment,
              text: "Start Recee",
              color: Colors.orange,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceeFormPage(
                      client_name: widget.clientName,
                      branchname: widget.branchname,
                      mmid: widget.mmid,
                      bmid: widget.bmid,
                      address: widget.address,
                      city: widget.city,
                      state: widget.state,
                      client_no: widget.client_no,
                      lon: widget.lon,
                      lat: widget.lat,
                      username: widget.username,
                      vendorname: widget.vendorname,
                      date: widget.date,
                      id: widget.id,
                      logourl: widget.logourl,
                      phone: widget.phone,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.07),
          ],
        ),
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
            zoom: _locationFromCity ? 10 : 14, // 🔁 Wider view for city
          ),

          compassEnabled: true,
          myLocationEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: (controller) => _mapController = controller,
          markers: _locationFromCity
              ? {} // 🔕 No marker
              : {
            Marker(
              markerId: const MarkerId("storeLocation"),
              position: storeLocation!,
              infoWindow: const InfoWindow(title: "Store Location"),
            ),
          },

        )
            : const Center(
          child: Text(
            "Loading...",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon ?? Icons.check_circle_outline, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                "Address: ${widget.branchname}",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.location_on, "Street Line", widget.address),
            _infoRow(Icons.location_city, "City", widget.city),
            _infoRow(Icons.map, "State", widget.state),
            GestureDetector(
              onTap: () => _launchDialer(widget.client_no),
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
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        Text(
                          widget.client_no,
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
          Text("$label: ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
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
