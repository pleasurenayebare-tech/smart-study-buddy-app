import 'package:flutter/material.dart';
import '../theme.dart';

class CourseSelectionScreen extends StatefulWidget {
  const CourseSelectionScreen({super.key});

  @override
  State<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  final List<String> _selectedCourses = [];
  String _searchQuery = '';
  String _selectedFaculty = 'All';

  final Map<String, List<Map<String, String>>> _facultyCourses = {
    'Computing & IT': [
      {'code': 'BCS 1101', 'name': 'Introduction to Programming'},
      {'code': 'BCS 1102', 'name': 'Computer Mathematics'},
      {'code': 'BCS 1103', 'name': 'Communication Skills'},
      {'code': 'BCS 1104', 'name': 'Introduction to Computer Systems'},
      {'code': 'BCS 2101', 'name': 'Data Structures & Algorithms'},
      {'code': 'BCS 2102', 'name': 'Object Oriented Programming'},
      {'code': 'BCS 2103', 'name': 'Computer Networks'},
      {'code': 'BCS 2104', 'name': 'Web Technologies'},
      {'code': 'BCS 2105', 'name': 'Database Systems'},
      {'code': 'BCS 2106', 'name': 'Systems Analysis & Design'},
      {'code': 'BCS 3101', 'name': 'Software Engineering'},
      {'code': 'BCS 3102', 'name': 'Operating Systems'},
      {'code': 'BCS 3103', 'name': 'Artificial Intelligence'},
      {'code': 'BCS 3104', 'name': 'Human Computer Interaction'},
      {'code': 'BCS 3105', 'name': 'Mobile Application Development'},
      {'code': 'BCS 3201', 'name': 'Information Security'},
      {'code': 'BCS 3202', 'name': 'Cloud Computing'},
      {'code': 'BCS 3203', 'name': 'Machine Learning'},
      {'code': 'BCS 4101', 'name': 'Final Year Project I'},
      {'code': 'BCS 4102', 'name': 'Final Year Project II'},
    ],
    'Engineering': [
      {'code': 'ELE 1101', 'name': 'Engineering Mathematics I'},
      {'code': 'ELE 1102', 'name': 'Engineering Physics'},
      {'code': 'ELE 1103', 'name': 'Introduction to Engineering'},
      {'code': 'ELE 2101', 'name': 'Circuit Theory'},
      {'code': 'ELE 2102', 'name': 'Electronics I'},
      {'code': 'ELE 2103', 'name': 'Digital Systems'},
      {'code': 'ELE 3101', 'name': 'Microprocessors & Microcontrollers'},
      {'code': 'ELE 3102', 'name': 'Communication Systems'},
      {'code': 'ELE 3103', 'name': 'Power Systems'},
      {'code': 'MEE 2101', 'name': 'Thermodynamics'},
      {'code': 'MEE 2102', 'name': 'Fluid Mechanics'},
      {'code': 'MEE 3101', 'name': 'Machine Design'},
      {'code': 'CVE 2101', 'name': 'Structural Analysis'},
      {'code': 'CVE 2102', 'name': 'Soil Mechanics'},
      {'code': 'CVE 3101', 'name': 'Highway Engineering'},
    ],
    'Medicine & Health': [
      {'code': 'MED 1101', 'name': 'Anatomy I'},
      {'code': 'MED 1102', 'name': 'Physiology I'},
      {'code': 'MED 1103', 'name': 'Biochemistry'},
      {'code': 'MED 2101', 'name': 'Pathology'},
      {'code': 'MED 2102', 'name': 'Pharmacology'},
      {'code': 'MED 2103', 'name': 'Microbiology'},
      {'code': 'MED 3101', 'name': 'Internal Medicine'},
      {'code': 'MED 3102', 'name': 'Surgery'},
      {'code': 'MED 3103', 'name': 'Pediatrics'},
      {'code': 'NRS 1101', 'name': 'Fundamentals of Nursing'},
      {'code': 'NRS 2101', 'name': 'Medical-Surgical Nursing'},
      {'code': 'PHR 1101', 'name': 'Pharmaceutical Chemistry'},
      {'code': 'PHR 2101', 'name': 'Pharmacognosy'},
    ],
    'Business & Economics': [
      {'code': 'BAM 1101', 'name': 'Principles of Management'},
      {'code': 'BAM 1102', 'name': 'Financial Accounting'},
      {'code': 'BAM 1103', 'name': 'Business Statistics'},
      {'code': 'BAM 2101', 'name': 'Marketing Management'},
      {'code': 'BAM 2102', 'name': 'Organizational Behaviour'},
      {'code': 'BAM 2103', 'name': 'Business Law'},
      {'code': 'BAM 3101', 'name': 'Strategic Management'},
      {'code': 'BAM 3102', 'name': 'Entrepreneurship'},
      {'code': 'ECO 1101', 'name': 'Microeconomics'},
      {'code': 'ECO 1102', 'name': 'Macroeconomics'},
      {'code': 'ECO 2101', 'name': 'Development Economics'},
      {'code': 'ECO 3101', 'name': 'International Economics'},
      {'code': 'ACC 2101', 'name': 'Cost Accounting'},
      {'code': 'ACC 3101', 'name': 'Auditing'},
    ],
    'Law': [
      {'code': 'LAW 1101', 'name': 'Introduction to Law'},
      {'code': 'LAW 1102', 'name': 'Constitutional Law'},
      {'code': 'LAW 2101', 'name': 'Law of Contract'},
      {'code': 'LAW 2102', 'name': 'Criminal Law'},
      {'code': 'LAW 2103', 'name': 'Law of Tort'},
      {'code': 'LAW 3101', 'name': 'Company Law'},
      {'code': 'LAW 3102', 'name': 'Land Law'},
      {'code': 'LAW 3103', 'name': 'International Law'},
      {'code': 'LAW 4101', 'name': 'Human Rights Law'},
    ],
    'Education': [
      {'code': 'EDU 1101', 'name': 'Introduction to Education'},
      {'code': 'EDU 1102', 'name': 'Educational Psychology'},
      {'code': 'EDU 2101', 'name': 'Curriculum Development'},
      {'code': 'EDU 2102', 'name': 'Teaching Methods'},
      {'code': 'EDU 3101', 'name': 'Educational Research'},
      {'code': 'EDU 3102', 'name': 'School Administration'},
      {'code': 'EDU 4101', 'name': 'Teaching Practice'},
    ],
    'Agriculture': [
      {'code': 'AGR 1101', 'name': 'Introduction to Agriculture'},
      {'code': 'AGR 1102', 'name': 'Soil Science'},
      {'code': 'AGR 2101', 'name': 'Crop Production'},
      {'code': 'AGR 2102', 'name': 'Animal Production'},
      {'code': 'AGR 3101', 'name': 'Agricultural Economics'},
      {'code': 'AGR 3102', 'name': 'Agricultural Extension'},
      {'code': 'VET 2101', 'name': 'Veterinary Medicine'},
    ],
    'Social Sciences': [
      {'code': 'SOC 1101', 'name': 'Introduction to Sociology'},
      {'code': 'SOC 1102', 'name': 'Social Research Methods'},
      {'code': 'PSY 1101', 'name': 'Introduction to Psychology'},
      {'code': 'PSY 2101', 'name': 'Developmental Psychology'},
      {'code': 'POL 1101', 'name': 'Introduction to Political Science'},
      {'code': 'POL 2101', 'name': 'International Relations'},
      {'code': 'SWK 1101', 'name': 'Introduction to Social Work'},
      {'code': 'SWK 2101', 'name': 'Community Development'},
    ],
  };

