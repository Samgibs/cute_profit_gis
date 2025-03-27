import 'package:flutter/material.dart';
import '../constants/colors.dart';

class LayerControl extends StatefulWidget {
  final Function(String, bool) onLayerToggle;
  final Function(String, Map<String, dynamic>) onLayerStyleChange;
  final Function() onAddLayer;

  const LayerControl({
    Key? key,
    required this.onLayerToggle,
    required this.onLayerStyleChange,
    required this.onAddLayer,
  }) : super(key: key);

  @override
  _LayerControlState createState() => _LayerControlState();
}

class _LayerControlState extends State<LayerControl> {
  List<MapLayerItem> _layers = [];

  @override
  void initState() {
    super.initState();
    // TODO: Load layers from API
    _layers = [
      MapLayerItem(
        id: '1',
        name: 'Water Lines',
        type: 'line',
        isVisible: true,
        color: Colors.blue,
      ),
      MapLayerItem(
        id: '2',
        name: 'Meters',
        type: 'point',
        isVisible: true,
        color: Colors.red,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Layers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: widget.onAddLayer,
                icon: const Icon(Icons.add),
                tooltip: 'Add Layer',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _layers.length,
            itemBuilder: (context, index) {
              final layer = _layers[index];
              return _buildLayerItem(layer);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLayerItem(MapLayerItem layer) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(
            layer.type == 'point' ? Icons.location_on : Icons.timeline,
            color: layer.color,
          ),
          const SizedBox(width: 8),
          Text(layer.name),
        ],
      ),
      trailing: Switch(
        value: layer.isVisible,
        onChanged: (value) {
          setState(() {
            layer.isVisible = value;
          });
          widget.onLayerToggle(layer.id, value);
        },
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Style',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Color:'),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      // TODO: Show color picker
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: layer.color,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              if (layer.type == 'line') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Width:'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Slider(
                        value: layer.width,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: layer.width.toString(),
                        onChanged: (value) {
                          setState(() {
                            layer.width = value;
                          });
                          widget.onLayerStyleChange(layer.id, {
                            'width': value,
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class MapLayerItem {
  final String id;
  final String name;
  final String type;
  bool isVisible;
  Color color;
  double width;

  MapLayerItem({
    required this.id,
    required this.name,
    required this.type,
    required this.isVisible,
    required this.color,
    this.width = 2,
  });
}
