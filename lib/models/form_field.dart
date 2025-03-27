class FormFieldModel {
  final String id;
  final String name;
  final String label;
  final String fieldType;
  final bool required;
  final List<String>? options;
  final int order;

  FormFieldModel({
    required this.id,
    required this.name,
    required this.label,
    required this.fieldType,
    this.required = false,
    this.options,
    this.order = 0,
  });

  factory FormFieldModel.fromJson(Map<String, dynamic> json) {
    return FormFieldModel(
      id: json['id'],
      name: json['name'],
      label: json['label'],
      fieldType: json['field_type'],
      required: json['required'] ?? false,
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
      'field_type': fieldType,
      'required': required,
      'options': options,
      'order': order,
    };
  }

  FormFieldModel copyWith({
    String? id,
    String? name,
    String? label,
    String? fieldType,
    bool? required,
    List<String>? options,
    int? order,
  }) {
    return FormFieldModel(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      fieldType: fieldType ?? this.fieldType,
      required: required ?? this.required,
      options: options ?? this.options,
      order: order ?? this.order,
    );
  }
}
