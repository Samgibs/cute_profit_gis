import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/colors.dart';
import '../../widgets/layer_control.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  List<Polygon> _polygons = [];
  bool _isDrawingMode = false;
  List<LatLng> _currentDrawing = [];
  String _currentDrawingType = 'point'; // point, line, polygon

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Layer Control Panel
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: LayerControl(
              onLayerToggle: _handleLayerToggle,
              onLayerStyleChange: _handleLayerStyleChange,
              onAddLayer: _handleAddLayer,
            ),
          ),
          // Map View
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(0, 0),
                    zoom: 13.0,
                    onTap: _handleMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: _markers),
                    PolylineLayer(polylines: _polylines),
                    PolygonLayer(polygons: _polygons),
                    // Current Drawing Layer
                    if (_currentDrawing.isNotEmpty) ...[
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _currentDrawing,
                            color: AppColors.primaryBlue.withOpacity(0.7),
                            strokeWidth: 2.0,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                // Drawing Controls
                Positioned(
                  top: 16,
                  right: 16,
                  child: Column(
                    children: [
                      _buildDrawingControl('Point', Icons.location_on),
                      const SizedBox(height: 8),
                      _buildDrawingControl('Line', Icons.timeline),
                      const SizedBox(height: 8),
                      _buildDrawingControl('Polygon', Icons.category),
                    ],
                  ),
                ),
                // Zoom Controls
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        mini: true,
                        onPressed: () => _mapController.move(
                          _mapController.center,
                          _mapController.zoom + 1,
                        ),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () => _mapController.move(
                          _mapController.center,
                          _mapController.zoom - 1,
                        ),
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isDrawingMode
          ? FloatingActionButton(
              onPressed: _finishDrawing,
              backgroundColor: AppColors.success,
              child: const Icon(Icons.check),
            )
          : null,
    );
  }

  Widget _buildDrawingControl(String type, IconData icon) {
    final isSelected =
        _currentDrawingType.toLowerCase() == type.toLowerCase() &&
            _isDrawingMode;
    return FloatingActionButton(
      mini: true,
      backgroundColor: isSelected ? AppColors.primaryBlue : Colors.white,
      onPressed: () => _startDrawing(type.toLowerCase()),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
    );
  }

  void _startDrawing(String type) {
    setState(() {
      _isDrawingMode = true;
      _currentDrawingType = type;
      _currentDrawing = [];
    });
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    if (!_isDrawingMode) return;

    setState(() {
      _currentDrawing.add(point);

      if (_currentDrawingType == 'point') {
        _finishDrawing();
      }
    });
  }

  void _finishDrawing() {
    if (_currentDrawing.isEmpty) return;

    switch (_currentDrawingType) {
      case 'point':
        setState(() {
          _markers.add(
            Marker(
              point: _currentDrawing.first,
              builder: (ctx) => const Icon(
                Icons.location_on,
                color: AppColors.primaryBlue,
                size: 30,
              ),
            ),
          );
        });
        break;
      case 'line':
        if (_currentDrawing.length < 2) return;
        setState(() {
          _polylines.add(
            Polyline(
              points: List.from(_currentDrawing),
              color: AppColors.primaryBlue,
              strokeWidth: 2.0,
            ),
          );
        });
        break;
      case 'polygon':
        if (_currentDrawing.length < 3) return;
        setState(() {
          _polygons.add(
            Polygon(
              points: List.from(_currentDrawing),
              color: AppColors.primaryBlue.withOpacity(0.2),
              borderColor: AppColors.primaryBlue,
              borderStrokeWidth: 2.0,
            ),
          );
        });
        break;
    }

    setState(() {
      _isDrawingMode = false;
      _currentDrawing = [];
    });
  }

  void _handleLayerToggle(String layerId, bool isVisible) {
    // TODO: Implement layer visibility toggle
  }

  void _handleLayerStyleChange(String layerId, Map<String, dynamic> style) {
    // TODO: Implement layer style changes
  }

  void _handleAddLayer() {
    // TODO: Implement add new layer
  }
}
