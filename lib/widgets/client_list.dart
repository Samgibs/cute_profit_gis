import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/client.dart';

class ClientList extends StatefulWidget {
  const ClientList({Key? key}) : super(key: key);

  @override
  _ClientListState createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  List<Client> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    // TODO: Load clients from API
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _clients = [
        Client(
          id: '1',
          name: 'Water Utility Co',
          industry: 'Utilities',
          status: 'active',
          subscriptionPlan: 'Enterprise',
          usersCount: 25,
          storageUsed: '500 GB',
        ),
        Client(
          id: '2',
          name: 'City Planning Department',
          industry: 'Government',
          status: 'active',
          subscriptionPlan: 'Professional',
          usersCount: 15,
          storageUsed: '200 GB',
        ),
        Client(
          id: '3',
          name: 'Construction Corp',
          industry: 'Construction',
          status: 'trial',
          subscriptionPlan: 'Basic',
          usersCount: 5,
          storageUsed: '50 GB',
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildClientList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add client
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clients',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search clients...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.filter_list),
                      SizedBox(width: 8),
                      Text('Filter'),
                    ],
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('All Clients'),
                  ),
                  const PopupMenuItem(
                    value: 'active',
                    child: Text('Active'),
                  ),
                  const PopupMenuItem(
                    value: 'trial',
                    child: Text('Trial'),
                  ),
                  const PopupMenuItem(
                    value: 'suspended',
                    child: Text('Suspended'),
                  ),
                ],
                onSelected: (value) {
                  // TODO: Implement filtering
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientList() {
    final filteredClients = _clients.where((client) {
      return client.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          client.industry.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredClients.length,
      itemBuilder: (context, index) {
        final client = filteredClients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              // TODO: Navigate to client details
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              client.industry,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusChip(client.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoItem(
                        'Plan',
                        client.subscriptionPlan,
                        Icons.card_membership,
                      ),
                      const SizedBox(width: 24),
                      _buildInfoItem(
                        'Users',
                        client.usersCount.toString(),
                        Icons.people,
                      ),
                      const SizedBox(width: 24),
                      _buildInfoItem(
                        'Storage',
                        client.storageUsed,
                        Icons.storage,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement manage users
                        },
                        icon: const Icon(Icons.people),
                        label: const Text('Manage Users'),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement edit client
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement delete client
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = AppColors.success;
        break;
      case 'trial':
        color = AppColors.warning;
        break;
      case 'suspended':
        color = AppColors.error;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
