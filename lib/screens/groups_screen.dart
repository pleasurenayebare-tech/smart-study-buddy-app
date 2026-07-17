import 'package:flutter/material.dart';
import '../theme.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final List<Map<String, dynamic>> _allGroups = [
    // Computing & IT
    {'name': 'Introduction to Programming', 'course': 'BCS 1101', 'members': 24, 'joined': false, 'faculty': 'Computing & IT'},
    {'name': 'Computer Mathematics', 'course': 'BCS 1102', 'members': 18, 'joined': false, 'faculty': 'Computing & IT'},
    {'name': 'Data Structures & Algorithms', 'course': 'BCS 2101', 'members': 31, 'joined': false, 'faculty': 'Computing & IT'},
    {'name': 'Object Oriented Programming', 'course': 'BCS 2102', 'members': 22, 'joined': false, 'faculty': 'Computing & IT'},
    {'name': 'Computer Networks', 'course': 'BCS 2103', 'members': 19, 'joined': false, 'faculty': 'Computing & IT'},
    {'name': 'Web Technologies', 'course': 'BCS 2104', 'members': 27, 'joined': false, 'faculty': 'Computing & IT'},
    {'name': 'Database Systems', 'course': 'BCS 2105', 'members': 33, 'joined': true, 'faculty': 'Computing & IT'},
    {'name': 'Software Engineering', 'course': 'BCS 3101', 'members': 21, 'joined': false, 'faculty': 'Computing & IT'},
    {'name': 'Operating Systems', 'course': 'BCS 3102', 'members': 16, 'joined': false, 'faculty': 'Computing & IT'},
    {'name': 'Mobile App Development', 'course': 'BCS 3105', 'members': 29, 'joined': true, 'faculty': 'Computing & IT'},
    {'name': 'Artificial Intelligence', 'course': 'BCS 3103', 'members': 14, 'joined': false, 'faculty': 'Computing & IT'},
    {'name': 'Information Security', 'course': 'BCS 3201', 'members': 11, 'joined': false, 'faculty': 'Computing & IT'},
    // Engineering
    {'name': 'Engineering Mathematics', 'course': 'ELE 1101', 'members': 20, 'joined': false, 'faculty': 'Engineering'},
    {'name': 'Circuit Theory', 'course': 'ELE 2101', 'members': 15, 'joined': false, 'faculty': 'Engineering'},
    {'name': 'Digital Systems', 'course': 'ELE 2103', 'members': 18, 'joined': false, 'faculty': 'Engineering'},
    {'name': 'Thermodynamics', 'course': 'MEE 2101', 'members': 13, 'joined': false, 'faculty': 'Engineering'},
    {'name': 'Fluid Mechanics', 'course': 'MEE 2102', 'members': 17, 'joined': false, 'faculty': 'Engineering'},
    {'name': 'Structural Analysis', 'course': 'CVE 2101', 'members': 12, 'joined': false, 'faculty': 'Engineering'},
    // Business & Economics
    {'name': 'Principles of Management', 'course': 'BAM 1101', 'members': 35, 'joined': false, 'faculty': 'Business & Economics'},
    {'name': 'Financial Accounting', 'course': 'BAM 1102', 'members': 28, 'joined': false, 'faculty': 'Business & Economics'},
    {'name': 'Microeconomics', 'course': 'ECO 1101', 'members': 22, 'joined': false, 'faculty': 'Business & Economics'},
    {'name': 'Marketing Management', 'course': 'BAM 2101', 'members': 19, 'joined': false, 'faculty': 'Business & Economics'},
    // Law
    {'name': 'Introduction to Law', 'course': 'LAW 1101', 'members': 16, 'joined': false, 'faculty': 'Law'},
    {'name': 'Constitutional Law', 'course': 'LAW 1102', 'members': 14, 'joined': false, 'faculty': 'Law'},
    {'name': 'Law of Contract', 'course': 'LAW 2101', 'members': 18, 'joined': false, 'faculty': 'Law'},
    // Medicine
    {'name': 'Anatomy Study Group', 'course': 'MED 1101', 'members': 20, 'joined': false, 'faculty': 'Medicine & Health'},
    {'name': 'Physiology Study Group', 'course': 'MED 1102', 'members': 17, 'joined': false, 'faculty': 'Medicine & Health'},
    {'name': 'Pharmacology Group', 'course': 'MED 2102', 'members': 15, 'joined': false, 'faculty': 'Medicine & Health'},
    // Education
    {'name': 'Educational Psychology', 'course': 'EDU 1102', 'members': 21, 'joined': false, 'faculty': 'Education'},
    {'name': 'Teaching Methods Group', 'course': 'EDU 2102', 'members': 19, 'joined': false, 'faculty': 'Education'},
  ];

  String _selectedFaculty = 'All';
  String _searchQuery = '';
  bool _showJoinedOnly = false;

  List<Map<String, dynamic>> get _filteredGroups {
    return _allGroups.where((g) {
      final matchesFaculty = _selectedFaculty == 'All' || g['faculty'] == _selectedFaculty;
      final matchesSearch = _searchQuery.isEmpty ||
          g['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g['course'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesJoined = !_showJoinedOnly || g['joined'] == true;
      return matchesFaculty && matchesSearch && matchesJoined;
    }).toList();
  }

  final List<String> _faculties = [
    'All', 'Computing & IT', 'Engineering', 'Business & Economics',
    'Law', 'Medicine & Health', 'Education'
  ];

  @override
  Widget build(BuildContext context) {
    final joinedCount = _allGroups.where((g) => g['joined'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7),
      appBar: AppBar(
        title: const Text('Study Groups'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showJoinedOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showJoinedOnly ? const Color(0xFFFFD700) : Colors.white,
            ),
            onPressed: () => setState(() => _showJoinedOnly = !_showJoinedOnly),
            tooltip: 'Show joined only',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Stats row
                Row(
                  children: [
                    _buildStatPill('${_allGroups.length} Groups', Icons.group),
                    const SizedBox(width: 8),
                    _buildStatPill('$joinedCount Joined', Icons.check_circle),
                  ],
                ),
                const SizedBox(height: 12),
                // Search
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search groups or course codes...',
                      prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Faculty chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _faculties.map((f) {
                      final selected = _selectedFaculty == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFaculty = f),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: selected ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: selected ? Colors.black87 : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // Groups list
          Expanded(
            child: _filteredGroups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'No groups found',
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    itemCount: _filteredGroups.length,
                    itemBuilder: (context, index) {
                      final group = _filteredGroups[index];
                      final isJoined = group['joined'] as bool;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isJoined
                                ? AppTheme.primary.withOpacity(0.3)
                                : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: isJoined
                                      ? AppTheme.primaryLightBg
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.group_rounded,
                                  color: isJoined ? AppTheme.primary : Colors.grey,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryLightBg,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            group['course'],
                                            style: const TextStyle(
                                              color: AppTheme.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.people_outline,
                                          size: 12,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${group['members']} members',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    group['joined'] = !isJoined;
                                    if (!isJoined) {
                                      group['members'] = (group['members'] as int) + 1;
                                    } else {
                                      group['members'] = (group['members'] as int) - 1;
                                    }
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isJoined
                                            ? 'Left ${group['name']}'
                                            : 'Joined ${group['name']}!',
                                      ),
                                      backgroundColor: isJoined
                                          ? Colors.grey
                                          : AppTheme.primary,
                                      duration: const Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isJoined
                                        ? Colors.grey.shade100
                                        : AppTheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isJoined
                                          ? Colors.grey.shade300
                                          : AppTheme.primary,
                                    ),
                                  ),
                                  child: Text(
                                    isJoined ? 'Joined ✓' : 'Join',
                                    style: TextStyle(
                                      color: isJoined
                                          ? Colors.grey[600]
                                          : Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupDialog() {
    final nameController = TextEditingController();
    final courseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Study Group',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  prefixIcon: const Icon(Icons.group, color: AppTheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: courseController,
                decoration: InputDecoration(
                  labelText: 'Course Code (e.g. BCS 2105)',
                  prefixIcon: const Icon(Icons.school, color: AppTheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            courseController.text.isNotEmpty) {
                          setState(() {
                            _allGroups.insert(0, {
                              'name': nameController.text,
                              'course': courseController.text.toUpperCase(),
                              'members': 1,
                              'joined': true,
                              'faculty': 'Computing & IT',
                            });
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Group "${nameController.text}" created!'),
                              backgroundColor: AppTheme.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                      ),
                      child: const Text('Create'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
