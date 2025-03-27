import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/client_list.dart';
import '../../widgets/subscription_plans.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Admin Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('Clients'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.card_membership),
                label: Text('Plans'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview();
      case 1:
        return const ClientList();
      case 2:
        return const SubscriptionPlans();
      case 3:
        return _buildAnalytics();
      case 4:
        return _buildSettings();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Total Clients',
                  value: '45',
                  icon: Icons.business,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Active Users',
                  value: '256',
                  icon: Icons.people,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Total Revenue',
                  value: '\$12,450',
                  icon: Icons.attach_money,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Storage Used',
                  value: '1.2 TB',
                  icon: Icons.storage,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildActivityItem(
                          'New Client Registration',
                          'Water Utility Co.',
                          '2 hours ago',
                          Icons.business,
                          AppColors.primaryBlue,
                        ),
                        const Divider(),
                        _buildActivityItem(
                          'Subscription Upgraded',
                          'City Planning Department',
                          '5 hours ago',
                          Icons.upgrade,
                          AppColors.success,
                        ),
                        const Divider(),
                        _buildActivityItem(
                          'Storage Limit Warning',
                          'Construction Corp',
                          '1 day ago',
                          Icons.warning,
                          AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickAction(
                          'Add New Client',
                          Icons.add_business,
                          () {
                            // TODO: Implement add client
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildQuickAction(
                          'Create Plan',
                          Icons.add_card,
                          () {
                            // TODO: Implement create plan
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildQuickAction(
                          'View Reports',
                          Icons.assessment,
                          () {
                            // TODO: Implement view reports
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 16),
              Text(title),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalytics() {
    // TODO: Implement analytics view
    return const Center(child: Text('Analytics Coming Soon'));
  }

  Widget _buildSettings() {
    // TODO: Implement settings view
    return const Center(child: Text('Settings Coming Soon'));
  }
}
