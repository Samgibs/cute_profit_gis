class Client {
  final String id;
  final String name;
  final String industry;
  final String status;
  final String subscriptionPlan;
  final int usersCount;
  final String storageUsed;

  Client({
    required this.id,
    required this.name,
    required this.industry,
    required this.status,
    required this.subscriptionPlan,
    required this.usersCount,
    required this.storageUsed,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      industry: json['industry'],
      status: json['status'],
      subscriptionPlan: json['subscription_plan'],
      usersCount: json['users_count'],
      storageUsed: json['storage_used'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'industry': industry,
      'status': status,
      'subscription_plan': subscriptionPlan,
      'users_count': usersCount,
      'storage_used': storageUsed,
    };
  }
}
