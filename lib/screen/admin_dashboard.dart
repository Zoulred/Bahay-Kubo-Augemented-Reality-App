import 'package:flutter/material.dart';
import 'package:ar_capstone2/utils/ARDatabaseSQLviewer.dart';
import 'package:ar_capstone2/utils/ARDatabaseSQL.dart';
import 'package:ar_capstone2/screen/ARLeaderboardScreen.dart'; // Add this import

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  int _totalUsers = 0;
  int _totalStudents = 0;
  int _totalTeachers = 0;
  int _pendingStudents = 0;
  int _pendingTeachers = 0;
  List<Map<String, dynamic>> _pendingStudentsList = [];
  List<Map<String, dynamic>> _pendingTeachersList = [];
  bool _isLoading = true;
  String? _currentUserRole;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStats();
    _loadPendingUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final users = await _databaseHelper.getAllUsers();
    setState(() {
      _totalUsers = users.length;
      _totalStudents = users.where((user) => user['role'] == 'student').length;
      _totalTeachers = users.where((user) => user['role'] == 'teacher').length;
      _pendingStudents = users
          .where((user) =>
              user['role'] == 'student' && user['status'] == 'pending')
          .length;
      _pendingTeachers = users
          .where((user) =>
              user['role'] == 'teacher' && user['status'] == 'pending')
          .length;
    });
  }

  Future<void> _loadPendingUsers() async {
    final students = await _databaseHelper.getPendingStudents();
    final teachers = await _databaseHelper.getPendingTeachers();
    setState(() {
      _pendingStudentsList = students;
      _pendingTeachersList = teachers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentUserRole == 'admin'
              ? 'Super Admin Dashboard'
              : 'Teacher Dashboard',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(
              child: Text(
                'Dashboard',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Tab(
              child: Text(
                'Pending Students',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Tab(
              child: Text(
                'Pending Teachers',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Tab(
              child: Text(
                'User Directory',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.green[50],
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(),
            _buildPendingStudentsTab(),
            _buildPendingTeachersTab(),
            DatabaseViewer(
              currentUserEmail:
                  _currentUserRole == 'admin' ? 'admin@gmail.com' : '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentUserRole == 'admin'
                ? 'Welcome, Super Admin!'
                : 'Welcome, Teacher!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(
                  'Total Users', _totalUsers.toString(), Icons.people),
              const SizedBox(width: 16),
              _buildStatCard(
                  'Students', _totalStudents.toString(), Icons.school),
              const SizedBox(width: 16),
              _buildStatCard(
                  'Teachers', _totalTeachers.toString(), Icons.person),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard('Pending Students', _pendingStudents.toString(),
                  Icons.hourglass_top, Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard('Pending Teachers', _pendingTeachers.toString(),
                  Icons.hourglass_top, Colors.deepPurple),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            'Management Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  'View Directory', 
                  Icons.storage,
                  Colors.blue,
                  () {
                    _tabController.animateTo(3);
                  },
                ),
                _buildDashboardCard(
                  'Pending Students',
                  Icons.hourglass_top,
                  Colors.orange,
                  () {
                    _tabController.animateTo(1);
                  },
                ),
                _buildDashboardCard(
                  'Pending Teachers',
                  Icons.hourglass_top,
                  Colors.deepPurple,
                  () {
                    _tabController.animateTo(2);
                  },
                ),
                _buildDashboardCard(
                  'Leaderboards',
                  Icons.leaderboard,
                  Colors.amber,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaderboardScreen(
                          currentUserRole: _currentUserRole,
                        ),
                      ),
                    );
                  },
                ),
                _buildDashboardCard(
                  'Content Management',
                  Icons.edit,
                  Colors.purple,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Content management feature coming soon!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                _buildDashboardCard(
                  'Reports',
                  Icons.assessment,
                  Colors.red,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reports feature coming soon!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
                if (_currentUserRole == 'admin')
                  _buildDashboardCard(
                    'Admin Management',
                    Icons.admin_panel_settings,
                    Colors.deepPurple,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Admin management feature coming soon!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingStudentsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _pendingStudentsList.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No Pending Students',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'All student accounts have been approved',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Students Pending Approval: ${_pendingStudentsList.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 175, 135, 76),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _pendingStudentsList.length,
                      itemBuilder: (context, index) {
                        final student = _pendingStudentsList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child:
                                  const Icon(Icons.person, color: Colors.green),
                            ),
                            title: Text(student['username']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student['email']),
                                if (student['grade'] != null)
                                  Text('Grade: ${student['grade']}'),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await _databaseHelper.updateUserStatus(
                                  student['id'],
                                  'approved',
                                );
                                _loadPendingUsers();
                                _loadStats();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Student approved successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 209, 76, 5),
                              ),
                              child: const Text(
                                'Approve',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
  }

  Widget _buildPendingTeachersTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _pendingTeachersList.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 80,
                      color: Colors.green,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No Pending Teachers',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'All teacher accounts have been approved',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Teachers Pending Approval: ${_pendingTeachersList.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 138, 43, 226),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _pendingTeachersList.length,
                      itemBuilder: (context, index) {
                        final teacher = _pendingTeachersList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple[100],
                              child: const Icon(Icons.person,
                                  color: Colors.deepPurple),
                            ),
                            title: Text(teacher['username']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(teacher['email']),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await _databaseHelper.updateUserStatus(
                                  teacher['id'],
                                  'approved',
                                );
                                _loadPendingUsers();
                                _loadStats();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Teacher approved successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 138, 43, 226),
                              ),
                              child: const Text(
                                'Approve',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      [Color? color]) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color ?? Colors.green[700],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
