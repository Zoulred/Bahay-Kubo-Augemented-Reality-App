import 'package:flutter/material.dart';
import 'package:ar_capstone2/utils/ARDatabaseSQL.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class LeaderboardScreen extends StatefulWidget {
  final int? currentUserId;
  final String? currentUserRole;

  const LeaderboardScreen(
      {super.key, this.currentUserId, this.currentUserRole});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Map<String, dynamic>> _topScanners = [];
  List<Map<String, dynamic>> _weeklyTopScanners = [];
  List<Map<String, dynamic>> _studentLeaderboard = [];
  List<Map<String, dynamic>> _gradeLeaderboard = [];
  Map<String, dynamic>? _userRanking;

  bool _isLoading = true;
  bool _isStudent = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isStudent = widget.currentUserRole == 'student';
    _tabController = TabController(length: _isStudent ? 3 : 4, vsync: this);
    _loadLeaderboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final topScanners = await _databaseHelper.getTopScanners(limit: 20);
      final weeklyTopScanners =
          await _databaseHelper.getTopScannersThisWeek(limit: 20);
      final studentLeaderboard =
          await _databaseHelper.getStudentLeaderboard(limit: 50);
      final gradeLeaderboard = await _databaseHelper.getGradeWiseLeaderboard();

      if (widget.currentUserId != null) {
        _userRanking =
            await _databaseHelper.getUserRanking(widget.currentUserId!);
      }

      setState(() {
        _topScanners = topScanners;
        _weeklyTopScanners = weeklyTopScanners;
        _studentLeaderboard = studentLeaderboard;
        _gradeLeaderboard = gradeLeaderboard;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading leaderboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _printGradeRankings() async {
    final action = await showDialog<PrintAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.print, color: Colors.green),
            SizedBox(width: 8),
            Text('Export Grade Rank'),
          ],
        ),
        content:
            const Text('Choose how you want to export the grade rankings:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, PrintAction.cancel),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, PrintAction.print),
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, PrintAction.savePdf),
            icon: const Icon(Icons.save),
            label: const Text('Save as PDF'),
          ),
        ],
      ),
    );

    switch (action) {
      case PrintAction.print:
        await _generateAndPrintPdf();
        break;
      case PrintAction.savePdf:
        await _savePdfToDevice();
        break;
      case PrintAction.share:
        await _sharePdf();
        break;
      case PrintAction.cancel:
      case null:
        break;
    }
  }

  Future<void> _generateAndPrintPdf() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final pdf = await _generatePdfDocument();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF ready for printing'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _savePdfToDevice() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Request storage permission
      if (await Permission.storage.request().isGranted) {
        final pdf = await _generatePdfDocument();
        final directory = await getExternalStorageDirectory();
        final downloadsDir = Directory('/storage/emulated/0/Download');

        String filePath;
        if (await downloadsDir.exists()) {
          filePath =
              '${downloadsDir.path}/Grade_Rankings_${DateTime.now().millisecondsSinceEpoch}.pdf';
        } else {
          filePath =
              '${directory?.path}/Grade_Rankings_${DateTime.now().millisecondsSinceEpoch}.pdf';
        }

        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _sharePdf() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final pdf = await _generatePdfDocument();
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/Grade_Rankings_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // For sharing, you would typically use the share package
      // For now, we'll show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF ready for sharing at: $filePath'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error preparing PDF for sharing: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<pw.Document> _generatePdfDocument() async {
    final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Grade Rankings Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Generated: ${DateTime.now().toString().split(' ')[0]}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Summary',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text('Total Grades: ${_gradeLeaderboard.length}'),
                        pw.Text('Total Students: ${_calculateTotalStudents()}'),
                        pw.Text('Total Scans: ${_calculateTotalScans()}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Student Performance Table
            pw.Text(
              'Student Performance',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),

            // Table Header
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.green100,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Rank',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Grade',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Students',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Total Scans',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Avg/Student',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Grade Data
            ..._gradeLeaderboard.asMap().entries.map((entry) {
              final index = entry.key;
              final grade = entry.value;
              final totalScans = grade['total_scans'] ?? 0;
              final totalStudents = grade['total_students'] ?? 0;
              final avgScans = grade['avg_scans_per_student'] ?? 0;

              return pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey300)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${index + 1}'),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(grade['grade']?.toString() ?? 'Unknown'),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(totalStudents.toString()),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(totalScans.toString()),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(avgScans.toStringAsFixed(1)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            pw.SizedBox(height: 20),

            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              child: pw.Text(
                'Generated by AR Vegetable Scanner App',
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  int _calculateTotalStudents() {
    return _gradeLeaderboard.fold<int>(
        0, (int sum, grade) => sum + ((grade['total_students'] as int?) ?? 0));
  }

  int _calculateTotalScans() {
    return _gradeLeaderboard.fold<int>(
        0, (int sum, grade) => sum + ((grade['total_scans'] as int?) ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activity Leaderboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(
          color: Colors.white, // This makes the back button white
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _isStudent ? _buildStudentTabs() : _buildAllUserTabs(),
        ),
        actions: [
          if (!_isStudent && _tabController.index == 3) // Grade Rankings tab
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : PopupMenuButton<PrintAction>(
                    icon: const Icon(Icons.print, color: Colors.white),
                    onSelected: (action) {
                      switch (action) {
                        case PrintAction.print:
                          _generateAndPrintPdf();
                          break;
                        case PrintAction.savePdf:
                          _savePdfToDevice();
                          break;
                        case PrintAction.share:
                          _sharePdf();
                          break;
                        case PrintAction.cancel:
                          // TODO: Handle this case.
                          throw UnimplementedError();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<PrintAction>(
                        value: PrintAction.print,
                        child: Row(
                          children: [
                            Icon(Icons.print, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Print'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<PrintAction>(
                        value: PrintAction.savePdf,
                        child: Row(
                          children: [
                            Icon(Icons.save, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Save as PDF'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<PrintAction>(
                        value: PrintAction.share,
                        child: Row(
                          children: [
                            Icon(Icons.share, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                    ],
                  ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isSaving ? null : _loadLeaderboardData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children:
              _isStudent ? _buildStudentTabViews() : _buildAllUserTabViews(),
        ),
      ),
    );
  }

  List<Widget> _buildStudentTabs() {
    return const [
      Tab(text: 'My Ranking'),
      Tab(text: 'Class Rankings'),
      Tab(text: 'Grade Rankings'),
    ];
  }

  List<Widget> _buildAllUserTabs() {
    return const [
      Tab(
        child: Text(
          'All Time Top',
          style: TextStyle(color: Colors.white),
        ),
      ),
      Tab(
        child: Text(
          'Weekly Top',
          style: TextStyle(color: Colors.white),
        ),
      ),
      Tab(
        child: Text(
          'Student Rankings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      Tab(
        child: Text(
          'Grade Rankings',
          style: TextStyle(color: Colors.white),
        ),
      ),
    ];
  }

  List<Widget> _buildStudentTabViews() {
    return [
      _buildMyRankingTab(),
      _buildStudentLeaderboardTab(),
      _buildGradeLeaderboardTab(),
    ];
  }

  List<Widget> _buildAllUserTabViews() {
    return [
      _buildAllTimeLeaderboardTab(),
      _buildWeeklyLeaderboardTab(),
      _buildStudentLeaderboardTab(),
      _buildGradeLeaderboardTab(),
    ];
  }

  Widget _buildMyRankingTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_userRanking != null) ...[
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.green[400]!,
                      Colors.green[700]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 60,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rank #${_userRanking!['rank']}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'out of ${_userRanking!['total_users']} users',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_userRanking!['total_scans']} Total Scans',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Progress to next rank
          if (_userRanking != null && _userRanking!['rank']! > 1)
            _buildNextRankProgress(),

          const SizedBox(height: 24),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Your Rank',
                  '#${_userRanking?['rank'] ?? 'N/A'}',
                  Icons.leaderboard,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Total Scans',
                  '${_userRanking?['total_scans'] ?? 0}',
                  Icons.scanner,
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Top 5 for motivation
          _buildTopPerformersPreview(),
        ],
      ),
    );
  }

  Widget _buildNextRankProgress() {
    final currentRank = _userRanking!['rank'] as int;
    final currentScans = _userRanking!['total_scans'] as int;

    // Find the user at the next higher rank
    int? nextRankScans;
    for (var user in _studentLeaderboard) {
      if (user['total_scans'] != null && user['total_scans'] > currentScans) {
        nextRankScans = user['total_scans'] as int;
        break;
      }
    }

    if (nextRankScans == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.emoji_events, size: 40, color: Colors.amber),
              const SizedBox(height: 8),
              const Text(
                'You are the top scanner!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Keep up the great work!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final scansNeeded = nextRankScans - currentScans;
    final progress = currentScans / nextRankScans;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress to Rank #${currentRank - 1}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentScans scans',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '$nextRankScans scans needed',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$scansNeeded more scans to reach next rank',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformersPreview() {
    final top5 = _studentLeaderboard.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 5 Performers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...top5.asMap().entries.map((entry) {
              final index = entry.key;
              final user = entry.value;
              return _buildLeaderboardTile(user, index + 1, showGrade: true);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTimeLeaderboardTab() {
    return _buildLeaderboardList(_topScanners, 'All Time Top Scanners');
  }

  Widget _buildWeeklyLeaderboardTab() {
    return _buildLeaderboardList(
        _weeklyTopScanners, 'This Week\'s Top Scanners');
  }

  Widget _buildStudentLeaderboardTab() {
    return _buildLeaderboardList(_studentLeaderboard, 'Student Rankings',
        showGrade: true);
  }

  Widget _buildGradeLeaderboardTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Student Performance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_isStudent)
                _isSaving
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _printGradeRankings,
                        icon: const Icon(Icons.print),
                        label: const Text('Export'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
            ],
          ),
          const SizedBox(height: 16),
          ..._gradeLeaderboard.asMap().entries.map((entry) {
            final index = entry.key;
            final grade = entry.value;
            return _buildGradeLeaderboardCard(grade, index + 1);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<Map<String, dynamic>> data, String title,
      {bool showGrade = false}) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No data available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final user = data[index];
              return _buildLeaderboardTile(user, index + 1,
                  showGrade: showGrade);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(Map<String, dynamic> user, int rank,
      {bool showGrade = false}) {
    final totalScans = user['total_scans'] ?? user['weekly_scans'] ?? 0;
    final uniqueVegetables = user['unique_vegetables'] ?? 0;
    final isCurrentUser = widget.currentUserId == user['id'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isCurrentUser ? 4 : 1,
      color: isCurrentUser ? Colors.green[50] : Colors.white,
      child: ListTile(
        leading: _buildRankBadge(rank),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user['username'] ?? 'Unknown',
                style: TextStyle(
                  fontWeight:
                      isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentUser ? Colors.green[700] : Colors.black,
                ),
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showGrade && user['grade'] != null)
              Text('Grade: ${user['grade']}'),
            if (user['adviser'] != null &&
                user['adviser'].toString().isNotEmpty)
              Text('Adviser: ${user['adviser']}'),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatChip(Icons.scanner, '$totalScans scans'),
                const SizedBox(width: 8),
                if (uniqueVegetables > 0)
                  _buildStatChip(Icons.eco, '$uniqueVegetables veggies'),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$totalScans',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Text(
              'scans',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeLeaderboardCard(Map<String, dynamic> grade, int rank) {
    final totalScans = grade['total_scans'] ?? 0;
    final totalStudents = grade['total_students'] ?? 0;
    final uniqueVegetables = grade['unique_vegetables_scanned'] ?? 0;
    final avgScans = grade['avg_scans_per_student'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildRankBadge(rank),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grade['grade'] ?? 'Unknown Grade',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildGradeStat('Students', totalStudents.toString()),
                      _buildGradeStat('Total Scans', totalScans.toString()),
                      _buildGradeStat(
                          'Unique Veggies', uniqueVegetables.toString()),
                      _buildGradeStat(
                          'Avg/Student', avgScans.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    IconData? icon;

    switch (rank) {
      case 1:
        badgeColor = Colors.amber;
        icon = Icons.emoji_events;
        break;
      case 2:
        badgeColor = Colors.grey;
        icon = Icons.emoji_events;
        break;
      case 3:
        badgeColor = Colors.orange;
        icon = Icons.emoji_events;
        break;
      default:
        badgeColor = Colors.green;
        icon = null;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 24)
            : Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum PrintAction {
  print,
  savePdf,
  share,
  cancel,
}
