import 'package:firebase_database/firebase_database.dart';
import '../models/course_models.dart';
import '../models/note_models.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ─── COURSES ────────────────────────────────────────────────────────────────

  /// Tambah mata kuliah baru ke Firebase
  Future<void> addCourse(CourseModel course) async {
    await _db.child('courses').push().set(course.toMap());
  }

  /// Stream realtime semua mata kuliah
  Stream<List<CourseModel>> getCourses() {
    return _db.child('courses').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final map = Map<dynamic, dynamic>.from(data as Map);
      return map.entries
          .map(
            (e) => CourseModel.fromMap(
              e.key.toString(),
              Map<dynamic, dynamic>.from(e.value as Map),
            ),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  // ─── NOTES ──────────────────────────────────────────────────────────────────

  /// Tambah catatan baru ke Firebase
  Future<void> addNote(NoteModel note) async {
    await _db.child('notes').push().set(note.toMap());
  }

  /// Update catatan yang ada
  Future<void> updateNote(String id, NoteModel note) async {
    await _db.child('notes/$id').update(note.toMap());
  }

  /// Hapus catatan berdasarkan id
  Future<void> deleteNote(String id) async {
    await _db.child('notes/$id').remove();
  }

  /// Stream realtime semua catatan, diurutkan terbaru dulu
  Stream<List<NoteModel>> getNotes() {
    return _db.child('notes').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      final map = Map<dynamic, dynamic>.from(data as Map);
      return map.entries
          .map(
            (e) => NoteModel.fromMap(
              e.key.toString(),
              Map<dynamic, dynamic>.from(e.value as Map),
            ),
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  /// Stream catatan berdasarkan courseId tertentu
  Stream<List<NoteModel>> getNotesByCourse(String courseId) {
    return getNotes().map(
      (notes) => notes.where((n) => n.courseId == courseId).toList(),
    );
  }
}
