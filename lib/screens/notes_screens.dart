import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/note_model.dart';
import '../models/course_model.dart';

class NotesScreen extends StatefulWidget {
  final FirebaseService service;

  const NotesScreen({super.key, required this.service});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  CourseModel? _selectedCourse;
  bool _isLoading = false;
  String _searchQuery = '';
  String _filterCourseId = '';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourse == null) return;

    setState(() => _isLoading = true);
    try {
      await widget.service.addNote(NoteModel(
        id: '',
        courseId: _selectedCourse!.id,
        courseName: _selectedCourse!.name,
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      ));
      _titleCtrl.clear();
      _contentCtrl.clear();
      setState(() => _selectedCourse = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Catatan berhasil disimpan!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddNoteSheet(List<CourseModel> courses) {
    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Tambahkan mata kuliah terlebih dahulu!'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Tambah Catatan',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  // Dropdown Mata Kuliah
                  DropdownButtonFormField<CourseModel>(
                    initialValue: _selectedCourse,
                    decoration: InputDecoration(
                      labelText: 'Pilih Mata Kuliah',
                      prefixIcon: const Icon(Icons.book_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: courses
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) {
                      setSheetState(() => _selectedCourse = v);
                    },
                    validator: (v) => v == null ? 'Pilih mata kuliah' : null,
                  ),
                  const SizedBox(height: 16),
                  // Judul
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Judul Catatan',
                      prefixIcon: const Icon(Icons.title_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  // Isi Catatan
                  TextFormField(
                    controller: _contentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Isi Catatan',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 56),
                        child: Icon(Icons.notes_rounded),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              await _addNote();
                              if (mounted && !_isLoading) {
                                Navigator.pop(ctx);
                              }
                            },
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Catatan'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNoteSheet(NoteModel note, List<CourseModel> courses) {
    final editTitleCtrl = TextEditingController(text: note.title);
    final editContentCtrl = TextEditingController(text: note.content);
    CourseModel? editCourse;
    try {
      editCourse = courses.firstWhere((c) => c.id == note.courseId);
    } catch (_) {}

    final editFormKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: editFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Edit Catatan',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<CourseModel>(
                    initialValue: editCourse,
                    decoration: InputDecoration(
                      labelText: 'Pilih Mata Kuliah',
                      prefixIcon: const Icon(Icons.book_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: courses
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setSheetState(() => editCourse = v),
                    validator: (v) => v == null ? 'Pilih mata kuliah' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: editTitleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Judul Catatan',
                      prefixIcon: const Icon(Icons.title_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: editContentCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Isi Catatan',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 56),
                        child: Icon(Icons.notes_rounded),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: saving
                          ? null
                          : () async {
                              if (!editFormKey.currentState!.validate()) return;
                              setSheetState(() => saving = true);
                              try {
                                await widget.service.updateNote(
                                  note.id,
                                  NoteModel(
                                    id: note.id,
                                    courseId: editCourse!.id,
                                    courseName: editCourse!.name,
                                    title: editTitleCtrl.text.trim(),
                                    content: editContentCtrl.text.trim(),
                                    timestamp: note.timestamp,
                                  ),
                                );
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Catatan berhasil diupdate!'),
                                      backgroundColor: Colors.green.shade600,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              } catch (e) {
                                setSheetState(() => saving = false);
                              }
                            },
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(saving ? 'Menyimpan...' : 'Update Catatan'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah kamu yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.service.deleteNote(noteId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Catatan dihapus'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<CourseModel>>(
      stream: widget.service.getCourses(),
      builder: (context, courseSnap) {
        final courses = courseSnap.data ?? [];

        return StreamBuilder<List<NoteModel>>(
          stream: widget.service.getNotes(),
          builder: (context, noteSnap) {
            if (noteSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            List<NoteModel> notes = noteSnap.data ?? [];

            // Filter by course
            if (_filterCourseId.isNotEmpty) {
              notes = notes
                  .where((n) => n.courseId == _filterCourseId)
                  .toList();
            }

            // Filter by search query
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              notes = notes
                  .where((n) =>
                      n.title.toLowerCase().contains(q) ||
                      n.content.toLowerCase().contains(q) ||
                      n.courseName.toLowerCase().contains(q))
                  .toList();
            }

            return Scaffold(
              body: Column(
                children: [
                  // Search & Filter bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      children: [
                        // Search Field
                        TextField(
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'Cari catatan...',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () =>
                                        setState(() => _searchQuery = ''),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Course Filter Chips
                        if (courses.isNotEmpty)
                          SizedBox(
                            height: 36,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _FilterChip(
                                  label: 'Semua',
                                  selected: _filterCourseId.isEmpty,
                                  onSelected: () =>
                                      setState(() => _filterCourseId = ''),
                                ),
                                ...courses.map((c) => _FilterChip(
                                      label: c.name,
                                      selected: _filterCourseId == c.id,
                                      onSelected: () => setState(
                                          () => _filterCourseId = c.id),
                                    )),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Notes count info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          '${notes.length} Catatan',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Notes list
                  Expanded(
                    child: notes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.note_alt_outlined,
                                    size: 80,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.4)),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Catatan tidak ditemukan'
                                      : 'Belum ada catatan',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tekan tombol + untuk menambahkan',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: notes.length,
                            itemBuilder: (ctx, i) {
                              final note = notes[i];
                              return _NoteCard(
                                note: note,
                                onEdit: () =>
                                    _showEditNoteSheet(note, courses),
                                onDelete: () => _confirmDelete(note.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _showAddNoteSheet(courses),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Tambah Catatan'),
              ),
            );
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  static const _colors = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colors[note.courseName.length % _colors.length];
    final fmt = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    final dateStr = fmt.format(note.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    note.courseName,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Edit',
                  color: theme.colorScheme.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Hapus',
                  color: Colors.red.shade400,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Title
            Text(
              note.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            // Content preview
            Text(
              note.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            // Timestamp
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.45),
                ),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}