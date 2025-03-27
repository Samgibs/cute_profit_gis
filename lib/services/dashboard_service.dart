import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_stats.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';

class DashboardService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboards/stats/'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DashboardStats.fromJson(data);
      } else {
        throw Exception('Failed to load dashboard stats');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<List<Map<String, dynamic>>> getRecentSubmissions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/submissions/recent/'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load recent submissions');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<Map<String, dynamic>> getFormAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forms/analytics/'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load form analytics');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<Map<String, dynamic>> getIncidenceAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/incidences/analytics/'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load incidence analytics');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<Map<String, dynamic>> getMapLayerStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/map-layers/stats/'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load map layer stats');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<Map<String, dynamic>> getUserActivity() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/activity/'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user activity');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<Map<String, dynamic>> getDataCollectionStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/collection-sessions/stats/'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data collection stats');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<Map<String, dynamic>> getSubscriptionStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription-plans/stats/'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load subscription stats');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<Map<String, dynamic>> createDashboard(
      Map<String, dynamic> dashboardConfig) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dashboards/'),
        headers: {
          ...await AuthService.getAuthHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode(dashboardConfig),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create dashboard');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<List<Map<String, dynamic>>> getDashboards() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboards/'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load dashboards');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }
}
