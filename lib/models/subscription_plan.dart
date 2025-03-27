class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final List<String> features;
  final int maxUsers;
  final int maxStorage;
  final int maxForms;
  final int maxItems;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    required this.maxUsers,
    required this.maxStorage,
    required this.maxForms,
    required this.maxItems,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      features: List<String>.from(json['features']),
      maxUsers: json['max_users'],
      maxStorage: json['max_storage'],
      maxForms: json['max_forms'],
      maxItems: json['max_items'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'features': features,
      'max_users': maxUsers,
      'max_storage': maxStorage,
      'max_forms': maxForms,
      'max_items': maxItems,
    };
  }
}
