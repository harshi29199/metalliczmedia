import '../../Utils/all_imports.dart';

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Deep blue Paytm-like background
      appBar: AppBar(
        title: const Text(
          "MM Wallet",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.account_balance_wallet, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Wallet Balance Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Wallet Balance",
                  style: TextStyle(fontSize: 16, color: AppColors.primary),
                ),
                SizedBox(height: 8),
                Text(
                  "₹ 2,345.75",
                  style: TextStyle(
                    fontSize: 28,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(Icons.add, "Add Bills"),
                _buildQuickAction(Icons.receipt_long, "Passbook"),
                _buildQuickAction(Icons.more_horiz, "More"),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recent Transactions
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                children: [
                  const Text(
                    "Recent Received Amount",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionTile(
                      "Received from Metallicz Media", "+ ₹390", "Yesterday"),
                  _buildTransactionTile(
                      "Received from Metallicz Media", "+ ₹1278", "3 days ago"),
                  _buildTransactionTile(
                      "Received from Metallicz Media", "+ ₹890", "2 days ago"),
                  _buildTransactionTile(
                      "Received from Metallicz Media", "+ ₹1478", "3 days ago"),
                  _buildTransactionTile(
                      "Received from Metallicz Media", "+ ₹1500", "1 week ago"),
                  _buildTransactionTile(
                      "Received from Metallicz Media", "+ ₹1600", "1 week ago"),
                  _buildTransactionTile(
                      "Received from Metallicz Media", "+ ₹1500", "1 week ago"),
                  _buildTransactionTile(
                      "Received from Metallicz Media", "+ ₹1900", "1 week ago"),
                  _buildTransactionTile(
                      "Received from Metallicz Media", "+ ₹2200", "1 week ago"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.black,
          radius: 24,
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 12)),
      ],
    );
  }

  Widget _buildTransactionTile(String title, String amount, String date) {
    final isCredit = amount.contains("+");
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isCredit ? Colors.green[100] : Colors.red[100],
        child: Icon(
          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
          color: isCredit ? Colors.green : Colors.red,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: TextStyle(
          color: isCredit ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
