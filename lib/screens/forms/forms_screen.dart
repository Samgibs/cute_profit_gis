import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/form.dart';
import '../../models/form_field.dart';

class FormsScreen extends StatefulWidget {
  const FormsScreen({Key? key}) : super(key: key);

  @override
  _FormsScreenState createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  List<DynamicForm> _forms = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    // TODO: Load forms from API
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _forms = [
        DynamicForm(
          id: '1',
          name: 'Water Meter Reading',
          description: 'Form for collecting water meter readings',
          category: 'Utilities',
          fields: [
            FormFieldModel(
              id: '1',
              name: 'meter_number',
              label: 'Meter Number',
              fieldType: 'text',
              required: true,
              order: 0,
            ),
            FormFieldModel(
              id: '2',
              name: 'reading_value',
              label: 'Reading Value',
              fieldType: 'number',
              required: true,
              order: 1,
            ),
            FormFieldModel(
              id: '3',
              name: 'location',
              label: 'Location',
              fieldType: 'geometry',
              required: true,
              order: 2,
            ),
          ],
        ),
        DynamicForm(
          id: '2',
          name: 'Pipe Inspection',
          description: 'Form for pipe maintenance inspections',
          category: 'Maintenance',
          fields: [
            FormFieldModel(
              id: '4',
              name: 'pipe_id',
              label: 'Pipe ID',
              fieldType: 'text',
              required: true,
              order: 0,
            ),
            FormFieldModel(
              id: '5',
              name: 'condition',
              label: 'Condition',
              fieldType: 'select',
              required: true,
              order: 1,
              options: ['Good', 'Fair', 'Poor', 'Critical'],
            ),
            FormFieldModel(
              id: '6',
              name: 'photos',
              label: 'Photos',
              fieldType: 'image',
              required: false,
              order: 2,
            ),
          ],
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
                : _buildFormList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create form
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
            'Forms',
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
                    hintText: 'Search forms...',
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
                    child: Text('All Forms'),
                  ),
                  const PopupMenuItem(
                    value: 'utilities',
                    child: Text('Utilities'),
                  ),
                  const PopupMenuItem(
                    value: 'maintenance',
                    child: Text('Maintenance'),
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

  Widget _buildFormList() {
    final filteredForms = _forms.where((form) {
      return form.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          form.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          form.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredForms.length,
      itemBuilder: (context, index) {
        final form = filteredForms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              // TODO: Navigate to form details
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
                              form.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              form.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          form.category,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Fields',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: form.fields.map((field) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getFieldIcon(field.fieldType),
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              field.label,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement view submissions
                        },
                        icon: const Icon(Icons.list),
                        label: const Text('View Submissions'),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement edit form
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement delete form
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

  IconData _getFieldIcon(String fieldType) {
    switch (fieldType) {
      case 'text':
        return Icons.text_fields;
      case 'number':
        return Icons.numbers;
      case 'select':
        return Icons.list;
      case 'multiselect':
        return Icons.checklist;
      case 'checkbox':
        return Icons.check_box;
      case 'radio':
        return Icons.radio_button_checked;
      case 'file':
        return Icons.attach_file;
      case 'image':
        return Icons.image;
      case 'geometry':
        return Icons.location_on;
      default:
        return Icons.input;
    }
  }
}
