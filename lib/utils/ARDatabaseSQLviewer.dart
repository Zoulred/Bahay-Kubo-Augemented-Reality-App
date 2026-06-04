import 'package:flutter/material.dart';
import 'package:ar_capstone2/utils/ARDatabaseSQL.dart';
import 'package:ar_capstone2/services/ARApiegetablescannerapi.dart';

class DatabaseViewer extends StatefulWidget {
  final String currentUserEmail;

  const DatabaseViewer({super.key, required this.currentUserEmail});

  @override
  State<DatabaseViewer> createState() => _DatabaseViewerState();
}

class _DatabaseViewerState extends State<DatabaseViewer> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final VegetableScannerAPI _scannerAPI = VegetableScannerAPI();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _vegetableScans = [];
  List<Map<String, dynamic>> _vegetablesWithCounts = [];
  List<Map<String, dynamic>> _userVegetableScans = [];
  bool _isLoading = true;
  int _totalScans = 0;
  bool _isSuperAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _loadData();
  }

  void _checkAdminStatus() {
    setState(() {
      _isSuperAdmin = widget.currentUserEmail == 'admin@gmail.com';
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _databaseHelper.getAllUsers();
      final vegetableScans = await _databaseHelper.getAllVegetableScans();
      final vegetablesWithCounts =
          await _scannerAPI.getAllVegetablesWithScanCounts();
      final totalScans = await _scannerAPI.getTotalScanCount();
      final userVegetableScans =
          await _databaseHelper.getAllUserVegetableScans();

      setState(() {
        _users = users;
        _vegetableScans = vegetableScans;
        _vegetablesWithCounts = vegetablesWithCounts;
        _totalScans = totalScans;
        _userVegetableScans = userVegetableScans;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }
// ==================== USER DELETION METHODS ====================

Future<void> _deleteUser(int userId, String username) async {
  try {
    final userToDelete = _findUserById(userId);
    
    if (_isSuperAdmin(userToDelete)) {
      _showSuperAdminError();
      return;
    }

    final bool? shouldDelete = await _showDeleteConfirmationDialog(username);
    
    if (shouldDelete == true) {
      await _performUserDeletion(userId, username);
    }
  } catch (e) {
    _showDeletionError(e);
  }
}

// Helper method to find user by ID
Map<String, dynamic> _findUserById(int userId) {
  return _users.firstWhere((user) => user['id'] == userId);
}

// Helper method to check if user is super admin
bool _isSuperAdmin(Map<String, dynamic> user) {
  return user['email'] == 'admin@gmail.com';
}

// Helper method to show super admin error
void _showSuperAdminError() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Cannot delete the super admin account.'),
      backgroundColor: Colors.red,
    ),
  );
}

// Helper method to show delete confirmation dialog
Future<bool?> _showDeleteConfirmationDialog(String username) async {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user "$username"?'),
        actions: _buildDialogActions(),
      );
    },
  );
}

// Helper method to build dialog actions
List<Widget> _buildDialogActions() {
  return [
    _buildCancelButton(),
    _buildDeleteButton(),
  ];
}

// Helper method to build cancel button
TextButton _buildCancelButton() {
  return TextButton(
    onPressed: () => Navigator.of(context).pop(false),
    child: const Text('Cancel'),
  );
}

// Helper method to build delete button
TextButton _buildDeleteButton() {
  return TextButton(
    onPressed: () => Navigator.of(context).pop(true),
    style: TextButton.styleFrom(
      foregroundColor: Colors.red,
    ),
    child: const Text('Delete'),
  );
}

// Helper method to perform user deletion
Future<void> _performUserDeletion(int userId, String username) async {
  await _databaseHelper.deleteUser(userId);
  await _loadData();
  _showDeletionSuccess(username);
}

// Helper method to show deletion success message
void _showDeletionSuccess(String username) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('User "$username" deleted successfully.'),
      backgroundColor: Colors.green,
    ),
  );
}