  List<Map<String, String>> get _filteredCourses {
    List<Map<String, String>> all = [];
    if (_selectedFaculty == 'All') {
      for (var courses in _facultyCourses.values) {
        all.addAll(courses);
      }
    } else {
      all = _facultyCourses[_selectedFaculty] ?? [];
    }
    if (_searchQuery.isEmpty) return all;
    return all.where((c) =>
      c['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      c['code']!.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F7),
      appBar: AppBar(
        title: const Text('Select Your Courses'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedCourses.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context, _selectedCourses),
              child: Text(
                'Done (${_selectedCourses.length})',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
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
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search courses...',
                      prefixIcon: Icon(Icons.search, color: AppTheme.primary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Faculty filter chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['All', ..._facultyCourses.keys].map((faculty) {
                      final selected = _selectedFaculty == faculty;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFaculty = faculty),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFFD700)
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFFFFD700)
                                    : Colors.white.withOpacity(0.4),
                              ),
                            ),
                            child: Text(
                              faculty,
                              style: TextStyle(
                                color: selected ? Colors.black87 : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
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

          // Selected count bar
          if (_selectedCourses.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLightBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedCourses.length} course${_selectedCourses.length == 1 ? '' : 's'} selected',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _selectedCourses.clear()),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Course list
          Expanded(
            child: _filteredCourses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'No courses found',
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    itemCount: _filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = _filteredCourses[index];
                      final code = course['code']!;
                      final name = course['name']!;
                      final isSelected = _selectedCourses.contains(code);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedCourses.remove(code);
                            } else {
                              _selectedCourses.add(code);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryLightBg
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.primaryLightBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    code.split(' ')[0],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: isSelected
                                            ? AppTheme.primary
                                            : const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      code,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? AppTheme.primaryLight
                                            : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
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
      floatingActionButton: _selectedCourses.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pop(context, _selectedCourses),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.check),
              label: Text(
                'Confirm ${_selectedCourses.length} Course${_selectedCourses.length == 1 ? '' : 's'}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }
}
