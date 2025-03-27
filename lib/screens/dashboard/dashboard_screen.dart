import 'package:flutter/material.dart';
import '../../widgets/side_menu.dart';
import '../../constants/colors.dart';
import '../../services/dashboard_service.dart';
import '../../models/dashboard_stats.dart';
import '../forms/form_builder_screen.dart';
import '../forms/form_submission_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isMenuExpanded = true;
  bool _isLoading = true;
  DashboardStats? _stats;
  List<Map<String, dynamic>> _recentSubmissions = [];
  Map<String, dynamic> _formAnalytics = {};
  Map<String, dynamic> _incidenceAnalytics = {};
  Map<String, dynamic> _mapLayerStats = {};
  Map<String, dynamic> _userActivity = {};
  Map<String, dynamic> _dataCollectionStats = {};
  Map<String, dynamic> _subscriptionStats = {};
  String? _selectedVisualization = 'line';
  List<Map<String, dynamic>> _dashboards = [];
  String? _selectedDashboardId;

  @override
  void initState() {
    super.initState();
    _loadDashboards();
    _loadDashboardData();
  }

  Future<void> _loadDashboards() async {
    try {
      final dashboardService = DashboardService();
      final dashboards = await dashboardService.getDashboards();
      setState(() {
        _dashboards = dashboards;
        if (dashboards.isNotEmpty && _selectedDashboardId == null) {
          _selectedDashboardId = dashboards[0]['id'];
        }
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final dashboardService = DashboardService();
      final stats = await dashboardService.getDashboardStats();
      final submissions = await dashboardService.getRecentSubmissions();
      final formAnalytics = await dashboardService.getFormAnalytics();
      final incidenceAnalytics = await dashboardService.getIncidenceAnalytics();
      final mapLayerStats = await dashboardService.getMapLayerStats();
      final userActivity = await dashboardService.getUserActivity();
      final dataCollectionStats =
          await dashboardService.getDataCollectionStats();
      final subscriptionStats = await dashboardService.getSubscriptionStats();

      setState(() {
        _stats = stats;
        _recentSubmissions = submissions;
        _formAnalytics = formAnalytics;
        _incidenceAnalytics = incidenceAnalytics;
        _mapLayerStats = mapLayerStats;
        _userActivity = userActivity;
        _dataCollectionStats = dataCollectionStats;
        _subscriptionStats = subscriptionStats;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          if (_isMenuExpanded)
            SideMenu(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              onLogout: () {
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                authService.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Expanded(
                    child: _buildContent(),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showAddDialog(context),
              child: const Icon(Icons.add),
              backgroundColor: AppColors.primaryBlue,
            )
          : null,
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/Cute Profit GEO Logo.png',
                    height: 40,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Create or Submit Data',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'What would you like to do?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    context,
                    icon: Icons.add_chart,
                    label: 'Design Form',
                    subtitle: 'Create a new data collection form',
                    color: AppColors.primaryBlue,
                    onTap: () async {
                      Navigator.pop(context);
                      _showLocationRecommendation(context);
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormBuilderScreen(),
                        ),
                      );

                      // If form was created successfully, show dashboard generation dialog
                      if (result != null && result is Map<String, dynamic>) {
                        _showDashboardGenerationDialog(context, result);
                      }
                    },
                  ),
                  _buildActionButton(
                    context,
                    icon: Icons.edit_document,
                    label: 'Collect Data',
                    subtitle: 'Fill out an existing form',
                    color: AppColors.success,
                    onTap: () async {
                      Navigator.pop(context);
                      _showLocationRecommendation(context);
                      _showFormSelectionDialog(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLocationRecommendation(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/Cute Profit GEO Logo.png',
                height: 40,
              ),
              const SizedBox(height: 16),
              const Text(
                'Location Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'For better data accuracy, we recommend enabling location services. This helps in mapping and tracking your data collection points.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        side: BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Skip Location',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement location permission request
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Enable Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFormSelectionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/Cute Profit GEO Logo.png',
                    height: 40,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Select Data Collection Form',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Choose a form to start collecting data:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: 2, // Replace with actual form count
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.description,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        title: Text(
                          'Form ${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Tap to start data collection',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Last used: 2 hours ago',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormSubmissionScreen(
                                formId: (index + 1).toString(),
                                formName: 'Form ${index + 1}',
                                fields: [], // Replace with actual form fields
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isMenuExpanded ? Icons.menu_open : Icons.menu,
              color: AppColors.primaryBlue,
            ),
            onPressed: () {
              setState(() {
                _isMenuExpanded = !_isMenuExpanded;
              });
            },
          ),
          const SizedBox(width: 16),
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            color: AppColors.primaryBlue,
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            color: AppColors.primaryBlue,
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return _buildMapContent();
      case 2:
        return _buildFormsContent();
      case 3:
        return _buildIncidencesContent();
      case 4:
        return _buildAnalyticsContent();
      case 5:
        return _buildSettingsContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/Cute Profit GEO Logo.png',
                height: 40,
              ),
              const SizedBox(width: 16),
              const Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDashboardSelector(),
          if (_dashboards.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_customize,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Dashboards Available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a form and generate a dashboard to get started',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Form'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1200
                    ? 4
                    : constraints.maxWidth > 800
                        ? 3
                        : constraints.maxWidth > 600
                            ? 2
                            : 1;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      title: 'Total Forms',
                      value: _stats?.totalForms.toString() ?? '0',
                      icon: Icons.list_alt,
                      color: AppColors.primaryBlue,
                    ),
                    _buildStatCard(
                      title: 'Total Submissions',
                      value: _stats?.totalSubmissions.toString() ?? '0',
                      icon: Icons.edit_document,
                      color: AppColors.success,
                    ),
                    _buildStatCard(
                      title: 'Open Incidences',
                      value: _stats?.openIncidences.toString() ?? '0',
                      icon: Icons.warning,
                      color: AppColors.warning,
                    ),
                    _buildStatCard(
                      title: 'Active Users',
                      value: _stats?.activeUsers.toString() ?? '0',
                      icon: Icons.people,
                      color: AppColors.info,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            _buildDataVisualization(),
            const SizedBox(height: 24),
            _buildRecentActivity(),
          ],
        ],
      ),
    );
  }

  Widget _buildDashboardSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Select Dashboard:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedDashboardId,
              isExpanded: true,
              hint: const Text('Select a dashboard'),
              items: _dashboards.map<DropdownMenuItem<String>>((dashboard) {
                return DropdownMenuItem<String>(
                  value: dashboard['id'].toString(),
                  child: Text(dashboard['name'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDashboardId = value;
                });
                _loadDashboardData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final trendData = _stats?.trends[title.toLowerCase().replaceAll(' ', '_')];
    final trendValue = trendData?['value'] ?? 0;
    final trendDirection = trendData?['direction'] ?? 'up';
    final isTrendUp = trendDirection == 'up';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isTrendUp ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: isTrendUp ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  '$trendValue%',
                  style: TextStyle(
                    fontSize: 12,
                    color: isTrendUp ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataVisualization() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Data Visualization',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedVisualization ?? 'line',
                  items: const [
                    DropdownMenuItem(
                      value: 'line',
                      child: Text('Line Chart'),
                    ),
                    DropdownMenuItem(
                      value: 'bar',
                      child: Text('Bar Chart'),
                    ),
                    DropdownMenuItem(
                      value: 'pie',
                      child: Text('Pie Chart'),
                    ),
                    DropdownMenuItem(
                      value: 'scatter',
                      child: Text('Scatter Plot'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedVisualization = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: _buildSelectedVisualization(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedVisualization() {
    switch (_selectedVisualization) {
      case 'line':
        return LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(0, 3),
                  const FlSpot(2.6, 2),
                  const FlSpot(4.9, 5),
                  const FlSpot(6.8, 3.1),
                  const FlSpot(8, 4),
                  const FlSpot(9.5, 3),
                  const FlSpot(11, 4),
                ],
                isCurved: true,
                color: AppColors.primaryBlue,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primaryBlue.withOpacity(0.1),
                ),
              ),
            ],
          ),
        );
      case 'pie':
        return PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: (_stats?.formStats['completion_rate'] ?? 0).toDouble(),
                title: '${_stats?.formStats['completion_rate'] ?? 0}%',
                radius: 100,
                color: AppColors.success,
              ),
              PieChartSectionData(
                value: (100 - (_stats?.formStats['completion_rate'] ?? 0))
                    .toDouble(),
                title: '${100 - (_stats?.formStats['completion_rate'] ?? 0)}%',
                radius: 100,
                color: AppColors.warning,
              ),
            ],
          ),
        );
      case 'bar':
        return BarChart(
          BarChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: 8,
                    color: AppColors.primaryBlue,
                    width: 20,
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: 10,
                    color: AppColors.primaryBlue,
                    width: 20,
                  ),
                ],
              ),
              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(
                    toY: 14,
                    color: AppColors.primaryBlue,
                    width: 20,
                  ),
                ],
              ),
              BarChartGroupData(
                x: 3,
                barRods: [
                  BarChartRodData(
                    toY: 15,
                    color: AppColors.primaryBlue,
                    width: 20,
                  ),
                ],
              ),
              BarChartGroupData(
                x: 4,
                barRods: [
                  BarChartRodData(
                    toY: 13,
                    color: AppColors.primaryBlue,
                    width: 20,
                  ),
                ],
              ),
            ],
          ),
        );
      case 'scatter':
        return ScatterChart(
          ScatterChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            scatterSpots: [
              ScatterSpot(4, 4,
                  dotPainter: FlDotCirclePainter(
                    color: AppColors.primaryBlue,
                    strokeWidth: 1,
                    strokeColor: AppColors.primaryBlue,
                  )),
              ScatterSpot(2, 5,
                  dotPainter: FlDotCirclePainter(
                    color: AppColors.primaryBlue,
                    strokeWidth: 1,
                    strokeColor: AppColors.primaryBlue,
                  )),
              ScatterSpot(4, 5,
                  dotPainter: FlDotCirclePainter(
                    color: AppColors.primaryBlue,
                    strokeWidth: 1,
                    strokeColor: AppColors.primaryBlue,
                  )),
              ScatterSpot(8, 6,
                  dotPainter: FlDotCirclePainter(
                    color: AppColors.primaryBlue,
                    strokeWidth: 1,
                    strokeColor: AppColors.primaryBlue,
                  )),
              ScatterSpot(5, 7,
                  dotPainter: FlDotCirclePainter(
                    color: AppColors.primaryBlue,
                    strokeWidth: 1,
                    strokeColor: AppColors.primaryBlue,
                  )),
              ScatterSpot(7, 2,
                  dotPainter: FlDotCirclePainter(
                    color: AppColors.primaryBlue,
                    strokeWidth: 1,
                    strokeColor: AppColors.primaryBlue,
                  )),
              ScatterSpot(3, 2,
                  dotPainter: FlDotCirclePainter(
                    color: AppColors.primaryBlue,
                    strokeWidth: 1,
                    strokeColor: AppColors.primaryBlue,
                  )),
              ScatterSpot(2, 8,
                  dotPainter: FlDotCirclePainter(
                    color: AppColors.primaryBlue,
                    strokeWidth: 1,
                    strokeColor: AppColors.primaryBlue,
                  )),
            ],
          ),
        );
      default:
        return const Center(child: Text('Select a visualization type'));
    }
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stats?.recentActivity['submissions'].length ?? 0,
              itemBuilder: (context, index) {
                final activity = _stats?.recentActivity['submissions'][index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_document,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  title: Text(activity['title'] ?? ''),
                  subtitle: Text(activity['description'] ?? ''),
                  trailing: Text(activity['time'] ?? ''),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapContent() {
    return const Center(
      child: Text('Map View'),
    );
  }

  Widget _buildFormsContent() {
    return const Center(
      child: Text('Forms View'),
    );
  }

  Widget _buildIncidencesContent() {
    return const Center(
      child: Text('Incidences View'),
    );
  }

  Widget _buildAnalyticsContent() {
    return const Center(
      child: Text('Analytics View'),
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Text('Settings View'),
    );
  }

  Future<void> _showDashboardGenerationDialog(
      BuildContext context, Map<String, dynamic> formData) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/Cute Profit GEO Logo.png',
                    height: 40,
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Generate Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Generate a dashboard for "${formData['name']}"?',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'The dashboard will include:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildDashboardFeature(
                icon: Icons.analytics,
                text: 'Data visualization charts',
              ),
              _buildDashboardFeature(
                icon: Icons.map,
                text: 'Geographic data mapping',
              ),
              _buildDashboardFeature(
                icon: Icons.table_chart,
                text: 'Submission statistics',
              ),
              _buildDashboardFeature(
                icon: Icons.history,
                text: 'Recent submissions tracking',
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Skip'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await _generateDashboard(formData);
                      if (!mounted) return;
                      Navigator.pop(context);
                      _loadDashboards(); // Refresh the dashboards list
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Generate Dashboard'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardFeature({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _generateDashboard(Map<String, dynamic> formData) async {
    try {
      final dashboardConfig = {
        'name': '${formData['name']} Dashboard',
        'form_id': formData['id'],
        'visualizations': [
          {
            'type': 'line',
            'title': 'Submissions Over Time',
            'data_field': 'created_at',
          },
          {
            'type': 'map',
            'title': 'Geographic Distribution',
            'data_fields': ['latitude', 'longitude'],
          },
          {
            'type': 'pie',
            'title': 'Data Distribution',
            'data_fields':
                (formData['fields'] as List).map((f) => f['name']).toList(),
          },
          {
            'type': 'bar',
            'title': 'Field Completion Rate',
            'data_fields':
                (formData['fields'] as List).map((f) => f['name']).toList(),
          },
          {
            'type': 'scatter',
            'title': 'Data Correlation',
            'data_fields': (formData['fields'] as List)
                .where((f) => f['fieldType'] == 'number')
                .map((f) => f['name'])
                .toList(),
          },
        ],
        'filters': [
          {
            'field': 'created_at',
            'type': 'date_range',
          },
          {
            'field': 'status',
            'type': 'select',
            'options': ['Pending', 'Completed', 'Rejected'],
          },
        ],
        'layout': {
          'columns': 2,
          'rows': 3,
        },
      };

      // TODO: Save dashboard configuration to backend
      final dashboardService = DashboardService();
      await dashboardService.createDashboard(dashboardConfig);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dashboard generated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating dashboard: $e')),
      );
    }
  }
}
