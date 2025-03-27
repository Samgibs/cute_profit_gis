// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../widgets/stats_card.dart';
import '../map/map_screen.dart';

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({Key? key}) : super(key: key);

  @override
  _ClientDashboardState createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Client Navigation Rail
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
                icon: Icon(Icons.map),
                label: Text('Map'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list_alt),
                label: Text('Forms'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warning),
                label: Text('Incidences'),
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
        return const MapScreen();
      case 2:
        return _buildForms();
      case 3:
        return _buildIncidences();
      case 4:
        return _buildAnalytics();
      case 5:
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
            'Dashboard',
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
                  title: 'Active Forms',
                  value: '12',
                  icon: Icons.list_alt,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Total Submissions',
                  value: '1,234',
                  icon: Icons.send,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Open Incidences',
                  value: '5',
                  icon: Icons.warning,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  title: 'Storage Used',
                  value: '2.3 GB',
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
                          'Form Submission',
                          'Water Meter Reading',
                          '10 minutes ago',
                          Icons.send,
                          AppColors.primaryBlue,
                        ),
                        const Divider(),
                        _buildActivityItem(
                          'New Incidence',
                          'Leaking Pipe',
                          '1 hour ago',
                          Icons.warning,
                          AppColors.warning,
                        ),
                        const Divider(),
                        _buildActivityItem(
                          'Map Layer Updated',
                          'Water Lines',
                          '2 hours ago',
                          Icons.map,
                          AppColors.success,
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
                          'Create Form',
                          Icons.add_chart,
                          () {
                            // TODO: Implement create form
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildQuickAction(
                          'Add Map Layer',
                          Icons.layers,
                          () {
                            // TODO: Implement add map layer
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildQuickAction(
                          'Report Incidence',
                          Icons.report_problem,
                          () {
                            // TODO: Implement report incidence
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

  Widget _buildForms() {
    // TODO: Implement forms view
    return const Center(child: Text('Forms Coming Soon'));
  }

  Widget _buildIncidences() {
    // TODO: Implement incidences view
    return const Center(child: Text('Incidences Coming Soon'));
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
