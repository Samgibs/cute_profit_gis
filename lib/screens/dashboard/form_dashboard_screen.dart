import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/colors.dart';

class FormDashboardScreen extends StatefulWidget {
  final String formId;
  final String formName;

  const FormDashboardScreen({
    Key? key,
    required this.formId,
    required this.formName,
  }) : super(key: key);

  @override
  _FormDashboardScreenState createState() => _FormDashboardScreenState();
}

class _FormDashboardScreenState extends State<FormDashboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _submissions = [];
  String _selectedVisualization = 'map';
  String? _selectedField;
  final List<Marker> _markers = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Load form submissions from backend
      // final response = await getFormSubmissions(widget.formId);
      // _submissions = response.data;

      // Temporary mock data
      _submissions = [
        {
          'id': '1',
          'data': {
            'name': 'Test Point 1',
            'type': 'Water Meter',
            'reading': 123.45,
            'status': 'Active',
            'latitude': -1.2921,
            'longitude': 36.8219,
          },
          'created_at': '2024-03-15T10:00:00Z',
        },
        {
          'id': '2',
          'data': {
            'name': 'Test Point 2',
            'type': 'Water Meter',
            'reading': 234.56,
            'status': 'Inactive',
            'latitude': -1.2911,
            'longitude': 36.8229,
          },
          'created_at': '2024-03-15T11:00:00Z',
        },
      ];

      _updateMarkers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    _markers.clear();
    for (final submission in _submissions) {
      final data = submission['data'] as Map<String, dynamic>;
      if (data['latitude'] != null && data['longitude'] != null) {
        _markers.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(
              data['latitude'] as double,
              data['longitude'] as double,
            ),
            child: IconButton(
              icon: const Icon(Icons.location_on),
              color: AppColors.primaryBlue,
              onPressed: () => _showSubmissionDetails(submission),
            ),
          ),
        );
      }
    }
  }

  void _showSubmissionDetails(Map<String, dynamic> submission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submission ${submission['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Created: ${submission['created_at']}'),
              const Divider(),
              ...(submission['data'] as Map<String, dynamic>)
                  .entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key}: ',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: Text(entry.value.toString()),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.formName} Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Visualization Controls
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visualization',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(
                                    value: 'map',
                                    icon: Icon(Icons.map),
                                    label: Text('Map'),
                                  ),
                                  ButtonSegment(
                                    value: 'chart',
                                    icon: Icon(Icons.bar_chart),
                                    label: Text('Chart'),
                                  ),
                                  ButtonSegment(
                                    value: 'table',
                                    icon: Icon(Icons.table_chart),
                                    label: Text('Table'),
                                  ),
                                ],
                                selected: {_selectedVisualization},
                                onSelectionChanged: (selection) {
                                  setState(() {
                                    _selectedVisualization = selection.first;
                                  });
                                },
                              ),
                            ),
                            if (_selectedVisualization == 'chart') ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Field',
                                    border: OutlineInputBorder(),
                                  ),
                                  value: _selectedField,
                                  items: _getNumericFields()
                                      .map((field) => DropdownMenuItem(
                                            value: field,
                                            child: Text(field),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedField = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Visualization Content
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _buildVisualization(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildVisualization() {
    switch (_selectedVisualization) {
      case 'map':
        return _buildMap();
      case 'chart':
        return _buildChart();
      case 'table':
        return _buildTable();
      default:
        return const Center(child: Text('Select a visualization'));
    }
  }

  Widget _buildMap() {
    if (_markers.isEmpty) {
      return const Center(
        child: Text('No location data available'),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _markers.first.point,
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(markers: _markers),
      ],
    );
  }

  Widget _buildChart() {
    if (_selectedField == null) {
      return const Center(
        child: Text('Select a field to visualize'),
      );
    }

    final data = _submissions
        .map((s) => (s['data'] as Map<String, dynamic>)[_selectedField])
        .whereType<num>()
        .toList();

    if (data.isEmpty) {
      return const Center(
        child: Text('No numeric data available for the selected field'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          maxY: data.reduce((a, b) => a > b ? a : b) * 1.2,
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
              ),
            ),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true),
          barGroups: data
              .asMap()
              .entries
              .map(
                (entry) => BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.toDouble(),
                      color: AppColors.primaryBlue,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTable(
        columns: [
          const DataColumn(label: Text('ID')),
          const DataColumn(label: Text('Date')),
          ...(_submissions.isNotEmpty
              ? (_submissions.first['data'] as Map<String, dynamic>)
                  .keys
                  .map((key) => DataColumn(label: Text(key)))
              : []),
        ],
        rows: _submissions.map((submission) {
          final data = submission['data'] as Map<String, dynamic>;
          return DataRow(
            cells: [
              DataCell(Text(submission['id'].toString())),
              DataCell(Text(submission['created_at'].toString())),
              ...data.values.map((value) => DataCell(Text(value.toString()))),
            ],
          );
        }).toList(),
      ),
    );
  }

  List<String> _getNumericFields() {
    if (_submissions.isEmpty) return [];

    final firstSubmission = _submissions.first['data'] as Map<String, dynamic>;
    return firstSubmission.entries
        .where((entry) => entry.value is num)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
