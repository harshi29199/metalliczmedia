import '../../Utils/all_imports.dart';
import 'modals/recee_detail_modal.dart' as recee;

class ReceeIdPage extends StatefulWidget {
  final List<recee.Result> clients;
  final String? logoUrl;
  final String phone;
  const ReceeIdPage(
      {super.key, required this.clients, this.logoUrl, required this.phone});

  @override
  State<ReceeIdPage> createState() => _ReceeIdPageState();
}

class _ReceeIdPageState extends State<ReceeIdPage> {
  List<recee.Result> filteredClients = [];
  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _applyPendingFilter();
  }

  void _applyPendingFilter() {
    print("======== ALL CLIENTS RECEIVED ========");
    for (var client in widget.clients) {
      print("ID: ${client.id}, Status: ${client.status}, MM: ${client.mmId}, BM: ${client.bmId}, Username: ${client.username}");
    }

    filteredClients = widget.clients.where((client) {
      final status = client.status?.toLowerCase();
      return status != 'recee complete' && status != 'client approved';
    }).toList();

    print("======== FILTERED CLIENTS ========");
    for (var client in filteredClients) {
      print("Showing ID: ${client.id}, Status: ${client.status}");
    }
  }



  void updateSearch(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredClients = widget.clients.where((client) {
        final status = client.status?.toLowerCase();
        final mm = client.mmId?.toString().toLowerCase() ?? '';
        final bm = client.bmId?.toLowerCase() ?? '';
        final user = client.username?.toLowerCase() ?? '';

        return status != 'recee complete' &&
            status != 'client approved' &&
            (mm.contains(lowerQuery) ||
                bm.contains(lowerQuery) ||
                user.contains(lowerQuery));
      }).toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            : const Text("Recee Id"),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  _applyPendingFilter();
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
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.16,
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
                      print("${client.clientAddress}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoreOverViewPage(
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
                      "MMRE${client.mmId ?? client.mmId ?? 'No ID'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    subtitle: Text(
                      "BM: ${client.bmId ?? client.bmId ?? 'No ID'}",
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
                          client.date ?? 'No Date',
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (client.status?.toLowerCase() == 'pending') ? 'Pending' : '',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
