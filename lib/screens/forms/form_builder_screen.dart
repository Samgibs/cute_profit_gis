import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/form_field.dart';

class FormBuilderScreen extends StatefulWidget {
  const FormBuilderScreen({Key? key}) : super(key: key);

  @override
  _FormBuilderScreenState createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<FormFieldModel> _fields = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Form'),
        actions: [
          TextButton.icon(
            onPressed: _saveForm,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Details Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Form Details',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Form Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter a form name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fields Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Form Fields',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              ElevatedButton.icon(
                                onPressed: _addField,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Field'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._buildFieldsList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildFieldsList() {
    return _fields.asMap().entries.map((entry) {
      final index = entry.key;
      final field = entry.value;
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(field.label),
          subtitle: Text(field.fieldType),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editField(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _removeField(index),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _addField() {
    showDialog(
      context: context,
      builder: (context) => FieldEditorDialog(
        onSave: (field) {
          setState(() {
            _fields.add(field);
          });
        },
        fieldsCount: _fields.length,
      ),
    );
  }

  void _editField(int index) {
    showDialog(
      context: context,
      builder: (context) => FieldEditorDialog(
        initialField: _fields[index],
        onSave: (field) {
          setState(() {
            _fields[index] = field;
          });
        },
        fieldsCount: _fields.length,
      ),
    );
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save form to backend
      final form = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'fields': _fields.map((f) => f.toJson()).toList(),
      };

      // TODO: Make API call to save form and get response with ID
      // For now, simulate an API response
      final formResponse = {
        ...form,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      // Show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form saved successfully')),
      );

      // Return form data to previous screen
      Navigator.pop(context, formResponse);
    } catch (e) {
      // Show error message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving form: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDashboardGenerationDialog(BuildContext context) {
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
              const Text(
                'Would you like to create a dashboard for this form?',
                style: TextStyle(
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
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Skip'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _generateDashboard();
                      Navigator.pop(context);
                      Navigator.pop(context);
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

  Future<void> _generateDashboard() async {
    try {
      // TODO: Call backend to generate dashboard
      final dashboardConfig = {
        'name': '${_nameController.text} Dashboard',
        'form_id': 'FORM_ID', // Replace with actual form ID
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
            'data_fields': _fields.map((f) => f.name).toList(),
          },
          {
            'type': 'bar',
            'title': 'Field Completion Rate',
            'data_fields': _fields.map((f) => f.name).toList(),
          },
          {
            'type': 'scatter',
            'title': 'Data Correlation',
            'data_fields': _fields
                .where((f) => f.fieldType == 'number')
                .map((f) => f.name)
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
      // After saving, show success message
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class FieldEditorDialog extends StatefulWidget {
  final FormFieldModel? initialField;
  final Function(FormFieldModel) onSave;
  final int fieldsCount;

  const FieldEditorDialog({
    Key? key,
    this.initialField,
    required this.onSave,
    required this.fieldsCount,
  }) : super(key: key);

  @override
  _FieldEditorDialogState createState() => _FieldEditorDialogState();
}

class _FieldEditorDialogState extends State<FieldEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _labelController = TextEditingController();
  String _selectedType = 'text';
  bool _isRequired = false;
  final _optionsController = TextEditingController();

  final _fieldTypes = [
    'text',
    'number',
    'date',
    'select',
    'multiselect',
    'checkbox',
    'radio',
    'file',
    'image',
    'geometry',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialField != null) {
      _nameController.text = widget.initialField!.name;
      _labelController.text = widget.initialField!.label;
      _selectedType = widget.initialField!.fieldType;
      _isRequired = widget.initialField!.required;
      if (widget.initialField!.options != null) {
        _optionsController.text = widget.initialField!.options!.join('\n');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialField == null ? 'Add Field' : 'Edit Field'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Field Name',
                  helperText: 'Used as the field identifier',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a field name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Field Label',
                  helperText: 'Displayed to users',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a field label';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Field Type',
                ),
                items: _fieldTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Required'),
                value: _isRequired,
                onChanged: (value) {
                  setState(() {
                    _isRequired = value!;
                  });
                },
              ),
              if (_selectedType == 'select' ||
                  _selectedType == 'multiselect' ||
                  _selectedType == 'radio') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _optionsController,
                  decoration: const InputDecoration(
                    labelText: 'Options',
                    helperText: 'Enter options, one per line',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_selectedType == 'select' ||
                        _selectedType == 'multiselect' ||
                        _selectedType == 'radio') {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter at least one option';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveField,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveField() {
    if (!_formKey.currentState!.validate()) return;

    final field = FormFieldModel(
      id: widget.initialField?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      label: _labelController.text,
      fieldType: _selectedType,
      required: _isRequired,
      options: (_selectedType == 'select' ||
              _selectedType == 'multiselect' ||
              _selectedType == 'radio')
          ? _optionsController.text
              .split('\n')
              .where((s) => s.isNotEmpty)
              .toList()
          : null,
      order: widget.initialField?.order ?? widget.fieldsCount,
    );

    widget.onSave(field);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _labelController.dispose();
    _optionsController.dispose();
    super.dispose();
  }
}
