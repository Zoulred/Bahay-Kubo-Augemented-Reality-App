import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bahay_kubo.db');
    return await openDatabase(
      path,
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'student',
        age INTEGER,
        address TEXT,
        adviser TEXT,
        grade TEXT,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE vegetable_scans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vegetable_key TEXT NOT NULL,
        scan_count INTEGER DEFAULT 0,
        last_scanned TEXT,
        UNIQUE(vegetable_key)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_vegetable_scans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        vegetable_key TEXT NOT NULL,
        scanned_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Insert default admin account
    await db.insert('users', {
      'username': 'Super Admin',
      'email': 'admin@gmail.com',
      'password': 'admin123',
      'role': 'admin',
      'status': 'approved',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT "student"');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE vegetable_scans(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vegetable_key TEXT NOT NULL,
          scan_count INTEGER DEFAULT 0,
          last_scanned TEXT,
          UNIQUE(vegetable_key)
        )
      ''');
    }

    if (oldVersion < 4) {
      await db.execute(
          'ALTER TABLE users ADD COLUMN status TEXT NOT NULL DEFAULT "pending"');

      List<Map<String, dynamic>> admin = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: ['admin@gmail.com'],
      );

      if (admin.isEmpty) {
        await db.insert('users', {
          'username': 'Super Admin',
          'email': 'admin@gmail.com',
          'password': 'admin123',
          'role': 'admin',
          'status': 'approved',
        });
      }
    }

    if (oldVersion < 5) {
      // Add any new schema changes for version 5
    }

    if (oldVersion < 6) {
      // Add any new schema changes for version 6
    }

    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_vegetable_scans(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          vegetable_key TEXT NOT NULL,
          scanned_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
    }
  }

  // USER MANAGEMENT METHODS

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<bool> userExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<bool> isValidUser(String email, String password) async {
    final user = await getUserByEmail(email);
    return user != null && user['password'] == password;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'id DESC');
  }

  Future<void> updateUserStatus(int userId, String status) async {
    final db = await database;
    await db.update(
      'users',
      {'status': status},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingStudents() async {
    final db = await database;
    return await db.query(
      'users',
      where: 'role = ? AND status = ?',
      whereArgs: ['student', 'pending'],
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getPendingTeachers() async {
    final db = await database;
    return await db.query(
      'users',
      where: 'role = ? AND status = ?',
      whereArgs: ['teacher', 'pending'],
      orderBy: 'id DESC',
    );
  }

  // USER DELETION METHODS

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteAllPendingUsers(String role) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'role = ? AND status = ?',
      whereArgs: [role, 'pending'],
    );
  }

  Future<void> deleteAllNonAdminUsers() async {
    final db = await database;
    await db.delete(
      'users',
      where: 'role != ?',
      whereArgs: ['admin'],
    );
  }

  Future<void> resetUserPassword(String email, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // VEGETABLE SCAN METHODS

  Future<void> recordVegetableScan(String vegetableKey) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    List<Map<String, dynamic>> results = await db.query(
      'vegetable_scans',
      where: 'vegetable_key = ?',
      whereArgs: [vegetableKey],
    );

    if (results.isNotEmpty) {
      await db.update(
        'vegetable_scans',
        {
          'scan_count': (results.first['scan_count'] as int) + 1,
          'last_scanned': now,
        },
        where: 'vegetable_key = ?',
        whereArgs: [vegetableKey],
      );
    } else {
      await db.insert('vegetable_scans', {
        'vegetable_key': vegetableKey,
        'scan_count': 1,
        'last_scanned': now,
      });
    }
  }

  Future<void> recordVegetableScanForUser(
      int userId, String vegetableKey) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    // Record in user_vegetable_scans table
    await db.insert('user_vegetable_scans', {
      'user_id': userId,
      'vegetable_key': vegetableKey,
      'scanned_at': now,
    });

    // Also update the general vegetable_scans table (existing functionality)
    List<Map<String, dynamic>> results = await db.query(
      'vegetable_scans',
      where: 'vegetable_key = ?',
      whereArgs: [vegetableKey],
    );

    if (results.isNotEmpty) {
      await db.update(
        'vegetable_scans',
        {
          'scan_count': (results.first['scan_count'] as int) + 1,
          'last_scanned': now,
        },
        where: 'vegetable_key = ?',
        whereArgs: [vegetableKey],
      );
    } else {
      await db.insert('vegetable_scans', {
        'vegetable_key': vegetableKey,
        'scan_count': 1,
        'last_scanned': now,
      });
    }
  }

  Future<void> recordVegetableScanByName(String vegetableName) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    String vegetableKey = vegetableName.toLowerCase().replaceAll(' ', '_');

    List<Map<String, dynamic>> results = await db.query(
      'vegetable_scans',
      where: 'vegetable_key = ?',
      whereArgs: [vegetableKey],
    );

    if (results.isNotEmpty) {
      await db.update(
        'vegetable_scans',
        {
          'scan_count': (results.first['scan_count'] as int) + 1,
          'last_scanned': now,
        },
        where: 'vegetable_key = ?',
        whereArgs: [vegetableKey],
      );
    } else {
      await db.insert('vegetable_scans', {
        'vegetable_key': vegetableKey,
        'scan_count': 1,
        'last_scanned': now,
      });
    }
  }
// ==================== VEGETABLE SCAN METHODS ====================

// ==================== GET SCAN COUNTS ====================

Future<int> getVegetableScanCount(String vegetableKey) async {
  final db = await database;
  final results = await _queryVegetableScansByKey(db, vegetableKey);
  
  return _extractScanCount(results);
}

Future<int> getVegetableScanCountByName(String vegetableName) async {
  final db = await database;
  final vegetableKey = _normalizeVegetableKey(vegetableName);
  final results = await _queryVegetableScansByKey(db, vegetableKey);
  
  return _extractScanCount(results);
}

Future<Map<String, int>> getAllVegetableScanCounts() async {
  final db = await database;
  final results = await _queryAllVegetableScans(db);
  
  return _buildScanCountsMap(results);
}

// ==================== GET ALL SCANS ====================

Future<List<Map<String, dynamic>>> getAllVegetableScans() async {
  final db = await database;
  return await _queryVegetableScansOrdered(db);
}

// ==================== RESET SCANS ====================

Future<void> resetVegetableScans() async {
  final db = await database;
  await _deleteAllVegetableScans(db);
}

Future<void> resetVegetableScan(String vegetableKey) async {
  final db = await database;
  await _deleteVegetableScanByKey(db, vegetableKey);
}

// ==================== PRIVATE HELPER METHODS ====================

// Query helpers
Future<List<Map<String, dynamic>>> _queryVegetableScansByKey(
  Database db,
  String vegetableKey,
) async {
  return await db.query(
    'vegetable_scans',
    where: 'vegetable_key = ?',
    whereArgs: [vegetableKey],
  );
}

Future<List<Map<String, dynamic>>> _queryAllVegetableScans(Database db) async {
  return await db.query('vegetable_scans');
}

Future<List<Map<String, dynamic>>> _queryVegetableScansOrdered(Database db) async {
  return await db.query(
    'vegetable_scans',
    orderBy: 'scan_count DESC',
  );
}

// Delete helpers
Future<void> _deleteAllVegetableScans(Database db) async {
  await db.delete('vegetable_scans');
}

Future<void> _deleteVegetableScanByKey(Database db, String vegetableKey) async {
  await db.delete(
    'vegetable_scans',
    where: 'vegetable_key = ?',
    whereArgs: [vegetableKey],
  );
}

// Data extraction helpers
int _extractScanCount(List<Map<String, dynamic>> results) {
  if (results.isNotEmpty) {
    return results.first['scan_count'] as int;
  }
  return 0;
}

Map<String, int> _buildScanCountsMap(List<Map<String, dynamic>> results) {
  final Map<String, int> scanCounts = {};
  for (final row in results) {
    scanCounts[row['vegetable_key'] as String] = row['scan_count'] as int;
  }
  return scanCounts;
}

// String helpers
String _normalizeVegetableKey(String vegetableName) {
  return vegetableName.toLowerCase().replaceAll(' ', '_');
}

// ==================== USER SCAN TRACKING METHODS ====================

// ==================== GET USER SCANS ====================

Future<List<Map<String, dynamic>>> getUserScanHistory(int userId) async {
  final db = await database;
  return await _queryUserScanHistory(db, userId);
}

Future<int> getUserTotalScanCount(int userId) async {
  final db = await database;
  final result = await _queryUserTotalScanCount(db, userId);
  return _extractCount(result);
}

// ==================== GET ALL USER SCANS ====================

Future<List<Map<String, dynamic>>> getAllUserVegetableScans() async {
  final db = await database;
  return await _queryAllUserVegetableScans(db);
}

// ==================== PRIVATE HELPER METHODS ====================

// Query helpers
Future<List<Map<String, dynamic>>> _queryUserScanHistory(
  Database db,
  int userId,
) async {
  return await db.query(
    'user_vegetable_scans',
    where: 'user_id = ?',
    whereArgs: [userId],
    orderBy: 'scanned_at DESC',
  );
}

Future<List<Map<String, dynamic>>> _queryUserTotalScanCount(
  Database db,
  int userId,
) async {
  return await db.rawQuery(
    'SELECT COUNT(*) as count FROM user_vegetable_scans WHERE user_id = ?',
    [userId],
  );
}

Future<List<Map<String, dynamic>>> _queryAllUserVegetableScans(Database db) async {
  return await db.rawQuery('''
    SELECT uvs.*, u.username, u.email, u.role 
    FROM user_vegetable_scans uvs
    JOIN users u ON uvs.user_id = u.id
    ORDER BY uvs.scanned_at DESC
  ''');
}

// Data extraction helpers
int _extractCount(List<Map<String, dynamic>> result) {
  return result.first['count'] as int? ?? 0;
}
  Future<Map<String, dynamic>> getUserScanStats(int userId) async {
    final db = await database;

    final totalScans = await getUserTotalScanCount(userId);

    final vegetableStats = await db.rawQuery('''
      SELECT vegetable_key, COUNT(*) as scan_count
      FROM user_vegetable_scans 
      WHERE user_id = ?
      GROUP BY vegetable_key
      ORDER BY scan_count DESC
    ''', [userId]);

    return {
      'total_scans': totalScans,
      'vegetable_stats': vegetableStats,
    };
  }

  // FIXED LEADERBOARD METHODS - EXCLUDE SUPER ADMIN
  Future<List<Map<String, dynamic>>> getTopScanners({int limit = 10}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        u.id,
        u.username,
        u.email,
        u.role,
        COUNT(uvs.id) as total_scans,
        MAX(uvs.scanned_at) as last_scan
      FROM users u
      LEFT JOIN user_vegetable_scans uvs ON u.id = uvs.user_id
      WHERE u.status = 'approved' AND u.email != 'admin@gmail.com'
      GROUP BY u.id
      ORDER BY total_scans DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, dynamic>>> getTopScannersThisWeek(
      {int limit = 10}) async {
    final db = await database;
    final weekAgo =
        DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

    return await db.rawQuery('''
      SELECT 
        u.id,
        u.username,
        u.email,
        u.role,
        COUNT(uvs.id) as weekly_scans,
        MAX(uvs.scanned_at) as last_scan
      FROM users u
      LEFT JOIN user_vegetable_scans uvs ON u.id = uvs.user_id 
        AND uvs.scanned_at > ?
      WHERE u.status = 'approved' AND u.email != 'admin@gmail.com'
      GROUP BY u.id
      ORDER BY weekly_scans DESC
      LIMIT ?
    ''', [weekAgo, limit]);
  }

  Future<List<Map<String, dynamic>>> getMostActiveUsers(
      {int limit = 10}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        u.id,
        u.username,
        u.email,
        u.role,
        COUNT(DISTINCT uvs.vegetable_key) as unique_vegetables,
        COUNT(uvs.id) as total_scans,
        MAX(uvs.scanned_at) as last_activity
      FROM users u
      LEFT JOIN user_vegetable_scans uvs ON u.id = uvs.user_id
      WHERE u.status = 'approved' AND u.email != 'admin@gmail.com'
      GROUP BY u.id
      ORDER BY total_scans DESC, unique_vegetables DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, dynamic>>> getStudentLeaderboard(
      {int limit = 20}) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        u.id,
        u.username,
        u.email,
        u.grade,
        u.adviser,
        COUNT(uvs.id) as total_scans,
        COUNT(DISTINCT uvs.vegetable_key) as unique_vegetables,
        MAX(uvs.scanned_at) as last_activity
      FROM users u
      LEFT JOIN user_vegetable_scans uvs ON u.id = uvs.user_id
      WHERE u.role = 'student' AND u.status = 'approved' AND u.email != 'admin@gmail.com'
      GROUP BY u.id
      ORDER BY total_scans DESC, unique_vegetables DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, dynamic>>> getGradeWiseLeaderboard() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        u.grade,
        COUNT(DISTINCT u.id) as total_students,
        COUNT(uvs.id) as total_scans,
        COUNT(DISTINCT uvs.vegetable_key) as unique_vegetables_scanned,
        ROUND(AVG(scans_per_user.scan_count), 2) as avg_scans_per_student
      FROM users u
      LEFT JOIN user_vegetable_scans uvs ON u.id = uvs.user_id
      LEFT JOIN (
        SELECT user_id, COUNT(*) as scan_count
        FROM user_vegetable_scans
        GROUP BY user_id
      ) scans_per_user ON u.id = scans_per_user.user_id
      WHERE u.role = 'student' AND u.status = 'approved' AND u.grade IS NOT NULL AND u.email != 'admin@gmail.com'
      GROUP BY u.grade
      ORDER BY total_scans DESC
    ''');
  }

  Future<Map<String, dynamic>?> getUserRanking(int userId) async {
    final db = await database;

    // Get user's total scans
    final userScans = await getUserTotalScanCount(userId);

    // Get ranking - EXCLUDE SUPER ADMIN
    final result = await db.rawQuery('''
      WITH user_scan_counts AS (
        SELECT 
          u.id,
          COUNT(uvs.id) as total_scans
        FROM users u
        LEFT JOIN user_vegetable_scans uvs ON u.id = uvs.user_id
        WHERE u.status = 'approved' AND u.email != 'admin@gmail.com'
        GROUP BY u.id
      )
      SELECT 
        (SELECT COUNT(*) FROM user_scan_counts WHERE total_scans > ?) + 1 as rank,
        (SELECT COUNT(*) FROM user_scan_counts) as total_users
      FROM user_scan_counts
      LIMIT 1
    ''', [userScans]);

    if (result.isNotEmpty) {
      return {
        'rank': result.first['rank'] as int,
        'total_users': result.first['total_users'] as int,
        'total_scans': userScans,
      };
    }

    return null;
  }

  // STATISTICS AND ANALYTICS METHODS

  Future<int> getTotalScanCount() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT SUM(scan_count) as total FROM vegetable_scans');
    return result.first['total'] as int? ?? 0;
  }

  Future<int> getTotalUsersCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getPendingUsersCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE status = ?', ['pending']);
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getApprovedUsersCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE status = ?', ['approved']);
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getAdminUsersCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE role = ?', ['admin']);
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getStudentUsersCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE role = ?', ['student']);
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getTeacherUsersCount() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM users WHERE role = ?', ['teacher']);
    return result.first['count'] as int? ?? 0;
  }

  Future<Map<String, dynamic>> getDatabaseStats() async {
    final db = await database;

    final totalUsers = await getTotalUsersCount();
    final pendingUsers = await getPendingUsersCount();
    final approvedUsers = await getApprovedUsersCount();
    final totalScans = await getTotalScanCount();
    final totalVegetables =
        await db.rawQuery('SELECT COUNT(*) as count FROM vegetable_scans');
    final adminUsers = await getAdminUsersCount();
    final studentUsers = await getStudentUsersCount();
    final teacherUsers = await getTeacherUsersCount();

    return {
      'total_users': totalUsers,
      'pending_users': pendingUsers,
      'approved_users': approvedUsers,
      'total_scans': totalScans,
      'total_vegetables': totalVegetables.first['count'] as int? ?? 0,
      'admin_users': adminUsers,
      'student_users': studentUsers,
      'teacher_users': teacherUsers,
    };
  }

  // ADVANCED QUERY METHODS

  Future<List<Map<String, dynamic>>> getTopScannedVegetables(
      {int limit = 10}) async {
    final db = await database;
    return await db.query(
      'vegetable_scans',
      orderBy: 'scan_count DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getRecentlyScannedVegetables(
      {int limit = 10}) async {
    final db = await database;
    return await db.query(
      'vegetable_scans',
      orderBy: 'last_scanned DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role],
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUsersByStatus(String status) async {
    final db = await database;
    return await db.query(
      'users',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'id DESC',
    );
  }

  // MAINTENANCE METHODS

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('vegetable_scans');
    await db.delete('user_vegetable_scans');

    // Reinsert admin account
    await db.insert('users', {
      'username': 'Super Admin',
      'email': 'admin@gmail.com',
      'password': 'admin123',
      'role': 'admin',
      'status': 'approved',
    });
  }

  Future<void> exportDatabase() async {
    await database;

    // Get all users
    final users = await getAllUsers();

    // Get all vegetable scans
    final vegetableScans = await getAllVegetableScans();

    // Get all user vegetable scans
    final userVegetableScans = await getAllUserVegetableScans();

    // This would typically export to a file or send to server
    // For now, we'll just return the data structure
    print('Database Export:');
    print('Users: $users');
    print('Vegetable Scans: $vegetableScans');
    print('User Vegetable Scans: $userVegetableScans');
  }

  Future<void> optimizeDatabase() async {
    final db = await database;
    await db.execute('VACUUM');
  }

  // ERROR HANDLING AND VALIDATION

  Future<bool> validateUserData(Map<String, dynamic> user) async {
    // Check required fields
    if (user['username'] == null || user['username'].toString().isEmpty) {
      return false;
    }
    if (user['email'] == null || user['email'].toString().isEmpty) {
      return false;
    }
    if (user['password'] == null || user['password'].toString().isEmpty) {
      return false;
    }

    // Check if email already exists
    final existingUser = await getUserByEmail(user['email']);
    return existingUser == null;
  }

  Future<List<String>> getDatabaseIssues() async {
    final db = await database;
    List<String> issues = [];

    // Check for users without required fields
    final invalidUsers = await db.rawQuery('''
      SELECT id, username, email FROM users 
      WHERE username IS NULL OR username = '' OR email IS NULL OR email = ''
    ''');

    if (invalidUsers.isNotEmpty) {
      issues.add(
          'Found ${invalidUsers.length} users with missing required fields');
    }

    // Check for duplicate emails (should be handled by UNIQUEutter constraint, but just in case)
    final duplicateEmails = await db.rawQuery('''
      SELECT email, COUNT(*) as count FROM users 
      GROUP BY email HAVING COUNT(*) > 1
    ''');

    if (duplicateEmails.isNotEmpty) {
      issues.add('Found duplicate emails in database');
    }

    return issues;
  }
}
