import 'form_field.dart';

class DynamicForm {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<FormFieldModel> fields;

  DynamicForm({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.fields,
  });

  factory DynamicForm.fromJson(Map<String, dynamic> json) {
    return DynamicForm(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      fields: (json['fields'] as List)
          .map((field) => FormFieldModel.fromJson(field))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'fields': fields.map((field) => field.toJson()).toList(),
    };
  }
}
