import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:metallicz/Screens/Rectification/rectification_id_page.dart';
import '../../Utils/all_imports.dart';
import 'Modal/get_recti_modal.dart';

class AllClientsScreenRectification extends StatefulWidget {
  final String phone;
  final String vendorName;
  final String userName;

  const AllClientsScreenRectification({
    super.key,
    required this.phone,
    required this.vendorName,
    required this.userName,
  });

  @override
  State<AllClientsScreenRectification> createState() =>
      _AllClientsScreenRectificationState();
}

class _AllClientsScreenRectificationState
    extends State<AllClientsScreenRectification> {
  List<Result> rectificationClients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRectificationClients();
  }

  Future<void> fetchRectificationClients() async {
    final url = Uri.parse('http://otplai.com:4000/api/recee_data');
    final body = jsonEncode({"vendorname": widget.vendorName});

    print("📤 Sending POST to: $url");
    print("📨 Body: $body");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("📥 Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = GetRectificationModal.fromJson(data);

        final filteredClients = model.result?.where((client) {
          final type = client.type?.toLowerCase().trim();
          final status = client.status?.toLowerCase().trim();
          return type == 'rectification' && status != 'rectification complete';
        }).toList() ?? [];


        print("✅ Rectification Clients: ${filteredClients.length}");
        for (var client in filteredClients) {
          print(
              "🔹 ${client.clientName} | ${client.branchName} | ${client.status}");
        }

        setState(() {
          rectificationClients = filteredClients;
          isLoading = false;
        });
      } else {
        print("❌ Server Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❗ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  Future<String?> fetchLogoFromClientAPI(String? clientName) async {
    if (clientName == null) return null;
    final url = Uri.parse('http://otplai.com:4000/api/client_get');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"client_name": clientName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final logo = data['result']?[0]?['logo'];
        if (logo != null && logo.toString().isNotEmpty) {
          return "https://otplai.com/Metallicz/Myapi/upload_logo/$logo";
        }
      }
    } catch (e) {
      print("Error fetching fallback logo: $e");
    }
    return null;
  }

  Future<String?> _resolveClientLogo(List<Result> clients) async {
    final logo = clients.first.logo;
    if (logo != null && logo.isNotEmpty && logo != "no_logo") {
      return logo.startsWith("http")
          ? logo
          : "https://otplai.com/Metallicz/Myapi/upload_logo/$logo";
    }
    final clientName = clients.first.clientName;
    return await fetchLogoFromClientAPI(clientName);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Map<String, List<Result>> groupedByClientName = {};
    for (var client in rectificationClients) {
      final key = client.clientName ?? 'Unnamed Client';
      groupedByClientName.putIfAbsent(key, () => []).add(client);
    }
    final groupedList = groupedByClientName.entries.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainActivityScreen(
                phone: widget.phone,
                vendorName: widget.vendorName,
                isLoading: true,
              ),
            ),
          ),
        ),
        title: const Text(
          "Assigned Rectification",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            child: Column(
              children: [
                Image.asset(logo, width: screenWidth * 0.2),
                heightGap(screenHeight * 0.008),
                Text(
                  "Metallicz Media™",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "We get you noticed!",
                  style: TextStyle(
                    color: AppColors.subtitleText,
                    fontSize: screenHeight * 0.018,
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
                    child: CircularProgressIndicator(color: AppColors.primary))
                : groupedList.isEmpty
                    ? Center(
                        child: Lottie.asset(
                          'assets/Icons/not_found.json',
                          height: screenHeight * 0.25,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        child: GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: groupedList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.8,
                          ),
                          itemBuilder: (context, index) {
                            final clientName = groupedList[index].key;
                            final clients = groupedList[index].value;

                            return FutureBuilder<String?>(
                              future: _resolveClientLogo(clients),
                              builder: (context, snapshot) {
                                final logoUrl = snapshot.data;

                                return TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration:
                                      Duration(milliseconds: 600 + index * 100),
                                  builder: (context, value, child) {
                                    return Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.identity()
                                        ..setEntry(3, 2, 0.001)
                                        ..rotateX(0.05 * (1 - value))
                                        ..rotateY(0.05 * (1 - value))
                                        ..translate(0.0, 20 * (1 - value)),
                                      child:
                                          Opacity(opacity: value, child: child),
                                    );
                                  },
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RectificationIdPage(
                                            clients: clients, // Pass the list of Result
                                            logoUrl: logoUrl,
                                            phone: widget.phone,
                                            vendorName: widget.vendorName,
                                            userName: widget.userName,
                                          ),
                                        ),
                                      );
                                    },

                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: logoUrl != null
                                            ? Image.network(
                                                logoUrl,
                                                fit: BoxFit.contain,
                                                width: double.infinity,
                                                height: double.infinity,
                                              )
                                            : Center(
                                                child: Text(
                                                  clientName,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        screenHeight * 0.018,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          )
        ],
      ),
      backgroundColor: AppColors.scaffoldBackground,
    );
  }
}
