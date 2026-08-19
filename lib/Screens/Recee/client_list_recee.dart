import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import '../../Utils/all_imports.dart';
import 'modals/recee_detail_modal.dart' as recee;

class AllClientsScreenRecee extends StatefulWidget {
  final String phone;
  final String vendorName;
  const AllClientsScreenRecee({
    super.key,
    required this.phone,
    required this.vendorName,
  });

  @override
  State<AllClientsScreenRecee> createState() => _AllClientsScreenReceeState();
}

class _AllClientsScreenReceeState extends State<AllClientsScreenRecee> {
  List<recee.Result> receeClients = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    fetchReceeClients();
  }

  Future<void> fetchReceeClients() async {
    final url = Uri.parse('http://otplai.com:4000/api/recee_data');
    final body = {"vendorname": widget.vendorName};

    try {
      print("📤 Request URL: $url");
      print("📤 Request Body: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("📥 Response Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = recee.receeDetailModal.fromJson(data);

        setState(() {
          receeClients = model.result ?? [];
          isLoading = false;
        });
      } else {
        print("❌ Failed to load data from API");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Exception occurred: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> searchReceeClients(String query) async {
    if (query.trim().isEmpty) return;

    final url = Uri.parse('http://otplai.com:4000/api/recee_data');
    final body = {
      "vendorname": "all", // override
      "search": query.trim()
    };

    try {
      setState(() {
        isLoading = true;
        _searchQuery = query;
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = recee.receeDetailModal.fromJson(data);
        setState(() {
          receeClients = (model.result ?? []).where((client) {
            final status = client.status?.toLowerCase().trim();
            final type = client.type?.toLowerCase().trim();
            return type == "recee" &&
                status != null &&
                !["client approved", "recee complete"].contains(status);
          }).toList();
        });
      } else {
        print("❌ Search failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception during search: $e");
    } finally {
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
      print("❌ Error fetching fallback logo: $e");
    }
    return null;
  }

  Future<String?> _resolveClientLogo(List<recee.Result> clients) async {
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

    Map<String, List<recee.Result>> groupedByClientName = {};
    for (var client in receeClients) {
      final status = client.status?.toLowerCase().trim();
      final type = client.type?.toLowerCase().trim();
      final mmid = client.mmId?.toString().trim();

      if (type == "recee" &&
          status != null &&
          !["client approved", "recee complete"].contains(status)) {
        if (_searchQuery.isEmpty || mmid == _searchQuery.trim()) {
          final key = client.clientName ?? 'Unnamed Client';
          groupedByClientName.putIfAbsent(key, () => []).add(client);
        }
      }
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
        title:
            const Text("Assigned Recee", style: TextStyle(color: Colors.white)),
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
          Padding(
            padding:EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.primary.withOpacity(0.8), width: 1),
              ),
              child: TextField(
                cursorColor: AppColors.primary.withOpacity(0.8),
                controller: _searchController,
                textInputAction: TextInputAction.search,
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w500),
                onSubmitted: (query) => searchReceeClients(query),
                decoration: InputDecoration(
                  hintText: 'Search MMID...',
                  hintStyle:
                      TextStyle(color: AppColors.primary.withOpacity(0.3)),
                  prefixIcon: Icon(Icons.search,
                      color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: AppColors.primary),
                          onPressed: () {
                            _searchController.clear();
                            _searchQuery = '';
                            fetchReceeClients();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
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
                            final filteredClients = _searchQuery.isNotEmpty
                                ? clients
                                    .where((c) =>
                                        c.mmId?.toString() ==
                                        _searchQuery.trim())
                                    .toList()
                                : clients;
                            return FutureBuilder<String?>(
                              future: _resolveClientLogo(clients),
                              builder: (context, snapshot) {
                                final logoUrl = snapshot.data;

                                return TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: Duration(
                                      milliseconds: 600 + (index * 100)),
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
                                          builder: (context) => ReceeIdPage(
                                            // clients: clients,
                                            clients: filteredClients,
                                            logoUrl: logoUrl,
                                            phone: widget.phone,
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
                                                Colors.white.withOpacity(0.3),
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
