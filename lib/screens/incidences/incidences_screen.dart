import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../models/incidence.dart';

class IncidencesScreen extends StatefulWidget {
  const IncidencesScreen({super.key});

  @override
  State<IncidencesScreen> createState() => _IncidencesScreenState();
}

class _IncidencesScreenState extends State<IncidencesScreen> {
  List<Incidence> _incidences = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadIncidences();
  }

  Future<void> _loadIncidences() async {
    // Simulating API call delay
    await Future.delayed(const Duration(seconds: 1));

    final sampleIncidences = [
      Incidence(
        id: '1',
        title: 'Broken Pipe',
        description: 'Water leakage from main pipeline',
        severity: 'high',
        status: 'open',
        itemId: 'PIPE_001',
        itemName: 'Main Water Pipeline',
        reportedBy: 'John Doe',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        location: const LatLng(-1.292066, 36.821945),
      ),
      Incidence(
        id: '2',
        title: 'Faulty Meter',
        description: 'Electric meter showing incorrect readings',
        severity: 'medium',
        status: 'in_progress',
        itemId: 'METER_001',
        itemName: 'Electric Meter',
        reportedBy: 'Jane Smith',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        location: const LatLng(-1.292066, 36.821945),
      ),
    ];

    setState(() {
      _incidences = sampleIncidences;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilters(),
                Expanded(
                  child: ListView.builder(
                    itemCount: _incidences.length,
                    itemBuilder: (context, index) {
                      final incidence = _incidences[index];
                      return _buildIncidenceCard(incidence);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new incidence reporting
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('Open', 'open'),
          const SizedBox(width: 8),
          _buildFilterChip('In Progress', 'in_progress'),
          const SizedBox(width: 8),
          _buildFilterChip('Resolved', 'resolved'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  Widget _buildIncidenceCard(Incidence incidence) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    incidence.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSeverityChip(incidence.severity),
              ],
            ),
            const SizedBox(height: 8),
            Text(incidence.description),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Status', incidence.status),
                _buildInfoItem('Item', incidence.itemName),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Reported by', incidence.reportedBy),
                _buildInfoItem(
                  'Created',
                  _formatDate(incidence.createdAt),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityChip(String severity) {
    final color = severity == 'high'
        ? Colors.red
        : severity == 'medium'
            ? Colors.orange
            : Colors.green;

    return Chip(
      label: Text(
        severity.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
