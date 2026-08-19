import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Utils/all_imports.dart';
import 'Modal/get_recti_modal.dart';
import 'store_overview_page_rectification.dart';

class RectificationIdPage extends StatefulWidget {
  final List<Result> clients;
  final String? logoUrl;
  final String phone;
  final String vendorName;
  final String userName;

  const RectificationIdPage({
    super.key,
    required this.clients,
    this.logoUrl,
    required this.phone,
    required this.vendorName,
    required this.userName,
  });

  @override
  State<RectificationIdPage> createState() => _RectificationIdPageState();
}

class _RectificationIdPageState extends State<RectificationIdPage> {
  List<Result> filteredClients = [];
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredClients = widget.clients
        .where((client) => client.status?.toLowerCase() != 'rectification complete')
        .toList();

  }

  void updateSearch(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredClients = widget.clients
          .where((client) =>
      client.status?.toLowerCase() != 'rectification complete' &&
          (
              (client.mmId?.toString().toLowerCase() ?? '').contains(lowerQuery) ||
                  (client.bmId?.toLowerCase() ?? '').contains(lowerQuery) ||
                  (client.username?.toLowerCase() ?? '').contains(lowerQuery)
          ))
          .toList();
    });
  }


  String formatDate(String? originalDate) {
    try {
      if (originalDate == null || originalDate.isEmpty) return "No Date";
      final date = DateTime.parse(originalDate);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return originalDate ?? "No Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: isSearching
            ? TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search MM/BM/User ID...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: updateSearch,
        )
            : const Text("Rectification Id"),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  filteredClients = List.from(widget.clients);
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
              child: widget.logoUrl != null
                  ? Image.network(
                widget.logoUrl!,
                height: sh * 0.16,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image, color: Colors.white),
              )
                  : const SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    "No Logo",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredClients.length,
              itemBuilder: (context, index) {
                final client = filteredClients[index];
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
                          builder: (context) =>
                              StoreOverViewPageRectification(
                                address: client.clientAddress ?? '',
                                city: client.city ?? '',
                                state: client.state ?? '',
                                client_no: client.clientNo ?? '',
                                lon: client.lon ?? '',
                                lat: client.lat ?? '',
                                username: client.username ?? '',
                                vendorname: client.vendorName ?? '',
                                date: client.date ?? '',
                                id: client.id ?? '',
                                bmid: client.bmId ?? '',
                                mmid: client.mmId?.toString() ?? '',
                                branchname: client.branchName ?? '',
                                logourl: client.logo ?? '',
                                clientName: client.clientName ?? '',
                                phone: widget.phone,
                                issue: client.issue,
                                issueImg: client.issueImg,
                              ),
                        ),
                      );
                    },
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      "MMRE${client.mmId ?? 'No ID'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "BM: ${client.bmId ?? 'No ID'}",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    trailing: Text(
                      formatDate(client.date),
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
