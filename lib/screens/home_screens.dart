import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'notes_screens.dart';
import 'courses_screens.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _service = FirebaseService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.school_rounded,
                color: theme.colorScheme.onPrimary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'CatatanKuliah',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Light Mode' : 'Dark Mode',
            onPressed: widget.onToggleTheme,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          indicatorColor: theme.colorScheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded), text: 'Mata Kuliah'),
            Tab(icon: Icon(Icons.notes_rounded), text: 'Catatan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CoursesScreen(service: _service),
          NotesScreen(service: _service),
        ],
      ),
    );
  }
}