import 'package:flutter/material.dart';
import '../constants/colors.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback? onLogout;

  const SideMenu({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  index: 0,
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  badge: 'Overview',
                ),
                _buildMenuItem(
                  index: 1,
                  icon: Icons.map,
                  label: 'Map View',
                  badge: 'GIS',
                ),
                _buildMenuItem(
                  index: 2,
                  icon: Icons.list_alt,
                  label: 'Forms',
                  badge: 'Data Collection',
                ),
                _buildMenuItem(
                  index: 3,
                  icon: Icons.warning,
                  label: 'Incidences',
                  badge: 'Issues',
                ),
                _buildMenuItem(
                  index: 4,
                  icon: Icons.analytics,
                  label: 'Analytics',
                  badge: 'Reports',
                ),
                _buildMenuItem(
                  index: 5,
                  icon: Icons.settings,
                  label: 'Settings',
                  badge: 'Configuration',
                ),
              ],
            ),
          ),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            'assets/icons/Cute Profit GEO Logo.png',
            height: 40,
          ),
          const SizedBox(height: 8),
          const Text(
            'GIS Application',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
    required String badge,
  }) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : AppColors.primaryBlue,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryBlue : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          badge,
          style: TextStyle(
            color: isSelected
                ? AppColors.primaryBlue.withOpacity(0.7)
                : Colors.grey[400],
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onTap: () => onItemSelected(index),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.logout,
            color: AppColors.error,
            size: 20,
          ),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          'Sign out of the application',
          style: TextStyle(
            color: AppColors.error,
            fontSize: 12,
          ),
        ),
        onTap: onLogout,
      ),
    );
  }
}
