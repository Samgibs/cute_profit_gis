import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/form_field.dart';
import '../../constants/colors.dart';

class FormSubmissionScreen extends StatefulWidget {
  final String formId;
  final String formName;
  final List<FormFieldModel> fields;

  const FormSubmissionScreen({
    Key? key,
    required this.formId,
    required this.formName,
    required this.fields,
  }) : super(key: key);

  @override
  _FormSubmissionScreenState createState() => _FormSubmissionScreenState();
}

class _FormSubmissionScreenState extends State<FormSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isLoading = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _formData['latitude'] = position.latitude;
        _formData['longitude'] = position.longitude;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.formName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            if (_currentPosition != null) ...[
                              Text(
                                'Latitude: ${_currentPosition!.latitude}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                'Longitude: ${_currentPosition!.longitude}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ] else
                              const Text('Getting location...'),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _getCurrentLocation,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh Location'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Form Fields
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Form Data',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            ...widget.fields
                                .where((field) =>
                                    field.name != 'latitude' &&
                                    field.name != 'longitude')
                                .map(_buildField)
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField(FormFieldModel field) {
    switch (field.fieldType) {
      case 'text':
        return _buildTextField(field);
      case 'number':
        return _buildNumberField(field);
      case 'date':
        return _buildDateField(field);
      case 'select':
        return _buildSelectField(field);
      case 'multiselect':
        return _buildMultiSelectField(field);
      case 'checkbox':
        return _buildCheckboxField(field);
      case 'radio':
        return _buildRadioField(field);
      case 'file':
        return _buildFileField(field);
      case 'image':
        return _buildImageField(field);
      case 'geometry':
        return _buildGeometryField(field);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(FormFieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
        ),
        validator: field.required
            ? (value) {
                if (value?.isEmpty ?? true) {
                  return '${field.label} is required';
                }
                return null;
              }
            : null,
        onSaved: (value) {
          _formData[field.name] = value;
        },
      ),
    );
  }

  Widget _buildNumberField(FormFieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (field.required && (value?.isEmpty ?? true)) {
            return '${field.label} is required';
          }
          if (value != null && value.isNotEmpty) {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
          }
          return null;
        },
        onSaved: (value) {
          _formData[field.name] =
              value != null && value.isNotEmpty ? double.parse(value) : null;
        },
      ),
    );
  }

  Widget _buildDateField(FormFieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            _formData[field.name] = date.toIso8601String();
            setState(() {});
          }
        },
        validator: field.required
            ? (value) {
                if (value?.isEmpty ?? true) {
                  return '${field.label} is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildSelectField(FormFieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: field.label,
          border: const OutlineInputBorder(),
        ),
        items: field.options?.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          _formData[field.name] = value;
        },
        validator: field.required
            ? (value) {
                if (value == null) {
                  return '${field.label} is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildMultiSelectField(FormFieldModel field) {
    final selectedValues = _formData[field.name] as List<String>? ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<List<String>>(
        initialValue: selectedValues,
        validator: field.required
            ? (value) {
                if (value?.isEmpty ?? true) {
                  return '${field.label} is required';
                }
                return null;
              }
            : null,
        builder: (FormFieldState<List<String>> state) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
              errorText: state.errorText,
            ),
            child: Column(
              children: field.options?.map((option) {
                    return CheckboxListTile(
                      title: Text(option),
                      value: selectedValues.contains(option),
                      onChanged: (checked) {
                        if (checked ?? false) {
                          selectedValues.add(option);
                        } else {
                          selectedValues.remove(option);
                        }
                        state.didChange(selectedValues);
                        _formData[field.name] = selectedValues;
                      },
                    );
                  }).toList() ??
                  [],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckboxField(FormFieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<bool>(
        initialValue: _formData[field.name] ?? false,
        validator: field.required
            ? (value) {
                if (value != true) {
                  return '${field.label} is required';
                }
                return null;
              }
            : null,
        builder: (FormFieldState<bool> state) {
          return CheckboxListTile(
            title: Text(field.label),
            value: state.value ?? false,
            onChanged: (value) {
              state.didChange(value);
              _formData[field.name] = value;
            },
            subtitle: state.errorText != null
                ? Text(
                    state.errorText!,
                    style: const TextStyle(color: Colors.red),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildRadioField(FormFieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FormField<String>(
        initialValue: _formData[field.name],
        validator: field.required
            ? (value) {
                if (value == null) {
                  return '${field.label} is required';
                }
                return null;
              }
            : null,
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
              errorText: state.errorText,
            ),
            child: Column(
              children: field.options?.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: state.value,
                      onChanged: (value) {
                        state.didChange(value);
                        _formData[field.name] = value;
                      },
                    );
                  }).toList() ??
                  [],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileField(FormFieldModel field) {
    // TODO: Implement file upload
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(field.label),
        subtitle: const Text('File upload not implemented yet'),
        trailing: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildImageField(FormFieldModel field) {
    // TODO: Implement image upload
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(field.label),
        subtitle: const Text('Image upload not implemented yet'),
        trailing: const Icon(Icons.image),
      ),
    );
  }

  Widget _buildGeometryField(FormFieldModel field) {
    // TODO: Implement geometry drawing
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(field.label),
        subtitle: const Text('Geometry drawing not implemented yet'),
        trailing: const Icon(Icons.edit),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for location data')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _formKey.currentState!.save();

      // TODO: Submit form data to backend
      // final response = await submitFormData({
      //   'form_id': widget.formId,
      //   'data': _formData,
      // });

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting form: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