// Helper method to show deletion error
void _showDeletionError(dynamic error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error deleting user: $error'),
      backgroundColor: Colors.red,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Monitoring Panel',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green[700],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                child: Text(
                  'Users',
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tab(
                child: Text(
                  'Scan Stats',
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tab(
                child: Text(
                  'Raw Data',
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Tab(
                child: Text(
                  'User Scans',
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            if (_isSuperAdmin)
              IconButton(
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                onPressed: _showBulkDeleteOptions,
                tooltip: 'Bulk Delete Options',
              ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadData,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildUsersTab(),
                  _buildScanStatsTab(),
                  _buildRawDataTab(),
                  _buildUserScansTab(),
                ],
              ),
      ),
    );
  }

  void _showBulkDeleteOptions() {
    if (!_isSuperAdmin) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.people_outline, color: Colors.red),
                title: const Text('Delete All Pending Students'),
                onTap: () => _deleteAllPendingUsers('student'),
              ),
              ListTile(
                leading: const Icon(Icons.school_outlined, color: Colors.red),
                title: const Text('Delete All Pending Teachers'),
                onTap: () => _deleteAllPendingUsers('teacher'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete All Non-Admin Users'),
                onTap: _deleteAllNonAdminUsers,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.restart_alt, color: Colors.orange),
                title: const Text('Reset All Scan Data'),
                onTap: _resetScanData,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteAllPendingUsers(String role) async {
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Pending Users'),
          content: Text(
              'Are you sure you want to delete all pending ${role}s? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await _databaseHelper.deleteAllPendingUsers(role);
        await _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All pending ${role}s deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAllNonAdminUsers() async {
    bool? shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Non-Admin Users'),
          content: const Text(
              'Are you sure you want to delete all non-admin users? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await _databaseHelper.deleteAllNonAdminUsers();
        await _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All non-admin users deleted successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetScanData() async {
    bool? shouldReset = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset All Scan Data'),
          content: const Text(
              'Are you sure you want to reset all vegetable scan data? This will set all scan counts to zero.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: const Text('Reset Data'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      try {
        await _databaseHelper.resetVegetableScans();
        await _loadData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All scan data has been reset successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting scan data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUsersTab() {
    // Filter out super admin from display if not super admin
    final displayUsers = _isSuperAdmin
        ? _users
        : _users.where((user) => user['email'] != 'admin@gmail.com').toList();

    return displayUsers.isEmpty
        ? const Center(child: Text('No users found in database'))
        : SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildStatCard(
                        'Total Users',
                        displayUsers.length.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Pending Users',
                        displayUsers
                            .where((user) => user['status'] == 'pending')
                            .length
                            .toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Approved Users',
                        displayUsers
                            .where((user) => user['status'] == 'approved')
                            .length
                            .toString(),
                        Icons.verified,
                        Colors.green,
                      ),
                      if (_isSuperAdmin)
                        _buildStatCard(
                          'Admin Users',
                          displayUsers
                              .where((user) => user['role'] == 'admin')
                              .length
                              .toString(),
                          Icons.admin_panel_settings,
                          Colors.purple,
                        ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('ID')),
                      const DataColumn(label: Text('Username')),
                      const DataColumn(label: Text('Email')),
                      const DataColumn(label: Text('Role')),
                      const DataColumn(label: Text('Status')),
                      const DataColumn(label: Text('Age')),
                      const DataColumn(label: Text('Address')),
                      const DataColumn(label: Text('Adviser')),
                      const DataColumn(label: Text('Grade')),
                      if (_isSuperAdmin)
                        const DataColumn(
                          label: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 4),
                              Text('Actions',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                    rows: displayUsers.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user['id']?.toString() ?? 'N/A')),
                          DataCell(Text(user['username']?.toString() ?? 'N/A')),
                          DataCell(Text(user['email']?.toString() ?? 'N/A')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getRoleColor(user['role']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user['role']?.toString().toUpperCase() ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(user['status']),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user['status']?.toString().toUpperCase() ??
                                    'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(user['age']?.toString() ?? 'N/A')),
                          DataCell(
                            Container(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Text(
                                user['address']?.toString() ?? 'N/A',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(user['adviser']?.toString() ?? 'N/A')),
                          DataCell(Text(user['grade']?.toString() ?? 'N/A')),
                          if (_isSuperAdmin)
                            DataCell(
                              user['email'] == 'admin@gmail.com'
                                  ? const Tooltip(
                                      message: 'Cannot delete super admin',
                                      child:
                                          Icon(Icons.lock, color: Colors.grey),
                                    )
                                  : _buildDeleteButton(user),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildDeleteButton(Map<String, dynamic> user) {
    return Tooltip(
      message: 'Delete user',
      child: IconButton(
        icon: const Icon(Icons.delete_forever, color: Colors.red),
        onPressed: () => _deleteUser(
          user['id'],
          user['username']?.toString() ?? 'User',
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'teacher':
        return Colors.blue;
      case 'student':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildScanStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All User Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard(
                'Total Scans',
                _totalScans.toString(),
                Icons.scanner,
                Colors.green,
              ),
              _buildStatCard(
                'Total Vegetables',
                _vegetablesWithCounts.length.toString(),
                Icons.eco,
                Colors.teal,
              ),
              _buildStatCard(
                'Unique Vegetables Scanned',
                _vegetableScans.length.toString(),
                Icons.list_alt,
                Colors.purple,
              ),
              _buildStatCard(
                'User Scan Records',
                _userVegetableScans.length.toString(),
                Icons.people,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.analytics, size: 48, color: Colors.green),
                  const SizedBox(height: 12),
                  const Text(
                    'Total Scans',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_totalScans',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Text(
                    'across all vegetables',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Most Scanned Vegetables',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._vegetablesWithCounts.take(10).map((vegetable) {
            final scanCount = vegetable['scan_count'] ?? 0;
            final percentage =
                _totalScans > 0 ? (scanCount / _totalScans * 100) : 0;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.eco, color: Colors.green[700]),
                ),
                title: Text(
                  vegetable['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(vegetable['english']),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$scanCount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          if (_vegetablesWithCounts.length > 10)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('All Vegetable Scan Counts'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _vegetablesWithCounts.length,
                            itemBuilder: (context, index) {
                              final vegetable = _vegetablesWithCounts[index];
                              final scanCount = vegetable['scan_count'] ?? 0;
                              final percentage = _totalScans > 0
                                  ? (scanCount / _totalScans * 100)
                                  : 0;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green[50],
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  title: Text(vegetable['name']),
                                  subtitle: Text(vegetable['english']),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$scanCount',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('View All Vegetables'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRawDataTab() {
    return _vegetableScans.isEmpty
        ? const Center(child: Text('No vegetable scans found in database'))
        : SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                            'Total Records', _vegetableScans.length.toString()),
                        _buildSummaryItem(
                            'Total Scans', _totalScans.toString()),
                        _buildSummaryItem(
                            'Avg Scans/Record',
                            _vegetableScans.isNotEmpty
                                ? (_totalScans / _vegetableScans.length)
                                    .toStringAsFixed(1)
                                : '0'),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Vegetable Key')),
                      DataColumn(label: Text('Scan Count')),
                      DataColumn(label: Text('Last Scanned')),
                    ],
                    rows: _vegetableScans.map((scan) {
                      return DataRow(
                        cells: [
                          DataCell(Text(scan['id']?.toString() ?? 'N/A')),
                          DataCell(
                              Text(scan['vegetable_key']?.toString() ?? 'N/A')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                scan['scan_count']?.toString() ?? '0',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(
                            _formatDate(scan['last_scanned']?.toString()),
                            style: const TextStyle(fontSize: 12),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildUserScansTab() {
    // Filter out super admin scans
    final displayUserScans = _userVegetableScans
        .where((scan) => scan['email'] != 'admin@gmail.com')
        .toList();

    return displayUserScans.isEmpty
        ? const Center(child: Text('No user scan data found'))
        : SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildStatCard(
                        'Total User Scans',
                        displayUserScans.length.toString(),
                        Icons.scanner,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Unique Users',
                        displayUserScans
                            .map((scan) => scan['user_id'])
                            .toSet()
                            .length
                            .toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Unique Vegetables',
                        displayUserScans
                            .map((scan) => scan['vegetable_key'])
                            .toSet()
                            .length
                            .toString(),
                        Icons.eco,
                        Colors.teal,
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('User')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Vegetable')),
                      DataColumn(label: Text('Scanned At')),
                    ],
                    rows: displayUserScans.map((scan) {
                      return DataRow(
                        cells: [
                          DataCell(Text(scan['username']?.toString() ?? 'N/A')),
                          DataCell(Text(scan['email']?.toString() ?? 'N/A')),
                          DataCell(Text(scan['role']?.toString() ?? 'N/A')),
                          DataCell(
                              Text(scan['vegetable_key']?.toString() ?? 'N/A')),
                          DataCell(Text(
                              _formatDate(scan['scanned_at']?.toString()))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString == 'Never') return 'Never';
    try {
      final date = DateTime.parse(dateString);
      return '${date.month}/${date.day}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
