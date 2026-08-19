import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../Themes/app_colors.dart';
import '../../Themes/appImages.dart';
import 'installationid_page.dart';

class InstallationPage extends StatefulWidget {
  final String phone;
  final String vendorName;
  final String userName;

  const InstallationPage({
    super.key,
    required this.phone,
    required this.vendorName,
    required this.userName,
  });

  @override
  State<InstallationPage> createState() => _InstallationPageState();
}

class _InstallationPageState extends State<InstallationPage> {
  List<Map<String, dynamic>> installationClients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInstallationData();
  }

  Future<void> fetchInstallationData() async {
    final url = Uri.parse('http://otplai.com:4000/api/recee_data');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"vendorname": widget.vendorName}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> data = jsonResponse['result'] ?? [];

        final Map<String, List<dynamic>> groupedByClientName = {};

        for (var client in data) {
          final clientName =
              client['client_name']?.toString().trim() ?? 'Unnamed Client';
          if (!groupedByClientName.containsKey(clientName)) {
            groupedByClientName[clientName] = [];
          }
          groupedByClientName[clientName]!.add(client);
        }

        final List<Map<String, dynamic>> resultList = [];

        for (var entry in groupedByClientName.entries) {
          final clientName = entry.key;
          final clients = entry.value;

          // final installationClients = clients
          //     .where((c) =>
          //         (c['type']?.toString().toLowerCase() ?? '') ==
          //             'installation' &&
          //         (c['status']?.toString().toLowerCase() ?? '') == 'pending')
          //     .toList();

          final installationClients = clients
              .where((c) =>
                  (c['type']?.toString().toLowerCase() ?? '') ==
                      'installation' &&
                  (c['status']?.toString().toLowerCase() ?? '') !=
                      'installation complete')
              .toList();

          if (installationClients.isNotEmpty) {
            final installList = installationClients.map((c) {
              return {
                'install_ref': '${c['mm_id']}/${c['bm_id']}',
                'id': c['id'],
                'date': c['date'],
                'address': c['client_address'] ?? '',
                'city': c['city'] ?? '',
                'clientno': c['client_no'] ?? '',
                'log': c['longitude'] ?? '',
                'branchName': c['branch_name'] ?? '',
                'lat': c['latitude'] ?? '',
                'state': c['state'] ?? '',
                'username': c['username'] ?? '',
                'status': c['status'] ?? '',
                'vendorname': c['vendor_name'] ?? '',
                'installation_img': c['installation_img'] ?? '', // ✅ Add this line
              };
            }).toList();


            resultList.add({
              'clientName': clientName,
              'image': installationClients[0]['logo'] ?? '',
              'installationIds': installList,
              'branchName': installationClients[0]['branch_name'] ?? '',
              'address': installationClients[0]['client_address'] ?? '',
              'city': installationClients[0]['city'] ?? '',
              'clientno': installationClients[0]['client_no'] ?? '',
              'log': installationClients[0]['longitude'] ?? '',
              'lat': installationClients[0]['latitude'] ?? '',
              'state': installationClients[0]['state'] ?? '',
              'vendorname': installationClients[0]['vendor_name'] ?? '',
              'status': installationClients[0]['status'] ?? '',
              'id': installationClients[0]['id'] ?? '',
              'username': installationClients[0]['username'] ?? '',
              'installation_img': installationClients[0]['installation_img'] ?? '', // ✅ Add here too
            });

          }
        }

        setState(() {
          installationClients = resultList;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Assigned Installation",
          style: TextStyle(color: Colors.white, fontSize: sw * 0.050),
        ),
      ),
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(vertical: sh * 0.02),
            child: Column(
              children: [
                Image.asset(logo, width: sw * 0.2),
                SizedBox(height: sw * 0.008),
                Text(
                  "Metallicz Media™",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: sh * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "We get you noticed!",
                  style: TextStyle(
                    color: AppColors.subtitleText,
                    fontSize: sh * 0.018,
                  ),
                ),
              ],
            ),
          ),
          Container(
              height: 4, width: double.infinity, color: AppColors.primary),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ))
                : installationClients.isEmpty
                    ? Center(
                        child: Lottie.asset(
                        'assets/Icons/not_found.json',
                        height: sh * 0.25,
                        fit: BoxFit.cover,
                      ))
                    : Padding(
                        padding: const EdgeInsets.all(12),
                        child: GridView.builder(
                          itemCount: installationClients.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.8,
                          ),
                          itemBuilder: (context, index) {
                            final client = installationClients[index];
                            print("raju $client");
                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration:
                                  Duration(milliseconds: 600 + (index * 100)),
                              builder: (context, value, child) {
                                return Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001) // Perspective
                                    ..rotateX(0.05 * (1 - value))
                                    ..rotateY(0.05 * (1 - value))
                                    ..translate(
                                        0.0, 20 * (1 - value)), // Float up
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => InstallationIdPage(
                                        phone: widget.phone,
                                        clientName: client['clientName'],
                                        installationIds:
                                            client['installationIds'],
                                        address: client['address'],
                                        city: client['city'],
                                        clientno: client['clientno'],
                                        log: client['log'],
                                        lat: client['lat'],
                                        state: client['state'],
                                        vendorname: client['vendorname'],
                                        id: client['id'],
                                        status: client['status'],
                                        logoUrl: client['image'],
                                        userName: widget.userName,
                                        branchName: client['branchName'],
                                        installationImg: client['installation_img'],
                                      ),
                                    ),
                                  );
                                  print(
                                    "hsdfghjk${client['branchName']}",
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      client['image'],
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                            child: CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ));
                                      },
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.error,
                                          color: Colors.red),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
