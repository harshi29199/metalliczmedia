import '../../Utils/all_imports.dart';
import 'installation_storeoverview.dart';

class InstallationIdPage extends StatefulWidget {
  final String phone;
  final String clientName;
  final String address;
  final String city;
  final String clientno;
  final String state;
  final String log;
  final String lat;
  final String userName;
  final String vendorname;
  final String id;
  final String status;
  final String logoUrl;
  final String branchName;
  final String installationImg;

  final List<Map<String, dynamic>> installationIds;

  const InstallationIdPage({
    super.key,
    required this.clientName,

    required this.installationIds,
    required this.phone,
    required this.address,
    required this.city,
    required this.clientno,
    required this.log,
    required this.lat,
    required this.state,
    required this.vendorname,
    required this.id,
    required this.status,
    required this.logoUrl,
    required this.userName, required this.branchName, required this.installationImg,
  });

  @override
  State<InstallationIdPage> createState() => _InstallationIdPageState();
}

class _InstallationIdPageState extends State<InstallationIdPage> {
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();
  late List<Map<String, dynamic>> filteredIds;

  String safeString(dynamic value) => value?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    // filteredIds = widget.installationIds
    //     .where((item) => item['status']?.toString().toLowerCase() == 'pending')
    //     .toList();
    filteredIds = widget.installationIds
        .where((item) => item['status']?.toString().toLowerCase() != 'installation complete')
        .toList();

  }

  void updateSearch(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredIds = widget.installationIds.where((item) {
        final status = item['status']?.toString().toLowerCase();
        final refParts = item['install_ref']?.toString().split('/') ?? [];
        final mm = refParts.isNotEmpty ? refParts[0].toLowerCase() : '';
        final bm = refParts.length > 1 ? refParts[1].toLowerCase() : '';
        // return status == 'pending' &&
        //     (mm.contains(lowerQuery) || bm.contains(lowerQuery));
        return status != 'installation complete' &&
            (mm.contains(lowerQuery) || bm.contains(lowerQuery));

      }).toList();
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(
        const Duration(seconds: 1)); // Simulate delay or fetch API
    setState(() {
      // Reapply filter or reload data
      // filteredIds = widget.installationIds
      //     .where(
      //         (item) => item['status']?.toString().toLowerCase() == 'pending')
      //     .toList();
      filteredIds = widget.installationIds
          .where((item) =>
      item['status']?.toString().toLowerCase() != 'installation complete')
          .toList();

    });
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search Installation ID...',
                  hintStyle:
                      TextStyle(color: Colors.white70, fontSize: sw * 0.040),
                  border: InputBorder.none,
                ),
                onChanged: updateSearch,
              )
            : Text(
                "Installation Id",
                style: const TextStyle(color: Colors.white),
              ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  filteredIds = widget.installationIds
                      .where((item) =>
                          item['status']?.toString().toLowerCase() == 'pending')
                      .toList();
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.logoUrl,
                width: sw,
                height: sh * 0.16,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredIds.length,
              itemBuilder: (context, index) {
                final item = filteredIds[index];
                return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary,
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InstallationStoreOverview(
                              phone: widget.phone,
                              clientAddress: safeString(item['address']),
                              city: safeString(item['city']),
                              state: safeString(item['state']),
                              clientNo: safeString(item['clientno']),
                              lon: safeString(item['log']),
                              lat: safeString(item['lat']),
                              date: safeString(item['date']),
                              id: safeString(item['id']),
                              vendorName: widget.vendorname,
                              userName: widget.userName,
                              logoUrl: widget.logoUrl,
                              clientName: widget.clientName, branchName: widget.branchName,
                                installationImg:widget.installationImg

                            ),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.description,
                            color: Colors.white, size: 28),
                      ),
                      title: Text(
                        "MM ${item['install_ref'].toString().split('/')[0]}", // You can use item['mm_id'] if available
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      subtitle: Text(
                        "BM ${item['install_ref'].toString().split('/')[1]}",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['date'] ?? 'No Date',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
