class DashboardStats {
  final int totalForms;
  final int totalSubmissions;
  final int openIncidences;
  final int activeUsers;
  final Map<String, dynamic> trends;
  final Map<String, dynamic> recentActivity;
  final Map<String, dynamic> formStats;
  final Map<String, dynamic> incidenceStats;

  DashboardStats({
    required this.totalForms,
    required this.totalSubmissions,
    required this.openIncidences,
    required this.activeUsers,
    required this.trends,
    required this.recentActivity,
    required this.formStats,
    required this.incidenceStats,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalForms: json['total_forms'] ?? 0,
      totalSubmissions: json['total_submissions'] ?? 0,
      openIncidences: json['open_incidences'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      trends: json['trends'] ??
          {
            'forms': {'value': 0, 'direction': 'up'},
            'submissions': {'value': 0, 'direction': 'up'},
            'incidences': {'value': 0, 'direction': 'down'},
            'users': {'value': 0, 'direction': 'up'},
          },
      recentActivity: json['recent_activity'] ??
          {
            'submissions': [],
            'incidences': [],
            'users': [],
          },
      formStats: json['form_stats'] ??
          {
            'by_category': {},
            'by_department': {},
            'completion_rate': 0,
          },
      incidenceStats: json['incidence_stats'] ??
          {
            'by_severity': {},
            'by_status': {},
            'resolution_rate': 0,
          },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_forms': totalForms,
      'total_submissions': totalSubmissions,
      'open_incidences': openIncidences,
      'active_users': activeUsers,
      'trends': trends,
      'recent_activity': recentActivity,
      'form_stats': formStats,
      'incidence_stats': incidenceStats,
    };
  }
}
