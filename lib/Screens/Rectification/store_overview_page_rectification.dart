import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:metallicz/Screens/Rectification/rectification_form.dart';
import '../../Utils/all_imports.dart';

class StoreOverViewPageRectification extends StatefulWidget {
  final String address, city, state, client_no, lon, lat;
  final String bmid, mmid, phone, branchname, username;
  final String vendorname, date, id, logourl, clientName;
  final String? issue;
  final String? issueImg;

  const StoreOverViewPageRectification({
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
    this.issue,
    this.issueImg,
  });

  @override
  State<StoreOverViewPageRectification> createState() =>
      _StoreOverViewPageRectificationState();
}

class _StoreOverViewPageRectificationState
    extends State<StoreOverViewPageRectification> {
  late GoogleMapController _mapController;
  LatLng? storeLocation;
  File? buildingImage;
  File? gsbImage;

  bool showMap = false;

  final String baseUrl = 'https://otplai.com/Metallicz/Myapi/upload_logo/';

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

  Future<void> _getCoordinatesFromCity(String city) async {
    try {
      final locations = await locationFromAddress(city);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          storeLocation = LatLng(loc.latitude, loc.longitude);
          showMap = true;
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

  void _openSmartNavigation() async {
    final lat = double.tryParse(widget.lat);
    final lon = double.tryParse(widget.lon);

    if (lat != null && lon != null && lat != 0.0 && lon != 0.0) {
      final url = Uri.parse(
          "https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } else {
      final encodedAddress = Uri.encodeComponent(widget.address);
      final url = Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=$encodedAddress");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
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

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900)),
        Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white))),
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text("Address ${widget.branchname}",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ),
          const SizedBox(height: 8),
          _infoRow("Street Line: ", widget.address),
          _infoRow("City: ", widget.city),
          _infoRow("State: ", widget.state),
          GestureDetector(
            onTap: () => _launchDialer(widget.client_no),
            child: _infoRow("Contact: ", widget.client_no),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Store Overview", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(),
            const SizedBox(height: 20),
            ...widget.issueImg!.split(',').map((imgName) {
              final isSvg = imgName.trim().toLowerCase().endsWith('.svg');
              final imageUrl = '$baseUrl${imgName.trim()}';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Issue:  ${widget.issue ?? 'No issue description'}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isSvg
                        ? SvgPicture.network(
                            imageUrl,
                            width: double.infinity,
                            height: 200,
                            placeholderBuilder: (context) => Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary)),
                          )
                        : Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
            const Center(
                child: Text("Store Location on Map",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: screenHeight * 0.25,
                width: double.infinity,
                child: storeLocation != null
                    ? GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: storeLocation!, zoom: 15),
                        markers: {
                          Marker(
                              markerId: const MarkerId("storeLocation"),
                              position: storeLocation!,
                              infoWindow:
                                  const InfoWindow(title: "Store Location")),
                        },
                        onMapCreated: (controller) =>
                            _mapController = controller,
                        myLocationEnabled: true,
                        compassEnabled: true,
                      )
                    : const Center(
                        child: Text("Loading...",
                            style: TextStyle(color: Colors.grey))),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton.icon(
                onPressed: _openSmartNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.navigation, color: Colors.white),
                label: const Text("Navigate to Store",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraRectificationElementspage(
                          id: widget.id,
                          clientName: widget.clientName,
                          branchName: widget.branchname,
                          clientLogo: widget.logourl,
                          clientAddress: widget.address,
                          city: widget.city,
                          state: widget.state,
                          clientNo: widget.client_no,
                          vendorName: widget.vendorname,
                          userName: widget.username,
                          reportDate: widget.date,
                          issue: widget.issue ?? '',
                          phone: widget.phone),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Start Rectification",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.07),
          ],
        ),
      ),
    );
  }
}
